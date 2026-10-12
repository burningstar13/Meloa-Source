class_name JudgmentCard
extends PanelContainer



var _cap: Label
var _value: Label
var _col: Color


func _init() -> void :
	theme_type_variation = &"RCard"
	custom_minimum_size = Vector2(120, 84)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v: = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 0)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	_cap = Label.new()
	_cap.theme_type_variation = &"RCardCap"
	_cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_cap)
	_value = Label.new()
	_value.theme_type_variation = &"RCardValue"
	_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_value)


func setup(caption: String, col: Color) -> void :
	_col = col
	_cap.text = caption
	_cap.add_theme_color_override("font_color", col)
	add_theme_stylebox_override("panel", 
		ResultsTheme.box(ResultsTheme.PANEL, Color(col, 0.45), 12, 1, Vector2(10, 8)))


func set_value(text: String) -> void :
	_value.text = text
