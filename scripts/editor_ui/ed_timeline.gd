extends Control
























const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")
const EdFx = preload("res://scripts/editor_ui/ed_fx.gd")
const WavePeaks = preload("res://scripts/wave_peaks.gd")

const GUT: = 48.0
const RULER: = 15.0
const WAVE_H: = 26.0
const LANE_H: = 38.0
const AIM_H: = 32.0
const FX_H: = 17.0
const PAD: = 3.0


const PLAYHEAD_FRAC: = 0.34



const LANE_STAGGER: = 9.0

const GRIP: = 6.0

var ed

var _drag: = ""
var _from: = Vector2.ZERO
var _now: = Vector2.ZERO
var _ref: = {}
var _anchor_t: = 0.0
var _committed: = false
var _hover_uid: = -1
var _hover_fx: = -1
var _hover_grip: = -1


func _ready() -> void :
	custom_minimum_size = Vector2(320, RULER + WAVE_H + LANE_H + AIM_H + FX_H + PAD * 2)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	ed.chart_changed.connect(_on_chart)
	ed.selection_changed.connect(_on_selection)
	ed.time_changed.connect(queue_redraw)
	ed.tool_changed.connect(queue_redraw)
	ed.view_changed.connect(_on_view)
	_build_zoom_strip()
	_on_chart()


func _on_view() -> void :
	_fx_assign_rows()
	custom_minimum_size.y = RULER + WAVE_H + LANE_H + AIM_H + PAD * 2 + fx_height()
	queue_redraw()



func _on_chart() -> void :
	_fx_assign_rows()
	var h: = RULER + WAVE_H + LANE_H + AIM_H + PAD * 2 + fx_height()
	if not is_equal_approx(custom_minimum_size.y, h):
		custom_minimum_size.y = h
	queue_redraw()



func _on_selection() -> void :
	if ed.sel_fx_uid >= 0 and _fx_rows.has(ed.sel_fx_uid):
		var row: int = _fx_rows[ed.sel_fx_uid]
		var vis: = fx_visible_rows()
		if row < _fx_scroll:
			_fx_scroll = row
		elif row >= _fx_scroll + vis:
			_fx_scroll = row - vis + 1
	queue_redraw()



func _build_zoom_strip() -> void :
	var zb: = HBoxContainer.new()
	zb.add_theme_constant_override("separation", 2)
	zb.anchor_left = 1.0
	zb.anchor_right = 1.0
	zb.offset_left = -46
	zb.offset_right = -3
	zb.offset_top = 1
	zb.offset_bottom = 14
	add_child(zb)
	var zm: = EdTheme.text_button("–", "Zoom out - more music on screen\n-", 
		Color.TRANSPARENT, ed.font, EdTheme.S_VALUE)
	zm.custom_minimum_size = Vector2(20, 13)
	zm.pressed.connect( func(): ed.set_zoom(ed.zoom / 1.25))
	zb.add_child(zm)
	var zp: = EdTheme.text_button("+", "Zoom in - the grid gets finer\n+", 
		Color.TRANSPARENT, ed.font, EdTheme.S_VALUE)
	zp.custom_minimum_size = Vector2(20, 13)
	zp.pressed.connect( func(): ed.set_zoom(ed.zoom * 1.25))
	zb.add_child(zp)





func area() -> Rect2:
	return Rect2(GUT, PAD, maxf(size.x - GUT - PAD, 40.0), 
		maxf(size.y - PAD * 2, 40.0))


func ruler_rect() -> Rect2:
	var a: = area()
	return Rect2(a.position.x, a.position.y, a.size.x, RULER)


func wave_rect() -> Rect2:
	var a: = area()
	return Rect2(a.position.x, a.position.y + RULER, a.size.x, WAVE_H)


func lane_rect() -> Rect2:
	var a: = area()
	return Rect2(a.position.x, a.position.y + RULER + WAVE_H, a.size.x, LANE_H)


func aim_rect() -> Rect2:
	var a: = area()
	return Rect2(a.position.x, a.position.y + RULER + WAVE_H + LANE_H, 
		a.size.x, AIM_H)


func fx_rect() -> Rect2:
	var a: = area()
	return Rect2(a.position.x, a.position.y + RULER + WAVE_H + LANE_H + AIM_H, 
		a.size.x, fx_height())





func fx_height() -> float:
	if not ed.show_fx:
		return 0.0
	return FX_ROW_H * float(fx_visible_rows())


func fx_visible_rows() -> int:
	return clampi(_fx_rows_total, FX_MIN_ROWS, FX_MAX_ROWS)


func playhead_x() -> float:
	var a: = area()
	return a.position.x + a.size.x * PLAYHEAD_FRAC


func time_to_x(tt: float) -> float:
	return playhead_x() + (tt - ed.view_t) * ed.zoom


func x_to_time(x: float) -> float:
	return ed.view_t + (x - playhead_x()) / maxf(ed.zoom, 1.0)




func note_y(n: Dictionary) -> float:
	if EdTheme.is_aim_type(String(n.type)):
		var ar: = aim_rect()
		return ar.position.y + ar.size.y * 0.5
	var lr: = lane_rect()
	return lr.position.y + lr.size.y * 0.5\
	+ (float(clampi(int(n.get("lane", 1)), 0, 2)) - 1.0) * LANE_STAGGER


func note_pos(n: Dictionary) -> Vector2:
	return Vector2(time_to_x(float(n.time)), note_y(n))



func note_end_x(n: Dictionary) -> float:
	return time_to_x(float(n.time) + ed.note_span(n))






func visible_notes() -> Array:
	var a: = area()
	var t0: float = x_to_time(a.position.x) - ed.max_span()
	var t1: float = x_to_time(a.end.x)
	var out: Array = []
	var i: int = ed.first_note_at_or_after(t0)
	while i < ed.notes.size():
		var n: Dictionary = ed.notes[i]
		i += 1
		if float(n.time) > t1:
			break
		out.append(n)
	return out





