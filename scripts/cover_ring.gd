class_name CoverRing
extends Control
const Spectrum = preload("res://scripts/spectrum.gd")


















const SEGS: = 72
const BARS: = 52
const BAR_W: = 3.4
const BAR_LEN: = 0.55
const CYAN: = Color(0.4, 0.82, 1.0)
const VIOLET: = Color(0.72, 0.45, 1.0)
const PINK: = Color(1.0, 0.5, 0.85)
const GOLD: = Color(1.0, 0.82, 0.3)

var accent: = Color(0.72, 0.45, 1.0)
var glow_tex: Texture2D
var beat_bus: BeatBus
var radius: = 168.0

var _disc: Control
var _cover: TextureRect
var _prev: TextureRect
var _letter: Label
var _beat: = 0.0
var _strong: = 0.0
var _spin: = 0.0
var _swap: = 0.0


var _ring_pts: = PackedVector2Array()
var _ring_cols: = PackedColorArray()
var _bar_pts: = PackedVector2Array()
var _bar_cols: = PackedColorArray()
var _levels: = PackedFloat32Array()
var _spec_frame: = -100
var _spectrum: AudioEffectSpectrumAnalyzerInstance = null


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring_pts.resize(SEGS + 1)
	_ring_cols.resize(SEGS + 1)
	_bar_pts.resize(BARS * 2)
	_bar_cols.resize(BARS)
	_levels.resize(BARS)
	_disc = Control.new()
	_disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disc.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	_disc.draw.connect(_draw_disc)
	add_child(_disc)
	_prev = _make_rect()
	_disc.add_child(_prev)
	_cover = _make_rect()
	_disc.add_child(_cover)
	_letter = Label.new()
	_letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_letter.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	_letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_disc.add_child(_letter)
	resized.connect(_layout)
	_find_spectrum()
	_layout()


func _make_rect() -> TextureRect:
	var t: = TextureRect.new()
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t





func _find_spectrum() -> void :
	var bus: = AudioServer.get_bus_index("Master")
	for i in AudioServer.get_bus_effect_count(bus):
		var inst: = AudioServer.get_bus_effect_instance(bus, i)
		if inst is AudioEffectSpectrumAnalyzerInstance:
			_spectrum = inst
			return


func set_font(f: Font) -> void :
	if f != null:
		_letter.add_theme_font_override("font", f)


func _layout() -> void :


	radius = minf(size.x, size.y) * 0.5 * 0.64
	var d: = radius * 2.0
	_disc.position = (size - Vector2(d, d)) * 0.5
	_disc.size = Vector2(d, d)
	_disc.pivot_offset = Vector2(radius, radius)
	for t in [_prev, _cover, _letter]:
		t.position = Vector2.ZERO
		t.size = Vector2(d, d)
		t.pivot_offset = Vector2(radius, radius)
	_letter.add_theme_font_size_override("font_size", int(radius * 0.72))




func set_cover(tex: Texture2D, letter: String) -> void :
	_swap = 1.0
	_prev.texture = _cover.texture
	_prev.modulate.a = 1.0 if _cover.texture != null else 0.0
	_prev.scale = Vector2.ONE
	var ptw: = _prev.create_tween()
	ptw.tween_property(_prev, "modulate:a", 0.0, 0.2)
	ptw.parallel().tween_property(_prev, "scale", Vector2(0.96, 0.96), 0.24)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_cover.texture = tex
	_cover.visible = tex != null
	_letter.text = letter
	_letter.visible = tex == null
	_cover.modulate.a = 0.0
	_cover.scale = Vector2(1.04, 1.04)
	var ctw: = _cover.create_tween()
	ctw.tween_property(_cover, "modulate:a", 1.0, 0.18)
	ctw.parallel().tween_property(_cover, "scale", Vector2.ONE, 0.26)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)



func cover_rect() -> TextureRect:
	return _cover


func on_beat(strength: float) -> void :
	_beat = maxf(_beat, strength)


func on_strong_beat(strength: float) -> void :
	_strong = maxf(_strong, strength)


func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	_beat = maxf(0.0, _beat - delta * 2.4)
	_strong = maxf(0.0, _strong - delta * 1.6)
	_swap = maxf(0.0, _swap - delta * 3.0)
	_spin += delta * 0.07
	var s: float = SettingsManager.menu_fx_intensity
	var k: = 1.0 + (0.015 * _beat + 0.01 * _strong) * s
	_disc.scale = Vector2(k, k)
	_refresh_levels()
	queue_redraw()



func _refresh_levels() -> void :
	if _spectrum == null:
		_find_spectrum()
		if _spectrum == null:
			return
	var f: = Engine.get_process_frames()


	var t: = Spectrum.tick()
	var fresh: = t != _spec_frame
	if fresh:
		_spec_frame = t
	for i in BARS:
		if not fresh:
			_levels[i] *= 0.94
			continue
		var f0: = 60.0 * pow(9000.0 / 60.0, float(i) / BARS)
		var f1: = 60.0 * pow(9000.0 / 60.0, float(i + 1) / BARS)
		var lvl: = Spectrum.level(f0, f1)
		_levels[i] = maxf(lvl, lerpf(_levels[i], lvl, 0.3))


func _draw_disc() -> void :

	_disc.draw_circle(Vector2(radius, radius), radius, Color(0.03, 0.025, 0.06, 1.0))


func _draw() -> void :
	var c: = size * 0.5
	var s: float = SettingsManager.menu_fx_intensity

	if glow_tex != null:
		var g: = radius * (2.6 + 0.25 * _beat * s)
		draw_texture_rect(glow_tex, Rect2(c - Vector2(g, g) * 0.5, Vector2(g, g)), 
			false, Color(accent.r, accent.g, accent.b, 0.22 + 0.1 * _strong * s))


	_ring(c, radius * 1.045, 1.6, 0.42 + 0.2 * _beat * s, _spin)
	_ring(c, radius * (1.0 + BAR_LEN) + 8.0, 1.0, 0.16 + 0.1 * _strong * s, - _spin * 0.6)


	var boost: = 1.0 + 0.18 * _beat * s
	for i in BARS:
		var a: = TAU * float(i) / BARS - PI * 0.5 + _spin * 0.35
		var lvl: float = _levels[i]
		var len: = radius * BAR_LEN * (0.08 + 0.92 * lvl * lvl) * boost
		var dir: = Vector2(cos(a), sin(a))
		var r0: = radius * 1.09
		_bar_pts[i * 2] = c + dir * r0
		_bar_pts[i * 2 + 1] = c + dir * (r0 + len)
		var u: = float(i) / float(BARS - 1)
		var col: = CYAN.lerp(VIOLET, u * 2.0) if u < 0.5 else VIOLET.lerp(PINK, u * 2.0 - 1.0)
		col = col.lerp(accent, 0.35)
		col.a = 0.22 + 0.55 * lvl
		_bar_cols[i] = col
	draw_multiline_colors(_bar_pts, _bar_cols, BAR_W)


func _ring(c: Vector2, r: float, w: float, alpha: float, phase: float) -> void :
	for i in SEGS + 1:
		var a: = TAU * float(i) / SEGS
		_ring_pts[i] = c + Vector2(cos(a), sin(a)) * r
		var u: = fposmod(float(i) / SEGS + phase, 1.0)
		var col: = CYAN.lerp(VIOLET, u * 2.0) if u < 0.5 else VIOLET.lerp(PINK, u * 2.0 - 1.0)
		_ring_cols[i] = Color(col, alpha)
	draw_polyline_colors(_ring_pts, _ring_cols, w, true)
