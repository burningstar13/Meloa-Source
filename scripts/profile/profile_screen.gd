class_name ProfileScreen
extends Control























signal closed
signal ranking_requested

const PANEL_W: = 720.0

var main
var _p: PlayerProfile
var _card: Control
var _closing: = false
var _pending_events: Array = []
var _playing_event: = false

var _dim: ColorRect
var _panel: PanelContainer
var _avatar: AvatarView
var _name: Label
var _title: Label
var _rank: Label
var _rank_sub: Label
var _state_msg: Label
var _ms_from: Label
var _ms_to: Label
var _ms_bar: Control
var _ms_text: Label
var _acc_value: Label
var _acc_tier: Label
var _acc_tier_style: StyleBoxFlat
var _acc_next: Label
var _st_time: Label
var _st_clears: Label
var _st_fc: Label
var _rows: = {}
var _items: = {}
var _dev: HFlowContainer


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _ready() -> void :
	get_viewport().size_changed.connect(_layout)
	ProfileService.profile_changed.connect(_on_profile_changed)
	ProfileService.unlock_events.connect(_on_unlock_events)


	_wire(_panel)
	_wire(_dev)
	_on_profile_changed(ProfileService.profile)
	_layout()


func _wire(node: Node) -> void :
	if main != null and main.has_method("_wire_ui_sounds"):
		main._wire_ui_sounds(node)


func is_open() -> bool:
	return visible and not _closing




