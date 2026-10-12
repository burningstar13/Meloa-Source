extends PanelContainer




















const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const AutoCheck = preload("res://scripts/auto_check.gd")
const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")
const EdJson = preload("res://scripts/editor_ui/ed_json.gd")
const EdBusy = preload("res://scripts/editor_ui/ed_busy.gd")

var ed

var _play_btn: Button
var _undo_btn: Button
var _redo_btn: Button
var _save_btn: Button
var _publish_btn: Button
var _time_lbl: Label
var _beat_lbl: Label
var _bpm_lbl: Label
var _sig_lbl: Label
var _grid_lbl: Label
var _speed_lbl: Label
var _sfx_lbl: Label
var _name_lbl: Label
var _title_lbl: Label
var _diff_btn: Button
var _charge_lbl: Label
var _tier_lbl: Label


func _ready() -> void :
	custom_minimum_size.y = 40
	EdTheme.skin_panel(self, true)
	_build()
	ed.time_changed.connect(_on_time)
	ed.chart_changed.connect(refresh)
	ed.view_changed.connect(refresh)
	refresh()


func _build() -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	add_child(row)





	var id_box: = VBoxContainer.new()
	id_box.add_theme_constant_override("separation", -2)
	id_box.custom_minimum_size.x = 150
	_title_lbl = EdTheme.make_label("", 14, EdTheme.VIOLET, ed.font_display)
	_title_lbl.clip_text = true
	id_box.add_child(_title_lbl)
	var sub: = HBoxContainer.new()
	sub.add_theme_constant_override("separation", 4)
	_diff_btn = EdTheme.text_button("", "Difficulties of this song", EdTheme.CYAN, 
		ed.font, EdTheme.S_MICRO)
	_diff_btn.pressed.connect( func(): _diff_menu(_diff_btn))
	sub.add_child(_diff_btn)
	_name_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.TXT_FAINT, ed.font)
	_name_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_name_lbl.clip_text = true
	sub.add_child(_name_lbl)
	id_box.add_child(sub)
	row.add_child(id_box)
	row.add_child(EdTheme.spacer(4))
	row.add_child(_vsep())


	var b_start: = EdTheme.icon_button("prev", "Back to start\nHome")
	b_start.pressed.connect( func(): ed.seek_to(0.0))
	row.add_child(b_start)
	var b_back: = EdTheme.icon_button("back", "Back one bar\nLeft arrow")


	b_back.pressed.connect( func(): ed.seek( - float(ed.beats_per_bar) * ed.grid_div()))
	row.add_child(b_back)
	_play_btn = EdTheme.icon_button("play", "Play / pause\nSpace", EdTheme.MINT, 30, 13)
	_play_btn.pressed.connect( func(): ed.toggle_play())
	row.add_child(_play_btn)
	var b_stop: = EdTheme.icon_button("stop", "Stop and rewind")
	b_stop.pressed.connect( func(): ed.stop_play())
	row.add_child(b_stop)
	var b_fwd: = EdTheme.icon_button("fwd", "Forward one bar\nRight arrow")
	b_fwd.pressed.connect( func(): ed.seek(float(ed.beats_per_bar) * ed.grid_div()))
	row.add_child(b_fwd)
	row.add_child(_vsep())


	var tbox: = VBoxContainer.new()
	tbox.add_theme_constant_override("separation", -3)
	tbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tbox.custom_minimum_size.x = 76
	_time_lbl = EdTheme.make_label("00:00.000", 15, EdTheme.TXT, ed.font)
	tbox.add_child(_time_lbl)
	_beat_lbl = EdTheme.make_label("beat 0.00", EdTheme.S_MICRO, EdTheme.TXT_FAINT, ed.font)
	tbox.add_child(_beat_lbl)
	row.add_child(tbox)

	_bpm_lbl = _chip("126.67", "BPM", EdTheme.CYAN, _bpm_menu, 
		"Map BPM - click to adjust\nB / N: +/-0.05  (Shift: +/-1)")
	_sig_lbl = _chip("4/4", "SIGNATURE", EdTheme.TXT_DIM, _sig_menu, 
		"Beats per bar - grid display only")
	_grid_lbl = _chip("1/4", "GRID", EdTheme.VIOLET, _grid_menu, 
		"Snap resolution - click to choose\nAUTO: the grid follows the zoom")
	_speed_lbl = _chip("x1", "SPEED", EdTheme.CYAN, _speed_menu, 
		"Playback speed - pitch corrected\nSlow the song down to read a section")


	_sfx_lbl = _chip("ON", "SFX", EdTheme.MINT, _sfx_toggle, 
		"Hit sounds while playing\nEvery note plays its PERFECT sound")
	row.add_child(_bpm_lbl.get_parent().get_parent())
	row.add_child(_sig_lbl.get_parent().get_parent())
	row.add_child(_grid_lbl.get_parent().get_parent())
	row.add_child(_speed_lbl.get_parent().get_parent())
	row.add_child(_sfx_lbl.get_parent().get_parent())


	_charge_lbl = _chip("0.0", "LEVEL", EdTheme.GOLD, _charge_menu, 
		"Difficulty computed live\nRhythm + aim + reading, "
		+ "choreography included\nClick for the breakdown in the inspector")
	row.add_child(_charge_lbl.get_parent().get_parent())
	_tier_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.GOLD, ed.font)
	_tier_lbl.custom_minimum_size.x = 74
	_tier_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_tier_lbl)






	row.add_child(EdTheme.spacer(0, true))


	_undo_btn = EdTheme.icon_button("undo", "Undo\nCtrl+Z")
	_undo_btn.pressed.connect( func(): ed.undo())
	row.add_child(_undo_btn)
	_redo_btn = EdTheme.icon_button("redo", "Redo\nCtrl+Y")
	_redo_btn.pressed.connect( func(): ed.redo())
	row.add_child(_redo_btn)
	row.add_child(_vsep())

	var test: = EdTheme.text_button(" TEST ", 
		"Saves and plays the map from the cursor\nEsc in game returns here (T)", 
		EdTheme.MINT, ed.font, EdTheme.S_BODY)
	test.pressed.connect( func(): ed.playtest())
	row.add_child(test)
	_save_btn = EdTheme.text_button("  SAVE  ", "Write the chart to disk\nCtrl+S", 
		EdTheme.VIOLET, ed.font, EdTheme.S_BODY)
	_save_btn.pressed.connect( func(): ed.save())
	row.add_child(_save_btn)


	_publish_btn = EdTheme.text_button(" PUBLISH MAP ", 
		"Share this map with everyone\nUploads to the online catalog "
		+ "(needs your account)", 
		EdTheme.GOLD, ed.font, EdTheme.S_MICRO)
	_publish_btn.pressed.connect(_publish_pick)
	row.add_child(_publish_btn)
	var help: = EdTheme.icon_button("help", "All shortcuts\nH or F1")
	help.pressed.connect( func(): ed.shortcuts.toggle_help())
	row.add_child(help)
	var more: = EdTheme.icon_button("menu", "More actions")
	more.pressed.connect(_more_menu)
	row.add_child(more)


