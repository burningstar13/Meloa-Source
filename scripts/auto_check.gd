extends RefCounted
class_name AutoCheck






































const FxEval = preload("res://scripts/fx_eval.gd")






static var _guide_script = null



const DT: = 1.0 / 120.0

const MAX_SIM_SECONDS: = 900.0


const LEAD_IN: = 2.5
const TAIL_OUT: = 3.0


const ZONE_MERGE: = 0.45


const ZONE_PAD: = 0.12


const MAX_PROBLEMS: = 200

const SCREEN_W: = 1280.0
const LANE_COUNT: = 3



static func empty() -> Dictionary:
	return {"ok": true, "playable": true, "perfect": 0, "good": 0, "meh": 0, "miss": 0, 
		"judged": 0, "expected": 0, "accuracy": 100.0, 
		"breaks": 0, "problems": [], "zones": [], "sim_dt": DT, "sim_steps": 0, 
		"sim_ms": 0.0, "warnings": []}








static func run(data: Dictionary, tuning, opts: = {}) -> Dictionary:
	var t_start: = Time.get_ticks_usec()
	var dt: float = float(opts.get("dt", DT))
	var out: = empty()
	out.sim_dt = dt
	var raw = data.get("notes", [])
	if not (raw is Array) or (raw as Array).is_empty():
		return out

	var notes: = _prepare(raw as Array, data, tuning, out.warnings)
	if notes.is_empty():
		return out

	var fx_raw = data.get("fx", [])
	var fx: = FxEval.build(fx_raw if fx_raw is Array else [], 
		float(tuning.lane_width), float(tuning.lane_gap), SCREEN_W)

	var sim: = {
		"t": 0.0, "dt": dt, "tuning": tuning, "fx": fx, 
		"notes": notes, "next_spawn": 0, "live": [], 
		"cursor": Vector2(SCREEN_W * 0.5, float(tuning.hit_y)), 
		"lane": 1, "lane_x": [0.0, 0.0, 0.0], 
		"perfect": 0, "good": 0, "meh": 0, "miss": 0, "breaks": 0, 
		"problems": [], "n_problems": 0, 
		"kiai": _kiai_of(data), "vmult": float(tuning.kiai_velocity_mult), 
	}
	var first: float = float(notes[0].time)
	var last: = 0.0
	for n in notes:
		last = maxf(last, float(n.time) + float(n.get("duration", 0.0)))
	var t: = first - LEAD_IN
	var t_end: float = minf(last + TAIL_OUT, t + MAX_SIM_SECONDS)

	sim.lane_x = _lanes_at(fx, tuning, t)
	var steps: = 0
	while t <= t_end:
		sim.t = t

		sim.lane_x = _lanes_at(fx, tuning, t)
		_spawn_due(sim)
		_run_auto(sim)
		_judge_expired(sim)
		_update_beams(sim)
		_update_sliders(sim)
		_purge(sim)
		t += dt
		steps += 1


	for n in sim.live:
		if not n.judged:
			_problem(sim, float(n.time), "unresolved", n, 
				"objet jamais résolu — la map se termine avant sa fin")

	out.perfect = int(sim.perfect)
	out.good = int(sim.good)
	out.meh = int(sim.meh)
	out.miss = int(sim.miss)
	out.breaks = int(sim.breaks)
	out.judged = out.perfect + out.good + out.meh + out.miss
	out.expected = _expected_judgements(notes)
	out.problems = sim.problems
	out.zones = _zones(sim.problems)



	for n in notes:
		if n.has("guide") and is_instance_valid(n.guide):
			n.guide.free()
	out.sim_steps = steps
	out.sim_ms = float(Time.get_ticks_usec() - t_start) / 1000.0



	out.accuracy = 100.0 * float(out.perfect) / maxf(float(out.judged), 1.0)












	out.ok = out.judged > 0 and out.perfect == out.judged\
	and out.breaks == 0 and out.judged >= out.expected
	out.playable = out.judged > 0 and out.miss == 0\
	and out.breaks == 0 and out.judged >= out.expected
	if out.judged < out.expected:
		out.warnings.append(
			"%d jugement(s) attendu(s), %d rendu(s) : des objets n'ont jamais été atteints"
			%[out.expected, out.judged])
	return out




