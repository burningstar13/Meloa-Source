extends RefCounted
class_name ChartRating

















































































const FxEval = preload("res://scripts/fx_eval.gd")








const VERSION: = 1

const SCREEN_W: = 1280.0
const SCREEN_H: = 720.0
const LANE_W: = 150.0
const LANE_GAP: = 30.0
const HIT_Y: = 600.0
const NATURAL_GAP: = LANE_W + LANE_GAP
const LANE_COUNT: = 3





const HIT_RADIUS: = 66.0
const RAIL_TOL: = 140.0
const SLIDER_GRACE: = 0.18
const LAST_WINDOW: = 0.16
const APPROACH_CLICK: = 0.55
const APPROACH_LANE: = 0.6
const APPROACH_SLIDER: = 0.6


const MIN_DT: = 0.045
const SIMUL_EPS: = 0.015
const SECTION: = 0.5
const DECAY_TAU: = 0.62
const DECAY_TAU_VI: = 0.62
const DECAY_TAU_CO: = 0.75
const COMFORT_SPEED: = 900.0





const TOP_WEIGHT: = 0.945
const TOP_WEIGHT_RY: = 0.975
const TOP_WEIGHT_MIX: = 0.968


const MAX_TRAVEL: = 1470.0
const MAX_SPEED_RATIO: = 13.0
const FLICK_KNEE: = 3.0
const FLICK_POW: = 1.3
const FLICK_DIST_REF: = 2.0 * NATURAL_GAP
const FLICK_DIST_POW: = 0.7


const MAX_D_RY: = 28.9
const MAX_D_VI: = 45.0
const MAX_D_LE: = 8.0
const MAX_D_CO: = 12.0
const CAP_RY: = 412.0
const CAP_VI: = 643.0
const CAP_LE: = 114.0
const CAP_CO: = 172.0



















const W_RYTHME: = 1.0
const W_VISEE: = 1.55
const W_LECTURE: = 2.8
const W_COORD: = 3.2



const MIX_POW: = 1.5



const RY_IRREG_GAIN: = 0.22
const RY_IRREG_CAP: = 0.3
const RY_CHORD_GAIN: = 0.2
const RY_CHORD_MAX: = 3



const RY_ONE_HAND: = 0.45
const RY_ONE_HAND_GAP: = 0.22







const VI_ANGLE_GAIN: = 0.55
const VI_ANGLE_MIN_TRAVEL: = 45.0
const VI_PREC_REF: = HIT_RADIUS
const VI_PREC_POW: = 0.35
const VI_PREC_MIN: = 0.55
const VI_PREC_MAX: = 1.9
const VI_CHAIN_BASE: = 1.15
const VI_CHAIN_STEP: = 0.1
const VI_CHAIN_MAX: = 6


const SLIDER_SAMPLE_PX: = 55.0
const SLIDER_SAMPLE_MAX: = 96
const SLIDER_SAMPLE_MIN: = 3
const SLIDER_SAMPLE_HZ: = 11.0



const SLIDER_INJ_HZ: = 14.0
const SLIDER_CURVE_GAIN: = 0.85
const SLIDER_PREC: = VI_PREC_REF / RAIL_TOL
const SLIDER_MAX_FOLLOW: = 6.0


const LANE_HOLD_SAMPLE: = 0.08
const BEAM_SAMPLE: = 0.05


const LE_SWITCH: = 0.3
const LE_SWITCH_CAP: = 6.0
const LE_CHAIN_LEAD: = 0.34
const LE_CHAIN_CAP: = 6.0

const LE_VIS_REF: = 0.45
const LE_VIS_GAIN: = 1.6
const LE_VIS_CAP: = 2.2
const LE_HIDDEN_LANE: = 1.1
const LE_OFFSCREEN_LANE: = 1.6
const LE_GLITCH: = 1.3
const LE_LANE_SWAP: = 0.9


const CO_TAP_UNDER_AIM_HOLD: = 1.5
const CO_TAP_UNDER_LANE_HOLD: = 1.0
const CO_TAP_UNDER_CHAIN: = 1.9
const CO_BOTH_BUSY: = 2.4
const CO_RAIL_CROSS: = 1.3
const CO_RED_TIGHT: = 1.15
const CO_RED_CAP: = 3.0
const CO_HOLD_ENTRY: = 0.6
const CO_RED_ON_LANE: = 1.4
const CO_INVALID: = 2.0







const SPLIT_WINDOW: = 0.12


const PRESS_PER_KEY: = 3


const RED_EPS: = 0.03
const RED_LINK: = 0.3
const RED_LOOKAHEAD: = 0.45
const RED_CONFLICT: = 0.03


const MAX_NOTES: = 20000
const MAX_CHAIN: = 64
const MAX_SLIDER_DUR: = 60.0
const MAX_POS: = 40000.0
const MAX_INVALID_LOGGED: = 40






const STEP_HOLD_END: = 0
const STEP_ACT: = 1
const STEP_RED: = 2
const STEP_TRACK: = 3



const TIERS: = [
	[2.5, "EASY", Color(0.45, 0.82, 1.0)], 
	[4.4, "NORMAL", Color(0.45, 1.0, 0.75)], 
	[6.8, "HARD", Color(1.0, 0.78, 0.25)], 
	[10.0, "INSANE", Color(1.0, 0.35, 0.55)], 
	[16.0, "DEMON", Color(1.0, 0.25, 0.3)], 
	[999.0, "CORRUPT", Color(0.44, 0.07, 0.13)], 
]


static func tier_for(level: float) -> Array:
	for t in TIERS:
		if level < float(t[0]):
			return [String(t[1]), t[2]]
	return [String(TIERS.back()[1]), TIERS.back()[2]]




static func empty() -> Dictionary:
	return {"level": 0.0, "charge": 0.0, "rythme": 0.0, "visee": 0.0, "lecture": 0.0, 
		"coordination": 0.0, "tier": "EASY", "color": TIERS[0][2], "taps": 0, 
		"dur": 0.0, "peak": 0.0, "nps": 0.0, 
		"raw": [0.0, 0.0, 0.0, 0.0, 0.0], "peaks": [0.0, 0.0, 0.0, 0.0], 
		"invalid_patterns": [], "impossible_count": 0, "warnings": [], 
		"debug": {}}





