func note_at(pos: Vector2) -> int:
	var tol_x: = clampf(ed.beat_dur() / float(ed.grid_div()) * ed.zoom * 0.45, 
		6.0, 14.0)
	var best: = -1
	var best_d: = INF
	for n in visible_notes():
		var y: = note_y(n)
		if absf(pos.y - y) > LANE_STAGGER + 5.0:
			continue
		var x: = time_to_x(float(n.time))
		var span: float = ed.note_span(n)
		if span > 0.0:
			var xe: = note_end_x(n)
			if pos.x < x - tol_x or pos.x > xe + tol_x:
				continue
			var d: = minf(absf(x - pos.x), tol_x * 0.9)
			if d < best_d:
				best_d = d
				best = int(n._uid)
			continue
		var dx: = absf(x - pos.x)
		if dx > tol_x:
			continue
		if dx < best_d:
			best_d = dx
			best = int(n._uid)
	return best




func grip_at(pos: Vector2) -> int:
	for n in visible_notes():
		if ed.note_span(n) <= 0.0:
			continue
		if absf(pos.y - note_y(n)) > LANE_STAGGER + 5.0:
			continue
		if absf(pos.x - note_end_x(n)) <= GRIP:
			return int(n._uid)
	return -1







const FX_ROW_H: = 13.0
const FX_MIN_ROWS: = 2
const FX_MAX_ROWS: = 5

var _fx_rows: = {}
var _fx_rows_total: = 0
var _fx_scroll: = 0
var _hover_fx_grip: = -1
var _hover_fx_grip_l: = -1


func _fx_assign_rows() -> void :
	_fx_rows.clear()
	var ends: Array = []
	for ev in ed.fx_sorted():
		var e0: = float(ev.get("time", 0.0))
		var e1: = e0 + maxf(float(ev.get("len", 0.0)), 0.0)
		var row: = -1
		for i in ends.size():
			if e0 >= float(ends[i]):
				row = i
				break
		if row < 0:
			row = ends.size()
			ends.append( - INF)
		ends[row] = maxf(e1, e0 + 0.001)
		_fx_rows[int(ev.get("_uid", -1))] = row
	_fx_rows_total = maxi(ends.size(), 1)
	_fx_scroll = clampi(_fx_scroll, 0, maxi(_fx_rows_total - fx_visible_rows(), 0))




func fx_layout() -> Array:
	var a: = area()
	var t0: = x_to_time(a.position.x)
	var t1: = x_to_time(a.end.x)
	var vis: = fx_visible_rows()
	var out: Array = []
	for ev in ed.fx_in_window(t0, t1):
		var uid: = int(ev.get("_uid", -1))
		if not _fx_rows.has(uid):
			_fx_assign_rows()
		var row: int = int(_fx_rows.get(uid, 0)) - _fx_scroll
		if row < 0 or row >= vis:
			continue
		var e0: = float(ev.get("time", 0.0))
		var e1: = e0 + maxf(float(ev.get("len", 0.0)), 0.0)
		out.append({"ev": ev, "row": row, "x0": time_to_x(e0), "x1": time_to_x(e1)})
	return out


func fx_at(pos: Vector2) -> int:
	var r: = fx_rect()
	if not ed.show_fx or pos.y < r.position.y or pos.y > r.end.y:
		return -1
	for item in fx_layout():
		var y0: float = r.position.y + float(item.row) * FX_ROW_H
		if pos.y < y0 or pos.y > y0 + FX_ROW_H:
			continue
		if pos.x >= float(item.x0) - 4.0 and pos.x <= float(item.x1) + 4.0:
			return int(item.ev.get("_uid", -1))
	return -1




func fx_start_grip_at(pos: Vector2) -> int:
	var r: = fx_rect()
	if not ed.show_fx or pos.y < r.position.y or pos.y > r.end.y:
		return -1
	for item in fx_layout():
		var y0: float = r.position.y + float(item.row) * FX_ROW_H
		if pos.y < y0 or pos.y > y0 + FX_ROW_H:
			continue
		if float(item.x1) - float(item.x0) < GRIP * 2.0:
			continue
		if absf(pos.x - float(item.x0)) <= GRIP:
			return int(item.ev.get("_uid", -1))
	return -1



func fx_grip_at(pos: Vector2) -> int:
	var r: = fx_rect()
	if not ed.show_fx or pos.y < r.position.y or pos.y > r.end.y:
		return -1
	for item in fx_layout():
		var y0: float = r.position.y + float(item.row) * FX_ROW_H
		if pos.y < y0 or pos.y > y0 + FX_ROW_H:
			continue
		if float(item.x1) - float(item.x0) < GRIP * 2.0:
			continue
		if absf(pos.x - float(item.x1)) <= GRIP:
			return int(item.ev.get("_uid", -1))
	return -1


func fx_scroll_by(rows: int) -> void :
	var max_scroll: = maxi(_fx_rows_total - fx_visible_rows(), 0)
	var s: = clampi(_fx_scroll + rows, 0, max_scroll)
	if s != _fx_scroll:
		_fx_scroll = s
		queue_redraw()


func cancel_drag() -> bool:
	if _drag == "":
		return false
	if _drag in ["move", "resize", "fx", "fxresize", "fxresize_l"] and _committed:
		ed.undo()
	_drag = ""
	_ref.clear()
	_committed = false
	queue_redraw()
	return true




func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		_now = event.position
		match _drag:
			"move":
				_update_move()
			"resize":
				_update_resize()
			"fx":
				_update_fx_move()
			"fxresize":
				_update_fx_resize()
			"fxresize_l":
				_update_fx_resize_l()
			"scrub":
				ed.seek_to(x_to_time(event.position.x))
				ed.audio_peek()
			"box":
				queue_redraw()
			_:
				_update_hover(event.position)
		return

	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					_wheel(1.0, event)
				MOUSE_BUTTON_WHEEL_DOWN:
					_wheel(-1.0, event)
				MOUSE_BUTTON_LEFT:
					_from = event.position
					_now = event.position
					_committed = false
					_press(event)
				MOUSE_BUTTON_RIGHT:
					_context_menu(event.position)
				MOUSE_BUTTON_MIDDLE:
					_drag = "scrub"
					ed.seek_to(x_to_time(event.position.x))
		elif _drag != "":
			_release(event.position)
		accept_event()


