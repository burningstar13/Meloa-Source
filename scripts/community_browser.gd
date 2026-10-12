class_name CommunityBrowser
extends Control
























signal play_requested(online_id: String)
signal closed

const EdMenu = preload("res://scripts/editor_ui/ed_menu.gd")


const BG: = Color(0.027, 0.027, 0.067)
const SURF: = Color(0.043, 0.035, 0.082)
const SURF2: = Color(0.071, 0.063, 0.125)
const CYAN: = Color(0.196, 0.902, 1.0)
const CYAN2: = Color(0.271, 0.812, 1.0)
const VIO: = Color(0.659, 0.333, 0.969)
const VIO_L: = Color(0.761, 0.4, 1.0)
const GREEN: = Color(0.259, 0.961, 0.655)
const AMBER: = Color(1.0, 0.788, 0.29)
const RED: = Color(1.0, 0.322, 0.404)
const ORANGE: = Color(1.0, 0.6, 0.25)
const TXT: = Color(0.969, 0.961, 0.988)
const TXT2: = Color(0.667, 0.647, 0.71)

const PAGE: = 50
const SEARCH_DEBOUNCE: = 0.18
const STATUS_OPTIONS: = ["All", "Ranked", "Reviewing", "Pending", "Unranked"]




const SORT_OPTIONS: = ["Popular", "Most Liked", "Most Downloaded", "Newest", "Name", "Difficulty"]
const PINK: = Color(1.0, 0.42, 0.72)
const ORDER_OPTIONS: = ["Ascending", "Descending"]

var main
var select


var _all: Array = []
var _shown: Array = []
var _by_id: = {}
var _state: = "idle"
var _error_msg: = ""
var _token: = 0
var _loading: = false
var _reports: = {}


var _search: = ""
var _search_wait: = -1.0
var _f_status: = "All"
var _f_diff: = "All"
var _f_sort: = "Popular"
var _f_order: = "Descending"

var _selected_id: = ""
var _mod_busy: = {}
var _mod_open_id: = ""


var _dim: ColorRect
var _panel: PanelContainer
var _count_lbl: Label
var _search_edit: LineEdit
var _dd: = {}
var _list_wrap: Control
var _list: VirtualList
var _skeleton: VBoxContainer
var _skel_tw: Tween
var _state_box: CenterContainer
var _state_title: Label
var _state_sub: Label
var _state_retry: Button
var _state_reset: Button
var _state_close: Button
var _loading_more: Label

var _details: PanelContainer
var _d_empty: Label
var _d_cover_frame: Panel
var _d_cover: TextureRect
var _d_initial: Label
var _d_badge_row: HBoxContainer
var _d_badge: Label
var _d_wip: Label
var _d_title: Label
var _d_artist: Label
var _d_mapper: Label
var _d_diffs_cap: Label
var _d_diffs: HFlowContainer
var _d_stats: HFlowContainer
var _d_desc: Label
var _d_action: Button
var _d_action_kind: = ""
var _d_installed: HBoxContainer
var _d_like: Button
var _like_busy: = {}
var _d_err: Label
var _d_report: Button
var _d_status: Label
var _d_body: Array = []

var _fonts: = {}
var _inter: Font
var _last_vs: = Vector2.ZERO
var _closing: = false


const PREVIEW_DIR: = "user://previews"
const PREVIEW_MAX_FILES: = 20
const PREVIEW_SECONDS: = 30.0
var _pv_player: AudioStreamPlayer
var _pv_id: = ""
var _pv_state: = "idle"
var _pv_token: = 0
var _pv_tw: Tween




func _ready() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	_inter = load("res://fonts/Inter-Variable.ttf")





	_dim = ColorRect.new()
	_dim.color = Color(BG.r, BG.g, BG.b, 0.78)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dim)

	_panel = PanelContainer.new()
	var pst: = StyleBoxFlat.new()
	pst.bg_color = Color(SURF.r, SURF.g, SURF.b, 0.985)
	pst.border_color = Color(VIO, 0.42)
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(20)
	pst.corner_detail = 16
	pst.anti_aliasing = true
	pst.shadow_color = Color(0, 0, 0, 0.55)
	pst.shadow_size = 28
	pst.shadow_offset = Vector2(0, 8)
	pst.content_margin_left = 22
	pst.content_margin_right = 22
	pst.content_margin_top = 18
	pst.content_margin_bottom = 20
	_panel.add_theme_stylebox_override("panel", pst)
	add_child(_panel)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_panel.add_child(v)

	_build_header(v)
	_build_toolbar(v)
	var body: = HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(body)
	_build_list(body)
	_build_details(body)
	_build_preview()
	get_viewport().size_changed.connect(_layout)



func _fi(weight: int, spacing: = 0) -> Font:
	var key: = "%d_%d" % [weight, spacing]
	if _fonts.has(key):
		return _fonts[key]
	var f: Font
	if _inter != null:
		f = main._font_var(_inter, {"wght": weight}, spacing)
	else:
		f = main.font_bold if weight >= 600 else main.font_body
	_fonts[key] = f
	return f


func _lbl(parent: Node, text: String, sz: int, col: Color, weight: = 400) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	l.add_theme_font_override("font", _fi(weight))
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


func _box(bg: Color, border: Color, radius: = 10, mh: = 12, mv: = 6) -> StyleBoxFlat:
	var st: = StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(1)
	st.set_corner_radius_all(radius)
	st.corner_detail = 12
	st.anti_aliasing = true
	st.content_margin_left = mh
	st.content_margin_right = mh
	st.content_margin_top = mv
	st.content_margin_bottom = mv
	return st




func _btn(text: String, sz: = 11, accent: = VIO_L, mh: = 14, mv: = 7, 
		radius: = 10) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", sz)
	b.add_theme_font_override("font", _fi(600))
	b.add_theme_stylebox_override("normal", 
		_box(Color(SURF2, 0.9), Color(accent, 0.28), radius, mh, mv))
	var h: = _box(Color(accent.r * 0.22, accent.g * 0.16, accent.b * 0.3, 0.95), 
		Color(accent, 0.85), radius, mh, mv)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_stylebox_override("disabled", 
		_box(Color(SURF2, 0.5), Color(1, 1, 1, 0.06), radius, mh, mv))
	b.add_theme_color_override("font_color", Color(TXT, 0.8))
	b.add_theme_color_override("font_hover_color", TXT)
	b.add_theme_color_override("font_pressed_color", TXT)
	b.add_theme_color_override("font_disabled_color", Color(TXT, 0.3))
	b.pressed.connect( func() -> void : main.sfx.play_ui("click"))
	return b




func _icon_btn(kind: String, tip: String, accent: = VIO_L, sz: = 38.0) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(sz, sz)
	b.tooltip_text = tip
	b.add_theme_stylebox_override("normal", 
		_box(Color(SURF2, 0.9), Color(accent, 0.28), 10, 0, 0))
	var h: = _box(Color(accent.r * 0.22, accent.g * 0.16, accent.b * 0.3, 0.95), 
		Color(accent, 0.9), 10, 0, 0)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	var ic: = UiIcon.new()
	ic.kind = kind
	ic.tint = Color(TXT, 0.8)
	ic.position = Vector2(sz * 0.5 - 9.0, sz * 0.5 - 9.0)
	ic.size = Vector2(18, 18)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(ic)
	b.mouse_entered.connect( func() -> void :
		ic.tint = TXT
		ic.queue_redraw())
	b.mouse_exited.connect( func() -> void :
		ic.tint = Color(TXT, 0.8)
		ic.queue_redraw())
	return b