static func _expected_judgements(notes: Array) -> int:
	var n: = 0
	for o in notes:
		n += 1
		var tp: = String(o.type)
		if tp == "sliderg" or tp == "sliderm" or tp == "beam":
			n += 1
		elif tp == "clickx":
			n += (o.hits as Array).size() - 1
	return n









static func _prepare(raw: Array, data: Dictionary, tuning, 
		warnings: Array) -> Array:
	var vel: float = clampf(float(data.get("velocity", 1.0)), 0.1, 10.0)
	var out: Array = []
	var skipped: = 0
	for item in raw:
		if not (item is Dictionary) or not item.has("time") or not item.has("type"):
			skipped += 1
			continue
		var nd: Dictionary = item
		var tp: = String(nd.type)
		var time: = float(nd.get("time", 0.0))
		if not is_finite(time):
			skipped += 1
			continue
		var o: = {
			"type": tp, 
			"time": time, 
			"lane": clampi(int(nd.get("lane", 1)), 0, LANE_COUNT - 1), 
			"v": clampf(float(nd.get("v", 1.0)), 0.05, 20.0), 
			"vel": vel, 
			"judged": false, "spawned": false, 
			"duration": 0.0, 
		}
		o["pos"] = _click_pos(nd)
		match tp:
			"sliderg":
				o.duration = maxf(float(nd.get("duration", 1.0)), 0.02)



				if _guide_script == null:
					_guide_script = load("res://scripts/slider_guide.gd")
				var g = _guide_script.new()
				g.time = time
				g.duration = o.duration
				for p in _tuples(nd.get("points", []), 3):
					g.points.append([float(p[0]), Vector2(float(p[1]), float(p[2]))])
				if g.points.is_empty():
					g.points.append([0.0, o.pos])
				o["guide"] = g
				o["pos"] = g.pos_at(0.0)
				o["caught"] = false
				o["head_missed"] = false
				o["held_time"] = 0.0
				o["catch_late"] = 0.0
				o["off_time"] = 0.0
				o["grace"] = 0.0
				o["next_tick"] = 0.0
			"sliderm":
				o.duration = maxf(float(nd.get("duration", 1.0)), 0.02)
				o["caught"] = false
				o["head_missed"] = false
				o["held_time"] = 0.0
				o["catch_late"] = 0.0
				o["off_time"] = 0.0
				o["grace"] = 0.0
				o["next_tick"] = 0.0
			"beam":
				o.duration = maxf(float(nd.get("duration", 1.0)), 0.02)
				o["path"] = _tuples(nd.get("path", []), 2)
				o["caught"] = false
				o["grace"] = 0.0
				o["next_tick"] = 0.0
			"clickx":
				var hits: Array = [[time, o.pos]]
				for e in _tuples(nd.get("extra", []), 3):
					hits.append([float(e[0]), Vector2(float(e[1]), float(e[2]))])
				hits.sort_custom( func(a, b): return float(a[0]) < float(b[0]))
				o["hits"] = hits
				o["idx"] = 0
				o.duration = float(hits.back()[0]) - time
		out.append(o)
	if skipped > 0:
		warnings.append("%d note(s) sans time/type ignorée(s)" % skipped)

	out.sort_custom( func(a, b):
		if a.time != b.time:
			return float(a.time) < float(b.time)
		if int(a.lane) != int(b.lane):
			return int(a.lane) < int(b.lane)
		return String(a.type) < String(b.type))
	return out






