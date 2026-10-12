class_name MenuIntro
extends Control














signal finished

var main
var orb: Node2D
var sides: Array = []


var background
var late_bits: Array = []

var _running: = false
var _tw: Tween
var _veil: = 1.0:
	set(v):
		_veil = v
		queue_redraw()


func _ready() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func is_running() -> bool:
	return _running



func _cast() -> Array:
	var out: Array = []
	if orb != null:
		out.append(orb)
	for s in sides:
		if is_instance_valid(s):
			out.append(s)
	return out


func play() -> void :
	if _running:
		return
	_running = true
	visible = true
	_veil = 1.0

	for m in _cast():
		m.modulate = Color.WHITE
		m.eye_reveal = 0.0
		m.gaze_centered = true
		m.body_alpha = 0.0
		m.scale = Vector2(0.92, 0.92)
		m.playful = false
		m.blink_enabled = false
	if background != null:
		background.home_reveal = 0.0
	for n in late_bits:
		if is_instance_valid(n):
			(n as CanvasItem).modulate.a = 0.0
	if main != null and main.mascot_button != null:
		main.mascot_button.disabled = true

	var left_m: Node2D = sides[0] if sides.size() > 0 else null
	var right_m: Node2D = sides[1] if sides.size() > 1 else null
	_tw = create_tween()

	_tw.tween_interval(0.15)
	if orb != null:
		_tw.tween_property(orb, "eye_reveal", 1.0, 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tw.tween_interval(0.35)

	if left_m != null:
		_tw.tween_property(left_m, "eye_reveal", 1.0, 0.25)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if right_m != null:
		_tw.parallel().tween_property(right_m, "eye_reveal", 1.0, 0.25)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD).set_delay(0.12)
	_tw.tween_interval(0.4)

	_tw.tween_callback( func() -> void :
		_look_at(orb, left_m)
		_look_at(left_m, orb)
		_look_at(right_m, orb))
	_tw.tween_interval(0.6)

	_tw.tween_callback( func() -> void :
		_look_at(orb, right_m)
		_look_at(left_m, right_m))
	_tw.tween_interval(0.6)


	_tw.tween_callback( func() -> void :
		for m in _cast():
			m.ease_speed = 2.6
			m.gaze_centered = true)
	_tw.tween_interval(0.8)
	_tw.tween_callback( func() -> void :
		for m in _cast():
			m.ease_speed = 10.0)

	if orb != null:
		_tw.tween_property(orb, "body_alpha", 1.0, 0.26).set_ease(Tween.EASE_OUT)
		_tw.parallel().tween_property(orb, "scale", Vector2.ONE, 0.34)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	var side_delay: = 0.08
	for s in [left_m, right_m]:
		if s == null:
			continue
		_tw.parallel().tween_property(s, "body_alpha", 1.0, 0.26)\
		.set_ease(Tween.EASE_OUT).set_delay(side_delay)
		_tw.parallel().tween_property(s, "scale", Vector2.ONE, 0.34)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(side_delay)
		side_delay += 0.08

	_tw.tween_callback( func() -> void : _kick(0.55))


	_tw.tween_interval(0.1)
	_tw.tween_property(self, "_veil", 0.0, 0.4).set_ease(Tween.EASE_OUT)
	if background != null:
		_tw.parallel().tween_property(background, "home_reveal", 1.0, 0.8)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	_tw.tween_interval(0.26)
	_tw.tween_callback( func() -> void :
		_kick(1.0)
		if main != null:
			main.sfx.play_ui("impact"))

	_tw.tween_interval(0.18)
	var first: = true
	for n in late_bits:
		if not is_instance_valid(n):
			continue
		var t: = _tw.tween_property(n, "modulate:a", 1.0, 0.34) if first\
		else _tw.parallel().tween_property(n, "modulate:a", 1.0, 0.34)
		t.set_ease(Tween.EASE_OUT)
		first = false
	_tw.tween_callback(_done)



func skip() -> void :
	if not _running:
		return
	if _tw:
		_tw.kill()
	_done()


func _done() -> void :
	_running = false
	_veil = 0.0
	visible = false
	for m in _cast():
		m.modulate = Color.WHITE
		m.eye_reveal = 1.0
		m.body_alpha = 1.0
		m.scale = Vector2.ONE
		m.ease_speed = 10.0


		m.gaze_centered = false
		m.set_look_target(null)
		m.blink_enabled = true
	if orb != null:
		orb.playful = true
	for s in sides:
		if is_instance_valid(s):
			s.playful = true
	if main != null and main.mascot_button != null:
		main.mascot_button.disabled = false
	if background != null:
		background.home_reveal = 1.0
	for n in late_bits:
		if is_instance_valid(n):
			(n as CanvasItem).modulate.a = 1.0
	finished.emit()



func _look_at(a: Node2D, b: Node2D) -> void :
	if a == null or b == null:
		return
	a.gaze_centered = false
	a.set_look_target(b)


func _kick(strength: float) -> void :
	for m in _cast():
		if m.has_method("beat_kick"):
			m.beat_kick(strength)
	if main != null and main.background != null:
		main.background.on_beat(strength)


func _draw() -> void :
	if _veil <= 0.002:
		return



	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), 
		Color(0.006, 0.008, 0.018, _veil))
