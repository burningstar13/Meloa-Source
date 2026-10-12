class_name ClickTarget
extends Node2D







var time: = 0.0
var type: = "click"
var lane: = -1
var judged: = false

var glow_tex: Texture2D


var speed: = 1.0

var order: = 0
var _order_str: = ""


var priority: = 0
var main = null

const StageRender = preload("res://scripts/stage_render.gd")



var next_aim: = Vector2.ZERO

var _ring_radius: = 0.0
var _hit_radius: = 40.0
var _appear: = 0.0
var _dim: = 0.0
var _anim_t: = -1.0
var _result: = ""
var _font: Font = null


func set_order(n: int) -> void :
	order = n
	_order_str = str(n) if n > 0 else ""



func reset() -> void :
	time = 0.0
	judged = false
	speed = 1.0
	set_order(0)
	priority = 0
	next_aim = Vector2.ZERO
	_ring_radius = 0.0
	_appear = 0.0
	_dim = 0.0
	_anim_t = -1.0
	_result = ""
	scale = Vector2.ONE
	modulate = Color.WHITE
	visible = true
	set_process(false)


func update_visual(song_time: float, tuning: Tuning) -> void :
	if judged:
		return
	_hit_radius = tuning.click_hit_radius
	var remaining: = time - song_time
	var p: = clampf(remaining / (tuning.click_approach_time / speed), 0.0, 1.0)

	var pe: = pow(p, maxf(tuning.approach_ease, 0.05))
	_ring_radius = _hit_radius + pe * (tuning.click_ring_start_radius - _hit_radius)


	_appear = clampf((1.0 - p) / 0.35, 0.0, 1.0) * Mods.mirage_alpha(p, true)


	var want: float = 0.0 if priority <= 0 or StageRender.legacy()\
	else (0.6 if priority == 1 else 1.0)
	_dim = move_toward(_dim, want * tuning.future_dim, 5.0 * get_process_delta_time())
	queue_redraw()




func resolve(result: String) -> void :
	judged = true
	_result = result
	_anim_t = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void :
	if not judged:
		return
	_anim_t += delta
	var tun = StageRender.tuning
	var hit: = _result == "PERFECT" or _result == "GOOD"
	var strong: = 1.0 if _result == "PERFECT" else 0.6
	if StageRender.legacy():



		if _anim_t >= (0.27 if hit else 0.25):
			_finish()
			return
		if hit:
			var s: = 0.88
			if _anim_t > 0.03:
				var e: = clampf((_anim_t - 0.03) / 0.2, 0.0, 1.0)
				e = 1.0 - pow(1.0 - e, 3.0)
				s = lerpf(0.88, 1.0 + 0.3 * strong, e)
			scale = Vector2.ONE * s
		queue_redraw()
		return
	var dur: float = (tun.hit_anim_time if tun != null else 0.14)
	if not hit:
		dur *= 1.4
	if _anim_t >= dur:
		_finish()
		return
	if hit:

		var u: = _anim_t / dur
		var s: = 0.9
		if u > 0.25:
			var e: = (u - 0.25) / 0.75
			e = 1.0 - (1.0 - e) * (1.0 - e)
			s = lerpf(0.9, 1.0 + 0.25 * strong, e)
		scale = Vector2.ONE * s
	queue_redraw()


func _finish() -> void :
	if main != null and main.has_method("_release_note"):
		main._release_note(self)
	else:
		queue_free()


func _draw() -> void :
	var tun = StageRender.tuning
	var q: = SettingsManager.gfx_k(SettingsManager.gfx_click)
	if _font == null and main != null:
		_font = main.font_bold
	var font: = _font
	if not judged:
		var a: = _appear

		if next_aim != Vector2.ZERO:
			StageRender.aim_path(self, Vector2.ZERO, next_aim, 1.0, _hit_radius, a)
		if StageRender.legacy() and q >= 0.5:
			StageRender.aim_glow(self, Vector2.ZERO, 1.0, _hit_radius, glow_tex, 0.26 * a * q)
		StageRender.aim_circle(self, Vector2.ZERO, 1.0, _hit_radius, _ring_radius, a, 
			q, false, _order_str, font, _dim)
		return

	if StageRender.legacy():
		var strong_l: = 1.0 if _result == "PERFECT" else 0.6
		var hit_l: = _result == "PERFECT" or _result == "GOOD"
		var a_l: float
		if hit_l:
			a_l = 1.0 - clampf((_anim_t - 0.05) / 0.22, 0.0, 1.0)
		else:
			a_l = 1.0 - clampf(_anim_t / 0.25, 0.0, 1.0)
		if q >= 0.5:
			StageRender.aim_glow(self, Vector2.ZERO, 1.0, _hit_radius, glow_tex, 0.26 * a_l * q)
		StageRender.aim_circle(self, Vector2.ZERO, 1.0, _hit_radius, 0.0, a_l, q)
		if hit_l and _anim_t < 0.09:
			StageRender.aim_flash(self, Vector2.ZERO, 1.0, _hit_radius, 
				strong_l * (1.0 - _anim_t / 0.09), q)
		return
	var dur: float = (tun.hit_anim_time if tun != null else 0.14)
	if _result == "PERFECT" or _result == "GOOD":
		var u: = clampf(_anim_t / dur, 0.0, 1.0)
		var strong: = 1.0 if _result == "PERFECT" else 0.6

		var a: = 1.0 - smoothstep(0.3, 1.0, u)
		StageRender.aim_body(self, Vector2.ZERO, 1.0, _hit_radius, a, 0.0, false, false, q)

		if u < 0.25 and q > 0.0:
			var fl: float = (tun.hit_flash if tun != null else 0.8) * (1.0 - u / 0.25) * strong
			StageRender.aim_flash(self, Vector2.ZERO, 1.0, _hit_radius, fl, q)
		StageRender.aim_hit_ring(self, Vector2.ZERO, 1.0, _hit_radius, u, strong)
	else:

		var u: = clampf(_anim_t / (dur * 1.4), 0.0, 1.0)
		StageRender.aim_body(self, Vector2.ZERO, 1.0, _hit_radius, (1.0 - u) * 0.85, 0.7, false, false, q)
