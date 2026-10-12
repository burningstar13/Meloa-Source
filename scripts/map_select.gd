class_name MapSelect
extends Control
























enum Source{SOLO, COMMUNITY}




const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")

const ROW_H: = 76.0


const PREVIEW_DEBOUNCE: = 0.26


const CHART_DEBOUNCE: = 0.12


const HEAVY_DEBOUNCE: = 0.22

var main
var source: = Source.SOLO
var community_maps: Array = []


var center_zone: Control
var cover_ring: CoverRing
var now_bar: NowPlayingBar


var _search: = ""
var _quick: = "ALL"


var _lvl_min: = 0.0
var _lvl_max: = 99.0
var _cleared_only: = false
var _filtered: Array = []


var _list: VirtualList
var _tab_indicator: Panel
var _tab_tw: Tween
var _tab_buttons: Array = []
var _search_edit: LineEdit
var _quick_buttons: = {}
var _filter_pop: PanelContainer
var _count_label: Label
var _empty_label: Label
var _title: Label
var _artist: Label
var _meta: Label
var _desc: Label
var _partner: Label
var _diff_wrap: Control
var _diff_cw: = -1.0
var _diff_h: = 98.0
var _diff_row: HFlowContainer

var _center_tws: Array = []





var _title_y: = 0.0
var _artist_y: = 0.0
var _play: Button
var _play_hint: Label
var _best_score: Label
var _best_grade: Label
var _acc_value: Label
var _clear_value: Label
var _yours_line: Label
var _lb_rows: VBoxContainer
var _lb_cap: Label
var _left: Control
var _right: Control


var badge_root: Control
var _secondary: Control


var _mode_row: HBoxContainer
var _mode_buttons: = {}
var _mode_hint: Label
var _mods_btn: Button
var _mods_line: Label
var _mods_pop: PanelContainer
var _mods_scroll: ScrollContainer
var _mods_rows: VBoxContainer





var _lvl_slider: HSlider
var _cleared_cb: CheckBox

var _status_filter: = ""
var _status_row: HFlowContainer
var _status_buttons: = {}

var _preview_wait: = 0.0
var _preview_pending: = ""
var _chart_wait: = 0.0
var _chart_pending: = ""
var _heavy_wait: = 0.0
var _heavy_pending: = false
var _lb_token: = 0
var _last_size: = Vector2.ZERO




func _ready() -> void :
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_header()
	_build_left()
	_build_center()
	_build_right()
	_build_now_playing()



	_build_mods_popover()
	_refresh_modes()
	_apply_source_ui()
	get_viewport().size_changed.connect(_layout)
	refresh_library.call_deferred()




func on_enter() -> void :
	_heavy_pending = true
	_heavy_wait = 0.0
	_layout()
	refresh_library()
	refresh_all()

	_refresh_modes()
	_refresh_mods_line()





func _f(display: = false) -> Font:
	return main.font_display if display else main.font_bold


func _cap(text: String, parent: Control, col: = Color(1, 1, 1, 0.38), 
		sz: = 11) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	if _f() != null:
		l.add_theme_font_override("font", _f())
	parent.add_child(l)
	return l











const VIO: = Color(0.62, 0.34, 1.0)
const VIO_DARK: = Color(0.055, 0.032, 0.105)
const RADIUS_SM: = 12
const RADIUS_MD: = 16
const RADIUS_LG: = 22
const DETAIL: = 16



func _zone_style() -> StyleBoxFlat:
	var st: = StyleBoxFlat.new()
	st.bg_color = Color(0.022, 0.017, 0.042, 0.8)
	st.set_corner_radius_all(RADIUS_LG)
	st.corner_detail = DETAIL
	st.border_color = Color(0.55, 0.4, 0.9, 0.16)
	st.set_border_width_all(1)
	st.anti_aliasing = true
	st.content_margin_left = 18
	st.content_margin_right = 18
	st.content_margin_top = 16
	st.content_margin_bottom = 16
	return st






func _ctl_style(radius: int, on: = false, hover: = false, 
		accent: = VIO) -> StyleBoxFlat:
	var st: = StyleBoxFlat.new()
	if on:
		st.bg_color = Color(accent.r * 0.2, accent.g * 0.14, accent.b * 0.3, 0.92)
	elif hover:
		st.bg_color = Color(accent.r * 0.13, accent.g * 0.09, accent.b * 0.22, 0.9)
	else:
		st.bg_color = Color(VIO_DARK.r, VIO_DARK.g, VIO_DARK.b, 0.62)
	st.set_corner_radius_all(radius)
	st.corner_detail = DETAIL
	st.anti_aliasing = true
	st.set_border_width_all(1)
	if on:

		st.border_color = Color(accent.r * 1.55, accent.g * 1.35, accent.b * 1.6, 1.0)
	elif hover:
		st.border_color = Color(accent.r * 1.15, accent.g * 0.95, accent.b * 1.25, 0.9)
	else:
		st.border_color = Color(accent.r, accent.g, accent.b, 0.2)
	return st



func _skin(b: Button, radius: int, on: = false, accent: = VIO, 
		mh: = 12, mv: = 8) -> void :
	for pair in [["normal", _ctl_style(radius, on, false, accent)], 
			["hover", _ctl_style(radius, on, true, accent)], 
			["pressed", _ctl_style(radius, true, false, accent)], 
			["focus", _ctl_style(radius, on, true, accent)]]:
		var st: StyleBoxFlat = pair[1]
		st.content_margin_left = mh
		st.content_margin_right = mh
		st.content_margin_top = mv
		st.content_margin_bottom = mv
		b.add_theme_stylebox_override(String(pair[0]), st)
	b.add_theme_color_override("font_color", 
		Color(0.92, 0.84, 1.06) if on else Color(1, 1, 1, 0.52))
	b.add_theme_color_override("font_hover_color", Color(0.96, 0.9, 1.1))
	b.add_theme_color_override("font_pressed_color", Color(1.0, 0.95, 1.15))


func _build_header() -> void :
	var back: = Button.new()
	back.name = "Back"
	back.text = "ESC  ·  BACK"
	back.focus_mode = Control.FOCUS_NONE
	back.position = Vector2(32, 26)
	back.add_theme_font_size_override("font_size", 12)
	if _f() != null:
		back.add_theme_font_override("font", _f())
	_skin(back, RADIUS_SM, false, VIO, 16, 9)
	back.set_meta("ui_sound", "back")
	back.pressed.connect( func() -> void : main._go_home_animated())
	add_child(back)




	_mode_row = HBoxContainer.new()
	_mode_row.position = Vector2(158, 26)
	_mode_row.add_theme_constant_override("separation", 6)
	add_child(_mode_row)
	for key in Mods.MODE_KEYS:
		var b: = Button.new()
		b.text = Mods.mode_name(key)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 12)
		if _f() != null:
			b.add_theme_font_override("font", _f())
		b.pressed.connect(_on_mode_tab.bind(key))
		_mode_row.add_child(b)
		_mode_buttons[key] = b
	_mode_hint = Label.new()
	_mode_hint.position = Vector2(158, 56)
	_mode_hint.add_theme_font_size_override("font_size", 10)
	_mode_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	if _f() != null:
		_mode_hint.add_theme_font_override("font", _f())
	_mode_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mode_hint)






	_secondary = Control.new()
	_secondary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_secondary)
	var acts: Array = [
		["settings", "SETTINGS", Callable(main, "_open_settings"), VIO], 
		["quit", "QUIT", Callable(main, "_quit_game"), main.COL_GOLD], 
	]
	for i in acts.size():
		var e: Array = acts[i]
		var b: Button = main._secondary_icon(_secondary, e[0], e[1], e[2], e[3])
		b.position = Vector2(i * 52.0, 0.0)




