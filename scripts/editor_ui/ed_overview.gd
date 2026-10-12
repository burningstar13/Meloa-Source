extends Control







const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdFx = preload("res://scripts/editor_ui/ed_fx.gd")
const WavePeaks = preload("res://scripts/wave_peaks.gd")

const PAD_L: = 92.0
const PAD: = 6.0



const H_OPEN: = 88.0
const H_FOLD: = 32.0

var ed
var _drag: = false
var _drag_grab: = 0.0
var _fold_btn: Button


func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	tooltip_text = "Overview\nClick to jump, drag the frame to scrub."


	_fold_btn = Button.new()
	_fold_btn.position = Vector2(4, 2)
	_fold_btn.size = Vector2(16, 16)
	_fold_btn.tooltip_text = "Fold / unfold the overview"
	EdTheme.style_button(_fold_btn, Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
	_fold_btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_fold_btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_fold_btn.pressed.connect( func(): ed.ui_set_open("overview", 
		not ed.ui_is_open("overview")))
	var caret: = EdTheme.make_glyph("caret", 5.0, Color(1, 1, 1, 0.32))
	caret.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fold_btn.add_child(caret)
	_fold_btn.set_meta("caret", caret)
	add_child(_fold_btn)
	_apply_fold()
	_head = _Head.new()
	_head.ov = self
	add_child(_head)
	ed.chart_changed.connect(queue_redraw)


	ed.time_changed.connect(_head.queue_redraw)
	ed.selection_changed.connect(queue_redraw)
	ed.view_changed.connect(_on_view)
	resized.connect(_head.queue_redraw)


func _on_view() -> void :
	_apply_fold()
	queue_redraw()
	if _head != null:
		_head.queue_redraw()


func _apply_fold() -> void :
	var open: bool = ed.ui_is_open("overview")
	custom_minimum_size.y = H_OPEN if open else H_FOLD
	var caret = _fold_btn.get_meta("caret")
	caret.angle = PI * 0.5 if open else 0.0
	caret.queue_redraw()


func folded() -> bool:
	return not ed.ui_is_open("overview")


func track() -> Rect2:
	if folded():

		return Rect2(PAD_L, 8.0, maxf(size.x - PAD_L - PAD, 20.0), 
			maxf(size.y - 14.0, 10.0))
	return Rect2(PAD_L, 22.0, maxf(size.x - PAD_L - PAD, 20.0), 
		maxf(size.y - 32.0, 20.0))


func x_to_time(x: float) -> float:
	var r: = track()
	return clampf((x - r.position.x) / maxf(r.size.x, 1.0), 0.0, 1.0) * ed.song_len()


func time_to_x(tt: float) -> float:
	var r: = track()
	return r.position.x + clampf(tt / maxf(ed.song_len(), 0.001), 0.0, 1.0) * r.size.x



func window_span() -> float:
	if ed.timeline == null:
		return 4.0
	return ed.timeline.area().size.x / maxf(ed.zoom, 1.0)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed\
	and event.button_index == MOUSE_BUTTON_LEFT:
		var tt: = x_to_time(event.position.x)
		var span: = window_span()

		if absf(tt - ed.view_t) < span * 0.5:
			_drag = true
			_drag_grab = ed.view_t - tt
		else:
			_drag = true
			_drag_grab = 0.0
			ed.seek_to(tt, false)
		accept_event()
	elif event is InputEventMouseButton and not event.pressed\
	and event.button_index == MOUSE_BUTTON_LEFT:
		_drag = false
		accept_event()
	elif event is InputEventMouseMotion and _drag:
		ed.seek_to(x_to_time(event.position.x) + _drag_grab, false)
		ed.audio_peek()
		accept_event()
	elif event is InputEventMouseButton and event.pressed\
	and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		var d: = 1.0 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1.0
		ed.seek(d * ed.grid_div())
		accept_event()










class _Head:
	extends Control
	var ov

	func _ready() -> void :
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void :
		if ov == null or ov.ed == null:
			return
		var r: Rect2 = ov.track()
		var span: float = ov.window_span()
		var wx0: float = ov.time_to_x(ov.ed.view_t - span * 0.5)
		var wx1: float = ov.time_to_x(ov.ed.view_t + span * 0.5)
		var wrect: = Rect2(wx0, r.position.y, maxf(wx1 - wx0, 4.0), r.size.y)
		draw_rect(wrect, Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 0.1))
		draw_rect(wrect, Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 0.85), 
			false, 1.0)
		var cx: float = ov.time_to_x(ov.ed.t)
		draw_line(Vector2(cx, r.position.y - 3), Vector2(cx, r.end.y + 3), 
			ov.ed.main.neon(EdTheme.MINT, 1.3), 1.5)


