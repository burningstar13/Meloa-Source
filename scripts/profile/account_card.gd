class_name AccountCard
extends Button





const CARD_SIZE: = Vector2(300, 54)
const RADIUS: = 14

var _avatar: AvatarView
var _name: Label
var _title: Label
var _rank: Label
var _rp: Label
var _chevron: TextureRect
var _style: StyleBoxFlat
var _tw: Tween
var _rank_col: = ProfileTheme.GOLD


func _init() -> void :
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = CARD_SIZE
	size = CARD_SIZE
	set_meta("ui_sound", "menu_open")
	_style = ProfileTheme.chip(Color(0.05, 0.06, 0.1, 0.72), Color(1, 1, 1, 0.1), RADIUS, Vector2(10, 6))
	_style.shadow_color = Color(0, 0, 0, 0.3)
	_style.shadow_size = 8
	_style.shadow_offset = Vector2(0, 3)
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(s, _style)
	_build()
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))


func _build() -> void :
	var h: = HBoxContainer.new()
	h.set_anchors_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 10
	h.offset_right = -30
	h.offset_top = 6
	h.offset_bottom = -6
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(h)
	_avatar = AvatarView.new()
	_avatar.custom_minimum_size = Vector2(38, 38)
	_avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_avatar.show_frame = false
	h.add_child(_avatar)
	var idc: = VBoxContainer.new()
	idc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	idc.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	idc.add_theme_constant_override("separation", 0)
	idc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(idc)
	_name = ProfileTheme.label("", 15, ProfileTheme.TEXT, idc)
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title = ProfileTheme.label("", 10, ProfileTheme.VIOLET, idc)
	_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	var rk: = VBoxContainer.new()
	rk.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rk.add_theme_constant_override("separation", 0)
	rk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(rk)
	_rank = ProfileTheme.label("", 16, ProfileTheme.GOLD, rk)
	_rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_rp = ProfileTheme.label("", 10, ProfileTheme.DIM, rk)
	_rp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_chevron = ProfileTheme.icon("chevron", 11, Color(1, 1, 1, 0.35), self)
	_chevron.position = Vector2(CARD_SIZE.x - 21, CARD_SIZE.y * 0.5 - 5.5)


func avatar_center_global() -> Vector2:
	return _avatar.get_global_rect().get_center()


func set_profile(p: PlayerProfile) -> void :
	_avatar.set_identity(p.avatar_id, "", p.username)
	var tier: = p.rank_tier()
	_rank_col = tier["color"] if p.has_rank else ProfileTheme.DIM
	var at: = p.acc_tier()
	_avatar.ring_color = Color(at["color"], 0.9) if ( not at.is_empty() and p.ranked_acc_plays >= ProfileRules.ACC_MIN_PLAYS) else Color(0, 0, 0, 0)
	_avatar.queue_redraw()
	match p.state:
		"loading":
			_name.text = "…"
			_title.text = "CONNECTING"
			_rank.text = ""
			_rp.text = ""
		"signed_out":
			_name.text = "NOT SIGNED IN"
			_title.text = "SIGN IN TO ENTER THE RANKING"
			_rank.text = ""
			_rp.text = ""
		"error":
			_name.text = p.username if p.username != "" else "ACCOUNT"
			_title.text = "PROFILE UNAVAILABLE"
			_rank.text = ""
			_rp.text = "offline"
		_:
			_name.text = p.username if p.username != "" else "PLAYER"
			_title.text = p.title_name()
			if p.has_rank:
				_rank.text = "GLOBAL  " + ProfileRules.fmt_rank(p.rank)
				_rp.text = ProfileRules.fmt_rp(p.rp)
			else:
				_rank.text = "UNRANKED"
				_rp.text = "clear a map to get ranked"
	_rank.add_theme_color_override("font_color", _rank_col)
	_title.visible = _title.text != ""


func _on_hover(inside: bool) -> void :
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_style, "border_color", Color(1, 1, 1, 0.26 if inside else 0.1), 0.14)
	_tw.tween_property(_style, "bg_color", Color(0.09, 0.1, 0.15, 0.82) if inside else Color(0.05, 0.06, 0.1, 0.72), 0.14)
	_tw.tween_property(_chevron, "position:x", CARD_SIZE.x - (19.0 if inside else 21.0), 0.12).set_ease(Tween.EASE_OUT)
	_tw.tween_property(_chevron, "modulate:a", 0.7 if inside else 0.35, 0.12)