func _build_left() -> void :
	_left = PanelContainer.new()
	_left.add_theme_stylebox_override("panel", _zone_style())
	add_child(_left)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_left.add_child(v)



	var tabs: = Control.new()
	tabs.custom_minimum_size = Vector2(0, 50)





	tabs.resized.connect(_layout_tabs)
	v.add_child(tabs)
	var tabs_bg: = Panel.new()
	tabs_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var tbs: = _ctl_style(RADIUS_MD)
	tbs.bg_color = Color(0.015, 0.012, 0.03, 0.8)
	tbs.border_color = Color(0.55, 0.4, 0.9, 0.14)
	tabs_bg.add_theme_stylebox_override("panel", tbs)
	tabs_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tabs.add_child(tabs_bg)
	_tab_indicator = Panel.new()
	_tab_indicator.add_theme_stylebox_override("panel", 
		_ctl_style(RADIUS_SM, true))
	_tab_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tabs.add_child(_tab_indicator)
	for i in 2:
		var b: = Button.new()
		b.focus_mode = Control.FOCUS_NONE
		var empty: = StyleBoxEmpty.new()
		for s in ["normal", "hover", "pressed"]:
			b.add_theme_stylebox_override(s, empty)
		b.pressed.connect(_on_source_tab.bind(i))
		tabs.add_child(b)
		_tab_buttons.append(b)
		var t: = VBoxContainer.new()
		t.set_anchors_preset(Control.PRESET_FULL_RECT)
		t.add_theme_constant_override("separation", 0)
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.alignment = BoxContainer.ALIGNMENT_CENTER
		b.add_child(t)
		var head: = Label.new()
		head.text = ["COMMUNITY", "SOLO"][i]
		head.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.add_theme_font_size_override("font_size", 13)
		if _f(true) != null:
			head.add_theme_font_override("font", _f(true))
		t.add_child(head)
		var sub: = Label.new()
		sub.text = ["All maps", "Featured"][i]
		sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub.add_theme_font_size_override("font_size", 9)
		sub.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
		t.add_child(sub)
		b.set_meta("head", head)




	_browse_btn = _build_browse_button()
	v.add_child(_browse_btn)


	var srow: = HBoxContainer.new()
	srow.add_theme_constant_override("separation", 8)
	v.add_child(srow)
	_search_edit = LineEdit.new()
	_search_edit.placeholder_text = "SEARCH SONGS..."
	_search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_edit.custom_minimum_size = Vector2(0, 36)
	_search_edit.add_theme_font_size_override("font_size", 12)
	if _f() != null:
		_search_edit.add_theme_font_override("font", _f())


	var ss: = _ctl_style(18)
	ss.content_margin_left = 16
	ss.content_margin_right = 12
	_search_edit.add_theme_stylebox_override("normal", ss)
	_search_edit.add_theme_stylebox_override("focus", _ctl_style(18, true))
	_search_edit.add_theme_color_override("font_placeholder_color", 
		Color(1, 1, 1, 0.28))
	_search_edit.add_theme_color_override("font_color", Color(0.94, 0.9, 1.05))
	_search_edit.add_theme_color_override("caret_color", Color(0.85, 0.6, 1.15))
	_search_edit.text_changed.connect(_on_search)
	srow.add_child(_search_edit)
	var fb: = Button.new()
	fb.focus_mode = Control.FOCUS_NONE
	fb.custom_minimum_size = Vector2(36, 36)
	fb.tooltip_text = "Advanced filters"
	_skin(fb, 18, false, VIO, 0, 0)
	fb.draw.connect( func() -> void :
		var c: = fb.size * 0.5
		var col: = Color(1, 1, 1, 0.85 if fb.is_hovered() else 0.55)
		for i in 3:
			var y: = c.y - 6.0 + i * 6.0
			fb.draw_line(Vector2(c.x - 8, y), Vector2(c.x + 8, y), col, 1.4, true)
			fb.draw_circle(Vector2(c.x - 4.0 + i * 4.0, y), 2.2, col))
	fb.pressed.connect(_toggle_filter_popover)
	srow.add_child(fb)








	var qrow: = HFlowContainer.new()
	qrow.add_theme_constant_override("h_separation", 6)
	qrow.add_theme_constant_override("v_separation", 4)
	v.add_child(qrow)






	for key in ["ALL", "YOUR MAPS", "FAVORITES", "RECENT"]:
		var b: = Button.new()
		b.text = key
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 10)
		if _f() != null:
			b.add_theme_font_override("font", _f())
		b.pressed.connect(_on_quick.bind(key))
		qrow.add_child(b)
		_quick_buttons[key] = b
	_style_quick()




	_status_row = HFlowContainer.new()
	_status_row.add_theme_constant_override("h_separation", 6)
	_status_row.add_theme_constant_override("v_separation", 4)
	v.add_child(_status_row)
	for key in ["RANKED", "PENDING", "UNRANKED"]:
		var b: = Button.new()
		b.text = key
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 10)
		if _f() != null:
			b.add_theme_font_override("font", _f())
		b.pressed.connect(_on_status.bind(key))
		_status_row.add_child(b)
		_status_buttons[key] = b
	_style_status()


	_list = VirtualList.new()
	_list.item_height = ROW_H
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.make_item = func() -> Control:
		var r: = MapRow.new()
		r.font_bold = main.font_body
		r.font_display = _f()
		r.pressed.connect( func() -> void : _on_row_pressed(r))
		r.gui_input.connect( func(e: InputEvent) -> void : _on_row_input(r, e))
		return r
	_list.bind_item = func(row: Control, i: int) -> void :
		row.set_meta("track", _filtered[i])
		(row as MapRow).bind(_row_data(_filtered[i]))
	v.add_child(_list)
	_empty_label = Label.new()
	_empty_label.text = ""
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.add_theme_font_size_override("font_size", 12)
	_empty_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
	_empty_label.visible = false
	v.add_child(_empty_label)


	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	v.add_child(foot)
	var fcol: = VBoxContainer.new()
	fcol.add_theme_constant_override("separation", 0)
	fcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(fcol)
	_cap("ALL SONGS", fcol, Color(1, 1, 1, 0.34), 9)
	_count_label = Label.new()
	_count_label.add_theme_font_size_override("font_size", 20)
	if _f() != null:
		_count_label.add_theme_font_override("font", _f())
	_count_label.add_theme_color_override("font_color", Color(0.85, 0.62, 1.05))
	fcol.add_child(_count_label)
	var rnd: = Button.new()
	rnd.text = "RANDOM"
	rnd.focus_mode = Control.FOCUS_NONE
	rnd.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rnd.add_theme_font_size_override("font_size", 11)
	if _f() != null:
		rnd.add_theme_font_override("font", _f())
	_skin(rnd, 16, false, VIO, 18, 10)
	rnd.pressed.connect(random_map)
	foot.add_child(rnd)

	_build_filter_popover()


func _style_quick() -> void :
	for key in _quick_buttons:
		var b: Button = _quick_buttons[key]
		var on: bool = key == _quick
		_skin(b, 14, on, VIO, 11, 6)



const STATUS_COLS: = {
	"RANKED": Color(0.3, 1.0, 0.6), 
	"PENDING": Color(1.0, 0.82, 0.3), 
	"UNRANKED": Color(1.0, 0.36, 0.4), 
}

func _style_status() -> void :
	for key in _status_buttons:
		var b: Button = _status_buttons[key]
		_skin(b, 14, key == _status_filter, STATUS_COLS[key], 11, 6)


func _on_status(key: String) -> void :
	main.sfx.play_ui("click")
	_status_filter = "" if _status_filter == key else key
	_style_status()
	refresh_library()


const BROWSE_H: = 74.0


const CommunityCta: = preload("res://scripts/community_cta.gd")






func _build_browse_button() -> Button:
	var b: Button = CommunityCta.new()
	b.main = main
	b.pressed.connect(open_community_browser)
	return b




func _build_filter_popover() -> void :
	_filter_pop = PanelContainer.new()
	_filter_pop.visible = false
	var st: = _zone_style()
	st.bg_color = Color(0.045, 0.038, 0.085, 0.98)
	st.border_color = Color(0.72, 0.45, 1.0, 0.45)
	_filter_pop.add_theme_stylebox_override("panel", st)
	_filter_pop.custom_minimum_size = Vector2(260, 0)
	add_child(_filter_pop)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_filter_pop.add_child(v)
	_cap("LEVEL", v, Color(0.85, 0.62, 1.05), 10)
	var lrow: = HBoxContainer.new()
	lrow.add_theme_constant_override("separation", 8)
	v.add_child(lrow)



	var lbl: = _cap("0 — ∞", lrow, Color(1, 1, 1, 0.75), 12)
	lbl.custom_minimum_size = Vector2(64, 0)
	var slider_max: = HSlider.new()
	_lvl_slider = slider_max
	slider_max.min_value = 0.5
	slider_max.max_value = 15.0
	slider_max.step = 0.5
	slider_max.value = 15.0
	slider_max.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lrow.add_child(slider_max)
	var apply_lvl: = func(_v: float) -> void :
		_lvl_min = 0.0
		_lvl_max = slider_max.value
		if _lvl_max >= 15.0:
			_lvl_max = 99.0
		lbl.text = "0 — %s" % ("∞" if _lvl_max > 90.0 else "%.1f" % _lvl_max)
		refresh_library()
		_snap_diff_to_filter()
	slider_max.value_changed.connect(apply_lvl)
	var cb: = CheckBox.new()
	_cleared_cb = cb
	cb.text = "Cleared only"
	cb.focus_mode = Control.FOCUS_NONE
	cb.add_theme_font_size_override("font_size", 11)
	cb.toggled.connect( func(on: bool) -> void :
		_cleared_only = on
		refresh_library())
	v.add_child(cb)
	var reset: = Button.new()
	reset.text = "RESET"
	reset.focus_mode = Control.FOCUS_NONE
	reset.add_theme_font_size_override("font_size", 10)
	reset.pressed.connect(_reset_level_filter)
	v.add_child(reset)




func _reset_level_filter() -> void :
	if _lvl_slider != null:
		_lvl_slider.value = 15.0
	if _cleared_cb != null:
		_cleared_cb.button_pressed = false
	_cleared_only = false
	_lvl_min = 0.0
	_lvl_max = 99.0
	refresh_library()







func _build_mods_popover() -> void :
	_mods_pop = PanelContainer.new()
	_mods_pop.visible = false
	var st: = _zone_style()
	st.bg_color = Color(0.045, 0.038, 0.085, 0.98)
	st.border_color = Color(1.0, 0.82, 0.3, 0.45)
	_mods_pop.add_theme_stylebox_override("panel", st)
	_mods_pop.custom_minimum_size = Vector2(MODS_POP_W, 0)
	add_child(_mods_pop)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	_mods_pop.add_child(v)
	_cap("MODS", v, Color(1.0, 0.86, 0.45), 11)


	_mods_scroll = ScrollContainer.new()
	_mods_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_mods_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	v.add_child(_mods_scroll)
	_mods_rows = VBoxContainer.new()
	_mods_rows.add_theme_constant_override("separation", MODS_ROW_GAP)
	_mods_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mods_scroll.add_child(_mods_rows)
	var clear: = Button.new()
	clear.text = "NO MOD"
	clear.focus_mode = Control.FOCUS_NONE
	clear.add_theme_font_size_override("font_size", 10)
	clear.pressed.connect( func() -> void :
		Mods.clear()
		main._toggle_auto(false)
		main._toggle_invincible(false)
		_refresh_mods())
	v.add_child(clear)




func _refresh_mods() -> void :
	if _mods_rows == null:
		return




	for c in _mods_rows.get_children():
		_mods_rows.remove_child(c)
		c.queue_free()
	var count: = 0
	for m in Mods.available():
		count += 1
		var on: bool = Mods.has(m.id)
		var row: = Button.new()
		row.focus_mode = Control.FOCUS_NONE
		row.custom_minimum_size = Vector2(0, MODS_ROW_H)
		row.toggle_mode = true
		row.button_pressed = on
		row.text = ""
		_skin(row, RADIUS_SM, on, m.color, 10, 6)
		row.pressed.connect(_on_mod_pressed.bind(String(m.id)))
		_mods_rows.add_child(row)
		var h: = HBoxContainer.new()
		h.set_anchors_preset(Control.PRESET_FULL_RECT)
		h.add_theme_constant_override("separation", 10)
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.offset_left = 10
		h.offset_right = -10
		row.add_child(h)


		var dot: = Panel.new()
		dot.custom_minimum_size = Vector2(10, 10)
		dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ds: = StyleBoxFlat.new()
		ds.set_corner_radius_all(5)
		ds.bg_color = main.neon(m.color, 1.2) if on else Color(0, 0, 0, 0)
		ds.border_color = Color(m.color, 0.55)
		ds.set_border_width_all(1)
		dot.add_theme_stylebox_override("panel", ds)
		h.add_child(dot)
		var name_l: = Label.new()
		name_l.text = String(m.name)
		name_l.custom_minimum_size = Vector2(130, 0)
		name_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_l.add_theme_font_size_override("font_size", 13)
		name_l.add_theme_color_override("font_color", 
			main.neon(m.color, 1.15) if on else Color(m.color, 0.75))
		if _f() != null:
			name_l.add_theme_font_override("font", _f())
		name_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(name_l)
		var desc_l: = Label.new()
		desc_l.text = String(m.desc).replace("\n", "  ")
		desc_l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		desc_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		desc_l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS




		desc_l.clip_text = true
		desc_l.add_theme_font_size_override("font_size", 10)
		desc_l.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
		desc_l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(desc_l)
		var tag: = Label.new()
		tag.text = "×%.2f" % Mods.mult_of(String(m.id)) if bool(m.ranked) else "UNRANKED"
		tag.custom_minimum_size = Vector2(74, 0)
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		tag.add_theme_font_size_override("font_size", 10)
		tag.add_theme_color_override("font_color", 
			Color(1, 1, 1, 0.55) if bool(m.ranked) else Color(1.0, 0.42, 0.42, 0.9))
		tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(tag)



	var rows_h: = float(count) * MODS_ROW_H + maxf(count - 1, 0) * MODS_ROW_GAP
	_mods_scroll.custom_minimum_size.y = minf(rows_h, MODS_ROWS_MAX_H)
	if _mods_pop.visible:
		_layout_mods_pop()
	_refresh_mods_line()


