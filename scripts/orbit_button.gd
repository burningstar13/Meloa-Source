class_name OrbitButton
extends Button

















const HOVER_SPEED: = 22.0

var icon_kind: = "diamond"
var accent: = Color(0.72, 0.45, 1.0)


var weight: = 1.0
var radius: = 34.0
var caption: = ""
var glow_tex: Texture2D


var appear: = 0.0:
	set(v):
		appear = v
		_dirty = true











var base_pos: = Vector2.ZERO
var float_phase: = 0.0


var frozen: = false

var _font: Font
var _hover: = 0.0
var _press: = 1.0
var _flash: = 0.0
var _beat: = 0.0
var _dirty: = true


func _ready() -> void :
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
	size = Vector2(radius * 2.0, radius * 2.0)
	pivot_offset = size * 0.5
	mouse_default_cursor_shape = Control.CURSOR_ARROW

	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(st, empty)



	_font = ThemeDB.fallback_font
	button_down.connect(_on_press)

	scale = Vector2.ONE * weight * 0.001
	visible = false


func set_font(f: Font) -> void :
	if f != null:
		_font = f



func _has_point(point: Vector2) -> bool:
	return point.distance_to(size * 0.5) <= radius * 1.06



func on_beat(strength: float) -> void :
	_beat = maxf(_beat, strength)


func _on_press() -> void :

	_flash = 1.0
	var tw: = create_tween()
	tw.tween_property(self, "_press", 0.94, 0.05).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "_press", 1.08, 0.09)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "_press", 1.0, 0.12).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void :
	if get_parent() is CanvasItem and not (get_parent() as CanvasItem).is_visible_in_tree():
		return
	var want: = 1.0 if (is_hovered() and not disabled) else 0.0
	var k: = 1.0 - exp( - HOVER_SPEED * delta)
	var prev: = _hover
	_hover = lerpf(_hover, want, k)
	_flash = maxf(0.0, _flash - delta * 4.0)
	_beat = maxf(0.0, _beat - delta * 2.6)


	var ap: = ease(clampf(appear, 0.0, 1.0), 0.35)
	scale = Vector2.ONE * weight * ap * _press\
	* (1.0 + 0.1 * _hover + 0.018 * _beat)
	visible = appear > 0.005


	if _dirty or appear > 0.005 or _flash > 0.001 or _beat > 0.001:
		_dirty = false
		queue_redraw()




func float_offset() -> Vector2:
	if frozen:
		return Vector2.ZERO
	var t: = Time.get_ticks_msec() / 1000.0
	var amp: = ease(clampf(appear, 0.0, 1.0), 0.35) * (1.0 - 0.7 * _hover)
	return Vector2(sin(t * 0.61 + float_phase) * 4.0, 
		sin(t * 0.83 + float_phase * 1.7) * 9.0) * amp


func _draw() -> void :
	var ap: = ease(clampf(appear, 0.0, 1.0), 0.35)
	if ap <= 0.005:
		return


	draw_set_transform(float_offset())
	var c: = size * 0.5
	var lit: = _hover * 0.9 + _flash * 0.6 + _beat * 0.12









	if glow_tex != null:
		var gr: = radius * (2.3 + 0.45 * _hover)
		draw_texture_rect(glow_tex, Rect2(c - Vector2(gr, gr), Vector2(gr, gr) * 2.0), 
			false, Color(accent.r, accent.g, accent.b, (0.045 + 0.16 * lit) * ap))
		var er: = radius * 1.45
		draw_texture_rect(glow_tex, Rect2(c - Vector2(er, er), Vector2(er, er) * 2.0), 
			false, Color(accent.r, accent.g, accent.b, (0.07 + 0.2 * lit) * ap))


	draw_circle(c, radius, Color(0.026, 0.02, 0.048, (0.5 + 0.22 * _hover) * ap))


	if glow_tex != null and weight > 1.05:
		var ir: = radius * 0.92
		draw_texture_rect(glow_tex, Rect2(c - Vector2(ir, ir), Vector2(ir, ir) * 2.0), 
			false, Color(accent.r, accent.g, accent.b, (0.14 + 0.12 * lit) * ap))



	var boost: = 1.15 + 0.45 * lit
	draw_arc(c, radius, 0.0, TAU, 72, 
		Color(accent.r * boost, accent.g * boost, accent.b * boost, 
			(0.62 + 0.38 * lit) * ap), 
		1.0 + 0.4 * _hover, true)


	if _flash > 0.01:
		var f: = 1.0 - _flash
		draw_arc(c, radius * (1.0 + 0.85 * f), 0.0, TAU, 48, 
			Color(1, 1, 1, 0.45 * _flash * _flash * ap), 1.2, true)


	var ic: = 1.0 + 0.4 * lit
	UiIcon.draw_kind(self, icon_kind, c, radius * 1.45, 
		Color(ic, ic, ic, (0.86 + 0.14 * _hover) * ap), 1.9)


	if _font != null and caption != "":
		var tp: = Vector2(c.x - 100.0, radius * 2.0 + 26.0)
		var ta: = (0.34 + 0.66 * _hover) * ap
		draw_string_outline(_font, tp, caption, HORIZONTAL_ALIGNMENT_CENTER, 
			200.0, 12, 4, Color(0, 0, 0, 0.5 * ta))
		draw_string(_font, tp, caption, HORIZONTAL_ALIGNMENT_CENTER, 
			200.0, 12, Color(1, 1, 1, ta))
