class_name SliderMania
extends Node2D













var time: = 0.0
var duration: = 1.0
var lane: = 1
var type: = "sliderm"
var judged: = false

var caught: = false
var broken: = false
var head_missed: = false
var drops: = 0
var hold_src: = ""




var speed: = 1.0
var grace: = 0.0
var next_tick: = 0.0
var held_time: = 0.0
var catch_late: = 0.0
var main
var glow_tex: Texture2D

const StageRender = preload("res://scripts/stage_render.gd")

var _t: = 0.0


func update_visual(song_time: float, _tuning) -> void :
	_t = song_time
	queue_redraw()


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
	var col: = Skins.col("hold_idle")
	if broken:
		col = Skins.col("hold_broken")
	elif caught:
		col = Skins.col("hold_active")
	elif _t > time and _t < s1:
		col = Skins.col("hold_free")

	var w: float = tun.slider_rail_width



	var tt: float = tun.travel_time / maxf(speed, 0.05)
	var pts: = PackedVector2Array()
	var s: = s0
	while true:
		var y: = lerpf(tun.spawn_y, tun.hit_y, 1.0 - (s - _t) / tt)
		if y < tun.spawn_y - 20.0:
			break
		pts.append(Vector2(main.lane_x_at(lane, y), y))
		if s >= s1:
			break
		s = minf(s + tt * 26.0 / (tun.hit_y - tun.spawn_y), s1)
	if pts.size() < 2:
		return



	var p_m: = clampf((time - _t) / tt, 0.0, 1.0)
	var ma: = Mods.mirage_alpha(p_m)


	StageRender.hold_rail(self, pts, 1.0, w, col, caught, 
		0.55 + 0.35 * sin(_t * 12.0), ma)

	var head: = pts[0]
	StageRender.hold_head(self, head, 1.0, col, caught, glow_tex, 1.0 if caught else ma)


	if not caught and not broken and _t > time and _t < s1:
		draw_arc(head, 26.0 + 3.0 * sin(_t * 6.0), 0.0, TAU, 32, 
			Color(1.0, 1.0, 1.0, 0.35 * maxf(ma, 0.35)), 2.5)


	var tail: = pts[pts.size() - 1]
	var close: = clampf(1.0 - (s1 - _t) / 0.8, 0.0, 1.0)
	draw_arc(tail, 13.0 + 4.0 * close, 0.0, TAU, 24, 
		Color(col.r * (1.0 + close * 0.5), col.g * (1.0 + close * 0.5), 
		col.b * (1.0 + close * 0.5), (0.5 + 0.5 * close) * ma), 2.5 + 2.0 * close)
