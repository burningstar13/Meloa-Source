class_name ChartEditor
extends Node2D



























const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdFx = preload("res://scripts/editor_ui/ed_fx.gd")
const FxEval = preload("res://scripts/fx_eval.gd")
const FxImages = preload("res://scripts/fx_images.gd")
const GifDecoder = preload("res://scripts/gif_decoder.gd")
const ChartRating = preload("res://scripts/chart_rating.gd")
const AutoCheck = preload("res://scripts/auto_check.gd")
const WavePeaks = preload("res://scripts/wave_peaks.gd")
const StageRender = preload("res://scripts/stage_render.gd")
const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")
const EdTopBar = preload("res://scripts/editor_ui/ed_topbar.gd")
const EdTools = preload("res://scripts/editor_ui/ed_tools.gd")
const EdTimeline = preload("res://scripts/editor_ui/ed_timeline.gd")
const EdCanvas = preload("res://scripts/editor_ui/ed_canvas.gd")
const EdInspector = preload("res://scripts/editor_ui/ed_inspector.gd")
const EdOverview = preload("res://scripts/editor_ui/ed_overview.gd")
const EdShortcuts = preload("res://scripts/editor_ui/ed_shortcuts.gd")
const EdDialog = preload("res://scripts/editor_ui/ed_dialog.gd")
const EdBrowser = preload("res://scripts/editor_ui/ed_browser.gd")
const EdBusy = preload("res://scripts/editor_ui/ed_busy.gd")
const EdToast = preload("res://scripts/editor_ui/ed_toast.gd")


signal chart_changed

signal selection_changed

signal time_changed

signal tool_changed

signal view_changed

signal status_changed

var main














var map_track: = ""


var map_meta: Dictionary = {}

var diff_key: = ""



var draft: Dictionary = {}




var read_only: = false



var chart_path: = ""
var bpm: = 120.0
var chart_offset: = 0.0
var chart_vel: = 1.0




var default_v_lane: = 1.0
var default_v_aim: = 1.0
var audio_res: = ""
var notes: Array = []
var kiai: Array = []
var grid_anchor: = 0.0
var chart_end: = 0.0
var chart_practice: = 0.0





var fx_events: Array = []




var bookmarks: Array = []



var t: = 0.0
var view_t: = 0.0
var zoom: = 240.0
var playing: = false
var dirty: = false
var _quit_armed: = false





var tool: = "select"


var chain_building_uid: = -1
var grid_manual: = 0





var grid_base: = 1
var snap_on: = true



var beats_per_bar: = 4
var follow_playhead: = true
var show_fx: = true
var show_ghosts: = true
var show_bars: = true




var hit_sounds: = true
var _sfx_last_t: = -1.0
var _sfx_pending: Array = []



var show_approach: = true


var preview_ratio: = 1280.0 / 720.0



var sel_uids: Array = []
var sel_fx_uid: = -1
var sel_fx_extra: Array = []
var hover_uid: = -1
var sel_a: = -1.0
var selection: Array = []
var clipboard: Array = []
var clipboard_len: = 0.0
var clipboard_fx: Array = []



var recording: = false


var rec_offset: = -0.03
var rec_flash: = 0.0
var _rec_pass: Array = []
var rec_lane: = 1



const HISTORY_MAX: = 96
var _undo: Array = []
var _redo: Array = []
var _uid_next: = 1



var _bounds_dirty: = true
var _max_span: = 0.0
var _max_lead: = 1.0
var _fx_sorted_cache: Array = []
var _fx_sort_dirty: = true



var _player: AudioStreamPlayer


var play_rate: = 1.0
var _pitch_fx: AudioEffectPitchShift


var _peek_timer: Timer
const PEEK_SEC: = 0.09
var _len: = 1.0
var _audio_loaded: = ""



var wave: = PackedFloat32Array()
var _wave_scan = null
var status: = ""
var _status_until: = 0
var hint: = ""



var ui: Control
var topbar
var tools_panel
var timeline
var canvas
var inspector
var overview
var shortcuts
var side_col: VBoxContainer
var side_rail: Button
var font: Font
var font_display: Font





var ui_open: = {
	"display": false, 
	"details": false, 
	"overview": true, 
	"inspector": true, 
}


func ui_is_open(key: String) -> bool:
	return bool(ui_open.get(key, true))


func ui_set_open(key: String, value: bool) -> void :
	if bool(ui_open.get(key, true)) == value:
		return
	ui_open[key] = value
	view_changed.emit()


func _ready() -> void :
	_player = AudioStreamPlayer.new()


	if AudioServer.get_bus_index("EditorMusic") == -1:
		var bi: = AudioServer.bus_count
		AudioServer.add_bus(bi)
		AudioServer.set_bus_name(bi, "EditorMusic")
		AudioServer.set_bus_send(bi, "Music")
		AudioServer.add_bus_effect(bi, AudioEffectPitchShift.new())
		AudioServer.set_bus_effect_enabled(bi, 0, false)
	_pitch_fx = AudioServer.get_bus_effect(AudioServer.get_bus_index("EditorMusic"), 0)
	_player.bus = "EditorMusic"
	add_child(_player)
	_peek_timer = Timer.new()
	_peek_timer.one_shot = true
	_peek_timer.timeout.connect( func() -> void :
		if not playing:
			_player.stop())
	add_child(_peek_timer)
	font = main.font_bold if main.font_bold != null else ThemeDB.fallback_font
	font_display = main.font_display if main.font_display != null else font
	if draft.is_empty():
		_load()
	else:
		_load_blank()
	_build_ui()
	chart_changed.emit()
	time_changed.emit()














const PLAY_W: = 1280.0
const PLAY_H: = 720.0


func play_size() -> Vector2:
	return Vector2(PLAY_W, PLAY_H)





func preview_width() -> float:
	return snappedf(PLAY_H * preview_ratio, 1.0)




func previewing() -> bool:
	return absf(preview_ratio - PLAY_W / PLAY_H) > 0.001





func lane_center(i: int, tt: = NAN, width: = 0.0) -> float:
	var w: float = PLAY_W if width <= 0.0 else width
	var st: = fx_state_at(t if is_nan(tt) else tt)
	return FxEval.lane_center(st, i, t if is_nan(tt) else tt, 
		main.tuning.lane_width, main.tuning.lane_gap, w)



func lane_half(i: int, tt: = NAN) -> float:
	return FxEval.lane_half(fx_state_at(t if is_nan(tt) else tt), i, 
		main.tuning.lane_width)


func song_len() -> float:
	return _len


















func _build_ui() -> void :
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ui)





	_fit_ui()
	get_viewport().size_changed.connect(_fit_ui)

	var bg: = ColorRect.new()
	bg.color = EdTheme.BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	ui.add_child(bg)

	var margin: = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(margin)

	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 5)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(col)

	topbar = EdTopBar.new()
	topbar.ed = self
	col.add_child(topbar)

	var body: = HBoxContainer.new()
	body.add_theme_constant_override("separation", 5)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(body)

	tools_panel = EdTools.new()
	tools_panel.ed = self
	body.add_child(tools_panel)



	var center: = VBoxContainer.new()
	center.add_theme_constant_override("separation", 5)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(center)

	timeline = EdTimeline.new()
	timeline.ed = self
	timeline.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	center.add_child(timeline)

	canvas = EdCanvas.new()
	canvas.ed = self
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(canvas)





	side_col = VBoxContainer.new()
	side_col.add_theme_constant_override("separation", 5)
	side_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(side_col)

	inspector = EdInspector.new()
	inspector.ed = self
	inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_col.add_child(inspector)




	side_rail = EdTheme.icon_button("chevron", "Show the inspector", EdTheme.VIOLET)
	side_rail.custom_minimum_size = Vector2(18, 0)
	side_rail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_rail.pressed.connect( func(): ui_set_open("inspector", true))
	body.add_child(side_rail)

	view_changed.connect(_apply_side_layout)
	_apply_side_layout()


	var bottom: = HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 5)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(bottom)

	overview = EdOverview.new()
	overview.ed = self
	overview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(overview)



	shortcuts = EdShortcuts.new()
	shortcuts.ed = self
	shortcuts.visible = false
	ui.add_child(shortcuts)



	var toast: = EdToast.new()
	toast.ed = self
	ui.add_child(toast)





func editing_path() -> bool:
	var n = focus_note()
	return n != null and String(n.type) == "sliderg"


func _apply_side_layout() -> void :
	if side_col == null or not is_instance_valid(side_col):
		return
	var open: = ui_is_open("inspector")
	side_col.visible = open
	side_col.custom_minimum_size.x = 0.0 if not open else 230.0
	side_rail.visible = not open


func _fit_ui() -> void :
	if ui == null or not is_instance_valid(ui):
		return
	ui.position = Vector2.ZERO
	ui.size = get_viewport_rect().size



func overlay_host() -> Control:
	return ui










func _extract_fx_raw(raw: String) -> Array:
	var key: = -1
	var from: = 0
	while true:
		var at: = raw.find("\"fx\"", from)
		if at < 0:
			return []
		var j: = at + 4
		while j < raw.length() and raw[j] in [" ", "\t", "\n", "\r"]:
			j += 1
		if j < raw.length() and raw[j] == ":":
			key = j
			break
		from = at + 4
	var open: = raw.find("[", key)
	if open < 0:
		return []
	var out: Array = []
	var depth: = 0
	var start: = -1
	var in_str: = false
	var esc: = false
	for i in range(open, raw.length()):
		var c: = raw[i]
		if in_str:
			if esc:
				esc = false
			elif c == "\\":
				esc = true
			elif c == "\"":
				in_str = false
			continue
		match c:
			"\"":
				in_str = true
			"{":
				if depth == 0:
					start = i
				depth += 1
			"}":
				depth -= 1
				if depth == 0 and start >= 0:
					out.append(raw.substr(start, i - start + 1))
					start = -1
			"]":
				if depth == 0:
					return out
	return out






func _load_blank() -> void :
	notes = []
	kiai = []
	fx_events = []
	_fx_sort_dirty = true
	_bounds_dirty = true
	bpm = 120.0
	chart_offset = 0.0
	chart_vel = 1.0
	var dv: Dictionary = draft.get("default_v", {}) if draft.get("default_v", {}) is Dictionary else {}
	default_v_lane = clampf(float(dv.get("lane", 1.0)), 0.5, 2.0)
	default_v_aim = clampf(float(dv.get("aim", 1.0)), 0.5, 2.0)
	grid_anchor = 0.0
	chart_end = 0.0
	chart_practice = 0.0
	audio_res = String(draft.get("source_audio", ""))
	_attach_audio(audio_res)
	dirty = true




func _attach_audio(path: String) -> void :

	if path == _audio_loaded and _player.stream != null:
		return
	var stream: AudioStream = MapLibrary.load_audio(path)
	if stream == null:
		if path != "":
			flash("audio not found: " + path.get_file())
		return
	_player.stream = stream
	_len = stream.get_length()
	_audio_loaded = path
	_start_wave(stream, path)


func _load() -> void :
	var file: = FileAccess.open(chart_path, FileAccess.READ)
	if file == null:
		flash("chart not found: " + chart_path)
		return
	var raw_text: = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(raw_text)
	if not (parsed is Dictionary):
		flash("unreadable chart (invalid JSON)")
		return
	apply_data(parsed, raw_text)