func _update_hover(pos: Vector2) -> void :
	var g: = grip_at(pos)
	var h: = -1 if g >= 0 else note_at(pos)
	var gfx: = fx_grip_at(pos)
	var gfxl: = fx_start_grip_at(pos)
	var hfx: = fx_at(pos)
	if g != _hover_grip or h != _hover_uid or hfx != _hover_fx or gfx != _hover_fx_grip\
	or gfxl != _hover_fx_grip_l:
		_hover_grip = g
		_hover_uid = h
		_hover_fx = hfx
		_hover_fx_grip = gfx
		_hover_fx_grip_l = gfxl
		ed.hover_uid = h
		mouse_default_cursor_shape = Control.CURSOR_HSIZE if (g >= 0 or gfx >= 0 or gfxl >= 0)\
		else Control.CURSOR_ARROW
		queue_redraw()


func _wheel(dir: float, event: InputEventMouseButton) -> void :
	if event.ctrl_pressed:
		ed.set_zoom(ed.zoom * (1.15 if dir > 0.0 else 1.0 / 1.15))
	elif event.shift_pressed:
		ed.seek(dir * ed.grid_div())
	elif ed.show_fx and event.position.y >= fx_rect().position.y\
	and _fx_rows_total > fx_visible_rows():


		fx_scroll_by(-1 if dir > 0.0 else 1)
	else:
		ed.seek(dir)


func _press(event: InputEventMouseButton) -> void :
	var pos: Vector2 = event.position

	if pos.x < GUT or pos.y <= ruler_rect().end.y:
		_drag = "scrub"
		ed.seek_to(x_to_time(pos.x))
		return

	if ed.show_fx and pos.y >= fx_rect().position.y:


		var fx_grip_l: = fx_start_grip_at(pos)
		if fx_grip_l >= 0:
			ed.select_fx(fx_grip_l)
			ed.inspector.open_tab("events")
			_drag = "fxresize_l"
			var evl = ed.fx_by_uid(fx_grip_l)
			_ref = {fx_grip_l: float(evl.get("time", 0.0)) + float(evl.get("len", 1.0))}
			_anchor_t = float(evl.get("time", 0.0))
			return
		var fx_grip: = fx_grip_at(pos)
		if fx_grip >= 0:
			ed.select_fx(fx_grip)
			ed.inspector.open_tab("events")
			_drag = "fxresize"
			_ref = {fx_grip: float(ed.fx_by_uid(fx_grip).get("len", 1.0))}
			_anchor_t = float(ed.fx_by_uid(fx_grip).get("time", 0.0))
			return
		var fx_hit: = fx_at(pos)
		if fx_hit >= 0:



			if event.ctrl_pressed or event.shift_pressed:
				ed.toggle_fx_selection(fx_hit)
				ed.inspector.open_tab("events")
				return
			if not ed.fx_selected(fx_hit) or ed.fx_selection().size() <= 1:
				ed.select_fx(fx_hit)
			ed.inspector.open_tab("events")
			_drag = "fx"
			_ref = {}
			for u in ed.fx_selection():
				_ref[int(u)] = float(ed.fx_by_uid(int(u)).get("time", 0.0))
			_anchor_t = float(ed.fx_by_uid(fx_hit).get("time", 0.0))
		else:
			ed.select_fx(-1)
			ed.seek_to(x_to_time(pos.x))
		return

	if pos.y <= wave_rect().end.y:
		_drag = "scrub"
		ed.seek_to(x_to_time(pos.x))
		return

	if event.shift_pressed and not (event.ctrl_pressed):
		var g0: = grip_at(pos)
		if g0 < 0 and note_at(pos) < 0:
			ed.zone_key(ed.snap(x_to_time(pos.x)))
			return

	var grip: = grip_at(pos)
	if grip >= 0:
		ed.select_uids([grip])
		_drag = "resize"
		_ref = {grip: ed.note_span(ed.note_by_uid(grip))}
		return

	var hit: = note_at(pos)

	if ed.tool == "erase":
		if hit >= 0:
			ed.delete_uids([hit], "erase")
		return
	if hit >= 0:
		if event.shift_pressed or event.ctrl_pressed:
			ed.toggle_uid(hit)
		elif not ed.sel_uids.has(hit):
			ed.select_uids([hit])
		_begin_move(hit)
		return






	if not (event.shift_pressed or event.ctrl_pressed):
		ed.select_uids([])
	_drag = "box"


func _begin_move(anchor_uid: = -1) -> void :
	_drag = "move"
	_ref.clear()
	for uid in ed.sel_uids:
		var n = ed.note_by_uid(uid)
		if n != null:
			_ref[uid] = float(n.time)



	var an = ed.note_by_uid(anchor_uid) if anchor_uid >= 0 else null
	if an != null:
		_anchor_t = float(an.time)
	elif not _ref.is_empty():
		_anchor_t = float(_ref[_ref.keys()[0]])






func _move_dt() -> float:
	var raw: float = x_to_time(_now.x) - x_to_time(_from.x)

	return ed.snap_magnet(_anchor_t + raw, _ref.keys()) - _anchor_t




func _update_move() -> void :
	if _ref.is_empty():
		return
	var dt: float = _move_dt()
	if absf(dt) < 0.0005 and not _committed:
		return
	if not _committed:
		ed.push_undo("move %d note(s)" % _ref.size())
		_committed = true
	for uid in _ref:
		var n = ed.note_by_uid(uid)
		if n == null:
			continue
		var was: = float(n.time)
		n["time"] = clampf(float(_ref[uid]) + dt, 0.0, ed.song_len())


		if EdTheme.is_chain(String(n.type)) and n.has("extra"):
			var shifted: Array = []
			for e in n["extra"]:
				shifted.append([float(e[0]) + (float(n.time) - was), 
					float(e[1]), float(e[2])])
			n["extra"] = shifted
	ed._sort()
	ed.mark_dirty()
	queue_redraw()



