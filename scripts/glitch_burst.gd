extends Node2D




var life: = 0.14
var strength: = 1.0

var _t: = 0.0
var _slices: Array = []


func _ready() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	for i in 3:
		_slices.append([rng.randf_range(-44.0, 44.0), 
			rng.randf_range(34.0, 70.0), rng.randf_range(0.0, TAU)])


func _process(delta: float) -> void :
	_t += delta
	if _t >= life:
		queue_free()
		return
	queue_redraw()


func _draw() -> void :
	var p: = _t / life
	var a: = (1.0 - p) * strength
	var r: = 26.0 + p * 54.0
	var split: = (3.0 + 6.0 * p) * strength


	draw_arc(Vector2( - split, 0), r, 0.0, TAU, 26, Color(1.5, 1.5, 1.45, a * 0.55), 2.5)
	draw_arc(Vector2(split, 0), r, 0.0, TAU, 26, Color(1.5, 1.5, 1.45, a * 0.55), 2.5)
	draw_arc(Vector2.ZERO, r * 0.82, 0.0, TAU, 26, Color(1.75, 1.75, 1.7, a), 2.0)

	for s in _slices:
		var jitter: float = sin(_t * 90.0 + s[2]) * 9.0 * strength
		var w: float = s[1] * (1.0 - p * 0.5)
		draw_rect(Rect2(Vector2( - w + jitter, s[0] - 1.5), Vector2(w * 2.0, 3.0)), 
			Color(1.5, 1.5, 1.45, a * 0.5))
