extends PanelContainer










const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")
const EdFx = preload("res://scripts/editor_ui/ed_fx.gd")
const EdColorPicker = preload("res://scripts/editor_ui/ed_color_picker.gd")

var ed
var tab: = "note"
var _images: = {}
var _picker_session: = ""






class Swatch extends Control:
	var color: = Color(0, 0, 0, 0):
		set(v):
			color = v
			queue_redraw()
	var hovered: = false

	func _ready() -> void :
		mouse_entered.connect( func():
			hovered = true
			queue_redraw())
		mouse_exited.connect( func():
			hovered = false
			queue_redraw())

	func _draw() -> void :
		var r: = Rect2(Vector2.ZERO, size)
		var has: = color.a > 0.0
		var line: = Color(1, 1, 1, 0.55 if hovered else 0.22)
		draw_rect(r, Color(1, 1, 1, 0.05))
		if has:
			draw_rect(Rect2(2, 2, size.x - 12, size.y - 4), Color(color.r, color.g, color.b))
		else:

			var c: = Color(1.0, 0.36, 0.36, 0.7)
			draw_line(Vector2(4, 4), Vector2(size.x - 12, size.y - 4), c, 1.2)
			draw_line(Vector2(4, size.y - 4), Vector2(size.x - 12, 4), c, 1.2)
		draw_rect(r, line, false, 1.0)

		var cx: = size.x - 6.0
		var cy: = size.y * 0.5
		draw_line(Vector2(cx - 3, cy - 1.5), Vector2(cx, cy + 1.5), line, 1.4)
		draw_line(Vector2(cx, cy + 1.5), Vector2(cx + 3, cy - 1.5), line, 1.4)

var _tab_btns: = {}
var _body: VBoxContainer
var _fields: = {}
var _values: = {}
var _choices: = {}
var _bools: = {}
var _swatches: = {}
var _pending_choice: = ""
var _pending_choice_uid: = -1
var _lane_btn: Button
var _charge_head: Label
var _charge_tier: Label
var _axis_bars: = {}
var _signature: = ""




var _dest: VBoxContainer


func _ready() -> void :
	custom_minimum_size.x = 218
	EdTheme.skin_panel(self)
	var m: = MarginContainer.new()
	m.add_theme_constant_override("margin_left", 6)
	m.add_theme_constant_override("margin_right", 6)
	m.add_theme_constant_override("margin_top", 4)
	m.add_theme_constant_override("margin_bottom", 5)
	add_child(m)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	m.add_child(v)



	var ihead: = HBoxContainer.new()
	ihead.add_theme_constant_override("separation", 3)
	var ilbl: = EdTheme.section("INSPECTOR", ed.font)
	ilbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ilbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ihead.add_child(ilbl)
	var fold: = EdTheme.text_button("  ›  ", 
		"Fold the side panels away\nGives their width back to the timeline", 
		Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
	fold.custom_minimum_size = Vector2(20, 14)
	fold.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	fold.pressed.connect( func(): ed.ui_set_open("inspector", false))
	ihead.add_child(fold)
	v.add_child(ihead)
	var tabs: = HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 2)
	for e in [["note", "NOTE"], ["tempo", "TEMPO"], ["events", "EVENTS"]]:
		var b: = EdTheme.text_button(String(e[1]), "", Color.TRANSPARENT, ed.font, 
			EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var tid: = String(e[0])
		b.pressed.connect( func(): open_tab(tid))
		tabs.add_child(b)
		_tab_btns[tid] = b
	v.add_child(tabs)
	v.add_child(EdTheme.separator())

	var scroll: = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(scroll)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 3)
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_body)




	ed.selection_changed.connect(_sync)
	ed.chart_changed.connect(_sync)
	ed.view_changed.connect(_sync)
	ed.time_changed.connect(_on_time)
	_sync()





func _on_time() -> void :
	if tab == "events" and ed.selected_fx() == null:
		_sync()


func open_tab(name: String) -> void :
	tab = name
	_signature = ""
	_sync()







func _sig() -> String:
	var n = ed.focus_note()
	var fev = ed.selected_fx()


	var fx_part: = "-"
	if tab == "events":
		fx_part = "%d|%d|%d" % [ed.sel_fx_uid, ed.fx_events.size(), 
			int(ed.t * 0.25)] if fev == null else str(ed.sel_fx_uid)


	var chain: = 0
	if n != null and EdTheme.is_chain(String(n.type)):
		chain = ed.chain_steps(n).size()
	return "%s|%d|%s|%s|%d" % [tab, ed.sel_uids.size(), 
		String(n.type) if n != null else "-", fx_part, chain]















var _sync_queued: = false


func _sync() -> void :
	if _sync_queued:
		return
	_sync_queued = true
	_sync_now.call_deferred()


func _sync_now() -> void :
	_sync_queued = false
	if not is_inside_tree():
		return
	for tid in _tab_btns:
		EdTheme.style_button(_tab_btns[tid], 
			EdTheme.VIOLET if tid == tab else Color.TRANSPARENT, ed.font, 
			EdTheme.S_MICRO)
	var s: = _sig()
	if s != _signature:
		_signature = s
		_rebuild()
	_refresh_values()


func _rebuild() -> void :
	for c in _body.get_children():
		c.queue_free()
	_dest = _body
	_fields.clear()
	_values.clear()
	_choices.clear()
	_bools.clear()
	_swatches.clear()
	_images.clear()
	match tab:
		"tempo":
			_build_tempo()
		"events":
			_build_events()
		_:
			_build_note()




