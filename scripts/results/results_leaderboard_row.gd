class_name ResultsLeaderboardRow
extends PanelContainer





const AVATAR: = 30.0

var _rank: Label
var _avatar: Control
var _name: Label
var _acc: Label
var _combo: Label
var _score: Label
var _sep: Label
var _initial: = ""
var _col: = ResultsTheme.VIOLET
var _skeleton: = false
var _tex: Texture2D = null
var _h: HBoxContainer


func _init() -> void :
	theme_type_variation = &"RRow"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 46)
	_h = HBoxContainer.new()
	_h.add_theme_constant_override("separation", 10)
	_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_h)
	_rank = Label.new()
	_rank.theme_type_variation = &"RRowRank"
	_rank.custom_minimum_size = Vector2(34, 0)
	_rank.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_h.add_child(_rank)
	_avatar = Control.new()
	_avatar.custom_minimum_size = Vector2(AVATAR, AVATAR)
	_avatar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_avatar.draw.connect(_draw_avatar)
	_h.add_child(_avatar)
	_name = Label.new()
	_name.theme_type_variation = &"RRowName"
	_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.clip_text = true
	_h.add_child(_name)
	var mid: = VBoxContainer.new()
	mid.add_theme_constant_override("separation", -2)
	mid.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mid.custom_minimum_size = Vector2(58, 0)
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_h.add_child(mid)
	_acc = Label.new()
	_acc.theme_type_variation = &"RRowSubStrong"
	mid.add_child(_acc)
	_combo = Label.new()
	_combo.theme_type_variation = &"RRowSub"
	mid.add_child(_combo)
	_score = Label.new()
	_score.theme_type_variation = &"RRowScore"
	_score.custom_minimum_size = Vector2(66, 0)
	_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_score.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_h.add_child(_score)
	_sep = Label.new()
	_sep.theme_type_variation = &"RNote"
	_sep.text = "· · ·"
	_sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sep.set_anchors_preset(Control.PRESET_FULL_RECT)
	_sep.visible = false
	_sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_sep)



func bind(e: Dictionary, me: bool, compact: = false) -> void :
	_skeleton = false
	_sep.visible = false
	_h.visible = true
	custom_minimum_size = Vector2(0, 40 if compact else 46)
	var rank: = int(e.get("rank", 0))
	var uname: = str(e.get("username", "?"))
	_rank.text = "#%d" % rank
	_name.text = "You" if me else uname
	_acc.text = "%.2f%%" % float(e.get("accuracy", 0.0))
	var combo: = int(e.get("maxCombo", e.get("combo", -1)))
	_combo.text = ("%d×" % combo) if combo >= 0 else ""
	_score.text = ResultsTheme.thousands(int(e.get("score", 0)))
	_initial = uname.substr(0, 1).to_upper()
	_col = ResultsAccountCard.color_for(uname)
	theme_type_variation = &"RRowMe" if me else &"RRow"
	var c: = ResultsTheme.CYAN if me else ResultsTheme.TEXT
	_rank.add_theme_color_override("font_color", ResultsTheme.CYAN if me else ResultsTheme.TEXT_DIM)
	_name.add_theme_color_override("font_color", c)
	_acc.add_theme_color_override("font_color", c)
	_score.add_theme_color_override("font_color", c)
	modulate.a = 1.0
	_avatar.queue_redraw()


func set_skeleton() -> void :
	_skeleton = true
	_sep.visible = false
	_h.visible = true
	_rank.text = ""
	_name.text = ""
	_acc.text = ""
	_combo.text = ""
	_score.text = ""
	theme_type_variation = &"RRow"
	modulate.a = 0.6
	_avatar.queue_redraw()


func set_separator() -> void :
	_skeleton = false
	_h.visible = false
	_sep.visible = true
	theme_type_variation = &"RSkeleton"
	custom_minimum_size = Vector2(0, 22)
	modulate.a = 1.0


func set_avatar(tex: Texture2D) -> void :
	_tex = tex
	_avatar.queue_redraw()


func _draw_avatar() -> void :
	var c: = _avatar.size * 0.5
	var r: = AVATAR * 0.5
	if _skeleton:
		_avatar.draw_circle(c, r, Color(1, 1, 1, 0.06))
		_avatar.draw_rect(Rect2(AVATAR + 10.0, c.y - 8.0, 110.0, 7.0), Color(1, 1, 1, 0.06))
		_avatar.draw_rect(Rect2(AVATAR + 10.0, c.y + 3.0, 70.0, 5.0), Color(1, 1, 1, 0.04))
		return
	if _tex != null:
		_avatar.draw_texture_rect(_tex, Rect2(Vector2.ZERO, _avatar.size), false)
		return
	_avatar.draw_circle(c, r, Color(_col, 0.28))
	_avatar.draw_arc(c, r - 0.5, 0.0, TAU, 28, Color(ResultsTheme.VIOLET, 0.85), 1.2, true)
	var f: = ResultsTheme.font(700)
	var s: = f.get_string_size(_initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	_avatar.draw_string(f, c + Vector2( - s.x * 0.5, 4.5), _initial, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 13, _col.lerp(Color.WHITE, 0.45))
