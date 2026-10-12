class_name UiIcon
extends Control









@export var kind: = "hex"
var tint: = Color(1, 1, 1, 0.72)

















const ICON_DIR: = "res://assets/icons/"
static var _icon_cache: = {}



static func icon_texture(kind_name: String) -> Texture2D:
	if _icon_cache.has(kind_name):
		return _icon_cache[kind_name]
	var found: Texture2D = null
	for ext in [".png", ".svg", ".webp"]:
		var path: String = ICON_DIR + kind_name + ext
		if ResourceLoader.exists(path):
			found = load(path)
			break
	_icon_cache[kind_name] = found
	return found


func _draw() -> void :
	draw_kind(self, kind, size * 0.5, minf(size.x, size.y), tint)




static func draw_kind(ci: CanvasItem, kind_name: String, c: Vector2, s: float, 
		col: Color, width: = 2.0) -> void :
	var tex: = icon_texture(kind_name)
	if tex != null:

		var ts: = tex.get_size()
		var k: = s / maxf(maxf(ts.x, ts.y), 1.0)
		var d: = ts * k
		ci.draw_texture_rect(tex, Rect2(c - d * 0.5, d), false, col)
		return
	match kind_name:
		"settings":
			ci.draw_arc(c, s * 0.26, 0.0, TAU, 24, col, width, true)
			ci.draw_circle(c, s * 0.09, col)
			for i in 8:
				var a: = TAU * float(i) / 8.0
				var d: = Vector2(cos(a), sin(a))
				ci.draw_line(c + d * s * 0.34, c + d * s * 0.46, col, width, true)
		"stats":
			for i in 3:
				var h: float = s * [0.34, 0.62, 0.48][i]
				var x: = c.x + (i - 1) * s * 0.3 - s * 0.09
				ci.draw_rect(Rect2(x, c.y + s * 0.34 - h, s * 0.18, h), col)
		"account":
			ci.draw_circle(c + Vector2(0, - s * 0.16), s * 0.16, col)
			ci.draw_arc(c + Vector2(0, s * 0.34), s * 0.3, PI + 0.35, TAU - 0.35, 
				16, col, width * 1.2, true)
		"multiplayer":



			_person(ci, c + Vector2(s * 0.2, - s * 0.03), s * 0.52, 
				Color(col.r, col.g, col.b, col.a * 0.5))
			_person(ci, c - Vector2(s * 0.15, 0.0), s * 0.62, col)
		"editor":


			var dir: = Vector2(0.7071, -0.7071)
			var perp: = Vector2(0.7071, 0.7071) * s * 0.105
			var tip: = c - dir * s * 0.4
			var neck: = c - dir * s * 0.2
			var tail: = c + dir * s * 0.36
			ci.draw_colored_polygon(PackedVector2Array([
				neck - perp, tail - perp, tail + perp, neck + perp]), col)
			ci.draw_colored_polygon(PackedVector2Array([
				tip, neck - perp * 1.05, neck + perp * 1.05]), col)
			var band: = c + dir * s * 0.2
			ci.draw_line(band - perp * 1.15, band + perp * 1.15, 
				Color(0, 0, 0, 0.55), width * 1.1, true)
		"play":

			var h2: = s * 0.36
			var w2: = s * 0.27
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, - h2), c + Vector2(w2, 0), 
				c + Vector2(0, h2), c + Vector2( - w2, 0)]), col)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2( - w2 * 0.5, - h2 * 0.5), c + Vector2(0, - h2 * 0.05), 
				c + Vector2(w2 * 0.5, - h2 * 0.5)]), 
				Color(1, 1, 1, col.a * 0.45), width * 0.8, true)
		"media_play":
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2( - s * 0.16, - s * 0.26), 
				c + Vector2(s * 0.3, 0), 
				c + Vector2( - s * 0.16, s * 0.26)]), col)
		"media_pause":
			var bw: = s * 0.11
			ci.draw_rect(Rect2(c.x - s * 0.21, c.y - s * 0.24, bw, s * 0.48), col)
			ci.draw_rect(Rect2(c.x + s * 0.1, c.y - s * 0.24, bw, s * 0.48), col)
		"quit":
			ci.draw_arc(c + Vector2(0, s * 0.04), s * 0.3, - PI * 0.36, 
				PI + PI * 0.36, 24, col, width, true)
			ci.draw_line(c + Vector2(0, - s * 0.34), c + Vector2(0, - s * 0.04), 
				col, width, true)
		"help":

			var hc: = c + Vector2(0, - s * 0.14)
			ci.draw_arc(hc, s * 0.2, - PI * 0.95, PI * 0.42, 20, col, width, true)
			ci.draw_line(c + Vector2(s * 0.06, s * 0.015), 
				c + Vector2(0, s * 0.16), col, width, true)
			ci.draw_circle(c + Vector2(0, s * 0.36), width * 0.95, col)
		"hex":
			var pts: = PackedVector2Array()
			for i in 7:
				var a: = TAU * float(i) / 6.0 - PI * 0.5
				pts.append(c + Vector2(cos(a), sin(a)) * s * 0.38)
			ci.draw_polyline(pts, col, width, true)


		"globe":
			ci.draw_arc(c, s * 0.36, 0.0, TAU, 32, col, width, true)
			ci.draw_line(c + Vector2( - s * 0.36, 0), c + Vector2(s * 0.36, 0), col, width * 0.8, true)
			ci.draw_line(c + Vector2(0, - s * 0.36), c + Vector2(0, s * 0.36), col, width * 0.8, true)

			var pts: = PackedVector2Array()
			for i in 25:
				var a: = TAU * float(i) / 24.0
				pts.append(c + Vector2(cos(a) * s * 0.16, sin(a) * s * 0.36))
			ci.draw_polyline(pts, col, width * 0.8, true)
			ci.draw_line(c + Vector2( - s * 0.3, - s * 0.16), c + Vector2(s * 0.3, - s * 0.16), 
				Color(col, col.a * 0.6), width * 0.7, true)
			ci.draw_line(c + Vector2( - s * 0.3, s * 0.16), c + Vector2(s * 0.3, s * 0.16), 
				Color(col, col.a * 0.6), width * 0.7, true)
		"download":

			ci.draw_line(c + Vector2(0, - s * 0.36), c + Vector2(0, s * 0.12), col, width, true)
			ci.draw_line(c + Vector2( - s * 0.2, - s * 0.08), c + Vector2(0, s * 0.12), col, width, true)
			ci.draw_line(c + Vector2(s * 0.2, - s * 0.08), c + Vector2(0, s * 0.12), col, width, true)
			ci.draw_line(c + Vector2( - s * 0.32, s * 0.32), c + Vector2(s * 0.32, s * 0.32), col, width, true)
			ci.draw_line(c + Vector2( - s * 0.32, s * 0.18), c + Vector2( - s * 0.32, s * 0.32), col, width, true)
			ci.draw_line(c + Vector2(s * 0.32, s * 0.18), c + Vector2(s * 0.32, s * 0.32), col, width, true)
		"refresh":



			var r: = s * 0.3
			var a_end: = - PI * 0.44
			var a_start: = a_end - TAU * 0.8
			ci.draw_arc(c, r, a_start, a_end, 28, col, width * 1.1, true)
			var tip_base: = c + Vector2(cos(a_end), sin(a_end)) * r
			var tang: = Vector2( - sin(a_end), cos(a_end))
			var nrm: = Vector2(cos(a_end), sin(a_end))
			ci.draw_colored_polygon(PackedVector2Array([
				tip_base + tang * s * 0.17, 
				tip_base - tang * s * 0.04 + nrm * s * 0.15, 
				tip_base - tang * s * 0.04 - nrm * s * 0.15]), col)
		"close":
			ci.draw_line(c + Vector2( - s * 0.28, - s * 0.28), c + Vector2(s * 0.28, s * 0.28), col, width, true)
			ci.draw_line(c + Vector2(s * 0.28, - s * 0.28), c + Vector2( - s * 0.28, s * 0.28), col, width, true)
		"dots":
			for i in 3:
				ci.draw_circle(c + Vector2(0, (i - 1) * s * 0.26), s * 0.075, col)
		"search":
			ci.draw_arc(c + Vector2( - s * 0.06, - s * 0.06), s * 0.24, 0.0, TAU, 24, col, width, true)
			ci.draw_line(c + Vector2(s * 0.11, s * 0.11), c + Vector2(s * 0.32, s * 0.32), col, width * 1.2, true)
		"check":
			ci.draw_line(c + Vector2( - s * 0.3, 0.0), c + Vector2( - s * 0.08, s * 0.22), col, width, true)
			ci.draw_line(c + Vector2( - s * 0.08, s * 0.22), c + Vector2(s * 0.32, - s * 0.22), col, width, true)
		"chevron":
			ci.draw_line(c + Vector2( - s * 0.22, - s * 0.1), c + Vector2(0.0, s * 0.12), col, width, true)
			ci.draw_line(c + Vector2(0.0, s * 0.12), c + Vector2(s * 0.22, - s * 0.1), col, width, true)
		"warning":
			var tri: = PackedVector2Array([c + Vector2(0, - s * 0.34), 
				c + Vector2(s * 0.36, s * 0.3), c + Vector2( - s * 0.36, s * 0.3), c + Vector2(0, - s * 0.34)])
			ci.draw_polyline(tri, col, width, true)
			ci.draw_line(c + Vector2(0, - s * 0.1), c + Vector2(0, s * 0.1), col, width, true)
			ci.draw_circle(c + Vector2(0, s * 0.2), width * 0.8, col)




static func _person(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void :
	ci.draw_circle(c + Vector2(0, - s * 0.3), s * 0.26, col)
	var pts: = PackedVector2Array()
	var bc: = c + Vector2(0, s * 0.46)
	for i in 15:
		var a: = PI + PI * float(i) / 14.0
		pts.append(bc + Vector2(cos(a) * s * 0.44, sin(a) * s * 0.42))
	ci.draw_colored_polygon(pts, col)
