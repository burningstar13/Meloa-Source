extends Control













const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdBrowser = preload("res://scripts/editor_ui/ed_browser.gd")


signal done(draft)

const W: = 640.0
const H: = 516.0
const PAD: = 26.0
const ROW: = 30.0
const LABEL_W: = 150.0


const AUDIO_BTN_W: = 256.0

var main
var _rect: = Rect2()
var _edits: = {}
var _audio_path: = ""
var _audio_len: = 0.0
var _audio_btn: Button
var _audio_lbl: Label
var _create_btn: Button
var _err_lbl: Label
var _browser: Control


const FIELDS: = [
	{"key": "title", "label": "SONG TITLE", "req": true, 
		"hint": "As written by the artist."}, 
	{"key": "artist", "label": "ARTIST", "req": true, "hint": ""}, 
	{"key": "title_r", "label": "TITLE (ROMANISED)", "req": false, 
		"hint": "Optional. Used for display and search when it is set."}, 
	{"key": "artist_r", "label": "ARTIST (ROMANISED)", "req": false, "hint": ""}, 
	{"key": "creator", "label": "MAPPER", "req": false, 
		"hint": "Your name. Optional."}, 
	{"key": "diff", "label": "FIRST DIFFICULTY", "req": true, 
		"hint": "Normal, Hard, Insane... you can add more later."}, 
	{"key": "level", "label": "LEVEL", "req": false, 
		"hint": "The constant you announce. The game computes its own too."}, 



	{"key": "lane_v", "label": "LANE NOTE SPEED", "req": false, 
		"hint": "Scroll speed of white and red notes placed in this map (SV).\n1 = normal, 0.5 slow, 2 fast. Each note can still be changed later."}, 
	{"key": "aim_v", "label": "AIM APPROACH SPEED", "req": false, 
		"hint": "Approach-ring speed of yellow targets placed in this map (SV).\n1 = normal, 0.5 slow, 2 fast. Each note can still be changed later."}, 
]
const V_MIN: = 0.5
const V_MAX: = 2.0


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 80


func _ready() -> void :
	var vs: = get_viewport_rect().size
	_rect = Rect2((vs - Vector2(W, H)) * 0.5, Vector2(W, H))
	_build()
	get_viewport().size_changed.connect(_refit)


func _font(display: = false) -> Font:
	if display and main.font_display != null:
		return main.font_display
	return main.font_bold if main.font_bold != null else ThemeDB.fallback_font


func _refit() -> void :


	var vs: = get_viewport_rect().size
	var old: = _rect.position
	_rect.position = (vs - _rect.size) * 0.5
	var d: = _rect.position - old
	for c in get_children():
		if c is Control:
			(c as Control).position += d
	queue_redraw()