func _on_mod_pressed(id: String) -> void :
	Mods.toggle(id)


	if id == "auto":
		main._toggle_auto(Mods.has("auto"))
	elif id == "invincible":
		main._toggle_invincible(Mods.has("invincible"))
	main.sfx.play_ui("click")
	_refresh_mods()



func _refresh_mods_line() -> void :
	if _mods_line == null:
		return
	var s: = Mods.summary()
	if s == "":
		_mods_line.text = ""
		return
	_mods_line.text = s if Mods.ranked() else s + "\nUNRANKED RUN"
	_mods_line.add_theme_color_override("font_color", 
		Color(main.COL_GOLD, 0.9) if Mods.ranked() else Color(1.0, 0.45, 0.45, 0.9))


func _toggle_mods_popover() -> void :
	if _mods_pop == null:
		_build_mods_popover()
	_mods_pop.visible = not _mods_pop.visible
	if not _mods_pop.visible:
		return
	_refresh_mods()
	_layout_mods_pop()
	_mods_pop.modulate.a = 0.0
	var tw: = _mods_pop.create_tween()
	tw.tween_property(_mods_pop, "modulate:a", 1.0, 0.12)






const MODS_POP_W: = 560.0
const MODS_ROW_H: = 46.0
const MODS_ROW_GAP: = 6.0
const MODS_ROWS_MAX_H: = 420.0

func _layout_mods_pop() -> void :
	if _mods_pop == null or not _mods_pop.visible:
		return


	var h: float = _mods_pop.get_combined_minimum_size().y
	_mods_pop.size = Vector2(MODS_POP_W, h)
	var vs: = get_viewport_rect().size
	_mods_pop.position = Vector2((vs.x - MODS_POP_W) * 0.5, 
		clampf(vs.y - h - 96.0, 60.0, maxf(vs.y - h - 20.0, 60.0)))




func _on_mode_tab(key: String) -> void :
	if Mods.mode_key() == key:
		return
	Mods.set_mode(key)
	main.sfx.play_ui("click")
	_refresh_modes()
	if _mods_pop != null and _mods_pop.visible:
		_refresh_mods()
	_refresh_mods_line()


	refresh_all()


func _refresh_modes() -> void :
	for key in _mode_buttons:
		var on: bool = Mods.mode_key() == key
		_skin(_mode_buttons[key], RADIUS_SM, on, 
			VIO if key == "STANDARD" else Color(0.35, 0.85, 1.0), 14, 8)
	if _mode_hint != null:
		if Mods.is_mania():
			var keys: Array = []
			for a in SettingsManager.MANIA_ACTIONS:
				keys.append(SettingsManager.key_label(SettingsManager.bind_of(a)))
			_mode_hint.text = "%s  ·  one key per lane" % "  ".join(keys)
		else:
			_mode_hint.text = "mouse aim  ·  click to hit"





func close_popovers() -> bool:


	if _browser != null and _browser.is_open():
		if _browser.on_escape():
			main.sfx.play_ui("back")
			return true
	var closed: = false
	for pop in [_mods_pop, _filter_pop]:
		if pop != null and pop.visible:
			pop.visible = false
			closed = true
	if closed:
		main.sfx.play_ui("back")
	return closed






func _input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventMouseButton)\
	or not event.pressed or event.device != main.SYNTH_DEVICE:
		return
	for pop in [_mods_pop, _filter_pop]:
		if pop != null and pop.visible\
		and not pop.get_global_rect().has_point(event.position):
			close_popovers()
			get_viewport().set_input_as_handled()
			return


func _toggle_filter_popover() -> void :
	_filter_pop.visible = not _filter_pop.visible
	if not _filter_pop.visible:
		return
	_filter_pop.modulate.a = 0.0
	_filter_pop.scale = Vector2(0.97, 0.97)
	_filter_pop.pivot_offset = Vector2(130, 0)
	var tw: = _filter_pop.create_tween()
	tw.tween_property(_filter_pop, "modulate:a", 1.0, 0.12)
	tw.parallel().tween_property(_filter_pop, "scale", Vector2.ONE, 0.16)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)




func _build_center() -> void :
	center_zone = Control.new()
	center_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center_zone)

	cover_ring = CoverRing.new()
	cover_ring.glow_tex = main.glow_tex
	cover_ring.beat_bus = main.beat_bus
	center_zone.add_child(cover_ring)
	cover_ring.set_font(_f(true))

	_partner = Label.new()
	_partner.text = main.PARTNER_LABEL
	_partner.visible = false
	_partner.add_theme_font_size_override("font_size", 10)
	_partner.add_theme_color_override("font_color", Color(0.1, 0.08, 0.02))
	if _f() != null:
		_partner.add_theme_font_override("font", _f())
	var ps: = StyleBoxFlat.new()
	ps.bg_color = Color(1.0, 0.82, 0.3, 0.95)
	ps.set_corner_radius_all(6)
	ps.content_margin_left = 9
	ps.content_margin_right = 9
	ps.content_margin_top = 3
	ps.content_margin_bottom = 3
	_partner.add_theme_stylebox_override("normal", ps)
	_partner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_zone.add_child(_partner)



	_title = _center_label(TITLE_MAX, Color(1, 1, 1, 0.98), false)
	_artist = _center_label(15, Color(0.8, 0.6, 1.05, 0.95), false)
	_meta = _center_label(12, Color(1, 1, 1, 0.55), false)
	_meta.visible = false
	_desc = _center_label(12, Color(1, 1, 1, 0.32), false)
















	_diff_wrap = Control.new()
	_diff_wrap.clip_contents = true
	_diff_wrap.name = "DiffWrap"
	center_zone.add_child(_diff_wrap)
	_diff_row = HFlowContainer.new()
	_diff_row.alignment = FlowContainer.ALIGNMENT_CENTER
	_diff_wrap.add_child(_diff_row)


	_play = Button.new()
	_play.focus_mode = Control.FOCUS_NONE
	_play.custom_minimum_size = Vector2(74, 74)
	_play.size = Vector2(74, 74)
	_play.pivot_offset = Vector2(37, 37)
	_play.rotation = PI / 4.0



	var jn: = _ctl_style(16, true)
	jn.bg_color = Color(0.045, 0.022, 0.085, 0.92)
	jn.border_color = Color(1.05, 0.62, 1.7, 1.0)
	var jh: StyleBoxFlat = jn.duplicate()
	jh.bg_color = Color(0.085, 0.038, 0.15, 0.95)
	jh.border_color = Color(1.35, 0.85, 2.0, 1.0)
	_play.add_theme_stylebox_override("normal", jn)
	_play.add_theme_stylebox_override("hover", jh)
	_play.add_theme_stylebox_override("pressed", jh)
	_play.set_meta("ui_sound", "impact")
	_play.pressed.connect(launch)
	_play.mouse_entered.connect( func() -> void : _play_zoom(1.08))
	_play.mouse_exited.connect( func() -> void : _play_zoom(1.0))
	center_zone.add_child(_play)
	var tri: = Polygon2D.new()
	tri.polygon = PackedVector2Array([Vector2(-9, -13), Vector2(-9, 13), Vector2(16, 0)])
	tri.color = Color(1, 1, 1, 0.96)
	tri.position = Vector2(37, 37)
	tri.rotation = - PI / 4.0
	_play.add_child(tri)

	_play_hint = Label.new()
	_play_hint.text = "NOT AVAILABLE"
	_play_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_play_hint.add_theme_font_size_override("font_size", 11)
	_play_hint.add_theme_color_override("font_color", Color(1.0, 0.35, 0.4, 0.9))
	if _f() != null:
		_play_hint.add_theme_font_override("font", _f())
	_play_hint.visible = false
	_play_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_zone.add_child(_play_hint)




	_mods_btn = Button.new()
	_mods_btn.text = "MODS"
	_mods_btn.focus_mode = Control.FOCUS_NONE
	_mods_btn.custom_minimum_size = Vector2(92, 34)
	_mods_btn.add_theme_font_size_override("font_size", 12)
	if _f() != null:
		_mods_btn.add_theme_font_override("font", _f())
	_skin(_mods_btn, RADIUS_SM, false, main.COL_GOLD, 14, 8)
	_mods_btn.pressed.connect(_toggle_mods_popover)
	center_zone.add_child(_mods_btn)
	_mods_line = Label.new()
	_mods_line.add_theme_font_size_override("font_size", 11)
	_mods_line.add_theme_color_override("font_color", Color(main.COL_GOLD, 0.9))
	_mods_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _f() != null:
		_mods_line.add_theme_font_override("font", _f())
	_mods_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_zone.add_child(_mods_line)


func _center_label(sz: int, col: Color, display: bool) -> Label:
	var l: = Label.new()
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER



	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	l.clip_text = true
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	var f: = _f(display)
	if f != null:
		l.add_theme_font_override("font", f)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center_zone.add_child(l)
	return l


func _play_zoom(target: float) -> void :
	var tw: = _play.create_tween()
	tw.tween_property(_play, "scale", Vector2.ONE * target, 0.14)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)




