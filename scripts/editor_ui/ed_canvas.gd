extends PanelContainer





















const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")
const StageRender = preload("res://scripts/stage_render.gd")


const RATIOS: = [
	["16:9", 16.0 / 9.0, "The editing frame. 1280x720 - the coordinates\n"
		+ "written in the chart."], 
	["16:10", 16.0 / 10.0, "Preview only: a 16:10 screen. Read-only."], 
	["21:9", 21.0 / 9.0, "Preview only: an ultrawide screen. The lanes\n"
		+ "re-center, the aim notes keep their absolute x -\n"
		+ "this is where you see them drift. Read-only."], 
	["4:3", 4.0 / 3.0, "Preview only: a 4:3 screen. Read-only."], 
]

var ed
var view
var _mode_lbl: Label
var _xy_lbl: Label
var _ratio_box: AspectRatioContainer
var _ratio_btns: Array = []


func _ready() -> void :
	EdTheme.skin_panel(self)
	var m: = MarginContainer.new()
	m.add_theme_constant_override("margin_left", 5)
	m.add_theme_constant_override("margin_right", 5)
	m.add_theme_constant_override("margin_top", 4)
	m.add_theme_constant_override("margin_bottom", 5)
	add_child(m)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	m.add_child(v)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 6)
	v.add_child(head)
	var title: = EdTheme.make_label("STAGE", EdTheme.S_MICRO, 
		Color(1, 1, 1, 0.38), ed.font)
	title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(title)
	_mode_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.GOLD, ed.font)
	_mode_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_mode_lbl)
	_xy_lbl = EdTheme.make_label("", EdTheme.S_MICRO, EdTheme.TXT_FAINT, ed.font)
	_xy_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_xy_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(_xy_lbl)
	for r in RATIOS:
		var b: = EdTheme.text_button(String(r[0]), String(r[2]), 
			Color.TRANSPARENT, ed.font, EdTheme.S_MICRO)
		b.custom_minimum_size = Vector2(34, 15)
		var ratio: float = float(r[1])
		b.pressed.connect( func(): _set_ratio(ratio))
		head.add_child(b)
		_ratio_btns.append([b, ratio])


	_ratio_box = AspectRatioContainer.new()
	_ratio_box.ratio = ed.preview_ratio
	_ratio_box.stretch_mode = AspectRatioContainer.STRETCH_FIT
	_ratio_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_ratio_box)
	view = View.new()
	view.ed = ed
	_ratio_box.add_child(view)

	ed.selection_changed.connect(_refresh)
	ed.chart_changed.connect(_refresh)
	ed.tool_changed.connect(_refresh)
	ed.view_changed.connect(_refresh)
	ed.time_changed.connect(view.queue_redraw)
	_refresh()


func _set_ratio(r: float) -> void :
	var same: bool = is_equal_approx(ed.preview_ratio, r)
	ed.preview_ratio = r



	_ratio_box.ratio = r
	if same:
		return
	if ed.previewing():
		ed.flash("preview %d x 720 - read-only, editing stays in the 1280 frame"
			%int(ed.preview_width()))
	else:
		ed.flash("back to the 1280 x 720 editing frame")
	ed.view_changed.emit()


func _refresh() -> void :
	if _ratio_box != null:
		_ratio_box.ratio = ed.preview_ratio
	for pair in _ratio_btns:
		var on: bool = is_equal_approx(float(pair[1]), ed.preview_ratio)
		(pair[0] as Button).modulate = Color(1, 1, 1, 1.0 if on else 0.45)
	var n = ed.focus_note()
	if ed.previewing():
		_mode_lbl.text = "● PREVIEW %d x 720 — READ-ONLY" % int(ed.preview_width())
		_mode_lbl.add_theme_color_override("font_color", EdTheme.WARM)
	elif ed.chain_building_uid >= 0:
		_mode_lbl.text = "● BUILDING A CHAIN — click to add a step, Esc to finish"
		_mode_lbl.add_theme_color_override("font_color", EdTheme.GOLD)
	elif n != null and String(n.type) == "sliderg":
		_mode_lbl.text = "● PATH — click the rail to add a corner"
		_mode_lbl.add_theme_color_override("font_color", EdTheme.GOLD)
	else:
		_mode_lbl.text = ""
	_xy_lbl.text = _readout(n)
	view.queue_redraw()





func _readout(n) -> String:
	if ed.previewing():
		return "checking how the map reads on a wider screen — click 16:9 to edit"
	if n == null:
		return "click a lane to place a lane note · click anywhere to place an aim note"
	var vs: Vector2 = ed.play_size()
	var label: String = EdTheme.type_label(String(n.type))
	if EdTheme.is_aim_type(String(n.type)):
		var px: = float(n.get("x", vs.x * 0.5))
		var py: = float(n.get("y", 300.0))
		return "%s · %s · X %s (%d px) · Y %s (%d px)" % [label, 
			EdTheme.fmt_time(float(n.time)), 
			EdTheme.fmt_pct(px / vs.x), int(px), 
			EdTheme.fmt_pct(py / vs.y), int(py)]
	return "%s · %s · lane %s" % [label, EdTheme.fmt_time(float(n.time)), 
		["LEFT", "CENTER", "RIGHT"][clampi(int(n.get("lane", 1)), 0, 2)]]