func _build() -> void :
	_dim = ColorRect.new()
	_dim.color = Color(0.008, 0.012, 0.028, 0.8)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.gui_input.connect( func(ev: InputEvent) -> void :
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close())
	add_child(_dim)

	_panel = PanelContainer.new()
	var st: = ProfileTheme.chip(ProfileTheme.PANEL_BG, Color(1, 1, 1, 0.13), 16, Vector2(22, 18))
	st.shadow_color = Color(0, 0, 0, 0.4)
	st.shadow_size = 14
	st.shadow_offset = Vector2(0, 6)
	_panel.add_theme_stylebox_override("panel", st)
	add_child(_panel)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	_panel.add_child(v)


	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	v.add_child(top)
	var av_box: = Control.new()
	av_box.custom_minimum_size = Vector2(72, 72)
	av_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	av_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(av_box)
	_avatar = AvatarView.new()
	_avatar.set_anchors_preset(Control.PRESET_FULL_RECT)
	_avatar.offset_left = 0
	_avatar.offset_top = 0
	_avatar.offset_right = 0
	_avatar.offset_bottom = 0
	av_box.add_child(_avatar)
	var idc: = VBoxContainer.new()
	idc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	idc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	idc.add_theme_constant_override("separation", 2)
	top.add_child(idc)
	_name = ProfileTheme.label("", 26, ProfileTheme.TEXT, idc, ProfileTheme.display())
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title = ProfileTheme.label("", 11, ProfileTheme.VIOLET, idc)
	_state_msg = ProfileTheme.label("", 10, ProfileTheme.DIM, idc, ProfileTheme.body())
	_state_msg.visible = false

	var rk: = Button.new()
	rk.focus_mode = Control.FOCUS_NONE
	rk.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	rk.tooltip_text = "Open the global ranking"
	rk.add_theme_stylebox_override("normal", ProfileTheme.chip(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 10, Vector2(10, 6)))
	rk.add_theme_stylebox_override("hover", ProfileTheme.chip(Color(1, 1, 1, 0.04), Color(1, 1, 1, 0.1), 10, Vector2(10, 6)))
	rk.add_theme_stylebox_override("pressed", ProfileTheme.chip(Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.14), 10, Vector2(10, 6)))
	rk.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	rk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rk.set_meta("ui_sound", "click")
	rk.pressed.connect( func() -> void : ranking_requested.emit())
	top.add_child(rk)
	var rkv: = VBoxContainer.new()
	rkv.add_theme_constant_override("separation", 0)
	rkv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rk.add_child(rkv)
	ProfileTheme.cap("GLOBAL RANKING", rkv, ProfileTheme.VIOLET, 10).horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rank = ProfileTheme.label("", 34, ProfileTheme.GOLD, rkv)
	_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rank_sub = ProfileTheme.label("", 11, ProfileTheme.DIM, rkv)
	_rank_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	rkv.resized.connect( func() -> void : rk.custom_minimum_size = rkv.size + Vector2(20, 12))
	var close_b: = ProfileTheme.button("✕", Color(1, 1, 1, 0.5), top, 12)
	close_b.custom_minimum_size = Vector2(30, 30)
	close_b.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	close_b.tooltip_text = "Close (Esc)"
	close_b.set_meta("ui_sound", "back")
	close_b.pressed.connect(close)

	ProfileTheme.hsep(v)


	var ms: = HBoxContainer.new()
	ms.add_theme_constant_override("separation", 12)
	v.add_child(ms)
	ProfileTheme.cap("NEXT MILESTONE", ms).custom_minimum_size = Vector2(120, 0)
	_ms_from = ProfileTheme.label("", 11, ProfileTheme.DIM, ms)
	_ms_bar = ProfileTheme.bar(160, 4, ProfileTheme.GOLD, ms)
	_ms_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ms_to = ProfileTheme.label("", 11, ProfileTheme.TEXT, ms)
	_ms_text = ProfileTheme.label("", 11, ProfileTheme.DIM, ms, ProfileTheme.body())
	_ms_text.custom_minimum_size = Vector2(230, 0)
	_ms_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_ms_text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

	ProfileTheme.hsep(v)


	var mid: = HBoxContainer.new()
	mid.add_theme_constant_override("separation", 22)
	v.add_child(mid)
	var accc: = VBoxContainer.new()
	accc.add_theme_constant_override("separation", 1)
	accc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_child(accc)
	ProfileTheme.cap("RANKED ACCURACY", accc)
	var accr: = HBoxContainer.new()
	accr.add_theme_constant_override("separation", 10)
	accc.add_child(accr)
	_acc_value = ProfileTheme.label("", 26, ProfileTheme.CYAN, accr)
	_acc_tier = ProfileTheme.label("", 10, ProfileTheme.TEXT, accr)
	_acc_tier_style = ProfileTheme.chip(Color(1, 1, 1, 0.06), Color(1, 1, 1, 0.15), 8, Vector2(8, 1))
	_acc_tier.add_theme_stylebox_override("normal", _acc_tier_style)
	_acc_tier.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_acc_next = ProfileTheme.label("", 11, ProfileTheme.DIM, accc, ProfileTheme.body())
	ProfileTheme.vsep(mid, 40)
	_st_time = _stat(mid, "PLAYED")
	_st_clears = _stat(mid, "CLEARS")
	_st_fc = _stat(mid, "FULL COMBOS")

	ProfileTheme.hsep(v)


	for pair in [["avatar", "AVATAR"], ["title", "TITLE"]]:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		v.add_child(row)
		ProfileTheme.cap(String(pair[1]), row).custom_minimum_size = Vector2(120, 0)
		var items: = HBoxContainer.new()
		items.add_theme_constant_override("separation", 6)
		items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(items)
		_rows[pair[0]] = items


	_dev = HFlowContainer.new()
	_dev.add_theme_constant_override("h_separation", 5)
	_dev.add_theme_constant_override("v_separation", 4)
	_dev.visible = false
	add_child(_dev)
	ProfileTheme.cap("DEV · MOCK", _dev, ProfileTheme.RED, 9).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for key in ProfileMockData.PROFILES + ProfileMockData.STATES:
		var b: = ProfileTheme.button(key.to_upper(), Color(1, 1, 1, 0.5), _dev, 9)
		b.pressed.connect( func() -> void : ProfileService.mock_select(key))
	var up: = ProfileTheme.button("+ RANK MILESTONE", ProfileTheme.GOLD, _dev, 9)
	up.pressed.connect( func() -> void : ProfileService.mock_simulate_rank_up())
	var tier: = ProfileTheme.button("+ ACC TIER", ProfileTheme.MINT, _dev, 9)
	tier.pressed.connect( func() -> void : ProfileService.mock_simulate_acc_tier_up())


func _stat(parent: Control, cap: String) -> Label:
	var c: = VBoxContainer.new()
	c.add_theme_constant_override("separation", 1)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	parent.add_child(c)
	ProfileTheme.cap(cap, c)
	return ProfileTheme.label("—", 19, ProfileTheme.TEXT, c)


func _layout() -> void :
	var vs: = get_viewport_rect().size
	if vs.x < 100.0:
		return
	var w: = minf(PANEL_W, vs.x - 80.0)
	_panel.custom_minimum_size = Vector2(w, 0)
	_panel.size = Vector2(w, _panel.get_combined_minimum_size().y)
	_panel.position = ((vs - _panel.size) * 0.5).round()
	_panel.pivot_offset = _panel.size * 0.5
	_dev.position = Vector2(_panel.position.x, _panel.position.y + _panel.size.y + 8.0)
	_dev.size = Vector2(w, 0)