var _publishing: = false












const GATE_PERFECT: = true











func _auto_check(blocking: bool) -> bool:
	if ed.notes.is_empty():
		ed.flash("NOTHING TO TEST — the map has no notes")
		return false
	var was: String = _publish_btn.text
	_publish_btn.disabled = true
	_publish_btn.text = " TESTING… "
	ed.flash("AUTO IS PLAYING THE MAP…")
	await get_tree().process_frame
	var r: Dictionary = ed.run_auto_check()
	_publish_btn.disabled = false
	_publish_btn.text = was
	var passed: bool = bool(r.ok) if GATE_PERFECT else bool(r.playable)
	if passed:
		ed.flash("%s — %d objects judged" % [AutoCheck.summary(r), int(r.judged)])
		ed.main.sfx.play_ui("click")
		return true


	var zones: Array = r.zones
	if not zones.is_empty():
		ed.seek_to(maxf(float(zones[0][0]), 0.0))
	ed.main.sfx.play_ui("back")
	var first: = ""
	if not (r.problems as Array).is_empty():
		var p: Dictionary = (r.problems as Array)[0]
		first = "  ·  %s %s @ %s" % [String(p.kind).to_upper(), 
			String(p.type), EdTheme.fmt_time(float(p.t))]
	ed.flash("%s%s  —  %d ZONE(S) IN RED BELOW%s"
		%[AutoCheck.summary(r), "" if blocking else " (check only)", 
		zones.size(), first])
	return false












