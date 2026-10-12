class_name ResultActionButtons
extends HBoxContainer






signal retry_pressed
signal continue_pressed

var retry_button: Button
var continue_button: Button
var _selected: = 1
var _retry_icon: Control
var _cont_bg: Panel
var _cont_glow: TextureRect
var _cont_label: Label
var _cont_arrow: Control
var _retry_label: Label


func _init() -> void :
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 28)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


	retry_button = Button.new()
	retry_button.theme_type_variation = &"RButton"
	retry_button.custom_minimum_size = Vector2(250, 52)
	retry_button.focus_mode = Control.FOCUS_NONE
	retry_button.text = ""
	retry_button.tooltip_text = "Play this map again  (R)"
	retry_button.pressed.connect( func() -> void : retry_pressed.emit())
	retry_button.mouse_entered.connect( func() -> void : select(0))
	add_child(retry_button)
	var rh: = HBoxContainer.new()
	rh.set_anchors_preset(Control.PRESET_FULL_RECT)
	rh.alignment = BoxContainer.ALIGNMENT_CENTER
	rh.add_theme_constant_override("separation", 12)
	rh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	retry_button.add_child(rh)
	_retry_icon = Control.new()
	_retry_icon.custom_minimum_size = Vector2(20, 20)
	_retry_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_retry_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_retry_icon.draw.connect(_draw_retry_icon)
	rh.add_child(_retry_icon)
	_retry_label = Label.new()
	_retry_label.theme_type_variation = &"RButton"
	_retry_label.text = "RETRY"
	_retry_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_retry_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rh.add_child(_retry_label)


	continue_button = Button.new()
	continue_button.theme_type_variation = &"RButtonMain"
	continue_button.custom_minimum_size = Vector2(290, 52)
	continue_button.focus_mode = Control.FOCUS_NONE
	continue_button.text = ""
	continue_button.tooltip_text = "Back to the map menu  (Esc)"
	continue_button.set_meta("ui_sound", "back")
	continue_button.pressed.connect( func() -> void : continue_pressed.emit())
	continue_button.mouse_entered.connect( func() -> void : select(1))
	add_child(continue_button)

	_cont_glow = TextureRect.new()
	_cont_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cont_glow.offset_left = -40
	_cont_glow.offset_right = 40
	_cont_glow.offset_top = -30
	_cont_glow.offset_bottom = 30
	_cont_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cont_glow.stretch_mode = TextureRect.STRETCH_SCALE
	_cont_glow.modulate = Color(ResultsTheme.VIOLET.lerp(ResultsTheme.CYAN, 0.5), 0.14)
	_cont_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_button.add_child(_cont_glow)

	_cont_bg = Panel.new()
	_cont_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cont_bg.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_cont_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_button.add_child(_cont_bg)
	var grad: = GradientTexture2D.new()
	var g: = Gradient.new()
	g.set_color(0, ResultsTheme.VIOLET)
	g.set_color(1, ResultsTheme.CYAN)
	grad.gradient = g
	grad.width = 256
	grad.height = 8
	grad.fill_from = Vector2(0, 0)
	grad.fill_to = Vector2(1, 0)
	var tr: = TextureRect.new()
	tr.texture = grad
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cont_bg.add_child(tr)
	var ch: = HBoxContainer.new()
	ch.set_anchors_preset(Control.PRESET_FULL_RECT)
	ch.alignment = BoxContainer.ALIGNMENT_CENTER
	ch.add_theme_constant_override("separation", 12)
	ch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	continue_button.add_child(ch)
	_cont_label = Label.new()
	_cont_label.theme_type_variation = &"RButtonMain"
	_cont_label.text = "CONTINUE"
	_cont_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_cont_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ch.add_child(_cont_label)
	_cont_arrow = Control.new()
	_cont_arrow.custom_minimum_size = Vector2(14, 20)
	_cont_arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_cont_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cont_arrow.draw.connect(_draw_arrow)
	ch.add_child(_cont_arrow)
	for b in [retry_button, continue_button]:
		b.resized.connect( func() -> void : b.pivot_offset = b.size * 0.5)
	select(1)


func set_glow_texture(t: Texture2D) -> void :
	_cont_glow.texture = t



func select(i: int) -> void :
	_selected = clampi(i, -1, 1)
	_restyle()


func selected() -> int:
	return _selected


func _restyle() -> void :
	var r_sel: = _selected == 0
	var c_sel: = _selected == 1
	var rn: = ResultsTheme.box(ResultsTheme.PANEL, 
		ResultsTheme.CYAN if r_sel else ResultsTheme.LINE, 26, 
		2 if r_sel else 1, Vector2(20, 8))
	var rh: = ResultsTheme.box(ResultsTheme.PANEL_2, ResultsTheme.CYAN, 26, 2, Vector2(20, 8))
	retry_button.add_theme_stylebox_override("normal", rn)
	retry_button.add_theme_stylebox_override("hover", rh)
	retry_button.add_theme_stylebox_override("pressed", rh)


	var cn: = ResultsTheme.box(Color(0, 0, 0, 0), 
		ResultsTheme.CYAN if c_sel else Color(0, 0, 0, 0), 26, 2 if c_sel else 0, 
		Vector2(0, 0))
	continue_button.add_theme_stylebox_override("normal", cn)
	continue_button.add_theme_stylebox_override("hover", cn)
	continue_button.add_theme_stylebox_override("pressed", cn)
	var bg: = ResultsTheme.box(Color(1, 1, 1, 1), Color(0, 0, 0, 0), 26, 0, Vector2(0, 0))
	_cont_bg.add_theme_stylebox_override("panel", bg)
	_cont_bg.modulate = Color(1.06, 1.06, 1.06) if c_sel else Color.WHITE
	_cont_glow.modulate.a = 0.18 if c_sel else 0.1



func press_visual(i: int) -> void :
	var b: = retry_button if i == 0 else continue_button
	var t: = b.create_tween()
	t.tween_property(b, "scale", Vector2(0.96, 0.96), 0.06).set_ease(Tween.EASE_OUT)
	t.tween_property(b, "scale", Vector2.ONE, 0.16).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func set_interactive(on: bool) -> void :
	for b in [retry_button, continue_button]:
		(b as Button).mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE


func _draw_retry_icon() -> void :
	var c: = _retry_icon.size * 0.5
	var col: = ResultsTheme.VIOLET_LIGHT
	_retry_icon.draw_arc(c, 7.5, - PI * 0.15, PI * 1.55, 20, col, 2.2, true)
	var tip: = c + Vector2(cos( - PI * 0.15), sin( - PI * 0.15)) * 7.5
	_retry_icon.draw_colored_polygon(PackedVector2Array([tip + Vector2(-4, -4), tip + Vector2(3, -1), 
		tip + Vector2(-2, 4)]), col)


func _draw_arrow() -> void :
	var c: = _cont_arrow.size * 0.5
	_cont_arrow.draw_polyline(PackedVector2Array([c + Vector2(-3, -7), c + Vector2(4, 0), c + Vector2(-3, 7)]), 
		Color.WHITE, 2.6, true)