func _update_resize() -> void :
	if _ref.is_empty():
		return
	var uid: int = int(_ref.keys()[0])
	var n = ed.note_by_uid(uid)
	if n == null:
		return
	var step: float = ed.beat_dur() / float(ed.grid_div())
	var want: float = maxf(ed.snap_magnet(x_to_time(_now.x), [uid]) - float(n.time), step)
	if is_equal_approx(want, ed.note_span(n)) and not _committed:
		return
	if not _committed:
		ed.push_undo("resize")
		_committed = true
	if EdTheme.is_chain(String(n.type)):


		var steps: Array = ed.chain_steps(n)
		var old: float = maxf(float(steps.back()[0]) - float(steps[0][0]), 0.001)
		var out: Array = []
		for s in steps:
			out.append([float(steps[0][0])
				+ (float(s[0]) - float(steps[0][0])) / old * want, s[1]])
		ed.set_chain_steps(n, out)
	else:
		n["duration"] = snappedf(want, 0.001)
	ed.mark_dirty()
	queue_redraw()




func _fx_free() -> bool:
	return Input.is_key_pressed(KEY_ALT)


func _update_fx_move() -> void :
	if _ref.is_empty():
		return
	var dt: float = (x_to_time(_now.x) - x_to_time(_from.x)) if _fx_free() else _move_dt()
	if absf(dt) < 0.0005 and not _committed:
		return
	if not _committed:
		ed.push_undo("move event")
		_committed = true
	for uid in _ref:
		var ev = ed.fx_by_uid(uid)
		if ev == null:
			continue
		ev["time"] = snappedf(maxf(float(_ref[uid]) + dt, 0.0), 0.001)
		ev.erase("_raw")
	ed.mark_dirty()
	queue_redraw()




func _update_fx_resize() -> void :
	if _ref.is_empty():
		return
	var uid: int = int(_ref.keys()[0])
	var ev = ed.fx_by_uid(uid)
	if ev == null:
		return
	var t0: = float(ev.get("time", 0.0))
	var end: float = x_to_time(_now.x) if _fx_free() else ed.snap_magnet(x_to_time(_now.x), [uid])
	var want: float = maxf(end - t0, 0.05)
	if is_equal_approx(want, float(ev.get("len", 1.0))) and not _committed:
		return
	if not _committed:
		ed.push_undo("resize event")
		_committed = true
	ev["len"] = snappedf(want, 0.001)
	ev.erase("_raw")
	ed.mark_dirty()
	queue_redraw()




func _update_fx_resize_l() -> void :
	if _ref.is_empty():
		return
	var uid: int = int(_ref.keys()[0])
	var ev = ed.fx_by_uid(uid)
	if ev == null:
		return
	var end: float = float(_ref[uid])
	var start: float = x_to_time(_now.x) if _fx_free() else ed.snap_magnet(x_to_time(_now.x), [uid])
	start = clampf(start, 0.0, end - 0.05)
	if is_equal_approx(start, float(ev.get("time", 0.0))) and not _committed:
		return
	if not _committed:
		ed.push_undo("resize event")
		_committed = true
	ev["time"] = snappedf(start, 0.001)
	ev["len"] = snappedf(end - start, 0.001)
	ev.erase("_raw")
	ed.mark_dirty()
	queue_redraw()


func _release(pos: Vector2) -> void :
	match _drag:
		"box":
			_finish_box(pos)
		"move":
			if _committed:
				ed.flash("%d note(s) moved in time" % _ref.size())
		"resize":
			if _committed:
				var n = ed.note_by_uid(int(_ref.keys()[0]))
				if n != null:
					ed.flash("duration %.2f s (%.1f beats)" % [ed.note_span(n), 
						ed.note_span(n) / ed.beat_dur()])
		"fx":
			if _committed:
				ed.flash("event moved")
		"fxresize", "fxresize_l":
			if _committed:
				var ev = ed.fx_by_uid(int(_ref.keys()[0]))
				if ev != null:
					ed.flash("event length %.2f s (%.1f beats)" % [float(ev.get("len", 0.0)), 
						float(ev.get("len", 0.0)) / ed.beat_dur()])
	_drag = ""
	_ref.clear()
	_committed = false
	queue_redraw()


func _finish_box(pos: Vector2) -> void :
	var r: = Rect2(_from, pos - _from).abs()
	if r.size.length() < 5.0:
		return
	var picked: Array = []
	for n in visible_notes():
		if r.has_point(note_pos(n)):
			picked.append(int(n._uid))
	ed.select_uids(picked, Input.is_key_pressed(KEY_SHIFT))

	ed.selection = [x_to_time(r.position.x), x_to_time(r.end.x)]
	ed.flash("%d note(s) selected" % picked.size())