func apply_data(data: Dictionary, raw_text: = "") -> void :


	fx_events = []
	var fx_src: Array = data.get("fx", [])
	var fx_raw: = _extract_fx_raw(raw_text)
	var verbatim: bool = fx_raw.size() == fx_src.size()
	for i in fx_src.size():
		var ev: Dictionary = (fx_src[i] as Dictionary).duplicate(true)
		ev["_uid"] = _uid_next
		_uid_next += 1
		if verbatim:
			ev["_raw"] = fx_raw[i]
		fx_events.append(ev)



	bpm = maxf(_num(float(data.get("bpm", 120.0)), 120.0), 20.0)
	chart_end = maxf(_num(float(data.get("end", 0.0))), 0.0)
	chart_practice = maxf(_num(float(data.get("practice", 0.0))), 0.0)
	chart_offset = clampf(_num(float(data.get("offset", 0.0))), -60.0, 60.0)
	chart_vel = clampf(_num(float(data.get("velocity", 1.0)), 1.0), 0.6, 2.0)
	var dv: Dictionary = data.get("default_v", {}) if data.get("default_v", {}) is Dictionary else {}
	default_v_lane = clampf(_num(float(dv.get("lane", 1.0)), 1.0), 0.5, 2.0)
	default_v_aim = clampf(_num(float(dv.get("aim", 1.0)), 1.0), 0.5, 2.0)
	audio_res = String(data.get("audio", ""))




	if map_track != "" and MapLibrary.is_user_map(map_track)\
	and (audio_res == "" or not FileAccess.file_exists(audio_res)):
		var lib_audio: = MapLibrary.audio_path(map_track)
		if lib_audio != "":
			audio_res = lib_audio
	grid_anchor = _num(float(data.get("grid_anchor", 0.0)))
	kiai = []
	for k in data.get("kiai", []):
		if not (k is Array) or (k as Array).size() < 2:
			continue
		kiai.append([_num(float(k[0])), _num(float(k[1]))])
	bookmarks = []
	for b in data.get("bookmarks", []):
		bookmarks.append(_num(float(b)))
	bookmarks.sort()
	notes = []
	for n in data.get("notes", []):


		if not (n is Dictionary) or not n.has("time") or not n.has("type"):
			continue
		var note: = {
			"time": _num(float(n["time"])), 
			"lane": clampi(int(n.get("lane", 1)), 0, 2), 
			"type": String(n["type"]), 
			"_uid": _uid_next, 
		}
		_uid_next += 1
		if n.has("x"):
			note["x"] = _num(float(n["x"]), PLAY_W * 0.5)
		if n.has("y"):
			note["y"] = _num(float(n["y"]), PLAY_H * 0.5)
		if n.has("v"):
			note["v"] = clampf(_num(float(n["v"]), 1.0), 0.5, 2.0)

		if n.has("duration"):
			note["duration"] = maxf(_num(float(n["duration"]), 0.5), 0.02)
		if n.has("points"):
			note["points"] = n["points"]

		if n.has("path"):
			note["path"] = n["path"]

		if n.has("extra"):
			note["extra"] = n["extra"]
		notes.append(note)
	_sort()
	_attach_audio(audio_res)










func import_json(text: String) -> String:



	var json: = JSON.new()
	if json.parse(text) != OK:
		return "Line %d — %s" % [json.get_error_line() + 1, 
			json.get_error_message()]
	if not (json.data is Dictionary):
		return "A chart must be a JSON object — it starts with { and ends with }."
	var data: Dictionary = json.data
	if not (data.get("notes", null) is Array):
		return "This chart has no \"notes\" array."
	if not (data.get("bpm", null) is float or data.get("bpm", null) is int):
		return "This chart has no numeric \"bpm\"."
	for i in (data.notes as Array).size():
		var n = data.notes[i]
		if not (n is Dictionary) or not n.has("time") or not n.has("type"):
			return "Note %d is missing \"time\" or \"type\"." % (i + 1)
	if playing:
		toggle_play()
	push_undo("import JSON")
	var keep_audio: = audio_res
	var own_audio: bool = is_draft() or MapLibrary.is_user_map(map_track)
	apply_data(data, text)
	if own_audio and keep_audio != "":
		audio_res = keep_audio
		_attach_audio(audio_res)
	clear_selection()
	chain_building_uid = -1
	t = clampf(t, 0.0, _len)
	view_t = t
	mark_dirty()
	flash("chart replaced — %d notes (Ctrl+Z to undo)" % notes.size())
	chart_changed.emit()
	selection_changed.emit()
	time_changed.emit()
	view_changed.emit()
	return ""







func auto_bounds() -> Array:
	var first: = INF
	var last: = - INF
	for n in notes:
		first = minf(first, float(n.time))
		last = maxf(last, float(n.time) + float(n.get("duration", 0.0)))
	for ev in fx_events:
		var t0: = float(ev.get("time", 0.0))
		first = minf(first, t0)
		last = maxf(last, t0 + maxf(float(ev.get("len", 0.5)), 0.0))
	for k in kiai:
		first = minf(first, float(k[0]))
		last = maxf(last, float(k[1]))
	if first == INF:
		return [0.0, 0.0]
	var a: = 0.0
	var b: = 0.0
	if first > main.AUTO_MIN_SKIP:
		a = maxf(0.0, first - main.AUTO_LEAD)
	var stop: float = last + main.AUTO_TAIL
	if _len > 0.0 and stop < _len - main.AUTO_MIN_CUT:
		b = stop
	return [a, b]




func played_window() -> Array:
	var auto: = auto_bounds()
	var a: float = chart_practice if chart_practice > 0.0 else float(auto[0])
	var b: float = chart_end if chart_end > 0.0 else float(auto[1])
	return [a, b if b > 0.0 else song_len()]



func diff_path(key: String) -> String:
	if map_track == "":
		return ""
	if MapLibrary.is_user_map(map_track):



		for d in map_meta.get("difficulties", []):
			if String(d.key) == key:
				return "%s/%s" % [MapLibrary.map_dir(map_track), String(d.file)]
		return ""


	return String(MapLibrary.diffs_of(map_track).get(key, ""))



func is_draft() -> bool:
	return not draft.is_empty()



func map_title() -> String:
	if not draft.is_empty():
		var t2: = String(draft.meta.title)
		return t2 if t2 != "" else "UNTITLED"
	if map_track != "":
		return MapLibrary.title_of(map_track)
	return chart_path.get_file().get_basename().to_upper()



func diff_label() -> String:
	if not draft.is_empty():
		var ds: Array = draft.meta.difficulties
		return String(ds[0].name) if not ds.is_empty() else "NEW"
	if map_track != "" and diff_key != "":
		return MapLibrary.diff_name(map_track, diff_key)

	return diff_key.to_upper() if diff_key != "" else\
	chart_path.get_file().get_basename().to_upper()




func _materialise_draft() -> bool:
	var key: String = MapLibrary.commit_draft(draft)
	if key == "":
		flash("SAVE FAILED! could not create the map folder")
		return false
	map_track = key
	map_meta = MapLibrary.meta_of(key)
	diff_key = String(draft.diff)
	audio_res = MapLibrary.audio_path(key)
	draft = {}
	chart_path = diff_path(diff_key)
	return chart_path != ""






func _sync_map_meta() -> void :
	if map_track == "" or not can_write():
		return
	map_meta["duration"] = _len
	for d in map_meta.get("difficulties", []):
		if String(d.key) == diff_key:



			d["rated"] = float(rating.get("level", 0.0))
			d["modified"] = MapLibrary.now_stamp()
	MapLibrary.save_meta(map_track, map_meta)
	map_meta = MapLibrary.meta_of(map_track)











static func _json_str(s: String) -> String:
	return JSON.stringify(s)


func serialize() -> String:
	_sort()
	var sb: = "{\n  \"bpm\": %.2f,\n  \"audio\": %s,\n  \"offset\": %.3f,\n"\
	%[bpm, _json_str(audio_res), chart_offset]


	if map_track != "" and MapLibrary.is_user_map(map_track):
		sb += """  \"diff\": { \"name\": %s, \"level\": %.1f },
""" %[_json_str(diff_label()), 
			MapLibrary.diff_level(map_track, diff_key)]
	if absf(chart_vel - 1.0) > 0.001:
		sb += "  \"velocity\": %.2f,\n" % chart_vel
	if absf(default_v_lane - 1.0) > 0.001 or absf(default_v_aim - 1.0) > 0.001:
		sb += """  \"default_v\": { \"lane\": %.2f, \"aim\": %.2f },
""" %[default_v_lane, default_v_aim]
	if chart_end > 0.0:
		sb += "  \"end\": %.1f,\n" % chart_end
	if chart_practice > 0.0:
		sb += "  \"practice\": %.2f,\n" % chart_practice
	sb += "  \"grid_anchor\": %.3f,\n" % grid_anchor
	if not kiai.is_empty():
		var ks: = PackedStringArray()
		for k in kiai:
			ks.append("[%.3f, %.3f]" % [k[0], k[1]])
		sb += "  \"kiai\": [%s],\n" % ", ".join(ks)
	if not bookmarks.is_empty():
		var bs: = PackedStringArray()
		for b in bookmarks:
			bs.append("%.3f" % float(b))
		sb += "  \"bookmarks\": [%s],\n" % ", ".join(bs)
	if not fx_events.is_empty():


		var fxs: = PackedStringArray()
		for ev in fx_events:

			fxs.append("    " + (String(ev._raw) if ev.has("_raw")
				else EdFx.to_json(ev)))
		sb += "  \"fx\": [\n%s\n  ],\n" % ",\n".join(fxs)
	sb += "  \"notes\": [\n"
	for i in notes.size():
		var n: Dictionary = notes[i]



		var line: = "    { \"time\": %.3f, \"lane\": %d, \"type\": %s"\
		%[n.time, n.lane, _json_str(String(n.type))]
		if n.has("duration"):
			line += ", \"duration\": %.3f" % n.duration
		if n.has("points"):
			var ps: = PackedStringArray()
			for p in n.points:
				ps.append("[%.3f, %.1f, %.1f]" % [float(p[0]), float(p[1]), float(p[2])])
			line += ", \"points\": [%s]" % ", ".join(ps)
		if n.has("path"):
			var hs: = PackedStringArray()
			for p in n.path:
				hs.append("[%.3f, %.1f]" % [float(p[0]), float(p[1])])
			line += ", \"path\": [%s]" % ", ".join(hs)
		if n.has("extra"):
			var xs: = PackedStringArray()
			for e in n.extra:
				xs.append("[%.3f, %.1f, %.1f]" % [float(e[0]), float(e[1]), float(e[2])])
			line += ", \"extra\": [%s]" % ", ".join(xs)
		if n.has("x"):
			line += ", \"x\": %.1f, \"y\": %.1f" % [n.x, n.get("y", 300.0)]
		if absf(n.get("v", 1.0) - 1.0) > 0.001:
			line += ", \"v\": %.2f" % n.v
		line += " }"
		sb += line + (",\n" if i < notes.size() - 1 else "\n")
	sb += "  ]\n}\n"
	return sb




func save(quiet: = false) -> void :
	if read_only:
		if not quiet:
			flash("REVIEW MODE — this map is not yours, nothing is written")
		return
	if not draft.is_empty() and not _materialise_draft():
		return
	var sb: = serialize()


	if not MapLibrary.write_text_atomic(chart_path, sb):
		flash("SAVE FAILED!")
		return
	dirty = false
	_quit_armed = false
	_autosave_t = 0.0
	_sync_map_meta()
	if quiet:
		flash("auto-saved")
	else:
		flash("saved — %d notes" % notes.size())
		main.sfx.play_ui("click")
	chart_changed.emit()






const AUTOSAVE_SEC: = 60.0
var _autosave_t: = 0.0

func _autosave_tick(delta: float) -> void :
	if not dirty or is_draft() or playing or read_only:
		_autosave_t = 0.0 if not dirty else _autosave_t
		return
	_autosave_t += delta
	if _autosave_t >= AUTOSAVE_SEC:
		save(true)









func _start_wave(stream: AudioStream, path: String) -> void :
	wave = PackedFloat32Array()
	_wave_scan = null
	if stream == null:
		return
	var r: = WavePeaks.begin(stream, path)
	wave = r.peaks
	_wave_scan = r.scan




func _step_wave() -> void :
	if _wave_scan == null:
		return
	var finished: bool = _wave_scan.step()
	wave = _wave_scan.peaks
	if finished:
		WavePeaks.save_cached(_wave_scan.print_, _wave_scan.peaks)
		_wave_scan = null
		view_changed.emit()



func wave_building() -> bool:
	return _wave_scan != null



func wave_progress() -> float:
	return 1.0 if _wave_scan == null else float(_wave_scan.progress)




func _process(delta: float) -> void :
	_autosave_tick(delta)
	if playing:


		t = _player.get_playback_position() + AudioServer.get_time_since_last_mix() * play_rate
		_sfx_step(t)
		if not _player.playing:
			playing = false
			topbar.refresh()
		if follow_playhead:
			view_t = t
		time_changed.emit()
	if rec_flash > 0.0:
		rec_flash = maxf(0.0, rec_flash - delta * 6.0)
		timeline.queue_redraw()
	if _status_until > 0 and Time.get_ticks_msec() > _status_until:
		_status_until = 0
		status = ""
		status_changed.emit()
	_poll_rating()
	_step_wave()