func _build() -> void :
	var f: = _font()
	var y: = _rect.position.y + PAD + 52.0


	_audio_btn = EdTheme.text_button("  CHOOSE AN AUDIO FILE  ", 
		"mp3, ogg or wav\nThe file is copied into the map's own folder", 
		EdTheme.CYAN, f, EdTheme.S_BODY)
	_audio_btn.position = Vector2(_rect.position.x + PAD + LABEL_W, y)
	_audio_btn.size = Vector2(AUDIO_BTN_W, ROW - 4.0)
	_audio_btn.pressed.connect(_open_browser)
	add_child(_audio_btn)
	_audio_lbl = EdTheme.make_label("no file selected", EdTheme.S_SMALL, 
		EdTheme.TXT_FAINT, f)
	_audio_lbl.position = Vector2(
		_rect.position.x + PAD + LABEL_W + AUDIO_BTN_W + 10.0, y + 4.0)
	_audio_lbl.size = Vector2(
		W - PAD * 2.0 - LABEL_W - AUDIO_BTN_W - 10.0, 20)
	_audio_lbl.clip_text = true
	add_child(_audio_lbl)
	y += ROW + 10.0

	for fd in FIELDS:
		var le: = LineEdit.new()
		le.placeholder_text = "required" if bool(fd.req) else "optional"


		le.tooltip_text = String(fd.hint)
		if String(fd.key) == "level":
			le.text = "0"
		elif String(fd.key) in ["lane_v", "aim_v"]:
			le.text = "1.0"
		EdTheme.style_line_edit(le, f, EdTheme.S_VALUE)
		le.alignment = HORIZONTAL_ALIGNMENT_LEFT
		le.position = Vector2(_rect.position.x + PAD + LABEL_W, y)
		le.size = Vector2(W - PAD * 2.0 - LABEL_W, ROW - 8.0)
		le.text_changed.connect( func(_t): _revalidate())
		add_child(le)
		_edits[String(fd.key)] = le
		y += ROW + 4.0

	_err_lbl = EdTheme.make_label("", EdTheme.S_SMALL, EdTheme.GOLD, f)
	_err_lbl.position = Vector2(_rect.position.x + PAD, _rect.end.y - 62.0)
	_err_lbl.size = Vector2(W - PAD * 2.0 - 220.0, 30)
	_err_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_err_lbl)

	var cancel: = EdTheme.text_button("  CANCEL  ", "Esc", Color.TRANSPARENT, 
		f, EdTheme.S_BODY)
	cancel.size = Vector2(96, 28)
	cancel.position = Vector2(_rect.end.x - PAD - 96.0 - 6.0 - 128.0, 
		_rect.end.y - PAD - 22.0)
	cancel.pressed.connect(_cancel)
	add_child(cancel)

	_create_btn = EdTheme.text_button("  CREATE  ", 
		"Creates the map and opens it in the editor", EdTheme.MINT, f, 
		EdTheme.S_BODY)
	_create_btn.size = Vector2(128, 28)
	_create_btn.position = Vector2(_rect.end.x - PAD - 128.0, 
		_rect.end.y - PAD - 22.0)
	_create_btn.pressed.connect(_create)
	add_child(_create_btn)

	(_edits["title"] as LineEdit).grab_focus()
	_revalidate()






func _revalidate() -> void :
	var msg: = ""
	if _audio_path == "":
		msg = "Choose the audio file the map will be built on."
	elif String((_edits["title"] as LineEdit).text).strip_edges() == "":
		msg = "The song needs a title."
	elif String((_edits["artist"] as LineEdit).text).strip_edges() == "":
		msg = "The song needs an artist."
	elif String((_edits["diff"] as LineEdit).text).strip_edges() == "":
		msg = "The first difficulty needs a name."
	elif not _v_ok("lane_v"):
		msg = "Lane note speed must be a number between %.1f and %.1f." % [V_MIN, V_MAX]
	elif not _v_ok("aim_v"):
		msg = "Aim approach speed must be a number between %.1f and %.1f." % [V_MIN, V_MAX]
	_create_btn.disabled = msg != ""
	_err_lbl.text = msg
	_err_lbl.add_theme_color_override("font_color", 
		EdTheme.GOLD if msg != "" else Color(1, 1, 1, 0.3))
	if msg == "":
		_err_lbl.text = "Nothing is written to disk until you save in the editor."


func _cancel() -> void :
	done.emit({})
	queue_free()


func _create() -> void :
	if _create_btn.disabled:
		return
	var v: = func(k: String) -> String:
		return String((_edits[k] as LineEdit).text).strip_edges()
	var draft: Dictionary = MapLibrary.new_draft({
		"title": v.call("title"), 
		"artist": v.call("artist"), 
		"title_romanised": v.call("title_r"), 
		"artist_romanised": v.call("artist_r"), 
		"creator": v.call("creator"), 
		"source_audio": _audio_path, 
		"duration": _audio_len, 
		"diff_name": v.call("diff"), 
		"diff_level": float(v.call("level")), 
		"default_v_lane": _v_of("lane_v"), 
		"default_v_aim": _v_of("aim_v"), 
	})
	done.emit(draft)
	queue_free()