static func _click_pos(nd: Dictionary) -> Vector2:
	if nd.has("x") and nd.has("y"):
		return Vector2(float(nd.get("x", 0.0)), float(nd.get("y", 0.0)))
	var rng: = RandomNumberGenerator.new()
	rng.seed = int(round(float(nd.get("time", 0.0)) * 1000.0)) * 7919\
	+ clampi(int(nd.get("lane", 1)), 0, LANE_COUNT - 1)
	return Vector2(rng.randf_range(180.0, SCREEN_W - 180.0), 
		rng.randf_range(140.0, 600.0 - 160.0))


static func _tuples(value: Variant, arity: int) -> Array:
	var out: Array = []
	if not (value is Array):
		return out
	for row in (value as Array):
		if not (row is Array) or (row as Array).size() < arity:
			continue
		var vals: Array = []
		var ok: = true
		for i in arity:
			var v = row[i]
			if not (v is float or v is int) or not is_finite(float(v)):
				ok = false
				break
			vals.append(float(v))
		if ok:
			out.append(vals)
	return out


static func _kiai_of(data: Dictionary) -> Array:
	var out: Array = []
	var k = data.get("kiai", [])
	if not (k is Array):
		return out
	for s in (k as Array):
		if s is Array and (s as Array).size() >= 2:
			out.append([float(s[0]), float(s[1])])
	return out


static func _in_kiai(sim: Dictionary, t: float) -> bool:
	for k in (sim.kiai as Array):
		if t >= float(k[0]) and t <= float(k[1]):
			return true
	return false














static func _lane_ctx(fx: Dictionary) -> Dictionary:
	var tracks: Dictionary = fx.tracks
	var mk: = func(key: String):
		if not tracks.has(key):
			return null
		var evs: Array = tracks[key].evs
		var t0: = PackedFloat32Array()
		for e in evs:
			t0.append(float(e.t0))
		return {"t0": t0, "evs": evs, "neutral": float(tracks[key].neutral)}
	var dx: Array = []
	var pos: Array = []
	var sway: Array = []
	for i in LANE_COUNT:
		dx.append(mk.call("dx%d" % i))
		pos.append(mk.call("pos%d" % i))
		sway.append(mk.call("sway%d" % i))
	var glitch: Array = []
	for e in (fx.pulses as Array):
		if String(e.get("kind", "")) == "glitch":
			glitch.append(e)
	return {"spread": mk.call("spread"), "dx": dx, "pos": pos, "sway": sway, 
		"glitch": glitch}


static func _tr_last(tr, t: float):
	if tr == null:
		return null
	var t0: PackedFloat32Array = tr.t0
	var lo: = 0
	var hi: = t0.size()
	while lo < hi:
		@warning_ignore("integer_division")
		var mid: = (lo + hi) / 2
		if t0[mid] <= t:
			lo = mid + 1
		else:
			hi = mid
	return null if lo == 0 else tr.evs[lo - 1]


static func _tr_val(tr, t: float) -> float:
	if tr == null:
		return 0.0
	var cur = _tr_last(tr, t)
	if cur == null:
		return float(tr.neutral)
	var u: = clampf((t - float(cur.t0)) / maxf(float(cur.dur), 0.001), 0.0, 1.0)
	return lerpf(float(cur.from), float(cur.to), FxEval.ease_at(u, String(cur.ease)))