func _build_right() -> void :
	_right = PanelContainer.new()
	_right.add_theme_stylebox_override("panel", _zone_style())
	add_child(_right)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	_right.add_child(v)

	_cap("BEST SCORE", v, Color(0.85, 0.62, 1.05), 11)
	var srow: = HBoxContainer.new()
	srow.add_theme_constant_override("separation", 12)
	v.add_child(srow)
	_best_score = Label.new()
	_best_score.add_theme_font_size_override("font_size", 34)
	_best_score.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _f() != null:
		_best_score.add_theme_font_override("font", _f())
	srow.add_child(_best_score)
	_best_grade = Label.new()
	_best_grade.custom_minimum_size = Vector2(44, 44)
	_best_grade.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_best_grade.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_best_grade.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_best_grade.add_theme_font_size_override("font_size", 22)
	if _f() != null:
		_best_grade.add_theme_font_override("font", _f())
	var gs: = StyleBoxFlat.new()
	gs.bg_color = Color(0.03, 0.028, 0.06, 0.9)
	gs.set_corner_radius_all(22)
	gs.set_border_width_all(1)
	gs.border_color = Color(1, 1, 1, 0.15)
	_best_grade.add_theme_stylebox_override("normal", gs)
	srow.add_child(_best_grade)

	var stats: = HBoxContainer.new()
	stats.add_theme_constant_override("separation", 26)
	v.add_child(stats)
	var c1: = VBoxContainer.new()
	c1.add_theme_constant_override("separation", 1)
	stats.add_child(c1)
	_cap("ACCURACY", c1, Color(1, 1, 1, 0.36), 10)
	_acc_value = Label.new()
	_acc_value.add_theme_font_size_override("font_size", 19)
	if _f() != null:
		_acc_value.add_theme_font_override("font", _f())
	c1.add_child(_acc_value)
	var c2: = VBoxContainer.new()
	c2.add_theme_constant_override("separation", 1)
	stats.add_child(c2)
	_cap("CLEAR", c2, Color(1, 1, 1, 0.36), 10)
	_clear_value = Label.new()
	_clear_value.add_theme_font_size_override("font_size", 19)
	if _f() != null:
		_clear_value.add_theme_font_override("font", _f())
	c2.add_child(_clear_value)

	_yours_line = Label.new()
	_yours_line.add_theme_font_size_override("font_size", 11)
	_yours_line.add_theme_color_override("font_color", Color(1, 1, 1, 0.42))
	if _f() != null:
		_yours_line.add_theme_font_override("font", _f())
	v.add_child(_yours_line)

	var sep: = Panel.new()
	sep.custom_minimum_size = Vector2(0, 1)
	var sps: = StyleBoxFlat.new()
	sps.bg_color = Color(1, 1, 1, 0.07)
	sep.add_theme_stylebox_override("panel", sps)
	v.add_child(sep)



	_lb_cap = _cap("GLOBAL RANKING", v, Color(0.85, 0.62, 1.05), 11)
	_lb_rows = VBoxContainer.new()
	_lb_rows.add_theme_constant_override("separation", 2)
	_lb_rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_lb_rows)

	var full: = Button.new()
	full.text = "VIEW FULL LEADERBOARD"
	full.focus_mode = Control.FOCUS_NONE
	full.add_theme_font_size_override("font_size", 11)
	if _f() != null:
		full.add_theme_font_override("font", _f())
	var fs: = StyleBoxFlat.new()
	fs.bg_color = Color(0.06, 0.05, 0.11, 0.75)
	fs.set_corner_radius_all(10)
	fs.border_color = Color(1, 1, 1, 0.1)
	fs.set_border_width_all(1)
	fs.content_margin_top = 9
	fs.content_margin_bottom = 9
	full.add_theme_stylebox_override("normal", fs)
	var fh: StyleBoxFlat = fs.duplicate()
	fh.border_color = Color(0.72, 0.45, 1.0, 0.6)
	fh.bg_color = Color(0.1, 0.07, 0.16, 0.9)
	full.add_theme_stylebox_override("hover", fh)
	full.add_theme_stylebox_override("pressed", fh)
	full.pressed.connect( func() -> void : main._open_leaderboard())
	v.add_child(full)


func _build_now_playing() -> void :
	now_bar = NowPlayingBar.new()
	now_bar.main = main
	now_bar.beat_bus = main.beat_bus
	add_child(now_bar)
	now_bar.set_fonts(_f(), _f())






func _layout() -> void :



	var vs: = get_viewport_rect().size
	if vs.x < 100.0:
		return
	_last_size = vs
	position = Vector2.ZERO
	size = vs
	var lw: = clampf(vs.x * 0.245, 330.0, 460.0)
	var rw: = clampf(vs.x * 0.235, 320.0, 430.0)
	var top: = 78.0
	var pad: = 28.0
	_left.position = Vector2(pad, top)
	_left.size = Vector2(lw, vs.y - top - pad)
	_filter_pop.position = Vector2(pad + lw - 260.0, top + 116.0 + BROWSE_H + 12.0)
	_filter_pop.size = Vector2(260, 0)



	if badge_root != null:
		badge_root.position = Vector2((vs.x - badge_root.size.x) * 0.5, 18.0)
	if _secondary != null:
		_secondary.position = Vector2(vs.x - pad - 2.0 * 52.0 + 14.0, 22.0)
	var nb_h: = now_bar.size.y
	_right.position = Vector2(vs.x - pad - rw, top)
	_right.size = Vector2(rw, vs.y - top - pad - nb_h - 16.0)
	now_bar.position = Vector2(vs.x - pad - rw + 6.0, vs.y - pad - nb_h + 6.0)



	var cx: = pad + lw
	var cw: = vs.x - pad * 2.0 - lw - rw
	center_zone.position = Vector2(cx, top)
	center_zone.size = Vector2(cw, vs.y - top - pad)




	var ch: = center_zone.size.y


	var play_y: = ch - 80.0
	_play.position = Vector2((cw - 74.0) * 0.5, play_y)
	_play_hint.position = Vector2(0, play_y + 80.0)
	_play_hint.size = Vector2(cw, 16)

	if _mods_btn != null:
		_mods_btn.position = Vector2((cw - 74.0) * 0.5 - 132.0, play_y + 20.0)
		_mods_line.position = Vector2((cw - 74.0) * 0.5 + 96.0, play_y + 14.0)
		_mods_line.size = Vector2(maxf(cw * 0.5 - 100.0, 120.0), 44)
	var wrap: Control = _diff_wrap



	var was_cw: = _diff_cw


	var inner: = maxf(cw - DIFF_SIDE_PAD * 2.0, 120.0)
	_diff_cw = inner
	var dm: = _diff_metrics(inner, 
		MapLibrary.diffs_of(main.tuning.current_track).size())
	_diff_h = float(dm.height)
	var wrap_y: = play_y - _diff_h - 20.0
	wrap.position = Vector2((cw - inner) * 0.5, wrap_y)
	wrap.size = Vector2(inner, _diff_h)


	_diff_row.position = Vector2((inner - float(dm.row_w)) * 0.5, 0.0)
	_diff_row.size = Vector2(float(dm.row_w), float(dm.full))


	if _diff_row.get_child_count() > 0 and not is_equal_approx(cw, was_cw):
		_refresh_difficulties.call_deferred()



	for tw in _center_tws:
		if tw != null and tw.is_valid():
			tw.kill()
	_center_tws.clear()
	_title.modulate.a = 1.0
	_artist.modulate.a = 1.0


	var y: = wrap_y - 26.0
	_place(_desc, y, 20.0, cw)
	y -= 30.0
	_place(_artist, y, 26.0, cw)
	_artist_y = y
	y -= 60.0
	_place(_title, y, 60.0, cw)
	_title_y = y
	_fit_title()






	var cover_box: = clampf(minf(cw * 0.78, y - 14.0), 140.0, 560.0)
	cover_ring.position = Vector2((cw - cover_box) * 0.5, maxf(y - 12.0 - cover_box, 0.0))
	cover_ring.size = Vector2(cover_box, cover_box)
	_partner.position = Vector2((cw - 120.0) * 0.5, 
		cover_ring.position.y + cover_box * 0.16 - 9.0)
	_layout_tabs()


func _place(l: Control, y: float, h: float, w: float) -> void :
	l.position = Vector2(0, y)
	l.size = Vector2(w, h)






const TITLE_MAX: = 44
const TITLE_MIN: = 24

func _fit_title() -> void :
	if _title == null or _title.text == "":
		return
	var f: Font = _f()
	if f == null:
		return
	var avail: = _title.size.x - 24.0
	var sz: = TITLE_MAX
	while sz > TITLE_MIN\
	and f.get_string_size(_title.text, HORIZONTAL_ALIGNMENT_LEFT, 
			-1, sz).x > avail:
		sz -= 2
	_title.add_theme_font_size_override("font_size", sz)


func _layout_tabs() -> void :
	if _tab_buttons.size() < 2:
		return
	var tabs: Control = _tab_buttons[0].get_parent()
	var w: = tabs.size.x
	if w < 10.0:
		return
	var half: = (w - 8.0) * 0.5
	for i in 2:
		var b: Button = _tab_buttons[i]
		b.position = Vector2(4.0 + i * half, 4.0)
		b.size = Vector2(half, tabs.size.y - 8.0)

	if _tab_tw != null and _tab_tw.is_valid():
		_tab_tw.kill()
	_tab_indicator.size = Vector2(half, tabs.size.y - 8.0)
	_tab_indicator.position = Vector2(4.0 + (1 if source == Source.SOLO else 0) * half, 4.0)









func _source_maps() -> Array:
	if source == Source.COMMUNITY:


		var out: Array = MapLibrary.user_tracks()
		for t in Tuning.TRACKS.keys():
			if not Tuning.FEATURED.has(t):
				out.append(t)
		out.append_array(community_maps)
		return out
	var feat: Array = []
	for t in Tuning.FEATURED:
		if Tuning.TRACKS.has(t):
			feat.append(t)
	return feat


func _meta_of(track: String, diff: = "") -> Dictionary:
	var d: = diff if diff != "" else _hardest_diff(track)
	return main._chart_meta_diff.get(track + "|" + d, 
		main._chart_meta.get(track, {}))


func _hardest_diff(track: String) -> String:
	return MapLibrary.hardest_diff(track)



func _lvl_filtered() -> bool:
	return _lvl_min > 0.0 or _lvl_max < 90.0