func _v_ok(key: String) -> bool:
	var raw: = String((_edits[key] as LineEdit).text).strip_edges().replace(",", ".")
	if raw == "":
		return true
	if not raw.is_valid_float():
		return false
	var f: = raw.to_float()
	return f >= V_MIN and f <= V_MAX


func _v_of(key: String) -> float:
	var raw: = String((_edits[key] as LineEdit).text).strip_edges().replace(",", ".")
	if raw == "" or not raw.is_valid_float():
		return 1.0
	return clampf(raw.to_float(), V_MIN, V_MAX)




func pick_audio(path: String) -> void :
	if _browser != null and is_instance_valid(_browser):
		_browser.queue_free()
	_pick_audio(path)


func _pick_audio(path: String) -> void :


	var stream: AudioStream = MapLibrary.load_audio(path)
	if stream == null:
		_audio_path = ""
		_audio_lbl.text = "could not read this file"
		_audio_lbl.add_theme_color_override("font_color", EdTheme.RED)
		_revalidate()
		return
	_audio_path = path
	_audio_len = stream.get_length()
	_audio_lbl.text = "%s   ·   %02d:%02d" % [path.get_file(), 
		int(_audio_len) / 60, int(_audio_len) % 60]
	_audio_lbl.add_theme_color_override("font_color", EdTheme.MINT)


	var t: LineEdit = _edits["title"]
	if t.text.strip_edges() == "":
		t.text = path.get_file().get_basename()
	_revalidate()


func _open_browser() -> void :
	if _browser != null and is_instance_valid(_browser):
		return
	_browser = EdBrowser.open(self, _font(), _font(true), 
		PackedStringArray(MapLibrary.AUDIO_EXT), "CHOOSE AUDIO", 
		EdTheme.CYAN, _pick_audio)


func _unhandled_key_input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed\
	and event.physical_keycode == KEY_ESCAPE:
		if _browser != null and is_instance_valid(_browser):
			_browser.queue_free()
		else:
			_cancel()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed\
	and not _rect.has_point(event.position):
		accept_event()


func _draw() -> void :
	var vs: = get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, vs), Color(0.008, 0.01, 0.028, 0.94))
	draw_rect(Rect2(_rect.position + Vector2(0, 5), _rect.size), Color(0, 0, 0, 0.5))
	draw_rect(_rect, Color(0.018, 0.024, 0.052, 0.99))
	draw_rect(_rect, Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 
		0.7), false, 1.0)
	var f: = _font()
	draw_string(_font(true), _rect.position + Vector2(PAD, PAD + 16.0), 
		"NEW MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, 
		main.neon(EdTheme.VIOLET, 1.15))
	draw_string(f, _rect.position + Vector2(PAD + 132.0, PAD + 16.0), 
		"a blank map, on the song of your choice", 
		HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_SMALL, Color(1, 1, 1, 0.3))
	draw_line(_rect.position + Vector2(PAD, PAD + 30.0), 
		Vector2(_rect.end.x - PAD, _rect.position.y + PAD + 30.0), 
		EdTheme.LINE, 1.0)

	var y: = _rect.position.y + PAD + 52.0
	draw_string(f, Vector2(_rect.position.x + PAD, y + 17.0), "AUDIO FILE", 
		HORIZONTAL_ALIGNMENT_LEFT, LABEL_W - 8.0, EdTheme.S_SMALL, EdTheme.TXT_DIM)
	y += ROW + 10.0
	for fd in FIELDS:
		draw_string(f, Vector2(_rect.position.x + PAD, y + 15.0), 
			String(fd.label), HORIZONTAL_ALIGNMENT_LEFT, LABEL_W - 8.0, 
			EdTheme.S_SMALL, 
			EdTheme.TXT_DIM if bool(fd.req) else Color(1, 1, 1, 0.3))
		y += ROW + 4.0