static func _lanes_at(fx: Dictionary, tuning, t: float) -> Array:
	var ctx = fx.get("_ac_ctx")
	if ctx == null:
		ctx = _lane_ctx(fx)
		fx["_ac_ctx"] = ctx
	var glitch: = 0.0
	for e in (ctx.glitch as Array):
		if t < float(e.t0) or t > float(e.t0) + float(e.dur):
			continue
		var damp: = pow(1.0 - clampf((t - float(e.t0)) / maxf(float(e.dur), 0.001), 
			0.0, 1.0), 1.6)
		glitch = maxf(glitch, float(e.to) * damp)
	var spread: = 1.0
	if ctx.spread != null:
		spread = _tr_val(ctx.spread, t)
	var gap: float = float(tuning.lane_width) + float(tuning.lane_gap)
	var out: Array = [0.0, 0.0, 0.0]
	for i in LANE_COUNT:
		var wob: = 0.0
		var sw = _tr_last(ctx.sway[i], t)
		if sw != null:
			var amp: float = float(sw.to) * FxEval.sway_envelope(t, 
				float(sw.t0), float(sw.dur))
			var freq: = float((sw.ev as Dictionary).get("params", {}).get("freq", 0.5))
			wob = amp * sin(t * freq * TAU + float(i) * 2.1)
		if glitch > 0.1:
			wob += (floorf(fposmod(t * 27.0 + float(i) * 7.31, 3.0)) - 1.0) * glitch
		var pe = _tr_last(ctx.pos[i], t)


		if pe != null and not (bool((pe.ev as Dictionary).get("release", false))
				and t >= float(pe.t0) + float(pe.dur)):
			out[i] = _tr_val(ctx.pos[i], t) + wob
		else:
			out[i] = SCREEN_W * 0.5 + float(i - 1) * gap * spread\
			+ _tr_val(ctx.dx[i], t) + wob
	return out





static func _lane_of(lanes: Array, x: float) -> int:
	var best: = 0
	var best_d: = INF
	for i in LANE_COUNT:
		var d: float = absf(x - float(lanes[i]))
		if d < best_d:
			best_d = d
			best = i
	return best













static func _spawn_due(sim: Dictionary) -> void :
	var tuning = sim.tuning
	var notes: Array = sim.notes
	var t: float = sim.t
	while int(sim.next_spawn) < notes.size():
		var o: Dictionary = notes[int(sim.next_spawn)]
		var lead: float = float(tuning.click_approach_time)\
		if o.type == "click" or o.type == "clickx"\
		else float(tuning.travel_time)
		if o.type == "sliderg":
			lead = float(tuning.sliderg_approach_time)
		var vm: float = float(sim.vmult) if _in_kiai(sim, float(o.time)) else 1.0
		lead /= float(o.vel) * float(o.v) * vm
		if t < float(o.time) - lead:
			break
		o.spawned = true
		(sim.live as Array).append(o)
		sim.next_spawn = int(sim.next_spawn) + 1





static func _purge(sim: Dictionary) -> void :
	var live: Array = sim.live
	for i in range(live.size() - 1, -1, -1):
		if bool(live[i].judged):
			live.remove_at(i)






