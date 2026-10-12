class_name BreakScreen
extends Node2D











var font: Font = null
var glow_tex: Texture2D = null
var alpha: = 0.0
var col: = Color(0.71, 0.55, 1.0)
var remaining: = 0.0
var duration: = 1.0
var show_timer: = true


func _process(_delta: float) -> void :
	if visible:
		queue_redraw()




static func _spaced(s: String) -> String:
	var out: = ""
	for c in s:
		out += c + " "
	return out.strip_edges()


func _draw() -> void :
	if alpha <= 0.01:
		return
	var vs: = get_viewport_rect().size
	var c: = Vector2(vs.x * 0.5, vs.y * 0.44)
	var fnt: = font if font != null else ThemeDB.fallback_font

	if glow_tex != null:
		var gs: = vs.y * 1.6
		draw_texture_rect(glow_tex, Rect2(c - Vector2(gs, gs) * 0.5, 
			Vector2(gs, gs)), false, Color(0, 0, 0, 0.55 * alpha))
		var hs: = vs.y * 0.9
		draw_texture_rect(glow_tex, Rect2(c - Vector2(hs, hs) * 0.5, 
			Vector2(hs, hs)), false, Color(col.r, col.g, col.b, 0.07 * alpha))
	if not show_timer:
		return

	var secs: = maxi(int(ceil(remaining)), 0)
	var txt: = _spaced("%d:%02d" % [secs / 60, secs % 60])
	var sz: = fnt.get_string_size(txt, HORIZONTAL_ALIGNMENT_CENTER, -1, 62)
	draw_string(fnt, Vector2(c.x - sz.x * 0.5, c.y), txt, 
		HORIZONTAL_ALIGNMENT_CENTER, -1, 62, 
		Color(col.r * 1.25, col.g * 1.25, col.b * 1.25, 0.92 * alpha))

	var w: = 190.0
	var u: = clampf(remaining / maxf(duration, 0.001), 0.0, 1.0)
	var gy: = c.y + 26.0
	draw_line(Vector2(c.x - w, gy), Vector2(c.x + w, gy), 
		Color(1, 1, 1, 0.1 * alpha), 1.0)
	if u > 0.001:
		draw_line(Vector2(c.x - w, gy), Vector2(c.x - w + w * 2.0 * u, gy), 
			Color(col.r * 1.2, col.g * 1.2, col.b * 1.2, 0.75 * alpha), 1.6)
