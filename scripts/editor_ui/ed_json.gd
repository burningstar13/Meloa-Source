extends Control















const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdBrowser = preload("res://scripts/editor_ui/ed_browser.gd")

const PAD: = 22.0

var ed
var _edit: CodeEdit
var _err: Label
var _rect: = Rect2()


static func open(host: Control, p_ed) -> Control:


	var d = load("res://scripts/editor_ui/ed_json.gd").new()
	d.ed = p_ed
	host.add_child(d)
	return d


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 94


func _ready() -> void :
	var vs: = get_viewport_rect().size
	var w: = minf(vs.x - 80.0, 900.0)
	var h: = minf(vs.y - 60.0, 600.0)
	_rect = Rect2((vs - Vector2(w, h)) * 0.5, Vector2(w, h))

	_edit = CodeEdit.new()
	_edit.text = ed.serialize()
	_edit.position = _rect.position + Vector2(PAD, 56.0)
	_edit.size = Vector2(w - PAD * 2.0, h - 56.0 - 74.0)
	_edit.add_theme_font_override("font", ed.font)
	_edit.add_theme_font_size_override("font_size", EdTheme.S_SMALL)
	_edit.add_theme_color_override("font_color", EdTheme.TXT)
	_edit.add_theme_color_override("caret_color", EdTheme.CYAN)
	_edit.add_theme_color_override("selection_color", 
		Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.25))
	_edit.add_theme_stylebox_override("normal", 
		EdTheme.flat(Color(0.012, 0.016, 0.036), EdTheme.LINE, 3))
	_edit.add_theme_stylebox_override("focus", 
		EdTheme.flat(Color(0.012, 0.016, 0.036), 
		Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.5), 3))


	_edit.gutters_draw_line_numbers = true
	_edit.scroll_smooth = true
	add_child(_edit)

	_err = EdTheme.make_label("", EdTheme.S_SMALL, EdTheme.RED, ed.font)
	_err.position = Vector2(_rect.position.x + PAD, _rect.end.y - 62.0)
	_err.size = Vector2(w - PAD * 2.0 - 320.0, 34)
	_err.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_err)



	var x: = _rect.position.x + PAD
	x = _btn(" IMPORT FILE... ", x, EdTheme.CYAN, 
		"Read a .json chart from disk into this box", _import)
	x = _btn(" PASTE ", x, Color.TRANSPARENT, 
		"Replace this box with the clipboard", func():
			_edit.text = DisplayServer.clipboard_get()
			_err.text = "")
	x = _btn(" COPY ", x, Color.TRANSPARENT, 
		"Copy this chart to the clipboard", func():
			DisplayServer.clipboard_set(_edit.text)
			_err.add_theme_color_override("font_color", EdTheme.MINT)
			_err.text = "Copied to the clipboard.")

	var ax: = _rect.end.x - PAD
	ax = _btn_right(" APPLY ", ax, EdTheme.MINT, 
		"Replace the chart with this text\nUndoable — nothing is written "
		+ "to disk until you save", _apply)
	_btn_right(" CANCEL ", ax, Color.TRANSPARENT, "Esc", func(): queue_free())

	_edit.grab_focus()


func _btn(text: String, x: float, accent: Color, tip: String, 
		cb: Callable) -> float:
	var b: = EdTheme.text_button(text, tip, accent, ed.font, EdTheme.S_SMALL)
	var w: float = ed.font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 
		EdTheme.S_SMALL).x + 22.0
	b.size = Vector2(w, 24)
	b.position = Vector2(x, _rect.end.y - PAD - 18.0)
	b.pressed.connect(cb)
	add_child(b)
	return x + w + 6.0


func _btn_right(text: String, x: float, accent: Color, tip: String, 
		cb: Callable) -> float:
	var w: float = ed.font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 
		EdTheme.S_BODY).x + 30.0
	var b: = EdTheme.text_button(text, tip, accent, ed.font, EdTheme.S_BODY)
	b.size = Vector2(w, 26)
	b.position = Vector2(x - w, _rect.end.y - PAD - 19.0)
	b.pressed.connect(cb)
	add_child(b)
	return x - w - 6.0


func _import() -> void :
	EdBrowser.open(self, ed.font, ed.font_display, 
		PackedStringArray(["json"]), "IMPORT A CHART", EdTheme.CYAN, 
		func(path: String):
			var f: = FileAccess.open(path, FileAccess.READ)
			if f == null:
				_fail("Could not read " + path.get_file())
				return
			_edit.text = f.get_as_text()
			f.close()
			_err.add_theme_color_override("font_color", EdTheme.MINT)
			_err.text = "%s loaded — check it, then APPLY." % path.get_file())


func _fail(msg: String) -> void :
	_err.add_theme_color_override("font_color", EdTheme.RED)
	_err.text = msg


func _apply() -> void :
	var err: String = ed.import_json(_edit.text)
	if err != "":
		_fail(err)
		return
	queue_free()


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed\
	and not _rect.has_point(event.position):
		queue_free()
		accept_event()


func _unhandled_key_input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed\
	and event.physical_keycode == KEY_ESCAPE:
		queue_free()
		get_viewport().set_input_as_handled()


func _draw() -> void :
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0, 0, 0.01, 0.72))
	draw_rect(Rect2(_rect.position + Vector2(0, 4), _rect.size), Color(0, 0, 0, 0.45))
	draw_rect(_rect, Color(0.018, 0.024, 0.052, 0.99))
	draw_rect(_rect, Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.6), 
		false, 1.0)
	draw_string(ed.font_display, _rect.position + Vector2(PAD, PAD + 14.0), 
		"CHART JSON", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, 
		ed.main.neon(EdTheme.CYAN, 1.1))
	draw_string(ed.font, _rect.position + Vector2(PAD + 132.0, PAD + 14.0), 
		"exactly what SAVE writes — APPLY replaces the chart in memory "
		+ "(undoable), it does not touch the disk", 
		HORIZONTAL_ALIGNMENT_LEFT, _rect.size.x - PAD * 2.0 - 132.0, 
		EdTheme.S_MICRO, Color(1, 1, 1, 0.3))
