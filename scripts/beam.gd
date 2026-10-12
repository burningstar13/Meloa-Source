class_name Beam
extends Node2D






var time: = 0.0
var duration: = 1.0
var lane: = 1
var path: Array = []
var type: = "beam"
var judged: = false

var caught: = false
var broken: = false
var grace: = 0.0
var next_tick: = 0.0
var main
var glow_tex: Texture2D



var speed: = 1.0

var _t: = 0.0



func _state_col() -> Color:
	if broken:
		return Skins.col("beam_broken")
	if caught:
		return Skins.col("beam_active")
	return Skins.col("beam_idle")


func update_visual(song_time: float, _tuning) -> void :
	_t = song_time
	queue_redraw()



func lane_frac_at(u: float) -> float:
	if path.is_empty():
		return float(lane)
	var prev_u: = 0.0
	var prev_l: = float(lane)
	for p in path:
		var pu: float = p[0]
		var pl: float = p[1]
		if u <= pu:
			if pu - prev_u < 0.0001:
				return pl
			return lerpf(prev_l, pl, (u - prev_u) / (pu - prev_u))
		prev_u = pu
		prev_l = pl
	return prev_l



func lane_at(t: float) -> int:
	return roundi(lane_frac_at(clampf((t - time) / duration, 0.0, 1.0)))



func _x_at(lf: float, y: float) -> float:
	var li: = clampi(int(floorf(lf)), 0, 2)
	var lj: = mini(li + 1, 2)
	return lerpf(main.lane_x_at(li, y), main.lane_x_at(lj, y), lf - li)


func resolve(_result: String) -> void :
	judged = true
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(queue_free)


func _draw() -> void :
	if main == null:
		return
	var tun = main.tuning

	var s0: = maxf(_t, time)
	var s1: = time + duration
	if s0 >= s1:
		s0 = s1 - 0.01
	var col: = _state_col()



	var tt: float = tun.travel_time / maxf(speed, 0.05)
	var pts_l: = PackedVector2Array()
	var pts_r: = PackedVector2Array()
	var centers: = PackedVector2Array()
	var s: = s0
	while true:
		var y: = lerpf(tun.spawn_y, tun.hit_y, 1.0 - (s - _t) / tt)
		if y < tun.spawn_y - 20.0:
			break
		var lf: = lane_frac_at(clampf((s - time) / duration, 0.0, 1.0))
		var x: = _x_at(lf, y)
		var hw: = 15.0 if caught else 12.0
		centers.append(Vector2(x, y))
		pts_l.append(Vector2(x - hw, y))
		pts_r.append(Vector2(x + hw, y))
		if s >= s1:
			break
		s = minf(s + tt * 28.0 / (tun.hit_y - tun.spawn_y), s1)
	if centers.size() < 2:
		return


	var fill: = PackedVector2Array(pts_l)
	var right_rev: = PackedVector2Array(pts_r)
	right_rev.reverse()
	fill.append_array(right_rev)
	draw_colored_polygon(fill, Color(col.r, col.g, col.b, 0.16 if not caught else 0.26))
	draw_polyline(pts_l, Color(col.r * 1.3, col.g * 1.3, col.b * 1.3, 0.85), 2.5)
	draw_polyline(pts_r, Color(col.r * 1.3, col.g * 1.3, col.b * 1.3, 0.85), 2.5)

	var core_a: = 0.65 + 0.3 * sin(_t * 14.0) if caught else 0.35
	draw_polyline(centers, Color(col.r * 1.5, col.g * 1.5, col.b * 1.5, core_a), 4.0)


	for k in 3:
		var pu: = fposmod(_t * 0.9 + k / 3.0, 1.0)
		var idx: = int(pu * (centers.size() - 1))
		draw_circle(centers[idx], 5.0, Color(col.r * 1.4, col.g * 1.4, col.b * 1.4, 0.5))


	var head: = centers[0]
	if glow_tex != null:
		var gs: = 120.0 if caught else 90.0
		draw_texture_rect(glow_tex, Rect2(head - Vector2(gs, gs) * 0.5, Vector2(gs, gs)), 
			false, Color(col.r, col.g, col.b, 0.4 if caught else 0.24))
	var r: = 17.0 if caught else 13.0
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(0, - r), head + Vector2(r, 0), 
		head + Vector2(0, r), head + Vector2( - r, 0), 
	]), Color(col.r * 1.4, col.g * 1.4, col.b * 1.4))
	draw_colored_polygon(PackedVector2Array([
		head + Vector2(0, - r * 0.5), head + Vector2(r * 0.5, 0), 
		head + Vector2(0, r * 0.5), head + Vector2( - r * 0.5, 0), 
	]), Color(0.04, 0.05, 0.08))


	var tail: = centers[centers.size() - 1]
	if absf(s - s1) < 0.001 or centers.size() >= 2:
		var close: = clampf(1.0 - (s1 - _t) / 0.8, 0.0, 1.0)
		draw_arc(tail, 14.0 + 4.0 * close, 0.0, TAU, 24, 
			Color(col.r * (1.0 + close), col.g * (1.0 + close), col.b * (1.0 + close), 
				0.5 + 0.5 * close), 2.5 + 2.0 * close)