func toggle_play() -> void :
	_rec_pass.clear()
	if playing:
		playing = false
		_player.stop()
		t = snap(t)
		view_t = t
	else:
		playing = true
		view_t = t


		_sfx_last_t = t
		_sfx_pending.clear()
		_player.play(clampf(t, 0.0, _len - 0.05))
	time_changed.emit()
	topbar.refresh()




static func _sfx_key(note_type: String) -> String:
	match note_type:
		"parry":
			return "parry_perfect"
		"dodge":
			return "dodge"
		"click", "clickx", "sliderg":
			return "click_perfect"
		"sliderm", "beam":
			return "parry_good"
	return ""







func _sfx_step(now: float) -> void :
	if not hit_sounds or main == null or main.sfx == null:
		_sfx_last_t = now
		return
	var since: = _sfx_last_t
	_sfx_last_t = now
	if now <= since:
		return
	var played: = {}
	var lo: = 0
	var hi: = notes.size()
	while lo < hi:
		var mid: = (lo + hi) >> 1
		if float(notes[mid].time) <= since:
			lo = mid + 1
		else:
			hi = mid
	for i in range(lo, notes.size()):
		var n: Dictionary = notes[i]
		if float(n.time) > now:
			break
		var key: = _sfx_key(String(n.type))
		if key == "":
			continue
		played[key] = true
		if EdTheme.has_duration(String(n.type)) and n.has("duration"):
			_sfx_pending.append([float(n.time) + float(n.duration), 
				"click_perfect" if String(n.type) == "sliderg" else "parry_perfect"])



		if String(n.type) == "clickx":
			for e in n.get("extra", []):
				if e is Array and e.size() >= 1:
					_sfx_pending.append([float(e[0]), "click_perfect"])
	var keep: Array = []
	for pend in _sfx_pending:
		if float(pend[0]) <= now:
			played[String(pend[1])] = true
		else:
			keep.append(pend)
	_sfx_pending = keep


	for key in played:
		main.sfx.play_sfx(String(key))


func stop_play() -> void :
	if playing:
		playing = false
		_player.stop()
	seek_to(0.0)
	topbar.refresh()


func seek(steps: float) -> void :
	if playing:
		toggle_play()
	var step: = beat_dur() / float(grid_div())
	t = clampf(snap(t + steps * step), 0.0, _len)
	view_t = t
	time_changed.emit()
	audio_peek()




func set_play_rate(r: float) -> void :
	play_rate = clampf(r, 0.25, 1.0)
	_player.pitch_scale = play_rate
	var bi: = AudioServer.get_bus_index("EditorMusic")
	if _pitch_fx != null and bi != -1:
		_pitch_fx.pitch_scale = 1.0 / play_rate
		AudioServer.set_bus_effect_enabled(bi, 0, not is_equal_approx(play_rate, 1.0))
	topbar.refresh()



func audio_peek() -> void :
	if playing or _player.stream == null or _len <= 0.1:
		return
	_player.play(clampf(t, 0.0, _len - 0.05))
	_peek_timer.start(PEEK_SEC / play_rate)


func _seek_to(tt: float) -> void :
	seek_to(tt)


func seek_to(tt: float, do_snap: = true) -> void :
	if playing:
		toggle_play()



	tt = _num(tt)
	t = clampf(snap(tt) if do_snap else tt, 0.0, _len)
	view_t = t
	time_changed.emit()








static func _num(v: float, fallback: = 0.0) -> float:
	return v if is_finite(v) else fallback


func beat_dur() -> float:
	return 60.0 / bpm








func grid_div() -> int:
	if grid_manual > 0:
		return grid_manual
	var div: = maxi(grid_base, 1)


	while div * 2 <= maxi(grid_base, 1) * 16 and div * 2 <= 32\
	and beat_dur() / float(div * 2) * zoom >= 26.0:
		div *= 2
	return div








func set_grid(manual: int, on: = true) -> void :
	snap_on = on
	grid_manual = maxi(manual, 0)
	if grid_manual > 0:
		var b: = grid_manual
		while b > 1 and b % 2 == 0:
			b /= 2
		grid_base = b
	resnap_cursor()
	view_changed.emit()




func resnap_cursor() -> void :
	if not snap_on or playing:
		return
	var snapped: = clampf(snap(t), 0.0, _len)
	if is_equal_approx(snapped, t):
		return
	t = snapped
	view_t = t
	time_changed.emit()


func grid_label() -> String:
	if not snap_on:
		return "OFF"
	if grid_manual > 0:
		return "1/%d" % grid_manual
	return "1/%d" % grid_div()



func snap(tt: float) -> float:
	tt = _num(tt)
	if not snap_on:
		return tt
	var step: = beat_dur() / float(grid_div())
	if not is_finite(step) or step <= 0.0:
		return tt
	return _num(grid_anchor + roundf((tt - _num(grid_anchor)) / step) * step, tt)









func snap_magnet(tt: float, exclude: Array = []) -> float:
	tt = _num(tt)
	var g: = snap(tt)
	if not snap_on:
		return g
	var step: = beat_dur() / float(grid_div())
	if not is_finite(step) or step <= 0.0:
		return g
	var tol: = step * 0.5
	var best: = g
	var bd: = absf(g - tt)
	for n in notes:
		if exclude.has(int(n.get("_uid", -1))):
			continue
		for c in _magnet_times(n):
			var d: = absf(float(c) - tt)
			if d < bd and d <= tol:
				best = float(c)
				bd = d
	for ev in fx_events:
		if exclude.has(int(ev.get("_uid", -1))):
			continue
		var t0: = float(ev.get("time", 0.0))
		for c in [t0, t0 + float(ev.get("len", 0.0))]:
			var d: = absf(float(c) - tt)
			if d < bd and d <= tol:
				best = float(c)
				bd = d
	return _num(best, tt)




func _magnet_times(n: Dictionary) -> Array:
	var out: Array = [float(n.time)]
	if EdTheme.is_chain(String(n.type)) and n.has("extra"):
		for s in chain_steps(n):
			out.append(float(s[0]))
	else:
		var span: = note_span(n)
		if span > 0.0:
			out.append(float(n.time) + span)
	return out


func beat_of(tt: float) -> float:
	return (tt - grid_anchor) / beat_dur()


func set_zoom(z: float) -> void :
	zoom = clampf(z, 60.0, 1600.0)
	view_changed.emit()


func set_tool(tname: String) -> void :
	if tool == tname:
		return
	tool = tname
	chain_building_uid = -1
	main.sfx.play_ui("hover")
	tool_changed.emit()


func set_view_flag(flag: String, value: bool) -> void :
	set(flag, value)
	view_changed.emit()
















func _sort() -> void :
	notes.sort_custom( func(a, b):
		if a.time != b.time:
			return a.time < b.time
		if int(a.lane) != int(b.lane):
			return int(a.lane) < int(b.lane)
		if String(a.type) != String(b.type):
			return String(a.type) < String(b.type)
		return int(a.get("_uid", 0)) < int(b.get("_uid", 0)))
	_bounds_dirty = true
	_fx_sort_dirty = true












func fx_sorted() -> Array:
	if _fx_sort_dirty:
		_fx_sorted_cache = fx_events.duplicate()
		_fx_sorted_cache.sort_custom( func(a, b):
			return float(a.get("time", 0.0)) < float(b.get("time", 0.0)))
		_fx_sort_dirty = false
	return _fx_sorted_cache












func first_note_at_or_after(tt: float) -> int:
	var lo: = 0
	var hi: = notes.size()
	while lo < hi:
		@warning_ignore("integer_division")
		var mid: = (lo + hi) / 2
		if float(notes[mid].time) < tt:
			lo = mid + 1
		else:
			hi = mid
	return lo




func max_span() -> float:
	if _bounds_dirty:
		_recompute_bounds()
	return _max_span




func max_lead() -> float:
	if _bounds_dirty:
		_recompute_bounds()
	return _max_lead


func _recompute_bounds() -> void :
	_bounds_dirty = false
	_max_span = 0.0
	var min_v: = 1.0
	for n in notes:
		_max_span = maxf(_max_span, note_span(n))
		min_v = minf(min_v, float(n.get("v", 1.0)))
	var base: float = maxf(main.tuning.travel_time, 
		maxf(main.tuning.click_approach_time, main.tuning.sliderg_approach_time))
	_max_lead = base / maxf(chart_vel * min_v, 0.05)


func note_by_uid(uid: int) -> Variant:
	for n in notes:
		if int(n.get("_uid", -1)) == uid:
			return n
	return null


func selected_notes() -> Array:
	var out: Array = []
	for uid in sel_uids:
		var n = note_by_uid(uid)
		if n != null:
			out.append(n)
	return out



func focus_note() -> Variant:
	if sel_uids.is_empty():
		return null
	return note_by_uid(sel_uids.back())


func _new_uid() -> int:
	var u: = _uid_next
	_uid_next += 1
	return u


func mark_dirty() -> void :
	dirty = true
	_fx_dirty = true
	_bounds_dirty = true
	_fx_sort_dirty = true
	_rate_dirty = true
	chart_changed.emit()







func _snapshot() -> Dictionary:
	var ns: Array = []
	for n in notes:
		ns.append((n as Dictionary).duplicate(true))
	var fxs: Array = []
	for ev in fx_events:
		fxs.append((ev as Dictionary).duplicate(true))
	return {
		"notes": ns, "fx": fxs, "kiai": kiai.duplicate(true), "bpm": bpm, 
		"grid_anchor": grid_anchor, "chart_vel": chart_vel, 
		"default_v_lane": default_v_lane, "default_v_aim": default_v_aim, 
		"chart_offset": chart_offset, "chart_end": chart_end, 
		"chart_practice": chart_practice, "bookmarks": bookmarks.duplicate(), 
	}


func _restore(s: Dictionary) -> void :
	notes = s.notes
	fx_events = s.fx
	kiai = s.kiai


	_fx_dirty = true
	_bounds_dirty = true
	_fx_sort_dirty = true
	_rate_dirty = true
	bpm = s.bpm
	grid_anchor = s.grid_anchor
	chart_vel = s.chart_vel
	default_v_lane = float(s.get("default_v_lane", 1.0))
	default_v_aim = float(s.get("default_v_aim", 1.0))
	chart_offset = s.chart_offset
	chart_end = s.chart_end
	chart_practice = s.chart_practice
	bookmarks = s.get("bookmarks", [])

	var kept: Array = []
	for uid in sel_uids:
		if note_by_uid(uid) != null:
			kept.append(uid)
	sel_uids = kept
	if sel_fx_uid >= 0 and fx_by_uid(sel_fx_uid) == null:
		sel_fx_uid = -1
	sel_fx_extra = sel_fx_extra.filter( func(u): return fx_by_uid(int(u)) != null)




func push_undo(label: String) -> void :
	_undo.append({"state": _snapshot(), "label": label})
	if _undo.size() > HISTORY_MAX:
		_undo.pop_front()
	_redo.clear()


func can_undo() -> bool:
	return not _undo.is_empty()


func can_redo() -> bool:
	return not _redo.is_empty()


func undo_label() -> String:
	return String(_undo.back().label) if can_undo() else ""


func redo_label() -> String:
	return String(_redo.back().label) if can_redo() else ""


func undo() -> void :
	if _undo.is_empty():
		flash("nothing to undo")
		return
	var entry: Dictionary = _undo.pop_back()
	_redo.append({"state": _snapshot(), "label": entry.label})
	_restore(entry.state)
	dirty = true
	flash("undone: %s" % entry.label)
	main.sfx.play_ui("back")
	chart_changed.emit()
	selection_changed.emit()


func redo() -> void :
	if _redo.is_empty():
		flash("nothing to redo")
		return
	var entry: Dictionary = _redo.pop_back()
	_undo.append({"state": _snapshot(), "label": entry.label})
	_restore(entry.state)
	dirty = true
	flash("redone: %s" % entry.label)
	main.sfx.play_ui("click")
	chart_changed.emit()
	selection_changed.emit()






