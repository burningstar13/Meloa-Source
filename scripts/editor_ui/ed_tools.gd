extends PanelContainer







const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")




const HINT_H: = 128

var ed
var _rows: Array = []
var _toggles: Array = []
var _zoom_lbl: Label
var _hint_lbl: Label
var _rec_row


func _ready() -> void :
	custom_minimum_size.x = 138
	EdTheme.skin_panel(self)
	_build()
	ed.tool_changed.connect(_refresh_tools)
	ed.view_changed.connect(_refresh_view)
	ed.status_changed.connect(_refresh_hint)
	_refresh_tools()
	_refresh_view()


func _build() -> void :
	var m: = MarginContainer.new()
	m.add_theme_constant_override("margin_left", 5)
	m.add_theme_constant_override("margin_right", 5)
	m.add_theme_constant_override("margin_top", 5)
	m.add_theme_constant_override("margin_bottom", 5)
	add_child(m)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	m.add_child(v)

	v.add_child(EdTheme.section("TOOLS", ed.font))


	_add_tool(v, "select", "select", "SELECT", "S", EdTheme.CYAN, 
		"Select\nClick a note, on the stage or in the timeline.\n"
		+ "Shift+click adds to the selection.\n\n"
		+ "Timeline drag = TIME. Stage drag = position, or lane.\n\n"
		+ "Shortcut: S")

	v.add_child(EdTheme.spacer(3))
	v.add_child(EdTheme.section("NOTES", ed.font))



	_add_tool(v, "parry", "circle", "WHITE", "1", Color(0.88, 0.92, 1.0), 
		"White note (parry)\nPlayhead in the timeline, then click a lane\n"
		+ "on the stage.\n\nShortcut: 1")
	_add_tool(v, "dodge", "diamond", "DODGE (RED)", "2", EdTheme.RED, 
		"Red dodge\nThe lane to AVOID at that instant.\n"
		+ "Same gesture: playhead, then a lane.\n\nShortcut: 2")
	_add_tool(v, "click", "target", "AIM (YELLOW)", "3", EdTheme.GOLD, 
		"Aim note (yellow)\nPlayhead, then click the stage where the\n"
		+ "player must aim. That click IS the position.\n\n"
		+ "Drag it to move it. Shift snaps to the center, the lanes and\n"
		+ "the neighbouring aim notes.\n\nShortcut: 3")
	_add_tool(v, "clickx", "chain", "AIM ×N", "6", EdTheme.GOLD, 
		"Counter target (ghost circles)\nONE target, SEVERAL clicks: it\n"
		+ "glides from step to step between hits.\n\n"
		+ "One click per step on the stage, Esc finishes. Drag a step to\n"
		+ "move it, right-click to remove it.\n\n"
		+ "A missed step costs HP and the combo, but the chain goes on.\n\n"
		+ "Shortcut: 6")
	_add_tool(v, "sliderm", "hold", "HOLD", "4", Color(0.88, 0.92, 1.0), 
		"White hold\nClick a lane: one beat long.\n"
		+ "Drag its right end in the timeline.\n\nShortcut: 4")
	_add_tool(v, "sliderg", "slider", "SLIDER", "5", EdTheme.GOLD, 
		"Yellow slider\nClick the stage: head there, one beat, automatic\n"
		+ "arc. Drag its right end in the timeline.\n\n"
		+ "ITS SHAPE IS YOURS: select it and the stage shows the path\n"
		+ "handles. Click the path to add a corner, right-click a handle\n"
		+ "to remove it, LINE (right-click) flattens it — that is how a\n"
		+ "zigzag is drawn.\n\nShortcut: 5")

	v.add_child(EdTheme.spacer(3))
	v.add_child(EdTheme.section("EDIT", ed.font))
	_add_tool(v, "move", "move", "MOVE", "M", EdTheme.VIOLET, 
		"Move\nDrag any note through time and from one lane to another.\n"
		+ "The whole gesture counts as a single Undo.\n\nShortcut: M")
	_add_tool(v, "drawpath", "slider", "DRAW PATH", "D", EdTheme.GOLD, 
		"Draw a slider path\nSelect a yellow slider, then HOLD and draw\n"
		+ "the shape you want on the stage. The whole path is replaced\n"
		+ "on release.\n\n"
		+ "The trace is resampled into evenly spaced handles: the shape\n"
		+ "stays yours, and you can still nudge it afterwards.\n\n"
		+ "Shortcut: D")
	_add_tool(v, "erase", "erase", "ERASE", "E", EdTheme.RED, 
		"Erase\nEach click deletes the note under the cursor.\n"
		+ "(Right-click also erases, whatever the tool.)\n\nShortcut: E")

	var g: = GridContainer.new()
	g.columns = 5
	g.add_theme_constant_override("h_separation", 2)
	g.add_theme_constant_override("v_separation", 2)
	v.add_child(g)
	_add_action(g, "cut", "CUT", "Cut the selection\nCtrl+X")
	_add_action(g, "copy", "COPY", "Copy the selection\nCtrl+C")
	_add_action(g, "paste", "PASTE", "Paste at the cursor\nCtrl+V  (Shift: chain paste)")
	_add_action(g, "dup", "DUPLICATE", "Duplicate one beat later\nCtrl+D")
	_add_action(g, "del", "DELETE", "Delete the selection\nDel")

	v.add_child(EdTheme.spacer(3))



	var disp: = EdTheme.make_section("DISPLAY", ed.font, 
		ed.ui_is_open("display"), "Zoom, layers, playhead follow")
	disp.toggled.connect( func(o): ed.ui_set_open("display", o))
	v.add_child(disp)
	var v2: = disp.body

	var zr: = HBoxContainer.new()
	zr.add_theme_constant_override("separation", 2)
	var zl: = EdTheme.make_label("ZOOM", EdTheme.S_SMALL, EdTheme.TXT_DIM, ed.font)
	zl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zr.add_child(zl)
	var zm: = EdTheme.text_button("–", "Zoom out (wider grid)\n-", Color.TRANSPARENT, 
		ed.font, EdTheme.S_BODY)
	zm.custom_minimum_size = Vector2(18, 17)
	zm.pressed.connect( func(): ed.set_zoom(ed.zoom / 1.25))
	zr.add_child(zm)
	_zoom_lbl = EdTheme.make_label("100%", EdTheme.S_SMALL, EdTheme.TXT, ed.font)
	_zoom_lbl.custom_minimum_size.x = 34
	_zoom_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zr.add_child(_zoom_lbl)
	var zp: = EdTheme.text_button("+", "Zoom in (finer grid)\n+", Color.TRANSPARENT, 
		ed.font, EdTheme.S_BODY)
	zp.custom_minimum_size = Vector2(18, 17)
	zp.pressed.connect( func(): ed.set_zoom(ed.zoom * 1.25))
	zr.add_child(zp)
	v2.add_child(zr)

	_add_toggle(v2, "show_approach", "LIVE APPROACH", 
		"Live approach\nNotes fall down the lanes and the approach rings\n"
		+ "shrink, exactly as the player will see them. Unchecked,\n"
		+ "the stage only shows what sits on the judgement line -\n"
		+ "calmer when you are placing positions by hand.")
	_add_toggle(v2, "show_fx", "CHOREO STRIP", 
		"Choreography\nShows the fx event strip at the bottom of the\n"
		+ "timeline: texts, lane moves, background, shakes.\n"
		+ "Right-click inside to add one, click to edit one.")
	_add_toggle(v2, "show_ghosts", "AIM GHOSTS", 
		"Aim ghosts\nThe previous and next aim notes appear as ghosts\n"
		+ "on the stage: you read the motion asked of the player.")
	_add_toggle(v2, "show_bars", "BAR LINES", 
		"Bar lines and numbering in the timeline.")
	_add_toggle(v2, "follow_playhead", "FOLLOW PLAYHEAD", 
		"During playback the view scrolls with the playhead. Unchecked,\n"
		+ "the view stays put and turns page by page.")

	v.add_child(EdTheme.spacer(3))
	_rec_row = ToolRow.new()
	_rec_row.setup(ed, "rec", "rec", "RECORD", "R", EdTheme.RED, 
		"Record mode\nMap WHILE PLAYING: arm it, start playback, then\n"
		+ "X / C = white on the hovered lane, W = dodge,\n"
		+ "click on the stage = aim note.\n\nShortcut: R")
	_rec_row.clicked.connect( func(_id): ed.toggle_recording())
	v.add_child(_rec_row)

	v.add_child(EdTheme.spacer(0, true))








	var hint_panel: = PanelContainer.new()
	hint_panel.add_theme_stylebox_override("panel", 
		EdTheme.flat(Color(0.018, 0.022, 0.045), EdTheme.LINE_SOFT, 4))
	hint_panel.custom_minimum_size.y = HINT_H
	hint_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	var hint_scroll: = ScrollContainer.new()
	hint_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	hint_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	hint_scroll.custom_minimum_size.y = HINT_H
	hint_panel.add_child(hint_scroll)
	_hint_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	_hint_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_hint_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL


	_hint_lbl.custom_minimum_size.x = 118
	hint_scroll.add_child(_hint_lbl)
	v.add_child(hint_panel)
	_refresh_hint()