func _context_menu(pos: Vector2) -> void :
	var at: = get_global_rect().position + pos
	set_meta("menu_pos", pos)
	if ed.show_fx and pos.y >= fx_rect().position.y:
		_fx_context_menu(pos, at)
		return
	var hit: = note_at(pos)
	var items: Array = []
	if hit >= 0:
		if not ed.sel_uids.has(hit):
			ed.select_uids([hit])
		var n = ed.note_by_uid(hit)
		items = [
			{"title": "%s · %s" % [EdTheme.type_label(String(n.type)), 
				EdTheme.fmt_time(float(n.time))]}, 
			{"text": "Delete", "id": "del", "hint": "Del", "accent": EdTheme.RED}, 
			{"text": "Duplicate", "id": "dup", "hint": "Ctrl+D"}, 
			{"text": "Copy", "id": "copy", "hint": "Ctrl+C"}, 
			{"text": "Cut", "id": "cut", "hint": "Ctrl+X"}, 
			{"sep": true}, 
			{"title": "CHANGE TYPE"}, 
			{"text": "White", "id": "t:parry", "check": n.type == "parry"}, 
			{"text": "Dodge (red)", "id": "t:dodge", "check": n.type == "dodge", 
				"accent": EdTheme.RED}, 
			{"text": "Aim (yellow)", "id": "t:click", "check": n.type == "click", 
				"accent": EdTheme.GOLD}, 
			{"text": "Aim counter", "id": "t:clickx", "check": n.type == "clickx", 
				"accent": EdTheme.GOLD}, 
			{"text": "Hold", "id": "t:sliderm", "check": n.type == "sliderm"}, 
			{"text": "Slider (yellow)", "id": "t:sliderg", "check": n.type == "sliderg", 
				"accent": EdTheme.GOLD}, 
			{"sep": true}, 
			{"title": "LANE"}, 
			{"text": "Left", "id": "l:0", "check": int(n.get("lane", 1)) == 0, 
				"disabled": EdTheme.is_aim_type(String(n.type))}, 
			{"text": "Center", "id": "l:1", "check": int(n.get("lane", 1)) == 1, 
				"disabled": EdTheme.is_aim_type(String(n.type))}, 
			{"text": "Right", "id": "l:2", "check": int(n.get("lane", 1)) == 2, 
				"disabled": EdTheme.is_aim_type(String(n.type))}, 
			{"sep": true}, 
			{"text": "Go to this timecode", "id": "goto"}, 
			{"text": "Properties...", "id": "props"}, 
		]
	else:
		var tt: float = ed.snap(x_to_time(pos.x))
		items = [
			{"title": "AT %s" % EdTheme.fmt_time(tt)}, 
			{"text": "Go to this timecode", "id": "goto"}, 
			{"text": "Paste here", "id": "paste", "hint": "Ctrl+V", 
				"disabled": ed.clipboard.is_empty() and ed.clipboard_fx.is_empty()}, 
			{"sep": true}, 
			{"text": "Range marker here", "id": "zone", "hint": "A"}, 
			{"text": "Kiai section here", "id": "kiai", "hint": "K", 
				"accent": EdTheme.WARM}, 
			{"text": "Bookmark here", "id": "mark", "hint": "Ctrl+B", 
				"accent": EdTheme.CYAN}, 
			{"text": "Snap grid anchor here", "id": "anchor", "hint": "G"}, 
			{"sep": true}, 
			{"text": "Add an event...", "id": "fxadd", "accent": EdTheme.VIOLET}, 
			{"sep": true}, 
			{"title": "NOTES ARE PLACED IN THE STAGE"}, 
			{"text": "Pick a tool, then click the stage", "id": "", "disabled": true}, 
		]
	EdMenu.open(ed.overlay_host(), items, at, ed.font, _menu_pick, 196)


func _fx_context_menu(pos: Vector2, at: Vector2) -> void :
	var hit: = fx_at(pos)
	var tt: float = ed.snap(x_to_time(pos.x))
	var items: Array = []
	if hit >= 0:
		ed.select_fx(hit)
		ed.inspector.open_tab("events")
		var ev = ed.fx_by_uid(hit)
		items = [
			{"title": "%s · %s" % [EdFx.label(String(ev.get("type", ""))), 
				EdTheme.fmt_time(float(ev.get("time", 0.0)))]}, 
			{"text": "Edit in the inspector", "id": "fxedit", "accent": EdTheme.VIOLET}, 
			{"text": "Duplicate after it", "id": "fxdup"}, 
			{"text": "Go to its start", "id": "fxgoto"}, 
			{"sep": true}, 
			{"text": "Delete", "id": "fxdel", "accent": EdTheme.RED, "hint": "Suppr"}, 
			{"sep": true}, 
			{"text": "Add an event...", "id": "fxadd"}, 
		]
	else:
		items = [{"title": "CHOREOGRAPHY AT %s" % EdTheme.fmt_time(tt)}]
		for tp in EdFx.MENU_ORDER:
			items.append({"text": EdFx.label(tp), "id": "fx:" + tp, 
				"accent": EdFx.color(tp)})
	EdMenu.open(ed.overlay_host(), items, at, ed.font, _menu_pick, 190)


func _fx_add_menu() -> void :
	var pos: Vector2 = get_meta("menu_pos", Vector2.ZERO)
	var items: Array = [{"title": "ADD AN EVENT"}]
	for tp in EdFx.MENU_ORDER:
		items.append({"text": EdFx.label(tp), "id": "fx:" + tp, 
			"accent": EdFx.color(tp)})
	EdMenu.open(ed.overlay_host(), items, get_global_rect().position + pos, 
		ed.font, _menu_pick, 190)


func _menu_pick(id: String) -> void :
	if id == "":
		return
	var pos: Vector2 = get_meta("menu_pos", Vector2.ZERO)
	var tt: float = ed.snap(x_to_time(pos.x))
	if id.begins_with("t:"):
		ed.convert_type(ed.sel_uids.duplicate(), id.substr(2))
		return
	if id.begins_with("l:"):
		ed.set_prop(ed.sel_uids.duplicate(), "lane", int(id.substr(2)), "change lane")
		return
	if id.begins_with("fx:"):
		ed.add_fx(id.substr(3), tt)
		ed.inspector.open_tab("events")
		return
	match id:
		"fxadd":
			_fx_add_menu()
		"fxedit":
			ed.inspector.open_tab("events")
		"fxdup":
			ed.duplicate_fx(ed.sel_fx_uid)
		"fxdel":
			ed.delete_fx(ed.sel_fx_uid)
			ed.flash("event deleted")
		"fxgoto":
			var fev = ed.selected_fx()
			if fev != null:
				ed.seek_to(float(fev.get("time", 0.0)), false)
		"del":
			ed.delete_selection()
		"dup":
			ed.duplicate_uids(ed.sel_uids.duplicate())
		"copy":
			ed.copy_selection(false)
		"cut":
			ed.copy_selection(true)
		"paste":
			ed.paste(false, tt)
		"zone":
			ed.zone_key(tt)
		"kiai":
			ed.kiai_key(tt)
		"mark":
			ed.seek_to(tt)
			ed.toggle_bookmark()
		"anchor":
			ed.push_undo("grid anchor")
			ed.grid_anchor = tt
			ed.mark_dirty()
			ed.flash("grid anchor snapped to %.3f s" % tt)
		"goto":
			ed.seek_to(tt)
		"props":
			ed.inspector.open_tab("note")