func add_note(type: String, tt: float, lane: int, sx: = NAN, sy: = NAN, 
		duration: = 0.0, select_it: = true) -> Dictionary:
	push_undo("place %s" % EdTheme.type_label(type).to_lower())
	var note: = {"time": clampf(tt, 0.0, _len), "lane": lane, "type": type, 
		"_uid": _new_uid()}

	var dv: float = default_v_aim if EdTheme.is_aim_type(type) else default_v_lane
	if absf(dv - 1.0) > 0.001:
		note["v"] = dv
	if EdTheme.is_aim_type(type):





		var p: = default_aim_pos(note.time)
		if not is_nan(sx) or not is_nan(sy):
			p = clamp_playfield(Vector2(p.x if is_nan(sx) else sx, 
				p.y if is_nan(sy) else sy))
		note["x"] = p.x
		note["y"] = p.y
	if duration > 0.0:
		note["duration"] = duration
	if type == "sliderg":
		note["points"] = gentle_arc(note.time, note.x, note.get("x", note.x))



		offset_slider_points(note, 
			Vector2(note.x, note.y) - slider_point_at(note, 0.0))
	notes.append(note)
	_sort()
	if select_it:
		sel_uids = [int(note._uid)]
		selection_changed.emit()
	mark_dirty()
	main.sfx.play_ui("click")
	return note




func default_aim_pos(tt: float) -> Vector2:
	var rng: = RandomNumberGenerator.new()
	rng.seed = int(round(tt * 1000.0))
	return Vector2(play_size().x * 0.5, 
		rng.randf_range(150.0, main.tuning.hit_y - 170.0))


func delete_uids(uids: Array, label: = "delete") -> void :
	if uids.is_empty():
		return
	push_undo("%s %d note(s)" % [label, uids.size()])
	for i in range(notes.size() - 1, -1, -1):
		if uids.has(int(notes[i].get("_uid", -1))):
			notes.remove_at(i)
	sel_uids = sel_uids.filter( func(u): return not uids.has(u))
	mark_dirty()
	selection_changed.emit()
	main.sfx.play_ui("back")


func duplicate_uids(uids: Array) -> void :
	if uids.is_empty():
		flash("nothing to duplicate")
		return
	push_undo("duplicate %d note(s)" % uids.size())
	var step: = beat_dur()
	var fresh: Array = []
	for uid in uids:
		var n = note_by_uid(uid)
		if n == null:
			continue
		var c: Dictionary = (n as Dictionary).duplicate(true)
		c["time"] = clampf(c.time + step, 0.0, _len)
		c["_uid"] = _new_uid()
		notes.append(c)
		fresh.append(int(c._uid))
	_sort()
	sel_uids = fresh
	mark_dirty()
	selection_changed.emit()
	flash("%d note(s) duplicated one beat later" % fresh.size())



func convert_type(uids: Array, new_type: String) -> void :
	if uids.is_empty():
		return
	push_undo("change type")
	for uid in uids:
		var n = note_by_uid(uid)
		if n == null or n.type == new_type:
			continue
		n["type"] = new_type
		if EdTheme.is_aim_type(new_type):
			if not n.has("x"):
				var p: = default_aim_pos(n.time)
				n["x"] = p.x
				n["y"] = p.y
		else:
			n.erase("x")
			n.erase("y")
			n.erase("points")
		if not EdTheme.is_chain(new_type):
			n.erase("extra")
		if EdTheme.has_duration(new_type):
			if not n.has("duration"):
				n["duration"] = beat_dur()
			if new_type == "sliderg" and not n.has("points"):
				n["points"] = gentle_arc(n.time, n.x, n.x)
		else:
			n.erase("duration")
			n.erase("points")
	mark_dirty()
	selection_changed.emit()




func set_prop(uids: Array, key: String, value, undo_label_txt: = "modifier") -> void :
	if uids.is_empty():
		return
	if undo_label_txt != "":
		push_undo("%s %s" % [undo_label_txt, key])
	for uid in uids:
		var n = note_by_uid(uid)
		if n == null:
			continue
		if value == null:
			n.erase(key)
		else:
			n[key] = value
	mark_dirty()



func move_notes(uids: Array, dt: float, dlane: = 0, commit: = false, 
		label: = "move") -> void :
	if uids.is_empty():
		return
	if commit:
		push_undo(label)
	for uid in uids:
		var n = note_by_uid(uid)
		if n == null:
			continue
		n["time"] = clampf(n.time + dt, 0.0, _len)
		if dlane != 0 and not EdTheme.is_aim_type(n.type):
			n["lane"] = clampi(int(n.lane) + dlane, 0, 2)
	_sort()
	mark_dirty()




func fx_by_uid(uid: int) -> Variant:
	for ev in fx_events:
		if int(ev.get("_uid", -1)) == uid:
			return ev
	return null


func selected_fx() -> Variant:
	return fx_by_uid(sel_fx_uid) if sel_fx_uid >= 0 else null


func select_fx(uid: int) -> void :
	sel_fx_uid = uid
	sel_fx_extra.clear()
	if uid >= 0:

		sel_uids.clear()
	selection_changed.emit()






func toggle_fx_selection(uid: int) -> void :
	if uid < 0:
		return
	if sel_fx_uid < 0:
		select_fx(uid)
		return
	if uid == sel_fx_uid:

		if sel_fx_extra.is_empty():
			sel_fx_uid = -1
		else:
			sel_fx_uid = int(sel_fx_extra.pop_front())
	elif sel_fx_extra.has(uid):
		sel_fx_extra.erase(uid)
	else:
		sel_fx_extra.append(uid)
	sel_uids.clear()
	selection_changed.emit()



func fx_selection() -> Array:
	var out: Array = []
	if sel_fx_uid >= 0 and fx_by_uid(sel_fx_uid) != null:
		out.append(sel_fx_uid)
	for u in sel_fx_extra:
		if int(u) != sel_fx_uid and fx_by_uid(int(u)) != null:
			out.append(int(u))
	return out


func fx_selected(uid: int) -> bool:
	return uid >= 0 and (uid == sel_fx_uid or sel_fx_extra.has(uid))



func delete_fx_many(uids: Array) -> void :
	var evs: Array = []
	for u in uids:
		var ev = fx_by_uid(int(u))
		if ev != null:
			evs.append(ev)
	if evs.is_empty():
		return
	push_undo("delete %d events" % evs.size())
	for ev in evs:
		fx_events.erase(ev)
	sel_fx_uid = -1
	sel_fx_extra.clear()
	mark_dirty()
	selection_changed.emit()
	main.sfx.play_ui("back")


func add_fx(type: String, at: float) -> Dictionary:
	push_undo("add event (%s)" % EdFx.label(type).to_lower())
	var ev: = EdFx.make(type, at)
	ev["_uid"] = _new_uid()
	fx_events.append(ev)
	sel_fx_uid = int(ev._uid)
	sel_fx_extra.clear()
	sel_uids.clear()
	mark_dirty()
	selection_changed.emit()
	flash("%s added at %s" % [EdFx.label(type), EdTheme.fmt_time(at)])
	main.sfx.play_ui("click")
	return ev


func delete_fx(uid: int) -> void :
	var ev = fx_by_uid(uid)
	if ev == null:
		return
	push_undo("delete event")
	fx_events.erase(ev)
	if sel_fx_uid == uid:
		sel_fx_uid = -1
	sel_fx_extra.erase(uid)
	mark_dirty()
	selection_changed.emit()
	main.sfx.play_ui("back")


func duplicate_fx(uid: int) -> void :
	var ev = fx_by_uid(uid)
	if ev == null:
		return
	push_undo("duplicate event")
	var c: Dictionary = (ev as Dictionary).duplicate(true)
	c["time"] = snappedf(float(c.get("time", 0.0)) + float(c.get("len", 1.0)), 0.001)
	c["_uid"] = _new_uid()
	c.erase("_raw")
	fx_events.append(c)
	sel_fx_uid = int(c._uid)
	sel_fx_extra.clear()
	mark_dirty()
	selection_changed.emit()
	flash("event duplicated after it")




func set_fx_field(uid: int, key: String, value, label: = "modifier") -> void :
	var ev = fx_by_uid(uid)
	if ev == null:
		return
	push_undo("%s %s" % [label, key.trim_prefix("params.")])
	ev.erase("_raw")
	if value == null:
		if key.begins_with("params."):
			(ev.get("params", {}) as Dictionary).erase(key.substr(7))
		else:
			(ev as Dictionary).erase(key)
	else:
		EdFx.set_field(ev, key, value)
	mark_dirty()




var _fx_built: = {}
var _fx_dirty: = true
var _fx_cache: = {}
var _fx_cache_frame: = -1


func _rebuild_fx() -> void :
	_fx_built = FxEval.build(fx_events, main.tuning.lane_width, 
		main.tuning.lane_gap, play_size().x)
	_fx_dirty = false
	_fx_cache.clear()







func fx_state_at(tt: float, width: = 0.0) -> Dictionary:
	if _fx_dirty:
		_rebuild_fx()





	var frame: = Engine.get_process_frames()
	if frame != _fx_cache_frame:
		_fx_cache_frame = frame
		_fx_cache.clear()
	var key: = "%d|%d" % [int(round(tt * 1000.0)), int(width)]
	if _fx_cache.has(key):
		return _fx_cache[key]
	var st: = FxEval.state_at(_fx_built, tt, main.tuning.lane_width, 
		main.tuning.lane_gap, PLAY_W if width <= 0.0 else width, 
		main.LANE_COLS_BASE)
	_fx_cache[key] = st
	return st



func fx_state_now() -> Dictionary:
	return fx_state_at(t)



func fx_texts_now() -> Array:
	if _fx_dirty:
		_rebuild_fx()
	return FxEval.texts_at(_fx_built, t)



func fx_images_now() -> Array:
	if _fx_dirty:
		_rebuild_fx()
	return FxEval.images_at(_fx_built, t)




var _fx_tex_cache: = {}



func fx_image_tex(file: String) -> Texture2D:
	if file == "":
		return null
	if _fx_tex_cache.has(file):
		return _fx_tex_cache[file]
	var tex: Texture2D = null
	if map_track != "":
		tex = FxImages.load_texture(FxImages.dir_for(map_track), file)
	_fx_tex_cache[file] = tex
	return tex






func pick_fx_image(uid: int, field: = "file") -> void :
	if is_draft():
		save()
		if is_draft():
			return
	if not can_write():
		flash("choreography images can only be added to your own maps")
		return
	var exts: = PackedStringArray(MapLibrary.IMAGE_EXT)
	exts.append("gif")
	EdBrowser.open(overlay_host(), font, font_display, exts, 
		"CHOOSE AN IMAGE OR GIF", EdFx.color("image"), 
		func(path: String): _apply_fx_image(uid, field, path))


func _apply_fx_image(uid: int, field: String, path: String) -> void :
	if path == "":
		return
	if path.get_extension().to_lower() == "gif":
		_apply_fx_gif(uid, field, path)
		return
	var name: = MapLibrary.import_asset(map_track, path, "fx_")
	if name == "":
		flash("could not read this image")
		return
	_fx_tex_cache.erase(name)
	set_fx_field(uid, field, name, "set image of")

	var ev = fx_by_uid(uid)
	if ev != null:
		for k in GIF_KEYS:
			(ev as Dictionary).erase(k)
		mark_dirty()
	flash("image set: " + name)
	main.sfx.play_ui("click")





