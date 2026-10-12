class_name SliderBody
extends Node2D









const StageRender = preload("res://scripts/stage_render.gd")

var geom: Dictionary = {}
var legacy: = false
var mesh_rim: Array = []
var mesh_core: Array = []
var body_pts: = PackedVector2Array()
var hw: = 58.0
var rim_w: = 6.0
var glow_tex: Texture2D = null
var discs: = -1
var cap: = Vector2.ZERO
var has_cap: = false
var first_ahead: = 0

var alpha: = 0.0
var dim: = 0.0
var broken: = false
var _drawn: = Vector3(-1.0, -1.0, -1.0)
var _drawn_discs: = -2


func setup_flat(g: Dictionary) -> void :
	legacy = false
	geom = g
	queue_redraw()


func setup_legacy(rim: Array, core: Array, pts: PackedVector2Array, half_w: float, 
		rim_width: float, glow: Texture2D) -> void :
	legacy = true
	mesh_rim = rim
	mesh_core = core
	body_pts = pts
	hw = half_w
	rim_w = rim_width
	glow_tex = glow
	queue_redraw()



func set_cut(n_discs: int, cap_pos: Vector2, cap_on: bool, ahead: int) -> void :
	if n_discs == _drawn_discs and cap_pos.is_equal_approx(cap) and cap_on == has_cap:
		return
	discs = n_discs
	cap = cap_pos
	has_cap = cap_on
	first_ahead = ahead
	_drawn_discs = n_discs
	queue_redraw()


func set_state(a: float, d: float, b: bool) -> void :
	var v: = Vector3(a, d, 1.0 if b else 0.0)
	if v.is_equal_approx(_drawn):
		return
	alpha = a
	dim = d
	broken = b
	_drawn = v
	queue_redraw()


func reset() -> void :
	geom = {}
	legacy = false
	mesh_rim = []
	mesh_core = []
	body_pts = PackedVector2Array()
	glow_tex = null
	discs = -1
	has_cap = false
	first_ahead = 0
	alpha = 0.0
	dim = 0.0
	broken = false
	_drawn = Vector3(-1.0, -1.0, -1.0)
	_drawn_discs = -2
	visible = true
	queue_redraw()


func _draw() -> void :
	if alpha <= 0.001:
		return
	var q: = SettingsManager.gfx_k(SettingsManager.gfx_slider)
	if legacy:
		if mesh_rim.is_empty():
			return
		var a: = alpha * (0.45 if broken else 1.0)
		StageRender.slider_body_legacy_draw(self, mesh_rim, mesh_core, discs, cap, has_cap, 
			hw, rim_w, a, body_pts, first_ahead, glow_tex, q)
		return
	if geom.is_empty():
		return
	StageRender.slider_body_draw(self, geom, 1.0, alpha, dim, broken, q)