func _publish_pick() -> void :
	ed.main.sfx.play_ui("click")
	if _publishing:
		return
	if not MapLibrary.is_user_map(ed.map_track):
		ed.flash("SHIPPED MAP — it is already everywhere")
		return
	if MapLibrary.status_of(ed.map_track) == MapLibrary.STATUS_DOWNLOADED:
		ed.flash("DOWNLOADED MAP — only its mapper can publish it")
		return
	if not Backend.is_logged_in():
		ed.flash("LOG IN FIRST — publishing needs your account")
		return
	var track: String = ed.map_track
	var wip_now: bool = MapLibrary.online_wip_of(track)


	var ranked: bool = MapLibrary.online_ranking_of(track) == "ranked"
	var items: Array = [
		{"title": "PUBLISH MAP"}, 
		{"text": "Publish for RANKED", "id": "ranked", "accent": EdTheme.GOLD, 
			"hint": "current" if (MapLibrary.is_shared(track) and not wip_now) else "", 
			"check": not wip_now if MapLibrary.is_shared(track) else false}, 
		{"text": "Publish for WIP", "id": "wip", "accent": EdTheme.CYAN, 
			"hint": "ranked" if ranked else ("current" if wip_now else ""), 
			"disabled": ranked, 
			"check": wip_now}, 
		{"sep": true}, 
		{"text": "RANKED: reviewed, then voted on Discord.", "id": "", "disabled": true}, 
		{"text": "WIP: playable online with a badge, never reviewed.", "id": "", "disabled": true}, 
	]
	var host: Control = ed.overlay_host()
	var at: Vector2 = _publish_btn.global_position - host.global_position\
	+ Vector2(0.0, _publish_btn.size.y + 4.0)


	at.x = minf(at.x, host.size.x - 350.0)
	EdMenu.open(host, items, at, ed.font, func(id: String) -> void :
		if id == "ranked":
			_publish(false)
		elif id == "wip":
			_publish(true), 250)





func _publish(wip: bool) -> void :
	if _publishing:
		return
	if not MapLibrary.is_user_map(ed.map_track):
		ed.flash("SHIPPED MAP — it is already everywhere")
		return
	if MapLibrary.status_of(ed.map_track) == MapLibrary.STATUS_DOWNLOADED:
		ed.flash("DOWNLOADED MAP — only its mapper can publish it")
		return
	if not Backend.is_logged_in():
		ed.flash("LOG IN FIRST — publishing needs your account")
		return
	if ed.is_draft() or ed.dirty:
		ed.save()
		if ed.dirty:
			return

	MapLibrary.set_online_wip(ed.map_track, wip)
	ed.flash("PUBLISHING AS WORK IN PROGRESS" if wip else "PUBLISHING FOR RANKING")








	if not await _auto_check( not wip) and not wip:
		return
	_publishing = true
	_publish_btn.disabled = true
	_publish_btn.text = " PUBLISHING… "





	var busy = EdBusy.open(ed.overlay_host(), ed.font, ed.font_display, 
		"PUBLISHING MAP", "preparing…")
	busy.set_message("preparing…", BUSY_HINT)






	var track: String = ed.map_track
	var done: = [false]
	var result: = [{}]
	var run: = func() -> void :
		result[0] = await MapPublisher.publish(track, 
			func(msg: String) -> void :
				if is_instance_valid(busy):
					busy.set_message(msg, BUSY_HINT)
				if is_instance_valid(ed):
					ed.flash(msg.to_upper()))
		done[0] = true
	run.call()
	var waited: = 0.0
	while not done[0] and waited < PUBLISH_DEADLINE_SEC:
		await get_tree().create_timer(0.5).timeout
		waited += 0.5
	var r: Dictionary = result[0] if done[0] else await _publish_status_fallback(track)
	if is_instance_valid(busy):
		busy.close()
	_publishing = false
	if not is_instance_valid(_publish_btn):
		return
	_publish_btn.disabled = false
	_publish_btn.text = " PUBLISH MAP "
	if is_instance_valid(ed):
		ed.flash(String(r.message).to_upper())
		ed.main.sfx.play_ui("impact" if r.ok else "back")
		refresh()