func _apply_fx_gif(uid: int, field: String, path: String) -> void :
	var bytes: = FileAccess.get_file_as_bytes(path)
	if bytes.is_empty():
		flash("could not read this GIF")
		return
	var name: = MapLibrary.asset_name(path, "fx_", "webp")
	var out: = "%s/%s" % [MapLibrary.map_dir(map_track), name]


	if playing:
		stop_play()
	var busy = EdBusy.open(overlay_host(), font, font_display, "CONVERTING GIF", 
		"Decoding %s into a sprite sheet…" % path.get_file(), 
		Callable())
	busy.set_message("Decoding %s into a sprite sheet…" % path.get_file(), 
		"%.1f MB — every frame is kept at its original timing" % (bytes.size() / 1048576.0))
	var th: = Thread.new()
	th.start( func(): return GifDecoder.import_to_sheet(bytes, out))
	while th.is_alive():
		await get_tree().create_timer(0.1).timeout
	var res = th.wait_to_finish()
	busy.close()
	if not (res is Dictionary) or not bool(res.get("ok", false)):
		flash("could not convert this GIF: " + String(res.get("error", "?")
			if res is Dictionary else "?"))
		return
	_fx_tex_cache.erase(name)
	var ev = fx_by_uid(uid)
	if ev == null:
		return
	set_fx_field(uid, field, name, "set GIF of")
	for k in GIF_KEYS:
		(ev as Dictionary).erase(k)
	for k in ["frames", "cols", "per", "sheets", "cw", "ch"]:
		EdFx.set_field(ev, k, int(res[k]))

	if res.has("fps"):
		EdFx.set_field(ev, "fps", float(res.fps))
	else:
		EdFx.set_field(ev, "delays", res.delays)

	var dur: = float(res.get("duration", 0.0))
	if dur > 0.05:
		ev["len"] = snappedf(dur, 0.001)
	mark_dirty()
	var rate: = "%.1f fps" % float(res.fps) if res.has("fps") else "variable timing"
	flash("GIF: %d frames, %s, %.2f s%s" % [int(res.frames), rate, dur, 
		(" — scaled to %d%% to fit memory" % int(round(float(res.get("scale", 1.0)) * 100.0)))
		if float(res.get("scale", 1.0)) < 0.999 else ""])
	main.sfx.play_ui("click")




const GIF_KEYS: = ["frames", "cols", "per", "sheets", "cw", "ch", "fps", "delays"]




var rating: Dictionary = ChartRating.empty()
var _rate_at: = 0
var _rate_dirty: = true





func _poll_rating() -> void :
	if not _rate_dirty:
		return
	var now: = Time.get_ticks_msec()
	if now - _rate_at < 400:
		return
	_rate_at = now
	_rate_dirty = false
	rating = ChartRating.rate(chart_data())
	view_changed.emit()






func chart_data() -> Dictionary:
	return {"notes": notes, "fx": fx_events, "bpm": bpm, 
		"velocity": chart_vel, "kiai": kiai}










var auto_report: Dictionary = {}



var _auto_stamp: = ""



func run_auto_check() -> Dictionary:
	auto_report = AutoCheck.run(chart_data(), main.tuning)
	_auto_stamp = _auto_fingerprint()
	view_changed.emit()
	return auto_report



func auto_report_fresh() -> bool:
	return not auto_report.is_empty() and _auto_stamp == _auto_fingerprint()




func _auto_fingerprint() -> String:
	var acc: = 0.0
	for n in notes:
		acc += float(n.get("time", 0.0)) * 7.0 + float(n.get("duration", 0.0))\
		+ float(n.get("x", 0.0)) * 0.001 + float(n.get("lane", 0)) * 3.0
	return "%d|%d|%.4f|%.3f" % [notes.size(), fx_events.size(), acc, chart_vel]





func fx_in_window(t0: float, t1: float) -> Array:
	var out: Array = []
	for ev in fx_sorted():
		var a: = float(ev.get("time", 0.0))
		var b: = a + maxf(float(ev.get("len", 0.0)), 0.0)
		if b >= t0 and a <= t1:
			out.append(ev)
	return out







func chain_steps(n: Dictionary) -> Array:
	var out: Array = [[float(n.get("time", 0.0)), 
		Vector2(float(n.get("x", play_size().x * 0.5)), 
			float(n.get("y", 300.0)))]]
	for e in n.get("extra", []):
		out.append([float(e[0]), Vector2(float(e[1]), float(e[2]))])
	return out



func set_chain_steps(n: Dictionary, steps: Array) -> void :
	if steps.is_empty():
		return
	steps.sort_custom( func(a, b): return float(a[0]) < float(b[0]))
	n["time"] = clampf(float(steps[0][0]), 0.0, _len)
	n["x"] = float((steps[0][1] as Vector2).x)
	n["y"] = float((steps[0][1] as Vector2).y)
	var extra: Array = []
	for i in range(1, steps.size()):
		var p: Vector2 = steps[i][1]
		extra.append([snappedf(float(steps[i][0]), 0.001), 
			snappedf(p.x, 0.1), snappedf(p.y, 0.1)])
	if extra.is_empty():
		n.erase("extra")
	else:
		n["extra"] = extra




func note_span(n: Dictionary) -> float:
	if EdTheme.is_chain(String(n.type)):
		var st: = chain_steps(n)
		return maxf(float(st.back()[0]) - float(st[0][0]), 0.0)
	return float(n.get("duration", 0.0))












func add_chain_step(uid: int, pos: Vector2, at: = NAN) -> void :
	var n = note_by_uid(uid)
	if n == null or not EdTheme.is_chain(String(n.type)):
		return
	push_undo("add chain step")
	var steps: = chain_steps(n)
	var tt: float = at
	if is_nan(tt):
		var step: = beat_dur() / float(grid_div())
		var after: float = float(steps.back()[0]) + step

		tt = snap(t) if snap(t) >= float(steps.back()[0]) + 0.075 else after
	var vs: = play_size()
	steps.append([clampf(tt, 0.0, _len), 
		Vector2(clampf(pos.x, 120.0, vs.x - 120.0), 
			clampf(pos.y, 90.0, main.tuning.hit_y - 90.0))])
	set_chain_steps(n, steps)
	_sort()
	mark_dirty()
	main.sfx.play_ui("click")


func remove_chain_step(uid: int, idx: int) -> void :
	var n = note_by_uid(uid)
	if n == null or not EdTheme.is_chain(String(n.type)):
		return
	var steps: = chain_steps(n)
	if steps.size() <= 1 or idx < 0 or idx >= steps.size():
		flash("a counter target keeps at least one step")
		return
	push_undo("remove chain step")
	steps.remove_at(idx)
	set_chain_steps(n, steps)
	_sort()
	mark_dirty()
	main.sfx.play_ui("back")



func move_chain_step(uid: int, idx: int, pos: Vector2, commit: = false) -> void :
	var n = note_by_uid(uid)
	if n == null:
		return
	var steps: = chain_steps(n)
	if idx < 0 or idx >= steps.size():
		return
	if commit:
		push_undo("move chain step")
	var vs: = play_size()
	steps[idx][1] = Vector2(clampf(pos.x, 120.0, vs.x - 120.0), 
		clampf(pos.y, 90.0, main.tuning.hit_y - 90.0))
	set_chain_steps(n, steps)
	mark_dirty()


func set_chain_step_time(uid: int, idx: int, tt: float) -> void :
	var n = note_by_uid(uid)
	if n == null:
		return
	var steps: = chain_steps(n)
	if idx < 0 or idx >= steps.size():
		return
	push_undo("set chain step time")
	steps[idx][0] = clampf(tt, 0.0, _len)
	set_chain_steps(n, steps)
	_sort()
	mark_dirty()







func gentle_arc(tt: float, x0: float, x1: float) -> Array:
	var vs: = play_size()
	var rng: = RandomNumberGenerator.new()
	rng.seed = int(round(tt * 1000.0))
	x0 = clampf(x0, 180.0, vs.x - 180.0)
	x1 = clampf(x1, 180.0, vs.x - 180.0)
	var y0: = rng.randf_range(170.0, main.tuning.hit_y - 190.0)
	var y1: = clampf(y0 + rng.randf_range(-90.0, 90.0), 
		150.0, main.tuning.hit_y - 170.0)
	var head: = Vector2(x0, y0)
	var tail: = Vector2(x1, y1)
	var dir: = tail - head
	var norm: = Vector2( - dir.y, dir.x).normalized() if dir.length() > 1.0\
	else Vector2(0, -1)
	var bulge: = clampf(dir.length() * 0.25, 30.0, 90.0)\
	* (1.0 if rng.randf() < 0.5 else -1.0)
	var mid: = (head + tail) * 0.5 + norm * bulge
	mid.x = clampf(mid.x, 170.0, vs.x - 170.0)
	mid.y = clampf(mid.y, 140.0, main.tuning.hit_y - 150.0)
	var pts: Array = []
	for i in 9:
		var u: = float(i) / 8.0
		var p: = head.lerp(mid, u).lerp(mid.lerp(tail, u), u)
		pts.append([snappedf(u, 0.001), snappedf(p.x, 0.1), snappedf(p.y, 0.1)])
	return pts



func slider_point_at(n: Dictionary, u: float) -> Vector2:
	var pts: Array = n.get("points", [])
	if pts.is_empty():
		return Vector2(float(n.get("x", main.lane_x(int(n.lane)))), 
			float(n.get("y", 300.0)))
	u = clampf(u, 0.0, 1.0)
	for i in range(pts.size() - 1):
		var u0: = float(pts[i][0])
		var u1: = float(pts[i + 1][0])
		if u <= u1 or i == pts.size() - 2:
			var s: = 0.0 if u1 - u0 < 0.0001 else clampf((u - u0) / (u1 - u0), 0.0, 1.0)
			return Vector2(lerpf(float(pts[i][1]), float(pts[i + 1][1]), s), 
				lerpf(float(pts[i][2]), float(pts[i + 1][2]), s))
	return Vector2(float(pts.back()[1]), float(pts.back()[2]))



















func clamp_playfield(p: Vector2) -> Vector2:
	var vs: = play_size()
	return Vector2(clampf(p.x, 120.0, vs.x - 120.0), 
		clampf(p.y, 90.0, main.tuning.hit_y - 90.0))





func slider_path(n: Dictionary) -> Array:
	var pts: Array = n.get("points", [])
	if pts.size() >= 2:
		return pts
	var head: = clamp_playfield(Vector2(float(n.get("x", play_size().x * 0.5)), 
		float(n.get("y", 300.0))))
	var tail: = clamp_playfield(head + Vector2(140.0, -60.0))
	return [[0.0, head.x, head.y], [1.0, tail.x, tail.y]]





func _write_slider_path(n: Dictionary, pts: Array) -> void :
	pts.sort_custom( func(a, b): return float(a[0]) < float(b[0]))
	var out: Array = []
	for i in pts.size():
		var p: Array = pts[i]
		var q: = clamp_playfield(Vector2(float(p[1]), float(p[2])))
		var u: = 0.0 if i == 0 else (1.0 if i == pts.size() - 1
			else clampf(float(p[0]), 0.001, 0.999))
		out.append([snappedf(u, 0.001), snappedf(q.x, 0.1), snappedf(q.y, 0.1)])
	n["points"] = out


	n["x"] = float(out[0][1])
	n["y"] = float(out[0][2])




func move_slider_point(uid: int, idx: int, pos: Vector2, commit: = false) -> void :
	var n = note_by_uid(uid)
	if n == null or String(n.type) != "sliderg":
		return
	var pts: Array = slider_path(n).duplicate(true)
	if idx < 0 or idx >= pts.size():
		return
	var p: = clamp_playfield(pos)
	pts[idx] = [float(pts[idx][0]), p.x, p.y]
	_write_slider_path(n, pts)
	if commit:
		mark_dirty()
	else:
		_rate_dirty = true
		chart_changed.emit()












func draw_slider_path(uid: int, trail: PackedVector2Array, count: = 9) -> bool:
	var n = note_by_uid(uid)
	if n == null or String(n.type) != "sliderg":
		return false

	var pts: Array = []
	for p in trail:
		var q: = clamp_playfield(p)
		if pts.is_empty() or (pts[pts.size() - 1] as Vector2).distance_to(q) >= 6.0:
			pts.append(q)
	if pts.size() < 2:
		flash("draw a longer path")
		return false

	var acc: Array = [0.0]
	var total: = 0.0
	for i in range(1, pts.size()):
		total += (pts[i] as Vector2).distance_to(pts[i - 1])
		acc.append(total)
	if total < 40.0:
		flash("draw a longer path")
		return false

	var out: Array = []
	var seg: = 1
	for i in count:
		var u: = float(i) / float(count - 1)
		var want: = u * total
		while seg < acc.size() - 1 and float(acc[seg]) < want:
			seg += 1
		var a: Vector2 = pts[seg - 1]
		var b: Vector2 = pts[seg]
		var l0: float = float(acc[seg - 1])
		var l1: float = float(acc[seg])
		var f: float = 0.0 if l1 - l0 < 0.001 else (want - l0) / (l1 - l0)
		var p2: = a.lerp(b, clampf(f, 0.0, 1.0))
		out.append([u, p2.x, p2.y])
	push_undo("draw slider path")
	_write_slider_path(n, out)
	mark_dirty()
	main.sfx.play_ui("click")
	flash("path redrawn — %d handles" % count)
	return true