func _diff_in_range(track: String) -> String:



	if MapLibrary.is_user_map(track) and not MapLibrary.is_shared(track):
		var own: = MapLibrary.diffs_of(track)
		if not own.is_empty():
			return String(own.keys()[0])
	var best: = ""
	var best_lvl: = -1.0
	for dkey in MapLibrary.diffs_of(track):
		var d: = String(dkey)
		var lvl: float = main._density_level(_meta_of(track, d))
		if lvl < _lvl_min or lvl > _lvl_max:
			continue
		if lvl > best_lvl:
			best_lvl = lvl
			best = d
	return best






func _visible_diffs(track: String) -> Array:
	var out: Array = []
	for dkey in MapLibrary.diffs_of(track):
		var d: = String(dkey)
		if _lvl_filtered():
			var lvl: float = main._density_level(_meta_of(track, d))
			if lvl < _lvl_min or lvl > _lvl_max:
				continue
		out.append(d)
	return out






func _snap_diff_to_filter() -> void :
	if not _lvl_filtered():
		return
	var track: String = main.tuning.current_track
	if track == "" or not MapLibrary.has(track):
		return
	var cur: float = main._density_level(_meta_of(track, main.tuning.current_diff))
	if cur >= _lvl_min and cur <= _lvl_max:
		return
	var d: = _diff_in_range(track)
	if d == "" or d == String(main.tuning.current_diff):
		return
	main.tuning.apply_track(track, d)
	main._load_chart()
	refresh_all()


func _best_record(track: String, diff: String) -> Dictionary:
	return main.map_records.get(main._rec_key(track, diff), {})




func _best_grade_of(track: String) -> Array:
	var order: = ["SS", "S", "A", "B", "C", "D", "F"]
	var best: = ""
	for d in MapLibrary.diffs_of(track):
		var g: = String(_best_record(track, String(d)).get("grade", ""))
		if g == "":
			continue
		if best == "" or order.find(g) < order.find(best):
			best = g
	if best == "":
		return ["", Color(1, 1, 1, 0.3)]
	return [best, main.GRADE_COLS.get(best, Color(1, 1, 1, 0.5))]


func _row_data(track: String) -> Dictionary:



	var meta: = _meta_of(track, _diff_in_range(track) if _lvl_filtered() else "")
	var lvl: float = main._density_level(meta)
	var tier: Array = main._tier_for(lvl)
	var g: = _best_grade_of(track)
	return {
		"title": main.track_title(track), 
		"artist": main.track_artist(track), 
		"cover": main.track_covers.tex(track), 
		"pips": clampi(int(round(lvl / 3.0)) + 1, 1, 5), 
		"grade": g[0], 
		"grade_col": g[1], 
		"accent": tier[1], 
		"selected": track == main.tuning.current_track, 
		"locked": main._is_locked(track), 
		"favorite": SettingsManager.is_favorite(track), 


		"badge": MapLibrary.status_of(track) == MapLibrary.STATUS_DRAFT, 



		"ranking": _ranking_badge_of(track), 


		"wip": MapLibrary.online_wip_of(track), 


		"meloved": MapLibrary.online_meloved_of(track), 
		"outdated": MapLibrary.is_outdated(track), 
	}







func refresh_library() -> void :
	var names: Array = _source_maps()
	var q: = _search.strip_edges().to_lower()
	var out: Array = []
	for n in names:
		var track: = String(n)
		if q != "":
			var hay: String = ("%s %s %s" % [main.track_title(track), 
				main.track_artist(track), main.track_desc(track)]).to_lower()
			if not hay.contains(q):
				continue

		if _quick == "YOUR MAPS" and ( not MapLibrary.is_user_map(track)
				or MapLibrary.status_of(track) == MapLibrary.STATUS_DOWNLOADED):
			continue
		if _quick == "FAVORITES" and not SettingsManager.is_favorite(track):
			continue
		if _quick == "RECENT" and not SettingsManager.recent_maps.has(track):
			continue

		if _status_filter != "" and _ranking_badge_of(track) != _status_filter.to_lower():
			continue


		if _diff_in_range(track) == "":
			continue
		if _cleared_only and _best_grade_of(track)[0] == "":
			continue
		out.append(track)
	if _quick == "RECENT":

		out.sort_custom( func(a, b):
			return SettingsManager.recent_maps.find(a)\
			< SettingsManager.recent_maps.find(b))
	elif _quick == "YOUR MAPS":
		pass
	else:
		out.sort_custom( func(a, b):
			return main.track_title(String(a)) < main.track_title(String(b)))
	_filtered = out
	_list.set_count(_filtered.size())




	_list.refresh()
	_count_label.text = "%d" % _filtered.size()
	_empty_label.visible = _filtered.is_empty()
	if _filtered.is_empty():
		if _status_filter != "":
			_empty_label.text = "No %s map here." % _status_filter.to_lower()
		elif _quick == "YOUR MAPS":
			_empty_label.text = """No maps of your own yet.
""" + "Create one from the EDITOR on the home screen."
		elif source == Source.COMMUNITY and _search == "":
			_empty_label.text = "No community maps yet."
		else:
			_empty_label.text = "No results."


	var idx: = _filtered.find(main.tuning.current_track)
	if idx >= 0:
		_list.ensure_visible(idx)
	elif not _filtered.is_empty():
		select_map(String(_filtered[0]))


func _on_search(text: String) -> void :
	_search = text
	refresh_library()












signal download_changed(online_id: String)





var _downloads: = {}

var _download_errors: = {}
var _browser: CommunityBrowser
var _browse_btn: Button




func download_state(online_id: String) -> Dictionary:
	if _downloads.has(online_id):
		return {"label": String(_downloads[online_id].get("label", "DOWNLOADING…"))}
	if _download_errors.has(online_id):
		return {"error": String(_download_errors[online_id])}
	return {}







func start_download(m: Dictionary) -> void :
	var online_id: = String(m.get("id", ""))
	if online_id == "" or _downloads.has(online_id):
		return
	var title: = String(m.get("title", "map"))
	_download_errors.erase(online_id)
	_downloads[online_id] = {"label": "REQUESTING…", "title": title}
	download_changed.emit(online_id)


	var progress: = func(msg: String) -> void :
		if not _downloads.has(online_id):
			return
		var low: = msg.to_lower()
		var label: = "DOWNLOADING…"
		if low.begins_with("downloading"):
			var rest: = low.trim_prefix("downloading").strip_edges().trim_suffix("…").strip_edges()
			label = "DOWNLOADING… " + rest.to_upper() if rest != "" else "DOWNLOADING…"
		elif low.begins_with("installing"):
			label = "INSTALLING…"
		elif low.begins_with("requesting"):
			label = "REQUESTING…"
		else:
			label = msg.to_upper().trim_suffix("…") + "…"
		_downloads[online_id]["label"] = label
		download_changed.emit(online_id)
	var r: Dictionary = await MapPublisher.download(m, progress)
	_downloads.erase(online_id)
	if not is_inside_tree():
		return
	if r.ok:
		main.sfx.play_ui("impact")


		main._scan_charts()
		_library_dirty = false
		refresh_library()


		main._screen_toast("MAP INSTALLED — %s" % title.to_upper(), main.COL_GOLD)
	else:
		main.sfx.play_ui("back")
		_download_errors[online_id] = String(r.message)
		main._screen_toast("DOWNLOAD FAILED — %s" % String(r.message).to_upper(), 
			main.COL_RED)
	download_changed.emit(online_id)





func open_community_browser() -> void :
	for pop in [_mods_pop, _filter_pop]:
		if pop != null:
			pop.visible = false
	if _browser == null:
		_browser = CommunityBrowser.new()
		_browser.main = main
		_browser.select = self
		_browser.play_requested.connect(_play_from_browser)
		download_changed.connect(_browser.on_download_changed)
		add_child(_browser)
	_browser.open()






func _play_from_browser(online_id: String) -> void :
	if _browser != null:
		_browser.close()
	if source != Source.COMMUNITY:
		_on_source_tab(0)


	if _search != "":
		_search = ""
		_search_edit.text = ""
	if _quick != "ALL":
		_quick = "ALL"
		_style_quick()
	if _status_filter != "":
		_status_filter = ""
		_style_status()
	_library_dirty = true
	_refresh_installed()
	var track: = MapLibrary.find_online(online_id)
	if track == "":
		main._screen_toast("MAP NOT FOUND IN YOUR LIBRARY — TRY AGAIN", main.COL_RED)
		return
	if _filtered.find(track) < 0 and (_lvl_filtered() or _cleared_only):
		_reset_level_filter()
	select_map(track)
	var idx: = _filtered.find(track)
	if idx >= 0:
		_list.ensure_visible(idx)






var _library_dirty: = false





func _reload_community() -> void :
	_library_dirty = true
	_refresh_installed()




var _rank_sync_token: = 0
var _rank_sync_at: = -1000000000.0

func _sync_rankings_from_catalog(force: = false) -> void :
	var now: = Time.get_ticks_msec() / 1000.0
	if not force and now - _rank_sync_at < 30.0:
		return
	_rank_sync_at = now



	var ids: Array = []
	for t in MapLibrary.user_tracks():
		if MapLibrary.is_shared(String(t)):
			var oid: = String(MapLibrary.meta_of(String(t)).get("online_id", ""))
			if oid != "":
				ids.append(oid)
	if ids.is_empty():
		return
	_rank_sync_token += 1
	var token: = _rank_sync_token
	var r: Dictionary = await Backend.api_maps_status(ids)
	if token != _rank_sync_token or not is_inside_tree():
		return
	if not r.ok:
		if r.code == 404:
			await _sync_rankings_legacy()
		return
	if not (r.data is Array):
		return
	var changed: = false
	for m in r.data:
		if not (m is Dictionary):
			continue
		var installed: = MapLibrary.find_online(String(m.get("id", "")))
		if installed == "":
			continue
		var nrk: = String(m.get("ranking", "pending")).to_lower()
		if MapLibrary.online_ranking_of(installed) != nrk:
			MapLibrary.set_online_ranking(installed, nrk)
			changed = true
		var nwip: = bool(m.get("wip", false))
		if MapLibrary.online_wip_of(installed) != nwip:
			MapLibrary.set_online_wip(installed, nwip)
			changed = true
		var nver: = int(m.get("version", 1))
		if MapLibrary.online_latest_of(installed) != nver:
			MapLibrary.set_online_latest(installed, nver)
			changed = true
		var nmel: = bool(m.get("meloved", false))
		if MapLibrary.online_meloved_of(installed) != nmel:
			MapLibrary.set_online_meloved(installed, nmel)
			changed = true
	if changed:
		refresh_library()
		refresh_all()