const PUBLISH_DEADLINE_SEC: = 300.0

const BUSY_HINT: = "keep the game open — this closes by itself when the server answers"

func _publish_status_fallback(track: String) -> Dictionary:
	var meta: Dictionary = MapLibrary.meta_of(track)
	var online_id: = String(meta.get("online_id", ""))
	var mine: Dictionary = await Backend.api_maps_mine()
	if mine.ok and mine.data is Array:
		for e in mine.data:
			if not (e is Dictionary):
				continue
			var same_id: = online_id != "" and String(e.get("id", "")) == online_id
			var same_title: = online_id == ""\
			and String(e.get("title", "")) == String(meta.get("title", ""))
			if not (same_id or same_title):
				continue
			var status: = String(e.get("status", ""))
			if status == "PUBLISHED":
				var ver: = int(e.get("version", 1))
				if online_id == "":
					meta["online_id"] = String(e.get("id", ""))
					meta["online_version"] = ver
					meta["status"] = MapLibrary.STATUS_PUBLISHED
					MapLibrary.save_meta(track, meta)
				elif MapLibrary.wip_of(track) != ""\
				and not bool(e.get("updating", false))\
				and ver > MapLibrary.online_version_of(track):




					MapLibrary.promote_wip(track, ver)
				return {"ok": true, "message": "your map is LIVE (version %d)%s"
					%[int(e.get("version", 1)), 
					" — an update is still being checked" if bool(e.get("updating", false)) else ""]}
			if status == "REJECTED":
				return {"ok": false, "message": "rejected: " + String(e.get("rejectionReason", "validation failed"))}
			return {"ok": true, "message": "upload received — the server is still checking it (%s)" % status.to_lower()}
	return {"ok": false, "message":
		"publishing took too long — check COMMUNITY > ONLINE in a minute, or try again"}







func _diff_menu(btn: Button) -> void :
	var items: Array = [{"title": "DIFFICULTIES"}]
	var keys: Array = ed.diff_keys()
	if keys.is_empty():
		items.append({"text": ed.diff_label(), "id": "", "check": true, 
			"disabled": true})
	for k in keys:
		var key: = String(k)
		var label: = key.to_upper()
		var lvl: = 0.0
		if MapLibrary.is_user_map(ed.map_track):
			label = MapLibrary.diff_name(ed.map_track, key)
			lvl = MapLibrary.diff_level(ed.map_track, key)
		items.append({"text": label, "id": "go:" + key, 
			"check": key == ed.diff_key, 
			"hint": ("%.1f" % lvl) if lvl > 0.0 else ""})
	var mine: bool = ed.can_manage_diffs()
	items.append({"sep": true})
	items.append({"text": "New empty difficulty...", "id": "new", 
		"accent": EdTheme.MINT, "disabled": not mine})
	items.append({"text": "Duplicate this difficulty...", "id": "dup", 
		"disabled": not mine})
	items.append({"text": "Rename / set level...", "id": "ren", 
		"disabled": not mine})
	items.append({"text": "Delete this difficulty...", "id": "del", 
		"accent": EdTheme.RED, 
		"disabled": not mine or ed.diff_keys().size() < 2})
	items.append({"sep": true})
	items.append({"text": "Song metadata...", "id": "meta", 
		"accent": EdTheme.VIOLET, "disabled": not mine})
	items.append({"text": "Cover & background...", "id": "img", 
		"accent": EdTheme.GOLD, "disabled": not mine})
	items.append({"text": "Set menu preview to cursor", "id": "prev", 
		"disabled": not mine})
	if not mine:
		items.append({"sep": true})
		items.append({"text": "Shipped map - read only", "id": "", 
			"disabled": true})
	EdMenu.open(ed.overlay_host(), items, _menu_at(btn), ed.font, _diff_pick, 250)


func _diff_pick(id: String) -> void :
	if id == "":
		return
	if id.begins_with("go:"):
		ed.request_switch_diff(id.substr(3))
		return
	match id:
		"new":
			ed.new_diff_dialog(false)
		"dup":
			ed.new_diff_dialog(true)
		"ren":
			ed.rename_diff_dialog()
		"del":
			ed.delete_diff_dialog()
		"meta":
			ed.song_meta_dialog()
		"img":
			ed.map_images_dialog(_menu_at(_diff_btn))
		"prev":
			ed.set_preview_here()


