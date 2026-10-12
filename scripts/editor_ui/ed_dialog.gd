extends Control
















const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

signal closed(id, values)

const W: = 420.0
const PAD: = 22.0
const ROW_H: = 26.0

var ed
var title: = ""
var body: = ""
var options: Array = []
var fields: Array = []
var _edits: = {}
var _validate: Callable
var _err_lbl: Label
var _ok_btn: Button
var _rect: = Rect2()





static func _spawn(p_ed) -> Control:


	var d = load("res://scripts/editor_ui/ed_dialog.gd").new()
	d.ed = p_ed
	return d



static func confirm(host: Control, p_ed, p_title: String, p_body: String, 
		ok_text: String, cb: Callable, danger: = false) -> Control:
	var d: = _spawn(p_ed)
	d.title = p_title
	d.body = p_body
	d.options = [
		{"text": "Cancel", "id": ""}, 
		{"text": ok_text, "id": "ok", 
			"accent": EdTheme.RED if danger else EdTheme.MINT}, 
	]
	if cb.is_valid():
		d.closed.connect( func(id, _v): cb.call(String(id)))
	host.add_child(d)
	return d



static func choices(host: Control, p_ed, p_title: String, p_body: String, 
		p_options: Array, cb: Callable) -> Control:
	var d: = _spawn(p_ed)
	d.title = p_title
	d.body = p_body
	d.options = p_options
	if cb.is_valid():
		d.closed.connect( func(id, _v): cb.call(String(id)))
	host.add_child(d)
	return d




static func form(host: Control, p_ed, p_title: String, p_fields: Array, 
		ok_text: String, cb: Callable, validate: = Callable()) -> Control:
	var d: = _spawn(p_ed)
	d.title = p_title
	d.fields = p_fields
	d.options = [{"text": "Cancel", "id": ""}, 
		{"text": ok_text, "id": "ok", "accent": EdTheme.MINT}]
	d._validate = validate
	if cb.is_valid():
		d.closed.connect( func(id, v): cb.call(String(id), v))
	host.add_child(d)
	return d


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 95


func _ready() -> void :
	_layout()
	_build()




func _row_advance(f: Dictionary) -> float:
	return ROW_H + (40.0 if f.has("hint") else 8.0)


func _layout() -> void :
	var vs: = get_viewport_rect().size
	var h: = PAD * 2.0 + 34.0
	if body != "":
		h += 34.0
	for f in fields:
		h += _row_advance(f)
	h += 44.0
	_rect = Rect2((vs - Vector2(W, h)) * 0.5, Vector2(W, h))


func _build() -> void :
	var y: = _rect.position.y + PAD + 30.0 + (34.0 if body != "" else 0.0)
	for f in fields:
		var le: = LineEdit.new()
		le.text = String(f.get("value", ""))
		le.placeholder_text = String(f.get("placeholder", ""))
		EdTheme.style_line_edit(le, ed.font, EdTheme.S_VALUE)
		le.alignment = HORIZONTAL_ALIGNMENT_LEFT
		le.position = Vector2(_rect.position.x + PAD + 132.0, y)
		le.size = Vector2(W - PAD * 2.0 - 132.0, ROW_H - 4.0)
		le.text_changed.connect( func(_t): _revalidate())
		le.text_submitted.connect( func(_t): _try_ok())
		add_child(le)
		_edits[String(f.key)] = le
		y += _row_advance(f)

	_err_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.RED, ed.font)
	_err_lbl.position = Vector2(_rect.position.x + PAD, _rect.end.y - 58.0)
	_err_lbl.size = Vector2(W - PAD * 2.0, 14)
	_err_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_err_lbl)



	var x: = _rect.end.x - PAD
	for i in range(options.size() - 1, -1, -1):
		var o: Dictionary = options[i]
		var b: = EdTheme.text_button("  %s  " % String(o.text), "", 
			o.get("accent", Color.TRANSPARENT), ed.font, EdTheme.S_BODY)
		var bw: float = maxf(92.0, ed.font.get_string_size(String(o.text), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_BODY).x + 34.0)
		b.size = Vector2(bw, 26)
		b.position = Vector2(x - bw, _rect.end.y - PAD - 20.0)
		x -= bw + 6.0
		var id: = String(o.get("id", ""))
		b.pressed.connect( func(): _finish(id))
		add_child(b)
		if id == "ok":
			_ok_btn = b
	if not _edits.is_empty():
		(_edits.values()[0] as LineEdit).grab_focus()
	_revalidate()


func values() -> Dictionary:
	var out: = {}
	for k in _edits:
		out[k] = (_edits[k] as LineEdit).text
	return out


func _revalidate() -> void :
	if not _validate.is_valid() or _ok_btn == null:
		return
	var msg: = String(_validate.call(values()))
	_ok_btn.disabled = msg != ""
	_err_lbl.text = msg


func _try_ok() -> void :
	if _ok_btn != null and _ok_btn.disabled:
		return
	_finish("ok")


func _finish(id: String) -> void :
	var v: = values()
	closed.emit(id, v)
	queue_free()


func _gui_input(event: InputEvent) -> void :

	if event is InputEventMouseButton and event.pressed\
	and not _rect.has_point(event.position):
		_finish("")
		accept_event()


func _unhandled_key_input(event: InputEvent) -> void :
	if not (event is InputEventKey and event.pressed):
		return
	if event.physical_keycode == KEY_ESCAPE:
		_finish("")
		get_viewport().set_input_as_handled()
	elif event.physical_keycode == KEY_ENTER or event.physical_keycode == KEY_KP_ENTER:
		_try_ok()
		get_viewport().set_input_as_handled()


func _draw() -> void :
	var vs: = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0.01, 0.68))
	draw_rect(Rect2(_rect.position + Vector2(0, 4), _rect.size), Color(0, 0, 0, 0.45))
	draw_rect(_rect, Color(0.018, 0.024, 0.052, 0.99))
	draw_rect(_rect, Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 
		0.65), false, 1.0)
	var f: Font = ed.font
	draw_string(ed.font_display, _rect.position + Vector2(PAD, PAD + 14.0), title, 
		HORIZONTAL_ALIGNMENT_LEFT, W - PAD * 2.0, 17, 
		ed.main.neon(EdTheme.VIOLET, 1.1))
	var y: = _rect.position.y + PAD + 30.0
	if body != "":
		draw_multiline_string(f, Vector2(_rect.position.x + PAD, y + 12.0), body, 
			HORIZONTAL_ALIGNMENT_LEFT, W - PAD * 2.0, EdTheme.S_BODY, 2, 
			Color(1, 1, 1, 0.66))
		y += 34.0
	for fd in fields:
		draw_string(f, Vector2(_rect.position.x + PAD, y + 16.0), 
			String(fd.label), HORIZONTAL_ALIGNMENT_LEFT, 126.0, 
			EdTheme.S_SMALL, EdTheme.TXT_DIM)
		if fd.has("hint"):


			draw_multiline_string(f, 
				Vector2(_rect.position.x + PAD + 132.0, y + ROW_H + 20.0), 
				String(fd.hint), HORIZONTAL_ALIGNMENT_LEFT, 
				W - PAD * 2.0 - 132.0, EdTheme.S_MICRO, 2, 
				Color(1, 1, 1, 0.26))
		y += _row_advance(fd)