func _sync_rankings_legacy() -> void :
	var shared: Array = []
	for t in MapLibrary.user_tracks():
		if MapLibrary.is_shared(String(t)):
			shared.append(String(t))
	if shared.is_empty():
		return
	_rank_sync_token += 1
	var token: = _rank_sync_token
	var r: Dictionary = await MapCatalog.search("")
	if token != _rank_sync_token or not is_inside_tree() or r.status != "ok":
		return
	var changed: = false
	for m in r.maps:
		var installed: = MapLibrary.find_online(String(m.get("id", "")))
		if installed == "":
			continue
		var before: = MapLibrary.online_ranking_of(installed)
		var nrk: = String(m.get("ranking", "pending")).to_lower()
		if before != nrk:
			MapLibrary.set_online_ranking(installed, nrk)
			changed = true

		var nwip: = bool(m.get("wip", false))
		if MapLibrary.online_wip_of(installed) != nwip:
			MapLibrary.set_online_wip(installed, nwip)
			changed = true
	if changed:
		refresh_library()
		refresh_all()



func _ranking_badge_of(track: String) -> String:
	if MapLibrary.is_user_map(track):
		if not MapLibrary.is_shared(track):
			return ""
		var rk: = MapLibrary.online_ranking_of(track)
		return rk if rk != "" else "pending"

	return "" if main._is_locked(track) else "ranked"


func _refresh_installed() -> void :
	var was_dirty: = _library_dirty
	if _library_dirty:
		_library_dirty = false
		MapLibrary.rescan()
		main._scan_charts()
	refresh_library()
	if was_dirty:
		_sync_rankings_from_catalog(true)







func _apply_source_ui() -> void :
	if _browse_btn != null:
		_browse_btn.visible = source == Source.COMMUNITY
	if _status_row != null:
		_status_row.visible = source == Source.COMMUNITY


func _on_quick(key: String) -> void :
	main.sfx.play_ui("click")
	_quick = key
	_style_quick()
	refresh_library()


