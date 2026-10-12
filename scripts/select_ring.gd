class_name SelectRing
extends Control









@export var radius: = 150.0
@export var subtle: = false


var accent: = Color(0.72, 0.45, 1.0)

var _spin: = 0.0

const CYAN: = Color(0.45, 0.82, 1.0)
const VIOLET: = Color(0.72, 0.45, 1.0)
const PINK: = Color(0.95, 0.35, 0.8)


func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	_spin += delta
	queue_redraw()




func _ring_col(a: float) -> Color:
	var u: = fposmod(a / TAU, 1.0)
	if u < 0.25:
		return CYAN.lerp(VIOLET, u / 0.25)
	if u < 0.5:
		return VIOLET.lerp(PINK, (u - 0.25) / 0.25)
	if u < 0.75:
		return PINK.lerp(accent, (u - 0.5) / 0.25)
	return accent.lerp(CYAN, (u - 0.75) / 0.25)


func _draw() -> void :
	var c: = size * 0.5
	var breath: = 0.5 + 0.5 * sin(_spin * 1.4)


	var ghost_alpha: = 0.05 if subtle else 0.08
	draw_arc(c, radius * 1.3, 0.0, TAU, 96, Color(1, 1, 1, ghost_alpha), 1.0, true)
	draw_arc(c, radius * 1.62, 0.0, TAU, 96, Color(1, 1, 1, ghost_alpha * 0.6), 1.0, true)
	if subtle:
		draw_arc(c, radius * 0.72, 0.0, TAU, 80, Color(1, 1, 1, ghost_alpha), 1.0, true)


	if not subtle:
		var rb: = radius * 1.46
		for i in 60:
			var a: = TAU * float(i) / 60.0
			var dirv: = Vector2(cos(a), sin(a))
			var long_tick: = i % 5 == 0
			var l: = 9.0 if long_tick else 4.0
			var al: = 0.16 if long_tick else 0.08
			draw_line(c + dirv * rb, c + dirv * (rb + l), Color(1, 1, 1, al), 1.0, true)


	var rd: = radius * 1.3
	for i in 48:
		var a: = TAU * float(i) / 48.0 + 0.02 * sin(_spin * 0.3)
		draw_circle(c + Vector2(cos(a), sin(a)) * rd, 1.4, Color(1, 1, 1, 0.13))



	if not subtle:
		const SEGS: = 72
		for i in SEGS:
			var a0: = TAU * float(i) / SEGS
			var a1: = TAU * float(i + 1) / SEGS + 0.004
			var col: = _ring_col(a0 + _spin * 0.22)
			draw_arc(c, radius, a0, a1, 4, 
				Color(col.r, col.g, col.b, 0.1 + 0.05 * breath), 16.0, true)
			draw_arc(c, radius, a0, a1, 4, 
				Color(col.r, col.g, col.b, 0.3), 7.0, true)
			draw_arc(c, radius, a0, a1, 4, col * 1.15, 2.6, true)


	var sats: = [
		[radius * 1.3, 0.35, 2.6, CYAN], 
		[radius * 1.3, -0.21, 2.0, Color.WHITE], 
		[radius * 1.62, 0.13, 2.2, VIOLET], 
	] if not subtle else [
		[radius * 1.3, 0.18, 2.0, CYAN], 
		[radius * 0.72, -0.11, 1.7, VIOLET], 
	]
	for s in sats:
		var a: float = _spin * float(s[1]) + hash(s[3]) % 7
		var p: Vector2 = c + Vector2(cos(a), sin(a)) * float(s[0])
		var col: Color = s[3]
		draw_circle(p, float(s[2]) * 2.6, Color(col.r, col.g, col.b, 0.1))
		draw_circle(p, float(s[2]), Color(col.r, col.g, col.b, 0.85))
