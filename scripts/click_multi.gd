class_name ClickMulti
extends Node2D
















const StageRender = preload("res://scripts/stage_render.gd")

var time: = 0.0
var type: = "clickx"
var lane: = -1
var judged: = false
var speed: = 1.0
var glow_tex: Texture2D
var font: Font = null

var hits: Array = []
var idx: = 0

var _hit_radius: = 40.0
var _ring_radius: = 0.0
var _appear: = 0.0
var _flash: = 0.0
var _hurt: = 0.0
var _missed: = 0


func setup(first_t: float, first_pos: Vector2, extra: Array) -> void :
	hits = [[first_t, first_pos]]
	for e in extra:
		hits.append([float(e[0]), Vector2(float(e[1]), float(e[2]))])
	time = first_t
	position = first_pos


func remaining() -> int:
	return hits.size() - idx




func _window(tun) -> float:
	if idx == 0:
		return tun.click_approach_time / speed
	return maxf(float(hits[idx][0]) - float(hits[idx - 1][0]), 0.08)



func advance_step() -> void :
	idx += 1
	time = float(hits[idx][0])
	_flash = 1.0
	var tw: = create_tween()
	tw.tween_property(self, "_flash", 0.0, 0.16)





func miss_step() -> void :
	idx += 1
	_missed += 1
	time = float(hits[idx][0])
	_hurt = 1.0
	var tw: = create_tween()
	tw.tween_property(self, "_hurt", 0.0, 0.32)


func update_visual(song_time: float, tun) -> void :
	if judged:
		return
	_hit_radius = tun.click_hit_radius
	var step_t: = float(hits[idx][0])
	var win: = _window(tun)
	var p: = clampf((step_t - song_time) / win, 0.0, 1.0)


	var start: float = _hit_radius + (tun.click_ring_start_radius - _hit_radius)\
	* clampf(win / (tun.click_approach_time / speed), 0.45, 1.0)
	_ring_radius = _hit_radius + p * (start - _hit_radius)



	_appear = clampf((1.0 - p) / 0.35, 0.0, 1.0) * Mods.mirage_alpha(p, true)\
	if idx == 0 else 1.0


	if idx > 0:
		var t0: = float(hits[idx - 1][0])
		var k: = clampf((song_time - t0) / maxf((step_t - t0) * 0.45, 0.05), 0.0, 1.0)
		k = k * k * (3.0 - 2.0 * k)
		position = (hits[idx - 1][1] as Vector2).lerp(hits[idx][1] as Vector2, k)
	queue_redraw()


func resolve(result: String) -> void :
	judged = true
	var tw: = create_tween()
	if result == "PERFECT" or result == "GOOD":
		_flash = 1.0
		tw.tween_property(self, "_flash", 0.0, 0.16)
		tw.parallel().tween_property(self, "scale", scale * 1.42, 0.16)\
		.set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.18)
	else:
		tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)


func _process(_delta: float) -> void :
	if judged or _flash > 0.0 or _hurt > 0.0:
		queue_redraw()


func _draw() -> void :
	var a: = _appear




	if SettingsManager.gfx_k(SettingsManager.gfx_click) >= 0.5:
		StageRender.aim_glow(self, Vector2.ZERO, 1.0, _hit_radius, glow_tex, 
			0.3 * a, 4.6)


	StageRender.aim_circle(self, Vector2.ZERO, 1.0, _hit_radius, 0.0, a, 1.0, true)


	var rem: = remaining()
	StageRender.aim_pips(self, Vector2.ZERO, 1.0, _hit_radius, rem, a)

	StageRender.aim_count(self, Vector2.ZERO, 1.0, _hit_radius, rem, font, _flash, a)





	if not judged and idx + 1 < hits.size():
		var ga: = (0.22 + 0.38 * _appear * (1.0 - clampf(
			(_ring_radius - _hit_radius) / 80.0, 0.0, 1.0)))
		var prev_p: = Vector2.ZERO
		for j in range(idx + 1, hits.size()):
			var gp: = (hits[j][1] as Vector2) - position
			var gaj: = ga * pow(0.62, float(j - idx - 1))
			if gaj < 0.05:
				break
			StageRender.aim_link(self, prev_p, gp, 1.0, _hit_radius, gaj, 
				j == idx + 1, 1.0 if j == idx + 1 else 0.85)
			StageRender.aim_ghost(self, gp, 1.0, _hit_radius, 
				hits.size() - j, gaj, font)
			prev_p = gp

	if not judged:
		StageRender.aim_ring(self, Vector2.ZERO, 1.0, _hit_radius, _ring_radius, a)
	StageRender.aim_flash(self, Vector2.ZERO, 1.0, _hit_radius, _flash, 1.0, true)



	var mcol: = Skins.col("clickx_miss")
	if _missed > 0 and not judged:
		draw_arc(Vector2.ZERO, _hit_radius + 6.0, 0.0, TAU, 48, 
			Color(mcol, 0.1 + 0.1 * float(_missed)), 2.0)
	if _hurt > 0.0:
		draw_circle(Vector2.ZERO, _hit_radius, Color(mcol, 0.42 * _hurt))
		draw_arc(Vector2.ZERO, _hit_radius, 0.0, TAU, 48, 
			Color(mcol.r * 1.18, mcol.g * 1.18, mcol.b * 1.14, 0.85 * _hurt), 5.0)