func _on_source_tab(i: int) -> void :
	var want: = Source.COMMUNITY if i == 0 else Source.SOLO
	if want == source:


		main.sfx.play_ui("click")
		_reload_community()
		return
	source = want
	main.sfx.play_ui("click")



	var tabs_ctl: Control = _tab_buttons[0].get_parent()
	var half: = (tabs_ctl.size.x - 8.0) * 0.5
	_tab_indicator.size = Vector2(half, tabs_ctl.size.y - 8.0)




	if _tab_tw != null and _tab_tw.is_valid():
		_tab_tw.kill()
	_tab_tw = create_tween()
	_tab_tw.tween_property(_tab_indicator, "position:x", 
		4.0 + (1 if source == Source.SOLO else 0) * half, 0.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_list.modulate.a = 0.25
	_list.position.x = (10.0 if source == Source.SOLO else -10.0)
	var ltw: = _list.create_tween()
	ltw.tween_property(_list, "modulate:a", 1.0, 0.18)
	ltw.parallel().tween_property(_list, "position:x", 0.0, 0.22)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_apply_source_ui()
	_refresh_installed()


func _on_row_pressed(row: MapRow) -> void :
	if _list.click_suppressed():
		return
	select_map(String(row.get_meta("track", "")))



func _on_row_input(row: MapRow, event: InputEvent) -> void :
	if not (event is InputEventMouseButton) or not event.pressed:
		return
	var mb: = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.double_click:
		select_map(String(row.get_meta("track", "")))
		launch()
	elif mb.button_index == MOUSE_BUTTON_RIGHT:
		_row_menu(String(row.get_meta("track", "")), 
			row.get_global_rect().position + mb.position)






func _row_menu(track: String, at: Vector2) -> void :
	if track == "" or not MapLibrary.has(track):
		return
	main.sfx.play_ui("click")
	select_map(track)
	var mine: bool = MapLibrary.is_user_map(track)\
	and MapLibrary.status_of(track) != MapLibrary.STATUS_DOWNLOADED
	var fav: bool = SettingsManager.is_favorite(track)

	var inspect: bool = not mine and MapLibrary.is_user_map(track)\
	and MapLibrary.status_of(track) == MapLibrary.STATUS_DOWNLOADED\
	and Backend.is_reviewer()
	var can_edit: bool = mine or inspect or OS.has_feature("editor")
	var items: Array = [
		{"title": main.track_title(track).substr(0, 28).to_upper()}, 
		{"text": "Play", "id": "play", "accent": VIO, "hint": "Enter", 
			"disabled": main._is_locked(track)}, 
		{"text": "Remove from favorites" if fav else "Add to favorites", 
			"id": "fav", "check": fav}, 
		{"sep": true}, 
		{"text": "Inspect map (read-only)..." if inspect else "Edit map...", 
			"id": "edit", "accent": Color(0.3, 1.0, 0.85), 
			"disabled": not can_edit}, 
	]



	var downloaded: bool = MapLibrary.is_user_map(track)\
	and MapLibrary.status_of(track) == MapLibrary.STATUS_DOWNLOADED
	if mine:
		items.append({"text": "Delete map...", "id": "del", 
			"accent": Color(1.0, 0.36, 0.36)})
	elif downloaded:
		items.append({"text": "Remove downloaded map...", "id": "del", 
			"accent": Color(1.0, 0.36, 0.36)})
	else:
		items.append({"text": "Shipped map - cannot be deleted", "id": "", 
			"disabled": true})
	if not can_edit:
		items.append({"sep": true})
		items.append({"text": "Editing shipped maps needs a dev build", 
			"id": "", "disabled": true})
	EdMenu.open(main.menu_root, items, at, _f(), 
		func(id: String): _row_menu_pick(track, id), 236)


func _row_menu_pick(track: String, id: String) -> void :
	match id:
		"play":
			launch()
		"fav":
			SettingsManager.toggle_favorite(track)
			main.sfx.play_ui("click")
			_list.refresh()
			refresh_library()
		"edit":
			main.sfx.play_ui("click")
			main._open_editor()
		"del":
			_confirm_delete(track)






func _confirm_delete(track: String) -> void :
	var n: int = MapLibrary.diffs_of(track).size()
	var online_id: = String(MapLibrary.meta_of(track).get("online_id", ""))
	var published: = online_id != ""\
	and MapLibrary.status_of(track) == MapLibrary.STATUS_PUBLISHED
	var downloaded: = MapLibrary.status_of(track) == MapLibrary.STATUS_DOWNLOADED
	var vs: = get_viewport_rect().size
	var items: Array
	if published:



		items = [
			{"title": "DELETE \"%s\" EVERYWHERE ?" % main.track_title(track).substr(0, 20)}, 
			{"text": "⚠  This map is PUBLISHED. Deleting it removes it", "id": "", "disabled": true}, 
			{"text": "    from THIS COMPUTER and from the ONLINE CATALOG —", "id": "", "disabled": true}, 
			{"text": "    nobody will be able to download it anymore.", "id": "", "disabled": true}, 
			{"text": "%d difficulty(ies) and its audio are erased. No undo." % n, "id": "", "disabled": true}, 
			{"sep": true}, 
			{"text": "Cancel", "id": ""}, 
			{"text": "DELETE LOCALLY AND ONLINE", "id": "yes", "accent": Color(1.0, 0.36, 0.36)}, 
		]
	elif downloaded:
		items = [
			{"title": "REMOVE \"%s\" ?" % main.track_title(track).substr(0, 24)}, 
			{"text": "Removes the downloaded map from this computer only.", "id": "", "disabled": true}, 
			{"text": "It stays online — you can download it again anytime.", "id": "", "disabled": true}, 
			{"sep": true}, 
			{"text": "Cancel", "id": ""}, 
			{"text": "Remove from my library", "id": "yes", "accent": Color(1.0, 0.36, 0.36)}, 
		]
	else:
		items = [
			{"title": "DELETE \"%s\" ?" % main.track_title(track).substr(0, 24)}, 
			{"text": "%d difficulty(ies) and its audio will be erased" % n, "id": "", "disabled": true}, 
			{"text": "from this computer. This cannot be undone.", "id": "", "disabled": true}, 
			{"sep": true}, 
			{"text": "Cancel", "id": ""}, 
			{"text": "Delete permanently", "id": "yes", "accent": Color(1.0, 0.36, 0.36)}, 
		]
	EdMenu.open(main.menu_root, items, vs * 0.5 - Vector2(150, 60), _f(), func(id: String):
		if id != "yes":
			return
		var title: String = main.track_title(track)
		if published and Backend.is_logged_in():



			Backend.api_maps_delete(online_id)
		MapLibrary.delete_map(track)
		main._scan_charts()


		if not MapLibrary.has(main.tuning.current_track):
			main.tuning.apply_track(String(MapLibrary.tracks().keys()[0]))
			main._load_chart()
		refresh_library()
		_list.refresh()
		refresh_all()
		main.sfx.play_ui("back")
		main._menu_toast("DELETED  ·  %s" % title.to_upper(), 
			Color(1.0, 0.36, 0.36)), 300)




func random_map() -> void :
	if _filtered.size() < 2:
		return
	main.sfx.play_ui("click")
	var pool: = _filtered.duplicate()
	pool.erase(main.tuning.current_track)
	for locked in main.LOCKED_TRACKS:
		pool.erase(locked)
	if pool.is_empty():
		return
	var target: = String(pool[randi() % pool.size()])
	for i in 3:
		select_map(String(pool[randi() % pool.size()]), false)
		await get_tree().create_timer(0.07).timeout
	select_map(target)







func select_map(track: String, with_preview: = true) -> void :
	if track == "" or not MapLibrary.has(track):
		return
	if track == main.tuning.current_track:
		refresh_all()
		return




	main.tuning.apply_track(track, 
		_diff_in_range(track) if _lvl_filtered() else "")







	_chart_pending = track
	_chart_wait = CHART_DEBOUNCE
	refresh_all()
	_list.refresh()
	var idx: = _filtered.find(track)
	if idx >= 0:
		_list.ensure_visible(idx)
	if with_preview:
		_preview_pending = track
		_preview_wait = PREVIEW_DEBOUNCE




func on_covers_ready() -> void :
	if not is_visible_in_tree():


		if _browser == null or not _browser.is_open():
			return
	if _list != null:
		_list.refresh()
	_refresh_center()

	if _browser != null and _browser.is_open() and _browser.has_method("on_covers_ready"):
		_browser.on_covers_ready()





func flush_chart() -> void :
	if _chart_pending == "":
		return
	_chart_pending = ""
	_chart_wait = 0.0
	main._load_chart()


	_refresh_center()




func select_difficulty(dkey: String) -> void :
	if dkey == main.tuning.current_diff:
		return
	main.sfx.play_ui("click")
	main.tuning.apply_track(main.tuning.current_track, dkey)
	_chart_pending = ""
	main._load_chart()
	refresh_all()


func refresh_all() -> void :







	_refresh_center()
	_refresh_difficulties()
	_heavy_pending = true
	_heavy_wait = HEAVY_DEBOUNCE
	if now_bar != null:
		now_bar.set_track(main.track_title(main.tuning.current_track), 
			main.track_artist(main.tuning.current_track))



func flush_heavy() -> void :
	if not _heavy_pending:
		return
	_heavy_pending = false
	_heavy_wait = 0.0



	_sync_rankings_from_catalog()
	_refresh_perf()
	_refresh_leaderboard()


func _refresh_center() -> void :
	var track: String = main.tuning.current_track
	var meta: = _meta_of(track, main.tuning.current_diff)
	var locked: bool = main._is_locked(track)
	var outdated: bool = MapLibrary.is_outdated(track)
	_play.disabled = locked
	_play.modulate = Color(1, 1, 1, 0.3) if locked else Color.WHITE


	_play_hint.text = "NOT AVAILABLE" if locked else "UPDATE AVAILABLE  ·  PRESS PLAY TO UPDATE"
	_play_hint.add_theme_color_override("font_color", 
		Color(1.0, 0.35, 0.4, 0.9) if locked else Color(1.0, 0.788, 0.29, 0.95))
	_play_hint.visible = locked or outdated
	_partner.visible = main.is_partner(track)
	cover_ring.accent = main._tier_for(main._density_level(meta))[1]
	cover_ring.set_cover(main.track_covers.tex(track), 
		main.track_title(track).substr(0, 1))








	for old in _center_tws:
		if old != null and old.is_valid():
			old.kill()
	_center_tws.clear()
	for pair in [[_title, _title_y], [_artist, _artist_y]]:
		var l: = pair[0] as Label
		var base_y: float = pair[1]
		l.modulate.a = 0.0
		l.position.y = base_y + 6.0
		var tw: Tween = l.create_tween()
		tw.tween_property(l, "modulate:a", 1.0, 0.18)
		tw.parallel().tween_property(l, "position:y", base_y, 0.24)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_center_tws.append(tw)
	_title.text = main.track_title(track)
	_fit_title()
	_artist.text = main.track_artist(track)


	if MapLibrary.is_user_map(track) and MapLibrary.is_shared(track):
		var rk: = MapLibrary.online_ranking_of(track)
		_artist.text += "   ·   %s" % (rk.to_upper() if rk != "" else "PENDING")

		if MapLibrary.online_wip_of(track):
			_artist.text += "   ·   WIP"


	_desc.text = main.track_desc(track)










const DIFF_BOX_PAD: = 18.0





const DIFF_SIDE_PAD: = 46.0
const DIFF_GROW: = 1.18
const DIFF_SIZES: = [56.0, 50.0, 44.0, 38.0, 32.0, 26.0]
const DIFF_MAX_ROWS: = 2

const DIFF_MULTIROW_MAX: = 44.0
const DIFF_SEP_V: = 4.0






func _diff_metrics(avail: float, n: int) -> Dictionary:
	var sep: = 22.0 if n <= 4 else 10.0
	var base: float = DIFF_SIZES[0]
	var rows: = 1
	var per_row: = maxi(n, 1)
	if n > 0 and avail > 60.0:



		var best_rows: = 99
		for cand in DIFF_SIZES:
			var pr: = maxi(int((avail - 4.0)
				/ (cand * DIFF_GROW + DIFF_BOX_PAD + sep)), 1)
			var r: = int(ceil(float(n) / float(pr)))


			if r > 1 and cand > DIFF_MULTIROW_MAX:
				continue
			if r < best_rows:
				best_rows = r
				base = cand
				per_row = pr
			if best_rows == 1:
				break
		rows = maxi(best_rows if best_rows < 99 else 1, 1)




		if rows > 1:
			var fits: int = maxi(int((avail - 4.0)
				/ (base * DIFF_GROW + DIFF_BOX_PAD + sep)), 1)
			per_row = mini(int(ceil(float(n) / float(mini(rows, DIFF_MAX_ROWS)))), 
				fits)
			rows = int(ceil(float(n) / float(per_row)))
	var item_w: = base * DIFF_GROW + DIFF_BOX_PAD + sep
	var item_h: = base * DIFF_GROW + 34.0
	var shown: = mini(rows, DIFF_MAX_ROWS)
	return {"base": base, "rows": rows, "item_h": item_h, "sep": sep, 
		"per_row": per_row, 



		"row_w": float(per_row) * item_w - sep, 


		"height": shown * item_h + (DIFF_SEP_V if shown > 1 else 0.0), 
		"full": rows * item_h + maxf(rows - 1, 0) * DIFF_SEP_V}


func _refresh_difficulties() -> void :
	for c in _diff_row.get_children():
		_diff_row.remove_child(c)
		c.queue_free()
	var track: String = main.tuning.current_track
	var diffs: Array = _visible_diffs(track)
	var m: = _diff_metrics(_diff_cw, diffs.size())
	var base: float = m.base
	var item_h: float = m.item_h
	_diff_row.add_theme_constant_override("h_separation", int(m.sep))
	_diff_row.add_theme_constant_override("v_separation", int(DIFF_SEP_V))
	for dkey in diffs:
		var d: = String(dkey)
		var dmeta: Dictionary = main._chart_meta_diff.get(track + "|" + d, {})
		var lvl: float = main._density_level(dmeta)
		var tier: Array = main._tier_for(lvl)


		var cap: = String(tier[0])
		if MapLibrary.is_user_map(track):


			cap = MapLibrary.diff_name(track, d).to_upper()
		_diff_row.add_child(_diff_button(d, lvl, tier, 
			d == String(main.tuning.current_diff), base, cap, item_h))




	if not is_equal_approx(float(m.height), _diff_h):
		_diff_h = float(m.height)
		_layout.call_deferred()
	_scroll_diff_into_view()






func _scroll_diff_into_view() -> void :
	if _diff_wrap == null or _diff_row == null:
		return
	var diffs: Array = _visible_diffs(main.tuning.current_track)
	var m: = _diff_metrics(_diff_cw, diffs.size())
	var i: = diffs.find(main.tuning.current_diff)
	if i < 0 or int(m.rows) <= DIFF_MAX_ROWS:
		_diff_row.position.y = 0.0
		return
	var row: = int(i / maxi(int(m.per_row), 1))
	var first: = clampi(row - (DIFF_MAX_ROWS - 1), 0, int(m.rows) - DIFF_MAX_ROWS)
	_diff_row.position.y = - float(first) * (float(m.item_h) + DIFF_SEP_V)





func _diff_button(dkey: String, lvl: float, tier: Array, selected: bool, 
		base: float, caption: = "", item_h: = 96.0, dimmed: = false) -> Control:
	var tcol: Color = tier[1]
	var d: = base * (DIFF_GROW if selected else 1.0)



	var box: = base * DIFF_GROW + DIFF_BOX_PAD
	var mid: = base * DIFF_GROW * 0.5 + 6.0
	var wrap: = Control.new()
	wrap.custom_minimum_size = Vector2(box, item_h)



	wrap.clip_contents = true
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(d, d)
	b.size = Vector2(d, d)
	b.position = Vector2((box - d) * 0.5, mid - d * 0.5)
	b.pivot_offset = Vector2(d * 0.5, d * 0.5)
	b.text = "%.1f" % lvl
	b.add_theme_font_size_override("font_size", int(d * 0.38))
	if _f() != null:
		b.add_theme_font_override("font", _f())
	b.add_theme_color_override("font_color", 
		main.neon(tcol, 1.2) if selected else Color(tcol, 0.85))
	b.add_theme_color_override("font_hover_color", main.neon(tcol, 1.3))



	var st: = StyleBoxFlat.new()
	st.bg_color = Color(tcol.r * 0.07, tcol.g * 0.06, tcol.b * 0.09, 0.88)
	st.set_corner_radius_all(int(d * 0.5))
	st.corner_detail = DETAIL
	st.anti_aliasing = true
	st.set_border_width_all(1)
	st.border_color = Color(tcol.r * 1.55, tcol.g * 1.45, tcol.b * 1.55, 1.0)\
	if selected else Color(tcol.r, tcol.g, tcol.b, 0.34)
	b.add_theme_stylebox_override("normal", st)
	var sth: StyleBoxFlat = st.duplicate()
	sth.bg_color = Color(tcol.r * 0.13, tcol.g * 0.1, tcol.b * 0.16, 0.92)
	sth.border_color = Color(tcol.r * 1.45, tcol.g * 1.3, tcol.b * 1.45, 1.0)
	b.add_theme_stylebox_override("hover", sth)
	b.add_theme_stylebox_override("pressed", sth)
	b.mouse_entered.connect( func() -> void :
		var tw: = b.create_tween()
		tw.tween_property(b, "scale", Vector2(1.08, 1.08), 0.12)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD))
	b.mouse_exited.connect( func() -> void :
		var tw: = b.create_tween()
		tw.tween_property(b, "scale", Vector2.ONE, 0.14)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD))
	b.pressed.connect(select_difficulty.bind(dkey))
	wrap.add_child(b)



	var fs: = 10 if base >= 38.0 else 9
	wrap.add_child(_diff_caption(caption if caption != "" else String(tier[0]), 
		box, mid + base * DIFF_GROW * 0.5 + 8.0, fs, 
		Color(tcol, 0.9) if selected else Color(1, 1, 1, 0.35)))
	if dimmed:
		wrap.modulate.a = 0.32
	return wrap



const CAP_SCROLL_SPEED: = 22.0
const CAP_SCROLL_HOLD: = 1.1






