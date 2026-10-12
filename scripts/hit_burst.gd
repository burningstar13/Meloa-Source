class_name HitBurst
extends Node2D





var color: = Color.WHITE
var count: = 12
var speed: = 320.0
var life: = 0.45

var _pos: PackedVector2Array
var _vel: PackedVector2Array
var _size: PackedFloat32Array
var _t: = 0.0


func _ready() -> void :
	var rng: = RandomNumberGenerator.new()
	rng.randomize()
	_pos.resize(count)
	_vel.resize(count)
	_size.resize(count)
	for i in count:
		var a: = rng.randf_range(0.0, TAU)
		_vel[i] = Vector2(cos(a), sin(a)) * speed * rng.randf_range(0.45, 1.0)
		_size[i] = rng.randf_range(2.0, 4.5)


func _process(delta: float) -> void :
	_t += delta
	if _t >= life:
		queue_free()
		return
	var fric: = maxf(0.0, 1.0 - 2.2 * delta)
	for i in count:
		var v: = _vel[i]
		v.y += 640.0 * delta
		v *= fric
		_vel[i] = v
		_pos[i] += v * delta
	queue_redraw()


func _draw() -> void :
	var a: = 1.0 - _t / life
	var col: = Color(color, a)
	for i in count:
		draw_circle(_pos[i], _size[i] * a, col)