func _on_profile_changed(p: PlayerProfile) -> void :
	_p = p
	_dev.visible = ProfileService.dev_controls_visible()
	if is_open() and (_playing_event or not _pending_events.is_empty()):
		return
	_apply(p)
	if visible:
		_layout.call_deferred()


func _apply(p: PlayerProfile) -> void :
	var live: = p.state in ["ready", "partial"]
	_avatar.set_identity(p.avatar_id, "", p.username)
	_name.text = p.username if p.username != "" else ("PLAYER" if p.state != "signed_out" else "NOT SIGNED IN")
	_title.text = p.title_name()
	_title.visible = _title.text != ""
	var msg: = ""
	match p.state:
		"loading": msg = "loading…"
		"signed_out": msg = "sign in to enter the ranking and unlock rewards"
		"error": msg = "profile unavailable · " + p.error_message
		"partial": msg = "detailed statistics are not available yet"
	_state_msg.text = msg
	_state_msg.visible = msg != ""

	var tier: = p.rank_tier()
	var tcol: Color = tier["color"]
	_rank.add_theme_color_override("font_color", tcol if p.has_rank else ProfileTheme.DIM)
	if p.has_rank:
		_rank.text = ProfileRules.fmt_rank(p.rank)
		var parts: Array = [ProfileRules.fmt_rp(p.rp)]
		if p.percentile > 0.0:
			parts.append(ProfileRules.fmt_percentile(p.percentile))
		if p.has_rank_delta and p.rank_delta_week != 0:
			parts.append(("▲ %d" if p.rank_delta_week > 0 else "▼ %d") % absi(p.rank_delta_week) + " this week")
		_rank_sub.text = "  ·  ".join(parts)
		var nxt: = ProfileRules.next_milestone(p.rank)
		var prev: = ProfileRules.last_milestone(p.rank)
		_ms_from.text = "#%s" % ProfileRules.thousands(prev) if prev > 0 else "#%s" % ProfileRules.thousands(nxt * 2)
		if nxt > 0:
			_ms_to.text = "#%s" % ProfileRules.thousands(nxt)
			ProfileTheme.set_bar(_ms_bar, ProfileRules.milestone_progress(p.rank), tcol)
			var places: = p.rank - nxt
			var reward: Dictionary = ProfileRules.RANK_REWARDS.get(nxt, {})
			_ms_text.text = "%d place%s to Top %d" % [places, "s" if places > 1 else "", nxt]\
			+ ((" · " + String(reward["name"]).capitalize().to_lower()) if not reward.is_empty() else "")
		else:
			_ms_to.text = "#1"
			ProfileTheme.set_bar(_ms_bar, 1.0, tcol)
			_ms_text.text = "top of the world"
	else:
		_rank.text = "UNRANKED" if live else "—"
		_rank_sub.text = "clear a ranked map to get ranked" if live else ""
		_ms_from.text = "—"
		_ms_to.text = "#%s" % ProfileRules.thousands(int(ProfileRules.RANK_LADDER[0]))
		ProfileTheme.set_bar(_ms_bar, 0.0, ProfileTheme.DIM)
		_ms_text.text = "your first ranked clear puts you on the ladder" if live else ""
	_rank.add_theme_font_size_override("font_size", 34 if _rank.text.length() <= 6 else 22)

	var at: = p.acc_tier()
	if p.has_acc() and p.ranked_acc_plays >= ProfileRules.ACC_MIN_PLAYS and not at.is_empty():
		var acol: Color = at["color"]
		_acc_value.text = ProfileRules.fmt_acc(p.ranked_acc)
		_acc_value.add_theme_color_override("font_color", acol)
		_acc_tier.text = String(at["name"])
		_acc_tier.visible = true
		_acc_tier.add_theme_color_override("font_color", acol)
		_acc_tier_style.bg_color = Color(acol, 0.1)
		_acc_tier_style.border_color = Color(acol, 0.55)
		_avatar.ring_color = Color(acol, 0.9)
		var nt: = ProfileRules.next_acc_tier(p.ranked_acc)
		_acc_next.text = ("%.2f%% to %s" % [maxf(float(nt["min"]) - p.ranked_acc, 0.0), String(nt["name"]).capitalize()])\
		if not nt.is_empty() else "highest tier · over %d ranked plays" % p.ranked_acc_plays
	else:
		_acc_value.text = "—"
		_acc_value.add_theme_color_override("font_color", ProfileTheme.DIM)
		_avatar.ring_color = Color(0, 0, 0, 0)
		_acc_tier.visible = false
		if p.has_acc():
			_acc_next.text = "%d more ranked plays to rate your accuracy" % maxi(ProfileRules.ACC_MIN_PLAYS - p.ranked_acc_plays, 1)
		else:
			_acc_next.text = "play ranked maps to rate your accuracy" if live else ""
	_st_time.text = ProfileRules.fmt_hours(p.play_time_sec) if p.has_stats and p.play_time_sec >= 0.0 else "—"
	_st_clears.text = ProfileRules.thousands(p.clears) if p.has_stats else "—"
	_st_fc.text = ProfileRules.thousands(p.full_combos) if p.has_stats else "—"

	_items.clear()
	for kind in _rows:
		var row: HBoxContainer = _rows[kind]
		for c in row.get_children():
			row.remove_child(c)
			c.queue_free()
		for it in ProfileRules.catalogue(kind):
			row.add_child(_item_button(String(kind), it, p))
		row.get_parent().visible = live
		_wire(row)