func insert_slider_point(uid: int, u: float, pos: Vector2) -> int:
	var n = note_by_uid(uid)
	if n == null or String(n.type) != "sliderg":
		return -1
	var pts: Array = slider_path(n).duplicate(true)
	u = clampf(u, 0.001, 0.999)
	var at: = pts.size() - 1
	for i in pts.size():
		if float(pts[i][0]) > u:
			at = i
			break


	if absf(float(pts[at - 1][0]) - u) < 0.004 or absf(float(pts[at][0]) - u) < 0.004:
		flash("no room for a point here — stretch the slider or zoom the path")
		return -1
	push_undo("slider point")
	var p: = clamp_playfield(pos)
	pts.insert(at, [u, p.x, p.y])
	_write_slider_path(n, pts)
	mark_dirty()
	flash("point added — %d in the path" % pts.size())
	return at




func remove_slider_point(uid: int, idx: int) -> void :
	var n = note_by_uid(uid)
	if n == null or String(n.type) != "sliderg":
		return
	var pts: Array = slider_path(n).duplicate(true)
	if pts.size() <= 2:
		flash("a path needs at least its two ends")
		return
	if idx <= 0 or idx >= pts.size() - 1:
		flash("the start and the end of a slider cannot be removed")
		return
	push_undo("slider point")
	pts.remove_at(idx)
	_write_slider_path(n, pts)
	mark_dirty()
	flash("point removed — %d left" % pts.size())




func reset_slider_path(uid: int, straight: bool) -> void :
	var n = note_by_uid(uid)
	if n == null or String(n.type) != "sliderg":
		return
	push_undo("slider path")
	if straight:
		var pts: Array = slider_path(n)
		var head: = Vector2(float(pts[0][1]), float(pts[0][2]))
		var tail: = Vector2(float(pts.back()[1]), float(pts.back()[2]))
		_write_slider_path(n, [[0.0, head.x, head.y], [1.0, tail.x, tail.y]])
		flash("path straightened — click it to add a corner")
	else:
		var pts2: Array = slider_path(n)
		n["points"] = gentle_arc(float(n.time), float(pts2[0][1]), 
			float(pts2.back()[1]))
		_write_slider_path(n, n.points)
		flash("automatic arc restored")
	mark_dirty()



func offset_slider_points(n: Dictionary, delta: Vector2) -> void :
	var pts: Array = n.get("points", [])
	if pts.is_empty():
		return
	var vs: = play_size()
	var out: Array = []
	for p in pts:
		out.append([float(p[0]), 
			clampf(float(p[1]) + delta.x, 120.0, vs.x - 120.0), 
			clampf(float(p[2]) + delta.y, 100.0, main.tuning.hit_y - 100.0)])
	n["points"] = out





func nearest_lane_from_x(x: float) -> int:
	var best: = 0
	var best_d: = INF
	for i in 3:
		var d: float = absf(x - lane_center(i))
		if d < best_d:
			best_d = d
			best = i
	return best




func select_uids(uids: Array, additive: = false) -> void :
	if additive:
		for u in uids:
			if not sel_uids.has(u):
				sel_uids.append(u)
	else:
		sel_uids = uids.duplicate()
	if not sel_uids.is_empty():
		sel_fx_uid = -1
		sel_fx_extra.clear()
	selection_changed.emit()


func toggle_uid(uid: int) -> void :
	if sel_uids.has(uid):
		sel_uids.erase(uid)
	else:
		sel_uids.append(uid)
	selection_changed.emit()


func clear_selection() -> void :
	sel_uids.clear()
	sel_fx_uid = -1
	sel_fx_extra.clear()
	sel_a = -1.0
	selection = []
	selection_changed.emit()




func zone_key(tt: float) -> void :
	if sel_a < 0.0:
		sel_a = tt
		selection = []
		flash("range marker placed — click a second one to close it")
	else:
		selection = [minf(sel_a, tt), maxf(sel_a, tt)]
		sel_a = -1.0

		sel_uids = zone_uids()
		flash("%d notes selected" % sel_uids.size())
	selection_changed.emit()
	main.sfx.play_ui("click")


func zone_uids() -> Array:
	var found: Array = []
	if selection.is_empty():
		return found
	for n in notes:
		if n.time >= selection[0] - 0.001 and n.time <= selection[1] + 0.001:
			found.append(int(n._uid))
	return found



func target_uids() -> Array:
	if not sel_uids.is_empty():
		return sel_uids.duplicate()
	return zone_uids()


func delete_selection() -> void :

	if sel_uids.is_empty() and sel_fx_uid >= 0:
		var fsel: = fx_selection()
		if fsel.size() > 1:
			delete_fx_many(fsel)
			flash("%d events deleted" % fsel.size())
		else:
			delete_fx(sel_fx_uid)
			flash("event deleted")
		return
	var uids: = target_uids()
	if uids.is_empty():
		flash("nothing to delete — select notes or a range")
		return
	delete_uids(uids, "delete")
	flash("%d note(s) deleted" % uids.size())



func copy_selection(cut: bool) -> void :



	if sel_uids.is_empty() and sel_fx_uid >= 0 and selected_fx() != null:
		var fsel: = fx_selection()
		var ft0: = INF
		for u in fsel:
			ft0 = minf(ft0, float(fx_by_uid(int(u)).get("time", 0.0)))
		clipboard_fx = []
		for u in fsel:
			var c: Dictionary = (fx_by_uid(int(u)) as Dictionary).duplicate(true)
			c["time"] = snappedf(float(c.get("time", 0.0)) - ft0, 0.001)
			c.erase("_uid")
			c.erase("_raw")
			clipboard_fx.append(c)
		clipboard = []
		clipboard_len = 0.0
		if cut:
			if fsel.size() > 1:
				delete_fx_many(fsel)
			else:
				delete_fx(sel_fx_uid)
		var verb: = "cut" if cut else "copied"
		flash(("event %s — Ctrl+V to paste at the cursor" % verb) if fsel.size() == 1
			else ("%d events %s — Ctrl+V to paste at the cursor" % [fsel.size(), verb]))
		main.sfx.play_ui("click")
		return
	var uids: = target_uids()
	if uids.is_empty():
		flash("nothing to copy — select notes or a range")
		return
	clipboard_fx = []
	var t0: = INF
	var t1: = - INF
	for uid in uids:
		var n = note_by_uid(uid)
		if n == null:
			continue
		t0 = minf(t0, float(n.time))
		t1 = maxf(t1, float(n.time) + float(n.get("duration", 0.0)))
	if not selection.is_empty():
		t0 = selection[0]
		t1 = selection[1]
	clipboard = []
	clipboard_len = maxf(t1 - t0, 0.0)
	for uid in uids:
		var n2 = note_by_uid(uid)
		if n2 == null:
			continue
		var c: Dictionary = (n2 as Dictionary).duplicate(true)
		c.time -= t0
		c.erase("_uid")
		clipboard.append(c)
	if cut:
		delete_uids(uids, "cut")
	flash("%d notes %s — Ctrl+V to paste at the cursor"
		%[clipboard.size(), "cut" if cut else "copied"])
	main.sfx.play_ui("click")





func paste(advance: = false, at: = NAN) -> void :
	if clipboard.is_empty() and clipboard_fx.is_empty():
		flash("clipboard empty (copy a range first)")
		return
	var anchor: = snap(t if is_nan(at) else at)
	if clipboard.is_empty():



		push_undo("paste event" if clipboard_fx.size() == 1
			else "paste %d events" % clipboard_fx.size())
		sel_fx_uid = -1
		sel_fx_extra.clear()
		sel_uids.clear()
		var block_end: = anchor
		for src in clipboard_fx:
			var ev: Dictionary = (src as Dictionary).duplicate(true)
			ev["time"] = snappedf(anchor + float(ev.get("time", 0.0)), 0.001)
			ev["_uid"] = _new_uid()
			fx_events.append(ev)
			if sel_fx_uid < 0:
				sel_fx_uid = int(ev._uid)
			else:
				sel_fx_extra.append(int(ev._uid))
			block_end = maxf(block_end, float(ev.time) + float(ev.get("len", 0.0)))
		if advance and block_end > anchor:
			t = clampf(snap(block_end), 0.0, _len)
			view_t = t
			time_changed.emit()
		mark_dirty()
		selection_changed.emit()
		if clipboard_fx.size() == 1:
			flash("event pasted at %s" % EdTheme.fmt_time(anchor))
		else:
			flash("%d events pasted at %s" % [clipboard_fx.size(), EdTheme.fmt_time(anchor)])
		main.sfx.play_ui("click")
		return
	push_undo("paste")
	var half_step: = beat_dur() / float(grid_div()) * 0.5
	var pasted: Array = []
	for c in clipboard:
		var tt: float = anchor + c.time
		if tt < 0.0 or tt > _len:
			continue
		var occupied: = false
		for n in notes:
			if absf(n.time - tt) > half_step:
				continue
			if EdTheme.is_aim_type(c.type) == EdTheme.is_aim_type(n.type)\
			and (EdTheme.is_aim_type(c.type) or n.lane == c.lane):
				occupied = true
				break
		if occupied:
			continue
		var note: Dictionary = (c as Dictionary).duplicate(true)
		note.time = tt
		note["_uid"] = _new_uid()
		notes.append(note)
		pasted.append(int(note._uid))
	_sort()
	sel_uids = pasted
	if advance and clipboard_len > 0.0:
		t = clampf(snap(anchor + clipboard_len), 0.0, _len)
		view_t = t
		time_changed.emit()
	mark_dirty()
	selection_changed.emit()
	flash("%d notes pasted at %s%s" % [pasted.size(), EdTheme.fmt_time(anchor), 
		" — cursor advanced, repeat to chain" if advance else ""])
	main.sfx.play_ui("click")






func nudge_velocity(delta_v: float) -> void :
	var uids: = target_uids()
	if uids.is_empty():
		flash("select notes or a range first")
		return
	push_undo("velocity (SV)")
	var newv: = 1.0
	for uid in uids:
		var n = note_by_uid(uid)
		if n == null:
			continue
		newv = clampf(float(n.get("v", 1.0)) + delta_v, 0.5, 2.0)
		n["v"] = newv
	mark_dirty()
	var lbl: = "faster" if newv > 1.001\
	else ("slower" if newv < 0.999 else "normal speed")
	flash("SV: x%.2f (%s) on %d note(s)" % [newv, lbl, uids.size()])
	main.sfx.play_ui("click")


func kiai_at(tt: float) -> int:
	for i in kiai.size():
		if tt >= kiai[i][0] and tt <= kiai[i][1]:
			return i
	return -1


var _kiai_pending: = -1.0

func kiai_pending() -> float:
	return _kiai_pending




func kiai_key(tt: = NAN) -> void :
	var at: = t if is_nan(tt) else tt
	var idx: = kiai_at(at)
	if idx >= 0:
		push_undo("delete kiai section")
		kiai.remove_at(idx)
		mark_dirty()
		flash("kiai section deleted")
		return
	if _kiai_pending < 0.0:
		_kiai_pending = at
		flash("kiai start placed — K again at the end of the drop, Esc to cancel")
		chart_changed.emit()
	else:
		push_undo("kiai section")
		kiai.append([minf(_kiai_pending, at), maxf(_kiai_pending, at)])
		kiai.sort_custom( func(a, b): return a[0] < b[0])
		_kiai_pending = -1.0
		mark_dirty()
		flash("kiai section created")
	main.sfx.play_ui("click")


func kiai_from_zone() -> void :
	if selection.is_empty():
		flash("close a range first (select tool, Shift+click)")
		return
	push_undo("kiai section")
	kiai.append([selection[0], selection[1]])
	kiai.sort_custom( func(a, b): return a[0] < b[0])
	mark_dirty()
	flash("kiai section on the range")