static func _run_auto(sim: Dictionary) -> void :
	var tuning = sim.tuning
	var t: float = sim.t
	var dt: float = sim.dt
	var lanes: Array = sim.lane_x
	var cursor: Vector2 = sim.cursor

	var next_lane_note = null
	var next_click = null
	var held_beam = null
	var held_slider = null
	var next_sliderg = null
	for n in (sim.live as Array):
		if bool(n.judged):
			continue
		var tp: = String(n.type)
		if tp == "click" or tp == "clickx":
			if next_click == null or float(n.time) < float(next_click.time):
				next_click = n
		elif tp == "beam" and bool(n.caught):
			held_beam = n
		elif tp == "sliderg" or tp == "sliderm":
			if bool(n.caught):
				held_slider = n
			elif tp == "sliderg":
				if next_sliderg == null or float(n.time) < float(next_sliderg.time):
					next_sliderg = n
			elif _lane_note_before(n, next_lane_note):
				next_lane_note = n
		elif _lane_note_before(n, next_lane_note):
			next_lane_note = n




	var target: = Vector2(float(lanes[int(sim.lane)]), float(tuning.hit_y) - 180.0)
	var deadline: = 0.35
	if next_lane_note != null:
		var tp2: = String(next_lane_note.type)
		if tp2 == "parry" or tp2 == "sliderm":
			target.x = float(lanes[int(next_lane_note.lane)])
		else:



			var unsafe: = {}
			var unsafe_soon: = {}
			for m in (sim.live as Array):
				if bool(m.judged) or String(m.type) != "dodge":
					continue
				if absf(float(m.time) - float(next_lane_note.time)) <= 0.08:
					unsafe[int(m.lane)] = true
				if float(m.time) >= float(next_lane_note.time) - 0.08\
				and float(m.time) <= float(next_lane_note.time) + 0.25:
					unsafe_soon[int(m.lane)] = true
			if unsafe.has(int(sim.lane)):
				target.x = float(lanes[_flee_lane(sim, next_lane_note, 
					unsafe_soon if unsafe_soon.size() < 3 else unsafe)])
			else:
				target.x = float(lanes[int(sim.lane)])
		deadline = float(next_lane_note.time) - t - 0.05
	if next_click != null:
		var cpos: Vector2 = _click_target(next_click)
		var flick_time: float = cursor.distance_to(cpos)\
		/ float(tuning.auto_cursor_speed) + 0.06
		var lane_duty_first: bool = next_lane_note != null\
		and float(next_lane_note.time) < float(next_click.time)
		if not lane_duty_first or float(next_click.time) - t <= flick_time:
			target = cpos
			deadline = float(next_click.time) - t - 0.03
	if held_beam != null:
		target.x = float(lanes[_beam_lane(held_beam, t)])
		deadline = 0.08
	if next_sliderg != null and (next_click == null
			or float(next_click.time) >= float(next_sliderg.time))\
			and (next_lane_note == null
			or float(next_lane_note.time) >= float(next_sliderg.time)):
		var head: Vector2 = next_sliderg.guide.pos_at(0.0)
		var flick2: float = cursor.distance_to(head)\
		/ float(tuning.auto_cursor_speed) + 0.06
		if float(next_sliderg.time) - t <= flick2 + 0.25:
			target = head
			deadline = float(next_sliderg.time) - t - 0.03
	if held_slider != null:
		if String(held_slider.type) == "sliderg":
			target = held_slider.guide.pos_at_time(t)
		else:
			target.x = float(lanes[int(held_slider.lane)])
		deadline = 0.05

	var k: = clampf(4.0 / maxf(deadline, 0.03), 3.0, 80.0)
	var step: = cursor.lerp(target, 1.0 - exp( - k * dt)) - cursor
	var max_step: float = float(tuning.auto_cursor_speed) * dt
	if step.length() > max_step:
		step = step.normalized() * max_step
	cursor += step
	sim.cursor = cursor

	sim.lane = _lane_of(lanes, cursor.x)


	for n in (sim.live as Array):
		if bool(n.judged) or t < float(n.time) - 0.003:
			continue
		var reach: float = float(tuning.click_hit_radius) + 8.0
		match String(n.type):
			"parry":
				if int(sim.lane) == int(n.lane):
					_hit(sim, n, absf(t - float(n.time)) <= _perfect_s(tuning))
			"beam":
				if not bool(n.caught) and int(sim.lane) == int(n.lane):
					n.caught = true
					n.next_tick = float(n.time) + 0.25
					_hit(sim, n, absf(t - float(n.time)) <= _perfect_s(tuning), false)
			"sliderg":
				if not bool(n.caught) and t < float(n.time) + float(n.duration):
					var ref: Vector2 = n.guide.pos_at(0.0) if t <= float(n.time)\
					else n.guide.pos_at_time(t)
					if cursor.distance_to(ref) <= reach:
						_slider_take(sim, n)
			"sliderm":
				if not bool(n.caught) and t < float(n.time) + float(n.duration)\
				and int(sim.lane) == int(n.lane):
					_slider_take(sim, n)
			"click":
				if cursor.distance_to(Vector2(n.pos)) <= reach:
					_hit(sim, n, absf(t - float(n.time)) <= _perfect_s(tuning))
			"clickx":
				if cursor.distance_to(_click_target(n)) <= reach:
					_clickx_step(sim, n, absf(t - float(n.time)) <= _perfect_s(tuning))