func _add_tool(box: VBoxContainer, id: String, glyph: String, label: String, 
		key: String, accent: Color, hint: String) -> void :
	var r: = ToolRow.new()
	r.setup(ed, id, glyph, label, key, accent, hint)
	r.clicked.connect( func(tid): ed.set_tool(tid))
	box.add_child(r)
	_rows.append(r)


func _add_action(g: GridContainer, id: String, label: String, tip: String) -> void :
	var glyphs: = {"cut": "cut", "copy": "copy", "paste": "paste", "dup": "copy", 
		"del": "erase"}
	var b: = EdTheme.icon_button(String(glyphs[id]), "%s\n%s" % [label, tip.split("\n")[-1]], 
		Color.TRANSPARENT, 24, 9)
	b.pressed.connect( func(): _do_action(id))
	b.mouse_entered.connect( func(): ed.set_hint(tip))
	b.mouse_exited.connect( func(): ed.set_hint(""))
	g.add_child(b)


func _do_action(id: String) -> void :
	match id:
		"cut":
			ed.copy_selection(true)
		"copy":
			ed.copy_selection(false)
		"paste":
			ed.paste(Input.is_key_pressed(KEY_SHIFT))
		"dup":
			ed.duplicate_uids(ed.target_uids())
		"del":
			ed.delete_selection()