func _item_button(kind: String, it: Dictionary, p: PlayerProfile) -> Button:
	var id: = String(it["id"])
	var locked: = not p.is_unlocked(kind, id)
	var equipped: = p.is_equipped(kind, id)
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not locked else Control.CURSOR_ARROW
	b.tooltip_text = ProfileRules.unlock_text(it) if locked else String(it["name"])
	b.set_meta("ui_sound", "click")
	var accent: = Color(1, 1, 1, 0.55) if equipped else Color(1, 1, 1, 0.1)
	if kind == "title":
		b.text = String(it["name"])
		b.add_theme_font_override("font", ProfileTheme.bold())
		b.add_theme_font_size_override("font_size", 9)
		b.add_theme_color_override("font_color", ProfileTheme.FAINT if locked else (ProfileTheme.TEXT if equipped else ProfileTheme.VIOLET))
		b.add_theme_color_override("font_hover_color", ProfileTheme.FAINT if locked else Color.WHITE)
		b.add_theme_color_override("font_pressed_color", ProfileTheme.FAINT if locked else Color.WHITE)
		b.add_theme_stylebox_override("normal", ProfileTheme.chip(Color(1, 1, 1, 0.02 if locked else 0.05), accent, 8, Vector2(8, 3)))
		b.add_theme_stylebox_override("hover", ProfileTheme.chip(Color(1, 1, 1, 0.02 if locked else 0.09), accent if locked else Color(1, 1, 1, 0.3), 8, Vector2(8, 3)))
		b.add_theme_stylebox_override("pressed", ProfileTheme.chip(Color(1, 1, 1, 0.12), accent, 8, Vector2(8, 3)))
	else:
		b.custom_minimum_size = Vector2(34, 34)
		b.add_theme_stylebox_override("normal", ProfileTheme.chip(Color(1, 1, 1, 0.02 if locked else 0.05), accent, 17, Vector2(0, 0)))
		b.add_theme_stylebox_override("hover", ProfileTheme.chip(Color(1, 1, 1, 0.02 if locked else 0.09), accent if locked else Color(1, 1, 1, 0.3), 17, Vector2(0, 0)))
		b.add_theme_stylebox_override("pressed", ProfileTheme.chip(Color(1, 1, 1, 0.12), accent, 17, Vector2(0, 0)))
		var av: = AvatarView.new()
		av.set_anchors_preset(Control.PRESET_FULL_RECT)
		av.offset_left = 7
		av.offset_top = 7
		av.offset_right = -7
		av.offset_bottom = -7
		if kind == "avatar":
			av.set_identity(id, "", p.username)
			av.show_frame = false
		else:
			av.set_identity(p.avatar_id, id, p.username)
		av.dim = 0.6 if locked else 0.0
		av.frame_alpha = 0.5 if locked else 1.0
		av.ring_color = Color(0, 0, 0, 0)
		b.add_child(av)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	if locked:
		var lk: = ProfileTheme.icon("lock", 8, Color(1, 1, 1, 0.5), b)
		lk.position = Vector2(2, 2)
	elif p.is_new(kind, id):
		var dot: = ColorRect.new()
		dot.color = ProfileTheme.GOLD
		dot.size = Vector2(5, 5)
		dot.position = Vector2(b.custom_minimum_size.x - 7 if kind != "title" else 3, 2)
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(dot)
	b.pressed.connect( func() -> void : _choose(kind, id))
	_items["%s:%s" % [kind, id]] = b
	return b


func _choose(kind: String, id: String) -> void :
	if _p == null or not _p.is_unlocked(kind, id):
		return
	ProfileService.mark_seen(kind, id)
	if kind == "title" and _p.title_id == id:
		ProfileService.unequip_title()
	else:
		ProfileService.equip(kind, id)
	ProfileTheme.play(main, "equip")




