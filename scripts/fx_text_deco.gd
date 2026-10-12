class_name FxTextDeco
extends Node2D






var items: Array = []


static func _h(n: float) -> float:
	return fposmod(sin(n * 12.9898) * 43758.5453, 1.0)


var _was_empty: = true

func _process(_delta: float) -> void :


	var empty: = items.is_empty()
	if empty and _was_empty:
		return
	_was_empty = empty
	queue_redraw()


func _draw() -> void :
	for it in items:
		var r: Rect2 = it.rect
		var ca: Color = it.col_a
		var cb: Color = it.col_b
		var u: float = it.u
		var seed: float = it.seed

		var grow: float = clampf(u / 0.18, 0.0, 1.0)
		grow = grow * grow * (3.0 - 2.0 * grow)
		var a: float = clampf(minf(u / 0.1, (1.0 - u) / 0.18), 0.0, 1.0)
		if a <= 0.01 or grow <= 0.01:
			continue


		var kick: = 1.0 + 0.25 * clampf(1.0 - absf(u - 0.2) / 0.12, 0.0, 1.0)
		for side in 2:
			var s: = -1.0 if side == 0 else 1.0
			var cc: Color = ca if side == 0 else cb
			cc.a = a * 0.9
			var anchor: = Vector2(r.position.x if side == 0 else r.end.x, 
				r.position.y + r.size.y * 0.5)
			for j in 3:
				var ang: = (-0.55 + 0.55 * float(j)) * 0.9
				var dir: = Vector2(s * cos(ang), sin(ang) - 0.35)
				var base: = 10.0 + 4.0 * float(j)
				var start: = anchor + dir * base
				var tip: = anchor + dir * (base + (16.0 + 6.0 * float(j)) * grow * kick)
				draw_line(start, tip, cc, 3.0)

				var perp: = Vector2( - dir.y, dir.x) * 4.0
				draw_line(start + perp, tip + perp, 
					Color(cc.r, cc.g, cc.b, cc.a * 0.35), 1.5)


		var count: = 3 + int(r.size.x / 120.0)
		for k in count:
			var h1: = _h(seed + float(k) * 3.17)
			var h2: = _h(seed + float(k) * 7.71)
			var px: = r.position.x + r.size.x * (0.02 + 0.96 * h1)
			var above: = k % 2 == 0
			var py: = (r.position.y - 12.0 - 28.0 * h2) if above\
			else (r.end.y + 6.0 + 20.0 * h2)
			var tw: = 0.55 + 0.45 * sin(u * TAU * (2.0 + 2.0 * h1) + h2 * TAU)
			var sr: = (3.0 + 4.0 * h2) * grow * tw
			var cc2: = ca.lerp(cb, h1).lerp(Color.WHITE, 0.35)
			cc2.a = a * (0.35 + 0.55 * tw)
			_star(Vector2(px, py), sr, cc2)
		if bool(it.get("ring", false)):
			_ring(r, ca, cb, u, a)



func _star(c: Vector2, s: float, col: Color) -> void :
	if s < 0.6:
		return
	var w: = s * 0.32
	draw_colored_polygon(PackedVector2Array([
		Vector2(c.x, c.y - s), Vector2(c.x + w, c.y), 
		Vector2(c.x, c.y + s), Vector2(c.x - w, c.y), 
	]), col)
	draw_colored_polygon(PackedVector2Array([
		Vector2(c.x - s, c.y), Vector2(c.x, c.y - w), 
		Vector2(c.x + s, c.y), Vector2(c.x, c.y + w), 
	]), col)




func _ring(r: Rect2, ca: Color, cb: Color, u: float, a: float) -> void :
	var ring_a: = a * clampf((u - 0.08) / 0.1, 0.0, 1.0)
	if ring_a <= 0.01:
		return
	var c: = r.get_center()
	var rx: = r.size.x * 0.72 + 26.0
	var ry: = maxf(r.size.y * 0.85, 30.0)
	var tilt: = -0.16
	var head: = - PI * 0.7 + u * TAU * 1.15
	var segs: = 26
	var span: = PI * 1.25
	for i in segs:
		var f0: = float(i) / float(segs)
		var a0: = head - span * f0
		var a1: = head - span * (float(i + 1) / float(segs))
		var p0: = c + Vector2(cos(a0) * rx, sin(a0) * ry).rotated(tilt)
		var p1: = c + Vector2(cos(a1) * rx, sin(a1) * ry).rotated(tilt)
		var fade: = 1.0 - f0
		var cc: = ca.lerp(cb, f0)
		cc.a = ring_a * fade * fade * 0.85
		draw_line(p0, p1, cc, 0.5 + 2.5 * fade)
	var head_p: = c + Vector2(cos(head) * rx, sin(head) * ry).rotated(tilt)
	_star(head_p, 5.0, Color(1, 1, 1, ring_a * 0.9))
