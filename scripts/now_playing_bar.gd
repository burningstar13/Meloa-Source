class_name NowPlayingBar
extends Control
const Spectrum = preload("res://scripts/spectrum.gd")








signal pause_toggled(paused: bool)

const W: = 300.0
const BARS: = 34

var main
var beat_bus: BeatBus

var _cap: Label
var _title: Label
var _artist: Label
var _time: Label
var _pause_b: Button
var _viz: Control
var _levels: = PackedFloat32Array()
var _beat: = 0.0
var _dot: = 0.0
var _progress: = 0.0
var _spec_frame: = -100


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_levels.resize(BARS)
	custom_minimum_size = Vector2(W + 60.0, 130.0)
	size = custom_minimum_size

	_cap = _mk_label("NOW PLAYING", 11, Color(0.8, 0.68, 1.0, 0.75), Vector2(16, 0))
	_title = _mk_label("", 26, Color(1, 1, 1, 0.96), Vector2(0, 18))
	_artist = _mk_label("", 12, Color(1, 1, 1, 0.42), Vector2(0, 50))
	_time = _mk_label("", 11, Color(1, 1, 1, 0.38), Vector2(0, 104))



	_viz = Control.new()
	_viz.position = Vector2(0, 70)
	_viz.size = Vector2(W - 46.0, 24.0)
	_viz.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_viz.draw.connect(_draw_viz)
	add_child(_viz)



	_pause_b = Button.new()
	_pause_b.focus_mode = Control.FOCUS_NONE
	_pause_b.custom_minimum_size = Vector2(34, 34)
	_pause_b.size = Vector2(34, 34)
	_pause_b.position = Vector2(W - 34.0, 66.0)
	_pause_b.pivot_offset = Vector2(17, 17)
	_pause_b.tooltip_text = "Pause / lecture"
	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "hover", "pressed", "focus"]:
		_pause_b.add_theme_stylebox_override(st, empty)
	_pause_b.draw.connect(_draw_pause)
	_pause_b.pressed.connect(_on_pause)
	add_child(_pause_b)


func _mk_label(txt: String, sz: int, col: Color, pos: Vector2) -> Label:
	var l: = Label.new()
	l.text = txt
	l.position = pos
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.add_theme_constant_override("outline_size", 5)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.45))
	add_child(l)
	return l




func set_fonts(title_f: Font, small_f: Font) -> void :
	if title_f != null:
		_title.add_theme_font_override("font", title_f)
	if small_f != null:
		_cap.add_theme_font_override("font", small_f)
		_time.add_theme_font_override("font", small_f)


func set_track(track_name: String, artist: String) -> void :
	_title.text = track_name
	_artist.text = artist


func on_beat(strength: float) -> void :
	_beat = maxf(_beat, strength)
	_dot = 1.0


func is_paused() -> bool:
	return main != null and main.conductor.stream_paused


func _on_pause() -> void :
	if main == null or main.screen == main.Screen.PLAYING:
		return
	var now: bool = not main.conductor.stream_paused
	main.conductor.stream_paused = now

	var tw: = _pause_b.create_tween()
	if now:
		tw.tween_property(_pause_b, "scale", Vector2(0.88, 0.88), 0.08)\
		.set_ease(Tween.EASE_OUT)
		tw.tween_property(_pause_b, "scale", Vector2.ONE, 0.14)\
		.set_ease(Tween.EASE_OUT)
	else:
		tw.tween_property(_pause_b, "scale", Vector2(1.16, 1.16), 0.1)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tw.tween_property(_pause_b, "scale", Vector2.ONE, 0.16)\
		.set_ease(Tween.EASE_OUT)
	_pause_b.queue_redraw()
	pause_toggled.emit(now)




func refresh() -> void :
	if main == null or main.conductor.stream == null:
		return
	var len: float = main.conductor.stream.get_length()
	if len > 0.0:
		var pos: float = main.conductor.get_playback_position()
		_progress = clampf(pos / len, 0.0, 1.0)
		_time.text = "%02d:%02d / %02d:%02d"\
		%[int(pos) / 60, int(pos) % 60, int(len) / 60, int(len) % 60]


func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	_beat = maxf(0.0, _beat - delta * 2.4)
	_dot = maxf(0.0, _dot - delta * 3.2)
	_refresh_levels()
	_viz.queue_redraw()
	_pause_b.queue_redraw()
	queue_redraw()




func _refresh_levels() -> void :
	if main == null or main.spectrum == null:
		return
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


func _draw() -> void :

	var s: = SettingsManager.menu_fx_intensity
	var dc: = Vector2(5.0, 7.0)
	var pulse: = 1.0 + 0.55 * _dot * s
	draw_circle(dc, 3.2 * pulse, Color(0.8, 0.55, 1.15, 0.55 + 0.4 * _dot * s))

	var by: = 98.0
	var bw: = W - 46.0
	draw_line(Vector2(0, by), Vector2(bw, by), Color(1, 1, 1, 0.1), 1.0)
	if _progress > 0.001:
		draw_line(Vector2(0, by), Vector2(bw * _progress, by), 
			Color(0.86, 0.7, 1.15, 0.72), 1.6)
		draw_circle(Vector2(bw * _progress, by), 2.2, 
			Color(1.05, 0.9, 1.3, 0.85))





func _draw_viz() -> void :
	var h: = _viz.size.y
	var w: = _viz.size.x
	var bw: = w / float(BARS)
	var s: = SettingsManager.menu_fx_intensity
	var boost: = 1.0 + 0.18 * _beat * s
	for i in BARS:
		var lvl: float = _levels[i]
		var bh: = maxf(1.5, lvl * lvl * h * 0.92 * boost)
		var u: = float(i) / float(BARS - 1)
		var col: = Color(0.4, 0.82, 1.0).lerp(Color(0.72, 0.45, 1.0), u * 2.0)\
		if u < 0.5 else Color(0.72, 0.45, 1.0)\
		.lerp(Color(1.0, 0.5, 0.85), u * 2.0 - 1.0)

		_viz.draw_rect(Rect2(i * bw + 0.8, h * 0.5 - bh * 0.5, bw - 1.6, bh), 
			Color(col.r, col.g, col.b, 0.28 + 0.45 * lvl))


func _draw_pause() -> void :
	var c: = _pause_b.size * 0.5
	var hov: = _pause_b.is_hovered()
	var a: = 0.95 if hov else 0.55
	_pause_b.draw_arc(c, 15.0, 0.0, TAU, 40, 
		Color(1, 1, 1, 0.22 if hov else 0.1), 1.2, true)
	UiIcon.draw_kind(_pause_b, "media_play" if is_paused() else "media_pause", c, 26.0, 
		Color(1, 1, 1, a), 1.8)