func remove_kiai(i: int) -> void :
	if i < 0 or i >= kiai.size():
		return
	push_undo("delete kiai section")
	kiai.remove_at(i)
	mark_dirty()









func record_note(type: String, screen_pos: = Vector2(NAN, NAN)) -> void :
	var step: = beat_dur() / float(grid_div())
	var tt: = clampf(snap(t + rec_offset), 0.0, _len)
	var lane: = rec_lane
	for _try in 3:
		var blocker = null
		for n in notes:
			if absf(n.time - tt) > step * 0.5:
				continue
			if EdTheme.is_aim_type(type) == EdTheme.is_aim_type(n.type)\
			and (EdTheme.is_aim_type(type) or n.lane == lane):
				blocker = n
				break
		if blocker == null:
			break
		if _rec_pass.has(int(blocker.get("_uid", -1))):
			tt = clampf(tt + step, 0.0, _len)
		else:
			return


	if _rec_pass.is_empty():
		push_undo("recording pass")
	var note: = {"time": tt, "lane": lane, "type": type, "_uid": _new_uid()}
	if EdTheme.is_aim_type(type):
		var p: = default_aim_pos(tt)
		if not is_nan(screen_pos.x):
			p = clamp_playfield(screen_pos)
		note["x"] = p.x
		note["y"] = p.y
	notes.append(note)
	_rec_pass.append(int(note._uid))
	_sort()
	dirty = true
	rec_flash = 1.0
	chart_changed.emit()


func toggle_recording() -> void :
	recording = not recording
	flash("RECORDING " + ("armed — start playback and play!"
		if recording else "off"))
	view_changed.emit()




func flash(msg: String) -> void :
	status = msg
	_status_until = Time.get_ticks_msec() + 3000
	status_changed.emit()


func set_hint(msg: String) -> void :
	if hint == msg:
		return
	hint = msg
	status_changed.emit()










func diff_keys() -> Array:
	if not draft.is_empty():
		var out: Array = []
		for d in draft.meta.difficulties:
			out.append(String(d.key))
		return out
	if map_track == "":
		return []
	return MapLibrary.diffs_of(map_track).keys()





func can_manage_diffs() -> bool:
	return not draft.is_empty() or can_write()




func can_write() -> bool:
	return not read_only and MapLibrary.is_user_map(map_track)




func guard_unsaved(what: String, then: Callable) -> void :
	if not dirty or read_only:
		then.call()
		return
	EdDialog.choices(overlay_host(), self, "UNSAVED CHANGES", 
		"This difficulty has changes that are not written to disk.\n"
		+ "What should happen before " + what + "?", 
		[{"text": "Cancel", "id": ""}, 
		{"text": "Discard", "id": "discard", "accent": EdTheme.RED}, 
		{"text": "Save first", "id": "save", "accent": EdTheme.MINT}], 
		func(id: String):
			if id == "save":
				save()
				if not dirty:
					then.call()
			elif id == "discard":
				dirty = false
				then.call())


func request_switch_diff(key: String) -> void :
	if key == diff_key:
		return
	guard_unsaved("switching difficulty", _do_switch_diff.bind(key))


func _do_switch_diff(key: String) -> void :
	var path: = diff_path(key)
	if path == "":
		flash("difficulty not found")
		return
	if playing:
		toggle_play()
	chart_path = path
	diff_key = key
	_undo.clear()
	_redo.clear()
	clear_selection()
	chain_building_uid = -1
	_load()
	dirty = false
	_quit_armed = false
	flash("switched to %s" % diff_label())
	chart_changed.emit()
	selection_changed.emit()
	time_changed.emit()
	view_changed.emit()







func new_diff_dialog(duplicate: bool) -> void :
	if not can_manage_diffs():
		flash("difficulties can only be managed on your own maps")
		return
	guard_unsaved("creating a difficulty", func(): _new_diff_form(duplicate))


func _new_diff_form(duplicate: bool) -> void :


	if is_draft():
		save()
		if is_draft():
			return
	EdDialog.form(overlay_host(), self, 
		"DUPLICATE DIFFICULTY" if duplicate else "NEW DIFFICULTY", 
		[{"key": "name", "label": "NAME", "value": "", 
			"placeholder": "Hard, Another, Insane...", 
			"hint": "Shown on the map card. Must be unique in this map."}, 
		{"key": "level", "label": "LEVEL", "value": "0", 
			"placeholder": "0", 
			"hint": "The constant you announce. The game also computes "
			+ "its own rating."}], 
		"Create", 
		func(id: String, v: Dictionary):
			if id == "ok":
				_create_diff(String(v.name).strip_edges(), 
					float(String(v.level)), duplicate), 
		func(v: Dictionary) -> String:
			var n: = String(v.get("name", "")).strip_edges()
			if n == "":
				return "The difficulty needs a name."
			if MapLibrary.diff_name_taken(map_meta, n):
				return "This map already has a difficulty called \"%s\"." % n
			return "")


func _create_diff(name: String, level: float, duplicate: bool) -> void :
	var key: String = MapLibrary.add_difficulty(map_meta, name, level)
	if not MapLibrary.save_meta(map_track, map_meta):
		flash("SAVE FAILED! could not write map.json")
		return
	map_meta = MapLibrary.meta_of(map_track)
	if not duplicate:
		notes = []
		kiai = []
		fx_events = []
	diff_key = key
	chart_path = diff_path(key)
	_undo.clear()
	_redo.clear()
	clear_selection()
	dirty = true
	save()
	flash("created difficulty %s" % name)
	chart_changed.emit()
	view_changed.emit()


func rename_diff_dialog() -> void :
	if not can_write():
		flash("difficulties can only be managed on your own maps")
		return
	EdDialog.form(overlay_host(), self, "DIFFICULTY SETTINGS", 
		[{"key": "name", "label": "NAME", 
			"value": MapLibrary.diff_name(map_track, diff_key)}, 
		{"key": "level", "label": "LEVEL", 
			"value": "%.1f" % MapLibrary.diff_level(map_track, diff_key), 
			"hint": "The constant you announce, independent of the "
			+ "computed rating."}], 
		"Apply", 
		func(id: String, v: Dictionary):
			if id != "ok":
				return
			var n: = String(v.name).strip_edges()
			MapLibrary.rename_difficulty(map_track, diff_key, n, 
				float(String(v.level)))
			map_meta = MapLibrary.meta_of(map_track)
			flash("difficulty renamed to %s" % n)
			chart_changed.emit()
			view_changed.emit(), 
		func(v: Dictionary) -> String:
			var n: = String(v.get("name", "")).strip_edges()
			if n == "":
				return "The difficulty needs a name."
			if MapLibrary.diff_name_taken(map_meta, n, diff_key):
				return "This map already has a difficulty called \"%s\"." % n
			return "")


func delete_diff_dialog() -> void :
	if not can_write():
		flash("difficulties can only be managed on your own maps")
		return
	if diff_keys().size() <= 1:
		flash("a map needs at least one difficulty")
		return
	var name: = diff_label()
	EdDialog.confirm(overlay_host(), self, "DELETE DIFFICULTY", 
		"\"%s\" and its %d notes will be erased from disk.\n"
		%[name, notes.size()] + "This cannot be undone.", 
		"Delete", func(id: String):
			if id != "ok":
				return
			var others: Array = diff_keys()
			others.erase(diff_key)
			if not MapLibrary.remove_difficulty(map_track, diff_key):
				flash("could not delete this difficulty")
				return
			map_meta = MapLibrary.meta_of(map_track)
			dirty = false
			_do_switch_diff(String(others[0]))
			flash("deleted %s" % name), true)




func song_meta_dialog() -> void :
	if not can_write():
		flash("song metadata is only editable on your own maps")
		return
	EdDialog.form(overlay_host(), self, "SONG METADATA", 
		[{"key": "title", "label": "TITLE", "value": String(map_meta.title)}, 
		{"key": "artist", "label": "ARTIST", "value": String(map_meta.artist)}, 
		{"key": "title_r", "label": "TITLE (ROMAN.)", 
			"value": String(map_meta.title_romanised), 
			"hint": "Optional — used for display and search."}, 
		{"key": "artist_r", "label": "ARTIST (ROMAN.)", 
			"value": String(map_meta.artist_romanised)}, 
		{"key": "creator", "label": "MAPPER", 
			"value": String(map_meta.creator)}, 
		{"key": "preview", "label": "PREVIEW AT", 
			"value": "%.2f" % float(map_meta.preview_time), 
			"hint": "Seconds. The menu starts the song here."}], 
		"Apply", 
		func(id: String, v: Dictionary):
			if id != "ok":
				return
			map_meta["title"] = String(v.title).strip_edges()
			map_meta["artist"] = String(v.artist).strip_edges()
			map_meta["title_romanised"] = String(v.title_r).strip_edges()
			map_meta["artist_romanised"] = String(v.artist_r).strip_edges()
			map_meta["creator"] = String(v.creator).strip_edges()
			map_meta["preview_time"] = maxf(0.0, float(String(v.preview)))
			MapLibrary.save_meta(map_track, map_meta)
			map_meta = MapLibrary.meta_of(map_track)
			flash("song metadata saved")
			chart_changed.emit(), 
		func(v: Dictionary) -> String:
			return "" if String(v.get("title", "")).strip_edges() != ""\
			else "The song needs a title.")










func map_images_dialog(at: Vector2) -> void :



	if is_draft():
		save()
		if is_draft():
			return
	if not can_write():
		flash("map images are only editable on your own maps")
		return
	var cover: = String(map_meta.get(MapLibrary.IMG_COVER, ""))
	var bg: = String(map_meta.get(MapLibrary.IMG_BACKGROUND, ""))
	var video: = String(map_meta.get("video", ""))
	EdMenu.open(overlay_host(), [
		{"text": "COVER — shown in the menus", "id": "", "disabled": true}, 
		{"text": "Choose a cover image...", "id": "set:cover", 
			"accent": EdTheme.GOLD}, 
		{"text": "Remove the cover", "id": "clear:cover", 
			"accent": EdTheme.RED, "disabled": cover == "", "hint": cover}, 
		{"sep": true}, 
		{"text": "BACKGROUND — behind the gameplay", "id": "", "disabled": true}, 
		{"text": "Choose a background image...", "id": "set:background", 
			"accent": EdTheme.VIOLET}, 
		{"text": "Use the cover as background", "id": "cover_as_bg", 
			"disabled": cover == ""}, 
		{"text": "No background (animated only)", "id": "clear:background", 
			"accent": EdTheme.RED, "disabled": bg == "", "hint": bg}, 
		{"sep": true}, 
		{"text": "VIDEO — behind the gameplay (local only, not published)", "id": "", 
			"disabled": true}, 
		{"text": "Choose a video (.ogv, or mp4/webm via VLC)...", "id": "set:video", 
			"accent": EdTheme.CYAN}, 
		{"text": "Video start delay...", "id": "video_offset", "disabled": video == "", 
			"hint": "%.2f s" % float(map_meta.get("video_offset", 0.0))}, 
		{"text": "Remove the video", "id": "clear:video", 
			"accent": EdTheme.RED, "disabled": video == "", "hint": video}, 
	], at, font, _map_image_pick, 300)


func _map_image_pick(id: String) -> void :
	if id == "":
		return
	if id == "cover_as_bg":
		_apply_map_image(MapLibrary.IMG_BACKGROUND, 
			MapLibrary.image_path(map_track, MapLibrary.IMG_COVER))
		return
	if id == "video_offset":
		_video_offset_dialog()
		return
	if id == "set:video":
		EdBrowser.open(overlay_host(), font, font_display, 
			PackedStringArray(MapLibrary.VIDEO_SRC_EXT), "CHOOSE A VIDEO", 
			EdTheme.CYAN, _apply_map_video)
		return
	if id == "clear:video":
		if MapLibrary.clear_video(map_track):
			_after_map_image("removed the video")
		return
	var parts: = id.split(":")
	if parts.size() != 2:
		return
	if parts[0] == "clear":
		if MapLibrary.clear_image(map_track, parts[1]):
			_after_map_image("removed the " + parts[1])
		return
	EdBrowser.open(overlay_host(), font, font_display, 
		PackedStringArray(MapLibrary.IMAGE_EXT), 
		"CHOOSE A " + parts[1].to_upper(), 
		EdTheme.GOLD if parts[1] == MapLibrary.IMG_COVER else EdTheme.VIOLET, 
		_apply_map_image.bind(parts[1]))