func _add_toggle(box: VBoxContainer, flag: String, label: String, hint: String) -> void :
	var r: = ToggleRow.new()
	r.setup(ed, flag, label, hint)
	box.add_child(r)
	_toggles.append(r)


func _refresh_tools() -> void :
	for r in _rows:
		r.set_active(ed.tool == r.id)


func _refresh_view() -> void :
	_zoom_lbl.text = "%d%%" % int(round(ed.zoom / 240.0 * 100.0))
	for r in _toggles:
		r.refresh()
	_rec_row.set_active(ed.recording)


func _refresh_hint() -> void :
	if ed.hint != "":
		_hint_lbl.text = ed.hint
		_hint_lbl.add_theme_color_override("font_color", EdTheme.TXT_DIM)
	else:
		_hint_lbl.text = "Hover a tool to see what it does.\n\n"\
		+ "Right-click anywhere for a context menu."
		_hint_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 0.22))






class ToolRow extends Control:
	const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

	signal clicked(id)

	var ed
	var id: = ""
	var label: = ""
	var key: = ""
	var accent: = Color.WHITE
	var hint: = ""
	var active: = false
	var _hover: = false
	var _glyph

	func setup(p_ed, p_id: String, glyph: String, p_label: String, p_key: String, 
			p_accent: Color, p_hint: String) -> void :
		ed = p_ed
		id = p_id
		label = p_label
		key = p_key
		accent = p_accent
		hint = p_hint
		tooltip_text = p_hint
		custom_minimum_size.y = 20
		mouse_filter = Control.MOUSE_FILTER_STOP
		_glyph = EdTheme.make_glyph(glyph, 7.0, p_accent)
		_glyph.position = Vector2(4, 3)
		_glyph.size = Vector2(14, 14)
		add_child(_glyph)

	func set_active(v: bool) -> void :
		if active == v:
			return
		active = v
		_glyph.color = accent if v else Color(accent.r, accent.g, accent.b, 0.55)
		_glyph.queue_redraw()
		queue_redraw()

	func _notification(what: int) -> void :
		if what == NOTIFICATION_MOUSE_ENTER:
			_hover = true
			ed.set_hint(hint)
			queue_redraw()
		elif what == NOTIFICATION_MOUSE_EXIT:
			_hover = false
			ed.set_hint("")
			queue_redraw()

	func _gui_input(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed\
		and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(id)
			accept_event()

	func _draw() -> void :
		var r: = Rect2(Vector2.ZERO, size)
		if active:
			draw_rect(r, Color(accent.r, accent.g, accent.b, 0.15))
			draw_rect(r, Color(accent.r, accent.g, accent.b, 0.45), false, 1.0)
			draw_rect(Rect2(0, 0, 2, size.y), accent)
		elif _hover:
			draw_rect(r, Color(1, 1, 1, 0.055))
		var f: Font = ed.font
		var col: Color = accent if active else (EdTheme.TXT if _hover else EdTheme.TXT_DIM)
		draw_string(f, Vector2(22, size.y * 0.5 + 4), label, 
			HORIZONTAL_ALIGNMENT_LEFT, size.x - 40, EdTheme.S_SMALL, col)
		if key != "":
			var kw: float = f.get_string_size(key, HORIZONTAL_ALIGNMENT_LEFT, -1, 
				EdTheme.S_MICRO).x
			draw_string(f, Vector2(size.x - 6 - kw, size.y * 0.5 + 4), key, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
				Color(1, 1, 1, 0.45) if active else Color(1, 1, 1, 0.22))



class ToggleRow extends Control:
	const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

	var ed
	var flag: = ""
	var label: = ""
	var hint: = ""
	var _hover: = false

	func setup(p_ed, p_flag: String, p_label: String, p_hint: String) -> void :
		ed = p_ed
		flag = p_flag
		label = p_label
		hint = p_hint
		tooltip_text = p_hint
		custom_minimum_size.y = 17
		mouse_filter = Control.MOUSE_FILTER_STOP

	func refresh() -> void :
		queue_redraw()

	func _notification(what: int) -> void :
		if what == NOTIFICATION_MOUSE_ENTER:
			_hover = true
			ed.set_hint(hint)
			queue_redraw()
		elif what == NOTIFICATION_MOUSE_EXIT:
			_hover = false
			ed.set_hint("")
			queue_redraw()

	func _gui_input(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed\
		and event.button_index == MOUSE_BUTTON_LEFT:
			ed.set_view_flag(flag, not bool(ed.get(flag)))
			ed.main.sfx.play_ui("click")
			accept_event()

	func _draw() -> void :
		var on: bool = bool(ed.get(flag))
		if _hover:
			draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.045))
		draw_string(ed.font, Vector2(4, size.y * 0.5 + 3.5), label, 
			HORIZONTAL_ALIGNMENT_LEFT, size.x - 34, EdTheme.S_MICRO, 
			EdTheme.TXT if on else Color(1, 1, 1, 0.3))

		var w: = 20.0
		var h: = 9.0
		var org: = Vector2(size.x - w - 4, (size.y - h) * 0.5)
		var col: Color = EdTheme.CYAN if on else Color(1, 1, 1, 0.16)
		draw_rect(Rect2(org, Vector2(w, h)), Color(col.r, col.g, col.b, 0.25 if on else 1.0))
		draw_rect(Rect2(org, Vector2(w, h)), Color(col.r, col.g, col.b, 0.7), false, 1.0)
		draw_circle(org + Vector2(w - h * 0.5 if on else h * 0.5, h * 0.5), 
			h * 0.34, col if on else Color(1, 1, 1, 0.35))