func _build_header(v: VBoxContainer) -> void :
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 12)
	v.add_child(h)

	var chip: = Panel.new()
	chip.custom_minimum_size = Vector2(42, 42)
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	chip.add_theme_stylebox_override("panel", 
		_box(Color(CYAN, 0.1), Color(CYAN, 0.45), 12, 0, 0))
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(chip)
	var ic: = UiIcon.new()
	ic.kind = "globe"
	ic.tint = CYAN
	ic.position = Vector2(10, 10)
	ic.size = Vector2(22, 22)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(ic)
	var tcol: = VBoxContainer.new()
	tcol.add_theme_constant_override("separation", 1)
	tcol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tcol.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	h.add_child(tcol)
	var t: = _lbl(tcol, "BROWSE COMMUNITY MAPS", 18, TXT, 800)
	t.clip_text = true
	t.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var s: = _lbl(tcol, "Discover and download maps made by the community.", 12, TXT2, 400)
	s.clip_text = true
	s.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	_count_lbl = _lbl(h, "", 12, Color(CYAN2, 0.95), 600)
	_count_lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var refresh: = _icon_btn("refresh", "Refresh the catalog")
	refresh.pressed.connect( func() -> void :
		main.sfx.play_ui("click")
		_load())
	h.add_child(refresh)
	var close_b: = _icon_btn("close", "Close  (Esc)", VIO_L)
	close_b.pressed.connect( func() -> void :
		main.sfx.play_ui("back")
		close())
	h.add_child(close_b)


func _build_toolbar(v: VBoxContainer) -> void :
	var row: = HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	v.add_child(row)

	var swrap: = Control.new()
	swrap.custom_minimum_size = Vector2(250, 38)
	swrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(swrap)
	_search_edit = LineEdit.new()
	_search_edit.set_anchors_preset(Control.PRESET_FULL_RECT)
	_search_edit.placeholder_text = "Search by title, artist or mapper…"
	_search_edit.add_theme_font_size_override("font_size", 12)
	_search_edit.add_theme_font_override("font", _fi(400))
	var ss: = _box(Color(BG, 0.85), Color(VIO, 0.3), 19, 38, 8)
	_search_edit.add_theme_stylebox_override("normal", ss)
	_search_edit.add_theme_stylebox_override("focus", 
		_box(Color(BG, 0.95), Color(CYAN, 0.75), 19, 38, 8))
	_search_edit.add_theme_color_override("font_placeholder_color", Color(TXT2, 0.55))
	_search_edit.add_theme_color_override("font_color", TXT)
	_search_edit.add_theme_color_override("caret_color", CYAN)
	_search_edit.text_changed.connect( func(t: String) -> void :
		_search = t
		_search_wait = SEARCH_DEBOUNCE)
	swrap.add_child(_search_edit)
	var sic: = UiIcon.new()
	sic.kind = "search"
	sic.tint = Color(TXT2, 0.9)
	sic.position = Vector2(13, 11)
	sic.size = Vector2(16, 16)
	sic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	swrap.add_child(sic)

	_dd["status"] = _dropdown(row, "STATUS", STATUS_OPTIONS, 
		func() -> String: return _f_status, 
		func(o: String) -> void : _f_status = o)
	var diffs: Array = ["All"]
	for t in ChartRating.TIERS:
		diffs.append(String(t[1]).capitalize())
	_dd["diff"] = _dropdown(row, "DIFFICULTY", diffs, 
		func() -> String: return _f_diff, 
		func(o: String) -> void : _f_diff = o)
	_dd["sort"] = _dropdown(row, "SORT BY", SORT_OPTIONS, 
		func() -> String: return _f_sort, 
		func(o: String) -> void : _f_sort = o)
	_dd["order"] = _dropdown(row, "ORDER", ORDER_OPTIONS, 
		func() -> String: return _f_order, 
		func(o: String) -> void : _f_order = o)
	var reset: = _btn("RESET FILTERS", 11, Color(1, 1, 1, 0.55), 14, 9)
	reset.pressed.connect(_reset_filters)
	row.add_child(reset)





func _dropdown(parent: Node, label: String, options: Array, 
		getter: Callable, setter: Callable) -> Button:
	var b: = _btn("", 11, VIO_L, 12, 9)
	b.custom_minimum_size = Vector2(0, 38)
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.set_meta("dd_label", label)
	b.set_meta("dd_getter", getter)
	var st: StyleBoxFlat = b.get_theme_stylebox("normal")
	for name in ["normal", "hover", "pressed"]:
		var s: StyleBoxFlat = (b.get_theme_stylebox(name) as StyleBoxFlat).duplicate()
		s.content_margin_right = 30
		b.add_theme_stylebox_override(name, s)
	b.draw.connect( func() -> void :
		UiIcon.draw_kind(b, "chevron", Vector2(b.size.x - 16.0, b.size.y * 0.5), 
			12.0, Color(VIO_L, 0.9 if b.is_hovered() else 0.6), 1.6))
	b.pressed.connect( func() -> void :
		var cur: String = getter.call()
		var items: Array = [{"title": label}]
		for o in options:
			items.append({"text": String(o), "id": String(o), "check": String(o) == cur, 
				"accent": CYAN})
		var at: = b.get_global_rect().position + Vector2(0, b.size.y + 4.0)
		var m: Control = EdMenu.open(main.menu_root, items, at, _fi(500), 
			func(id: String) -> void :
				if id == "" or id == cur:
					return
				setter.call(id)
				_refresh_dropdown(b)
				_apply(), 170)
		_animate_menu(m))
	_refresh_dropdown(b)
	parent.add_child(b)
	return b


func _refresh_dropdown(b: Button) -> void :
	var getter: Callable = b.get_meta("dd_getter")
	b.text = "%s  ·  %s" % [String(b.get_meta("dd_label")), String(getter.call()).to_upper()]



func _animate_menu(m: Control) -> void :
	if m == null:
		return
	m.modulate.a = 0.0
	m.position.y = -6.0
	var tw: = m.create_tween()
	tw.tween_property(m, "modulate:a", 1.0, 0.1)
	tw.parallel().tween_property(m, "position:y", 0.0, 0.14)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func _build_list(body: HBoxContainer) -> void :
	_list_wrap = Control.new()
	_list_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list_wrap.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list_wrap.clip_contents = true
	body.add_child(_list_wrap)
	_list = VirtualList.new()
	_list.set_anchors_preset(Control.PRESET_FULL_RECT)
	_list.item_height = CommunityRow.H
	_list.make_item = func() -> Control:
		var r: = CommunityRow.new()
		r.f_semi = _fi(600)
		r.f_body = _fi(400)
		r.f_medium = _fi(500)
		r.pressed.connect( func() -> void :
			if _list.click_suppressed():
				return
			main.sfx.play_ui("click")
			_select(r.online_id))
		r.action_pressed.connect(_on_action)
		r.moderate_pressed.connect(_open_mod_menu)
		r.preview_pressed.connect(_toggle_preview)
		r.like_pressed.connect(_on_like)
		return r
	_list.bind_item = func(row: Control, i: int) -> void :
		(row as CommunityRow).bind(_row_data(_shown[i]))
	_list_wrap.add_child(_list)


	_skeleton = VBoxContainer.new()
	_skeleton.set_anchors_preset(Control.PRESET_FULL_RECT)
	_skeleton.add_theme_constant_override("separation", 0)
	_skeleton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_skeleton.visible = false
	_list_wrap.add_child(_skeleton)
	for i in 6:
		var card: = Control.new()
		card.custom_minimum_size = Vector2(0, CommunityRow.H)
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.draw.connect( func() -> void :
			var w: = card.size.x
			CommunityRow.draw_rounded_on(card, Rect2(2, 3, w - 4, CommunityRow.H - 6), 
				14.0, Color(SURF2, 0.75))
			CommunityRow.draw_rounded_on(card, Rect2(14, 13, 58, 58), 10.0, Color(1, 1, 1, 0.05))
			CommunityRow.draw_rounded_on(card, Rect2(86, 18, minf(w * 0.34, 260.0), 12), 6.0, Color(1, 1, 1, 0.07))
			CommunityRow.draw_rounded_on(card, Rect2(86, 38, minf(w * 0.24, 180.0), 10), 5.0, Color(1, 1, 1, 0.05))
			CommunityRow.draw_rounded_on(card, Rect2(86, 57, minf(w * 0.42, 320.0), 9), 5.0, Color(1, 1, 1, 0.04))
			CommunityRow.draw_rounded_on(card, Rect2(w - 130, 25, 116, 34), 10.0, Color(CYAN, 0.06)))
		_skeleton.add_child(card)


	_state_box = CenterContainer.new()
	_state_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_state_box.visible = false
	_list_wrap.add_child(_state_box)
	var sv: = VBoxContainer.new()
	sv.add_theme_constant_override("separation", 8)
	sv.alignment = BoxContainer.ALIGNMENT_CENTER
	_state_box.add_child(sv)
	_state_title = _lbl(sv, "", 16, TXT, 700)
	_state_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state_sub = _lbl(sv, "", 12, TXT2, 400)
	_state_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_state_sub.custom_minimum_size = Vector2(320, 0)
	var sb: = HBoxContainer.new()
	sb.add_theme_constant_override("separation", 8)
	sb.alignment = BoxContainer.ALIGNMENT_CENTER
	sv.add_child(sb)
	_state_retry = _btn("RETRY", 11, CYAN, 18, 9)
	_state_retry.pressed.connect(_load)
	sb.add_child(_state_retry)
	_state_reset = _btn("RESET FILTERS", 11, CYAN, 18, 9)
	_state_reset.pressed.connect(_reset_filters)
	sb.add_child(_state_reset)
	_state_close = _btn("CLOSE", 11, Color(1, 1, 1, 0.55), 18, 9)
	_state_close.pressed.connect(close)
	sb.add_child(_state_close)

	_loading_more = _lbl(_list_wrap, "loading more maps…", 10, Color(TXT2, 0.7), 500)
	_loading_more.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_loading_more.offset_top = -18
	_loading_more.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading_more.visible = false


