extends Button


























var main: Node

const CARD_H: = 74.0
const CARD_RADIUS: = 16.0
const PILL_W: = 96.0
const PILL_H: = 42.0
const GLOBE: = 46.0


const COMPACT_BELOW: = 380.0
const PILL_W_COMPACT: = 84.0


const TINY_BELOW: = 330.0
const PILL_W_TINY: = 48.0
const HOT_DUR: = 0.14
const PRESS_DUR: = 0.06

const VIOLET: = Color(0.576, 0.294, 1.0)
const CYAN: = Color(0.149, 0.843, 0.957)
const CARD_BG: = Color(0.098, 0.071, 0.22)




const SHADER_CODE: = "\nshader_type canvas_item;\nrender_mode blend_mix;\n\nuniform vec4 left_color : source_color = vec4(0.55, 0.25, 1.0, 1.0);\nuniform vec4 right_color : source_color = vec4(0.08, 0.72, 0.95, 1.0);\nuniform vec4 border_left : source_color = vec4(0.58, 0.29, 1.0, 1.0);\nuniform vec4 border_right : source_color = vec4(0.15, 0.84, 0.96, 1.0);\nuniform float border_px = 2.0;\nuniform float radius_px = 16.0;\nuniform vec2 size_px = vec2(300.0, 74.0);\nuniform float hover_amount : hint_range(0.0, 1.0) = 0.0;\n\nvoid fragment() {\n\tvec2 p = UV * size_px;\n\tvec2 half_size = size_px * 0.5;\n\tfloat r = min(radius_px, min(half_size.x, half_size.y));\n\tvec2 q = abs(p - half_size) - (half_size - vec2(r));\n\tfloat d = length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - r;\n\tfloat t = smoothstep(0.0, 1.0, UV.x);\n\tvec4 fill = mix(left_color, right_color, t);\n\tvec4 edge = mix(border_left, border_right, t);\n\tfloat inside = 1.0 - smoothstep(-1.0, 0.0, d);\n\tfloat core = 1.0 - smoothstep(-border_px - 1.0, -border_px, d);\n\tvec4 col = mix(edge, fill, core);\n\tcol.rgb *= 1.0 + hover_amount * 0.12;\n\tCOLOR = vec4(col.rgb, col.a * inside);\n}\n"





























var _visual: Control
var _glow_style: StyleBoxFlat
var _card_mat: ShaderMaterial
var _pill_mat: ShaderMaterial
var _arrow: Control
var _pill: Control
var _open_label: Label
var _arrow_dx: = 0.0
var _hover_amt: = 0.0
var _hot_tw: Tween = null
var _press_tw: Tween = null
var _hot: = false


func _ready() -> void :
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(0, CARD_H)
	tooltip_text = "Open the online catalog of community maps"
	set_meta("ui_sound", "menu_open")


	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(st, empty)
	var sh: = Shader.new()
	sh.code = SHADER_CODE

	_visual = Control.new()
	_visual.name = "Visual"
	_visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_visual)



	var glow: = Panel.new()
	glow.name = "Glow"
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_glow_style = StyleBoxFlat.new()
	_glow_style.draw_center = false
	_glow_style.set_corner_radius_all(int(CARD_RADIUS))
	_glow_style.corner_detail = 12
	_glow_style.shadow_size = 10
	_glow_style.shadow_color = Color(0.52, 0.42, 1.0, 0.16)
	glow.add_theme_stylebox_override("panel", _glow_style)
	_visual.add_child(glow)



	_card_mat = ShaderMaterial.new()
	_card_mat.shader = sh
	_card_mat.set_shader_parameter("left_color", CARD_BG)
	_card_mat.set_shader_parameter("right_color", 
		Color(CARD_BG.r, CARD_BG.g + 0.06, CARD_BG.b + 0.07))
	_card_mat.set_shader_parameter("border_left", Color(VIOLET, 0.9))
	_card_mat.set_shader_parameter("border_right", Color(CYAN, 0.85))
	_card_mat.set_shader_parameter("border_px", 2.0)
	_card_mat.set_shader_parameter("radius_px", CARD_RADIUS)
	var bg: = _shader_rect("Background", _card_mat)
	_visual.add_child(bg)


	var margin: = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 11)
	_visual.add_child(margin)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)


	var globe: = PanelContainer.new()
	globe.name = "Globe"
	globe.custom_minimum_size = Vector2(GLOBE, GLOBE)
	globe.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	globe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var gs: = StyleBoxFlat.new()
	gs.bg_color = Color(CYAN.r * 0.1, CYAN.g * 0.16, CYAN.b * 0.2, 0.95)
	gs.set_corner_radius_all(int(GLOBE * 0.5))
	gs.corner_detail = 16
	gs.anti_aliasing = true
	gs.set_border_width_all(1)
	gs.border_color = Color(CYAN, 0.4)
	gs.content_margin_left = 10
	gs.content_margin_right = 10
	gs.content_margin_top = 10
	gs.content_margin_bottom = 10
	globe.add_theme_stylebox_override("panel", gs)
	var icon: = UiIcon.new()
	icon.kind = "globe"
	icon.tint = Color(CYAN.r * 1.1, CYAN.g * 1.08, CYAN.b * 1.08)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	globe.add_child(icon)
	row.add_child(globe)


	var texts: = VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	texts.add_theme_constant_override("separation", 1)
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(texts)
	texts.add_child(_label("GET MORE MAPS", _fredoka(600), 17, Color(1, 1, 1, 0.98)))
	texts.add_child(_label("Browse and download community maps", _fredoka(500, 0), 
		11, Color(1, 1, 1, 0.78)))


	_pill = Control.new()
	var pill: = _pill
	pill.name = "OpenPill"
	pill.custom_minimum_size = Vector2(PILL_W, PILL_H)
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pill_mat = ShaderMaterial.new()
	_pill_mat.shader = sh
	_pill_mat.set_shader_parameter("left_color", Color(0.55, 0.25, 1.0))
	_pill_mat.set_shader_parameter("right_color", Color(0.08, 0.72, 0.95))
	_pill_mat.set_shader_parameter("border_left", Color(1, 1, 1, 0.38))
	_pill_mat.set_shader_parameter("border_right", Color(1, 1, 1, 0.38))
	_pill_mat.set_shader_parameter("border_px", 1.0)
	_pill_mat.set_shader_parameter("radius_px", PILL_H * 0.5)
	pill.add_child(_shader_rect("PillBackground", _pill_mat))
	var pill_glow: = Panel.new()
	pill_glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pg: = StyleBoxFlat.new()
	pg.draw_center = false
	pg.set_corner_radius_all(int(PILL_H * 0.5))
	pg.corner_detail = 12
	pg.shadow_size = 6
	pg.shadow_color = Color(0.45, 0.55, 1.0, 0.18)
	pill_glow.add_theme_stylebox_override("panel", pg)
	pill.add_child(pill_glow)
	var pill_row: = HBoxContainer.new()
	pill_row.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pill_row.add_theme_constant_override("separation", 7)
	pill_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pill.add_child(pill_row)

	_open_label = _label("OPEN", _fredoka(600), 15, Color(1, 1, 1, 1), false)
	_open_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pill_row.add_child(_open_label)


	_arrow = Control.new()
	_arrow.custom_minimum_size = Vector2(16, 16)
	_arrow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arrow.draw.connect(_draw_arrow)
	pill_row.add_child(_arrow)
	row.add_child(pill)

	resized.connect(_on_resized)
	_on_resized()
	mouse_entered.connect(_refresh_hot)
	mouse_exited.connect(_refresh_hot)
	focus_entered.connect(_refresh_hot)
	focus_exited.connect(_refresh_hot)
	button_down.connect(_on_down)
	button_up.connect(_on_up)



	pressed.connect(release_focus, CONNECT_DEFERRED)