var _head: _Head = null




var _wave_px: = PackedFloat32Array()
var _wave_key: = ""


func _draw() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), EdTheme.PANEL)
	draw_rect(Rect2(Vector2.ZERO, size), EdTheme.LINE_SOFT, false, 1.0)
	var f: Font = ed.font
	var r: = track()
	var total: float = maxf(ed.song_len(), 0.001)

	if folded():

		draw_string(f, Vector2(22, 20), "OVERVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO, Color(1, 1, 1, 0.38))
	else:
		draw_string(f, Vector2(22, 15), "OVERVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO, Color(1, 1, 1, 0.38))
		draw_string(f, Vector2(8, 42), "LENGTH", HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO, Color(1, 1, 1, 0.28))
		draw_string(f, Vector2(8, 56), EdTheme.fmt_time(total), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_SMALL, EdTheme.TXT)
		draw_string(f, Vector2(8, 72), "%d notes" % ed.notes.size(), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, EdTheme.TXT_FAINT)

	draw_rect(r, Color(0.014, 0.018, 0.04))






	if not ed.wave.is_empty():
		var mid: = r.position.y + r.size.y * 0.5
		var per_px: float = total / maxf(r.size.x, 1.0)
		var x: = r.position.x
		while x <= r.end.x:
			var t0: float = (x - r.position.x) * per_px
			var h: float = WavePeaks.peak_between(ed.wave, t0, t0 + per_px)\
			* r.size.y * 0.46
			if h > 0.2:
				draw_line(Vector2(x, mid - h), Vector2(x, mid + h), 
					Color(0.4, 0.52, 0.95, 0.3), 1.0)
			x += 1.0


	for k in ed.kiai:
		var kx0: = time_to_x(float(k[0]))
		var kx1: = time_to_x(float(k[1]))
		draw_rect(Rect2(kx0, r.position.y, maxf(kx1 - kx0, 1.0), r.size.y), 
			Color(EdTheme.WARM.r, EdTheme.WARM.g, EdTheme.WARM.b, 0.02))
		draw_rect(Rect2(kx0, r.end.y - 2, maxf(kx1 - kx0, 1.0), 2), 
			Color(EdTheme.WARM.r, EdTheme.WARM.g, EdTheme.WARM.b, 0.8))


	for b in ed.bookmarks:
		var bx: = time_to_x(float(b))
		draw_line(Vector2(bx, r.position.y), Vector2(bx, r.end.y), 
			Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.3), 1.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx, r.position.y), Vector2(bx + 6.0, r.position.y), 
			Vector2(bx, r.position.y + 6.0)]), 
			Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.85))


	if not ed.selection.is_empty():
		var sx0: = time_to_x(float(ed.selection[0]))
		var sx1: = time_to_x(float(ed.selection[1]))
		draw_rect(Rect2(sx0, r.position.y, maxf(sx1 - sx0, 1.0), r.size.y), 
			Color(EdTheme.MINT.r, EdTheme.MINT.g, EdTheme.MINT.b, 0.07))



	var rows: = {"parry": 0.22, "dodge": 0.42, "click": 0.62, "sliderm": 0.8, 
		"sliderg": 0.8}
	for n in ed.notes:
		var tp: = String(n.type)
		var key: = tp
		if tp == "clickx":
			key = "click"
		elif tp == "beam":
			key = "sliderm"
		if not rows.has(key):
			continue
		var x: = time_to_x(float(n.time))
		var y: = r.position.y + r.size.y * float(rows[key])
		var c: Color = EdTheme.accent_for(tp)
		if EdTheme.has_duration(tp):
			var x2: = time_to_x(float(n.time) + float(n.get("duration", 0.0)))
			draw_rect(Rect2(x, y - 1.5, maxf(x2 - x, 1.5), 3.0), 
				Color(c.r, c.g, c.b, 0.75))
		else:
			draw_rect(Rect2(x, y - 2.0, 1.6, 4.0), Color(c.r, c.g, c.b, 0.85))


	for ev in ed.fx_sorted():
		var fx0: = time_to_x(float(ev.get("time", 0.0)))
		var fx1: = time_to_x(float(ev.get("time", 0.0))
			+ maxf(float(ev.get("len", 0.0)), 0.0))
		var fc: Color = EdFx.color(String(ev.get("type", "")))
		var selected: bool = int(ev.get("_uid", -1)) == ed.sel_fx_uid
		draw_rect(Rect2(fx0, r.position.y + 1.0, maxf(fx1 - fx0, 1.5), 4.0), 
			Color(fc.r, fc.g, fc.b, 0.95 if selected else 0.55))
		if selected:
			draw_rect(Rect2(fx0 - 1.0, r.position.y, maxf(fx1 - fx0, 1.5) + 2.0, 6.0), 
				Color(fc.r, fc.g, fc.b, 0.9), false, 1.0)









	if ed.auto_report_fresh():
		for z in (ed.auto_report.get("zones", []) as Array):
			var zx0: = time_to_x(float(z[0]))
			var zx1: = time_to_x(float(z[1]))



			var zw: float = maxf(zx1 - zx0, 3.0)
			draw_rect(Rect2(zx0, r.position.y, zw, r.size.y), 
				Color(1.0, 0.25, 0.3, 0.22))
			draw_rect(Rect2(zx0, r.position.y, zw, r.size.y), 
				Color(1.0, 0.35, 0.4, 0.75), false, 1.0)


			draw_rect(Rect2(zx0, r.position.y - 3.0, zw, 3.0), 
				Color(1.0, 0.32, 0.36, 0.95))







	var win: Array = ed.played_window()
	var vx0: = time_to_x(float(win[0]))
	var vx1: = time_to_x(float(win[1]))
	var veil: = Color(0.006, 0.008, 0.02, 0.62)
	var edge: = Color(EdTheme.MINT.r, EdTheme.MINT.g, EdTheme.MINT.b, 0.4)
	if vx0 > r.position.x + 0.5:
		draw_rect(Rect2(r.position.x, r.position.y, vx0 - r.position.x, r.size.y), 
			veil)
		draw_line(Vector2(vx0, r.position.y), Vector2(vx0, r.end.y), edge, 1.0)
	if vx1 < r.end.x - 0.5:
		draw_rect(Rect2(vx1, r.position.y, r.end.x - vx1, r.size.y), veil)
		draw_line(Vector2(vx1, r.position.y), Vector2(vx1, r.end.y), edge, 1.0)





	var stepsec: = 30.0
	if total < 60.0:
		stepsec = 10.0
	elif total > 300.0:
		stepsec = 60.0
	var s: = 0.0
	while s <= total:
		var gx: = time_to_x(s)
		draw_line(Vector2(gx, r.position.y - 4), Vector2(gx, r.position.y), 
			Color(1, 1, 1, 0.22), 1.0)
		draw_string(f, Vector2(gx + 2, r.position.y - 5), 
			"%d:%02d" % [int(s) / 60, int(s) % 60], HORIZONTAL_ALIGNMENT_LEFT, 
			-1, EdTheme.S_MICRO, Color(1, 1, 1, 0.25))
		s += stepsec
	draw_rect(r, EdTheme.LINE, false, 1.0)
