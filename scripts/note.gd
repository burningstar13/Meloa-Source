class_name Note
extends Node2D




var time: = 0.0
var lane: = 0
var type: = "dodge"
var judged: = false
var glow_tex: Texture2D


var speed: = 1.0



var stack: = 1
var danger: = 0.0

var _song_t: = 0.0

const StageRender = preload("res://scripts/stage_render.gd")



func update_visual(song_time: float, tuning: Tuning) -> void :



	if judged:
		return
	var progress: = 1.0 - (time - song_time) / (tuning.travel_time / speed)
	position.y = lerpf(tuning.spawn_y, tuning.hit_y, progress)
	_song_t = song_time
	queue_redraw()





	modulate.a = clampf(0.4 + 0.7 * progress, 0.0, 1.0)\
	* Mods.mirage_alpha(1.0 - progress)



func resolve(result: String) -> void :
	judged = true
	var tw: = create_tween()
	if result == "PERFECT" or result == "GOOD":

		tw.tween_property(self, "scale", Vector2(1.6, 1.6), 0.08)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.12)
	elif result == "DODGE":

		tw.tween_property(self, "scale", Vector2(2.2, 0.25), 0.1)\
		.set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(self, "modulate:a", 0.0, 0.14)
	else:

		tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)


func _draw() -> void :







	StageRender.lane_note(self, Vector2.ZERO, 1.0, type, _song_t, glow_tex, 
		true, stack, danger)