func _shader_rect(node_name: String, mat: ShaderMaterial) -> ColorRect:
	var r: = ColorRect.new()
	r.name = node_name
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.material = mat
	r.color = Color.WHITE
	return r




func _fredoka(weight: int, spacing: = 1) -> Font:
	if main == null or main.font_display == null:
		return null
	var base: Font = main.font_display
	if base is FontVariation and (base as FontVariation).base_font != null:
		return main._font_var((base as FontVariation).base_font, 
			{"wght": weight, "wdth": 100}, spacing)
	return base


func _label(text: String, font: Font, sz: int, col: Color, clip: = true) -> Label:
	var l: = Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	if clip:
		l.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		l.clip_text = true
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", col)
	if font != null:
		l.add_theme_font_override("font", font)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _draw_arrow() -> void :
	var c: = _arrow.size * 0.5 + Vector2(_arrow_dx, 0.0)
	var col: = Color(1, 1, 1, 0.98)
	_arrow.draw_line(c + Vector2(-6.0, 0.0), c + Vector2(5.0, 0.0), col, 1.8, true)
	_arrow.draw_line(c + Vector2(1.0, -4.5), c + Vector2(5.5, 0.0), col, 1.8, true)
	_arrow.draw_line(c + Vector2(5.5, 0.0), c + Vector2(1.0, 4.5), col, 1.8, true)




func _on_resized() -> void :
	pivot_offset = size * 0.5
	_card_mat.set_shader_parameter("size_px", size)
	var pw: = PILL_W
	if size.x < TINY_BELOW:
		pw = PILL_W_TINY
	elif size.x < COMPACT_BELOW:
		pw = PILL_W_COMPACT
	_open_label.visible = size.x >= TINY_BELOW
	_pill.custom_minimum_size = Vector2(pw, PILL_H)
	_pill_mat.set_shader_parameter("size_px", Vector2(pw, PILL_H))


func _set_hover_amt(v: float) -> void :
	_hover_amt = v
	_card_mat.set_shader_parameter("hover_amount", v)
	_pill_mat.set_shader_parameter("hover_amount", v)


func _set_arrow_dx(v: float) -> void :
	_arrow_dx = v
	_arrow.queue_redraw()



func _refresh_hot() -> void :
	var hot: = (is_hovered() or has_focus()) and not disabled
	if hot == _hot:
		return
	_hot = hot
	if _hot_tw != null and _hot_tw.is_valid():
		_hot_tw.kill()
	_hot_tw = create_tween().set_parallel(true)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var k: = 1.0 if hot else 0.0
	_hot_tw.tween_property(self, "scale", Vector2.ONE * (1.0 + 0.01 * k), HOT_DUR)
	_hot_tw.tween_property(_visual, "position:y", -2.0 * k, HOT_DUR)
	_hot_tw.tween_property(_glow_style, "shadow_color:a", 0.16 + 0.18 * k, HOT_DUR)


	_hot_tw.tween_method(_set_hover_amt, _hover_amt, k, HOT_DUR)
	_hot_tw.tween_method(_set_arrow_dx, _arrow_dx, 3.0 * k, HOT_DUR)


func _on_down() -> void :
	if _press_tw != null and _press_tw.is_valid():
		_press_tw.kill()
	_press_tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_press_tw.tween_property(self, "scale", Vector2(0.985, 0.985), PRESS_DUR)


func _on_up() -> void :
	if _press_tw != null and _press_tw.is_valid():
		_press_tw.kill()
	_press_tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_press_tw.tween_property(self, "scale", 
		Vector2.ONE * (1.01 if _hot else 1.0), HOT_DUR)