static func _click_target(n: Dictionary) -> Vector2:
	if String(n.type) == "clickx":
		return (n.hits as Array)[int(n.idx)][1]
	return n.pos




static func _lane_note_before(a: Dictionary, cur) -> bool:
	if cur == null or float(a.time) < float(cur.time):
		return true
	return float(a.time) == float(cur.time) and String(cur.type) == "dodge"\
	and String(a.type) != "dodge"




static func _flee_lane(sim: Dictionary, dodge: Dictionary, unsafe: Dictionary) -> int:
	for n in (sim.live as Array):
		if bool(n.judged) or String(n.type) != "parry":
			continue


		if float(n.time) >= float(dodge.time) and not unsafe.has(int(n.lane)):
			return int(n.lane)
	var best: int = int(sim.lane)
	var best_d: = INF
	var lanes: Array = sim.lane_x
	for i in LANE_COUNT:
		if unsafe.has(i):
			continue
		var d: float = absf(float(lanes[i]) - float(lanes[int(sim.lane)]))
		if d < best_d:
			best_d = d
			best = i
	return best



static func _beam_lane(n: Dictionary, t: float) -> int:
	var path: Array = n.get("path", [])
	var u: = clampf((t - float(n.time)) / maxf(float(n.duration), 0.001), 0.0, 1.0)
	if path.is_empty():
		return int(n.lane)
	var prev_u: = 0.0
	var prev_l: = float(n.lane)
	for p in path:
		var pu: = float(p[0])
		var pl: = float(p[1])
		if u <= pu:
			if pu - prev_u < 0.0001:
				return clampi(roundi(pl), 0, LANE_COUNT - 1)
			return clampi(roundi(lerpf(prev_l, pl, (u - prev_u) / (pu - prev_u))), 
				0, LANE_COUNT - 1)
		prev_u = pu
		prev_l = pl
	return clampi(roundi(prev_l), 0, LANE_COUNT - 1)











static func _perfect_s(tuning) -> float:
	return float(tuning.perfect_window_ms) / 1000.0


static func _last_s(tuning) -> float:
	return float(tuning.last_window_ms()) / 1000.0




static func _hit(sim: Dictionary, n: Dictionary, perfect: bool, 
		resolve: = true) -> void :
	if perfect:
		sim.perfect = int(sim.perfect) + 1
	else:
		sim.good = int(sim.good) + 1
		_problem(sim, float(sim.t), "good", n, 
			"le bot n'est pas arrivé dans la fenêtre PERFECT")
	if resolve:
		n.judged = true


static func _miss(sim: Dictionary, n: Dictionary, detail: String) -> void :
	sim.miss = int(sim.miss) + 1
	n.judged = true
	_problem(sim, float(n.time), "miss", n, detail)





static func _break(sim: Dictionary, n: Dictionary, kind: String, 
		detail: String) -> void :
	sim.breaks = int(sim.breaks) + 1
	_problem(sim, float(sim.t), kind, n, detail)


static func _problem(sim: Dictionary, t: float, kind: String, n: Dictionary, 
		detail: String) -> void :
	sim.n_problems = int(sim.n_problems) + 1
	var list: Array = sim.problems
	if list.size() >= MAX_PROBLEMS:
		return
	list.append({
		"t": snappedf(t, 0.001), 
		"kind": kind, 
		"type": String(n.get("type", "?")), 
		"lane": int(n.get("lane", -1)), 
		"pos": Vector2(n.get("pos", Vector2.ZERO)), 
		"detail": detail, 
	})



static func _clickx_step(sim: Dictionary, n: Dictionary, perfect: bool) -> void :
	var hits: Array = n.hits
	if int(n.idx) >= hits.size() - 1:
		_hit(sim, n, perfect)
		return
	if perfect:
		sim.perfect = int(sim.perfect) + 1
	else:
		sim.good = int(sim.good) + 1
		_problem(sim, float(sim.t), "good", n, 
			"maillon de chaîne hors fenêtre PERFECT")
	n.idx = int(n.idx) + 1
	n.time = float(hits[int(n.idx)][0])
	n.pos = hits[int(n.idx)][1]