func _draw() -> void :
	var a: = area()
	draw_rect(Rect2(Vector2.ZERO, size), EdTheme.PANEL)
	draw_rect(Rect2(Vector2.ZERO, size), EdTheme.LINE, false, 1.0)

	_draw_row_backgrounds()
	_draw_wave()
	_draw_grid()
	_draw_bands()
	_draw_notes()
	if ed.show_fx:
		_draw_fx_strip()
	_draw_gutter()
	_draw_playhead()
	_draw_gestures()
	if ed.recording:
		var rc: Color = Color(1.4, 0.3, 0.3) if ed.playing\
		else Color(0.9, 0.35, 0.35, 0.75)
		draw_circle(Vector2(a.position.x + 10, a.position.y + RULER + 10), 
			4.0 + 3.0 * ed.rec_flash, rc)


func _draw_row_backgrounds() -> void :
	draw_rect(wave_rect(), Color(0.016, 0.02, 0.048, 0.7))
	draw_rect(lane_rect(), Color(0.022, 0.028, 0.06, 0.55))
	draw_rect(aim_rect(), Color(EdTheme.GOLD.r, EdTheme.GOLD.g, EdTheme.GOLD.b, 0.02))
	for r in [wave_rect(), lane_rect(), aim_rect()]:
		draw_line(Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.end.y), 
			EdTheme.LINE, 1.0)





func _draw_wave() -> void :
	var r: = wave_rect()
	var mid: = r.position.y + r.size.y * 0.5
	if ed.wave.is_empty():


		draw_string(ed.font, Vector2(r.position.x + 6, mid + 3), 
			"no waveform for this audio — the grid and the notes still work", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.18))
		return
	var dt: = 1.0 / maxf(ed.zoom, 1.0)
	var col: = Color(0.4, 0.52, 0.95, 0.55)
	var x: = r.position.x
	while x <= r.end.x:
		var t0: = x_to_time(x)
		var h: float = WavePeaks.peak_between(ed.wave, t0, t0 + dt)\
		* r.size.y * 0.46
		if h > 0.2:
			draw_line(Vector2(x, mid - h), Vector2(x, mid + h), col, 1.0)
		x += 1.0
	if ed.wave_building():


		draw_string(ed.font, Vector2(r.end.x - 92, r.position.y + 10), 
			"waveform %d%%" % int(ed.wave_progress() * 100.0), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.3))




func _draw_grid() -> void :
	var a: = area()
	var top: = wave_rect().position.y
	var bot: = aim_rect().end.y



	var division: int = ed.grid_div() if ed.snap_on else 1
	var step: float = ed.beat_dur() / float(division)
	var per_bar: int = division * ed.beats_per_bar
	var t0: = x_to_time(a.position.x)
	var t1: = x_to_time(a.end.x)
	var k0: = floori((t0 - ed.grid_anchor) / step) - 1
	var k1: = ceili((t1 - ed.grid_anchor) / step) + 1
	if k1 - k0 > 4000:
		return
	for k in range(k0, k1 + 1):
		var tt: float = ed.grid_anchor + k * step
		if tt < -0.5:
			continue
		var x: = time_to_x(tt)
		if x < a.position.x - 2.0 or x > a.end.x + 2.0:
			continue
		var on_beat: bool = k % division == 0
		var on_bar: bool = k % per_bar == 0 and ed.show_bars
		var alpha: = 0.26 if on_bar else (0.13 if on_beat else 0.05)
		draw_line(Vector2(x, top if not on_bar else ruler_rect().position.y), 
			Vector2(x, bot), Color(1, 1, 1, alpha), 1.5 if on_bar else 1.0)
		if on_bar:
			var bar: = int(roundf(float(k) / float(per_bar))) + 1
			draw_string(ed.font, Vector2(x + 3, ruler_rect().position.y + 10), 
				str(bar), HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
				Color(1, 1, 1, 0.42))



func _draw_bands() -> void :
	var top: = wave_rect().position.y
	var bot: = aim_rect().end.y
	for k in ed.kiai:
		_band(float(k[0]), float(k[1]), top, bot, 
			Color(EdTheme.WARM.r, EdTheme.WARM.g, EdTheme.WARM.b, 0.045), 
			Color(1.25, 0.68, 0.2, 0.55))
	if ed.kiai_pending() >= 0.0:
		var xp: = time_to_x(ed.kiai_pending())
		draw_line(Vector2(xp, top), Vector2(xp, bot), Color(1.5, 0.8, 0.25, 0.9), 2.0)
		draw_string(ed.font, Vector2(xp + 4, top + 10), 
			"KIAI START — K to close, Esc to cancel", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
			Color(1.5, 0.85, 0.3, 0.85))



	if ed.auto_report_fresh():
		for z in (ed.auto_report.get("zones", []) as Array):
			_band(float(z[0]), float(z[1]), top, bot, 
				Color(1.0, 0.25, 0.3, 0.1), Color(1.0, 0.35, 0.4, 0.7))
	if not ed.selection.is_empty():
		_band(float(ed.selection[0]), float(ed.selection[1]), top, bot, 
			Color(EdTheme.MINT.r, EdTheme.MINT.g, EdTheme.MINT.b, 0.055), 
			Color(0.6, 1.3, 1.0, 0.6))
	if ed.sel_a >= 0.0:
		var xa: = time_to_x(ed.sel_a)
		draw_line(Vector2(xa, top), Vector2(xa, bot), Color(0.6, 1.3, 1.0, 0.85), 2.0)

	var rr: = ruler_rect()
	for bm in ed.bookmarks:
		var bx: = time_to_x(float(bm))
		if bx < rr.position.x - 6.0 or bx > rr.end.x + 6.0:
			continue
		draw_line(Vector2(bx, top), Vector2(bx, bot), 
			Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.22), 1.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(bx, rr.end.y - 7.0), Vector2(bx + 6.0, rr.end.y - 3.5), 
			Vector2(bx, rr.end.y)]), 
			Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.85))


func _band(t0: float, t1: float, top: float, bot: float, fill: Color, 
		edge: Color) -> void :
	var a: = area()
	var x0: = time_to_x(t0)
	var x1: = time_to_x(t1)
	if x1 < a.position.x or x0 > a.end.x:
		return
	var l: = maxf(x0, a.position.x)
	var r: = minf(x1, a.end.x)
	draw_rect(Rect2(l, top, maxf(r - l, 1.0), bot - top), fill)
	if x0 >= a.position.x:
		draw_line(Vector2(x0, top), Vector2(x0, bot), edge, 1.5)
	if x1 <= a.end.x:
		draw_line(Vector2(x1, top), Vector2(x1, bot), edge, 1.5)


