class_name GradeCore
extends Control
















const SEGMENTS: = 72
const RING_SEGS: = 96

var grade: = "A"
var grade_color: = ResultsTheme.CYAN
var glow_tex: Texture2D = null

var _letter: GlowLabel
var _letter_slot: Control
var _flash: = 0.0
var _lit: = 1.0
var _shake: = Vector2.ZERO
var _spin: = 0.0
var _ring_pts: = PackedVector2Array()
var _ring_cols: = PackedColorArray()
var _seg_pts: = PackedVector2Array()
var _seg_cols: = PackedColorArray()
var _tw: Tween


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(300, 300)
	_ring_pts.resize(RING_SEGS + 1)
	_ring_cols.resize(RING_SEGS + 1)
	_seg_pts.resize(SEGMENTS * 2)
	_seg_cols.resize(SEGMENTS)
	_letter_slot = Control.new()
	_letter_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_letter_slot)

	_letter = GlowLabel.new()
	_letter.font = ResultsTheme.font(int(ResultsTheme.role("RGrade")[0]))
	_letter.align = HORIZONTAL_ALIGNMENT_CENTER
	_letter.valign = VERTICAL_ALIGNMENT_CENTER
	_letter.glow_strength = 0.0
	_letter_slot.add_child(_letter)
	resized.connect(_layout)


func _layout() -> void :
	var r: = radius()
	_letter_slot.position = size * 0.5 - Vector2(r, r)
	_letter_slot.size = Vector2(r * 2.0, r * 2.0)
	_letter_slot.pivot_offset = Vector2(r, r)
	_letter.position = Vector2.ZERO
	_letter.size = _letter_slot.size


	_letter.font_size = int(r * 1.0)
	queue_redraw()


func radius() -> float:
	return minf(size.x, size.y) * 0.5 - 4.0




static func ring_color(a: float) -> Color:


	var u: = fposmod((a + PI * 0.75) / TAU, 1.0)
	var k: = 0.5 - 0.5 * cos(u * TAU)
	if k < 0.5:
		return ResultsTheme.VIOLET_LIGHT.lerp(ResultsTheme.BLUE, k * 2.0)
	return ResultsTheme.BLUE.lerp(ResultsTheme.CYAN, (k - 0.5) * 2.0)



func set_grade(g: String, instant: = true) -> void :
	grade = g
	grade_color = ResultsTheme.grade_color(g)
	_letter.text = g
	_letter.color = grade_color
	if instant:
		apply_final()


func hide_letter() -> void :
	_letter_slot.modulate.a = 0.0
	_lit = 0.55
	queue_redraw()


func apply_final() -> void :
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_letter_slot.modulate.a = 1.0
	_letter_slot.position = size * 0.5 - Vector2(radius(), radius())
	_letter_slot.scale = Vector2.ONE
	_flash = 0.0
	_lit = 1.0
	_shake = Vector2.ZERO
	queue_redraw()



func play_drop(profile: Dictionary, on_impact: Callable) -> Tween:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	var r: = radius()
	var base: = size * 0.5 - Vector2(r, r)
	var fall: = float(profile.get("fall", 120.0))
	var over: = float(profile.get("overshoot", 1.2))
	var squash: = float(profile.get("squash", 0.06))
	var heavy: = bool(profile.get("heavy", false))
	_letter_slot.position = base + Vector2(0, - fall)
	_letter_slot.scale = Vector2.ONE * over
	_letter_slot.modulate.a = 0.0
	_lit = 0.55
	_tw = create_tween()
	_tw.set_parallel(true)
	_tw.tween_property(_letter_slot, "modulate:a", 1.0, 0.1)
	_tw.tween_property(_letter_slot, "position", base, 0.26)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC if heavy else Tween.TRANS_QUAD)
	_tw.tween_property(_letter_slot, "scale", Vector2(1.0 + squash, 1.0 - squash), 0.26)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_tw.set_parallel(false)
	_tw.tween_callback( func() -> void :
		_impact(profile)
		if on_impact.is_valid():
			on_impact.call())
	_tw.tween_property(_letter_slot, "scale", Vector2.ONE, 0.32)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK if not heavy else Tween.TRANS_CUBIC)
	return _tw


func _impact(profile: Dictionary) -> void :
	var flash: = float(profile.get("flash", 0.4)) * 0.6
	var lit_t: = float(profile.get("lit", 0.35))
	var shake_amp: = float(profile.get("shake", 1.5)) * SettingsManager.shake_intensity
	var t: = create_tween()
	t.set_parallel(true)
	t.tween_method( func(v: float) -> void :
		_flash = v
		queue_redraw(), flash, 0.0, 0.3).set_ease(Tween.EASE_OUT)
	t.tween_method( func(v: float) -> void :
		_lit = v
		queue_redraw(), 0.55, 1.0, lit_t).set_ease(Tween.EASE_OUT)
	if shake_amp > 0.01:
		t.tween_method( func(u: float) -> void :
			var k: = shake_amp * (1.0 - u) * (1.0 - u)
			_shake = Vector2(sin(u * 61.0) * k, cos(u * 47.0 + 1.3) * k * 0.7)
			queue_redraw(), 0.0, 1.0, 0.16)
	t.tween_method( func(v: float) -> void :
		_spin = v
		queue_redraw(), 0.0, TAU / float(SEGMENTS), 0.5).set_ease(Tween.EASE_OUT)


func _draw() -> void :
	var c: = size * 0.5 + _shake
	var r: = radius()
	var lit: = _lit


	_ring(c, r * 0.845, 9.0, 0.1 * lit)
	_ring(c, r * 0.95, 8.0, 0.05 * lit)

	draw_circle(c, r * 0.78, ResultsTheme.BG_2)

	if glow_tex != null:
		var g: = r * 1.25
		draw_texture_rect(glow_tex, Rect2(c - Vector2(g, g) * 0.5, Vector2(g, g)), false, 
			Color(grade_color.r, grade_color.g, grade_color.b, 0.09 * lit))

	draw_arc(c, r * 0.78, 0.0, TAU, RING_SEGS, Color(ResultsTheme.LINE, 0.9), 1.4, true)

	_ring(c, r * 0.845, 2.0, 0.95 * lit)

	for i in SEGMENTS:
		var a: = TAU * float(i) / SEGMENTS - PI * 0.5 + _spin
		var dir: = Vector2(cos(a), sin(a))
		_seg_pts[i * 2] = c + dir * (r * 0.905)
		_seg_pts[i * 2 + 1] = c + dir * r
		var col: = ring_color(a)
		col.a = 0.55 + 0.35 * lit
		_seg_cols[i] = col
	draw_multiline_colors(_seg_pts, _seg_cols, 2.4)

	if _flash > 0.001:
		draw_circle(c, r * 0.76, Color(grade_color.lerp(Color.WHITE, 0.5), 0.5 * _flash))


func _ring(c: Vector2, r: float, w: float, alpha: float) -> void :
	for i in RING_SEGS + 1:
		var a: = TAU * float(i) / RING_SEGS - PI * 0.5 + _spin * 0.5
		_ring_pts[i] = c + Vector2(cos(a), sin(a)) * r
		_ring_cols[i] = Color(ring_color(a), alpha)
	draw_polyline_colors(_ring_pts, _ring_cols, w, true)
