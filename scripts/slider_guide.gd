class_name SliderGuide
extends Node2D



















const StageRender = preload("res://scripts/stage_render.gd")

var time: = 0.0
var duration: = 1.0
var points: Array = []
var type: = "sliderg"
var judged: = false
var lane: = -1
var speed: = 1.0

var caught: = false
var broken: = false
var head_missed: = false
var drops: = 0
var hold_src: = ""
var grace: = 0.0
var next_tick: = 0.0
var held_time: = 0.0
var catch_late: = 0.0
var off_time: = 0.0
var repeats: Array = []
var tick_pulse: = 0.0
var order: = 0
var priority: = 0
var main
var glow_tex: Texture2D

var body: SliderBody = null

var _order_str: = ""
var _font: Font = null
var _t: = 0.0
var _ball: = Vector2.ZERO
var _was_caught: = false
var _fc_anim: = 1.0
var _catch_t: = -1.0
var _dropped: = false
var _dim: = 0.0
var _appear: = 0.0
var _end_t: = -1.0
var _end_result: = ""


var _arc_pts: = PackedVector2Array()
var _arc_len: = PackedFloat32Array()
var _arc_total: = 0.0

var _body: = PackedVector2Array()
var _geom_hw: = -1.0
var _geom_legacy: = false


func _ready() -> void :
	set_process(false)




func _notification(what: int) -> void :
	if what != NOTIFICATION_PREDELETE or body == null or not is_instance_valid(body):
		return
	if body.get_parent() == null:
		body.free()


func set_order(n: int) -> void :
	order = n
	_order_str = str(n) if n > 0 else ""




func attach_body(root: Node2D) -> void :
	if body == null:
		body = SliderBody.new()
	if body.get_parent() != root:
		if body.get_parent() != null:
			body.get_parent().remove_child(body)
		root.add_child(body)

	root.move_child(body, 0)
	body.reset()



func reset() -> void :
	time = 0.0
	duration = 1.0
	points = []
	judged = false
	speed = 1.0
	caught = false
	broken = false
	head_missed = false
	hold_src = ""
	grace = 0.0
	next_tick = 0.0
	held_time = 0.0
	catch_late = 0.0
	off_time = 0.0




	drops = 0
	repeats = []
	tick_pulse = 0.0
	set_order(0)
	priority = 0
	_t = 0.0
	_ball = Vector2.ZERO
	_was_caught = false
	_fc_anim = 1.0
	_catch_t = -1.0
	_dropped = false
	_dim = 0.0
	_appear = 0.0
	_end_t = -1.0
	_end_result = ""
	_arc_pts = PackedVector2Array()
	_arc_len = PackedFloat32Array()
	_arc_total = 0.0
	_body = PackedVector2Array()
	_geom_hw = -1.0
	scale = Vector2.ONE
	modulate = Color.WHITE
	visible = true
	set_process(false)
	if body != null:
		body.reset()
		if body.get_parent() != null:
			body.get_parent().remove_child(body)


func update_visual(song_time: float, tun) -> void :
	var dt: = maxf(song_time - _t, 0.0)
	_t = song_time
	if judged:
		return

	_ball = pos_at_time(song_time)
	if caught and not _was_caught:
		_fc_anim = 0.0
		if _catch_t < 0.0:
			_catch_t = song_time
		_dropped = false
	elif not caught and _was_caught:
		_dropped = true
	_was_caught = caught
	_fc_anim = minf(_fc_anim + dt / 0.12, 1.0)
	tick_pulse = maxf(tick_pulse - dt * 6.0, 0.0)


	var p_app: = clampf((time - _t) / float(tun.sliderg_approach_time), 0.0, 1.0)
	_appear = clampf((1.0 - p_app) / 0.35, 0.0, 1.0)



	var p_head: = clampf((time - _t) / (float(tun.click_approach_time) / speed), 0.0, 1.0)
	_appear *= Mods.mirage_alpha(p_head, true)
	var legacy: = StageRender.legacy()
	var want: float = 0.0 if priority <= 0 or legacy else (0.6 if priority == 1 else 1.0)
	_dim = move_toward(_dim, want * float(tun.future_dim), 5.0 * get_process_delta_time())
	if body != null:
		if legacy and not _body.is_empty():


			var n: = _body.size() - 1
			var u_cut: = travelled()
			var first_ahead: = int(floor(u_cut * n)) + 1
			body.set_cut(maxi(n + 1 - first_ahead, 0), pos_at(u_cut), 
				u_cut > 0.0 and u_cut < 1.0, first_ahead)
		body.set_state(_appear, _dim, _dropped or broken)
	queue_redraw()




