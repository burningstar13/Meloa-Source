class_name Player
extends Node2D





const RADIUS: = 22.0


var lane: = 1
var lane_positions: Array = [0.0, 0.0, 0.0]
var flash_duration: = 0.18
var glow_tex: Texture2D
var fever: = 0.0

var _flash: = 0.0



func move(dir: int) -> void :
	set_lane(lane + dir)




func set_lane(i: int) -> void :
	var new_lane: = clampi(i, 0, 2)
	if new_lane == lane:
		return
	lane = new_lane
	position.x = lane_positions[lane]
	queue_redraw()



func flash() -> void :
	_flash = 1.0
	queue_redraw()


func reset() -> void :
	_flash = 0.0
	set_lane(1)
	position.x = lane_positions[1]
	queue_redraw()


func _process(delta: float) -> void :

	var dirty: = false
	if _flash > 0.0:
		_flash = maxf(0.0, _flash - delta / flash_duration)
		dirty = true
	if fever > 0.01:
		dirty = true
	if dirty:
		queue_redraw()


func _draw() -> void :

	if _flash > 0.0:
		var r: = RADIUS + 6.0 + 18.0 * (1.0 - _flash)
		draw_circle(Vector2.ZERO, r, Color(1.4, 1.4, 1.4, _flash * 0.5))

	var body: = Skins.col("player").lerp(Skins.col("player_hot"), fever * 0.85)

	var ptx: Texture2D = Skins.tex("player")
	if ptx != null:
		var ps: = 64.0 + 10.0 * _flash
		draw_texture_rect(ptx, Rect2(Vector2( - ps * 0.5, - ps * 0.5), Vector2(ps, ps)), false, 
			Color(body.r, body.g, body.b, 1.0))

	if glow_tex != null:
		var gs: = 170.0 + 70.0 * _flash + 55.0 * fever
		draw_texture_rect(glow_tex, Rect2(Vector2( - gs * 0.5, - gs * 0.5), 
			Vector2(gs, gs)), false, 
			Color(body.r, body.g, body.b, 0.3 + 0.25 * _flash + 0.14 * fever))