static func _clickx_miss(sim: Dictionary, n: Dictionary) -> void :
	sim.miss = int(sim.miss) + 1
	_problem(sim, float(n.time), "miss", n, 
		"maillon de chaîne jamais atteint par le bot")
	var hits: Array = n.hits
	n.idx = int(n.idx) + 1
	n.time = float(hits[int(n.idx)][0])
	n.pos = hits[int(n.idx)][1]






static func _judge_expired(sim: Dictionary) -> void :
	var t: float = sim.t
	var win: = _last_s(sim.tuning)
	for n in (sim.live as Array):
		if bool(n.judged):
			continue
		match String(n.type):
			"dodge":

				if t >= float(n.time):
					if int(sim.lane) == int(n.lane):
						_miss(sim, n, "le bot n'a pas pu quitter la lane du rouge")
					else:
						sim.perfect = int(sim.perfect) + 1
						n.judged = true
			"clickx":
				if t > float(n.time) + win:
					if (n.hits as Array).size() - int(n.idx) > 1:
						_clickx_miss(sim, n)
					else:
						_miss(sim, n, "chaîne jaune jamais atteinte")
			"parry":
				if t > float(n.time) + win:
					_miss(sim, n, 
						"blanche jamais frappée — le bot n'était pas sur la lane %d"
						%int(n.lane))
			"click":
				if t > float(n.time) + win:
					_miss(sim, n, "cible jaune jamais atteinte par le curseur")






static func _update_beams(sim: Dictionary) -> void :
	var t: float = sim.t
	var tuning = sim.tuning
	for n in (sim.live as Array):
		if String(n.type) != "beam" or bool(n.judged):
			continue
		if not bool(n.caught):
			if t > float(n.time) + _last_s(tuning):
				_miss(sim, n, "faisceau jamais pris (lane %d)" % int(n.lane))
			continue
		var end: float = float(n.time) + float(n.duration)
		if t >= end:
			_hit(sim, n, true)
			continue

		if int(sim.lane) == _beam_lane(n, t):
			n.grace = 0.0
		else:
			n.grace = float(n.grace) + float(sim.dt)
			if float(n.grace) > 0.16:
				if end - t <= float(tuning.good_window_ms) / 1000.0:
					_hit(sim, n, false)
				else:
					_miss(sim, n, "faisceau cassé : le bot a perdu sa lane")






static func _slider_take(sim: Dictionary, n: Dictionary) -> void :
	var t: float = sim.t
	var tuning = sim.tuning
	if not bool(n.head_missed) and float(n.held_time) == 0.0\
	and absf(t - float(n.time)) <= _last_s(tuning):

		n.caught = true
		n.catch_late = maxf(t - float(n.time), 0.0)
		n.next_tick = float(n.time) + float(tuning.slider_tick)
		_hit(sim, n, absf(t - float(n.time)) <= _perfect_s(tuning), false)
		return


	n.caught = true
	n.grace = 0.0
	n.next_tick = maxf(float(n.next_tick), t + float(tuning.slider_tick))


