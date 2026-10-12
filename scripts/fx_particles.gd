extends RefCounted














const KINDS: = ["rain", "snow", "embers", "stars", "bubbles", "petals", "dust"]
const BASE_N: = 140
const MAX_N: = 420



const DEFAULTS: = {
	"rain": {"color": Color(0.7, 0.85, 1.0, 0.55), "speed": 900.0, "dir": 97.0, "size": 1.0}, 
	"snow": {"color": Color(1.0, 1.0, 1.0, 0.85), "speed": 55.0, "dir": 90.0, "size": 2.4}, 
	"embers": {"color": Color(1.0, 0.62, 0.22, 0.9), "speed": 85.0, "dir": 272.0, "size": 2.2}, 
	"stars": {"color": Color(1.0, 1.0, 0.92, 0.9), "speed": 0.0, "dir": 0.0, "size": 1.6}, 
	"bubbles": {"color": Color(0.7, 0.95, 1.0, 0.55), "speed": 70.0, "dir": 270.0, "size": 5.0}, 
	"petals": {"color": Color(1.0, 0.72, 0.85, 0.85), "speed": 75.0, "dir": 82.0, "size": 5.0}, 
	"dust": {"color": Color(1.0, 1.0, 1.0, 0.3), "speed": 22.0, "dir": 0.0, "size": 1.5}, 
}


static func _h(n: float) -> float:
	return fposmod(sin(n * 12.9898 + 78.233) * 43758.5453, 1.0)



static func settings(params: Dictionary) -> Dictionary:
	var kind: = String(params.get("kind", "snow"))
	if not KINDS.has(kind):
		kind = "snow"
	var d: Dictionary = DEFAULTS[kind]
	var col: Color = d.color
	var cs: = String(params.get("color", ""))
	if cs != "":
		var parsed: = Color.from_string(cs, col)
		parsed.a = col.a if parsed.a >= 0.999 else parsed.a
		col = parsed
	var dir: = float(params.get("dir", -1.0))
	if dir < 0.0:
		dir = float(d.dir)
	return {
		"kind": kind, "color": col, 
		"density": clampf(float(params.get("density", 1.0)), 0.0, 3.0), 
		"speed": float(d.speed) * clampf(float(params.get("speed", 1.0)), 0.0, 5.0), 
		"size": float(d.size) * clampf(float(params.get("size", 1.0)), 0.2, 5.0), 
		"dir": dir, 
	}





static func draw(c: CanvasItem, rect: Rect2, t: float, st: Dictionary, 
		amt: float, k: = 1.0, seed: = 0) -> void :
	var n: = int(minf(BASE_N * amt * float(st.density), MAX_N))
	if n <= 0:
		return
	var kind: = String(st.kind)
	var col: Color = st.color
	var spd: = float(st.speed) * k
	var dirv: = Vector2(cos(deg_to_rad(float(st.dir))), sin(deg_to_rad(float(st.dir))))
	var sz: = float(st.size) * k
	var w: = rect.size.x
	var h: = rect.size.y
	var margin: = 24.0 * k
	for i in n:
		var fi: = float(i + seed * 1000)
		var h1: = _h(fi * 1.31)
		var h2: = _h(fi * 2.17 + 3.0)
		var h3: = _h(fi * 3.71 + 7.0)
		var h4: = _h(fi * 5.13 + 11.0)

		var v: = spd * (0.6 + 0.8 * h3)
		var base: = Vector2(h1 * (w + 2.0 * margin) - margin, h2 * (h + 2.0 * margin) - margin)
		var p: = base + dirv * v * t

		var sway: = 0.0
		if kind in ["snow", "petals", "bubbles"]:
			sway = sin(t * (0.8 + h4 * 1.4) + h1 * TAU) * (18.0 if kind == "snow" else 30.0) * k
		elif kind == "embers":
			sway = sin(t * (2.0 + h4 * 2.0) + h1 * TAU) * 8.0 * k
		elif kind == "dust":
			sway = sin(t * 0.5 + h1 * TAU) * 40.0 * k
		p += Vector2( - dirv.y, dirv.x) * sway

		p.x = fposmod(p.x + margin, w + 2.0 * margin) - margin
		p.y = fposmod(p.y + margin, h + 2.0 * margin) - margin
		p += rect.position
		var depth: = 0.5 + 0.5 * h3
		var a: = col.a * depth
		match kind:
			"rain":
				var tail: = dirv * (14.0 + 22.0 * depth) * k
				c.draw_line(p, p - tail, Color(col.r, col.g, col.b, a * 0.8), maxf(1.0, sz * depth))
			"snow":
				c.draw_circle(p, sz * (0.5 + depth * 0.8), Color(col.r, col.g, col.b, a))
			"embers":
				var fl: = 0.55 + 0.45 * sin(t * (6.0 + h2 * 9.0) + h4 * TAU)
				var r: = sz * (0.5 + depth * 0.9)
				c.draw_circle(p, r * 2.4, Color(col.r, col.g, col.b, a * 0.18 * fl))
				c.draw_circle(p, r, Color(minf(col.r * 1.3, 1.5), col.g, col.b, a * fl))
			"stars":
				var tw: = 0.35 + 0.65 * pow(0.5 + 0.5 * sin(t * (1.2 + h2 * 3.0) + h4 * TAU), 3.0)
				var r: = sz * (0.6 + depth * 0.8) * tw
				c.draw_circle(p, r, Color(col.r, col.g, col.b, a * tw))
				if tw > 0.8:
					var s: = r * 3.2
					c.draw_line(p - Vector2(s, 0), p + Vector2(s, 0), Color(col.r, col.g, col.b, a * 0.35 * tw), 1.0)
					c.draw_line(p - Vector2(0, s), p + Vector2(0, s), Color(col.r, col.g, col.b, a * 0.35 * tw), 1.0)
			"bubbles":
				var r: = sz * (0.4 + depth * 0.9)
				c.draw_arc(p, r, 0.0, TAU, 14, Color(col.r, col.g, col.b, a * 0.9), maxf(1.0, k))
				c.draw_circle(p + Vector2( - r * 0.35, - r * 0.35), r * 0.22, Color(1, 1, 1, a * 0.8))
			"petals":
				var rot: = t * (1.5 + h4 * 2.5) + h1 * TAU
				var r: = sz * (0.5 + depth * 0.8)
				var pts: = PackedVector2Array()
				for j in 8:
					var ang: = float(j) / 8.0 * TAU
					var rr: = r * (1.0 if j % 2 == 0 else 0.55)
					pts.append(p + Vector2(cos(ang + rot) * rr * 1.3, sin(ang + rot) * rr))
				c.draw_colored_polygon(pts, Color(col.r, col.g, col.b, a))
			_:
				c.draw_circle(p, sz * (0.4 + depth * 0.8), Color(col.r, col.g, col.b, a))
