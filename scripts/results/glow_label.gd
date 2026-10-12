class_name GlowLabel
extends Control






var text: = "":
	set(v):
		if text == v:
			return
		text = v
		update_minimum_size()
		queue_redraw()
var font: Font = null:
	set(v):
		font = v
		update_minimum_size()
		queue_redraw()
var font_size: = 32:
	set(v):
		font_size = v
		update_minimum_size()
		queue_redraw()
var color: = Color.WHITE:
	set(v):
		color = v
		queue_redraw()

var glow_color: = Color(0, 0, 0, 0)
var glow_strength: = 1.0:
	set(v):
		glow_strength = v
		queue_redraw()
var align: = HORIZONTAL_ALIGNMENT_LEFT
var valign: = VERTICAL_ALIGNMENT_CENTER




const PASSES: = [[2.5, 0.09], [5.5, 0.075], [10.0, 0.055], [16.0, 0.035], [24.0, 0.02]]


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _get_minimum_size() -> Vector2:
	if font == null or text == "":
		return Vector2(0, font_size * 1.2 if font != null else 0.0)
	return Vector2(font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x, 
		font.get_height(font_size))


func _draw() -> void :
	if font == null or text == "":
		return
	var w: = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var asc: = font.get_ascent(font_size)
	var desc: = font.get_descent(font_size)
	var x: = 0.0
	match align:
		HORIZONTAL_ALIGNMENT_CENTER:
			x = (size.x - w) * 0.5
		HORIZONTAL_ALIGNMENT_RIGHT:
			x = size.x - w
	var y: = asc
	match valign:
		VERTICAL_ALIGNMENT_CENTER:
			y = (size.y - (asc + desc)) * 0.5 + asc
		VERTICAL_ALIGNMENT_BOTTOM:
			y = size.y - desc
	var pos: = Vector2(x, y)
	var gc: = glow_color if glow_color.a > 0.0 else color
	if glow_strength > 0.001:


		var k: = font_size / 64.0
		for i in range(PASSES.size() - 1, -1, -1):
			var p: Array = PASSES[i]
			draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 
				int(ceil(float(p[0]) * k)), Color(gc.r, gc.g, gc.b, float(p[1]) * glow_strength))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