static func _objects(notes: Array, warnings: Array) -> Array:
	var out: Array = []
	var seen: = {}
	var dropped: = 0
	var bad: = 0
	var count: = 0
	for raw in notes:
		if count >= MAX_NOTES:
			warnings.append("chart tronqué à %d notes pour la notation" % MAX_NOTES)
			break
		if not (raw is Dictionary):
			bad += 1
			continue
		var n: Dictionary = raw
		var t: = _finite(float(n.get("time", 0.0)), 0.0)
		if not is_finite(t) or absf(t) > 1000000.0:
			bad += 1
			continue
		count += 1
		var tp: = String(n.get("type", ""))


		var lane: = clampi(int(n.get("lane", 1)), 0, LANE_COUNT - 1)
		var vel: = clampf(_finite(float(n.get("v", 1.0)), 1.0), 0.05, 20.0)
		var pos: = _safe_pos(n)
		match tp:
			"dodge":
				if _keep(seen, "dg|%d|%d" % [_ms(t), lane]):
					out.append({"t": t, "kind": "hazard", "lane": lane})
				else:
					dropped += 1
			"click":
				if _keep(seen, "ck|%d|%d|%d" % [_ms(t), roundi(pos.x), roundi(pos.y)]):
					out.append({"t": t, "kind": "tap_aim", "lane": -1, "pos": pos, 
						"chain": 0, "step": 0, "lead": APPROACH_CLICK, 
						"vis": APPROACH_CLICK / vel, "v": vel})
				else:
					dropped += 1
			"clickx":



				var steps: Array = [[t, pos]]
				for e in _tuples(n.get("extra", []), 3):
					if steps.size() >= MAX_CHAIN:
						warnings.append("chaîne clickx tronquée à %d maillons (t=%.2f)"
							%[MAX_CHAIN, t])
						break
					steps.append([_finite(float(e[0]), t), 
						_clamp_pos(Vector2(_finite(float(e[1]), pos.x), 
							_finite(float(e[2]), pos.y)))])
				steps.sort_custom( func(a, b): return float(a[0]) < float(b[0]))
				var key: = "cx|%d" % _ms(t)
				for s in steps:
					key += "|%d,%d,%d" % [_ms(float(s[0])), 
						roundi((s[1] as Vector2).x), roundi((s[1] as Vector2).y)]
				if not _keep(seen, key):
					dropped += 1
					continue
				var prev_t: = t
				for i in steps.size():
					var st: float = float(steps[i][0])
					var lead: float = APPROACH_CLICK / vel if i == 0\
					else maxf(st - prev_t, 0.02)
					out.append({"t": st, "kind": "tap_aim", "lane": -1, 
						"pos": steps[i][1], "chain": steps.size(), "step": i, 
						"lead": lead, "vis": lead, "v": vel, 
						"chain_end": float(steps.back()[0])})
					prev_t = st
			"sliderg":
				var dur: = clampf(_finite(float(n.get("duration", 1.0)), 1.0), 
					0.02, MAX_SLIDER_DUR)
				var pts: = _rail_points(n, pos)
				var key2: = "sg|%d|%d" % [_ms(t), _ms(dur)]
				for p in pts:
					key2 += "|%d,%d,%d" % [roundi(float(p[0]) * 1000.0), 
						roundi((p[1] as Vector2).x), roundi((p[1] as Vector2).y)]
				if not _keep(seen, key2):
					dropped += 1
					continue
				out.append({"t": t, "kind": "hold_aim", "lane": -1, 
					"pos": pts[0][1], "end": t + dur, "dur": dur, 
					"pts": pts, "v": vel, "vis": APPROACH_SLIDER / vel, 
					"lead": APPROACH_SLIDER / vel})
			"sliderm":
				var dm: = clampf(_finite(float(n.get("duration", 1.0)), 1.0), 
					0.02, MAX_SLIDER_DUR)
				if _keep(seen, "sm|%d|%d|%d" % [_ms(t), lane, _ms(dm)]):
					out.append({"t": t, "kind": "hold_lane", "lane": lane, 
						"end": t + dm, "dur": dm, "path": [], "v": vel, 
						"vis": APPROACH_LANE / vel, "lead": APPROACH_LANE / vel})
				else:
					dropped += 1
			"beam":
				var db: = clampf(_finite(float(n.get("duration", 1.0)), 1.0), 
					0.02, MAX_SLIDER_DUR)
				var path: = _tuples(n.get("path", []), 2)
				var key3: = "bm|%d|%d|%d" % [_ms(t), lane, _ms(db)]
				for p in path:
					key3 += "|%d,%d" % [roundi(float(p[0]) * 1000.0), int(p[1])]
				if not _keep(seen, key3):
					dropped += 1
					continue
				out.append({"t": t, "kind": "hold_lane", "lane": lane, 
					"end": t + db, "dur": db, "path": path, "v": vel, 
					"vis": APPROACH_LANE / vel, "lead": APPROACH_LANE / vel})
			_:


				if _keep(seen, "pr|%d|%d" % [_ms(t), lane]):
					out.append({"t": t, "kind": "tap_lane", "lane": lane, 
						"pos": Vector2.ZERO, "chain": 0, "step": 0, 
						"lead": APPROACH_LANE / vel, 
						"vis": APPROACH_LANE / vel, "v": vel})
				else:
					dropped += 1
	if dropped > 0:
		warnings.append("%d clone(s) exact(s) fusionné(s)" % dropped)
	if bad > 0:
		warnings.append("%d note(s) illisible(s) ignorée(s)" % bad)
	out.sort_custom( func(a, b):
		if a.t != b.t:
			return a.t < b.t
		return _kind_rank(String(a.kind)) < _kind_rank(String(b.kind)))
	return out





static func _kind_rank(kind: String) -> int:
	match kind:
		"hold_aim", "hold_lane":
			return 0
		"tap_aim", "tap_lane":
			return 1
	return 2


static func _keep(seen: Dictionary, key: String) -> bool:
	if seen.has(key):
		return false
	seen[key] = true
	return true


static func _ms(t: float) -> int:
	return int(round(clampf(t, -1000000.0, 1000000.0) * 1000.0))


static func _finite(v: float, fallback: = 0.0) -> float:
	return v if is_finite(v) else fallback


static func _clamp_pos(p: Vector2) -> Vector2:
	return Vector2(clampf(_finite(p.x, SCREEN_W * 0.5), - MAX_POS, MAX_POS), 
		clampf(_finite(p.y, HIT_Y * 0.5), - MAX_POS, MAX_POS))


static func _safe_pos(n: Dictionary) -> Vector2:




	if n.has("x") and n.has("y"):
		return _clamp_pos(Vector2(_finite(float(n.get("x", 0.0)), SCREEN_W * 0.5), 
			_finite(float(n.get("y", 0.0)), HIT_Y * 0.5)))
	var rng: = RandomNumberGenerator.new()
	rng.seed = int(round(_finite(float(n.get("time", 0.0))) * 1000.0)) * 7919\
	+ clampi(int(n.get("lane", 1)), 0, LANE_COUNT - 1)
	return Vector2(rng.randf_range(180.0, SCREEN_W - 180.0), 
		rng.randf_range(140.0, HIT_Y - 160.0))




static func _rail_points(n: Dictionary, head: Vector2) -> Array:
	var out: Array = []
	for p in _tuples(n.get("points", []), 3):
		var f: = clampf(_finite(float(p[0]), 0.0), 0.0, 1.0)
		out.append([f, _clamp_pos(Vector2(_finite(float(p[1]), head.x), 
			_finite(float(p[2]), head.y)))])
	out.sort_custom( func(a, b): return float(a[0]) < float(b[0]))
	if out.is_empty():
		out.append([0.0, head])
	return out




static func _tuples(value: Variant, arity: int) -> Array:
	var out: Array = []
	if not (value is Array):
		return out
	for row in (value as Array):
		if not (row is Array) or (row as Array).size() < arity:
			continue
		var ok: = true
		var vals: Array = []
		for i in arity:
			var v = row[i]
			if not (v is float or v is int) or not is_finite(float(v)):
				ok = false
				break
			vals.append(float(v))
		if ok:
			out.append(vals)
	return out










const RAIL_STEPS: = 160