func _diff_caption(text: String, box: float, y: float, fs: int, 
		col: Color) -> Control:
	var avail: = box - 4.0
	var clip: = Control.new()
	clip.clip_contents = true
	clip.position = Vector2(2.0, y)
	clip.size = Vector2(avail, 14)
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cap: = Label.new()
	cap.text = text
	cap.autowrap_mode = TextServer.AUTOWRAP_OFF
	cap.add_theme_font_size_override("font_size", fs)
	var f: Font = _f()
	if f != null:
		cap.add_theme_font_override("font", f)
	else:
		f = ThemeDB.fallback_font
	cap.add_theme_color_override("font_color", col)
	cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(cap)


	var tw_x: float = f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, 
		-1, fs).x
	cap.size = Vector2(maxf(tw_x, 1.0), 14)
	if tw_x <= avail:
		cap.position = Vector2((avail - tw_x) * 0.5, 0.0)
		return clip
	cap.position = Vector2.ZERO
	var over: = tw_x - avail
	var tw: Tween = cap.create_tween().set_loops()
	tw.tween_interval(CAP_SCROLL_HOLD)
	tw.tween_property(cap, "position:x", - over, over / CAP_SCROLL_SPEED)\
	.set_trans(Tween.TRANS_LINEAR)
	tw.tween_interval(CAP_SCROLL_HOLD)
	tw.tween_callback( func() -> void : cap.position.x = 0.0)
	return clip




func _refresh_perf() -> void :
	var track: String = main.tuning.current_track
	var diff: String = main.tuning.current_diff
	var rec: = _best_record(track, diff)
	var has: bool = rec.has("score")


	_best_score.text = _thousands(int(rec.get("score", 0))) if has else "NO SCORE YET"
	_best_score.add_theme_font_size_override("font_size", 34 if has else 15)
	_best_score.add_theme_color_override("font_color", 
		Color(1, 1, 1, 0.95) if has else Color(1, 1, 1, 0.26))
	var g: = String(rec.get("grade", ""))
	_best_grade.text = g if g != "" else "—"
	_best_grade.add_theme_color_override("font_color", 
		main.GRADE_COLS.get(g, Color(1, 1, 1, 0.28)))
	if rec.has("acc"):
		_acc_value.text = "%.2f%%" % float(rec.get("acc", 0.0))
	else:
		_acc_value.text = "—"
	var notes: = int(_meta_of(track, diff).get("notes", 0))
	if rec.has("combo") and notes > 0:
		_clear_value.text = "%d / %d" % [int(rec.get("combo", 0)), notes]
	else:
		_clear_value.text = "— / %d" % notes
	var tier: Array = main._tier_for(main._density_level(_meta_of(track, diff)))



	_yours_line.text = "%s  ·  %s" % [diff.to_upper(), String(tier[0])]





func _refresh_leaderboard() -> void :
	_lb_token += 1
	var token: = _lb_token
	if _lb_cap != null:
		_lb_cap.text = "GLOBAL RANKING  ·  %s" % Mods.mode_name()
	var track: String = main.tuning.current_track
	var diff: String = main.tuning.current_diff
	for c in _lb_rows.get_children():
		c.queue_free()




	var server_id: = track
	if MapLibrary.is_user_map(track):
		if not MapLibrary.is_shared(track):
			_lb_note("local map — not published yet")
			return
		server_id = String(MapLibrary.meta_of(track).get("online_id", ""))
		var rk: = MapLibrary.online_ranking_of(track)
		if rk != "" and rk != "ranked":
			_lb_note("%s map — scores stay local until it is ranked" % rk)
			return
	_lb_note("loading…")
	var top: Dictionary = await Backend.map_top(server_id, diff, 5)
	if token != _lb_token or not is_inside_tree():
		return
	for c in _lb_rows.get_children():
		c.queue_free()
	if not top.get("ok", false):
		_lb_note("server unreachable", Color(1.0, 0.35, 0.4, 0.7))
		return
	var rows: Array = top.data if top.data is Array else []
	if rows.is_empty():
		_lb_note("no scores — be the first!")
		return
	for e in rows:
		var me: bool = Backend.is_logged_in()\
		and str(e.get("username", "")) == Backend.username
		_lb_rows.add_child(_lb_row(int(e.get("rank", 0)), 
			str(e.get("username", "?")), int(e.get("score", 0)), 
			float(e.get("accuracy", 0.0)), me, int(e.get("misses", -1))))


func _lb_note(text: String, col: = Color(1, 1, 1, 0.35)) -> void :
	var l: = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 11)
	l.add_theme_color_override("font_color", col)
	if _f() != null:
		l.add_theme_font_override("font", _f())
	_lb_rows.add_child(l)


func _lb_row(rank: int, uname: String, score_v: int, acc: float, 
		me: bool, misses: = -1) -> Control:
	var row: = PanelContainer.new()
	var st: = StyleBoxFlat.new()
	st.bg_color = Color(0.72, 0.45, 1.0, 0.16) if me else Color(0, 0, 0, 0)
	st.set_corner_radius_all(7)
	st.content_margin_left = 8
	st.content_margin_right = 8
	st.content_margin_top = 5
	st.content_margin_bottom = 5
	if me:
		st.border_color = Color(0.78, 0.52, 1.0, 0.55)
		st.set_border_width_all(1)
	row.add_theme_stylebox_override("panel", st)
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	row.add_child(h)
	var n: = Label.new()
	n.text = "%02d" % rank
	n.custom_minimum_size = Vector2(24, 0)
	n.add_theme_font_size_override("font_size", 11)
	n.add_theme_color_override("font_color", 
		Color(1.0, 0.82, 0.3) if rank <= 3 else Color(1, 1, 1, 0.35))
	if _f() != null:
		n.add_theme_font_override("font", _f())
	h.add_child(n)
	var u: = Label.new()
	u.text = uname
	u.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	u.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	u.add_theme_font_size_override("font_size", 12)
	u.add_theme_color_override("font_color", 
		Color(0.92, 0.82, 1.05) if me else Color(1, 1, 1, 0.72))
	h.add_child(u)
	var sc: = Label.new()


	sc.text = _thousands(score_v)
	sc.add_theme_font_size_override("font_size", 12)
	sc.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	if _f() != null:
		sc.add_theme_font_override("font", _f())
	h.add_child(sc)
	var gr: Array = main._grade_for(acc, misses)
	var g: = Label.new()
	g.text = String(gr[0])
	g.custom_minimum_size = Vector2(16, 0)
	g.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	g.add_theme_font_size_override("font_size", 12)
	g.add_theme_color_override("font_color", main.neon(gr[1], 1.1))
	if _f() != null:
		g.add_theme_font_override("font", _f())
	h.add_child(g)
	return row


static func _thousands(v: int) -> String:
	var s: = str(v)
	var out: = ""
	var c: = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return out




func launch() -> void :
	if _play.disabled:
		return
	var track: String = main.tuning.current_track



	if MapLibrary.is_outdated(track):
		var meta: = MapLibrary.meta_of(track)
		var oid: = String(meta.get("online_id", ""))
		if oid != "" and not _downloads.has(oid):
			main._screen_toast("UPDATING  ·  " + main.track_title(track).to_upper(), Color(1.0, 0.788, 0.29))
			start_download({"id": oid, "version": MapLibrary.online_latest_of(track), 
				"title": main.track_title(track), 
				"ranking": MapLibrary.online_ranking_of(track), 
				"wip": MapLibrary.online_wip_of(track)})
		return
	SettingsManager.push_recent(main.tuning.current_track)

	var tw: = _play.create_tween()
	tw.tween_property(_play, "scale", Vector2(0.93, 0.93), 0.06)\
	.set_ease(Tween.EASE_OUT)
	tw.tween_property(_play, "scale", Vector2(1.05, 1.05), 0.1)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	main._launch(main.tuning.current_track)


func focus_search() -> void :
	_search_edit.grab_focus()
	_search_edit.select_all()



func handle_key(event: InputEventKey) -> bool:


	if _browser != null and _browser.is_open():
		return _browser.handle_key(event)
	if _search_edit.has_focus():
		if event.physical_keycode == KEY_ESCAPE:
			_search_edit.release_focus()
			return true
		return false


	if event.is_action_pressed("nav_up"):
		_step(-1)
		return true
	if event.is_action_pressed("nav_down"):
		_step(1)
		return true
	if event.is_action_pressed("nav_left"):
		_step_diff(-1)
		return true
	if event.is_action_pressed("nav_right"):
		_step_diff(1)
		return true
	if event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER]:
		launch()
		return true
	if event.physical_keycode == KEY_F and event.ctrl_pressed:
		focus_search()
		return true
	return false


func _step(dir: int) -> void :
	if _filtered.is_empty():
		return
	var i: = _filtered.find(main.tuning.current_track)
	i = posmod(i + dir, _filtered.size()) if i >= 0 else 0
	main.sfx.play_ui("hover")
	select_map(String(_filtered[i]))


func _step_diff(dir: int) -> void :
	var diffs: Array = MapLibrary.diffs_of(main.tuning.current_track).keys()
	if diffs.size() < 2:
		return
	var i: = diffs.find(main.tuning.current_diff)
	select_difficulty(String(diffs[posmod(i + dir, diffs.size())]))




func on_beat(strength: float) -> void :
	if cover_ring != null:
		cover_ring.on_beat(strength)
	if now_bar != null:
		now_bar.on_beat(strength * 2.4)


func on_strong_beat(strength: float) -> void :
	if cover_ring != null:
		cover_ring.on_strong_beat(strength)


func _process(delta: float) -> void :



	if get_viewport_rect().size != _last_size:
		_layout()
	if not is_visible_in_tree():
		return
	if now_bar != null:
		now_bar.refresh()


	if _chart_pending != "":
		_chart_wait -= delta
		if _chart_wait <= 0.0:
			flush_chart()
	if _heavy_pending:
		_heavy_wait -= delta
		if _heavy_wait <= 0.0:
			flush_heavy()
	if _preview_pending != "":
		_preview_wait -= delta
		if _preview_wait <= 0.0:
			if _preview_pending == main.tuning.current_track:
				main._play_preview()
			_preview_pending = ""



func play_intro() -> void :
	for pair in [[_left, Vector2(-24, 0), 0.0], [_right, Vector2(24, 0), 0.05], 
			[center_zone, Vector2(0, 16), 0.02]]:
		var n: Control = pair[0]
		if n == null:
			continue
		var base: Vector2 = n.position
		n.position = base + (pair[1] as Vector2)
		n.modulate.a = 0.0
		var tw: Tween = n.create_tween()
		tw.tween_interval(float(pair[2]))
		tw.tween_property(n, "modulate:a", 1.0, 0.2)
		tw.parallel().tween_property(n, "position", base, 0.28)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