func _apply_map_image(path: String, kind: String) -> void :
	if path == "" or not MapLibrary.set_image(map_track, kind, path):
		flash("could not read this image")
		return
	_after_map_image("%s set" % kind)



	if kind == MapLibrary.IMG_COVER\
	and String(map_meta.get(MapLibrary.IMG_BACKGROUND, "")) == "":
		EdDialog.confirm(overlay_host(), self, "BACKGROUND IMAGE", 
			"Use this image behind the gameplay too?\n"
			+ "Without it, the animated background plays alone — which is\n"
			+ "often easier to read.", "Use it too", 
			func(cid: String):
				if cid == "ok":
					_apply_map_image(
						MapLibrary.image_path(map_track, 
							MapLibrary.IMG_COVER), 
						MapLibrary.IMG_BACKGROUND))




const VLC_PATHS: = ["C:/Program Files/VideoLAN/VLC/vlc.exe", 
	"C:/Program Files (x86)/VideoLAN/VLC/vlc.exe"]
var _video_busy: = false


func _vlc_path() -> String:
	for p in VLC_PATHS:
		if FileAccess.file_exists(p):
			return p
	return ""






func _apply_map_video(path: String) -> void :
	if path == "":
		return
	if _video_busy:
		flash("a video is already being converted — wait for it to finish")
		return
	var ext: = path.get_extension().to_lower()
	if ext == "ogv":
		if MapLibrary.set_video(map_track, path):
			_after_map_image("video set (local only — it is not published)")
		else:
			flash("could not copy this video")
		return
	var vlc: = _vlc_path()
	if vlc == "":
		flash("VLC not found — convert the video to .ogv (Theora) first, then pick it")
		return





	var out: = OS.get_temp_dir().path_join("meloa_video_convert.ogv").replace("\\", "/")
	DirAccess.remove_absolute(out)
	_video_busy = true
	var track: = map_track







	var src_win: = path.replace("/", "\\")
	var log_path: = ProjectSettings.globalize_path("user://vlc_last.log")
	var args: = PackedStringArray(["-I", "dummy", "--file-logging", 
		"--logfile=%s" % log_path, "--log-verbose=1", src_win, 
		":sout=#transcode{vcodec=theo,venc=theora{quality=5},width=960,"
		+ "height=540,acodec=none}:std{access=file,mux=ogg,dst=\"%s\"}" % out, 
		"vlc://quit"])
	var pid: = OS.create_process(vlc, args)
	if pid <= 0:
		_video_busy = false
		flash("could not start VLC")
		return


	if playing:
		stop_play()
	var cancelled: = [false]
	var busy = EdBusy.open(overlay_host(), font, font_display, "CONVERTING VIDEO", 
		"VLC is encoding %s to Theora (960x540)…" % path.get_file(), 
		func():
			cancelled[0] = true
			OS.kill(pid))
	busy.set_message("VLC is encoding %s to Theora (960x540)…" % path.get_file(), 
		"A full clip takes a few minutes. Local only — the video is not published.")
	while OS.is_process_running(pid):
		await get_tree().create_timer(0.25).timeout
		if is_instance_valid(busy) and FileAccess.file_exists(out):
			var f: = FileAccess.open(out, FileAccess.READ)
			if f != null:
				busy.set_message("VLC is encoding %s to Theora (960x540)…" % path.get_file(), 
					"%.1f MB written so far — Esc to cancel" % (f.get_length() / 1048576.0))
				f.close()
	busy.close()
	_video_busy = false
	if cancelled[0]:
		DirAccess.remove_absolute(out)
		flash("video conversion cancelled")
		return
	if not FileAccess.file_exists(out):
		flash("video conversion failed (VLC exit %s) — see user://vlc_last.log"
			%str(OS.get_process_exit_code(pid)))
		return
	if map_track != track or not MapLibrary.is_user_map(track):
		DirAccess.remove_absolute(out)
		flash("video converted, but the map changed meanwhile — pick it again")
		return
	var ok: = MapLibrary.set_video(track, out)
	DirAccess.remove_absolute(out)
	if ok:
		_after_map_image("video converted and set (local only — it is not published)")
	else:
		flash("could not copy the converted video")




func _video_offset_dialog() -> void :
	var cur: = float(map_meta.get("video_offset", 0.0))
	EdDialog.form(overlay_host(), self, "VIDEO START DELAY", [
		{"key": "off", "label": "DELAY (s)", "value": "%.2f" % cur, "numeric": true, 
			"hint": "Song time at which the video starts playing. 0 = with the music."}, 
	], "Apply", func(id: String, values: Dictionary):
		if id != "ok":
			return
		var off: = String(values.get("off", "0")).replace(",", ".").to_float()
		if MapLibrary.set_video_offset(map_track, maxf(off, 0.0)):
			_after_map_image("video starts at %.2f s" % maxf(off, 0.0)))


func _after_map_image(msg: String) -> void :
	map_meta = MapLibrary.meta_of(map_track)


	if main != null:
		main._scan_charts()
	flash(msg)
	chart_changed.emit()






func toggle_bookmark() -> void :
	var tol: = maxf(beat_dur() / float(grid_div()) * 0.5, 0.02)
	for i in bookmarks.size():
		if absf(float(bookmarks[i]) - t) <= tol:
			push_undo("bookmark")
			bookmarks.remove_at(i)
			mark_dirty()
			flash("bookmark removed")
			return
	push_undo("bookmark")
	bookmarks.append(t)
	bookmarks.sort()
	mark_dirty()
	flash("bookmark at %s (%d total)" % [EdTheme.fmt_time(t), bookmarks.size()])



func seek_bookmark(dir: int) -> void :
	if bookmarks.is_empty():
		flash("no bookmark yet - Ctrl+B places one")
		return
	var best: = -1.0
	for b in bookmarks:
		var bt: = float(b)
		if dir > 0 and bt > t + 0.001:
			best = bt
			break
		if dir < 0 and bt < t - 0.001:
			best = bt
	if best < 0.0:
		flash("no bookmark %s here" % ("after" if dir > 0 else "before"))
		return
	seek_to(best, false)



func set_preview_here() -> void :
	if not can_write():
		flash("preview time is only editable on your own maps")
		return
	map_meta["preview_time"] = t
	MapLibrary.save_meta(map_track, map_meta)
	map_meta = MapLibrary.meta_of(map_track)
	flash("menu preview starts at %s" % EdTheme.fmt_time(t))




func playtest() -> void :
	if playing:
		toggle_play()



	var was_dirty: = dirty or is_draft()
	save()
	if is_draft() or dirty:
		flash("TEST CANCELLED — the map could not be saved")
		return
	if was_dirty:
		flash("AUTO-SAVED — testing…")
	main._playtest_from(t)


func request_quit() -> void :
	if dirty and not _quit_armed and not read_only:
		_quit_armed = true
		flash("unsaved! Ctrl+S, or Esc again to discard")
		return
	_player.stop()
	main._exit_editor()













func _key_of(event: InputEventKey) -> int:
	return event.keycode if event.keycode != 0 else event.physical_keycode





func _unhandled_input(event: InputEvent) -> void :
	if not (event is InputEventKey and event.pressed):
		return
	var key: = _key_of(event)
	if event.echo and key not in [KEY_LEFT, KEY_RIGHT, 
			KEY_B, KEY_N, KEY_EQUAL, KEY_MINUS, KEY_KP_ADD, KEY_KP_SUBTRACT]:
		return
	var ctrl: bool = event.ctrl_pressed
	var shift: bool = event.shift_pressed
	match key:
		KEY_ESCAPE:
			if shortcuts.help_open():
				shortcuts.close_help()
			elif _kiai_pending >= 0.0:




				_kiai_pending = -1.0
				flash("kiai marker cancelled")
				chart_changed.emit()
			elif chain_building_uid >= 0:
				chain_building_uid = -1
				flash("chain finished")
				selection_changed.emit()
			elif timeline.cancel_drag() or canvas.view.cancel_drag():
				flash("gesture cancelled")
			elif not sel_uids.is_empty() or sel_fx_uid >= 0 or sel_a >= 0.0\
			or not selection.is_empty():
				clear_selection()
				flash("selection cleared")
			else:
				request_quit()
		KEY_SPACE:
			toggle_play()
		KEY_S:
			if ctrl:
				save()
			else:
				set_tool("select")
		KEY_1, KEY_KP_1:
			set_tool("parry")
		KEY_2, KEY_KP_2:
			set_tool("dodge")
		KEY_3, KEY_KP_3:
			set_tool("click")
		KEY_4, KEY_KP_4:
			set_tool("sliderm")
		KEY_5, KEY_KP_5:
			set_tool("sliderg")
		KEY_6, KEY_KP_6:
			set_tool("clickx")
		KEY_M:
			set_tool("move")
		KEY_E:
			set_tool("erase")
		KEY_H, KEY_F1:
			shortcuts.toggle_help()
		KEY_Z:
			if ctrl:
				undo()
		KEY_Y:
			if ctrl:
				redo()
		KEY_D:
			if ctrl:
				duplicate_uids(target_uids())
			else:
				set_tool("drawpath")
		KEY_C:
			if ctrl:
				copy_selection(false)
			elif recording and playing:
				record_note("parry")
		KEY_X:
			if ctrl:
				copy_selection(true)
			elif recording and playing:
				record_note("parry")
		KEY_V:
			if ctrl:
				paste(shift)
		KEY_W:
			if recording and playing:
				record_note("dodge")
		KEY_A:
			if ctrl:
				select_uids(notes.map( func(n): return int(n._uid)))
				flash("%d notes selected" % sel_uids.size())
			else:
				zone_key(snap(t))
		KEY_DELETE, KEY_BACKSPACE:
			delete_selection()
		KEY_EQUAL, KEY_KP_ADD:
			set_zoom(zoom * 1.25)
		KEY_MINUS, KEY_KP_SUBTRACT:
			set_zoom(zoom / 1.25)
		KEY_G:
			push_undo("grid anchor")
			grid_anchor = t
			mark_dirty()
			flash("grid anchor snapped to %.3f s" % grid_anchor)
		KEY_B:
			if ctrl:
				toggle_bookmark()
			else:
				push_undo("BPM")
				bpm = maxf(20.0, bpm - (1.0 if shift else 0.05))
				mark_dirty()
		KEY_BRACKETLEFT:
			seek_bookmark(-1)
		KEY_BRACKETRIGHT:
			seek_bookmark(1)
		KEY_N:
			push_undo("BPM")
			bpm += 1.0 if shift else 0.05
			mark_dirty()
		KEY_K:
			kiai_key()
		KEY_R:
			toggle_recording()
		KEY_T:
			playtest()
		KEY_COMMA:
			rec_offset -= 0.005
			flash("recording offset: %+.0f ms" % (rec_offset * 1000.0))
		KEY_PERIOD:
			rec_offset += 0.005
			flash("recording offset: %+.0f ms" % (rec_offset * 1000.0))
		KEY_HOME:
			seek_to(0.0)
		KEY_END:
			seek_to(_len)
		KEY_LEFT:
			seek(-4.0 * grid_div())
		KEY_RIGHT:
			seek(4.0 * grid_div())
		KEY_UP:
			if ctrl:
				nudge_velocity(0.15)
			else:
				seek(1.0)
		KEY_DOWN:
			if ctrl:
				nudge_velocity(-0.15)
			else:
				seek(-1.0)
		KEY_U:
			push_undo("map velocity")
			chart_vel = clampf(chart_vel - 0.05, 0.6, 2.0)
			mark_dirty()
			flash("MAP velocity: x%.2f (the game's AR)" % chart_vel)
		KEY_I:
			push_undo("map velocity")
			chart_vel = clampf(chart_vel + 0.05, 0.6, 2.0)
			mark_dirty()
			flash("MAP velocity: x%.2f (the game's AR)" % chart_vel)
		_:
			return
	get_viewport().set_input_as_handled()