func _build_note() -> void :
	var n = ed.focus_note()
	if n == null:
		_build_map_summary()
		return
	if ed.sel_uids.size() > 1:
		_build_multi()
		return
	var type: = String(n.type)

	_head(EdTheme.type_label(type), EdTheme.accent_for(type))
	var tb: = EdTheme.text_button("  CHANGE TYPE  ", 
		"Converts the note, keeping its timing", Color.TRANSPARENT, 
		ed.font, EdTheme.S_MICRO)
	tb.pressed.connect(_type_menu)
	_body.add_child(tb)

	_sec("TIME")
	_field("time", "TIME", "%.3f" % float(n.time), "s")
	_value("beat", "BEAT")
	if EdTheme.has_duration(type):
		_field("duration", "LENGTH", "%.3f" % float(n.get("duration", 0.0)), "s")
		_value("beats", "THAT IS")

	if not EdTheme.is_aim_type(type):
		_sec("LANE")
		var lb: = EdTheme.text_button("  " + ["LEFT", "CENTER", "RIGHT"][clampi(
			int(n.lane), 0, 2)] + "  ", "Lane of the note", Color.TRANSPARENT, 
			ed.font, EdTheme.S_MICRO)
		lb.pressed.connect(_lane_menu)
		_body.add_child(lb)
		_lane_btn = lb
	elif type == "sliderg":





		_sec("PATH")
		_value("pathpts", "POINTS")
		_value("pathspan", "SPAN")
		var phint: = EdTheme.make_label(
			"Shape it on the stage: click the path to add a "
			+ "corner, drag a handle to move it, right-click one to "
			+ "remove it. LINE flattens it — that is how you draw a zigzag.", 
			EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
		phint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_body.add_child(phint)
	else:
		_sec("SCREEN POSITION")
		_field("x", "X", "", "%")
		_field("y", "Y", "", "%")
		var hint: = EdTheme.make_label(
			"Drag the target on the stage to place it.", 
			EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_body.add_child(hint)

	_sec("VELOCITY (SV)")
	_field("v", "SV", "", "x")
	var svrow: = HBoxContainer.new()
	svrow.add_theme_constant_override("separation", 2)
	for d in [-0.15, 0.15]:
		var b: = EdTheme.text_button("%+.2f" % d, "SV of the selection\nCtrl+Up / Ctrl+Down", 
			Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect( func(): ed.nudge_velocity(d))
		svrow.add_child(b)
	_body.add_child(svrow)

	if EdTheme.is_chain(type):
		_build_chain_editor(n)

	if type == "sliderg":
		_sec("PATH")
		_value("points", "POINTS")
		var rb: = EdTheme.text_button("  REGENERATE ARC  ", 
			"Redraws a smooth arc between head and tail", Color.TRANSPARENT, 
			ed.font, EdTheme.S_MICRO)
		rb.pressed.connect(_regen_arc)
		_body.add_child(rb)

	_body.add_child(EdTheme.spacer(4))
	_actions_row()





func _build_chain_editor(n: Dictionary) -> void :
	var steps: Array = ed.chain_steps(n)
	_sec("CHAIN — %d HIT%s" % [steps.size(), "S" if steps.size() > 1 else ""])
	var vs: Vector2 = ed.play_size()
	var uid: = int(n._uid)
	for i in steps.size():
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		var num: = EdTheme.make_label(str(steps.size() - i), EdTheme.S_SMALL, 
			EdTheme.GOLD, ed.font_display)
		num.custom_minimum_size.x = 16
		row.add_child(num)
		var p: Vector2 = steps[i][1]
		var idx: = i
		var b: = EdTheme.text_button("%s   %d%%,%d%%" % [
			EdTheme.fmt_time(float(steps[i][0])), 
			int(p.x / vs.x * 100.0), int(p.y / vs.y * 100.0)], 
			"Go to this step\n(drag it on the stage to place it)", 
			Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var st: = float(steps[i][0])
		b.pressed.connect( func(): ed.seek_to(st, false))
		row.add_child(b)



		if i > 0:
			var back: = EdTheme.text_button("◀", 
				"Move this hit one grid division earlier", 
				EdTheme.GOLD, ed.font, EdTheme.S_MICRO)
			back.pressed.connect( func(): _chain_nudge(uid, idx, -1))
			row.add_child(back)
			var fwd: = EdTheme.text_button("▶", 
				"Move this hit one grid division later", 
				EdTheme.GOLD, ed.font, EdTheme.S_MICRO)
			fwd.pressed.connect( func(): _chain_nudge(uid, idx, 1))
			row.add_child(fwd)
		var del: = EdTheme.text_button("✕", "Remove this step", EdTheme.RED, 
			ed.font, EdTheme.S_MICRO)
		del.disabled = steps.size() <= 1
		del.pressed.connect( func(): _chain_remove(uid, idx))
		row.add_child(del)
		_body.add_child(row)
	var add: = EdTheme.text_button("  + ADD A STEP  ", 
		"Lands on the PLAYHEAD when it is past the last hit,\n"
		+ "otherwise one grid division after it", EdTheme.GOLD, ed.font, 
		EdTheme.S_MICRO)
	add.pressed.connect( func(): _chain_add(uid))
	_body.add_child(add)
	var build: = EdTheme.text_button("  COMPOSE ON STAGE  ", 
		"Each click on the stage adds a step, on the PLAYHEAD\n"
		+ "(move it between clicks for free spacing) - Esc to finish", 
		Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
	build.pressed.connect( func(): _chain_build(uid))
	_body.add_child(build)


func _chain_add(uid: int) -> void :
	var n = ed.note_by_uid(uid)
	if n == null:
		return
	ed.add_chain_step(uid, ed.chain_steps(n).back()[1])
	_signature = ""
	_sync()




func _chain_nudge(uid: int, idx: int, dir: int) -> void :
	var n = ed.note_by_uid(uid)
	if n == null:
		return
	var steps: Array = ed.chain_steps(n)
	if idx <= 0 or idx >= steps.size():
		return
	var step: float = ed.beat_dur() / float(ed.grid_div())
	var want: float = float(steps[idx][0]) + step * float(dir)


	var lo: float = float(steps[idx - 1][0]) + 0.075
	var hi: float = float(steps[idx + 1][0]) - 0.075 if idx + 1 < steps.size()\
	else ed._len
	if want < lo or want > hi:
		ed.flash("no room — hits must stay 75 ms apart")
		return
	ed.set_chain_step_time(uid, idx, want)
	_signature = ""
	_sync()


func _chain_remove(uid: int, idx: int) -> void :
	ed.remove_chain_step(uid, idx)
	_signature = ""
	_sync()


func _chain_build(uid: int) -> void :
	ed.chain_building_uid = uid
	ed.flash("click on the stage to chain - Esc to finish")


func _build_multi() -> void :
	_head("%d NOTES SELECTED" % ed.sel_uids.size(), EdTheme.CYAN)
	_value("span", "RANGE")
	_value("kinds", "TYPES")
	_sec("GROUP VELOCITY (SV)")
	var svrow: = HBoxContainer.new()
	svrow.add_theme_constant_override("separation", 2)
	for d in [-0.15, 0.15]:
		var b: = EdTheme.text_button("%+.2f" % d, "", Color.TRANSPARENT, ed.font, 
			EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect( func(): ed.nudge_velocity(d))
		svrow.add_child(b)
	_body.add_child(svrow)
	_sec("CONVERT")
	var tb: = EdTheme.text_button("  CHANGE TYPE  ", "", Color.TRANSPARENT, 
		ed.font, EdTheme.S_MICRO)
	tb.pressed.connect(_type_menu)
	_body.add_child(tb)
	_body.add_child(EdTheme.spacer(4))
	_actions_row()


func _build_map_summary() -> void :
	_head("MAP", EdTheme.VIOLET)

	_charge_head = EdTheme.make_label("", 22, EdTheme.GOLD, ed.font_display)
	_body.add_child(_charge_head)
	_charge_tier = EdTheme.make_label("", EdTheme.S_SMALL, EdTheme.GOLD, ed.font)
	_body.add_child(_charge_tier)
	_axis_bars.clear()
	for e in [["rythme", "RHYTHM", "speed, regularity, one-hand streams"], 
			["visee", "AIM", "real cursor travel: lane zones, targets, slider rails"], 
			["lecture", "READING", "visible time, hidden or off-screen lanes, chains"], 
			["coordination", "COORDINATION", "tapping while holding, red lane bans"]]:
		var bar: = AxisBar.new()
		bar.setup(ed, String(e[1]), String(e[2]))
		_body.add_child(bar)
		_axis_bars[String(e[0])] = bar
	_body.add_child(EdTheme.spacer(4))
	_body.add_child(EdTheme.separator())

	_value("count", "NOTES")




	var det: = EdTheme.make_section("DETAILS", ed.font, ed.ui_is_open("details"), 
		"Note breakdown, file, length, save state")
	det.toggled.connect( func(o): ed.ui_set_open("details", o))
	_body.add_child(det)
	_dest = det.body
	_value("k_parry", "WHITE")
	_value("k_dodge", "DODGES")
	_value("k_click", "AIM")
	_value("k_hold", "HOLDS")
	_value("k_slider", "SLIDERS")
	_value("kiai", "KIAI SECTIONS")
	_value("len", "LENGTH")
	_value("file", "FILE")
	_value("audio", "AUDIO")
	_value("dirty", "SAVED")
	_dest = _body
	var hint: = EdTheme.make_label(
		"Select a note - on the stage or in the timeline - to edit its properties.", 
		EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(EdTheme.spacer(4))
	_body.add_child(hint)




func _build_tempo() -> void :
	_head("TEMPO & GRID", EdTheme.CYAN)
	_field("bpm", "BPM", "", "")
	_field("grid_anchor", "ANCHOR", "", "s")
	var ab: = EdTheme.text_button("  SNAP ANCHOR TO CURSOR  ", 
		"The anchor defines the grid's beat zero\nG", Color.TRANSPARENT, 
		ed.font, EdTheme.S_MICRO)
	ab.pressed.connect(_anchor_here)
	_body.add_child(ab)
	_value("div", "ACTIVE GRID")

	_sec("MAP PLAYBACK")
	_field("offset", "OFFSET", "", "s")
	_field("velocity", "VELOCITY", "", "x")

	_field("default_v_lane", "LANE NOTE SV", "", "x")
	_field("default_v_aim", "AIM NOTE SV", "", "x")
	var vhint: = EdTheme.make_label(
		"Velocity is the game's AR: raise it on fast maps, "
		+ "reading stays clean. Hit timing never changes.", 
		EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
	vhint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(vhint)

	_sec("CHART BOUNDS")
	_field("end", "END", "", "s")
	_field("practice", "PRACTICE", "", "s")




	_value("autoin", "AUTO START")
	_value("autoout", "AUTO END")
	var bhint: = EdTheme.make_label(
		"Leave END / PRACTICE at 0 to let the map bound itself. "
		+ "Anything on screen counts as content — a text or a lane move "
		+ "in the intro keeps it.", 
		EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
	bhint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(bhint)
	_value("audio2", "AUDIO")

	_sec("RECORDING")
	_field("rec_offset", "OFFSET", "", "ms")
	var rhint: = EdTheme.make_label(
		"Offset applied to hits captured in REC mode ( , and . ).", 
		EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
	rhint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(rhint)


func _anchor_here() -> void :
	ed.push_undo("ancre de grille")
	ed.grid_anchor = ed.t
	ed.mark_dirty()
	ed.flash("grid anchor snapped to %.3f s" % ed.grid_anchor)






func _build_events() -> void :
	var fev = ed.selected_fx()
	if fev != null:
		_build_fx_editor(fev)
		return
	_head("CHOREOGRAPHY", EdTheme.VIOLET)
	var add: = EdTheme.text_button("  + ADD AN EVENT  ", 
		"Text, lane move, background, shake...\nAdded at the cursor", 
		EdTheme.VIOLET, ed.font, EdTheme.S_MICRO)
	add.pressed.connect(_fx_add_menu)
	_body.add_child(add)
	_value("fxcount", "EVENTS")



	var near: Array = ed.fx_in_window(ed.t - 8.0, ed.t + 16.0)
	_body.add_child(EdTheme.section("AROUND THE CURSOR (-8 s / +16 s)", ed.font))
	if near.is_empty():
		_body.add_child(EdTheme.make_label("Nothing in this window.", 
			EdTheme.S_SMALL, EdTheme.TXT_FAINT, ed.font))
	for ev in near:
		_body.add_child(_fx_row(ev))

	_body.add_child(EdTheme.spacer(4))
	_head("KIAI SECTIONS", EdTheme.WARM)
	if ed.kiai.is_empty():
		_body.add_child(EdTheme.make_label("No sections.", EdTheme.S_SMALL, 
			EdTheme.TXT_FAINT, ed.font))
	for i in ed.kiai.size():
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		var k: Array = ed.kiai[i]
		var go: = EdTheme.text_button("%s → %s" % [EdTheme.fmt_time(float(k[0])), 
			EdTheme.fmt_time(float(k[1]))], "Go to the start of the section", 
			Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
		go.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var t0: = float(k[0])
		go.pressed.connect( func(): ed.seek_to(t0))
		row.add_child(go)
		var del: = EdTheme.text_button("✕", "Delete the section", EdTheme.RED, 
			ed.font, EdTheme.S_MICRO)
		var idx: int = i
		del.pressed.connect( func(): ed.remove_kiai(idx))
		row.add_child(del)
		_body.add_child(row)
	var add_kiai: = EdTheme.text_button("  KIAI ON SELECTED RANGE  ", 
		"Creates a section from the time range\nK places two markers", 
		EdTheme.WARM, ed.font, EdTheme.S_MICRO)
	add_kiai.pressed.connect( func(): ed.kiai_from_zone())
	_body.add_child(add_kiai)
	var mark: = EdTheme.text_button("  KIAI MARKER AT CURSOR  ", 
		"Two markers form a section\nK", Color.TRANSPARENT, ed.font, 
		EdTheme.S_MICRO)
	mark.pressed.connect( func(): ed.kiai_key())
	_body.add_child(mark)

	_sec("RANGE VELOCITY (SV)")
	_value("zone", "RANGE")
	var svrow: = HBoxContainer.new()
	svrow.add_theme_constant_override("separation", 2)
	for d in [-0.15, 0.15]:
		var b: = EdTheme.text_button("%+.2f" % d, 
			"SV of the targeted notes\nRed = faster, blue = slower", 
			Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect( func(): ed.nudge_velocity(d))
		svrow.add_child(b)
	_body.add_child(svrow)
	var reset: = EdTheme.text_button("  RESET SV = 1.00  ", "", Color.TRANSPARENT, 
		ed.font, EdTheme.S_MICRO)
	reset.pressed.connect(_reset_sv)
	_body.add_child(reset)







func _fx_row(ev: Dictionary) -> Control:
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	var type: = String(ev.get("type", ""))
	var b: = EdTheme.text_button("%s  %s" % [EdTheme.fmt_time(float(ev.get("time", 0.0))), 
		EdFx.short(ev)], EdFx.label(type), EdFx.color(type), ed.font, 
		EdTheme.S_MICRO)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_text = true
	var uid: = int(ev.get("_uid", -1))
	b.pressed.connect( func(): ed.select_fx(uid))
	row.add_child(b)
	return row


func _fx_add_menu() -> void :
	var items: Array = [{"title": "ADD AT %s" % EdTheme.fmt_time(ed.t)}]
	for tp in EdFx.MENU_ORDER:
		items.append({"text": EdFx.label(tp), "id": tp, "accent": EdFx.color(tp)})
	EdMenu.open(ed.overlay_host(), items, 
		get_global_rect().position + Vector2(-140, 60), ed.font, _fx_add_pick, 186)


func _fx_add_pick(id: String) -> void :
	if id != "":
		ed.add_fx(id, ed.t)




func _build_fx_editor(ev: Dictionary) -> void :
	var type: = String(ev.get("type", ""))
	var sp: = EdFx.spec(type)
	_head(EdFx.label(type), EdFx.color(type))

	var back: = EdTheme.text_button("  ‹ BACK TO LIST  ", "", Color.TRANSPARENT, 
		ed.font, EdTheme.S_MICRO)
	back.pressed.connect( func(): ed.select_fx(-1))
	_body.add_child(back)

	if sp.has("hint"):
		var h: = EdTheme.make_label(String(sp.hint), EdTheme.S_MICRO, 
			Color(1, 1, 1, 0.32), ed.font)
		h.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_body.add_child(h)

	_sec("TIME")
	_field("fx.time", "START", "", "s")
	_field("fx.len", "LENGTH", "", "s")


	_field("fx.end", "END", "", "s")
	_value("fx_beat", "BEAT")

	if bool(sp.get("anim", false)):
		_sec("ANIMATION")
		if bool(sp.get("lane", false)):
			_choice("fx.lane", "LANE", ["0", "1", "2"], ["LEFT", "CENTER", "RIGHT"])
		_field("fx.to", String(sp.get("to_label", "VALEUR")), "", "")
		_choice("fx.ease", "CURVE", EdFx.EASES, EdFx.EASES)
	elif bool(sp.get("lane", false)):

		_sec("LANE")
		_choice("fx.lane", "LANE", ["0", "1", "2"], ["LEFT", "CENTER", "RIGHT"])

	var fields: Array = sp.get("fields", [])
	if not fields.is_empty():
		_sec("SETTINGS")
	for fd in fields:
		var key: = "fx." + String(fd.key)
		var kind: = String(fd.kind)
		var lbl: = String(fd.label)
		if kind.begins_with("choice:"):
			_choice(key, lbl, EdFx.choices(kind), EdFx.choice_labels(kind))
		elif kind == "bool":
			_bool_row(key, lbl)
		elif kind == "color":
			_color_row(key, lbl, String(fd.get("def", "")) == "")
		elif kind == "image":
			_image_row(key, lbl)
		else:
			_field(key, lbl, "", "")

	_sec("")
	var g: = GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 2)
	for e in [["Go to start", "fxgoto"], ["Duplicate", "fxdup"], 
			["Delete", "fxdel"]]:
		var b: = EdTheme.text_button(String(e[0]), "", 
			EdTheme.RED if e[1] == "fxdel" else Color.TRANSPARENT, ed.font, 
			EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var id: = String(e[1])
		b.pressed.connect( func(): _fx_action(id))
		g.add_child(b)
	_body.add_child(g)

	var tip: = EdTheme.make_label(
		"In the CHOREO strip: drag the capsule to re-time the event, drag "
		+ "its right end to change its length (Alt = no grid snap), wheel "
		+ "to scroll the rows. Texts and images also have a frame in the "
		+ "STAGE: drag it to move, pull a corner to scale. Then TEST PLAY "
		+ "to see it in game.", 
		EdTheme.S_MICRO, Color(1, 1, 1, 0.28), ed.font)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(EdTheme.spacer(3))
	_body.add_child(tip)


func _fx_action(id: String) -> void :
	var ev = ed.selected_fx()
	if ev == null:
		return
	match id:
		"fxgoto":
			ed.seek_to(float(ev.get("time", 0.0)), false)
		"fxdup":
			ed.duplicate_fx(ed.sel_fx_uid)
		"fxdel":
			ed.delete_fx(ed.sel_fx_uid)
			ed.flash("event deleted")



func _choice(key: String, label: String, values: Array, shown: Array) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var l: = EdTheme.make_label(label, EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	l.custom_minimum_size.x = 74
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var b: = EdTheme.text_button("", "", Color.TRANSPARENT, ed.font, EdTheme.S_SMALL)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.set_meta("values", values)
	b.set_meta("shown", shown)
	b.pressed.connect( func(): _choice_menu(key, b))
	row.add_child(b)
	_body.add_child(row)
	_choices[key] = b


func _choice_menu(key: String, b: Button) -> void :
	var values: Array = b.get_meta("values", [])
	var shown: Array = b.get_meta("shown", [])
	var cur_raw = _fx_read(key, "")


	var cur: = str(cur_raw)
	if typeof(cur_raw) in [TYPE_FLOAT, TYPE_INT] and not values.has(cur):
		cur = str(int(cur_raw))
	var items: Array = []
	for i in values.size():
		items.append({"text": String(shown[i]), "id": String(values[i]), 
			"check": String(values[i]) == cur})
	_pending_choice = key
	_pending_choice_uid = ed.sel_fx_uid
	EdMenu.open(ed.overlay_host(), items, b.get_global_rect().position + Vector2(0, 22), 
		ed.font, _choice_pick, 130)


func _choice_pick(id: String) -> void :
	if _pending_choice == "":
		return
	var key: = _pending_choice
	_pending_choice = ""


	if _pending_choice_uid != ed.sel_fx_uid:
		return
	var field: = key.substr(3)
	if field == "lane":
		ed.set_fx_field(ed.sel_fx_uid, "lane", int(id), "change lane of")
	else:
		ed.set_fx_field(ed.sel_fx_uid, field, id, "change")
	_signature = ""
	_sync()


func _bool_row(key: String, label: String) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var l: = EdTheme.make_label(label, EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	l.custom_minimum_size.x = 74
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var b: = EdTheme.text_button("", "", Color.TRANSPARENT, ed.font, EdTheme.S_SMALL)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect( func():
		var field: = key.substr(3)
		ed.set_fx_field(ed.sel_fx_uid, field, not bool(_fx_read(key, false)), "toggle")
		_refresh_values())
	row.add_child(b)
	_body.add_child(row)
	_bools[key] = b





func _color_row(key: String, label: String, optional: = false) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var l: = EdTheme.make_label(label, EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	l.custom_minimum_size.x = 74
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var le: = LineEdit.new()
	le.placeholder_text = "#rrggbb"
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	EdTheme.style_line_edit(le, ed.font, EdTheme.S_SMALL)
	_bind_field(le, key)
	row.add_child(le)
	var swatch: = Swatch.new()
	swatch.custom_minimum_size = Vector2(26, 18)
	swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	swatch.mouse_filter = Control.MOUSE_FILTER_STOP
	swatch.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	swatch.tooltip_text = "Click to open the palette"
	swatch.gui_input.connect( func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed\
		and event.button_index == MOUSE_BUTTON_LEFT:
			_open_picker(key, swatch, optional)
			swatch.accept_event())
	row.add_child(swatch)
	_body.add_child(row)
	_fields[key] = le
	_swatches[key] = swatch





func _open_picker(key: String, swatch: Control, optional: bool) -> void :
	var uid: int = ed.sel_fx_uid
	if uid < 0:
		return
	var field: = key.substr(3)
	var cur: = Color.from_string(str(_fx_read(key, "")), Color(0, 0, 0, 0))
	_picker_session = ""
	var at: Vector2 = swatch.get_global_rect().position + Vector2(18.0 - 232.0, 22.0)
	EdColorPicker.open(ed.overlay_host(), at, ed.font, cur, 
		func(c: Color, final: bool): _picker_changed(uid, field, c, final), 
		optional)


func _picker_changed(uid: int, field: String, c: Color, final: bool) -> void :
	if uid != ed.sel_fx_uid:
		return
	var ev = ed.selected_fx()
	if ev == null:
		return
	if c.a <= 0.0:
		ed.set_fx_field(uid, field, null, "clear")
		_picker_session = ""
		_signature = ""
		_sync()
		return
	var hex: = "#" + c.to_html(false)
	var sess: = "%d|%s" % [uid, field]
	if _picker_session != sess:
		_picker_session = sess
		ed.set_fx_field(uid, field, hex, "pick color of")
	else:
		EdFx.set_field(ev, field, hex)
		ed.mark_dirty()
	_refresh_values()




func _image_row(key: String, label: String) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var l: = EdTheme.make_label(label, EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	l.custom_minimum_size.x = 74
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var b: = EdTheme.text_button("", "Choose an image file — it is copied into the map folder", 
		Color.TRANSPARENT, ed.font, EdTheme.S_SMALL)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.clip_text = true
	var uid: int = ed.sel_fx_uid
	b.pressed.connect( func(): ed.pick_fx_image(uid, key.substr(3)))
	row.add_child(b)
	_body.add_child(row)
	_images[key] = b



func _fx_read(key: String, def):
	var ev = ed.selected_fx()
	if ev == null:
		return def
	return EdFx.get_field(ev, key.substr(3), def)


func _reset_sv() -> void :
	var uids: Array = ed.target_uids()
	if uids.is_empty():
		ed.flash("select notes or a range first")
		return
	ed.set_prop(uids, "v", null, "reset SV of")
	ed.flash("SV reset to 1.00 on %d note(s)" % uids.size())




func _head(text: String, col: Color) -> void :
	var l: = EdTheme.make_label(text, EdTheme.S_HEAD, col, ed.font_display)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dest.add_child(l)


func _sec(text: String) -> void :
	_dest.add_child(EdTheme.spacer(3))
	_dest.add_child(EdTheme.section(text, ed.font))



func _field(key: String, label: String, value: String, suffix: String) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var l: = EdTheme.make_label(label, EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	l.custom_minimum_size.x = 74
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(l)
	var le: = LineEdit.new()
	le.text = value
	le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	EdTheme.style_line_edit(le, ed.font, EdTheme.S_SMALL)
	_bind_field(le, key)
	row.add_child(le)
	if suffix != "":
		var s: = EdTheme.make_label(suffix, EdTheme.S_MICRO, EdTheme.TXT_FAINT, ed.font)
		s.custom_minimum_size.x = 12
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(s)
	_dest.add_child(row)
	_fields[key] = le



func _value(key: String, label: String) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	var l: = EdTheme.make_label(label, EdTheme.S_MICRO, EdTheme.TXT_DIM, ed.font)
	l.custom_minimum_size.x = 74
	row.add_child(l)
	var vl: = EdTheme.make_label("", EdTheme.S_SMALL, EdTheme.TXT, ed.font)
	vl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(vl)
	_dest.add_child(row)
	_values[key] = vl


func _actions_row() -> void :
	var g: = GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 2)
	g.add_theme_constant_override("v_separation", 2)
	for e in [["Go to time", "goto"], ["Duplicate", "dup"], ["Delete", "del"]]:
		var b: = EdTheme.text_button(String(e[0]), "", EdTheme.RED if e[1] == "del"
			else Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var id: = String(e[1])
		b.pressed.connect( func(): _action(id))
		g.add_child(b)
	_body.add_child(g)


func _action(id: String) -> void :
	match id:
		"goto":
			var n = ed.focus_note()
			if n != null:
				ed.seek_to(float(n.time), false)
		"dup":
			ed.duplicate_uids(ed.sel_uids.duplicate())
		"del":
			ed.delete_selection()


func _type_menu() -> void :
	var items: Array = [{"title": "CONVERT TO"}]
	for tp in ["parry", "dodge", "click", "clickx", "sliderm", "sliderg"]:
		items.append({"text": EdTheme.type_label(tp), "id": tp, 
			"accent": EdTheme.accent_for(tp)})
	EdMenu.open(ed.overlay_host(), items, 
		get_global_rect().position + Vector2(10, 60), ed.font, _type_pick, 150)


func _type_pick(id: String) -> void :
	if id != "":
		ed.convert_type(ed.sel_uids.duplicate(), id)


func _lane_menu() -> void :
	var items: Array = [{"title": "LANE"}]
	var names: = ["LEFT", "CENTER", "RIGHT"]
	for i in 3:
		items.append({"text": names[i], "id": str(i), 
			"accent": ed.main.LANE_COLS[i]})
	EdMenu.open(ed.overlay_host(), items, 
		get_global_rect().position + Vector2(10, 110), ed.font, _lane_pick, 120)


func _lane_pick(id: String) -> void :
	if id == "":
		return
	ed.set_prop(ed.sel_uids.duplicate(), "lane", int(id), "change lane of")
	_signature = ""
	_sync()


func _regen_arc() -> void :
	var n = ed.focus_note()
	if n == null or String(n.type) != "sliderg":
		return
	ed.push_undo("regenerate arc")
	var head: Vector2 = ed.slider_point_at(n, 0.0)
	var tail: Vector2 = ed.slider_point_at(n, 1.0)
	n["points"] = ed.gentle_arc(float(n.time), head.x, tail.x)
	ed.mark_dirty()
	ed.flash("slider arc redrawn")





func _apply(key: String, txt: String) -> void :
	if key.begins_with("fx."):
		_apply_fx(key.substr(3), txt)
		return



	var val: = txt.strip_edges().replace(",", ".").to_float()
	if not is_finite(val):
		val = 0.0
	var uids: Array = ed.sel_uids.duplicate()
	var vs: Vector2 = ed.play_size()
	match key:
		"time":
			if uids.is_empty():
				return
			var n = ed.focus_note()
			if n != null:
				ed.move_notes(uids, clampf(val, 0.0, ed.song_len()) - float(n.time), 
					0, true, "set time")
		"duration":
			ed.set_prop(uids, "duration", maxf(val, 0.02), "set length of")
		"x":
			ed.set_prop(uids, "x", clampf(val * 0.01, 0.0, 1.0) * vs.x, "set X of")
		"y":
			ed.set_prop(uids, "y", clampf(val * 0.01, 0.0, 1.0) * vs.y, "set Y of")
		"v":
			ed.set_prop(uids, "v", clampf(val, 0.5, 2.0), "set SV of")
		"bpm":
			ed.push_undo("BPM")
			ed.bpm = maxf(val, 20.0)
			ed.mark_dirty()
		"grid_anchor":
			ed.push_undo("ancre de grille")
			ed.grid_anchor = val
			ed.mark_dirty()
		"offset":
			ed.push_undo("offset")
			ed.chart_offset = val
			ed.mark_dirty()
		"velocity":
			ed.push_undo("map velocity")
			ed.chart_vel = clampf(val, 0.6, 2.0)
			ed.mark_dirty()
		"default_v_lane":
			ed.push_undo("default lane SV")
			ed.default_v_lane = clampf(val, 0.5, 2.0)
			ed.mark_dirty()
		"default_v_aim":
			ed.push_undo("default aim SV")
			ed.default_v_aim = clampf(val, 0.5, 2.0)
			ed.mark_dirty()
		"end":
			ed.push_undo("chart end")
			ed.chart_end = maxf(val, 0.0)
			ed.mark_dirty()
		"practice":
			ed.push_undo("practice point")
			ed.chart_practice = maxf(val, 0.0)
			ed.mark_dirty()
		"rec_offset":
			ed.rec_offset = clampf(val * 0.001, -0.3, 0.3)
			ed.view_changed.emit()
	_refresh_values()




func _fx_kind(field: String) -> String:
	if field in ["time", "len", "to", "end"]:
		return "float"
	var ev = ed.selected_fx()
	if ev == null:
		return "text"
	for fd in EdFx.spec(String(ev.get("type", ""))).get("fields", []):
		if String(fd.key) == field:
			return String(fd.kind)
	return "text"




func _apply_fx(field: String, txt: String) -> void :
	if ed.sel_fx_uid < 0:
		return
	var raw: = txt.strip_edges()
	var kind: = _fx_kind(field)
	var value
	match kind:
		"float":
			value = raw.replace(",", ".").to_float()
			if field == "end":

				var ev = ed.selected_fx()
				var t0: float = float(ev.get("time", 0.0)) if ev != null else 0.0
				ed.set_fx_field(ed.sel_fx_uid, "len", maxf(float(value) - t0, 0.001), "set end")
				_refresh_values()
				return
			if field == "len":
				value = maxf(float(value), 0.001)
			elif field == "time":
				value = snappedf(maxf(float(value), 0.0), 0.001)
		"int":
			value = int(raw.to_float())
		"color":
			if raw == "":
				ed.set_fx_field(ed.sel_fx_uid, field, null, "clear")
				_signature = ""
				_sync()
				return
			if not raw.begins_with("#"):
				raw = "#" + raw
			value = raw
		_:
			value = raw
	ed.set_fx_field(ed.sel_fx_uid, field, value, "set")
	_refresh_values()




func _set_field(key: String, value: String) -> void :
	var le: LineEdit = _fields.get(key)

	if le != null and not le.has_focus():
		le.text = value
		le.set_meta("last", value)












func _bind_field(le: LineEdit, key: String) -> void :
	le.set_meta("last", le.text)
	var fx_uid: int = ed.sel_fx_uid
	var uids: Array = ed.sel_uids.duplicate()
	le.text_submitted.connect( func(txt: String):
		_apply_bound(le, key, txt, fx_uid, uids))
	le.focus_exited.connect( func():
		_apply_bound(le, key, le.text, fx_uid, uids))


func _apply_bound(le: LineEdit, key: String, txt: String, fx_uid: int, uids: Array) -> void :
	if not is_instance_valid(le):
		return
	if txt.strip_edges() == String(le.get_meta("last", "")).strip_edges():
		return
	if key.begins_with("fx."):
		if fx_uid != ed.sel_fx_uid:
			return
	elif uids != ed.sel_uids:
		return
	le.set_meta("last", txt)
	_apply(key, txt)


func _set_value(key: String, value: String) -> void :
	var l: Label = _values.get(key)
	if l != null:
		l.text = value


func _refresh_values() -> void :
	var vs: Vector2 = ed.play_size()
	match tab:
		"tempo":
			_set_field("bpm", "%.2f" % ed.bpm)
			_set_field("grid_anchor", "%.3f" % ed.grid_anchor)
			_set_field("offset", "%.3f" % ed.chart_offset)
			_set_field("velocity", "%.2f" % ed.chart_vel)
			_set_field("default_v_lane", "%.2f" % ed.default_v_lane)
			_set_field("default_v_aim", "%.2f" % ed.default_v_aim)
			_set_field("end", "%.2f" % ed.chart_end)
			_set_field("practice", "%.2f" % ed.chart_practice)
			_set_field("rec_offset", "%.0f" % (ed.rec_offset * 1000.0))
			_set_value("div", "%s  ·  %d/4" % [ed.grid_label(), ed.beats_per_bar])
			var ab: Array = ed.auto_bounds()
			_set_value("autoin", EdTheme.fmt_time(float(ab[0]))
				if float(ab[0]) > 0.0 else "from 0 — nothing to skip")
			_set_value("autoout", EdTheme.fmt_time(float(ab[1]))
				if float(ab[1]) > 0.0 else "plays to the end of the audio")
			_set_value("audio2", ed.audio_res.get_file())
		"events":
			_set_value("zone", "%d note(s) targeted" % ed.target_uids().size())
			_set_value("fxcount", "%d in the map" % ed.fx_events.size())
			_refresh_fx_values()
		_:
			_refresh_note_values(vs)




func _refresh_fx_values() -> void :
	var ev = ed.selected_fx()
	if ev == null:
		return
	_set_field("fx.time", "%.3f" % float(ev.get("time", 0.0)))
	_set_field("fx.len", "%.3f" % float(ev.get("len", 1.0)))
	_set_field("fx.end", "%.3f" % (float(ev.get("time", 0.0)) + float(ev.get("len", 1.0))))
	_set_value("fx_beat", "%.2f" % ed.beat_of(float(ev.get("time", 0.0))))
	if _fields.has("fx.to"):
		_set_field("fx.to", "%.3f" % float(ev.get("to", 1.0)))
	for key in _fields:
		if not key.begins_with("fx.") or key in ["fx.time", "fx.len", "fx.to", "fx.end"]:
			continue
		var field: String = key.substr(3)
		var val = EdFx.get_field(ev, field, "")
		var kind: = _fx_kind(field)
		var shown: = str(val)


		var num: float = float(val) if typeof(val) != TYPE_STRING\
		else String(val).to_float()
		if kind == "float":
			shown = "%.3f" % num
		elif kind == "int":
			shown = str(int(num))
		_set_field(key, shown)
		if _swatches.has(key):
			var sw: Swatch = _swatches[key]
			var c: = Color.from_string(str(val), Color(0, 0, 0, 0))
			sw.color = c
			sw.tooltip_text = ("No color set" if c.a == 0.0 else str(val))\
			+ " — click to open the palette"
	for key in _choices:
		var b: Button = _choices[key]
		var raw = EdFx.get_field(ev, key.substr(3), "")
		var v: = str(raw)

		var values: Array = b.get_meta("values", [])
		var shown_list: Array = b.get_meta("shown", [])
		var idx: = values.find(v)


		if idx < 0 and typeof(raw) in [TYPE_FLOAT, TYPE_INT]:
			idx = values.find(str(int(raw)))
		b.text = "  %s  " % (String(shown_list[idx]) if idx >= 0
			else ("(none)" if v == "" else v))
	for key in _bools:
		var b2: Button = _bools[key]
		var on: = bool(EdFx.get_field(ev, key.substr(3), false))
		b2.text = "  YES  " if on else "  NO  "
		EdTheme.style_button(b2, EdTheme.CYAN if on else Color.TRANSPARENT, 
			ed.font, EdTheme.S_SMALL)
	for key in _images:
		var b3: Button = _images[key]
		var file: = str(EdFx.get_field(ev, key.substr(3), ""))
		var has: = file != ""
		b3.text = "  %s  " % (file if has else "choose an image...")
		b3.tooltip_text = file if has else "Choose an image file — it is copied into the map folder"
		EdTheme.style_button(b3, Color.TRANSPARENT if has else EdFx.color("image"), 
			ed.font, EdTheme.S_SMALL)


func _refresh_note_values(vs: Vector2) -> void :
	var n = ed.focus_note()
	if n == null:
		var counts: = {"parry": 0, "dodge": 0, "click": 0, "sliderm": 0, "sliderg": 0}
		for note in ed.notes:
			var tp: = String(note.type)
			if tp == "clickx":
				tp = "click"
			if tp == "beam":
				tp = "sliderm"
			if counts.has(tp):
				counts[tp] += 1
		_set_value("file", ed.chart_path.get_file())
		_set_value("audio", ed.audio_res.get_file())
		_set_value("len", EdTheme.fmt_time(ed.song_len()))
		_set_value("count", str(ed.notes.size()))
		_set_value("k_parry", str(counts.parry))
		_set_value("k_dodge", str(counts.dodge))
		_set_value("k_click", str(counts.click))
		_set_value("k_hold", str(counts.sliderm))
		_set_value("k_slider", str(counts.sliderg))
		_set_value("dirty", "MODIFIED" if ed.dirty else "up to date")
		_set_value("kiai", str(ed.kiai.size()))
		var r: Dictionary = ed.rating
		var rc: Color = r.get("color", EdTheme.GOLD)
		if _charge_head != null and is_instance_valid(_charge_head):
			_charge_head.text = "LEVEL  %.1f" % float(r.get("level", 0.0))
			_charge_head.add_theme_color_override("font_color", rc)
			_charge_tier.text = String(r.get("tier", ""))
			_charge_tier.add_theme_color_override("font_color", rc)
		for key in _axis_bars:
			_axis_bars[key].set_value(float(r.get(key, 0.0)), rc)
		return
	if ed.sel_uids.size() > 1:
		var t0: = INF
		var t1: = - INF
		var kinds: = {}
		for uid in ed.sel_uids:
			var nn = ed.note_by_uid(uid)
			if nn == null:
				continue
			t0 = minf(t0, float(nn.time))
			t1 = maxf(t1, float(nn.time))
			kinds[String(nn.type)] = true
		_set_value("span", "%s → %s" % [EdTheme.fmt_time(t0), EdTheme.fmt_time(t1)])
		_set_value("kinds", ", ".join(PackedStringArray(kinds.keys())))
		return
	_set_field("time", "%.3f" % float(n.time))
	_set_value("beat", "%.2f" % ed.beat_of(float(n.time)))
	if EdTheme.has_duration(String(n.type)):
		_set_field("duration", "%.3f" % float(n.get("duration", 0.0)))
		_set_value("beats", "%.2f beats" % (float(n.get("duration", 0.0)) / ed.beat_dur()))
	if String(n.type) == "sliderg":
		var pts: Array = ed.slider_path(n)
		_set_value("pathpts", "%d" % pts.size())


		var minp: = Vector2(INF, INF)
		var maxp: = Vector2( - INF, - INF)
		for p in pts:
			minp = minp.min(Vector2(float(p[1]), float(p[2])))
			maxp = maxp.max(Vector2(float(p[1]), float(p[2])))
		_set_value("pathspan", "%d × %d px" % [int(maxp.x - minp.x), 
			int(maxp.y - minp.y)])
	elif EdTheme.is_aim_type(String(n.type)):
		_set_field("x", "%.1f" % (float(n.get("x", vs.x * 0.5)) / vs.x * 100.0))
		_set_field("y", "%.1f" % (float(n.get("y", 300.0)) / vs.y * 100.0))
	elif _lane_btn != null and is_instance_valid(_lane_btn):
		_lane_btn.text = "  " + ["LEFT", "CENTER", "RIGHT"][clampi(int(n.lane), 0, 2)] + "  "
	_set_field("v", "%.2f" % float(n.get("v", 1.0)))






class AxisBar extends Control:
	const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

	var ed
	var label: = ""
	var hint: = ""
	var value: = 0.0
	var accent: = Color(1, 1, 1)

	func setup(p_ed, p_label: String, p_hint: String) -> void :
		ed = p_ed
		label = p_label
		hint = p_hint
		tooltip_text = "%s\n%s" % [p_label, p_hint]
		custom_minimum_size.y = 20
		mouse_filter = Control.MOUSE_FILTER_STOP

	func set_value(v: float, col: Color) -> void :
		value = v
		accent = col
		queue_redraw()

	func _notification(what: int) -> void :
		if what == NOTIFICATION_MOUSE_ENTER:
			ed.set_hint("%s — %s" % [label, hint])
		elif what == NOTIFICATION_MOUSE_EXIT:
			ed.set_hint("")

	func _draw() -> void :
		var f: Font = ed.font
		draw_string(f, Vector2(0, 9), label, HORIZONTAL_ALIGNMENT_LEFT, 70, 
			EdTheme.S_MICRO, EdTheme.TXT_DIM)
		draw_string(f, Vector2(size.x - 24, 9), "%.1f" % value, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, EdTheme.TXT)

		var x0: = 74.0
		var w: = size.x - x0 - 28.0
		var seg: = w / 10.0
		for i in 10:
			var on: bool = float(i) < value
			var r: = Rect2(x0 + float(i) * seg + 1.0, 4.0, seg - 2.0, 6.0)
			draw_rect(r, Color(accent.r, accent.g, accent.b, 0.85) if on
				else Color(1, 1, 1, 0.09))