static func _rail_build(pts: Array) -> Dictionary:
	var arc_p: = PackedVector2Array()
	var arc_l: = PackedFloat32Array()
	var prev: = _rail_raw(pts, 0.0)
	var acc: = 0.0
	arc_p.append(prev)
	arc_l.append(0.0)
	for i in range(1, RAIL_STEPS + 1):
		var p: = _rail_raw(pts, float(i) / RAIL_STEPS)
		acc += prev.distance_to(p)
		arc_p.append(p)
		arc_l.append(acc)
		prev = p
	return {"p": arc_p, "l": arc_l, "total": maxf(acc, 0.001)}



static func _rail_raw(pts: Array, u: float) -> Vector2:
	if pts.is_empty():
		return Vector2.ZERO
	if pts.size() == 1:
		return pts[0][1]
	u = clampf(u, 0.0, 1.0)
	var last: = pts.size() - 1
	if u <= float(pts[0][0]):
		return pts[0][1]
	for i in last:
		var u0: = float(pts[i][0])
		var u1: = float(pts[i + 1][0])
		if u > u1:
			continue
		var s: = 0.0 if u1 - u0 < 0.0001 else (u - u0) / (u1 - u0)
		var p0: Vector2 = pts[maxi(i - 1, 0)][1]
		var p1: Vector2 = pts[i][1]
		var p2: Vector2 = pts[i + 1][1]
		var p3: Vector2 = pts[mini(i + 2, last)][1]
		return 0.5 * ((2.0 * p1) + ( - p0 + p2) * s
			+ (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * s * s
			+ ( - p0 + 3.0 * p1 - 3.0 * p2 + p3) * s * s * s)
	return pts[last][1]



static func _rail_pos(rail: Dictionary, u: float) -> Vector2:
	var arc_p: PackedVector2Array = rail.p
	var arc_l: PackedFloat32Array = rail.l
	if arc_p.is_empty():
		return Vector2.ZERO
	var target: = clampf(u, 0.0, 1.0) * float(rail.total)
	var lo: = 0
	var hi: = arc_l.size() - 1
	while lo < hi:
		@warning_ignore("integer_division")
		var mid: = (lo + hi) / 2
		if arc_l[mid] < target:
			lo = mid + 1
		else:
			hi = mid
	if lo == 0:
		return arc_p[0]
	var l0: = arc_l[lo - 1]
	var l1: = arc_l[lo]
	var k: = 0.0 if l1 - l0 < 0.001 else (target - l0) / (l1 - l0)
	return arc_p[lo - 1].lerp(arc_p[lo], k)



static func _rail_at(obj: Dictionary, t: float) -> Vector2:
	return _rail_pos(obj.rail, (t - float(obj.t)) / maxf(float(obj.dur), 0.001))




















static func _fx_ctx(built: Dictionary) -> Dictionary:
	var tracks: Dictionary = built.tracks
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
	var alpha: Array = []
	for i in LANE_COUNT:
		dx.append(mk.call("dx%d" % i))
		pos.append(mk.call("pos%d" % i))
		sway.append(mk.call("sway%d" % i))
		alpha.append(mk.call("alpha%d" % i))
	var glitch: Array = []
	for e in (built.pulses as Array):
		if String(e.get("kind", "")) == "glitch":
			glitch.append(e)
	var spread = mk.call("spread")
	var flat: = spread == null and glitch.is_empty()
	if flat:
		for i in LANE_COUNT:
			if dx[i] != null or pos[i] != null or sway[i] != null or alpha[i] != null:
				flat = false
				break
	return {"spread": spread, "dx": dx, "pos": pos, "sway": sway, 
		"alpha": alpha, "glitch": glitch, "cache": {}, "flat": flat, 
		"still": null}




static func _fx_last(tr, t: float):
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
	if lo == 0:
		return null
	return tr.evs[lo - 1]



static func _fx_val(tr, t: float) -> float:
	if tr == null:
		return 0.0
	var cur = _fx_last(tr, t)
	if cur == null:
		return float(tr.neutral)
	var u: = clampf((t - float(cur.t0)) / maxf(float(cur.dur), 0.001), 0.0, 1.0)
	return lerpf(float(cur.from), float(cur.to), FxEval.ease_at(u, String(cur.ease)))






















static func _geom_at(ctx: Dictionary, t: float) -> Dictionary:


	if bool(ctx.flat):
		if ctx.still == null:
			ctx.still = _geom_build(ctx, 0.0)
		return ctx.still



	var slot: = _ms(t)
	var hit = (ctx.cache as Dictionary).get(slot)
	if hit != null:
		return hit
	var g: = _geom_build(ctx, t)
	ctx.cache[slot] = g
	return g


static func _geom_build(ctx: Dictionary, t: float) -> Dictionary:
	var g: = {"x": [0.0, 0.0, 0.0], "lo": [0.0, 0.0, 0.0], "hi": [0.0, 0.0, 0.0], 
		"ok": [true, true, true], "alpha": [1.0, 1.0, 1.0], 
		"off": [false, false, false], "glitch": 0.0, "nlanes": 3}
	var spread: = 1.0
	if ctx.spread != null:
		spread = _fx_val(ctx.spread, t)
	var glitch: = 0.0
	for e in (ctx.glitch as Array):
		if t < float(e.t0) or t > float(e.t0) + float(e.dur):
			continue
		var damp: = pow(1.0 - clampf((t - float(e.t0)) / maxf(float(e.dur), 0.001), 
			0.0, 1.0), 1.6)
		glitch = maxf(glitch, float(e.to) * damp)
	g.glitch = clampf(glitch, 0.0, 400.0)
	for i in LANE_COUNT:
		var wob: = 0.0
		var sw = _fx_last(ctx.sway[i], t)
		if sw != null:
			var amp: float = float(sw.to) * FxEval.sway_envelope(t, 
				float(sw.t0), float(sw.dur))
			var freq: = float((sw.ev as Dictionary).get("params", {}).get("freq", 0.5))
			wob = amp * sin(t * freq * TAU + float(i) * 2.1)
		var x: float
		var pos_ev = _fx_last(ctx.pos[i], t)


		if pos_ev != null and not (bool((pos_ev.ev as Dictionary).get("release", false))
				and t >= float(pos_ev.t0) + float(pos_ev.dur)):
			x = _fx_val(ctx.pos[i], t) + wob
		else:
			x = SCREEN_W * 0.5 + float(i - 1) * NATURAL_GAP * spread\
			+ _fx_val(ctx.dx[i], t) + wob

		g.x[i] = clampf(_finite(x, SCREEN_W * 0.5), - MAX_TRAVEL, SCREEN_W + MAX_TRAVEL)
		if ctx.alpha[i] != null:
			g.alpha[i] = clampf(_fx_val(ctx.alpha[i], t), 0.0, 1.0)
		g.off[i] = g.x[i] < - LANE_W * 0.5 or g.x[i] > SCREEN_W + LANE_W * 0.5
	_voronoi(g)
	return g














static func _voronoi(g: Dictionary) -> void :
	var order: Array = [0, 1, 2]
	for a in range(1, LANE_COUNT):
		var k: int = order[a]
		var xk: float = float(g.x[k])
		var b: = a - 1
		while b >= 0:
			var j: int = order[b]
			var xj: float = float(g.x[j])
			if xj < xk or (xj == xk and j < k):
				break
			order[b + 1] = j
			b -= 1
		order[b + 1] = k


	var live: Array = []
	for i in order:
		if not live.is_empty()\
		and absf(float(g.x[live[-1]]) - float(g.x[i])) < 0.5:
			g.lo[i] = 1.0
			g.hi[i] = 0.0
			g.ok[i] = false
			continue
		live.append(i)
	for k2 in live.size():
		var i2: int = live[k2]
		var lo: = - INF
		var hi: = INF
		if k2 > 0:
			lo = (float(g.x[live[k2 - 1]]) + float(g.x[i2])) * 0.5
		if k2 < live.size() - 1:
			hi = (float(g.x[i2]) + float(g.x[live[k2 + 1]])) * 0.5
		g.lo[i2] = maxf(lo, 0.0)
		g.hi[i2] = minf(hi, SCREEN_W)
		g.ok[i2] = float(g.lo[i2]) <= float(g.hi[i2])
	var n: = 0
	for i3 in LANE_COUNT:
		if bool(g.ok[i3]):
			n += 1
	g.nlanes = n





static func _lane_at_x(g: Dictionary, x: float) -> int:
	var best: = 0
	var best_d: = INF
	for i in LANE_COUNT:
		var d: float = absf(x - float(g.x[i]))
		if d < best_d:
			best_d = d
			best = i
	return best














const LANE_SAFE_FRAC: = 0.25
const LANE_SAFE_MIN: = 12.0
const LANE_SAFE_MAX: = 45.0

static func _reach_lane(g: Dictionary, lane: int, x: float) -> Array:
	if not bool(g.ok[lane]):
		return [float(g.x[lane]), INF]
	var lo: = float(g.lo[lane])
	var hi: = float(g.hi[lane])
	var m: float = clampf((hi - lo) * LANE_SAFE_FRAC, LANE_SAFE_MIN, LANE_SAFE_MAX)
	m = minf(m, (hi - lo) * 0.5)
	lo += m
	hi -= m
	if x < lo:
		return [lo, lo - x]
	if x > hi:
		return [hi, x - hi]
	return [x, 0.0]




static func _lane_tol(g: Dictionary, lane: int) -> float:
	if not bool(g.ok[lane]):
		return 1.0
	return clampf((float(g.hi[lane]) - float(g.lo[lane])) * 0.5, 1.0, SCREEN_W)






















static func _red_windows(objs: Array) -> Dictionary:
	var inst: Array = []
	var cur_t: = -1000000000.0
	var cur_mask: = 0
	for o in objs:
		if String(o.kind) != "hazard":
			continue
		var t: = float(o.t)
		if t - cur_t <= RED_EPS and not inst.is_empty():
			cur_mask |= 1 << int(o.lane)
			inst[-1].mask = cur_mask
			inst[-1].t1 = t
			continue
		cur_t = t
		cur_mask = 1 << int(o.lane)
		inst.append({"t": t, "t1": t, "mask": cur_mask})
	var wins: Array = []
	for e in inst:
		if not wins.is_empty() and int(wins[-1].mask) == int(e.mask)\
		and float(e.t) - float(wins[-1].t1) <= RED_LINK:
			wins[-1].t1 = float(e.t1)
			wins[-1].n = int(wins[-1].n) + 1
			continue
		wins.append({"t0": float(e.t), "t1": float(e.t1), "mask": int(e.mask), "n": 1})
	return {"windows": wins, "instants": inst}


static func _mask_lanes(mask: int) -> Array:
	var out: Array = []
	for i in LANE_COUNT:
		if mask & (1 << i):
			out.append(i)
	return out


static func _mask_count(mask: int) -> int:
	var n: = 0
	for i in LANE_COUNT:
		if mask & (1 << i):
			n += 1
	return n











static func _groups(objs: Array) -> Array:
	var out: Array = []
	for o in objs:
		if String(o.kind) == "hazard":
			continue
		if not out.is_empty() and float(o.t) - float(out[-1].t) <= SIMUL_EPS:
			(out[-1].objs as Array).append(o)
			continue
		out.append({"t": float(o.t), "objs": [o]})
	return out







static func rate(data: Dictionary) -> Dictionary:
	var raw_notes = data.get("notes", [])
	if not (raw_notes is Array) or (raw_notes as Array).is_empty():
		return empty()
	var warnings: Array = []
	var objs: = _objects(raw_notes, warnings)
	if objs.is_empty():
		return empty()




	var map_vel: = clampf(_finite(float(data.get("velocity", 1.0)), 1.0), 0.1, 10.0)
	for o in objs:
		o["vis"] = maxf(float(o.get("vis", APPROACH_LANE)) / map_vel, 0.02)


	var fx_raw = data.get("fx", [])
	var built: Dictionary = FxEval.build(fx_raw if fx_raw is Array else [], 
		LANE_W, LANE_GAP, SCREEN_W)
	var ctx: = _fx_ctx(built)


	var n_slider_samples: = 0
	for o in objs:
		if String(o.kind) == "hold_aim":
			o["rail"] = _rail_build(o.pts)
			o["pos"] = _rail_pos(o.rail, 0.0)


	var reds: = _red_windows(objs)


	var groups: = _groups(objs)
	if groups.is_empty():
		return empty()



	var lane_t: = PackedFloat32Array()
	var lane_l: = PackedInt32Array()
	var chains: Array = []
	for g in groups:
		for o in g.objs:
			var k: = String(o.kind)
			if k == "tap_lane" or k == "hold_lane":
				lane_t.append(float(o.t))
				lane_l.append(int(o.lane))
			elif k == "tap_aim" and int(o.get("chain", 0)) > 1 and int(o.step) == 0:
				chains.append([float(o.t), float(o.get("chain_end", o.t))])












	var steps: Array = []
	var seq: = 0
	for g in groups:
		steps.append([float(g.t), STEP_ACT, seq, g, null])
		seq += 1
	for w in reds.windows:
		steps.append([float(w.t0), STEP_RED, seq, w, null])
		seq += 1
	for o in objs:
		var k: = String(o.kind)
		if k == "hold_aim":
			var samples: = _slider_samples(o)
			n_slider_samples += samples.size()
			for s in samples:
				steps.append([float(s.t), STEP_TRACK, seq, o, s])
				seq += 1
			steps.append([float(o.end), STEP_HOLD_END, seq, o, null])
			seq += 1
		elif k == "hold_lane":
			for s in _lane_hold_samples(o):
				steps.append([float(s.t), STEP_TRACK, seq, o, s])
				seq += 1
			steps.append([float(o.end), STEP_HOLD_END, seq, o, null])
			seq += 1
	steps.sort()


	var st: = {
		"ry": 0.0, "vi": 0.0, "le": 0.0, "co": 0.0, 
		"pk_ry": {}, "pk_vi": {}, "pk_le": {}, "pk_co": {}, 
		"last_t": float(groups[0].t), 



		"cursor": Vector2(SCREEN_W * 0.5, HIT_Y), 
		"cursor_t": float(groups[0].t), 
		"last_dir": Vector2.ZERO, 
		"last_lane": -1, 
		"prev_t": -1.0, "prev_gap": 0.5, "prev_reg": "", 
		"holds": [], 
		"gestures": 0, 
		"invalid": [], "n_invalid": 0, 
		"red_moves": 0, "red_free": 0, 
		"slider_strain": 0.0, 
		"simul": 0, 


		"chain_i": 0, "red_i": 0, "splits": 0, 
	}

	var first_target = _group_anchor(groups[0], ctx)
	if first_target != null:
		st.cursor = first_target
	st.last_lane = _lane_at_x(_geom_at(ctx, float(groups[0].t)), float((st.cursor as Vector2).x))

	var first_t: = float(groups[0].t)
	var last_t: = first_t

	for step in steps:
		var t: = float(step[0])
		_advance(st, t)
		match int(step[1]):
			STEP_HOLD_END:
				_hold_end(st, step[3])
			STEP_ACT:
				last_t = t
				_do_group(st, ctx, step[3], reds, chains)
			STEP_RED:
				_do_red(st, ctx, step[3], lane_t, lane_l)
			STEP_TRACK:
				_do_track(st, ctx, step[4], step[3])
		_record(st, t)


	var ry: = _top_weighted(st.pk_ry, TOP_WEIGHT_RY) * W_RYTHME
	var vi: = _top_weighted(st.pk_vi, TOP_WEIGHT) * W_VISEE
	var le: = _top_weighted(st.pk_le, TOP_WEIGHT) * W_LECTURE
	var co: = _top_weighted(st.pk_co, TOP_WEIGHT) * W_COORD






	var mix: = {}
	var secs: = {}
	for k in st.pk_ry:
		secs[k] = true
	for k in st.pk_vi:
		secs[k] = true
	for k in st.pk_le:
		secs[k] = true
	for k in st.pk_co:
		secs[k] = true
	for k in secs:
		var a: = float(st.pk_ry.get(k, 0.0)) * W_RYTHME
		var b: = float(st.pk_vi.get(k, 0.0)) * W_VISEE
		var c: = float(st.pk_le.get(k, 0.0)) * W_LECTURE
		var d: = float(st.pk_co.get(k, 0.0)) * W_COORD
		mix[k] = pow(pow(a, MIX_POW) + pow(b, MIX_POW) + pow(c, MIX_POW)
			+ pow(d, MIX_POW), 1.0 / MIX_POW)
	var raw: float = _top_weighted(mix, TOP_WEIGHT_MIX)
	var charge: float = _shape(raw)





	var dur: float = maxf(last_t - first_t, 1.0)
	var tier: = tier_for(charge)


	var top_secs: Array = []
	for k in mix:
		top_secs.append([float(k) * SECTION, float(mix[k]), 
			float(st.pk_ry.get(k, 0.0)), float(st.pk_vi.get(k, 0.0)), 
			float(st.pk_le.get(k, 0.0)), float(st.pk_co.get(k, 0.0))])
	top_secs.sort_custom( func(a, b): return float(a[1]) > float(b[1]))
	top_secs = top_secs.slice(0, 8)

	var out: = {
		"level": charge, "charge": charge, 
		"rythme": _axis(ry), "visee": _axis(vi), "lecture": _axis(le), 
		"coordination": _axis(co), 
		"tier": tier[0], "color": tier[1], 
		"taps": int(st.gestures), "dur": dur, 
		"nps": float(st.gestures) / dur, 
		"peak": _peak(st), 
		"raw": [ry, vi, le, co, raw], 
		"peaks": [_max_of(st.pk_ry), _max_of(st.pk_vi), _max_of(st.pk_le), 
			_max_of(st.pk_co)], 
		"invalid_patterns": st.invalid, 
		"impossible_count": int(st.n_invalid), 
		"warnings": warnings, 
		"debug": {
			"groups": groups.size(), 
			"simultaneous_groups": int(st.simul), 
			"objects": objs.size(), 
			"red_objects": reds.instants.size(), 
			"red_windows": (reds.windows as Array).size(), 
			"red_moves": int(st.red_moves), 
			"red_free": int(st.red_free), 
			"slider_samples": n_slider_samples, 
			"slider_strain": snappedf(float(st.slider_strain), 0.01), 
			"chains": chains.size(), 
			"split_stops": int(st.splits), 
			"sections": secs.size(), 
			"top_sections": top_secs, 
			"first_t": first_t, "last_t": last_t, 
		}, 
	}


	if not is_finite(charge) or charge < 0.0:
		warnings.append("résultat non fini : chart aberrante, niveau plafonné")
		out.level = float(TIERS[TIERS.size() - 2][0])
		out.charge = out.level
		var tt: = tier_for(out.level)
		out.tier = tt[0]
		out.color = tt[1]
	return out




static func _group_anchor(g: Dictionary, ctx: Dictionary):
	for o in g.objs:
		var k: = String(o.kind)
		if k == "tap_aim" or k == "hold_aim":
			return o.pos
	for o in g.objs:
		var k2: = String(o.kind)
		if k2 == "tap_lane" or k2 == "hold_lane":
			var geo: = _geom_at(ctx, float(g.t))
			var lane: = int(o.lane)
			var cx: float = float(geo.x[lane]) if bool(geo.ok[lane])\
			else SCREEN_W * 0.5
			return Vector2(clampf(cx, 0.0, SCREEN_W), HIT_Y)
	return null






static func _advance(st: Dictionary, t: float) -> void :
	var dt: float = maxf(t - float(st.last_t), 0.0)
	if dt > 0.0:
		st.ry = float(st.ry) * exp( - dt / DECAY_TAU)
		st.vi = float(st.vi) * exp( - dt / DECAY_TAU_VI)
		st.le = float(st.le) * exp( - dt / DECAY_TAU)
		st.co = float(st.co) * exp( - dt / DECAY_TAU_CO)
	st.last_t = t






static func _add(st: Dictionary, d_ry: float, d_vi: float, d_le: float, 
		d_co: float) -> void :
	st.ry = minf(float(st.ry) + minf(maxf(_finite(d_ry), 0.0), MAX_D_RY), CAP_RY)
	st.vi = minf(float(st.vi) + minf(maxf(_finite(d_vi), 0.0), MAX_D_VI), CAP_VI)
	st.le = minf(float(st.le) + minf(maxf(_finite(d_le), 0.0), MAX_D_LE), CAP_LE)
	st.co = minf(float(st.co) + minf(maxf(_finite(d_co), 0.0), MAX_D_CO), CAP_CO)





static func _record(st: Dictionary, t: float) -> void :
	var sec: = int(floor(t / SECTION))
	if float(st.ry) > float(st.pk_ry.get(sec, 0.0)):
		st.pk_ry[sec] = float(st.ry)
	if float(st.vi) > float(st.pk_vi.get(sec, 0.0)):
		st.pk_vi[sec] = float(st.vi)
	if float(st.le) > float(st.pk_le.get(sec, 0.0)):
		st.pk_le[sec] = float(st.le)
	if float(st.co) > float(st.pk_co.get(sec, 0.0)):
		st.pk_co[sec] = float(st.co)





static func _flag(st: Dictionary, t: float, kind: String, detail: String) -> void :
	st.n_invalid = int(st.n_invalid) + 1
	if (st.invalid as Array).size() < MAX_INVALID_LOGGED:
		(st.invalid as Array).append({"t": snappedf(t, 0.001), "kind": kind, 
			"detail": detail})










static func _move_to(st: Dictionary, t: float, target: Vector2, tol: float, 
		avail: float, fixed: = -1.0) -> float:
	var cur: Vector2 = st.cursor
	var travel: float = minf(cur.distance_to(target), MAX_TRAVEL)
	if not is_finite(travel):
		travel = MAX_TRAVEL
	var dt: float = fixed if fixed > 0.0\
	else clampf(minf(t - float(st.cursor_t), maxf(avail, MIN_DT)), 
		MIN_DT, 30.0)
	var cost: = _aim_cost(travel, dt)


	cost *= clampf(pow(VI_PREC_REF / maxf(tol, 8.0), VI_PREC_POW), 
		VI_PREC_MIN, VI_PREC_MAX)



	var dir: = target - cur
	var last: Vector2 = st.last_dir
	if travel >= VI_ANGLE_MIN_TRAVEL and last.length() >= VI_ANGLE_MIN_TRAVEL:
		var c: float = last.normalized().dot(dir.normalized())
		cost *= 1.0 + VI_ANGLE_GAIN * clampf((1.0 - c) * 0.5, 0.0, 1.0)
	if travel > 0.5:
		st.last_dir = dir
	st.cursor = target
	st.cursor_t = t
	return cost






static func _aim_cost(travel: float, move_dt: float) -> float:
	var r: float = minf(maxf((travel / maxf(move_dt, MIN_DT)) / COMFORT_SPEED, 0.0), 
		MAX_SPEED_RATIO)
	var speed_cost: float = r if r <= FLICK_KNEE\
	else FLICK_KNEE + pow(r - FLICK_KNEE, FLICK_POW)
	var dist_f: = 1.0
	if travel > FLICK_DIST_REF:
		dist_f = pow(travel / FLICK_DIST_REF, FLICK_DIST_POW)
	return speed_cost * dist_f


static func _first_ge(arr: PackedFloat32Array, t: float) -> int:
	var lo: = 0
	var hi: = arr.size()
	while lo < hi:
		@warning_ignore("integer_division")
		var mid: = (lo + hi) / 2
		if arr[mid] < t:
			lo = mid + 1
		else:
			hi = mid
	return lo



static func _active_rail(st: Dictionary):
	for h in (st.holds as Array):
		if String(h.kind) == "hold_aim":
			return h
	return null


static func _hold_end(st: Dictionary, o: Dictionary) -> void :
	var hs: Array = st.holds
	for i in hs.size():
		if is_same(hs[i], o):
			hs.remove_at(i)
			return











static func _slider_samples(o: Dictionary) -> Array:
	var rail: Dictionary = o.rail
	var dur: float = maxf(float(o.dur), 0.001)
	var total: float = float(rail.total)
	var n: = clampi(int(round(total / SLIDER_SAMPLE_PX)), SLIDER_SAMPLE_MIN, 
		SLIDER_SAMPLE_MAX)
	n = maxi(n, mini(int(ceil(dur * SLIDER_SAMPLE_HZ)), SLIDER_SAMPLE_MAX))
	var us: Array = []
	for i in range(n + 1):
		us.append(float(i) / float(n))
	for p in (o.pts as Array):
		var f: = clampf(float(p[0]), 0.0, 1.0)
		if f > 0.001 and f < 0.999:
			us.append(f)
	us.sort()

	var clean: Array = []
	for u in us:
		if clean.is_empty() or float(u) - float(clean[-1]) > 0.0005:
			clean.append(float(u))
	if clean.size() > SLIDER_SAMPLE_MAX:
		var keep: Array = []
		var stride: = float(clean.size() - 1) / float(SLIDER_SAMPLE_MAX - 1)
		for i in SLIDER_SAMPLE_MAX:
			keep.append(clean[mini(int(round(float(i) * stride)), clean.size() - 1)])
		clean = keep
	var out: Array = []
	var prev: = _rail_pos(rail, clean[0])
	var prev_dir: = Vector2.ZERO
	for i in range(1, clean.size()):
		var u: float = clean[i]
		var p: = _rail_pos(rail, u)
		var dt: float = maxf((u - float(clean[i - 1])) * dur, 0.001)
		var seg: = p - prev
		var v: float = seg.length() / dt


		var follow: float = (v / COMFORT_SPEED) * SLIDER_PREC



		if prev_dir.length() > 1.0 and seg.length() > 1.0:
			var c: float = prev_dir.normalized().dot(seg.normalized())
			follow *= 1.0 + SLIDER_CURVE_GAIN * clampf((1.0 - c) * 0.5, 0.0, 1.0)
		out.append({"t": float(o.t) + u * dur, "pos": p, 
			"follow": minf(follow, SLIDER_MAX_FOLLOW), "dt": dt})
		if seg.length() > 1.0:
			prev_dir = seg
		prev = p
	return out






static func _lane_hold_samples(o: Dictionary) -> Array:
	var dur: float = maxf(float(o.dur), 0.001)
	var path: Array = o.get("path", [])
	var step: float = BEAM_SAMPLE if not path.is_empty() else LANE_HOLD_SAMPLE
	var n: = clampi(int(ceil(dur / step)), 1, 400)
	var out: Array = []
	for i in range(1, n + 1):
		var u: = float(i) / float(n)
		out.append({"t": float(o.t) + u * dur, "lane": _beam_lane(o, u)})
	return out




static func _beam_lane(o: Dictionary, u: float) -> int:
	var path: Array = o.get("path", [])
	if path.is_empty():
		return int(o.lane)
	var prev_u: = 0.0
	var prev_l: = float(o.lane)
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







static func _do_track(st: Dictionary, ctx: Dictionary, s: Dictionary, 
		o: Dictionary) -> void :
	if s.has("lane"):
		var geo: = _geom_at(ctx, float(s.t))
		var lane: = int(s.lane)
		if not bool(geo.ok[lane]):
			return
		var cur: Vector2 = st.cursor
		var r: = _reach_lane(geo, lane, cur.x)
		if float(r[1]) <= 0.5:
			st.last_lane = lane
			return
		var d: = _move_to(st, float(s.t), Vector2(float(r[0]), cur.y), 
			_lane_tol(geo, lane), LANE_HOLD_SAMPLE)
		_add(st, 0.0, d, 0.0, 0.0)
		st.last_lane = lane
		return



	var pos: Vector2 = s.pos
	var cur2: Vector2 = st.cursor
	var dir: = pos - cur2
	if dir.length() > 0.5:
		st.last_dir = dir
	st.cursor = pos
	st.cursor_t = float(s.t)
	var d_vi: float = minf(float(s.follow) * SLIDER_INJ_HZ * float(s.dt), MAX_D_VI)
	st.slider_strain = float(st.slider_strain) + d_vi
	_add(st, 0.0, d_vi, 0.0, 0.0)
	st.last_lane = _lane_at_x(_geom_at(ctx, float(s.t)), pos.x)




static func _do_red(st: Dictionary, ctx: Dictionary, w: Dictionary, 
		lane_t: PackedFloat32Array, lane_l: PackedInt32Array) -> void :
	var t: = float(w.t0)
	var geo: = _geom_at(ctx, t)
	var mask: = int(w.mask)


	var forb: Array = []
	for i in LANE_COUNT:
		if (mask & (1 << i)) != 0 and bool(geo.ok[i]):
			forb.append(i)
	if forb.is_empty():
		st.red_free = int(st.red_free) + 1
		return
	var allowed: Array = []
	for i in LANE_COUNT:
		if bool(geo.ok[i]) and not forb.has(i):
			allowed.append(i)
	var d_co: = 0.0
	var d_vi: = 0.0
	if allowed.is_empty():
		_flag(st, t, "all_lanes_forbidden", 
			"toutes les lanes jouables sont interdites au même instant")
		_add(st, 0.0, 0.0, 0.0, CO_INVALID)
		return
	var cur: = _lane_at_x(geo, float((st.cursor as Vector2).x))
	if forb.has(cur):




		var dest: = -1
		var j: = _first_ge(lane_t, t)
		while j < lane_t.size() and float(lane_t[j]) - t <= RED_LOOKAHEAD:
			if allowed.has(int(lane_l[j])):
				dest = int(lane_l[j])
				break
			j += 1
		if dest < 0:
			var best: = INF
			for l in allowed:
				var rr: = _reach_lane(geo, int(l), float((st.cursor as Vector2).x))
				if float(rr[1]) < best:
					best = float(rr[1])
					dest = int(l)
		var r2: = _reach_lane(geo, dest, float((st.cursor as Vector2).x))
		d_vi = _move_to(st, t, Vector2(float(r2[0]), float((st.cursor as Vector2).y)), 
			_lane_tol(geo, dest), APPROACH_LANE)
		st.red_moves = int(st.red_moves) + 1
	else:
		st.red_free = int(st.red_free) + 1



	if forb.size() >= 2:
		d_co += minf(CO_RED_TIGHT * float(forb.size() - 1), CO_RED_CAP)
	_add(st, 0.0, d_vi, 0.0, d_co)
	st.last_lane = _lane_at_x(geo, float((st.cursor as Vector2).x))





static func _do_group(st: Dictionary, ctx: Dictionary, g: Dictionary, 
		reds: Dictionary, chains: Array) -> void :
	var t: = float(g.t)
	var geo: = _geom_at(ctx, t)
	var objs: Array = g.objs
	if objs.size() > 1:
		st.simul = int(st.simul) + 1
	var flags0: = int(st.n_invalid)




	var seen: = _lane_at_x(geo, float((st.cursor as Vector2).x))



	var rail = _active_rail(st)
	var rail_pos: = Vector2.ZERO
	var rail_lane: = -1
	if rail != null:
		rail_pos = _rail_at(rail, t)
		st.cursor = rail_pos
		rail_lane = _lane_at_x(geo, rail_pos.x)


	var aim_targets: Array = []
	var lanes: Array = []
	var new_holds: Array = []
	var n_aim: = 0
	var n_lane: = 0
	var chain_mult: = 1.0
	var d_le: = 0.0
	var min_vis: = 9.0
	var has_aim: = false
	for o in objs:
		var k: = String(o.kind)
		min_vis = minf(min_vis, float(o.get("vis", APPROACH_LANE)))
		match k:
			"tap_aim":
				aim_targets.append(o.pos)
				n_aim += 1
				has_aim = true
				var ch: = int(o.get("chain", 0))
				if ch > 0:




					chain_mult = maxf(chain_mult, VI_CHAIN_BASE
						+ VI_CHAIN_STEP * float(mini(ch - 1, VI_CHAIN_MAX)))
					if int(o.get("step", 0)) > 0:
						d_le += clampf(LE_CHAIN_LEAD / maxf(float(o.lead), 0.06), 
							0.0, LE_CHAIN_CAP)
			"tap_lane":
				lanes.append(int(o.lane))
				n_lane += 1
			"hold_aim":
				aim_targets.append(o.pos)
				new_holds.append(o)
				has_aim = true
			"hold_lane":
				lanes.append(int(o.lane))
				new_holds.append(o)
	if min_vis > 8.0:
		min_vis = APPROACH_LANE





	var want: Array = []
	for l in lanes:
		var li: = int(l)
		if not bool(geo.ok[li]):
			_flag(st, t, "lane_unreachable", 
				"note sur la lane %d, sortie des zones atteignables" % li)
		elif not want.has(li):
			want.append(li)












	var stops: Array = []
	if aim_targets.size() == 1 and want.is_empty():
		stops.append({"pos": aim_targets[0], "tol": HIT_RADIUS, "aim": true, 
			"lane": -1})
	elif aim_targets.is_empty() and want.size() == 1:
		var only: = int(want[0])
		stops.append({"pos": Vector2.ZERO, "tol": _lane_tol(geo, only), 
			"aim": false, "lane": only})
	else:
		_build_stops(st, geo, aim_targets, want, stops)
	var ordered: = stops if stops.size() <= 1 else _order_stops(st, geo, stops)


	var d_vi: = 0.0
	var split: = 0
	for i in ordered.size():
		var s3: Dictionary = ordered[i]
		var pos: Vector2 = s3.pos
		if not bool(s3.aim):


			var rr: = _reach_lane(geo, int(s3.lane), float((st.cursor as Vector2).x))
			pos = Vector2(float(rr[0]), float((st.cursor as Vector2).y))
			s3.pos = pos




		var avail: float = SLIDER_GRACE if rail != null else min_vis
		var d: float = _move_to(st, t, pos, float(s3.tol), avail, 
			SPLIT_WINDOW if i > 0 else -1.0)
		if bool(s3.aim):
			d *= chain_mult
		d_vi += d
		if i > 0:
			split += 1
	_do_group_tail(st, geo, g, reds, chains, ordered, rail, rail_pos, 
		rail_lane, want, new_holds, n_aim, n_lane, has_aim, min_vis, 
		seen, d_vi, d_le, split, flags0)



static func _build_stops(st: Dictionary, geo: Dictionary, aim_targets: Array, 
		want: Array, stops: Array) -> void :
	var pool: Array = aim_targets.duplicate()
	while not pool.is_empty():

		var bi: = 0
		var bd: = INF
		for i in pool.size():
			var dd: float = (st.cursor as Vector2).distance_to(pool[i])
			if dd < bd:
				bd = dd
				bi = i
		var head: Vector2 = pool[bi]
		pool.remove_at(bi)


		var sum: = head
		var n: = 1
		var j: = pool.size() - 1
		while j >= 0:
			if head.distance_to(pool[j]) <= HIT_RADIUS:
				sum += pool[j]
				n += 1
				pool.remove_at(j)
			j -= 1
		stops.append({"pos": sum / float(n), "tol": HIT_RADIUS, "aim": true, 
			"lane": -1})
	for li in want:



		var covered: = false
		for s in stops:
			if bool(s.aim) and _lane_at_x(geo, float((s.pos as Vector2).x)) == li:
				covered = true
				break
		if not covered:
			stops.append({"pos": Vector2.ZERO, "tol": _lane_tol(geo, li), 
				"aim": false, "lane": li})



static func _order_stops(st: Dictionary, geo: Dictionary, stops: Array) -> Array:
	var ordered: Array = []
	var ref: Vector2 = st.cursor
	while not stops.is_empty():
		var bi2: = 0
		var bd2: = INF
		for i in stops.size():
			var p: Vector2 = stops[i].pos
			if not bool(stops[i].aim):
				p = Vector2(float(_reach_lane(geo, int(stops[i].lane), ref.x)[0]), ref.y)
			var dd2: float = ref.distance_to(p)
			if dd2 < bd2:
				bd2 = dd2
				bi2 = i
		var s2: Dictionary = stops[bi2]
		stops.remove_at(bi2)
		if not bool(s2.aim):
			s2.pos = Vector2(float(_reach_lane(geo, int(s2.lane), ref.x)[0]), ref.y)
		ordered.append(s2)
		ref = s2.pos
	return ordered





static func _do_group_tail(st: Dictionary, geo: Dictionary, g: Dictionary, 
		reds: Dictionary, chains: Array, ordered: Array, rail, rail_pos: Vector2, 
		rail_lane: int, want: Array, new_holds: Array, n_aim: int, n_lane: int, 
		has_aim: bool, min_vis: float, seen: int, d_vi: float, d_le: float, 
		split: int, flags0: int) -> void :
	var t: = float(g.t)



	if rail != null and not ordered.is_empty():
		var far: = 0.0
		for s4 in ordered:
			far = maxf(far, rail_pos.distance_to(s4.pos))
		if far > RAIL_TOL:
			if 2.0 * far / (MAX_SPEED_RATIO * COMFORT_SPEED) > SLIDER_GRACE:
				_flag(st, t, "hold_broken", 
					"l'action force à quitter le rail (%d px) : la tenue casse"
					%int(far))
			else:
				d_vi += CO_RAIL_CROSS






	var presses: int = new_holds.size() + maxi(n_aim, n_lane)
	if presses <= 0:
		presses = 1
	var busy: int = (st.holds as Array).size()
	var free: int = 2 - busy




	if presses > maxi(free, 1) * PRESS_PER_KEY:
		_flag(st, t, "input_overflow", 
			"%d pression(s) au même instant pour %d touche(s) libre(s)"
			%[presses, maxi(free, 0)])
	var gap: = 1.0
	if float(st.prev_t) >= 0.0:
		gap = maxf(t - float(st.prev_t), MIN_DT)
	var d_ry: = 1.0 / gap
	if float(st.prev_t) >= 0.0:
		var ratio: = gap / maxf(float(st.prev_gap), MIN_DT)
		d_ry *= 1.0 + clampf(absf(log(ratio)) * RY_IRREG_GAIN, 0.0, RY_IRREG_CAP)
	d_ry *= 1.0 + RY_CHORD_GAIN * float(mini(presses - 1, RY_CHORD_MAX - 1))



	if busy > 0 and (n_aim + n_lane) > 0:
		d_ry *= 1.0 + RY_ONE_HAND * clampf(1.0 - gap / RY_ONE_HAND_GAP, 0.0, 1.0)


	var reg: = "aim" if has_aim else "lane"
	if String(st.prev_reg) != "" and reg != String(st.prev_reg):
		d_le += clampf(LE_SWITCH / gap, 0.0, LE_SWITCH_CAP)



	if min_vis < LE_VIS_REF:
		d_le += clampf((LE_VIS_REF / maxf(min_vis, 0.02) - 1.0) * LE_VIS_GAIN, 
			0.0, LE_VIS_CAP)
	for li2 in want:
		if float(geo.alpha[li2]) < 0.15:
			d_le += LE_HIDDEN_LANE
		if bool(geo.off[li2]):
			d_le += LE_OFFSCREEN_LANE
	if float(geo.glitch) > 0.1:



		d_le += LE_GLITCH * clampf(float(geo.glitch) / 40.0, 0.0, 1.0)
	if int(st.last_lane) >= 0 and seen != int(st.last_lane):
		d_le += LE_LANE_SWAP


	var d_co: = 0.0
	for h in (st.holds as Array):
		if String(h.kind) == "hold_aim":
			d_co += CO_TAP_UNDER_AIM_HOLD
			for li3 in want:
				if rail_lane >= 0 and rail_lane != li3:


					d_co += CO_RAIL_CROSS
		else:
			d_co += CO_TAP_UNDER_LANE_HOLD
			for li4 in want:
				if int(h.lane) != li4:
					d_co += CO_RAIL_CROSS
	if busy >= 2:
		d_co += CO_BOTH_BUSY
	if not new_holds.is_empty() and busy > 0:
		d_co += CO_HOLD_ENTRY * float(new_holds.size())


	if n_lane > 0 and _in_chain(st, chains, t):
		d_co += CO_TAP_UNDER_CHAIN



	for li5 in want:
		if _red_hits(st, reds, t, li5):
			d_co += CO_RED_ON_LANE



	d_co += CO_RAIL_CROSS * float(split)


	d_co += CO_INVALID * float(int(st.n_invalid) - flags0)


	st.gestures = int(st.gestures) + presses
	st.splits = int(st.splits) + split
	_add(st, d_ry, d_vi, d_le, d_co)
	st.prev_gap = gap
	st.prev_t = t
	st.prev_reg = reg
	st.last_lane = _lane_at_x(geo, float((st.cursor as Vector2).x))
	for h in new_holds:
		if (st.holds as Array).size() < 4:
			(st.holds as Array).append(h)




static func _in_chain(st: Dictionary, chains: Array, t: float) -> bool:
	var i: = int(st.chain_i)
	while i < chains.size() and float(chains[i][1]) < t:
		i += 1
	st.chain_i = i
	for j in range(i, chains.size()):
		if float(chains[j][0]) > t:
			return false
		if t > float(chains[j][0]) and t < float(chains[j][1]):
			return true
	return false



static func _red_hits(st: Dictionary, reds: Dictionary, t: float, lane: int) -> bool:
	var inst: Array = reds.instants
	var i: = int(st.red_i)
	while i < inst.size() and float(inst[i].t1) < t - RED_CONFLICT:
		i += 1
	st.red_i = i
	for j in range(i, inst.size()):
		if float(inst[j].t) > t + RED_CONFLICT:
			return false
		if (int(inst[j].mask) & (1 << lane)) != 0:
			return true
	return false










static func _top_weighted(peaks: Dictionary, weight: = TOP_WEIGHT) -> float:
	var vals: Array = []
	for k in peaks:
		vals.append(float(peaks[k]))
	if vals.is_empty():
		return 0.0
	vals.sort()
	vals.reverse()
	var total: = 0.0
	var w: = 1.0
	for v in vals:
		total += float(v) * w
		w *= weight
		if w < 0.0025:
			break
	return total * (1.0 - weight)


static func _max_of(pk: Dictionary) -> float:
	var best: = 0.0
	for k in pk:
		best = maxf(best, float(pk[k]))
	return best



static func _peak(st: Dictionary) -> float:
	var best: = 0.0
	for k in st.pk_ry:
		best = maxf(best, float(st.pk_ry[k]) + float(st.pk_vi.get(k, 0.0))
			+ float(st.pk_le.get(k, 0.0)) + float(st.pk_co.get(k, 0.0)))
	return best


















static func _shape(raw: float) -> float:
	return snappedf(pow(maxf(_finite(raw), 0.0), 0.7577) * 0.3526, 0.01)




static func _axis(v: float) -> float:
	return snappedf(clampf(pow(maxf(_finite(v), 0.0), 0.59) * 1.09 * 0.62, 
		0.0, 10.0), 0.1)