func _draw_notes() -> void :
	var a: = area()
	for n in visible_notes():
		var x: = time_to_x(float(n.time))
		var xe: = note_end_x(n)
		if xe < a.position.x - 20.0 or x > a.end.x + 20.0:
			continue
		_draw_note(n, x, xe)





func _draw_note(n: Dictionary, x: float, xe: float) -> void :
	var uid: = int(n.get("_uid", -1))
	var type: = String(n.type)
	var aim: = EdTheme.is_aim_type(type)
	var selected: bool = ed.sel_uids.has(uid)
	var y: = note_y(n)


	var col: Color = EdTheme.accent_for(type)
	if not aim:
		var lane: = clampi(int(n.get("lane", 1)), 0, 2)
		var lc: Color = ed.main.LANE_COLS[lane]
		col = lc if type != "dodge" else EdTheme.RED


	var fade: = 1.0 if float(n.time) >= ed.t - 0.02 else 0.5
	var c: = Color(col.r, col.g, col.b, fade)
	var r: = 7.0
	var p: = Vector2(x, y)


	var span: float = ed.note_span(n)
	if span > 0.0:
		var h: = 5.0 if not aim else 4.0
		draw_rect(Rect2(x, y - h, maxf(xe - x, 2.0), h * 2.0), 
			Color(c.r, c.g, c.b, 0.18 * fade))
		draw_rect(Rect2(x, y - h, maxf(xe - x, 2.0), h * 2.0), 
			Color(c.r, c.g, c.b, 0.6 * fade), false, 1.2)
		var grip_col: = Color(1, 1, 1, 0.85) if _hover_grip == uid\
		else Color(c.r, c.g, c.b, 0.9 * fade)
		draw_rect(Rect2(xe - 1.5, y - h - 2.0, 3.0, (h + 2.0) * 2.0), grip_col)

	match type:
		"parry":
			draw_circle(p, r, Color(0.05, 0.07, 0.1, 0.85 * fade))
			draw_arc(p, r, 0.0, TAU, 20, c, 2.0)
		"dodge":
			draw_colored_polygon(PackedVector2Array([
				p + Vector2(0, - r), p + Vector2(r, 0), p + Vector2(0, r), 
				p + Vector2( - r, 0)]), Color(c.r * 1.15, c.g * 0.9, c.b * 0.9, fade))
			draw_line(p - Vector2(r * 0.4, 0), p + Vector2(r * 0.4, 0), 
				Color(0.1, 0.02, 0.02, fade * 0.8), 1.4)
		"sliderm", "beam":
			draw_circle(p, r * 0.8, c)
		"click", "clickx", "sliderg":
			draw_circle(p, r * 0.9, Color(0.07, 0.06, 0.02, 0.8 * fade))
			draw_arc(p, r, 0.0, TAU, 22, c, 2.0)
			draw_arc(p, r * 0.4, 0.0, TAU, 14, Color(1.3, 1.25, 1.0, fade * 0.9), 1.2)
			for d in [Vector2(0, 1), Vector2(0, -1)]:
				draw_line(p + d * r, p + d * (r + 3.0), c, 1.2)
			if type == "clickx":



				var steps: Array = ed.chain_steps(n)
				for i in range(1, steps.size()):
					var sx: = time_to_x(float(steps[i][0]))
					draw_arc(Vector2(sx, y), r * 0.45, 0.0, TAU, 12, 
						Color(c.r, c.g, c.b, 0.9 * fade), 1.6)
				draw_string(ed.font_display, p + Vector2(r + 3, 4), 
					"×%d" % steps.size(), HORIZONTAL_ALIGNMENT_LEFT, -1, 
					EdTheme.S_MICRO, c)
		_:
			draw_arc(p, r, 0.0, TAU, 18, c, 1.8)


	var nv: = float(n.get("v", 1.0))
	if nv > 1.05 or nv < 0.95:
		var vc: = Color(1.1, 0.34, 0.28, 0.4 * fade) if nv > 1.0\
		else Color(0.34, 0.58, 1.1, 0.4 * fade)
		draw_arc(p, r + 3.0, 0.0, TAU, 20, vc, 1.2)

	if _hover_uid == uid and not selected:
		draw_arc(p, r + 4.0, 0.0, TAU, 22, Color(1, 1, 1, 0.35), 1.0)
	if selected:
		var s: = r + 5.0
		draw_arc(p, s + 2.0, 0.0, TAU, 24, 
			Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.18), 4.0)
		for sx2 in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				var cn: = p + Vector2(sx2 * s, sy * s)
				draw_line(cn, cn - Vector2(sx2 * 3.5, 0), EdTheme.CYAN, 1.5)
				draw_line(cn, cn - Vector2(0, sy * 3.5), EdTheme.CYAN, 1.5)