func _vsep() -> Control:
	var c: = ColorRect.new()
	c.color = EdTheme.LINE
	c.custom_minimum_size = Vector2(1, 22)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c




func _chip(value: String, caption: String, col: Color, on_click: Callable, 
		tip: = "") -> Label:
	var b: = Button.new()
	b.tooltip_text = tip
	b.custom_minimum_size = Vector2(58, 32)
	EdTheme.style_button(b, Color.TRANSPARENT)
	b.pressed.connect( func(): on_click.call(b))
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", -3)
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var lv: = EdTheme.make_label(value, EdTheme.S_VALUE, col, ed.font)
	lv.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lv)
	var lc: = EdTheme.make_label(caption, EdTheme.S_MICRO, EdTheme.TXT_FAINT, ed.font)
	lc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(lc)
	return lv


func _menu_at(node: Control) -> Vector2:
	return node.get_global_rect().position + Vector2(0, node.size.y + 3)


func _bpm_menu(btn: Button) -> void :
	var items: = [
		{"title": "BPM  %.2f" % ed.bpm}, 
		{"text": "-1.00", "id": "-1", "hint": "Shift+B"}, 
		{"text": "-0.05", "id": "-0.05", "hint": "B"}, 
		{"text": "+0.05", "id": "+0.05", "hint": "N"}, 
		{"text": "+1.00", "id": "+1", "hint": "Shift+N"}, 
		{"sep": true}, 
		{"text": "Type a value...", "id": "edit", "accent": EdTheme.CYAN}, 
		{"text": "Snap grid anchor to cursor", "id": "anchor", "hint": "G"}, 
	]
	EdMenu.open(ed.overlay_host(), items, _menu_at(btn), ed.font, _bpm_pick)


func _bpm_pick(id: String) -> void :
	if id == "":
		return
	if id == "edit":
		ed.inspector.open_tab("tempo")
		ed.flash("TEMPO tab opened in the inspector")
		return
	if id == "anchor":
		ed.push_undo("grid anchor")
		ed.grid_anchor = ed.t
		ed.mark_dirty()
		return
	ed.push_undo("BPM")
	ed.bpm = maxf(20.0, ed.bpm + float(id))
	ed.mark_dirty()


func _sig_menu(btn: Button) -> void :
	var items: Array = [{"title": "BEATS PER BAR"}]
	for n in [2, 3, 4, 5, 6, 7]:
		items.append({"text": "%d/4" % n, "id": str(n), "check": ed.beats_per_bar == n})
	EdMenu.open(ed.overlay_host(), items, _menu_at(btn), ed.font, _sig_pick)


func _sig_pick(id: String) -> void :
	if id == "":
		return
	ed.beats_per_bar = int(id)
	ed.view_changed.emit()
	refresh()


func _grid_menu(btn: Button) -> void :
	var items: Array = [
		{"title": "SNAP"}, 
		{"text": "AUTO - follows the zoom", "id": "auto", "accent": EdTheme.VIOLET, 
			"check": ed.snap_on and ed.grid_manual == 0}, 
	]



	for d in [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 16, 24, 32]:
		items.append({"text": "1/%d" % d, "id": str(d), 
			"check": ed.snap_on and ed.grid_manual == d})
	items.append({"sep": true})
	items.append({"text": "OFF - free placement", "id": "off", "check": not ed.snap_on})
	EdMenu.open(ed.overlay_host(), items, _menu_at(btn), ed.font, _grid_pick)


func _grid_pick(id: String) -> void :
	if id == "":
		return


	if id == "off":
		ed.set_grid(ed.grid_manual, false)
	elif id == "auto":
		ed.set_grid(0, true)
	else:
		ed.set_grid(int(id), true)
	refresh()


func _speed_menu(btn: Button) -> void :
	var items: Array = [{"title": "PLAYBACK SPEED"}]
	for r in [0.5, 0.75, 1.0]:
		items.append({"text": "x%s" % ("1" if r == 1.0 else String.num(r, 2)), "id": str(r), 
			"check": is_equal_approx(ed.play_rate, r)})
	EdMenu.open(ed.overlay_host(), items, _menu_at(btn), ed.font, _speed_pick)