class View extends Control:
	const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
	const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")
	const EdFx = preload("res://scripts/editor_ui/ed_fx.gd")
	const StageRender = preload("res://scripts/stage_render.gd")
	const FxEval = preload("res://scripts/fx_eval.gd")
	const FxParticles = preload("res://scripts/fx_particles.gd")
	const FxFonts = preload("res://scripts/fx_fonts.gd")
	const FxImages = preload("res://scripts/fx_images.gd")




	const POST: = 0.16

	const PICK: = 34.0

	var ed
	var _drag: = ""

	var _trail: = PackedVector2Array()
	var _drag_uid: = -1
	var _drag_step: = -1
	var _drag_pt: = -1
	var _hold_ref: = 0.0
	var _drag_lane_ref: = {}
	var _hover_pt: = -1
	var _path_u: = -1.0
	var _path_p: = Vector2.ZERO
	var _drag_ref: = Vector2.ZERO
	var _grab: = Vector2.ZERO
	var _from: = Vector2.ZERO
	var _now: = Vector2.ZERO
	var _committed: = false
	var _guides: Array = []
	var _hover_uid: = -1
	var _mouse: = Vector2(NAN, NAN)


	var _fx_ref: = {}
	var _hover_fx_uid: = -1
	var _hover_fx_handle: = -1

	func _init() -> void :
		mouse_filter = Control.MOUSE_FILTER_STOP
		clip_contents = true
		custom_minimum_size = Vector2(320, 180)









	func vw() -> float:
		return ed.preview_width()


	func k() -> float:
		return size.y / maxf(ed.PLAY_H, 1.0)

	func p2s(p: Vector2) -> Vector2:
		return p * k()

	func s2p(s: Vector2) -> Vector2:
		return s / maxf(k(), 0.0001)



	func tun():
		return ed.main.tuning




	func kiai_mult(tt: float) -> float:
		return tun().kiai_velocity_mult if ed.kiai_at(tt) >= 0 else 1.0





	func speed_of(n: Dictionary) -> float:
		return maxf(ed.chart_vel * float(n.get("v", 1.0))
			* kiai_mult(float(n.time)), 0.05)



	func lead_of(n: Dictionary) -> float:
		var type: = String(n.type)
		var base: float = tun().travel_time
		if type == "click" or type == "clickx":
			base = tun().click_approach_time
		elif type == "sliderg":
			base = tun().sliderg_approach_time
		return base / speed_of(n)


	func fall_y(n: Dictionary, prog: float) -> float:
		return lerpf(tun().spawn_y, tun().hit_y, clampf(prog, 0.0, 1.0))



	func lane_x_of(n: Dictionary, spawn_t: float) -> float:
		return ed.lane_center(clampi(int(n.get("lane", 1)), 0, 2), spawn_t, vw())


	func lane_x_at(i: int, y: float, tt: float) -> float:
		var cx: float = ed.lane_center(i, tt, vw())
		var center: = vw() * 0.5
		var kk: = lerpf(ed.main.LANE_PERSPECTIVE, 1.0, 
			clampf(y / tun().hit_y, 0.0, 1.0))
		return center + (cx - center) * kk










	func layout() -> Array:
		var t: float = ed.t
		var out: Array = []
		var sel: Array = ed.sel_uids
		var taken: = {}





		var t_lo: float = t - ed.max_span() - POST
		var t_hi: float = t + ed.max_lead()
		var i: int = ed.first_note_at_or_after(t_lo)
		while i < ed.notes.size():
			var n: Dictionary = ed.notes[i]
			i += 1
			if float(n.time) > t_hi:
				break
			var uid: = int(n.get("_uid", -1))
			var lead: = lead_of(n)
			var span: float = ed.note_span(n)
			if t < float(n.time) - lead or t > float(n.time) + span + POST:
				continue
			var item: = _place(n, t, lead, span, sel.has(uid))
			if not item.is_empty():
				taken[uid] = true
				out.append(item)



		for uid in sel:
			if taken.has(uid):
				continue
			var n = ed.note_by_uid(uid)
			if n == null:
				continue
			var item: = _place(n, t, lead_of(n), ed.note_span(n), true)
			if not item.is_empty():
				out.append(item)
		out.sort_custom( func(a, b): return float(a.n.time) > float(b.n.time))
		return out

	func _place(n: Dictionary, t: float, lead: float, span: float, 
			forced: bool) -> Dictionary:
		var type: = String(n.type)
		var item: = {"n": n, "uid": int(n.get("_uid", -1)), "type": type, 
			"lead": lead, "span": span, "forced": forced, 
			"ring": 0.0, "prog": 1.0, "alpha": 1.0, 
			"pos": Vector2.ZERO}
		var live: bool = ed.show_approach and not forced_static(n, t)
		match type:
			"parry", "dodge":
				var prog: = 1.0 if not live else 1.0 - (float(n.time) - t) / maxf(lead, 0.001)
				item.prog = prog
				item.pos = Vector2(lane_x_of(n, float(n.time) - lead), 
					fall_y(n, prog))
				item.alpha = clampf(0.4 + 0.7 * clampf(prog, 0.0, 1.0), 0.0, 1.0)
				if prog > 1.0:
					item.alpha *= clampf(1.0 - (t - float(n.time)) / POST, 0.0, 1.0)
			"click":
				item.pos = aim_pos(n)
				var p: = 0.0 if not live else clampf(
					(float(n.time) - t) / maxf(lead, 0.001), 0.0, 1.0)
				item.ring = tun().click_hit_radius\
				+ p * (tun().click_ring_start_radius - tun().click_hit_radius)
				item.alpha = 1.0 if not live else clampf((1.0 - p) / 0.35, 0.0, 1.0)
				if t > float(n.time):
					item.alpha *= clampf(1.0 - (t - float(n.time)) / POST, 0.0, 1.0)
			"clickx":
				var steps: Array = ed.chain_steps(n)
				var idx: = 0
				while idx + 1 < steps.size() and t > float(steps[idx][0]):
					idx += 1
				item["steps"] = steps
				item["idx"] = idx
				item.pos = chain_pos(steps, idx, t, live)
				var win: float = lead if idx == 0 else maxf(
					float(steps[idx][0]) - float(steps[idx - 1][0]), 0.08)
				var pc: = 0.0 if not live else clampf(
					(float(steps[idx][0]) - t) / maxf(win, 0.001), 0.0, 1.0)
				var start: float = tun().click_hit_radius\
				+ (tun().click_ring_start_radius - tun().click_hit_radius)\
				* clampf(win / maxf(lead, 0.001), 0.45, 1.0)
				item.ring = tun().click_hit_radius\
				+ pc * (start - tun().click_hit_radius)
				item.alpha = 1.0 if ( not live or idx > 0)\
				else clampf((1.0 - pc) / 0.35, 0.0, 1.0)
				var last: float = float(steps.back()[0])
				if t > last:
					item.alpha *= clampf(1.0 - (t - last) / POST, 0.0, 1.0)
			"sliderg":
				item.pos = aim_pos(n)
				var ps: = 0.0 if not live else clampf(
					(float(n.time) - t) / maxf(lead, 0.001), 0.0, 1.0)
				item.ring = tun().click_hit_radius\
				+ ps * (tun().click_ring_start_radius - tun().click_hit_radius)
				item.alpha = 1.0 if not live else clampf((1.0 - ps) / 0.35, 0.0, 1.0)
				var endt: float = float(n.time) + span
				if t > endt:
					item.alpha *= clampf(1.0 - (t - endt) / POST, 0.0, 1.0)
			"sliderm", "beam":
				var progm: = 1.0 if not live else 1.0 - (float(n.time) - t) / maxf(lead, 0.001)
				item.prog = progm
				item.pos = Vector2(lane_x_at(clampi(int(n.get("lane", 1)), 0, 2), 
					fall_y(n, progm), float(n.time)), fall_y(n, progm))
				item.alpha = clampf(0.4 + 0.7 * clampf(progm, 0.0, 1.0), 0.0, 1.0)
				var e2: float = float(n.time) + span
				if t > e2:
					item.alpha *= clampf(1.0 - (t - e2) / POST, 0.0, 1.0)
			_:
				item.pos = aim_pos(n)
		return item




	func forced_static(n: Dictionary, t: float) -> bool:
		var lead: = lead_of(n)
		return t < float(n.time) - lead or t > float(n.time) + ed.note_span(n) + POST


	func aim_pos(n: Dictionary) -> Vector2:
		if String(n.type) == "sliderg" and not n.get("points", []).is_empty():
			return ed.slider_point_at(n, 0.0)
		return Vector2(float(n.get("x", ed.PLAY_W * 0.5)), float(n.get("y", 300.0)))




	func chain_pos(steps: Array, idx: int, t: float, live: bool) -> Vector2:
		if idx <= 0 or not live:
			return steps[idx][1]
		var t0: float = float(steps[idx - 1][0])
		var t1: float = float(steps[idx][0])
		var kk: = clampf((t - t0) / maxf((t1 - t0) * 0.45, 0.05), 0.0, 1.0)
		kk = kk * kk * (3.0 - 2.0 * kk)
		return (steps[idx - 1][1] as Vector2).lerp(steps[idx][1] as Vector2, kk)





	func note_at(spos: Vector2) -> int:
		var p: = s2p(spos)
		var items: = layout()
		var best: = -1
		var best_d: = PICK
		for i in range(items.size() - 1, -1, -1):
			var it: Dictionary = items[i]
			var d: float = (it.pos as Vector2).distance_to(p)

			if String(it.type) == "sliderg":
				var hit: = slider_hit_path(it.n, spos)
				d = minf(d, float(hit[1]) / maxf(k(), 0.0001))
			if d < best_d:
				best_d = d
				best = int(it.uid)
		return best


	func lane_at(p: Vector2) -> int:
		var best: = 1
		var bd: = INF
		for i in 3:
			var d: float = absf(p.x - lane_x_at(i, p.y, ed.t))
			if d < bd:
				bd = d
				best = i
		return best



	func sel_slider():
		var n = ed.focus_note()
		if n != null and String(n.type) == "sliderg":
			return n
		return null

	func slider_point_at_screen(n: Dictionary, spos: Vector2) -> int:
		var pts: Array = ed.slider_path(n)
		var best: = -1
		var best_d: = 11.0
		for i in pts.size():
			var d: = p2s(Vector2(float(pts[i][1]), float(pts[i][2]))).distance_to(spos)
			if d < best_d:
				best_d = d
				best = i
		return best



	func slider_hit_path(n: Dictionary, spos: Vector2) -> Array:
		var pts: Array = ed.slider_path(n)
		var best_u: = -1.0
		var best_d: = INF
		var best_p: = Vector2.ZERO
		for i in range(pts.size() - 1):
			var a: = Vector2(float(pts[i][1]), float(pts[i][2]))
			var b: = Vector2(float(pts[i + 1][1]), float(pts[i + 1][2]))
			var sa: = p2s(a)
			var sb: = p2s(b)
			var seg: = sb - sa
			var len2: = seg.length_squared()
			var kk: float = 0.0 if len2 < 0.0001\
			else clampf((spos - sa).dot(seg) / len2, 0.0, 1.0)
			var d: = (sa + seg * kk).distance_to(spos)
			if d < best_d:
				best_d = d
				best_u = lerpf(float(pts[i][0]), float(pts[i + 1][0]), kk)
				best_p = a.lerp(b, kk)
		return [best_u, best_d, best_p]

	func chain_step_at(n: Dictionary, spos: Vector2) -> int:
		var best: = -1
		var best_d: = 18.0
		var steps: Array = ed.chain_steps(n)
		for i in steps.size():
			var d: = p2s(steps[i][1]).distance_to(spos)
			if d < best_d:
				best_d = d
				best = i
		return best





	func apply_position(n: Dictionary, p: Vector2, with_undo: bool) -> void :
		p = ed.clamp_playfield(p)
		if with_undo:
			ed.push_undo("move aim")
		if String(n.type) == "sliderg" and not n.get("points", []).is_empty():
			var old: Vector2 = ed.slider_point_at(n, 0.0)
			ed.offset_slider_points(n, p - old)
		n["x"] = p.x
		n["y"] = p.y
		ed.mark_dirty()
		queue_redraw()



	func snap_guides(p: Vector2, n) -> Vector2:
		_guides.clear()
		var tol: = 14.0
		var xs: Array = [ed.PLAY_W * 0.5]
		var ys: Array = [tun().hit_y * 0.5]
		for i in 3:
			xs.append(ed.lane_center(i))
		for g in neighbours(n):
			if g != null:
				xs.append(aim_pos(g).x)
				ys.append(aim_pos(g).y)
		for x in xs:
			if absf(p.x - float(x)) < tol:
				p.x = float(x)
				_guides.append(["v", float(x)])
				break
		for y in ys:
			if absf(p.y - float(y)) < tol:
				p.y = float(y)
				_guides.append(["h", float(y)])
				break
		return p


	func neighbours(n) -> Array:
		if n == null:
			return [null, null]
		var list: Array = []
		for m in ed.notes:
			if EdTheme.is_aim_type(String(m.type)):
				list.append(m)
		var uid: = int(n.get("_uid", -1))
		var i: = -1
		for j in list.size():
			if int(list[j]._uid) == uid:
				i = j
				break
		if i < 0:
			return [null, null]
		return [list[i - 1] if i > 0 else null, 
			list[i + 1] if i < list.size() - 1 else null]



	func _gui_input(event: InputEvent) -> void :
		if event is InputEventMouseMotion:
			_now = event.position
			_mouse = s2p(event.position)
			if _drag == "draw":
				_trail.append(s2p(event.position))
			elif _drag != "":
				_update_drag(event)
			else:
				_update_hover(event.position)
			queue_redraw()
			return
		if event is InputEventMouseButton:
			if event.pressed:
				match event.button_index:
					MOUSE_BUTTON_LEFT:
						_from = event.position
						_now = event.position
						_press(event)
						accept_event()
					MOUSE_BUTTON_RIGHT:
						_right_press(event)
						accept_event()
					MOUSE_BUTTON_WHEEL_UP:
						ed.seek(1.0)
						accept_event()
					MOUSE_BUTTON_WHEEL_DOWN:
						ed.seek(-1.0)
						accept_event()
			elif event.button_index == MOUSE_BUTTON_LEFT:
				_release(event.position)
				accept_event()

	func _update_hover(spos: Vector2) -> void :
		var h: = note_at(spos)
		if h != _hover_uid:
			_hover_uid = h
			ed.hover_uid = h

		_hover_fx_handle = fx_handle_at(spos)
		_hover_fx_uid = -1 if (h >= 0 or _hover_fx_handle >= 0) else fx_box_at(spos)


		var sl = sel_slider()
		_hover_pt = -1
		_path_u = -1.0
		if sl != null and not ed.previewing():
			_hover_pt = slider_point_at_screen(sl, spos)
			if _hover_pt < 0:
				var hit: = slider_hit_path(sl, spos)
				if float(hit[1]) < 9.0:
					_path_u = float(hit[0])
					_path_p = hit[2]

		if not EdTheme.is_aim_type(String(ed.tool)):
			ed.rec_lane = lane_at(s2p(spos))

	func _press(event: InputEventMouseButton) -> void :
		var spos: Vector2 = event.position
		var p: = s2p(spos)
		if ed.previewing():
			ed.flash("preview mode is read-only — click 16:9 to edit again")
			return

		if ed.recording and ed.playing:
			ed.record_note("click", p)
			return

		if ed.chain_building_uid >= 0:
			var cn = ed.note_by_uid(ed.chain_building_uid)
			if cn != null:
				ed.add_chain_step(ed.chain_building_uid, p)
				ed.flash("step %d placed — Esc to finish the chain"
					%ed.chain_steps(cn).size())
				ed.canvas._refresh()
				return
			ed.chain_building_uid = -1





		if ed.tool == "drawpath":
			var target = sel_slider()
			if target == null:
				ed.flash("select a yellow slider first, then draw its shape")
				return
			_drag = "draw"
			_drag_uid = int(target._uid)
			_trail = PackedVector2Array([p])
			return


		var sl = sel_slider()
		if sl != null:
			var pt: = slider_point_at_screen(sl, spos)
			if pt >= 0:
				var pts: Array = ed.slider_path(sl)
				_begin("point", int(sl._uid), Vector2(float(pts[pt][1]), 
					float(pts[pt][2])), p)
				_drag_pt = pt
				return
			var hit: = slider_hit_path(sl, spos)
			if float(hit[1]) < 9.0:
				var idx: int = ed.insert_slider_point(int(sl._uid), 
					float(hit[0]), hit[2])
				if idx >= 0:


					_begin("point", int(sl._uid), hit[2], p)
					_drag_pt = idx
					_committed = true
					_path_u = -1.0
					ed.canvas._refresh()
				return



		var sh = ed.focus_note()
		if is_hold(sh) and spos.distance_to(hold_tail_screen(sh)) <= 14.0:
			_drag = "holdlen"
			_drag_uid = int(sh._uid)
			_hold_ref = ed.note_span(sh)
			_committed = false
			return

		var sc = ed.focus_note()
		if sc != null and EdTheme.is_chain(String(sc.type)):
			var si: = chain_step_at(sc, spos)
			if si >= 0:
				_begin("step", int(sc._uid), ed.chain_steps(sc)[si][1], p)
				_drag_step = si
				return

		var hit_uid: = note_at(spos)




		var fxh: = fx_handle_at(spos)
		if fxh >= 0:
			_begin_fx("fxscale", ed.sel_fx_uid, spos, fxh)
			return
		if hit_uid < 0 and not event.alt_pressed:
			var fxb: = fx_box_at(spos)
			if fxb >= 0 and (ed.tool in ["select", "move"] or fxb == ed.sel_fx_uid):


				if event.ctrl_pressed or event.shift_pressed:
					ed.toggle_fx_selection(fxb)
					ed.inspector.open_tab("events")
					return
				if fxb != ed.sel_fx_uid:
					ed.select_fx(fxb)
					ed.inspector.open_tab("events")
				_begin_fx("fxmove", fxb, spos, -1)
				return

		if ed.tool == "erase":
			if hit_uid >= 0:
				ed.delete_uids([hit_uid], "erase")
			return




		if event.alt_pressed:
			if hit_uid >= 0:
				ed.delete_uids([hit_uid], "remove")
			else:
				_place_here("parry", p)
			return

		if ed.tool == "select" or ed.tool == "move":
			if hit_uid >= 0:
				if event.shift_pressed or event.ctrl_pressed:
					ed.toggle_uid(hit_uid)
				elif not ed.sel_uids.has(hit_uid):
					ed.select_uids([hit_uid])
				_begin_note_drag(p)
			else:
				if not (event.shift_pressed or event.ctrl_pressed):
					ed.select_uids([])
				_drag = "box"
			return


		if hit_uid >= 0 and _removable(hit_uid, p):
			ed.delete_uids([hit_uid], "remove")
			return
		_place_here(String(ed.tool), p)









	func _removable(uid: int, p: Vector2) -> bool:
		var n = ed.note_by_uid(uid)
		if n == null or String(n.type) != String(ed.tool):
			return false
		for it in layout():
			if int(it.uid) == uid:
				return (it.pos as Vector2).distance_to(p)\
				<= tun().click_hit_radius * 0.7
		return false




	func _place_here(type: String, p: Vector2) -> void :
		var tt: float = clampf(ed.snap(ed.t), 0.0, ed.song_len())
		var aim: = EdTheme.is_aim_type(type)
		var lane: = lane_at(p)
		var dur: float = ed.beat_dur() if EdTheme.has_duration(type) else 0.0
		var n: Dictionary = ed.add_note(type, tt, lane, 
			p.x if aim else NAN, p.y if aim else NAN, dur)
		if type == "clickx":
			ed.chain_building_uid = int(n._uid)
			ed.flash("chain started — 1 click = 1 step, Esc to finish")
		elif EdTheme.has_duration(type):
			ed.flash("%s placed — %.2f s (drag it in the timeline to resize)"
				%[EdTheme.type_label(type).to_lower(), dur])
		ed.canvas._refresh()

	func _begin(kind: String, uid: int, ref: Vector2, p: Vector2) -> void :
		_drag = kind
		_drag_uid = uid
		_drag_ref = ref
		_grab = ref - p
		_committed = false
		_drag_step = -1
		_drag_pt = -1





	func _begin_note_drag(p: Vector2) -> void :
		var f = ed.focus_note()
		if f == null:
			return
		_drag_lane_ref.clear()
		if EdTheme.is_aim_type(String(f.type)):
			_begin("aim", int(f._uid), aim_pos(f), p)
			return
		_drag = "lane"
		_drag_uid = int(f._uid)
		_committed = false
		for uid in ed.sel_uids:
			var n = ed.note_by_uid(uid)
			if n != null and not EdTheme.is_aim_type(String(n.type)):
				_drag_lane_ref[uid] = int(n.get("lane", 1))

	func _update_drag(event: InputEventMouseMotion) -> void :
		var p: = s2p(event.position)
		match _drag:
			"box":
				return
			"lane":
				_update_lane_drag(p)
				return
			"holdlen":
				_update_hold_len(p)
				return
			"fxmove":
				_update_fx_move(event.position, event.shift_pressed)
				return
			"fxscale":
				_update_fx_scale(event.position)
				return
		var n = ed.note_by_uid(_drag_uid)
		if n == null:
			return
		var q: = p + _grab
		if event.shift_pressed:
			q = snap_guides(q, n)
		else:
			_guides.clear()
		if not _committed and q.distance_to(_drag_ref) > 1.5:

			ed.push_undo("move chain step" if _drag == "step"
				else ("move slider point" if _drag == "point" else "move aim"))
			_committed = true
		match _drag:
			"step":
				ed.move_chain_step(_drag_uid, _drag_step, q, false)
			"point":
				ed.move_slider_point(_drag_uid, _drag_pt, q, false)
			_:
				apply_position(n, q, false)
		ed.canvas._refresh()





	func _update_hold_len(p: Vector2) -> void :
		var n = ed.note_by_uid(_drag_uid)
		if n == null:
			return
		var lead: = lead_of(n)
		var travel: float = maxf(tun().hit_y - tun().spawn_y, 1.0)
		var dt: float = (s2p(_from).y - p.y) / travel * lead
		var step: float = ed.beat_dur() / float(ed.grid_div())
		var want: float = maxf(
			ed.snap_magnet(float(n.time) + _hold_ref + dt, [int(n.get("_uid", -1))]) - float(n.time), step)
		if is_equal_approx(want, ed.note_span(n)):
			return
		if not _committed:
			ed.push_undo("resize")
			_committed = true
		n["duration"] = snappedf(want, 0.001)
		ed.mark_dirty()
		ed.canvas._refresh()

	func _update_lane_drag(p: Vector2) -> void :
		if _drag_lane_ref.is_empty():
			return
		var target: = lane_at(p)
		var ref_lane: int = int(_drag_lane_ref.get(_drag_uid, target))
		var d: = target - ref_lane
		if d == 0 and not _committed:
			return
		if not _committed:
			ed.push_undo("change lane")
			_committed = true
		for uid in _drag_lane_ref:
			var n = ed.note_by_uid(uid)
			if n != null:
				n["lane"] = clampi(int(_drag_lane_ref[uid]) + d, 0, 2)
		ed.mark_dirty()

	func _release(spos: Vector2) -> void :
		match _drag:
			"box":
				_finish_box(spos)
			"aim":
				if _committed:
					ed.flash("aim moved")
			"lane":
				if _committed:
					ed.flash("%d note(s) moved to another lane" % _drag_lane_ref.size())
			"step":
				if _committed:
					ed.flash("chain step moved")
			"point":
				if _committed:
					ed.flash("path point %d moved" % (_drag_pt + 1))
					ed.mark_dirty()
			"holdlen":
				if _committed:
					var hn = ed.note_by_uid(_drag_uid)
					if hn != null:
						ed.flash("duration %.2f s (%.1f beats)" % [ed.note_span(hn), 
							ed.note_span(hn) / ed.beat_dur()])
			"draw":
				_trail.append(s2p(spos))
				ed.draw_slider_path(_drag_uid, _trail)
				_trail.clear()
				ed.canvas._refresh()
			"fxmove":
				if _committed:
					var fe = ed.fx_by_uid(_drag_uid)
					if fe != null:
						ed.flash("event moved to %.2f, %.2f" % [float(fe.get("x", 0.5)), 
							float(fe.get("y", 0.5))])
			"fxscale":
				if _committed:
					var fe2 = ed.fx_by_uid(_drag_uid)
					if fe2 != null:
						ed.flash(("text size %d" % int(fe2.get("size", 64)))
							if String(fe2.get("type", "")) == "text"
							else ("image width %.0f%% of the screen"
								%(float(fe2.get("width", 0.35)) * 100.0)))
		_fx_ref.clear()
		_drag = ""
		_drag_uid = -1
		_drag_step = -1
		_drag_pt = -1
		_trail.clear()
		_committed = false
		_guides.clear()
		_drag_lane_ref.clear()
		queue_redraw()



	func _finish_box(spos: Vector2) -> void :
		var r: = Rect2(_from, spos - _from).abs()
		if r.size.length() < 5.0:
			return
		var picked: Array = []
		for it in layout():
			if r.has_point(p2s(it.pos)):
				picked.append(int(it.uid))
		ed.select_uids(picked, Input.is_key_pressed(KEY_SHIFT))
		ed.flash("%d note(s) selected on screen" % picked.size())

	func _right_press(event: InputEventMouseButton) -> void :
		if ed.previewing():
			return
		var spos: Vector2 = event.position


		var sl = sel_slider()
		if sl != null:
			var pt: = slider_point_at_screen(sl, spos)
			if pt >= 0:
				ed.remove_slider_point(int(sl._uid), pt)
				_hover_pt = -1
				ed.canvas._refresh()
				return

		var sc = ed.focus_note()
		if sc != null and EdTheme.is_chain(String(sc.type)):
			var si: = chain_step_at(sc, spos)
			if si >= 0:
				ed.remove_chain_step(int(sc._uid), si)
				ed.canvas._refresh()
				return
		_context_menu(spos)

	func _context_menu(spos: Vector2) -> void :
		set_meta("menu_pos", spos)
		var at: = get_global_rect().position + spos
		var hit: = note_at(spos)
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
				{"text": "Slider (yellow)", "id": "t:sliderg", 
					"check": n.type == "sliderg", "accent": EdTheme.GOLD}, 
				{"sep": true}, 
				{"text": "Go to its timecode", "id": "goto"}, 
				{"text": "Properties...", "id": "props"}, 
			]
		else:
			var p: = s2p(spos)
			items = [
				{"title": "HERE · %s · lane %s" % [EdTheme.fmt_time(ed.snap(ed.t)), 
					["LEFT", "CENTER", "RIGHT"][lane_at(p)]]}, 
				{"text": "Place a white note", "id": "n:parry", "hint": "1"}, 
				{"text": "Place a dodge", "id": "n:dodge", "hint": "2", 
					"accent": EdTheme.RED}, 
				{"text": "Place an aim note", "id": "n:click", "hint": "3", 
					"accent": EdTheme.GOLD}, 
				{"text": "Place an aim counter", "id": "n:clickx", "hint": "6", 
					"accent": EdTheme.GOLD}, 
				{"text": "Place a hold (1 beat)", "id": "n:sliderm", "hint": "4"}, 
				{"text": "Place a slider (1 beat)", "id": "n:sliderg", "hint": "5", 
					"accent": EdTheme.GOLD}, 
				{"sep": true}, 
				{"text": "Center the selected aim", "id": "center", 
					"disabled": not _aim_selected()}, 
				{"text": "Restore its generated position", "id": "auto", 
					"disabled": not _aim_selected()}, 
				{"sep": true}, 
				{"text": "Straighten the path", "id": "line", 
					"disabled": sel_slider() == null}, 
				{"text": "Restore the automatic arc", "id": "arc", 
					"disabled": sel_slider() == null}, 
			]
		EdMenu.open(ed.overlay_host(), items, at, ed.font, _menu_pick, 188)

	func _aim_selected() -> bool:
		var n = ed.focus_note()
		return n != null and EdTheme.is_aim_type(String(n.type))

	func _menu_pick(id: String) -> void :
		if id == "":
			return
		var spos: Vector2 = get_meta("menu_pos", Vector2.ZERO)
		var p: = s2p(spos)
		if id.begins_with("t:"):
			ed.convert_type(ed.sel_uids.duplicate(), id.substr(2))
			return
		if id.begins_with("n:"):
			_place_here(id.substr(2), p)
			return
		var n = ed.focus_note()
		match id:
			"del":
				ed.delete_selection()
			"dup":
				ed.duplicate_uids(ed.sel_uids.duplicate())
			"copy":
				ed.copy_selection(false)
			"goto":
				if n != null:
					ed.seek_to(float(n.time), false)
			"props":
				ed.inspector.open_tab("note")
			"center":
				if n != null:
					apply_position(n, Vector2(ed.PLAY_W * 0.5, 
						tun().hit_y * 0.5), true)
			"auto":
				if n != null:
					apply_position(n, ed.default_aim_pos(float(n.time)), true)
			"line":
				var sl = sel_slider()
				if sl != null:
					ed.reset_slider_path(int(sl._uid), true)
			"arc":
				var sa = sel_slider()
				if sa != null:
					ed.reset_slider_path(int(sa._uid), false)
		ed.canvas._refresh()


	func cancel_drag() -> bool:
		if _drag == "":
			return false
		if _committed:
			ed.undo()
		_drag = ""
		_drag_lane_ref.clear()
		_trail.clear()
		_committed = false
		queue_redraw()
		return true



	func _draw() -> void :
		var kk: = k()
		var w: = vw()
		var st: Dictionary = ed.fx_state_at(ed.t, w)
		var shake: Vector2 = (st.shake as Vector2) * kk

		_draw_background(st)

		var parts: Dictionary = st.get("particles", {})
		if not parts.is_empty():
			FxParticles.draw(self, Rect2(Vector2.ZERO, size), ed.t, parts.st, 
				float(parts.amt), kk)



		var rot: float = deg_to_rad(float(st.get("rot", 0.0)))
		var pivot: = p2s(Vector2(w * 0.5, tun().hit_y))
		var rot_pos: = pivot - pivot.rotated(rot)
		if rot != 0.0:
			draw_set_transform(rot_pos, rot, Vector2.ONE)
		_draw_lanes(st, shake, kk, w)
		_draw_impact(st, shake, kk, w)
		if rot != 0.0:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		if ed.previewing():
			_draw_frame_bounds(kk)
		_draw_fx_images()
		_draw_fx_texts(w)
		_draw_guides()
		if rot != 0.0:
			draw_set_transform(rot_pos, rot, Vector2.ONE)
		_draw_notes(kk)
		_draw_ghosts(kk)
		_draw_handles(kk)
		if rot != 0.0:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_draw_fx_frame(w)
		_update_film(st)
		_draw_tool_cursor(kk)
		if _drag == "box":
			var r: = Rect2(_from, _now - _from).abs()
			draw_rect(r, Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.08))
			draw_rect(r, Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.7), 
				false, 1.0)
		elif _drag == "draw" and _trail.size() > 1:


			var line: = PackedVector2Array()
			for tp in _trail:
				line.append(p2s(tp))
			draw_polyline(line, Color(EdTheme.GOLD.r, EdTheme.GOLD.g, 
				EdTheme.GOLD.b, 0.85), 3.0, true)
		draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.1), false, 1.0)




	var _film_rect: ColorRect = null

	func _update_film(st: Dictionary) -> void :
		var amt: float = float(st.get("film", 0.0))
		if _film_rect == null:
			if amt <= 0.005:
				return
			_film_rect = ColorRect.new()
			_film_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_film_rect.z_index = 5
			var sh: = Shader.new()
			sh.code = FxEval.FILM_SHADER
			var mat: = ShaderMaterial.new()
			mat.shader = sh
			_film_rect.material = mat
			add_child(_film_rect)
		_film_rect.visible = amt > 0.005
		if _film_rect.visible:
			_film_rect.position = Vector2.ZERO
			_film_rect.size = size
			var mat2: ShaderMaterial = _film_rect.material
			mat2.set_shader_parameter("amt", amt)
			mat2.set_shader_parameter("tt", ed.t)
			mat2.set_shader_parameter("grain", float(st.get("film_grain", 1.0)))
			mat2.set_shader_parameter("sepia", float(st.get("film_sepia", 0.0)))

	func _draw_background(st: Dictionary) -> void :

		var bg: = Color(0.02, 0.024, 0.055)
		if float(st.tint_w) > 0.001:
			var tc: Color = st.tint
			var tw: float = float(st.tint_w)
			bg = Color(lerpf(bg.r, bg.r * 0.4 + tc.r * 0.22, tw), 
				lerpf(bg.g, bg.g * 0.4 + tc.g * 0.22, tw), 
				lerpf(bg.b, bg.b * 0.4 + tc.b * 0.22, tw))
		draw_rect(Rect2(Vector2.ZERO, size), bg)

	func _draw_lanes(st: Dictionary, shake: Vector2, kk: float, w: float) -> void :
		var lw: float = tun().lane_width
		var lg: float = tun().lane_gap
		for i in 3:

			var gone: float = float(st.get("gone", [0.0, 0.0, 0.0])[i])
			var alpha: float = float(st.alpha[i]) * (1.0 - gone)
			if alpha <= 0.02:
				continue
			var col: Color = st.cols[i]
			var cx: float = FxEval.lane_center(st, i, ed.t, lw, lg, w)
			var half: float = FxEval.lane_half(st, i, lw) * (1.0 - gone)



			var quad: = StageRender.lane_quad(cx, half, w * 0.5, 
				ed.main.LANE_PERSPECTIVE, 0.0, tun().hit_y)
			var poly: = PackedVector2Array()
			for q in quad:
				poly.append(p2s(q) + shake)
			draw_colored_polygon(poly, Color(col.r, col.g, col.b, 0.1 * alpha))
			draw_line(poly[0], poly[3], Color(col.r, col.g, col.b, 0.45 * alpha), 1.5)
			draw_line(poly[1], poly[2], Color(col.r, col.g, col.b, 0.45 * alpha), 1.5)

			StageRender.receptor(self, p2s(Vector2(cx, tun().hit_y)) + shake, 
				15.0 * kk, col, false, 
				ed.main.neon(Color(col.r, col.g, col.b, alpha), 1.25), 
				ed.main.neon(col, 1.7))

			var lbl: String = ["LEFT", "CENTER", "RIGHT"][i]
			var lw2: float = ed.font.get_string_size(lbl, HORIZONTAL_ALIGNMENT_LEFT, 
				-1, EdTheme.S_MICRO).x
			draw_string(ed.font, p2s(Vector2(cx, tun().hit_y + 34.0))
				+ shake - Vector2(lw2 * 0.5, 0), lbl, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
				Color(col.r, col.g, col.b, 0.35 * alpha))

	func _draw_impact(st: Dictionary, shake: Vector2, kk: float, w: float) -> void :



		var in_kiai: bool = ed.kiai_at(ed.t) >= 0
		var hy: = p2s(Vector2(0, tun().hit_y)).y + shake.y
		var impact: Color = EdTheme.MINT
		if in_kiai:
			impact = EdTheme.WARM
			draw_rect(Rect2(0, hy - 9.0, size.x, 18.0), 
				Color(EdTheme.WARM.r, EdTheme.WARM.g, EdTheme.WARM.b, 0.1))
			draw_string(ed.font, Vector2(8, 16), "KIAI", 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_SMALL, 
				ed.main.neon(EdTheme.WARM, 1.2))
		draw_line(Vector2(2, hy), Vector2(size.x - 2, hy), 
			Color(impact.r, impact.g, impact.b, 0.85), 2.0)

		var mascot: = p2s(Vector2(FxEval.lane_center(st, 1, ed.t, 
			tun().lane_width, tun().lane_gap, w), tun().hit_y)) + shake
		var mr: = 11.0 * kk
		draw_circle(mascot, mr, Color(0.92, 0.95, 1.0, 0.85))
		draw_circle(mascot + Vector2( - mr * 0.34, - mr * 0.14), mr * 0.2, 
			Color(0.05, 0.06, 0.12))
		draw_circle(mascot + Vector2(mr * 0.34, - mr * 0.14), mr * 0.2, 
			Color(0.05, 0.06, 0.12))





	func _draw_frame_bounds(_kk: float) -> void :
		var x: = p2s(Vector2(ed.PLAY_W, 0)).x
		if x >= size.x - 1.0:
			return
		var warm: Color = EdTheme.WARM


		draw_rect(Rect2(x, 0, size.x - x, size.y), Color(warm.r, warm.g, warm.b, 0.055))
		draw_dashed_line(Vector2(x, 0), Vector2(x, size.y), 
			Color(warm.r, warm.g, warm.b, 0.85), 2.0, 6.0)
		draw_string(ed.font, Vector2(x + 6.0, size.y - 8.0), 
			"OUTSIDE THE 1280 FRAME", HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO, Color(warm.r, warm.g, warm.b, 0.8))









	const FX_HANDLE: = 7.0

	func fx_positioned(ev) -> bool:
		return ev != null and String(ev.get("type", "")) in ["text", "image"]


	func fx_frame(ev: Dictionary, w: float) -> Rect2:
		var type: = String(ev.get("type", ""))
		if type == "text":
			var txt: = String(ev.get("text", ""))
			var fs: int = maxi(int(float(ev.get("size", 64)) * size.x / w), 7)
			var f: Font = FxFonts.get_font(String(ev.get("font", FxFonts.DEFAULT)))
			if f == null:
				f = ed.font_display
			var tw: float = maxf(f.get_string_size(txt if txt != "" else "text", 
				HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, 10.0)
			var th: = float(fs) * 1.15
			var ax: = float(ev.get("x", 0.5))
			var side: = String(ev.get("side", ""))
			if side == "left":
				ax = 0.15
			elif side == "right":
				ax = 0.85
			var c: = Vector2(size.x * ax, size.y * float(ev.get("y", 0.3)))
			return Rect2(c - Vector2(tw, th) * 0.5, Vector2(tw, th))
		if type == "image":
			var iw: float = maxf(float(ev.get("width", 0.35)), 0.01) * size.x
			var ih: float = iw * 0.6
			var tex: Texture2D = ed.fx_image_tex(FxImages.sheet_file(ev, 0))
			if tex != null:
				var ts: Vector2 = FxImages.region_of(ev, tex, 0).size
				ih = iw * ts.y / maxf(ts.x, 1.0)
			var c2: = Vector2(size.x * float(ev.get("x", 0.5)), size.y * float(ev.get("y", 0.5)))
			return Rect2(c2 - Vector2(iw, ih) * 0.5, Vector2(iw, ih))
		return Rect2()




	func fx_box_at(spos: Vector2) -> int:
		if ed.previewing():
			return -1
		var w: = vw()
		var sel = ed.selected_fx()
		if fx_positioned(sel) and fx_frame(sel, w).grow(2.0).has_point(spos):
			return int(sel.get("_uid", -1))
		var shown: Array = []
		for it in ed.fx_images_now():
			shown.append(it.ev)
		for it in ed.fx_texts_now():
			shown.append(it.ev)
		for i in range(shown.size() - 1, -1, -1):
			var ev: Dictionary = shown[i]
			if fx_frame(ev, w).grow(2.0).has_point(spos):
				return int(ev.get("_uid", -1))
		return -1



	func fx_handle_at(spos: Vector2) -> int:
		var sel = ed.selected_fx()
		if not fx_positioned(sel) or ed.previewing():
			return -1
		var r: = fx_frame(sel, vw())
		var corners: = [r.position, Vector2(r.end.x, r.position.y), r.end, 
			Vector2(r.position.x, r.end.y)]
		for i in 4:
			if spos.distance_to(corners[i]) <= FX_HANDLE + 3.0:
				return i
		return -1

	func _begin_fx(kind: String, uid: int, spos: Vector2, corner: int) -> void :
		var ev = ed.fx_by_uid(uid)
		if ev == null:
			return
		var r: = fx_frame(ev, vw())
		_drag = kind
		_drag_uid = uid
		_committed = false
		_drag_step = corner
		_fx_ref = {
			"x": float(ev.get("x", 0.5)), "y": float(ev.get("y", 0.5 if 
				String(ev.get("type", "")) == "image" else 0.3)), 
			"v": float(ev.get("size", 64)) if String(ev.get("type", "")) == "text"
				else float(ev.get("width", 0.35)), 
			"center": r.get_center(), 
			"d0": maxf(r.get_center().distance_to(spos), 4.0), 
		}

		if String(ev.get("type", "")) == "text":
			_fx_ref["x"] = r.get_center().x / maxf(size.x, 1.0)


	func _update_fx_move(spos: Vector2, axis_lock: bool) -> void :
		var ev = ed.fx_by_uid(_drag_uid)
		if ev == null or _fx_ref.is_empty():
			return
		var d: = spos - _from
		if d.length() < 1.5 and not _committed:
			return
		if not _committed:
			ed.push_undo("move event in the stage")
			_committed = true
			ev.erase("_raw")
		if axis_lock:
			if absf(d.x) >= absf(d.y):
				d.y = 0.0
			else:
				d.x = 0.0
		ev["x"] = snappedf(clampf(float(_fx_ref.x) + d.x / maxf(size.x, 1.0), -0.5, 1.5), 0.001)
		ev["y"] = snappedf(clampf(float(_fx_ref.y) + d.y / maxf(size.y, 1.0), -0.5, 1.5), 0.001)
		if String(ev.get("type", "")) == "text" and String(ev.get("side", "")) != "":
			ev["side"] = ""
		ed.mark_dirty()



	func _update_fx_scale(spos: Vector2) -> void :
		var ev = ed.fx_by_uid(_drag_uid)
		if ev == null or _fx_ref.is_empty():
			return
		var c: Vector2 = _fx_ref.center
		var f: = clampf(c.distance_to(spos) / float(_fx_ref.d0), 0.05, 20.0)
		if absf(f - 1.0) < 0.01 and not _committed:
			return
		if not _committed:
			ed.push_undo("resize event in the stage")
			_committed = true
			ev.erase("_raw")
		if String(ev.get("type", "")) == "text":
			ev["size"] = maxi(int(round(float(_fx_ref.v) * f)), 6)
		else:
			ev["width"] = snappedf(clampf(float(_fx_ref.v) * f, 0.02, 3.0), 0.001)
		ed.mark_dirty()

	func _draw_fx_frame(w: float) -> void :
		if ed.previewing():
			return

		if _hover_fx_uid >= 0 and _hover_fx_uid != ed.sel_fx_uid and _drag == "":
			var hev = ed.fx_by_uid(_hover_fx_uid)
			if hev != null:
				var hc: Color = EdFx.color(String(hev.get("type", "")))
				draw_rect(fx_frame(hev, w), Color(hc.r, hc.g, hc.b, 0.45), false, 1.0)
		var sel = ed.selected_fx()
		if not fx_positioned(sel):
			return
		var r: = fx_frame(sel, w)
		var type: = String(sel.get("type", ""))
		var c: Color = EdFx.color(type)
		var active: = false
		var uid: = int(sel.get("_uid", -1))
		for it in (ed.fx_texts_now() if type == "text" else ed.fx_images_now()):
			if int(it.ev.get("_uid", -1)) == uid:
				active = true
				break
		if not active:

			draw_rect(r, Color(c.r, c.g, c.b, 0.08))
			draw_string(ed.font, Vector2(r.position.x + 4.0, r.get_center().y + 4.0), 
				"%s · %s (not at this time)" % [EdFx.label(type), EdFx.short(sel)], 
				HORIZONTAL_ALIGNMENT_LEFT, maxf(r.size.x - 8.0, 40.0), EdTheme.S_MICRO, 
				Color(c.r, c.g, c.b, 0.8))
		var dragging: = _drag in ["fxmove", "fxscale"]
		draw_rect(r, Color(c.r, c.g, c.b, 0.95 if dragging else 0.75), false, 
			1.5 if dragging else 1.0)
		var corners: = [r.position, Vector2(r.end.x, r.position.y), r.end, 
			Vector2(r.position.x, r.end.y)]
		for i in 4:
			var on: bool = _hover_fx_handle == i or (_drag == "fxscale" and _drag_step == i)
			var hs: = FX_HANDLE * (1.3 if on else 1.0)
			draw_rect(Rect2(corners[i] - Vector2(hs, hs) * 0.5, Vector2(hs, hs)), 
				Color(0.02, 0.02, 0.05, 0.9))
			draw_rect(Rect2(corners[i] - Vector2(hs, hs) * 0.5, Vector2(hs, hs)), 
				Color.WHITE if on else c, false, 1.2)
		var tip: = "drag to move · corners to scale · Shift = one axis"
		draw_string(ed.font, Vector2(r.position.x, r.end.y + 12.0), tip, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.35))




	func _draw_fx_images() -> void :
		for item in ed.fx_images_now():
			var ev: Dictionary = item.ev
			var file: = String(ev.get("file", ""))

			var fr: Dictionary = FxImages.frame_of(ev, ed.t - float(ev.get("time", 0.0)))
			var tex: Texture2D = ed.fx_image_tex(FxImages.sheet_file(ev, int(fr.sheet)))
			var a: float = float(item.alpha)
			if a <= 0.005:
				continue
			var iw: float = maxf(float(ev.get("width", 0.35)), 0.01) * size.x
			var ih: float = iw * 0.6
			var reg: = Rect2()
			if tex != null:
				var info: Dictionary = FxImages.region_of(ev, tex, int(fr.idx))
				reg = info.region
				var ts: Vector2 = info.size
				ih = iw * ts.y / maxf(ts.x, 1.0)
			var off: Vector2 = item.off
			var center: = Vector2(size.x * float(ev.get("x", 0.5)) + off.x * size.x, 
				size.y * float(ev.get("y", 0.5)) + off.y * size.y)
			var sc: float = float(item.scale)
			draw_set_transform(center, deg_to_rad(float(item.rot)), Vector2(sc, sc))
			var box: = Rect2( - iw * 0.5, - ih * 0.5, iw, ih)
			if tex != null:
				var tint: = Color.from_string(String(ev.get("color", "")), Color.WHITE)
				tint.a = a
				var gl: float = float(item.get("glitch", 0.0))
				if gl > 0.01:



					var step_t: = floorf(ed.t * 24.0)
					var sp: float = iw * 0.012 * gl
					draw_texture_rect_region(tex, Rect2(box.position + Vector2(sp, 0), box.size), 
						reg, Color(1.0, 0.25, 0.25, a * 0.55))
					draw_texture_rect_region(tex, Rect2(box.position - Vector2(sp, 0), box.size), 
						reg, Color(0.25, 0.4, 1.0, a * 0.55))
					var nb: = 18
					var bh: float = ih / float(nb)
					var sh: float = reg.size.y / float(nb)
					for b in nb:
						var r1: float = FxEval._hash(float(b) + step_t * 31.7)
						var gate: float = FxEval._hash(float(b) * 3.3 + step_t)
						var shift: float = (r1 - 0.5) * 0.14 * gl * iw if gate > 0.55 else 0.0
						var dark: bool = FxEval._hash(float(b) * 7.7 + step_t * 1.3) > 0.86
						var ghost: bool = FxEval._hash(float(b) * 9.1 + step_t * 2.1) > 0.92
						var col: = tint
						if dark:
							col = Color(tint.r * 0.2, tint.g * 0.2, tint.b * 0.2, a)
						if ghost:
							col.a = a * 0.2
						draw_texture_rect_region(tex, 
							Rect2(box.position.x + shift, box.position.y + float(b) * bh, 
								iw, bh), 
							Rect2(reg.position.x, reg.position.y + sh * float(b), 
								reg.size.x, sh), 
							col)
				else:
					draw_texture_rect_region(tex, box, reg, tint)
			else:
				var c: = EdFx.color("image")
				draw_rect(box, Color(c.r, c.g, c.b, a * 0.1))
				draw_rect(box, Color(c.r, c.g, c.b, a * 0.7), false, 1.0)
				var lbl: = "no image" if file == "" else file + " ?"
				draw_string(ed.font, Vector2( - iw * 0.5 + 4.0, 0.0), lbl, 
					HORIZONTAL_ALIGNMENT_LEFT, iw - 8.0, EdTheme.S_MICRO, 
					Color(c.r, c.g, c.b, a))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _draw_fx_texts(w: float) -> void :
		for item in ed.fx_texts_now():
			var ev: Dictionary = item.ev
			var txt: = String(ev.get("text", ""))
			if txt == "":
				continue
			var a: float = float(item.alpha)
			var col: = Color.from_string(String(ev.get("color", "#e8e6ff")), Color.WHITE)
			var ax: = float(ev.get("x", 0.5))
			var side: = String(ev.get("side", ""))
			if side == "left":
				ax = 0.15
			elif side == "right":
				ax = 0.85
			var ay: = float(ev.get("y", 0.3))
			var fs: int = maxi(int(float(ev.get("size", 64)) * size.x / w), 7)

			var f: Font = FxFonts.get_font(String(ev.get("font", FxFonts.DEFAULT)))
			if f == null:
				f = ed.font_display
			var tw: float = f.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			var pos: = Vector2(size.x * ax - tw * 0.5, size.y * ay + float(fs) * 0.35)
			if bool(ev.get("ring", false)):
				draw_arc(Vector2(size.x * ax, size.y * ay), float(fs) * 0.95, 
					0.0, TAU, 28, Color(col.r, col.g, col.b, a * 0.35), 1.0)
			draw_string(f, pos + Vector2(1.5, 1.5), txt, HORIZONTAL_ALIGNMENT_LEFT, 
				-1, fs, Color(0, 0, 0, a * 0.5))
			draw_string(f, pos, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 
				Color(col.r, col.g, col.b, a))

	func _draw_guides() -> void :
		for g in _guides:
			var c: = Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.6)
			if g[0] == "v":
				var gx: = p2s(Vector2(float(g[1]), 0)).x
				draw_dashed_line(Vector2(gx, 0), Vector2(gx, size.y), c, 1.0, 4.0)
			else:
				var gy: = p2s(Vector2(0, float(g[1]))).y
				draw_dashed_line(Vector2(0, gy), Vector2(size.x, gy), c, 1.0, 4.0)




	func _draw_notes(kk: float) -> void :
		var glow: Texture2D = ed.main.glow_tex
		for it in layout():
			var n: Dictionary = it.n
			var a: float = clampf(float(it.alpha), 0.0, 1.0)
			if a <= 0.01:
				continue
			var q: = p2s(it.pos)
			var selected: bool = ed.sel_uids.has(int(it.uid))



			if bool(it.forced) and forced_static(n, ed.t):
				a *= 0.5
			match String(it.type):
				"parry", "dodge":
					StageRender.lane_note(self, q, kk, String(it.type), 
						ed.t, glow, a > 0.9)
				"click":
					StageRender.aim_glow(self, q, kk, tun().click_hit_radius, 
						glow, 0.26 * a)
					StageRender.aim_circle(self, q, kk, tun().click_hit_radius, 
						float(it.ring), a)
				"clickx":
					_draw_chain(it, q, kk, a, glow)
				"sliderg":
					_draw_slider(it, q, kk, a)
				"sliderm", "beam":
					_draw_hold(it, q, kk, a)
				_:
					StageRender.aim_circle(self, q, kk, tun().click_hit_radius, 
						0.0, a)

			var nv: = float(n.get("v", 1.0))
			if nv > 1.05 or nv < 0.95:
				var vc: = Color(1.1, 0.34, 0.28, 0.45 * a) if nv > 1.0\
				else Color(0.34, 0.58, 1.1, 0.45 * a)
				draw_arc(q, 34.0 * kk, 0.0, TAU, 28, vc, 1.6)
			if int(it.uid) == _hover_uid and not selected:
				draw_arc(q, 30.0 * kk, 0.0, TAU, 28, Color(1, 1, 1, 0.35), 1.2)
			if selected:
				_draw_selection(q, kk)

	func _draw_chain(it: Dictionary, q: Vector2, kk: float, a: float, 
			glow: Texture2D) -> void :
		var steps: Array = it.steps
		var idx: int = int(it.idx)
		var rem: = steps.size() - idx
		var hr: float = tun().click_hit_radius
		StageRender.aim_glow(self, q, kk, hr, glow, 0.3 * a, 4.6)
		StageRender.aim_circle(self, q, kk, hr, 0.0, a, 1.0, true)
		StageRender.aim_pips(self, q, kk, hr, rem, a)
		StageRender.aim_count(self, q, kk, hr, rem, ed.font_display, 0.0, a)

		var ga: = 0.22 + 0.38 * a
		var prev: = q
		for j in range(idx + 1, steps.size()):
			var gp: = p2s(steps[j][1])
			var gaj: = ga * pow(0.62, float(j - idx - 1))
			if gaj < 0.05:
				break
			StageRender.aim_link(self, prev, gp, kk, hr, gaj, j == idx + 1, 
				1.0 if j == idx + 1 else 0.85)
			StageRender.aim_ghost(self, gp, kk, hr, steps.size() - j, gaj, 
				ed.font_display)
			prev = gp
		StageRender.aim_ring(self, q, kk, hr, float(it.ring), a)

	func _draw_slider(it: Dictionary, q: Vector2, kk: float, a: float) -> void :
		var n: Dictionary = it.n
		var pts: Array = ed.slider_path(n)


		var u_cut: = 0.0
		if ed.show_approach and ed.t > float(n.time):
			u_cut = clampf((ed.t - float(n.time))
				/ maxf(float(it.span), 0.001), 0.0, 1.0)
		var body: = PackedVector2Array()
		body.append(p2s(ed.slider_point_at(n, u_cut)))
		for i in 73:
			var u: = float(i) / 72.0
			if u > u_cut:
				body.append(p2s(ed.slider_point_at(n, u)))
		StageRender.slider_body(self, body, kk, tun().click_hit_radius, 
			tun().slider_rail_width, a)
		StageRender.slider_tail(self, p2s(ed.slider_point_at(n, 1.0)), kk, 
			tun().click_hit_radius, a)
		if u_cut <= 0.001:
			StageRender.slider_head(self, q, kk, tun().click_hit_radius, 
				float(it.ring), a)
		else:

			var b: = p2s(ed.slider_point_at(n, u_cut))
			var br: float = tun().click_hit_radius * 0.85 * 0.8 * kk
			draw_circle(b, br, Color(1.06 * 1.18, 0.87 * 1.18, 0.32 * 1.05, a))
			draw_circle(b, br * 0.45, Color(1.5, 1.45, 1.25, a))
			draw_arc(b, tun().slider_rail_tolerance * kk, 0.0, TAU, 56, 
				Color(1.3, 1.1, 0.4, 0.45 * a), 2.0)


		if not ed.sel_uids.has(int(it.uid)):
			for p in pts:
				draw_circle(p2s(Vector2(float(p[1]), float(p[2]))), 2.0, 
					Color(1, 1, 1, 0.18 * a))

	func _draw_hold(it: Dictionary, q: Vector2, kk: float, a: float) -> void :
		var n: Dictionary = it.n
		var lane: = clampi(int(n.get("lane", 1)), 0, 2)
		var t0: float = maxf(ed.t, float(n.time)) if ed.show_approach else float(n.time)
		var t1: float = float(n.time) + maxf(float(it.span), 0.01)
		if t0 >= t1:
			t0 = t1 - 0.01
		var col: = Color(0.85, 1.0, 0.95, a)
		var lead: float = float(it.lead)
		var pts: = PackedVector2Array()
		var s: = t0
		while true:
			var prog: float = 1.0 - (s - ed.t) / maxf(lead, 0.001)
			if not ed.show_approach:
				prog = 1.0 - (s - float(n.time)) / maxf(lead, 0.001)
			var y: = fall_y(n, prog)
			if y < tun().spawn_y - 20.0:
				break
			pts.append(p2s(Vector2(lane_x_at(lane, y, float(n.time)), y)))
			if s >= t1:
				break
			s = minf(s + lead * 26.0 / (tun().hit_y - tun().spawn_y), t1)
		StageRender.hold_rail(self, pts, kk, tun().slider_rail_width, col)
		if pts.size() > 0:
			StageRender.hold_head(self, pts[0], kk, col, false, ed.main.glow_tex)


	func is_hold(n) -> bool:
		return n != null and String(n.type) in ["sliderm", "beam"]



	func hold_tail_screen(n: Dictionary) -> Vector2:
		var lead: = lead_of(n)
		var t1: float = float(n.time) + maxf(ed.note_span(n), 0.01)
		var base: float = ed.t if ed.show_approach else float(n.time)
		var prog: float = 1.0 - (t1 - base) / maxf(lead, 0.001)
		var y: = fall_y(n, prog)
		var lane: = clampi(int(n.get("lane", 1)), 0, 2)
		return p2s(Vector2(lane_x_at(lane, y, float(n.time)), y))



	func _draw_ghosts(kk: float) -> void :
		if not ed.show_ghosts:
			return
		var sel = ed.focus_note()
		if sel == null or not EdTheme.is_aim_type(String(sel.type)):
			return
		var q: = p2s(aim_pos(sel))
		var nb: = neighbours(sel)
		for i in 2:
			var g = nb[i]
			if g == null:
				continue
			var gq: = p2s(aim_pos(g))
			var col: = Color(EdTheme.GOLD.r, EdTheme.GOLD.g, EdTheme.GOLD.b, 0.42)
			draw_dashed_line(q, gq, Color(col.r, col.g, col.b, 0.3), 1.2, 5.0)
			draw_arc(gq, tun().click_hit_radius * 0.55 * kk, 0.0, TAU, 22, col, 1.8)
			if q.distance_to(gq) > 30.0:
				draw_string(ed.font, gq + Vector2(11, -8), "PREV" if i == 0 else "NEXT", 
					HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
					Color(1, 1, 1, 0.28))





	func _draw_handles(kk: float) -> void :
		var n = ed.focus_note()
		if n == null:
			return
		var type: = String(n.type)



		if is_hold(n):
			var tail: = hold_tail_screen(n)
			var on: bool = _drag == "holdlen"\
			or _now.distance_to(tail) <= 14.0
			var hc: = Color(0.85, 1.0, 0.95, 1.0 if on else 0.7)
			draw_line(tail - Vector2(11, 0), tail + Vector2(11, 0), hc, 
				3.0 if on else 2.0, true)
			draw_circle(tail, 3.5 if on else 2.5, hc)
		if type == "sliderg":
			var pts: Array = ed.slider_path(n)
			var line: = PackedVector2Array()
			for p in pts:
				line.append(p2s(Vector2(float(p[1]), float(p[2]))))
			var gold: Color = EdTheme.GOLD
			draw_polyline(line, Color(gold.r, gold.g, gold.b, 0.8), 1.8)
			if _path_u >= 0.0:
				draw_circle(p2s(_path_p), 4.5, Color(gold.r, gold.g, gold.b, 0.6))
				draw_arc(p2s(_path_p), 8.0, 0.0, TAU, 16, 
					Color(gold.r, gold.g, gold.b, 0.4), 1.2)
			for i in pts.size():
				var s: = line[i]
				var on: bool = _hover_pt == i or (_drag_pt == i and _drag == "point")
				var col: = Color(gold.r * 1.3, gold.g * 1.25, gold.b, 1.0) if on\
				else Color(gold.r, gold.g, gold.b, 0.9)
				if i == 0:
					StageRender.diamond(self, s, 7.0, col)
				else:
					var box: = Rect2(s - Vector2(4.5, 4.5), Vector2(9, 9))
					draw_rect(box, Color(0.02, 0.026, 0.05, 0.9))
					draw_rect(box, col, false, 1.6)
				draw_string(ed.font, s + Vector2(9, -7), str(i + 1), 
					HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
					Color(col.r, col.g, col.b, 0.7))
		elif EdTheme.is_chain(type):
			var steps: Array = ed.chain_steps(n)
			for i in steps.size():
				var s2: = p2s(steps[i][1])
				draw_arc(s2, 12.0, 0.0, TAU, 20, EdTheme.CYAN
					if (_drag == "step" and _drag_step == i)
					else Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.5), 
					1.6)
				draw_string(ed.font, s2 + Vector2(13, -9), "#%d" % (i + 1), 
					HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, 
					Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.6))



	func _draw_selection(q: Vector2, kk: float) -> void :
		var s: float = tun().click_hit_radius * 0.72 * kk + 8.0
		draw_arc(q, s + 3.0, 0.0, TAU, 30, 
			Color(EdTheme.CYAN.r, EdTheme.CYAN.g, EdTheme.CYAN.b, 0.18), 5.0)
		for sx in [-1.0, 1.0]:
			for sy in [-1.0, 1.0]:
				var c: = q + Vector2(sx * s, sy * s)
				draw_line(c, c - Vector2(sx * 6.0, 0), EdTheme.CYAN, 1.8)
				draw_line(c, c - Vector2(0, sy * 6.0), EdTheme.CYAN, 1.8)



	func _draw_tool_cursor(kk: float) -> void :
		if is_nan(_mouse.x) or _drag != "" or ed.previewing():
			return
		var tool: = String(ed.tool)
		if tool in ["select", "move", "erase"]:
			return
		if EdTheme.is_aim_type(tool):
			var p: Vector2 = ed.clamp_playfield(_mouse)
			var q: = p2s(p)
			var col: Color = EdTheme.GOLD
			draw_arc(q, tun().click_hit_radius * kk, 0.0, TAU, 40, 
				Color(col.r, col.g, col.b, 0.45), 2.0)
			draw_line(q - Vector2(9, 0), q + Vector2(9, 0), 
				Color(col.r, col.g, col.b, 0.5), 1.2)
			draw_line(q - Vector2(0, 9), q + Vector2(0, 9), 
				Color(col.r, col.g, col.b, 0.5), 1.2)
			if p != _mouse:

				draw_dashed_line(p2s(_mouse), q, Color(col.r, col.g, col.b, 0.3), 
					1.0, 4.0)
		else:

			var i: = lane_at(_mouse)
			var col: Color = ed.main.LANE_COLS[i]
			var st: Dictionary = ed.fx_state_at(ed.t, vw())
			var quad: = StageRender.lane_quad(
				FxEval.lane_center(st, i, ed.t, tun().lane_width, 
					tun().lane_gap, vw()), 
				FxEval.lane_half(st, i, tun().lane_width), 
				vw() * 0.5, ed.main.LANE_PERSPECTIVE, 0.0, tun().hit_y)
			var poly: = PackedVector2Array()
			for q2 in quad:
				poly.append(p2s(q2))
			draw_colored_polygon(poly, Color(col.r, col.g, col.b, 0.07))
			draw_circle(p2s(Vector2(quad[3].x * 0.5 + quad[2].x * 0.5, 
				tun().hit_y)), 15.0 * kk, Color(col.r, col.g, col.b, 0.3))
