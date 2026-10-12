extends Control








const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

var ed
var _modal: Control


func _ready() -> void :

	visible = false
	custom_minimum_size = Vector2.ZERO
	mouse_filter = Control.MOUSE_FILTER_IGNORE




func help_open() -> bool:
	return _modal != null and is_instance_valid(_modal)


func close_help() -> void :
	if help_open():
		_modal.queue_free()
	_modal = null


func toggle_help() -> void :
	if help_open():
		close_help()
		return
	_modal = HelpModal.new()
	_modal.ed = ed
	ed.overlay_host().add_child(_modal)




class HelpModal extends Control:
	const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

	var ed
	var _filter: = ""
	var _search: LineEdit

	const GROUPS: = [
		["TRANSPORT", [
			["Space", "play / pause"], 
			["Wheel", "±1 grid division"], 
			["Shift + wheel", "±1 beat"], 
			["Up / Down", "±1 division"], 
			["Left / Right", "±1 bar"], 
			["Home / End", "start / end of the track"], 
			["Click overview", "jump there · drag the frame"], 
			["+ / -  ·  Ctrl+wheel", "zoom (AUTO grid follows it)"], 
			["[ / ]", "previous / next bookmark"], 
		]], 
		["PLACING NOTES — TIMELINE SAYS WHEN, STAGE SAYS WHERE", [
			["1 / 2", "white · dodge (red)"], 
			["3 / 6", "aim (yellow) · aim counter (1 target, N hits)"], 
			["4 / 5", "white hold · yellow slider"], 
			["Click a lane", "lane note there, at the playhead"], 
			["Click anywhere", "aim note at that exact spot"], 
			["Drag a hold's end", "in the TIMELINE or on the STAGE: its duration"], 
			["D  + drag", "redraw a selected yellow slider path"], 
			["Playhead + click", "a chain step lands ON the playhead"], 
			["Alt + click", "place a WHITE note, any tool"], 
			["Right click", "context menu"], 
			["Click the same type again", "on the note itself: removes it"], 
		]], 
		["SELECTION", [
			["S / M / E / D", "select · move · erase · draw path"], 
			["Click", "select a note (stage or timeline)"], 
			["Shift / Ctrl + click", "add to / remove from selection (notes AND events)"], 
			["Drag empty space", "selection box"], 
			["A  ·  Shift+click", "range marker (two = a range)"], 
			["Ctrl+A", "select everything"], 
			["Ctrl+C / Ctrl+X", "copy / cut (several events keep their spacing)"], 
			["Ctrl+V", "paste at the cursor"], 
			["Ctrl+Shift+V", "CHAIN paste (cursor advances)"], 
			["Ctrl+D", "duplicate one beat later"], 
			["Del / Backspace", "delete"], 
			["Esc", "deselect · cancel the gesture · quit"], 
		]], 
		["MOVING A NOTE", [
			["Drag in the TIMELINE", "moves it in TIME (snapped)"], 
			["Drag an aim on the STAGE", "moves it in X / Y"], 
			["Drag a lane note on the STAGE", "changes its LANE"], 
			["Shift while dragging", "snap to center, lanes, neighbors"], 
			["Ratio buttons (top right)", "preview another screen — read-only"], 
		]], 
		["AIM COUNTER (GHOST CIRCLES)", [
			["6, then click the stage", "creates the first point"], 
			["Each further click", "adds step 1, 2, 3... in rhythm"], 
			["Drag a step", "moves that point"], 
			["Right click a step", "removes it"], 
			["Esc", "finishes the chain"], 
		]], 
		["SLIDER PATH (YELLOW)", [
			["Select a slider", "its handles appear on the stage"], 
			["Click the path", "adds a corner there and grabs it"], 
			["Drag a handle", "moves that corner"], 
			["Right click a handle", "removes it (never the two ends)"], 
			["Right click > LINE", "flatten to one segment (zigzag base)"], 
			["Right click > ARC", "restore the automatic curve"], 
		]], 
		["GRID & TEMPO", [
			["G", "snap the grid anchor to the cursor"], 
			["B / N", "BPM -/+ 0.05 (Shift: ±1)"], 
			["U / I", "MAP velocity ±0.05 (the game's AR)"], 
			["Ctrl+Up / Ctrl+Down", "SV of the selection ±0.15"], 
			["K", "kiai marker (two presses = section)"], 
			["Ctrl+B", "place / remove a bookmark"], 
		]], 
		["MAP & DIFFICULTIES", [
			["Difficulty chip", "top left — switch / create / rename"], 
			["Song metadata", "same menu — title, artist, mapper"], 
			["Menu preview", "same menu — where the song starts"], 
			["PUBLISH MAP", "share the map online (account required)"], 
		]], 
		["RECORDING", [
			["R", "arm / disarm, then Space"], 
			["X / C", "white note on hovered lane"], 
			["W", "dodge"], 
			["Click the stage", "aim note at that position"], 
			[", / .", "latency offset ±5 ms"], 
		]], 
		["FILE & TEST", [
			["Ctrl+S", "save"], 
			["Ctrl+Z / Ctrl+Y", "undo / redo"], 
			["T", "save + test play from here"], 
			["Chart JSON", "☰ menu — edit, paste or import a chart"], 
			["H  ·  F1", "this reference"], 
			["Esc", "quit (twice if unsaved)"], 
		]], 
	]

	func _init() -> void :
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_STOP
		z_index = 90

	func _ready() -> void :
		var r: = _panel_rect()
		_search = LineEdit.new()
		_search.placeholder_text = "Search a shortcut..."
		EdTheme.style_line_edit(_search, ed.font, EdTheme.S_BODY)
		_search.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_search.position = r.position + Vector2(24, 46)
		_search.size = Vector2(240, 22)
		_search.text_changed.connect( func(txt):
			_filter = txt.to_lower()
			queue_redraw())
		add_child(_search)
		var close: = EdTheme.text_button("  CLOSE  ", "Esc", Color.TRANSPARENT, 
			ed.font, EdTheme.S_SMALL)
		close.position = r.end - Vector2(86, r.size.y - 44)
		close.size = Vector2(62, 22)
		close.pressed.connect( func(): ed.shortcuts.close_help())
		add_child(close)
		_search.grab_focus()

	func _panel_rect() -> Rect2:
		var vs: = get_viewport_rect().size
		var w: = minf(vs.x - 60.0, 1160.0)
		var h: = minf(vs.y - 46.0, 660.0)
		return Rect2((vs - Vector2(w, h)) * 0.5, Vector2(w, h))

	func _gui_input(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed\
		and not _panel_rect().has_point(event.position):
			ed.shortcuts.close_help()
			accept_event()

	func _draw() -> void :
		var vs: = get_viewport_rect().size
		var r: = _panel_rect()
		draw_rect(Rect2(Vector2.ZERO, vs), Color(0, 0, 0.01, 0.74))
		draw_rect(r, Color(0.018, 0.024, 0.052, 0.99))
		draw_rect(r, Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 0.7), 
			false, 1.0)
		var f: Font = ed.font
		draw_string(ed.font_display, r.position + Vector2(24, 32), 
			"MAP EDITOR SHORTCUTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, 
			ed.main.neon(EdTheme.VIOLET, 1.15))
		draw_string(f, r.position + Vector2(284, 62), 
			"Everything here also exists as a button — keys only make it faster.", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_SMALL, Color(1, 1, 1, 0.32))









		const HEAD_H: = 22.0
		const GAP_H: = 6.0
		var groups: Array = []
		for grp in GROUPS:
			var rows: Array = []
			for row in grp[1]:
				if _filter == "" or String(row[0]).to_lower().contains(_filter)\
				or String(row[1]).to_lower().contains(_filter)\
				or String(grp[0]).to_lower().contains(_filter):
					rows.append(row)
			if not rows.is_empty():
				groups.append({"title": String(grp[0]), "rows": rows})
		if groups.is_empty():
			draw_string(f, r.position + Vector2(24, 120), "No shortcut matches.", 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_BODY, Color(1, 1, 1, 0.35))
			return

		var top: = r.position.y + 88.0
		var avail: float = r.end.y - top - 18.0








		var cols: = 2
		var row_h: = 18.0
		var placed: Array = []
		for c in [2, 3]:
			for rh in [18.0, 17.0, 16.0, 15.0, 14.0]:
				placed = _place(groups, c, rh, avail, HEAD_H, GAP_H)
				if not placed.is_empty():
					cols = c
					row_h = rh
					break
			if not placed.is_empty():
				break
		if placed.is_empty():


			cols = 3
			row_h = 14.0
			placed = _place(groups, cols, row_h, avail, HEAD_H, GAP_H, true)

		var colw: = (r.size.x - 48.0 - 12.0 * float(cols - 1)) / float(cols)
		var keyw: float = clampf(colw * 0.42, 96.0, 158.0)
		for item in placed:
			var g: Dictionary = item.group
			var x: float = r.position.x + 24.0 + float(item.col) * (colw + 12.0)
			var y: float = top + float(item.y)
			draw_string(f, Vector2(x, y + 12), String(g.title), 
				HORIZONTAL_ALIGNMENT_LEFT, colw, EdTheme.S_BODY, EdTheme.MINT)
			y += HEAD_H
			for row in g.rows:
				draw_string(f, Vector2(x, y + 11), String(row[0]), 
					HORIZONTAL_ALIGNMENT_LEFT, keyw - 6.0, EdTheme.S_SMALL, 
					EdTheme.GOLD)
				draw_string(f, Vector2(x + keyw, y + 11), String(row[1]), 
					HORIZONTAL_ALIGNMENT_LEFT, colw - keyw, EdTheme.S_SMALL, 
					Color(1, 1, 1, 0.72))
				y += row_h




	func _place(groups: Array, cols: int, row_h: float, avail: float, 
			head_h: float, gap_h: float, force: = false) -> Array:
		var out: Array = []
		var col: = 0
		var y: = 0.0
		for g in groups:
			var h: float = head_h + float(g.rows.size()) * row_h + gap_h
			if y > 0.0 and y + h > avail:
				col += 1
				y = 0.0
				if col >= cols and not force:
					return []
			out.append({"group": g, "col": mini(col, cols - 1), "y": y})
			y += h
		return out