func open_from(card: Control) -> void :
	if is_open():
		return
	_card = card
	_closing = false
	visible = true
	if _p != null:
		_apply(_p)
	_layout()
	ProfileTheme.play(main, "open")
	_dim.modulate.a = 0.0
	_panel.modulate.a = 0.0
	_panel.scale = Vector2(0.965, 0.965)
	var tw: = create_tween().set_parallel(true)
	tw.tween_property(_dim, "modulate:a", 1.0, 0.14)
	tw.tween_property(_panel, "modulate:a", 1.0, 0.14)
	tw.tween_property(_panel, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.chain().tween_callback(_play_pending_events)


func close() -> void :
	if not visible or _closing:
		return
	_closing = true
	ProfileTheme.play(main, "close")
	var tw: = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_callback( func() -> void :
		if not _closing:
			return
		visible = false
		modulate.a = 1.0
		_closing = false
		closed.emit())


func on_escape() -> bool:
	if not is_open():
		return false
	close()
	return true




func _on_unlock_events(events: Array) -> void :
	_pending_events.append_array(events)
	if is_open():
		_play_pending_events()


func _play_pending_events() -> void :
	if _playing_event or _pending_events.is_empty() or not is_open():
		return
	_playing_event = true
	var e: Dictionary = _pending_events.pop_front()
	match String(e.get("kind", "")):
		"rank": await _play_rank(e)
		"acc_tier": await _play_acc(e)
		"cosmetic": await _play_cosmetic(e)
	_playing_event = false
	if not _pending_events.is_empty():
		_play_pending_events()
	elif _p != null:
		_apply(_p)




func _play_rank(e: Dictionary) -> void :
	var from_rank: = int(e.get("from", 0))
	var to_rank: = int(e.get("to", 0))
	ProfileTheme.play(main, "milestone")
	var tw: = create_tween()
	if from_rank > 0 and to_rank > 0:
		tw.tween_method( func(v: float) -> void :
			_rank.text = ProfileRules.fmt_rank(int(round(v))), float(from_rank), float(to_rank), 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.parallel().tween_method( func(v: float) -> void : ProfileTheme.set_bar(_ms_bar, v), 
		float(_ms_bar.get_meta("fill", 0.0)), 1.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	await tw.finished
	_apply(_p)



func _play_acc(e: Dictionary) -> void :
	var from_acc: = float(e.get("from_acc", 0.0))
	var to_acc: = float(e.get("to_acc", 0.0))
	var nt: Dictionary = ProfileRules.ACC_TIERS[clampi(int(e.get("to_index", 0)), 0, ProfileRules.ACC_TIERS.size() - 1)]
	var ncol: Color = nt["color"]
	ProfileTheme.play(main, "tier_up")
	var tw: = create_tween()
	tw.tween_method( func(v: float) -> void : _acc_value.text = ProfileRules.fmt_acc(v), from_acc, to_acc, 0.6)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.parallel().tween_property(_acc_value, "theme_override_colors/font_color", ncol, 0.6)
	await tw.finished
	_acc_tier.text = String(nt["name"])
	_acc_tier.visible = true
	_acc_tier.add_theme_color_override("font_color", ncol)
	_acc_tier_style.bg_color = Color(ncol, 0.3)
	_acc_tier_style.border_color = ncol
	_acc_tier.scale = Vector2(0.8, 0.8)
	_acc_tier.pivot_offset = _acc_tier.size * 0.5
	var tw2: = create_tween()
	tw2.tween_property(_acc_tier, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw2.tween_property(_acc_tier_style, "bg_color", Color(ncol, 0.1), 0.6)
	tw2.parallel().tween_property(_acc_tier_style, "border_color", Color(ncol, 0.55), 0.6)
	await tw2.finished
	_apply(_p)




func _play_cosmetic(e: Dictionary) -> void :
	var key: = "%s:%s" % [String(e.get("cosmetic_kind", "")), String(e.get("id", ""))]
	ProfileTheme.play(main, "unlock")
	_apply(_p)
	var b: Button = _items.get(key)
	if b == null:
		return
	var st: StyleBoxFlat = b.get_theme_stylebox("normal")
	if st == null:
		return
	var base: = st.border_color
	var tw: = create_tween()
	tw.tween_property(st, "border_color", ProfileTheme.CYAN, 0.18)
	tw.parallel().tween_property(b, "modulate", Color(1.35, 1.35, 1.35), 0.18)
	tw.tween_interval(0.5)
	tw.tween_property(st, "border_color", base, 0.5)
	tw.parallel().tween_property(b, "modulate", Color.WHITE, 0.5)
	await tw.finished