func _speed_pick(id: String) -> void :
	if id == "":
		return
	ed.set_play_rate(float(id))


func _sfx_toggle(_btn: Button) -> void :
	ed.set_view_flag("hit_sounds", not ed.hit_sounds)
	ed.flash("Hit sounds %s" % ("ON" if ed.hit_sounds else "OFF"))


func _charge_menu(_btn: Button) -> void :
	ed.inspector.open_tab("note")
	ed.select_uids([])
	ed.flash("LEVEL breakdown in the inspector")


func _more_menu() -> void :
	var items: = [
		{"title": "MAP"}, 
		{"text": "Save", "id": "save", "hint": "Ctrl+S", "accent": EdTheme.VIOLET}, 
		{"text": "Test play from cursor", "id": "test", "hint": "T", "accent": EdTheme.MINT}, 
		{"sep": true}, 
		{"text": "Record mode (map while playing)", "id": "rec", "hint": "R", 
			"check": ed.recording, "accent": EdTheme.RED}, 
		{"text": "Follow the playhead", "id": "follow", 
			"check": ed.follow_playhead}, 
		{"text": "Hit sounds while playing", "id": "hitsfx", 
			"check": ed.hit_sounds}, 
		{"sep": true}, 
		{"text": "Chart JSON — edit / import...", "id": "json", 
			"accent": EdTheme.CYAN}, 
		{"sep": true}, 
		{"text": "Run the AUTO check", "id": "autocheck", 
			"hint": "before publishing", "accent": EdTheme.RED}, 
		{"sep": true}, 
		{"title": "ONLINE"}, 
		_wip_item(), 
		{"sep": true}, 
		{"title": "BOOKMARKS"}, 
		{"text": "Bookmark here", "id": "bm", "hint": "Ctrl+B", 
			"accent": EdTheme.CYAN}, 
		{"text": "Previous bookmark", "id": "bmprev", "hint": "["}, 
		{"text": "Next bookmark", "id": "bmnext", "hint": "]"}, 
		{"sep": true}, 
		{"text": "All shortcuts...", "id": "help", "hint": "H"}, 
		{"text": "Quit the editor", "id": "quit", "hint": "Esc"}, 
	]
	EdMenu.open(ed.overlay_host(), items, Vector2(size.x - 200, 42), ed.font, 
		_more_pick, 210)








func _wip_item() -> Dictionary:
	var track: String = ed.map_track


	var mine: bool = ed.is_draft() or (MapLibrary.is_user_map(track)
		and MapLibrary.status_of(track) != MapLibrary.STATUS_DOWNLOADED)
	var wip: bool = MapLibrary.online_wip_of(track)
	var online: bool = mine and MapLibrary.is_shared(track)
	var ranked: bool = MapLibrary.online_ranking_of(track) == "ranked"
	if online:
		return {"text": "Mark as finished" if wip else "Mark as WIP", 
			"id": "wip", "accent": EdTheme.GOLD, 
			"disabled": _wip_busy or (ranked and not wip), 
			"hint": "ranked" if ranked else ""}
	return {"text": "Work in progress (WIP)", "id": "wip", 
		"accent": EdTheme.GOLD, "check": wip, "disabled": not mine}


var _wip_busy: = false





func _wip_toggle() -> void :


	if ed.is_draft():
		ed.save()
		if ed.is_draft():
			return
	var track: String = ed.map_track
	if not MapLibrary.is_user_map(track)\
	or MapLibrary.status_of(track) == MapLibrary.STATUS_DOWNLOADED:
		ed.flash("ONLY YOUR OWN MAPS CAN BE MARKED WIP")
		return
	var want: = not MapLibrary.online_wip_of(track)
	if not MapLibrary.is_shared(track):
		MapLibrary.set_online_wip(track, want)
		ed.flash("MARKED AS WORK IN PROGRESS — THE NEXT PUBLISH WILL SAY SO"
			if want else "WIP MARK CLEARED")
		refresh()
		return
	if not Backend.is_logged_in():
		ed.flash("LOG IN FIRST — THIS MAP IS ONLINE")
		return
	var online_id: = String(MapLibrary.meta_of(track).get("online_id", ""))
	if online_id == "":
		ed.flash("THIS MAP HAS NO ONLINE ENTRY YET")
		return
	_wip_busy = true
	ed.flash("UPDATING…")
	var r: Dictionary = await Backend.api_map_set_wip(online_id, want)
	_wip_busy = false
	if not is_instance_valid(ed):
		return
	if r.ok:
		MapLibrary.set_online_wip(track, want)
		ed.flash("MARKED AS WIP — PLAYERS SEE THE BADGE" if want
			else "MARKED AS FINISHED — THE WIP BADGE IS GONE")
		ed.main.sfx.play_ui("impact")
		refresh()
	else:
		ed.flash(MapPublisher.server_error(r, "could not update the WIP flag").to_upper())
		ed.main.sfx.play_ui("back")


