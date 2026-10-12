class_name PlayerBadge
extends Button








const BADGE_SIZE: = Vector2(280, 46)
const RADIUS: = 12
const GOLD: = Color(1.0, 0.82, 0.3)
const TEXT: = Color(1, 1, 1, 0.92)
const DIM: = Color(1, 1, 1, 0.45)

var _name: Label
var _sub: Label
var _style: StyleBoxFlat
var _tw: Tween


func _init() -> void :
	focus_mode = Control.FOCUS_NONE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	custom_minimum_size = BADGE_SIZE
	size = BADGE_SIZE
	set_meta("ui_sound", "menu_open")
	_style = StyleBoxFlat.new()
	_style.bg_color = Color(0.05, 0.06, 0.1, 0.72)
	_style.border_color = Color(1, 1, 1, 0.1)
	_style.set_border_width_all(1)
	_style.set_corner_radius_all(RADIUS)
	_style.shadow_color = Color(0, 0, 0, 0.3)
	_style.shadow_size = 8
	_style.shadow_offset = Vector2(0, 3)
	for s in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(s, _style)
	var v: = VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 14
	v.offset_right = -14
	v.offset_top = 5
	v.offset_bottom = -5
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", -2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.add_theme_font_size_override("font_size", 15)
	_name.add_theme_color_override("font_color", TEXT)
	_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_name)
	_sub = Label.new()
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub.add_theme_font_size_override("font_size", 10)
	_sub.add_theme_color_override("font_color", DIM)
	_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_sub)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))



func set_fonts(display: Font, body: Font) -> void :
	if display != null:
		_name.add_theme_font_override("font", display)
	if body != null:
		_sub.add_theme_font_override("font", body)




func set_state(logged: bool, username: String, rank: Dictionary) -> void :
	if not logged:
		_name.text = "NOT SIGNED IN"
		_sub.text = "SIGN IN TO ENTER THE RANKING"
		_sub.add_theme_color_override("font_color", DIM)
		return
	_name.text = username.to_upper() if username != "" else "PLAYER"
	var r: = int(rank.get("rank", 0))
	if r > 0:
		var n: = int(rank.get("players", 0))
		_sub.text = "GLOBAL #%d%s  ·  %s MP" % [r, 
			(" / %s PLAYERS" % _fmt_int(n)) if n > 0 else "", 
			_fmt_int(int(round(float(rank.get("totalPp", 0.0)))))]
		_sub.add_theme_color_override("font_color", GOLD)
	else:
		_sub.text = "UNRANKED  ·  clear a map to get ranked"
		_sub.add_theme_color_override("font_color", DIM)


static func _fmt_int(n: int) -> String:
	var s: = str(absi(n))
	var out: = ""
	var i: = s.length()
	while i > 3:
		out = "," + s.substr(i - 3, 3) + out
		i -= 3
	out = s.substr(0, i) + out
	return ("-" if n < 0 else "") + out


func _on_hover(inside: bool) -> void :
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween().set_parallel(true)
	_tw.tween_property(_style, "border_color", Color(1, 1, 1, 0.28 if inside else 0.1), 0.12)
	_tw.tween_property(_style, "bg_color", Color(0.07, 0.08, 0.14, 0.82) if inside else Color(0.05, 0.06, 0.1, 0.72), 0.12)