func _build_details(body: HBoxContainer) -> void :
	_details = PanelContainer.new()
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_details.custom_minimum_size = Vector2(320, 0)
	var st: = _box(Color(SURF2, 0.8), Color(VIO, 0.22), 16, 18, 16)
	_details.add_theme_stylebox_override("panel", st)
	body.add_child(_details)
	var scroll: = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_details.add_child(scroll)


	var vsb: = scroll.get_v_scroll_bar()
	var track: = StyleBoxFlat.new()
	track.bg_color = Color(0, 0, 0, 0)
	track.content_margin_left = 3
	track.content_margin_right = 0
	vsb.add_theme_stylebox_override("scroll", track)
	for name in ["grabber", "grabber_highlight", "grabber_pressed"]:
		var g: = StyleBoxFlat.new()
		g.bg_color = Color(VIO, 0.35 if name == "grabber" else 0.6)
		g.set_corner_radius_all(2)
		vsb.add_theme_stylebox_override(name, g)
	vsb.custom_minimum_size = Vector2(4, 0)
	var dv: = VBoxContainer.new()
	dv.add_theme_constant_override("separation", 8)
	dv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(dv)

	_d_empty = _lbl(dv, "Select a map to see its details.", 12, TXT2, 400)
	_d_empty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_d_empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


	_d_cover_frame = Panel.new()
	_d_cover_frame.custom_minimum_size = Vector2(180, 180)
	_d_cover_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var cst: = StyleBoxFlat.new()
	cst.bg_color = Color(0.11, 0.08, 0.2, 1.0)
	cst.set_corner_radius_all(16)
	cst.corner_detail = 16
	cst.anti_aliasing = true
	cst.border_color = Color(VIO, 0.35)
	cst.set_border_width_all(1)
	_d_cover_frame.add_theme_stylebox_override("panel", cst)
	_d_cover_frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_d_cover_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dv.add_child(_d_cover_frame)
	_d_cover = TextureRect.new()
	_d_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_d_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_d_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_d_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_d_cover_frame.add_child(_d_cover)
	_d_initial = Label.new()
	_d_initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	_d_initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_d_initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_d_initial.add_theme_font_size_override("font_size", 56)
	_d_initial.add_theme_font_override("font", _fi(700))
	_d_initial.add_theme_color_override("font_color", Color(VIO_L, 0.45))
	_d_initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_d_cover_frame.add_child(_d_initial)


	_d_badge_row = HBoxContainer.new()
	_d_badge_row.add_theme_constant_override("separation", 8)
	dv.add_child(_d_badge_row)
	_d_badge = _lbl(_d_badge_row, "", 10, GREEN, 600)
	_d_badge.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_d_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	_d_wip = _lbl(_d_badge_row, "WIP", 10, ORANGE, 600)
	_d_wip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_d_wip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_d_wip.add_theme_stylebox_override("normal", 
		_box(Color(ORANGE, 0.12), Color(ORANGE, 0.55), 10, 9, 3))
	_d_wip.visible = false
	var bspacer: = Control.new()
	bspacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bspacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_d_badge_row.add_child(bspacer)
	_d_title = _lbl(dv, "", 20, TXT, 700)
	_d_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_d_title.max_lines_visible = 2
	_d_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_d_artist = _lbl(dv, "", 13, TXT2, 400)
	_d_artist.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_d_artist.max_lines_visible = 2
	_d_mapper = _lbl(dv, "", 12, VIO_L, 500)
	_d_mapper.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_d_diffs_cap = _lbl(dv, "DIFFICULTIES", 9, Color(TXT2, 0.85), 500)
	_d_diffs = HFlowContainer.new()
	_d_diffs.add_theme_constant_override("h_separation", 6)
	_d_diffs.add_theme_constant_override("v_separation", 6)
	dv.add_child(_d_diffs)
	_d_stats = HFlowContainer.new()
	_d_stats.add_theme_constant_override("h_separation", 8)
	_d_stats.add_theme_constant_override("v_separation", 8)
	dv.add_child(_d_stats)
	_d_desc = _lbl(dv, "", 12, TXT2, 400)
	_d_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


	_d_action = Button.new()
	_d_action.focus_mode = Control.FOCUS_NONE
	_d_action.custom_minimum_size = Vector2(0, 46)
	_d_action.add_theme_font_size_override("font_size", 13)
	_d_action.add_theme_font_override("font", _fi(700, 1))
	_d_action.pressed.connect( func() -> void : _on_action(_selected_id))
	_d_action.draw.connect( func() -> void :
		var c: = Vector2(_d_action.size.x * 0.5 - _d_action.get_theme_font("font")
			.get_string_size(_d_action.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x * 0.5 - 16.0, 
			_d_action.size.y * 0.5)
		if _d_action_kind == "download":
			UiIcon.draw_kind(_d_action, "download", c, 17.0, Color(0.02, 0.08, 0.1, 0.95), 1.9)
		elif _d_action_kind == "update":
			UiIcon.draw_kind(_d_action, "download", c, 17.0, AMBER, 1.9)
		elif _d_action_kind == "play":
			UiIcon.draw_kind(_d_action, "media_play", c + Vector2(1, 0), 15.0, TXT, 1.8))
	dv.add_child(_d_action)
	_d_err = _lbl(dv, "", 11, RED, 500)
	_d_err.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_d_err.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER




	var row2: = HBoxContainer.new()
	row2.add_theme_constant_override("separation", 8)
	dv.add_child(row2)
	_d_report = _btn("REPORT", 10, Color(1, 1, 1, 0.45), 12, 8)
	_d_report.tooltip_text = "Report this map to the moderators"
	_d_report.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_d_report.pressed.connect( func() -> void : _open_report_menu(_d_report))
	row2.add_child(_d_report)

	_d_like = _btn("♥ LIKE", 10, PINK, 12, 8)
	_d_like.tooltip_text = "Like this map"
	_d_like.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_d_like.pressed.connect( func() -> void : _on_like(_selected_id))
	row2.add_child(_d_like)
	var spacer: = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row2.add_child(spacer)
	_d_installed = HBoxContainer.new()
	_d_installed.add_theme_constant_override("separation", 5)
	_d_installed.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row2.add_child(_d_installed)
	var chk: = UiIcon.new()
	chk.kind = "check"
	chk.tint = GREEN
	chk.custom_minimum_size = Vector2(14, 14)
	chk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_d_installed.add_child(chk)
	_lbl(_d_installed, "INSTALLED", 11, GREEN, 600)
	_d_status = _lbl(dv, "", 11, TXT2, 400)
	_d_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_d_body = [_d_cover_frame, _d_badge_row, _d_title, _d_artist, _d_mapper, _d_diffs_cap, 
		_d_diffs, _d_stats, _d_desc, _d_action, _d_err, row2, _d_status]
	_show_details(false)




func _layout() -> void :
	var vs: = get_viewport_rect().size
	if vs.x < 100.0:
		return
	_last_vs = vs




	var pw: = minf(vs.x * 0.83, vs.x - 56.0)
	var ph: = minf(vs.y * 0.82, vs.y - 44.0)
	pw = maxf(pw, minf(720.0, vs.x - 40.0))
	ph = maxf(ph, minf(440.0, vs.y - 32.0))
	_panel.position = ((vs - Vector2(pw, ph)) * 0.5).floor()
	_panel.size = Vector2(pw, ph)
	_panel.pivot_offset = Vector2(pw, ph) * 0.5
	var dw: = clampf(pw * 0.34, 300.0, 400.0)
	_details.custom_minimum_size = Vector2(dw, 0)



	var body_h: = ph - 158.0
	var cs: = clampf(minf(dw - 40.0, body_h * 0.25), 96.0, 240.0)
	_d_cover_frame.custom_minimum_size = Vector2(cs, cs)




func is_open() -> bool:
	return visible and not _closing


func open() -> void :
	_closing = false
	visible = true
	_layout()
	modulate.a = 0.0
	_panel.scale = Vector2(0.965, 0.965)
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.14)
	tw.parallel().tween_property(_panel, "scale", Vector2.ONE, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	if _all.is_empty() or _state == "error":
		_load()
	else:
		_apply()


func close() -> void :
	if not visible or _closing:
		return
	_closing = true
	_stop_preview(true)
	EdMenu.close_all(main.menu_root)
	if _search_edit.has_focus():
		_search_edit.release_focus()
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_callback( func() -> void :
		if not _closing:
			return
		visible = false
		_closing = false
		closed.emit())





func on_escape() -> bool:
	if not get_tree().get_nodes_in_group("ed_menu").is_empty():
		EdMenu.close_all(main.menu_root)
		return true
	if _search_edit.has_focus():
		_search_edit.release_focus()
		return true
	close()
	return true





func handle_key(event: InputEventKey) -> bool:
	if _search_edit.has_focus():
		return false
	if event.is_action_pressed("nav_up"):
		_step(-1)
	elif event.is_action_pressed("nav_down"):
		_step(1)
	elif event.physical_keycode == KEY_F and event.ctrl_pressed:
		_search_edit.grab_focus()
		_search_edit.select_all()
	return true


func _step(dir: int) -> void :
	if _shown.is_empty():
		return
	var i: = _index_of(_selected_id)
	i = posmod(i + dir, _shown.size()) if i >= 0 else 0
	main.sfx.play_ui("hover")
	_select(String(_shown[i].id))


func _process(delta: float) -> void :
	if not visible:
		return
	if get_viewport_rect().size != _last_vs:
		_layout()
	if _search_wait > 0.0:
		_search_wait -= delta
		if _search_wait <= 0.0:
			_search_wait = -1.0
			_apply()













func _load(quiet: = false) -> void :
	_token += 1
	var token: = _token
	var fresh: Array = []
	var fresh_by: = {}
	if not quiet:
		_all = fresh
		_by_id = fresh_by
		_state = "loading"
		_error_msg = ""
	_loading = true
	_apply()
	if Backend.is_mod():
		_load_reports(token)
	var cursor: = ""
	var status: = "ready"
	var err: = ""
	while true:
		var r: Dictionary = await MapCatalog.search("", cursor, PAGE)
		if token != _token or not is_inside_tree():
			return
		if r.status == "ok":
			for m in r.maps:
				var id: = String(m.get("id", ""))
				if id == "" or fresh_by.has(id):
					continue
				fresh.append(m)
				fresh_by[id] = m


				var installed: = MapLibrary.find_online(id)
				if installed != "":
					MapLibrary.set_online_ranking(installed, String(m.get("ranking", "pending")))
					MapLibrary.set_online_wip(installed, bool(m.get("wip", false)))
					MapLibrary.set_online_latest(installed, int(m.get("version", 1)))
					MapLibrary.set_online_meloved(installed, bool(m.get("meloved", false)))
			cursor = String(r.next_cursor)
			if not quiet:
				_state = "ready"
				_apply()
			if cursor == "":
				break
		elif r.status == "empty":
			if fresh.is_empty():
				status = "empty"
			break
		else:


			if fresh.is_empty():
				status = "error"
				err = String(r.message)
			break
	_loading = false
	if quiet and status == "error":

		_d_status.text = "could not refresh the catalog — " + err
		_d_status.add_theme_color_override("font_color", RED)
	else:
		_all = fresh
		_by_id = fresh_by
		_state = status
		_error_msg = err
	_apply()




func _load_reports(token: int) -> void :
	var r: Dictionary = await Backend.api_admin_reports()
	if token != _token or not is_inside_tree():
		return
	_reports.clear()
	if r.ok and r.data is Array:
		for rep in r.data:
			if not (rep is Dictionary):
				continue
			var map: Dictionary = rep.get("map", {}) if rep.get("map") is Dictionary else {}
			var mid: = str(map.get("id", rep.get("mapId", "")))
			if mid == "" or mid == "<null>":
				continue
			if not _reports.has(mid):
				_reports[mid] = []
			_reports[mid].append(rep)
	_list.refresh()




func _matches(m: Dictionary, q: String) -> bool:
	if q != "":
		var hay: = ("%s %s %s" % [String(m.title), String(m.artist), String(m.mapper)]).to_lower()
		if not hay.contains(q):
			return false
	if _f_status != "All" and String(m.ranking) != _f_status.to_lower():
		return false
	if _f_diff != "All":

		var want: = _f_diff.to_upper()
		var hit: = false
		for dd in _diffs_of(m, _track_of(m)):
			if String(ChartRating.tier_for(float(dd[1]))[0]) == want:
				hit = true
				break
		if not hit:
			return false
	return true






func _diffs_of(m: Dictionary, track: String) -> Array:
	var out: Array = []
	if track != "":
		for dkey in MapLibrary.diffs_of(track):
			var d: = String(dkey)




			var lvl: = 0.0
			if main != null:
				lvl = float(main._density_level(
					main._chart_meta_diff.get(track + "|" + d, {})))
			if lvl <= 0.0:
				lvl = MapLibrary.diff_rated(track, d)
			out.append([MapLibrary.diff_name(track, d).to_upper().substr(0, 14), lvl, 
				ChartRating.tier_for(lvl)[1]])
	elif not (m.get("difficulties", []) as Array).is_empty():
		for dd in m.difficulties:
			var lvl: = float(dd.level)
			out.append([String(dd.key).to_upper().substr(0, 14), lvl, ChartRating.tier_for(lvl)[1]])
	else:
		var lvl: = float(m.level)
		var tier: Array = ChartRating.tier_for(lvl)
		out.append([String(tier[0]), lvl, tier[1]])
	out.sort_custom( func(a, b): return a[1] < b[1])
	return out


func _sort_key(m: Dictionary) -> Variant:
	match _f_sort:
		"Popular":
			var d0: = String(m.get("published_at", ""))
			return [1 if String(m.get("ranking", "")) == "ranked" else 0, 
				1 if bool(m.get("meloved", false)) else 0, 
				int(m.get("likes", 0)), 
				d0 if d0 != "" else String(m.get("created_at", ""))]
		"Most Liked":
			return int(m.get("likes", 0))
		"Most Downloaded":
			return int(m.downloads)
		"Newest":
			var d: = String(m.get("published_at", ""))
			return d if d != "" else String(m.get("created_at", ""))
		"Name":
			return String(m.title).to_lower()
	return float(m.level)





func _apply() -> void :
	var prev_idx: = _index_of(_selected_id)
	var q: = _search.strip_edges().to_lower()
	var out: Array = []
	for m in _all:
		if _matches(m, q):
			out.append(m)
	var desc: = _f_order == "Descending"
	out.sort_custom( func(a, b) -> bool:
		var ka = _sort_key(a)
		var kb = _sort_key(b)
		if ka == kb:
			return String(a.title).to_lower() < String(b.title).to_lower()
		return ka > kb if desc else ka < kb)
	_shown = out
	_list.set_count(_shown.size())
	_list.refresh()
	if _state == "loading" and _all.is_empty():
		_count_lbl.text = "LOADING…"
	else:
		_count_lbl.text = "%d MAP%s" % [_shown.size(), "" if _shown.size() == 1 else "S"]


	if _index_of(_selected_id) < 0:
		if _shown.is_empty():
			_selected_id = ""
		else:
			_selected_id = String(_shown[clampi(prev_idx, 0, _shown.size() - 1)].id)
			_list.refresh()
	_refresh_details()


	var filtered: = q != "" or _f_status != "All" or _f_diff != "All"
	var loading_first: = _state == "loading" and _all.is_empty()
	_skeleton.visible = loading_first
	_set_skeleton_anim(loading_first)
	_loading_more.visible = _loading and not _all.is_empty()
	_state_box.visible = false
	_state_retry.visible = false
	_state_reset.visible = false
	_state_close.visible = false
	if _state == "error":
		_state_box.visible = true
		_state_title.text = "COULDN’T LOAD COMMUNITY MAPS"
		_state_sub.text = _error_msg
		_state_retry.visible = true
		_state_close.visible = true
	elif _state == "empty" or (_state == "ready" and _all.is_empty() and not _loading):
		_state_box.visible = true
		_state_title.text = "NO COMMUNITY MAPS AVAILABLE"
		_state_sub.text = "Nobody has published a map yet — be the first, from the editor."
		_state_close.visible = true
	elif _state == "ready" and _shown.is_empty() and filtered:
		_state_box.visible = true
		_state_title.text = "NO MAPS FOUND"
		_state_sub.text = "Try changing your search or filters."
		_state_reset.visible = true
	_list.visible = not _state_box.visible and not loading_first


func _set_skeleton_anim(on: bool) -> void :
	if _skel_tw != null and _skel_tw.is_valid():
		_skel_tw.kill()
		_skel_tw = null
	if not on:
		return
	_skeleton.modulate.a = 0.55
	_skel_tw = _skeleton.create_tween().set_loops()
	_skel_tw.tween_property(_skeleton, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	_skel_tw.tween_property(_skeleton, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)


func _reset_filters() -> void :
	_search = ""
	_search_edit.text = ""
	_search_wait = -1.0
	_f_status = "All"
	_f_diff = "All"
	_f_sort = "Popular"
	_f_order = "Descending"
	for key in _dd:
		_refresh_dropdown(_dd[key])
	_apply()


func _index_of(id: String) -> int:
	if id == "":
		return -1
	for i in _shown.size():
		if String(_shown[i].id) == id:
			return i
	return -1




func _select(id: String) -> void :
	if id == "" or id == _selected_id:
		return
	_selected_id = id
	if _pv_id != "" and _pv_id != id:
		_stop_preview(true)
	_list.refresh()
	var i: = _index_of(id)
	if i >= 0:
		_list.ensure_visible(i)
	_d_status.text = ""
	_refresh_details()



func _track_of(m: Dictionary) -> String:
	return MapLibrary.find_online(String(m.get("id", "")))


func _is_installed(m: Dictionary, track: String) -> bool:
	return track != "" and MapLibrary.online_version_of(track) >= int(m.get("version", 1))



func _action_state(m: Dictionary, installed: bool) -> Array:
	var id: = String(m.get("id", ""))
	if String(m.get("status", "published")) != "published":
		return ["off", "VALIDATING", "still being checked by the server"]
	var dl: Dictionary = select.download_state(id)
	if dl.has("label"):
		return ["busy", String(dl.label), "download in progress"]
	if installed:
		return ["play", "PLAY", "Open this map in your library"]
	if dl.has("error"):
		return ["retry", "RETRY", String(dl.error)]


	if _track_of(m) != "":
		return ["update", "UPDATE", "A newer version is online — update your copy to play it"]
	return ["download", "DOWNLOAD", "Install this map into your library"]


static func _fmt_size(bytes: int) -> String:
	if bytes <= 0:
		return ""
	if bytes < 1048576:
		return "%d KB" % maxi(int(bytes / 1024.0), 1)
	return "%.1f MB" % (bytes / 1048576.0)


static func _fmt_dur(sec: float) -> String:
	if sec <= 0.0:
		return ""
	var s: = int(round(sec))
	return "%d:%02d" % [s / 60, s % 60]


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




func _duration_of(track: String) -> String:
	if track == "":
		return ""
	return _fmt_dur(float(main._chart_meta.get(track, {}).get("dur", 0.0)))


func _row_data(m: Dictionary) -> Dictionary:
	var id: = String(m.get("id", ""))
	var track: = _track_of(m)
	var installed: = _is_installed(m, track)
	var act: = _action_state(m, installed)
	var parts: Array = []
	var dur: = _duration_of(track)
	if dur != "":
		parts.append(dur)
	var sz: = _fmt_size(int(m.size_bytes))
	if sz != "":
		parts.append(sz)
	var dl: = int(m.downloads)
	parts.append("%s download%s" % [_thousands(dl), "" if dl == 1 else "s"])
	var mapper: = String(m.mapper)
	var sub: = String(m.artist)
	if mapper != "":
		sub += "   ·   mapped by %s" % mapper
	return {
		"id": id, 
		"title": String(m.title), 
		"sub": sub, 
		"diffs": _diffs_of(m, track), 
		"meta": "  ·  ".join(parts), 
		"ranking": String(m.get("ranking", "pending")), 
		"wip": bool(m.get("wip", false)), 
		"likes": int(m.get("likes", 0)), 
		"liked": bool(m.get("liked", false)), 
		"meloved": bool(m.get("meloved", false)), 
		"selected": id == _selected_id, 
		"cover": main.track_covers.tex(track) if track != "" else null, 
		"action_kind": act[0], 
		"action_label": act[1], 
		"action_tip": act[2], 

		"admin": Backend.is_reviewer(), 
		"reports": (_reports.get(id, []) as Array).size(), 
		"mod_open": id == _mod_open_id, 
		"mod_busy": _mod_busy.has(id), 
		"preview": _pv_state if id == _pv_id else "idle", 
		"preview_ok": installed or String(m.get("status", "published")) == "published", 
	}


func _show_details(on: bool) -> void :
	_d_empty.visible = not on
	for n in _d_body:
		(n as Control).visible = on


func _refresh_details() -> void :
	var m: Dictionary = _by_id.get(_selected_id, {})
	if m.is_empty():
		_show_details(false)
		return
	_show_details(true)
	var track: = _track_of(m)
	var installed: = _is_installed(m, track)
	var cover: Texture2D = main.track_covers.tex(track) if track != "" else null
	_d_cover.texture = cover
	_d_cover.visible = cover != null
	_d_initial.visible = cover == null
	_d_initial.text = String(m.title).substr(0, 1).to_upper()

	var rk: = String(m.get("ranking", "pending"))
	var rc: = CommunityRow.ranking_color(rk)
	_d_badge.text = rk.to_upper()
	_d_badge.add_theme_color_override("font_color", rc)
	_d_badge.add_theme_stylebox_override("normal", _box(Color(rc, 0.14), Color(rc, 0.65), 10, 9, 3))

	_d_wip.visible = bool(m.get("wip", false))
	_d_title.text = String(m.title)
	_d_artist.text = String(m.artist)
	var mapper: = String(m.mapper)
	_d_mapper.visible = mapper != ""
	_d_mapper.text = "mapped by %s" % mapper


	for c in _d_stats.get_children():
		_d_stats.remove_child(c)
		c.queue_free()
	for c in _d_diffs.get_children():
		_d_diffs.remove_child(c)
		c.queue_free()
	var diffs: = _diffs_of(m, track)
	_d_diffs_cap.text = "DIFFICULT%s" % ("Y" if diffs.size() == 1 else "IES")
	for dd in diffs:
		var dc: Color = dd[2]
		var pill: = _lbl(_d_diffs, "%s  %.1f" % [String(dd[0]), float(dd[1])], 11, dc, 600)
		pill.add_theme_stylebox_override("normal", _box(Color(dc, 0.12), Color(dc, 0.6), 10, 9, 3))
	var dur: = _duration_of(track)
	if dur != "":
		_stat("DURATION", dur)
	var sz: = _fmt_size(int(m.size_bytes))
	if sz != "":
		_stat("SIZE", sz)
	_stat("DOWNLOADS", _thousands(int(m.downloads)))
	_stat("LIKES", _thousands(int(m.get("likes", 0))), PINK if bool(m.get("meloved", false)) else TXT)
	if _d_like != null:
		var lk: = bool(m.get("liked", false))
		_d_like.text = ("♥ LIKED  ·  %d" if lk else "♥ LIKE  ·  %d") % int(m.get("likes", 0))
		_d_like.tooltip_text = "Unlike" if lk else "Like this map"
		_d_like.disabled = _like_busy.has(String(m.id)) or not Backend.is_logged_in()


	_d_desc.visible = false
	_d_desc.text = ""

	var act: = _action_state(m, installed)
	var kind: = String(act[0])
	if kind != _d_action_kind:
		var was: = _d_action_kind
		_style_big_action(kind)
		if was != "" and kind == "play" and is_visible_in_tree():
			_d_action.pivot_offset = _d_action.size * 0.5
			var tw: = _d_action.create_tween()
			tw.tween_property(_d_action, "scale", Vector2(1.04, 1.04), 0.1)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tw.tween_property(_d_action, "scale", Vector2.ONE, 0.16)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_d_action.text = String(act[1])
	_d_action.tooltip_text = String(act[2])
	_d_action.disabled = kind in ["busy", "off"]
	_d_installed.visible = installed
	var dl: Dictionary = select.download_state(String(m.id))
	_d_err.visible = dl.has("error")
	_d_err.text = String(dl.get("error", ""))
	_d_action.queue_redraw()



func _stat(cap: String, value: String, col: = TXT) -> void :
	var box: = PanelContainer.new()
	box.add_theme_stylebox_override("panel", _box(Color(SURF, 0.85), Color(1, 1, 1, 0.06), 9, 9, 4))
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 1)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(v)
	_lbl(v, cap, 9, Color(TXT2, 0.85), 500)
	_lbl(v, value, 13, col, 600)
	_d_stats.add_child(box)


func _style_big_action(kind: String) -> void :
	_d_action_kind = kind
	var bg: Color
	var border: Color
	var bg_h: Color
	var border_h: Color
	var txt: Color
	match kind:
		"play":
			bg = Color(VIO.r * 0.42, VIO.g * 0.26, VIO.b * 0.55, 0.96)
			border = Color(VIO_L, 0.95)
			bg_h = Color(VIO.r * 0.58, VIO.g * 0.38, VIO.b * 0.72, 0.98)
			border_h = Color(CYAN, 1.0)
			txt = TXT
		"retry":
			bg = Color(RED, 0.12)
			border = Color(RED, 0.7)
			bg_h = Color(RED, 0.24)
			border_h = RED
			txt = RED
		"update":
			bg = Color(AMBER, 0.14)
			border = Color(AMBER, 0.75)
			bg_h = Color(AMBER, 0.26)
			border_h = AMBER
			txt = AMBER
		"busy":
			bg = Color(CYAN, 0.06)
			border = Color(CYAN, 0.3)
			bg_h = bg
			border_h = border
			txt = Color(CYAN, 0.85)
		"off":
			bg = Color(1, 1, 1, 0.03)
			border = Color(1, 1, 1, 0.1)
			bg_h = bg
			border_h = border
			txt = Color(1, 1, 1, 0.38)
		_:

			bg = Color(CYAN, 0.92)
			border = Color(CYAN, 1.0)
			bg_h = Color(0.42, 0.94, 1.0, 1.0)
			border_h = Color(0.75, 0.97, 1.0, 1.0)
			txt = Color(0.02, 0.08, 0.1)
	_d_action.add_theme_stylebox_override("normal", _box(bg, border, 12, 24, 10))
	_d_action.add_theme_stylebox_override("hover", _box(bg_h, border_h, 12, 24, 10))
	_d_action.add_theme_stylebox_override("pressed", _box(bg_h, border_h, 12, 24, 10))
	_d_action.add_theme_stylebox_override("disabled", _box(bg, border, 12, 24, 10))
	for n in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color"]:
		_d_action.add_theme_color_override(n, txt)







func _on_action(id: String) -> void :
	var m: Dictionary = _by_id.get(id, {})
	if m.is_empty():
		return
	var track: = _track_of(m)
	var act: = _action_state(m, _is_installed(m, track))
	match String(act[0]):
		"download", "retry", "update":
			main.sfx.play_ui("click")
			select.start_download(m)
			_on_download_changed(id)
		"play":
			main.sfx.play_ui("menu_play")


			_stop_preview(false)
			play_requested.emit(id)






func _on_like(id: String) -> void :
	var m: Dictionary = _by_id.get(id, {})
	if m.is_empty() or _like_busy.has(id):
		return
	if not Backend.is_logged_in():
		main._screen_toast("SIGN IN TO LIKE MAPS", AMBER)
		return
	var want: bool = not bool(m.get("liked", false))
	var before_likes: = int(m.get("likes", 0))
	m["liked"] = want
	m["likes"] = maxi(before_likes + (1 if want else -1), 0)
	_like_busy[id] = true
	_list.refresh()
	if id == _selected_id:
		_refresh_details()
	main.sfx.play_ui("click")
	var r: Dictionary = await Backend.api_map_like(id, want)
	_like_busy.erase(id)
	if not is_inside_tree():
		return
	if r.ok and r.data is Dictionary:
		m["liked"] = bool(r.data.get("liked", want))
		m["likes"] = int(r.data.get("likesCount", m["likes"]))
		m["meloved"] = bool(r.data.get("meloved", m.get("meloved", false)))
		var installed: = MapLibrary.find_online(id)
		if installed != "":
			MapLibrary.set_online_meloved(installed, bool(m["meloved"]))
	else:
		m["liked"] = not want
		m["likes"] = before_likes
		main._screen_toast("COULD NOT SAVE YOUR LIKE — " + MapPublisher.server_error(r, "server unreachable"), RED)
	_list.refresh()
	if id == _selected_id:
		_refresh_details()



func on_download_changed(id: String) -> void :
	_on_download_changed(id)


func _on_download_changed(id: String) -> void :
	if not visible:
		return
	var i: = _index_of(id)
	var row: Control = _list.row_for(i) if i >= 0 else null
	var was_kind: = (row as CommunityRow).action_kind if row != null else ""
	_list.refresh()
	if row != null and is_instance_valid(row):
		var now_kind: = (row as CommunityRow).action_kind
		if was_kind != now_kind and now_kind == "play":
			(row as CommunityRow).animate_action_change()
	if id == _selected_id:
		_refresh_details()







func _open_report_menu(anchor: Control) -> void :
	var m: Dictionary = _by_id.get(_selected_id, {})
	if m.is_empty():
		return
	var items: Array = [{"title": "REPORT THIS MAP"}]
	for it in [["copyright / stolen song", "COPYRIGHT"], 
			["inappropriate content", "INAPPROPRIATE"], 
			["broken map", "BROKEN"], ["something else", "OTHER"]]:
		items.append({"text": it[0], "id": it[1], "accent": AMBER})
	items.append({"sep": true})
	items.append({"text": "Cancel", "id": ""})
	var at: = anchor.get_global_rect().position + Vector2(0, anchor.size.y + 4.0)
	var menu: Control = EdMenu.open(main.menu_root, items, at, _fi(500), func(id: String) -> void :
		if id == "":
			return
		_d_status.text = "sending report…"
		_d_status.add_theme_color_override("font_color", TXT2)
		var r: Dictionary = await Backend.api_maps_report(String(m.id), id)
		if not is_inside_tree():
			return
		if r.ok:
			_d_status.text = "report sent — thanks, a moderator will look at it"
			_d_status.add_theme_color_override("font_color", GREEN)
		else:

			_d_status.text = MapPublisher.server_error(r, "report failed")
			_d_status.add_theme_color_override("font_color", RED), 200)
	_animate_menu(menu)











func _send_label(wip: bool, rk: String) -> String:
	if wip:
		return "WIP — NO NEED TO BE RANKED"
	match rk:
		"reviewing":
			return "ALREADY IN DISCORD REVIEW"
		"unranked":
			return "UNRANKED — NEEDS A NEW VERSION"
	return "SEND TO DISCORD REVIEW"

func _open_mod_menu(id: String, at: Vector2) -> void :
	var m: Dictionary = _by_id.get(id, {})
	if m.is_empty() or not Backend.is_reviewer():
		return
	if _mod_busy.has(id):
		return
	main.sfx.play_ui("click")
	_select(id)
	var rk: = String(m.get("ranking", "pending"))
	var is_mod: = Backend.is_mod()


	var wip: = bool(m.get("wip", false))



	var items: Array = [
		{"title": "MODERATE MAP" if is_mod else "REVIEW MAP"}, 
		{"text": "%s  ·  now %s" % [String(m.title).substr(0, 26), rk.to_upper()], 
			"id": "", "disabled": true}, 
		{"sep": true}, 
		{"text": _send_label(wip, rk), "id": "review", "accent": VIO_L, 
			"disabled": wip or rk == "ranked" or rk == "reviewing" or rk == "unranked"}, 
	]
	for reason in TRIAGE_UNRANKED_REASONS:
		items.append({"text": "SET UNRANKED — " + reason[0], "id": "unranked:" + reason[0], 
			"accent": AMBER, "disabled": rk == "unranked"})
	for reason in TRIAGE_REMOVE_REASONS:
		items.append({"text": "REMOVE — " + reason[0], "id": "cancel:" + reason[0], "accent": RED})
	if is_mod:
		items.append_array([
			{"sep": true}, 
			{"text": "VALIDATE AS RANKED", "id": "rank:RANKED", "accent": GREEN, 
				"disabled": rk == "ranked"}, 
			{"text": "SET AS UNRANKED", "id": "rank:UNRANKED", "accent": AMBER, 
				"disabled": rk == "unranked"}, 
			{"text": "RETURN TO PENDING", "id": "rank:PENDING", "accent": AMBER, 
				"disabled": rk == "pending"}, 
			{"sep": true}, 
		])
	var reps: Array = _reports.get(id, [])
	if is_mod and not reps.is_empty():
		items.append({"sep": true})
		items.append({"text": "DISMISS %d OPEN REPORT%s — unfounded" % [reps.size(), 
			"" if reps.size() == 1 else "S"], "id": "dismiss", "accent": VIO_L})
	items.append({"sep": true})
	items.append({"text": "CANCEL", "id": "", "accent": Color(1, 1, 1, 0.55)})
	_mod_open_id = id
	_list.refresh()
	var menu: Control = EdMenu.open(main.menu_root, items, at, _fi(500), func(pick: String) -> void :
		if pick == "review":
			_mod_triage(id, "SEND", "")
		elif pick.begins_with("unranked:"):
			_mod_triage(id, "UNRANKED", _triage_reason_text(TRIAGE_UNRANKED_REASONS, pick.trim_prefix("unranked:")))
		elif pick.begins_with("cancel:"):
			_mod_confirm_remove(id, pick.trim_prefix("cancel:"), at)
		elif pick.begins_with("rank:"):
			_mod_set_ranking(id, pick.trim_prefix("rank:"))
		elif pick.begins_with("remove:"):
			_mod_confirm_remove(id, pick.trim_prefix("remove:"), at)
		elif pick == "dismiss":
			_mod_dismiss_reports(id), 230)
	_animate_menu(menu)


	menu.tree_exiting.connect( func() -> void :
		if _mod_open_id == id:
			_mod_open_id = ""
			if is_inside_tree():
				_list.refresh())




const TRIAGE_UNRANKED_REASONS: = [
	["OFF-SYNC", "The map is not in sync with the music. Re-time it and upload a new version."], 
	["UNPLAYABLE", "Some sections are impossible or broken. Fix them and upload a new version."], 
	["TOO ROUGH", "The map is not ready for ranking yet (readability, flow, density). Polish it and upload a new version."], 
	["WRONG DIFFICULTY", "The difficulty does not match its label. Adjust it and upload a new version."], 
	["OTHER", "The map was refused by a reviewer. Upload a new version to request ranking again."], 
]
const TRIAGE_REMOVE_REASONS: = [
	["COPYRIGHT", "Removed: copyright issue."], 
	["INAPPROPRIATE", "Removed: inappropriate or malicious content."], 
	["BROKEN", "Removed: the map file is broken."], 
	["OTHER", "Removed by a reviewer."], 
]


func _triage_reason_text(table: Array, key: String) -> String:
	for entry in table:
		if entry[0] == key:
			return entry[1]
	return key





func _mod_triage(id: String, decision: String, reason: String) -> void :
	if _mod_busy.has(id):
		return
	_mod_busy[id] = true
	_list.refresh()
	_d_status.text = "sending to review…" if decision == "SEND" else "updating…"
	_d_status.add_theme_color_override("font_color", TXT2)
	var r: Dictionary = await Backend.api_admin_triage(id, decision, reason)
	_mod_busy.erase(id)
	if not is_inside_tree():
		return
	if r.ok:
		main.sfx.play_ui("impact")
		if decision == "SEND":
			main._screen_toast("SENT TO DISCORD REVIEW", main.COL_GOLD)

			if _by_id.has(id):
				_by_id[id]["ranking"] = "reviewing"
			var sent_installed: = MapLibrary.find_online(id)
			if sent_installed != "":
				MapLibrary.set_online_ranking(sent_installed, "REVIEWING")
			_apply()
		else:
			main._screen_toast("MAP SET UNRANKED  ·  the mapper will be notified", AMBER)
			if _by_id.has(id):
				_by_id[id]["ranking"] = "unranked"
			var installed: = MapLibrary.find_online(id)
			if installed != "":
				MapLibrary.set_online_ranking(installed, "UNRANKED")
			_apply()
		_d_status.text = ""
		_list.refresh()
	else:
		main.sfx.play_ui("back")


		_d_status.text = MapPublisher.server_error(r, "review action failed")
		_d_status.add_theme_color_override("font_color", RED)
		_list.refresh()


func _mod_set_ranking(id: String, ranking: String) -> void :
	if _mod_busy.has(id):
		return
	_mod_busy[id] = true
	_list.refresh()
	_d_status.text = "updating ranking…"
	_d_status.add_theme_color_override("font_color", TXT2)
	var r: Dictionary = await Backend.api_admin_set_ranking(id, ranking)
	_mod_busy.erase(id)
	if not is_inside_tree():
		return
	if r.ok:
		main.sfx.play_ui("impact")
		var diffs: = int(r.data.get("difficulties", 0)) if r.data is Dictionary else 0
		main._screen_toast("MAP %s%s" % [ranking, 
			"  ·  %d difficult%s registered" % [diffs, "y" if diffs == 1 else "ies"]
			if ranking == "RANKED" else ""], main.COL_GOLD)
		if _by_id.has(id):
			_by_id[id]["ranking"] = ranking.to_lower()


			if ranking == "RANKED":
				_by_id[id]["wip"] = false
		var installed: = MapLibrary.find_online(id)
		if installed != "":
			MapLibrary.set_online_ranking(installed, ranking)
			if ranking == "RANKED":
				MapLibrary.set_online_wip(installed, false)
		_d_status.text = ""
		_apply()
	else:
		main.sfx.play_ui("back")
		_d_status.text = MapPublisher.server_error(r, "ranking update failed")
		_d_status.add_theme_color_override("font_color", RED)
		_list.refresh()




func _mod_confirm_remove(id: String, reason: String, at: Vector2) -> void :
	var m: Dictionary = _by_id.get(id, {})
	if m.is_empty():
		return
	var items: Array = [
		{"title": "REMOVE \"%s\" ?" % String(m.title).substr(0, 24)}, 
		{"text": "The zip is deleted from storage; the entry and", "id": "", "disabled": true}, 
		{"text": "the reason (%s) are kept for traceability." % reason.to_lower(), 
			"id": "", "disabled": true}, 
		{"sep": true}, 
		{"text": "CANCEL", "id": "", "accent": Color(1, 1, 1, 0.55)}, 
		{"text": "REMOVE — " + reason, "id": "yes", "accent": RED}, 
	]
	_mod_open_id = id
	_list.refresh()
	var menu: Control = EdMenu.open(main.menu_root, items, at, _fi(500), func(pick: String) -> void :
		if pick == "yes":
			_mod_remove(id, reason), 260)

	_animate_menu(menu)
	menu.tree_exiting.connect( func() -> void :
		if _mod_open_id == id:
			_mod_open_id = ""
			if is_inside_tree():
				_list.refresh())


func _mod_remove(id: String, reason: String) -> void :
	if _mod_busy.has(id):
		return
	_mod_busy[id] = true
	_list.refresh()
	_d_status.text = "removing map…"
	_d_status.add_theme_color_override("font_color", TXT2)


	var r: Dictionary = await Backend.api_admin_triage(id, "CANCEL", 
		_triage_reason_text(TRIAGE_REMOVE_REASONS, reason))
	if not r.ok and r.code == 404 and Backend.is_mod():
		r = await Backend.api_admin_remove_map(id, reason)
	_mod_busy.erase(id)
	if not is_inside_tree():
		return
	if r.ok:
		main.sfx.play_ui("impact")
		var title: = String(_by_id.get(id, {}).get("title", "map"))
		main._screen_toast("MAP REMOVED — %s" % title.to_upper(), RED)
		_by_id.erase(id)
		for i in _all.size():
			if String(_all[i].id) == id:
				_all.remove_at(i)
				break
		_reports.erase(id)
		_d_status.text = ""
		_apply()




		await _load(true)
		if is_inside_tree() and _by_id.has(id):
			main.sfx.play_ui("back")
			_d_status.text = "the server still lists this map — the removal did not stick (server-side)"
			_d_status.add_theme_color_override("font_color", RED)
			main._screen_toast("REMOVAL NOT APPLIED — THE SERVER STILL LISTS \"%s\"" % title.to_upper(), 
				RED)
	else:
		main.sfx.play_ui("back")
		_d_status.text = MapPublisher.server_error(r, "takedown failed")
		_d_status.add_theme_color_override("font_color", RED)
		_list.refresh()




func _mod_dismiss_reports(id: String) -> void :
	if _mod_busy.has(id):
		return
	var reps: Array = _reports.get(id, [])
	if reps.is_empty():
		return
	_mod_busy[id] = true
	_list.refresh()
	_d_status.text = "dismissing reports…"
	_d_status.add_theme_color_override("font_color", TXT2)
	var failed: = 0
	for rep in reps:
		var r: Dictionary = await Backend.api_admin_resolve(str(rep.get("id", "")), "dismiss", "")
		if not r.ok:
			failed += 1
	_mod_busy.erase(id)
	if not is_inside_tree():
		return
	if failed == 0:
		main.sfx.play_ui("click")
		_reports.erase(id)
		_d_status.text = "reports dismissed"
		_d_status.add_theme_color_override("font_color", GREEN)
	else:
		main.sfx.play_ui("back")
		_d_status.text = "%d report%s could not be dismissed" % [failed, "" if failed == 1 else "s"]
		_d_status.add_theme_color_override("font_color", RED)
		_load_reports(_token)
	_list.refresh()












func _build_preview() -> void :
	_pv_player = AudioStreamPlayer.new()
	_pv_player.bus = "Music"
	add_child(_pv_player)
	_pv_player.finished.connect( func() -> void :
		if _pv_state == "playing":
			_stop_preview(true))






func on_covers_ready() -> void :
	_refresh_preview_rows()


func _refresh_preview_rows() -> void :
	if _list != null:
		_list.refresh()




func _toggle_preview(id: String) -> void :
	var m: Dictionary = _by_id.get(id, {})
	if m.is_empty():
		return
	if _pv_id == id and _pv_state != "idle":
		_stop_preview(true)
		return
	_select(id)
	_start_preview(m)


func _start_preview(m: Dictionary) -> void :
	_stop_preview(false)
	_pv_token += 1
	var token: = _pv_token
	var id: = String(m.id)
	_pv_id = id
	_pv_state = "loading"
	_d_status.text = ""
	_refresh_preview_rows()
	var stream: AudioStream = await _preview_stream(m, token)
	if token != _pv_token or not is_inside_tree():
		return
	if stream == null:
		_pv_state = "idle"
		_pv_id = ""
		_refresh_preview_rows()
		return

	main.conductor.stop()
	_pv_player.stream = stream
	var length: float = stream.get_length()
	var from: = 0.0
	var track: = _track_of(m)
	if track != "":
		from = float(MapLibrary.meta_of(track).get("preview_time", 0.0))
	if from <= 0.0 and length > 0.0:
		from = length * 0.4
	if length > 0.0:
		from = clampf(from, 0.0, maxf(length - 8.0, 0.0))
	_pv_player.volume_db = -40.0
	_pv_player.play(from)
	_pv_state = "playing"
	_refresh_preview_rows()
	_pv_tw = create_tween()
	_pv_tw.tween_property(_pv_player, "volume_db", float(main.music_db()) - 6.0, 0.5)
	_pv_tw.tween_interval(PREVIEW_SECONDS - 0.5)
	_pv_tw.tween_callback( func() -> void :
		if _pv_token == token:
			_stop_preview(true))



func _stop_preview(resume: bool) -> void :
	_pv_token += 1
	if _pv_tw != null and _pv_tw.is_valid():
		_pv_tw.kill()
	_pv_tw = null
	var was: = _pv_state
	_pv_state = "idle"
	_pv_id = ""
	_refresh_preview_rows()
	if was == "playing" and _pv_player != null and _pv_player.playing:
		var p: = _pv_player
		var tw: = create_tween()
		tw.tween_property(p, "volume_db", -40.0, 0.35)
		tw.tween_callback( func() -> void :
			if _pv_state != "playing":
				p.stop())
	if was == "playing" and resume and main.screen == main.Screen.SELECT:
		main._play_preview()





func _preview_stream(m: Dictionary, token: int) -> AudioStream:
	var id: = String(m.id)
	var track: = _track_of(m)
	if track != "":
		var local: = MapLibrary.load_audio(MapLibrary.audio_path(track))
		if local != null:
			return local
	var base: = "%s/%s_v%d" % [PREVIEW_DIR, id.validate_filename(), int(m.get("version", 1))]
	for ext in MapLibrary.AUDIO_EXT:
		if FileAccess.file_exists("%s.%s" % [base, ext]):
			return MapLibrary.load_audio("%s.%s" % [base, ext])
	_d_status.text = "loading preview…"
	_d_status.add_theme_color_override("font_color", TXT2)
	var r: Dictionary = await Backend.api_maps_preview_url(id)
	if token != _pv_token or not is_inside_tree():
		return null
	if not r.ok or not (r.data is Dictionary):


		_d_status.text = "previews are not available on this server yet" if r.code == 404 else MapPublisher.server_error(r, "preview unavailable")
		_d_status.add_theme_color_override("font_color", RED)
		return null
	var url: = String(r.data.get("presignedGetUrl", ""))
	var ext: = String(r.data.get("format", "mp3")).to_lower()
	if url == "" or not (ext in MapLibrary.AUDIO_EXT):
		_d_status.text = "preview unavailable"
		_d_status.add_theme_color_override("font_color", RED)
		return null
	DirAccess.make_dir_recursive_absolute(PREVIEW_DIR)
	var final: = "%s.%s" % [base, ext]
	var part: = final + ".part"
	var on_bytes: = func(got: int, total: int) -> void :
		if token != _pv_token:
			return
		if total > 0 and got > 0:
			_d_status.text = "loading preview… %d%%" % clampi(int(got * 100.0 / total), 1, 99)
	var dl: Dictionary = await Backend.download_to_file(url, part, on_bytes)
	if token != _pv_token or not is_inside_tree():
		DirAccess.remove_absolute(part)
		return null
	if not dl.ok:
		DirAccess.remove_absolute(part)
		_d_status.text = "preview download failed (%d) — check your connection" % int(dl.code)
		_d_status.add_theme_color_override("font_color", RED)
		return null
	DirAccess.rename_absolute(part, final)
	_prune_previews()
	_d_status.text = ""
	var stream: = MapLibrary.load_audio(final)
	if stream == null:
		DirAccess.remove_absolute(final)
		_d_status.text = "preview unavailable — the audio could not be decoded"
		_d_status.add_theme_color_override("font_color", RED)
	return stream




func _prune_previews() -> void :
	var d: = DirAccess.open(PREVIEW_DIR)
	if d == null:
		return
	var files: Array = []
	for f in d.get_files():
		if f.ends_with(".part"):
			continue
		var path: = "%s/%s" % [PREVIEW_DIR, f]
		files.append([FileAccess.get_modified_time(path), path])
	if files.size() <= PREVIEW_MAX_FILES:
		return
	files.sort_custom( func(a, b): return a[0] < b[0])
	for i in files.size() - PREVIEW_MAX_FILES:
		DirAccess.remove_absolute(String(files[i][1]))
