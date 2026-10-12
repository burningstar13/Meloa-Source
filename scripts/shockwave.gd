class_name Shockwave
extends Node2D



var color: = Color(0.4, 0.8, 1.0)
var max_radius: = 240.0
var duration: = 0.3

var _t: = 0.0


func _process(delta: float) -> void :
	_t += delta
	if _t >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void :
	var p: = _t / duration
	var eased: = 1.0 - (1.0 - p) * (1.0 - p)
	var r: = 20.0 + eased * (max_radius - 20.0)
	var a: = 1.0 - p
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(color.r, color.g, color.b, a), 2.0 + 8.0 * a)
	draw_arc(Vector2.ZERO, r * 0.8, 0.0, TAU, 40, Color(1, 1, 1, a * 0.4), 2.0)
