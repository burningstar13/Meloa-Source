extends Control













const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

var title: = "WORKING…"
var message: = ""
var detail: = ""
var on_cancel: Callable
var _font: Font
var _font_display: Font
var _t0: = 0.0
var _cancelling: = false





static func open(host: Control, p_font: Font, p_font_display: Font, p_title: String, 
		p_message: String, cancel: = Callable()) -> Control:
	var b = load("res://scripts/editor_ui/ed_busy.gd").new()
	b._font = p_font
	b._font_display = p_font_display
	b.title = p_title
	b.message = p_message
	b.on_cancel = cancel
	host.add_child(b)
	return b


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 200
	_t0 = Time.get_ticks_msec() / 1000.0
	set_process(true)
	set_process_input(true)


func set_message(msg: String, p_detail: = "") -> void :
	message = msg
	detail = p_detail
	queue_redraw()


func close() -> void :
	set_process_input(false)
	queue_free()


func _process(_dt: float) -> void :
	queue_redraw()




func _input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed and not event.echo\
	and event.physical_keycode == KEY_ESCAPE and on_cancel.is_valid()\
	and not _cancelling:
		_cancelling = true
		set_message("cancelling…", "")
		on_cancel.call()
	get_viewport().set_input_as_handled()


func _gui_input(_event: InputEvent) -> void :
	accept_event()


func _draw() -> void :
	var vs: = size
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.01, 0.012, 0.03, 0.78))
	var pw: = 420.0
	var ph: = 150.0
	var r: = Rect2((vs - Vector2(pw, ph)) * 0.5, Vector2(pw, ph))
	draw_rect(Rect2(r.position + Vector2(0, 4), r.size), Color(0, 0, 0, 0.5))
	draw_rect(r, Color(0.02, 0.026, 0.052, 0.99))
	draw_rect(r, EdTheme.LINE_HI, false, 1.0)

	var el: = Time.get_ticks_msec() / 1000.0 - _t0
	var c: = r.position + Vector2(44.0, ph * 0.5)
	var acc: Color = EdTheme.VIOLET
	for i in 3:
		var a0: = el * (2.2 + float(i) * 0.9) + float(i) * 2.1
		draw_arc(c, 18.0 - float(i) * 5.0, a0, a0 + 1.9, 18, 
			Color(acc.r, acc.g, acc.b, 0.9 - float(i) * 0.25), 2.2, true)
	if _font == null:
		return
	var tx: = r.position.x + 82.0
	var f_title: Font = _font_display if _font_display != null else _font
	draw_string(f_title, Vector2(tx, r.position.y + 42.0), title, 
		HORIZONTAL_ALIGNMENT_LEFT, pw - 100.0, EdTheme.S_TITLE, EdTheme.TXT)
	draw_string(_font, Vector2(tx, r.position.y + 68.0), message, 
		HORIZONTAL_ALIGNMENT_LEFT, pw - 100.0, EdTheme.S_BODY, EdTheme.TXT_DIM)
	if detail != "":
		draw_string(_font, Vector2(tx, r.position.y + 86.0), detail, 
			HORIZONTAL_ALIGNMENT_LEFT, pw - 100.0, EdTheme.S_MICRO, Color(1, 1, 1, 0.35))
	var mins: = floori(el / 60.0)
	var secs: = int(el) % 60
	var foot: = "elapsed %d:%02d" % [mins, secs]
	if on_cancel.is_valid():
		foot += "   ·   Esc to cancel"
	draw_string(_font, Vector2(tx, r.end.y - 16.0), foot, 
		HORIZONTAL_ALIGNMENT_LEFT, pw - 100.0, EdTheme.S_MICRO, Color(1, 1, 1, 0.35))

	var bar: = Rect2(r.position.x + 18.0, r.end.y - 6.0, pw - 36.0, 2.0)
	draw_rect(bar, Color(1, 1, 1, 0.06))
	var k: = 0.5 + 0.5 * sin(el * 2.4)
	draw_rect(Rect2(bar.position.x + (bar.size.x - 80.0) * k, bar.position.y, 80.0, 2.0), 
		Color(acc.r, acc.g, acc.b, 0.8))