func _raw_pos_at(u: float) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	if points.size() == 1:
		return points[0][1]
	u = clampf(u, 0.0, 1.0)
	var last: = points.size() - 1
	if u <= float(points[0][0]):
		return points[0][1]
	for i in last:
		var u0: = float(points[i][0])
		var u1: = float(points[i + 1][0])
		if u > u1:
			continue
		var s: = 0.0 if u1 - u0 < 0.0001 else (u - u0) / (u1 - u0)
		var p0: Vector2 = points[maxi(i - 1, 0)][1]
		var p1: Vector2 = points[i][1]
		var p2: Vector2 = points[i + 1][1]
		var p3: Vector2 = points[mini(i + 2, last)][1]
		return 0.5 * ((2.0 * p1) + ( - p0 + p2) * s
			+ (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * s * s
			+ ( - p0 + 3.0 * p1 - 3.0 * p2 + p3) * s * s * s)
	return points[last][1]


func _ensure_arc() -> void :
	if _arc_pts.size() > 0 or points.is_empty():
		return
	var m: = 160
	var prev: = _raw_pos_at(0.0)
	var acc: = 0.0
	_arc_pts.append(prev)
	_arc_len.append(0.0)
	for i in range(1, m + 1):
		var p: = _raw_pos_at(float(i) / m)
		acc += prev.distance_to(p)
		_arc_pts.append(p)
		_arc_len.append(acc)
		prev = p
	_arc_total = maxf(acc, 0.001)




func pos_at(u: float) -> Vector2:
	_ensure_arc()
	if _arc_pts.is_empty():
		return Vector2.ZERO
	var target: = clampf(u, 0.0, 1.0) * _arc_total
	var lo: = 0
	var hi: = _arc_len.size() - 1
	while lo < hi:
		var mid: = (lo + hi) / 2
		if _arc_len[mid] < target:
			lo = mid + 1
		else:
			hi = mid
	if lo == 0:
		return _arc_pts[0]
	var l0: = _arc_len[lo - 1]
	var l1: = _arc_len[lo]
	var k: = 0.0 if l1 - l0 < 0.001 else (target - l0) / (l1 - l0)
	return _arc_pts[lo - 1].lerp(_arc_pts[lo], k)



func pos_at_time(t: float) -> Vector2:
	return pos_at((t - time) / duration)



func travelled() -> float:
	if _t < time:
		return 0.0
	return clampf((_t - time) / duration, 0.0, 1.0)



func visible_body(u_cut: float, samples: = 72) -> PackedVector2Array:
	var out: = PackedVector2Array()
	if points.is_empty():
		return out
	u_cut = clampf(u_cut, 0.0, 1.0)
	out.append(pos_at(u_cut))
	for i in samples + 1:
		if float(i) / samples > u_cut:
			out.append(pos_at(float(i) / samples))
	return out




func _ensure_geom(hr: float, tun) -> void :
	var legacy: = StageRender.legacy()
	if not _body.is_empty() and absf(_geom_hw - hr) < 0.01 and _geom_legacy == legacy:
		return
	_ensure_arc()
	var n: = clampi(int(_arc_total / (5.0 if legacy else 6.0)), 12, 220)
	_body = PackedVector2Array()
	_body.resize(n + 1)
	for i in n + 1:
		_body[i] = pos_at(float(i) / n)
	if body != null:
		if legacy:


			var rev: = PackedVector2Array()
			for i in range(_body.size() - 1, -1, -1):
				rev.append(_body[i])
			var rim_w: float = clampf(float(tun.slider_rail_width), 3.0, 8.0)
			body.setup_legacy(StageRender.slider_mesh(rev, hr), 
				StageRender.slider_mesh(rev, hr - rim_w), _body, hr, rim_w, glow_tex)
		else:
			body.setup_flat(StageRender.slider_geometry(_body, hr, float(tun.slider_outline_width)))
	_geom_hw = hr
	_geom_legacy = legacy



func resolve(result: String) -> void :
	judged = true
	_end_result = result
	_end_t = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void :
	if not judged:
		return
	_end_t += delta
	var tun = StageRender.tuning
	var dur: float = (tun.hit_anim_time if tun != null else 0.14)
	if _end_t >= dur:
		_finish()
		return
	if body != null:
		body.set_state(_appear * (1.0 - _end_t / dur), _dim, _dropped or broken)
	queue_redraw()


func _finish() -> void :
	if main != null and main.has_method("_release_note"):
		main._release_note(self)
	else:
		queue_free()


func _draw() -> void :
	if main == null or points.is_empty():
		return
	var tun = main.tuning
	var hr: float = tun.click_hit_radius
	var q: = SettingsManager.gfx_k(SettingsManager.gfx_slider)
	if _font == null:
		_font = main.font_bold
	var font: = _font
	_ensure_geom(hr, tun)
	var n: = _body.size() - 1
	var endp: = _body[n]
	var legacy: = StageRender.legacy()
	if judged:
		if legacy:
			return


		var dur: float = tun.hit_anim_time
		var u: = clampf(_end_t / dur, 0.0, 1.0)
		if _end_result == "PERFECT" or _end_result == "GOOD":
			var strong: = 1.0 if _end_result == "PERFECT" else 0.6
			var s: = 0.9
			if u > 0.25:
				var e: = (u - 0.25) / 0.75
				e = 1.0 - (1.0 - e) * (1.0 - e)
				s = lerpf(0.9, 1.12, e)
			draw_set_transform(endp, 0.0, Vector2(s, s))
			StageRender.slider_ball(self, Vector2.ZERO, 1.0, hr, true, 0.0, 
				1.0 - smoothstep(0.3, 1.0, u))
			if u < 0.25 and q > 0.0:
				StageRender.aim_flash(self, Vector2.ZERO, 1.0, hr * 0.74, 
					float(tun.hit_flash) * (1.0 - u / 0.25) * strong, q)
			draw_set_transform(Vector2.ZERO)
			StageRender.aim_hit_ring(self, endp, 1.0, hr * 0.8, u, strong)
		else:
			StageRender.slider_ball(self, endp, 1.0, hr, false, 0.0, 1.0 - u)
		return

	var a: = _appear
	var u_cut: = travelled()




	var span: float = float(repeats[0]) if not repeats.is_empty() else 1.0
	for rf in repeats:
		var f: = float(rf)
		if u_cut >= f - 0.0005 or u_cut < f - 2.0 * span - 0.0005:
			continue
		var rp: = pos_at(f)
		var back: = pos_at(maxf(f - 0.03, 0.0))
		var rdir: = (back - rp).normalized()
		if rdir == Vector2.ZERO:
			continue
		StageRender.slider_arrow(self, rp, rdir, 1.0, hr, sin(_t * 10.0), a)


	StageRender.slider_tail(self, endp, 1.0, hr, a, _dim)



	var head: = _body[0]
	if not caught and not head_missed and held_time == 0.0 and _t <= time + tun.good_s():
		var pr: = clampf((time - _t) / (float(tun.click_approach_time) / speed), 0.0, 1.0)
		var pe: = pow(pr, maxf(float(tun.approach_ease), 0.05))
		StageRender.slider_head(self, head, 1.0, hr, 
			hr + pe * (float(tun.click_ring_start_radius) - hr), a, _order_str, font, _dim)
	elif not legacy and _catch_t >= 0.0 and _t - _catch_t < float(tun.hit_anim_time):
		var u: = clampf((_t - _catch_t) / float(tun.hit_anim_time), 0.0, 1.0)
		var s: = 0.9
		if u > 0.25:
			var e: = (u - 0.25) / 0.75
			s = lerpf(0.9, 1.1, 1.0 - (1.0 - e) * (1.0 - e))
		draw_set_transform(head, 0.0, Vector2(s, s))
		StageRender.aim_body(self, Vector2.ZERO, 1.0, hr, 1.0 - smoothstep(0.3, 1.0, u), 
			0.0, false, false, q)
		if u < 0.25 and q > 0.0:
			StageRender.aim_flash(self, Vector2.ZERO, 1.0, hr, 
				float(tun.hit_flash) * (1.0 - u / 0.25), q)
		draw_set_transform(Vector2.ZERO)



	if _t >= time and _t <= time + duration and not broken:
		var b: = _ball
		var grow: = 1.0 - pow(1.0 - _fc_anim, 3.0)
		var tol: = float(tun.slider_rail_tolerance)
		if legacy:
			var inside_l: = true
			if caught:
				var aim_l: Vector2 = main.auto_cursor if main.auto_mode else main.aim_position()
				inside_l = aim_l.distance_to(b) <= tol
			StageRender.slider_ball_legacy(self, b, 1.0, hr, caught, glow_tex, q)
			StageRender.slider_follow_legacy(self, b, 1.0, tol, caught, inside_l, grow, hr * 0.88)
		elif caught:
			var aim: Vector2 = main.auto_cursor if main.auto_mode else main.aim_position()
			var inside: bool = aim.distance_to(b) <= tol
			StageRender.slider_ball(self, b, 1.0, hr, true, tick_pulse, 1.0)
			StageRender.slider_follow(self, b, 1.0, tol, inside, grow, 1.0)
		else:
			StageRender.slider_ball(self, b, 1.0, hr, false, 0.0, 1.0)
			StageRender.slider_follow(self, b, 1.0, tol, true, 1.0, 0.35)
