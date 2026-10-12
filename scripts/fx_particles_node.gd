extends Node2D




var main
var song_t: = 0.0


func _draw() -> void :
	if main == null or main.fx_particles.is_empty():
		return
	var p: Dictionary = main.fx_particles
	preload("res://scripts/fx_particles.gd").draw(self, 
		Rect2(Vector2.ZERO, get_viewport_rect().size), song_t, p.st, float(p.amt))
