extends Control













const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

const BW: = 520.0
const BH: = 400.0


var exts: PackedStringArray = PackedStringArray(["mp3", "ogg", "wav"])
var title: = "CHOOSE A FILE"
var accent: Color = EdTheme.CYAN
var font: Font
var font_display: Font

var on_pick: Callable

var _cwd: = ""
var _list: VBoxContainer
var _path_lbl: Label
var _rect: = Rect2()



static func open(host: Control, p_font: Font, p_font_display: Font, 
		p_exts: PackedStringArray, p_title: String, p_accent: Color, 
		cb: Callable) -> Control:


	var b = load("res://scripts/editor_ui/ed_browser.gd").new()
	b.font = p_font
	b.font_display = p_font_display
	b.exts = p_exts
	b.title = p_title
	b.accent = p_accent
	b.on_pick = cb
	host.add_child(b)
	return b


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 96


func _ready() -> void :
	var vs: = get_viewport_rect().size
	_rect = Rect2((vs - Vector2(BW, BH)) * 0.5, Vector2(BW, BH))
	_path_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.TXT_FAINT, font)
	_path_lbl.position = _rect.position + Vector2(16, 34)
	_path_lbl.size = Vector2(BW - 100.0, 16)
	_path_lbl.clip_text = true
	add_child(_path_lbl)
	var close: = EdTheme.text_button(" CLOSE ", "Esc", Color.TRANSPARENT, 
		font, EdTheme.S_MICRO)
	close.size = Vector2(64, 20)
	close.position = Vector2(_rect.end.x - 80.0, _rect.position.y + 30.0)
	close.pressed.connect(queue_free)
	add_child(close)
	var scroll: = ScrollContainer.new()
	scroll.position = _rect.position + Vector2(12, 56)
	scroll.size = Vector2(BW - 24.0, BH - 68.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 1)
	_list.custom_minimum_size.x = BW - 40.0
	scroll.add_child(_list)
	_show_places()


func accepts(path: String) -> bool:
	return path.get_extension().to_lower() in exts



func _show_places() -> void :
	_cwd = ""
	_path_lbl.text = "PLACES"
	_clear()
	var places: = [
		["Game tracks", "res://tracks"], 
		["Game charts", "res://charts"], 
		["Your maps", "user://maps"], 
		["Music", OS.get_system_dir(OS.SYSTEM_DIR_MUSIC)], 
		["Desktop", OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)], 
		["Downloads", OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)], 
		["Documents", OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)], 
	]
	for p in places:
		var path: = String(p[1])
		if path == "" or not DirAccess.dir_exists_absolute(path):
			continue
		_row(String(p[0]), "folder", func(): _browse(path))
	for i in DirAccess.get_drive_count():
		var d: = DirAccess.get_drive_name(i)
		if d == "":
			continue
		_row(d, "drive", func(): _browse(d))


func _browse(path: String) -> void :
	var d: = DirAccess.open(path)
	if d == null:
		return
	_cwd = path
	_path_lbl.text = path
	_clear()
	_row("..  places", "up", _show_places)
	var parent: = path.get_base_dir()
	if parent != "" and parent != path:
		_row("..  " + parent.get_file(), "up", func(): _browse(parent))
	var dirs: = d.get_directories()
	dirs.sort()
	for sub in dirs:
		if sub.begins_with("."):
			continue
		var full: = path.path_join(sub)
		_row(sub, "folder", func(): _browse(full))
	var files: = d.get_files()
	files.sort()
	var any: = false
	for fl in files:
		if not accepts(fl):
			continue
		any = true
		var full2: = path.path_join(fl)
		_row(fl, "file", func():
			if on_pick.is_valid():
				on_pick.call(full2)
			queue_free())
	if not any and dirs.is_empty():
		_list.add_child(EdTheme.make_label("  Nothing to open here.", 
			EdTheme.S_SMALL, Color(1, 1, 1, 0.28), font))


func _clear() -> void :
	for c in _list.get_children():
		c.queue_free()


func _row(text: String, kind: String, cb: Callable) -> void :
	var col: Color = EdTheme.TXT_DIM
	var prefix: = "  "
	match kind:
		"file":
			col = EdTheme.MINT
			prefix = "  ·  "
		"up":
			col = EdTheme.CYAN
		"drive":
			col = EdTheme.VIOLET
	var b: = EdTheme.text_button(prefix + text, "", Color.TRANSPARENT, 
		font, EdTheme.S_SMALL)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.custom_minimum_size.y = 20
	b.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", col)
	b.pressed.connect(cb)
	_list.add_child(b)


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
	draw_rect(Rect2(Vector2.ZERO, get_viewport_rect().size), Color(0, 0, 0.01, 0.55))
	draw_rect(_rect, Color(0.016, 0.021, 0.046, 0.99))
	draw_rect(_rect, Color(accent.r, accent.g, accent.b, 0.55), false, 1.0)
	draw_string(font_display, _rect.position + Vector2(16, 24), title, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 
		Color(accent.r * 1.2, accent.g * 1.2, accent.b * 1.2))
