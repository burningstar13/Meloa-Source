class_name ClickPop
extends Node2D








var strength: = 1.0
var life: = 0.38

var _t: = 0.0
var _rot: = 0.0
var _shards: Array = []


func _ready() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	_rot = rng.randf_range(0.0, TAU)
	var n: = 7
	for i in n:
		_shards.append([
			_rot + float(i) * TAU / n + rng.randf_range(-0.18, 0.18), 
			rng.randf_range(66.0, 104.0) * strength, 
			rng.randf_range(26.0, 44.0), 
		])


func _process(delta: float) -> void :
	_t += delta
	if _t >= life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void :
	var p: = _t / life
	var fade: = 1.0 - p
	var ring_a: = pow(fade, 0.7)


	var gold: Color = Skins.col("gold") * 1.35
	gold.a = 1.0







	var e1: = 1.0 - exp(-5.5 * p)
	draw_arc(Vector2.ZERO, 30.0 + 95.0 * strength * e1, 0.0, TAU, 48, 
		Color(1.35, 1.34, 1.28, ring_a * 0.55), 1.6)
	var e2: = 1.0 - exp(-3.8 * p)
	var r2: = 26.0 + 70.0 * strength * e2
	draw_arc(Vector2.ZERO, r2, 0.0, TAU, 48, 
		Color(gold.r, gold.g, gold.b, ring_a * 0.85), 4.0 - 2.0 * p)


	for k in 3:
		var a0: = _rot + float(k) * TAU / 3.0 + p * 1.7
		draw_arc(Vector2.ZERO, r2 * 0.78, a0, a0 + 0.06 + TAU * 0.15 * fade, 12, 
			Color(gold.r * 1.1, gold.g * 1.17, gold.b * 1.4, ring_a), 2.2)


	for s in _shards:
		var reach: float = 24.0 + s[1] * (1.0 - exp(-5.0 * p))
		var u: = Vector2.from_angle(s[0])
		draw_line(u * maxf(reach - s[2] * (0.35 + 0.65 * fade), 14.0), u * reach, 
			Color(1.65, 1.5, 1.1, pow(fade, 0.8)), 2.5)


	if p < 0.25:
		var g: = 1.0 - p / 0.25
		var gl: = (36.0 + 34.0 * (1.0 - g)) * strength
		draw_line(Vector2( - gl, 0), Vector2(gl, 0), Color(1.8, 1.8, 1.7, g * 0.85), 1.5)
		draw_line(Vector2(0, - gl), Vector2(0, gl), Color(1.8, 1.8, 1.7, g * 0.85), 1.5)
