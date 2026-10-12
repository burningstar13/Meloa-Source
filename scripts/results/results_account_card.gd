class_name ResultsAccountCard
extends PanelContainer





var _avatar: Control
var _name: Label
var _cap: Label
var _rank: Label
var _state: = "loading"
var _initial: = ""
var _col: = ResultsTheme.VIOLET
var _tex: Texture2D = null


func _init() -> void :
	theme_type_variation = &"RAccount"
	custom_minimum_size = Vector2(190, 56)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h: = HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(h)
	_avatar = Control.new()
	_avatar.custom_minimum_size = Vector2(40, 40)
	_avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_avatar.draw.connect(_draw_avatar)
	h.add_child(_avatar)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", -1)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(col)
	_name = Label.new()
	_name.theme_type_variation = &"RAccountName"
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.clip_text = true
	col.add_child(_name)
	_cap = Label.new()
	_cap.theme_type_variation = &"RAccountCap"
	_cap.text = "GLOBAL RANK"
	col.add_child(_cap)
	_rank = Label.new()
	_rank.theme_type_variation = &"RAccountRank"
	col.add_child(_rank)
	set_loading()


func set_loading() -> void :
	_state = "loading"
	_name.text = "…"
	_cap.text = "ACCOUNT"
	_rank.text = "connecting"
	_rank.add_theme_color_override("font_color", ResultsTheme.TEXT_FAINT)
	_avatar.queue_redraw()


func set_signed_out() -> void :
	_state = "signed_out"
	_name.text = "NOT SIGNED IN"
	_cap.text = "ACCOUNT"
	_rank.text = "sign in to rank"
	_rank.add_theme_color_override("font_color", ResultsTheme.CYAN)
	_initial = ""
	_avatar.queue_redraw()


func set_signed_in(uname: String, global_rank: int, players: int, error: = false) -> void :
	_state = "signed_in"
	_name.text = uname
	_initial = uname.substr(0, 1).to_upper()
	_col = color_for(uname)
	_cap.text = "GLOBAL RANK"
	if error:
		_rank.text = "offline"
		_rank.add_theme_color_override("font_color", ResultsTheme.CORAL)
	elif global_rank > 0:
		_rank.text = "#%s" % ResultsTheme.thousands(global_rank)
		_rank.add_theme_color_override("font_color", ResultsTheme.TEXT)
		tooltip_text = "#%d of %d players" % [global_rank, players]
	else:
		_rank.text = "unranked"
		_rank.add_theme_color_override("font_color", ResultsTheme.TEXT_FAINT)
	_avatar.queue_redraw()


func set_avatar(tex: Texture2D) -> void :
	_tex = tex
	_avatar.queue_redraw()


func fill(r: RunResult) -> void :
	match r.account_state:
		"signed_in":
			set_signed_in(r.player_name, r.global_rank, r.global_players)
		"error":
			set_signed_in(r.player_name, 0, 0, true)
		"signed_out":
			set_signed_out()
		_:
			set_loading()


static func color_for(uname: String) -> Color:
	var h: = float(absi(uname.hash()) % 360) / 360.0
	return Color.from_hsv(h, 0.5, 0.95)


func _draw_avatar() -> void :
	var c: = _avatar.size * 0.5
	var r: = 19.0
	if _tex != null:
		_avatar.draw_texture_rect(_tex, Rect2(Vector2.ZERO, _avatar.size), false)
		return
	match _state:
		"signed_in":
			_avatar.draw_circle(c, r, Color(_col, 0.28))
			_avatar.draw_arc(c, r - 0.5, 0.0, TAU, 32, Color(ResultsTheme.VIOLET, 0.9), 1.5, true)
			var f: = ResultsTheme.font(700)
			var s: = f.get_string_size(_initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 17)
			_avatar.draw_string(f, c + Vector2( - s.x * 0.5, 6.0), _initial, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, 17, _col.lerp(Color.WHITE, 0.45))
		"loading":
			_avatar.draw_arc(c, r - 1.0, 0.0, TAU * 0.7, 24, Color(1, 1, 1, 0.22), 2.0, true)
		_:
			_avatar.draw_circle(c, r, Color(ResultsTheme.VIOLET, 0.12))
			_avatar.draw_arc(c, r - 0.5, 0.0, TAU, 32, Color(ResultsTheme.VIOLET, 0.6), 1.5, true)
			_avatar.draw_circle(c + Vector2(0, -4), 6.0, Color(1, 1, 1, 0.55))
			_avatar.draw_circle(c + Vector2(0, 12), 11.0, Color(1, 1, 1, 0.45))