func _more_pick(id: String) -> void :
	match id:
		"wip":
			_wip_toggle()
		"save":
			ed.save()
		"test":
			ed.playtest()
		"rec":
			ed.toggle_recording()
		"follow":
			ed.set_view_flag("follow_playhead", not ed.follow_playhead)
		"hitsfx":
			_sfx_toggle(null)
		"json":
			EdJson.open(ed.overlay_host(), ed)
		"autocheck":
			_auto_check(false)
		"bm":
			ed.toggle_bookmark()
		"bmprev":
			ed.seek_bookmark(-1)
		"bmnext":
			ed.seek_bookmark(1)
		"help":
			ed.shortcuts.toggle_help()
		"quit":
			ed.request_quit()




func _on_time() -> void :
	_time_lbl.text = EdTheme.fmt_time(ed.t)
	_beat_lbl.text = "beat %.2f" % ed.beat_of(ed.t)


func refresh() -> void :
	_on_time()
	_bpm_lbl.text = "%.2f" % ed.bpm
	_sig_lbl.text = "%d/4" % ed.beats_per_bar
	_grid_lbl.text = ed.grid_label()
	if _speed_lbl != null:
		_speed_lbl.text = "x%s" % ("1" if is_equal_approx(ed.play_rate, 1.0) else String.num(ed.play_rate, 2))
	if _sfx_lbl != null:
		_sfx_lbl.text = "ON" if ed.hit_sounds else "OFF"
		_sfx_lbl.add_theme_color_override("font_color", 
			EdTheme.MINT if ed.hit_sounds else EdTheme.TXT_DIM)
	var pg = _play_btn.get_meta("glyph")
	pg.glyph = "pause" if ed.playing else "play"
	pg.queue_redraw()
	_undo_btn.disabled = not ed.can_undo()
	_redo_btn.disabled = not ed.can_redo()
	_undo_btn.tooltip_text = ("Undo: %s\nCtrl+Z" % ed.undo_label()) if ed.can_undo()\
	else "Nothing to undo"
	_redo_btn.tooltip_text = ("Redo: %s\nCtrl+Y" % ed.redo_label()) if ed.can_redo()\
	else "Nothing to redo"
	var r: Dictionary = ed.rating
	var rc: Color = r.get("color", EdTheme.GOLD)
	_charge_lbl.text = "%.1f" % float(r.get("level", 0.0))
	_charge_lbl.add_theme_color_override("font_color", rc)
	_tier_lbl.text = String(r.get("tier", ""))
	_tier_lbl.add_theme_color_override("font_color", Color(rc.r, rc.g, rc.b, 0.85))
	_save_btn.text = "  SAVE •  " if ed.dirty else "  SAVE  "



	_title_lbl.text = ed.map_title()
	_diff_btn.text = " %s ▾" % ed.diff_label()
	var state: = ""
	if ed.is_draft():
		state = "not saved yet"
	elif ed.dirty:
		state = "modified"
	elif MapLibrary.status_of(ed.map_track) == MapLibrary.STATUS_DRAFT:
		state = "draft"
	elif MapLibrary.status_of(ed.map_track) == MapLibrary.STATUS_PUBLISHED:
		state = "published"
	_name_lbl.text = state
	_name_lbl.add_theme_color_override("font_color", 
		EdTheme.GOLD if (ed.dirty or ed.is_draft()) else EdTheme.TXT_FAINT)