func _draw_fx_strip() -> void :
	var r: = fx_rect()
	var f: Font = ed.font
	draw_rect(r, Color(0.02, 0.018, 0.042, 0.55))
	var rh: float = FX_ROW_H
	var vis: = fx_visible_rows()

	for i in vis:
		if i % 2 == 1:
			draw_rect(Rect2(r.position.x, r.position.y + float(i) * rh, r.size.x, rh), 
				Color(1, 1, 1, 0.025))
	for item in fx_layout():
		var ev: Dictionary = item.ev
		var uid: = int(ev.get("_uid", -1))
		var type: = String(ev.get("type", ""))
		var c: Color = EdFx.color(type)
		var selected: bool = ed.fx_selected(uid)
		var hovered: bool = _hover_fx == uid or _hover_fx_grip == uid or _hover_fx_grip_l == uid
		var y0: float = r.position.y + float(item.row) * rh
		var x0: float = maxf(float(item.x0), r.position.x - 20.0)
		var x1: float = minf(maxf(float(item.x1), float(item.x0) + 3.0), 
			r.end.x + 20.0)
		var body: = Rect2(x0, y0 + 1.0, maxf(x1 - x0, 3.0), rh - 2.0)
		draw_rect(body, Color(c.r, c.g, c.b, 0.3 if selected else 0.16))
		draw_rect(body, Color(c.r, c.g, c.b, 0.95 if selected else
			(0.7 if hovered else 0.45)), false, 1.0)


		draw_rect(Rect2(x0, y0 + 1.0, 2.0, rh - 2.0), c)


		if (selected or hovered) and body.size.x >= GRIP * 2.0:
			var gx: = body.end.x
			draw_rect(Rect2(gx - 3.0, y0 + 1.0, 3.0, rh - 2.0), 
				Color(c.r, c.g, c.b, 0.95 if _hover_fx_grip == uid
					or _drag == "fxresize" else 0.55))
			draw_rect(Rect2(x0, y0 + 1.0, 3.0, rh - 2.0), 
				Color(c.r, c.g, c.b, 0.95 if _hover_fx_grip_l == uid
					or _drag == "fxresize_l" else 0.55))


		var txt: = "%s · %s" % [EdFx.label(type), EdFx.short(ev)]
		var tw: float = f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO).x
		if selected or hovered or body.size.x >= tw + 10.0:
			draw_string(f, Vector2(x0 + 5.0, y0 + rh - 3.0), txt, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
				c if (selected or hovered) else Color(c.r, c.g, c.b, 0.75))

	if _fx_rows_total > vis:
		var track: = Rect2(r.end.x - 4.0, r.position.y + 1.0, 3.0, r.size.y - 2.0)
		draw_rect(track, Color(1, 1, 1, 0.06))
		var frac: = float(vis) / float(_fx_rows_total)
		var th: = maxf(track.size.y * frac, 6.0)
		var ty: float = track.position.y + (track.size.y - th)\
		* float(_fx_scroll) / float(maxi(_fx_rows_total - vis, 1))
		draw_rect(Rect2(track.position.x, ty, track.size.x, th), 
			Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 0.7))
		var hint: = "%d-%d / %d  (wheel)" % [_fx_scroll + 1, _fx_scroll + vis, _fx_rows_total]
		var hw: float = f.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO).x
		draw_string(f, Vector2(r.end.x - 8.0 - hw, r.position.y + 10.0), hint, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.3))
	if ed.fx_events.is_empty():
		draw_string(f, Vector2(r.position.x + 5, r.end.y - 5), 
			"no choreography events — right-click here to add one", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.18))




func _draw_gutter() -> void :
	var f: Font = ed.font
	draw_rect(Rect2(0, 0, GUT, size.y), Color(0.016, 0.02, 0.045, 0.96))
	draw_line(Vector2(GUT, 0), Vector2(GUT, size.y), EdTheme.LINE, 1.0)
	draw_string(f, Vector2(4, ruler_rect().position.y + 10), "BAR", 
		HORIZONTAL_ALIGNMENT_LEFT, GUT - 6, EdTheme.S_MICRO, Color(1, 1, 1, 0.25))
	draw_string(f, Vector2(4, wave_rect().position.y + 15), "WAVE", 
		HORIZONTAL_ALIGNMENT_LEFT, GUT - 6, EdTheme.S_MICRO, Color(1, 1, 1, 0.25))


	var lr: = lane_rect()
	draw_string(f, Vector2(4, lr.position.y + 11), "LANES", 
		HORIZONTAL_ALIGNMENT_LEFT, GUT - 6, EdTheme.S_MICRO, Color(1, 1, 1, 0.3))
	for i in 3:
		draw_circle(Vector2(GUT - 9.0, lr.position.y + lr.size.y * 0.5
			+ (float(i) - 1.0) * LANE_STAGGER), 2.6, 
			Color(ed.main.LANE_COLS[i].r, ed.main.LANE_COLS[i].g, 
				ed.main.LANE_COLS[i].b, 0.85))
	draw_string(f, Vector2(4, aim_rect().position.y + 14), "AIM", 
		HORIZONTAL_ALIGNMENT_LEFT, GUT - 6, EdTheme.S_MICRO, 
		Color(EdTheme.GOLD.r, EdTheme.GOLD.g, EdTheme.GOLD.b, 0.75))
	if ed.show_fx:
		draw_string(f, Vector2(4, fx_rect().position.y + 12), "CHOREO", 
			HORIZONTAL_ALIGNMENT_LEFT, GUT - 6, EdTheme.S_MICRO, 
			Color(EdTheme.VIOLET.r, EdTheme.VIOLET.g, EdTheme.VIOLET.b, 0.8))


func _draw_playhead() -> void :
	var a: = area()
	var px: = playhead_x()
	var col: Color = ed.main.neon(EdTheme.MINT, 1.4)
	draw_line(Vector2(px, a.position.y), Vector2(px, a.end.y), col, 2.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(px - 5, a.position.y), Vector2(px + 5, a.position.y), 
		Vector2(px, a.position.y + 6)]), col)
	var tl: = EdTheme.fmt_time(ed.t)
	var f: Font = ed.font
	var tw: float = f.get_string_size(tl, HORIZONTAL_ALIGNMENT_LEFT, -1, 
		EdTheme.S_MICRO).x
	var bx: float = clampf(px + 4.0, a.position.x, a.end.x - tw - 6.0)
	draw_rect(Rect2(bx - 2, a.position.y + 1, tw + 5, 12), 
		Color(0.02, 0.04, 0.05, 0.92))
	draw_string(f, Vector2(bx, a.position.y + 10), tl, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, EdTheme.MINT)


func _draw_gestures() -> void :
	if _drag == "box":
		var r: = Rect2(_from, _now - _from).abs()
		draw_rect(r, Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.08))
		draw_rect(r, Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.7), 
			false, 1.0)
	elif _drag == "resize" and not _ref.is_empty():
		var n = ed.note_by_uid(int(_ref.keys()[0]))
		if n != null:
			var beats: float = ed.note_span(n) / ed.beat_dur()
			draw_string(ed.font, _now + Vector2(10, -6), "%.2f beats" % beats, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_SMALL, EdTheme.GOLD)
	elif _drag == "move" and _committed:
		var dt: float = _move_dt()
		draw_string(ed.font, _now + Vector2(10, -6), "%+.3f s" % dt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_SMALL, EdTheme.CYAN)