static func _update_sliders(sim: Dictionary) -> void :
	var t: float = sim.t
	var dt: float = sim.dt
	var tuning = sim.tuning
	var rail_tol: float = float(tuning.slider_rail_tolerance)
	for n in (sim.live as Array):
		var tp: = String(n.type)
		if bool(n.judged) or (tp != "sliderg" and tp != "sliderm"):
			continue
		var end: float = float(n.time) + float(n.duration)
		if t >= end:


			if bool(n.caught):
				n.held_time = float(n.held_time) + clampf(end - (t - dt), 0.0, dt)
			_slider_finish(sim, n)
			continue
		if not bool(n.caught):
			if not bool(n.head_missed) and float(n.held_time) == 0.0\
			and t > float(n.time) + _last_s(tuning):
				n.head_missed = true
				_break(sim, n, "head_missed", 
					"départ de tenue raté : le bot n'était pas là à temps")
			elif t >= float(n.time)\
			and (bool(n.head_missed) or float(n.held_time) > 0.0):

				var ok_r: bool = int(sim.lane) == int(n.lane) if tp == "sliderm"\
				else (sim.cursor as Vector2).distance_to(
					n.guide.pos_at_time(t)) <= rail_tol
				if ok_r:
					_slider_take(sim, n)
			continue
		var ok: = true
		if tp == "sliderg":
			ok = (sim.cursor as Vector2).distance_to(n.guide.pos_at_time(t)) <= rail_tol
			if not ok:
				n.off_time = float(n.off_time) + dt
		else:
			ok = int(sim.lane) == int(n.lane)
		if ok:
			n.grace = 0.0
			n.held_time = float(n.held_time) + dt
			if t >= float(n.next_tick) and t < end - 0.05:
				n.next_tick = float(n.next_tick) + float(tuning.slider_tick)
		else:
			n.grace = float(n.grace) + dt
			if float(n.grace) > float(tuning.slider_grace):
				n.caught = false
				n.grace = 0.0
				_break(sim, n, "drop", 
					"tenue lâchée : le curseur du bot n'a pas suivi le rail")



static func _slider_finish(sim: Dictionary, n: Dictionary) -> void :
	var tuning = sim.tuning
	var lenience: float = minf(float(tuning.slider_end_lenience), float(n.duration) * 0.5)
	var avail: float = maxf(float(n.duration) - float(n.catch_late) - lenience, 0.001)
	var ratio: float = float(n.held_time) / avail
	n.judged = true
	if ratio >= float(tuning.slider_perfect_ratio)\
	and (String(n.type) != "sliderg" or float(n.off_time) <= float(tuning.slider_off_rail_max)):
		sim.perfect = int(sim.perfect) + 1
	elif ratio >= float(tuning.slider_good_ratio):
		sim.good = int(sim.good) + 1
		_problem(sim, float(n.time), "good", n, 
			"tenue incomplète : %d %% tenus (%d %% exigés)"
			%[int(ratio * 100.0), int(float(tuning.slider_perfect_ratio) * 100.0)])
	else:
		sim.miss = int(sim.miss) + 1
		_problem(sim, float(n.time), "miss", n, 
			"tenue perdue : %d %% tenus (%d %% exigés)"
			%[int(ratio * 100.0), int(float(tuning.slider_good_ratio) * 100.0)])









static func _zones(problems: Array) -> Array:
	if problems.is_empty():
		return []
	var ts: Array = []
	for p in problems:
		ts.append(float(p.t))
	ts.sort()
	var out: Array = []
	var t0: float = float(ts[0])
	var t1: float = t0
	for i in range(1, ts.size()):
		var t: float = float(ts[i])
		if t - t1 <= ZONE_MERGE:
			t1 = t
			continue
		out.append([t0 - ZONE_PAD, t1 + ZONE_PAD])
		t0 = t
		t1 = t
	out.append([t0 - ZONE_PAD, t1 + ZONE_PAD])
	return out



static func summary(r: Dictionary) -> String:
	if bool(r.ok):
		return "AUTO PASS — %d/%d PERFECT" % [int(r.perfect), int(r.judged)]
	var bits: Array = []
	if int(r.miss) > 0:
		bits.append("%d MISS" % int(r.miss))
	if int(r.good) > 0:
		bits.append("%d GOOD" % int(r.good))
	if int(r.get("breaks", 0)) > 0:
		bits.append("%d BREAK" % int(r.get("breaks", 0)))
	if bits.is_empty():
		bits.append("%d/%d judged" % [int(r.judged), int(r.expected)])
	return "AUTO FAILED — " + ", ".join(bits)
