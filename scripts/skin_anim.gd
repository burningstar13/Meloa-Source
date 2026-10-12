class_name SkinAnim
extends Node2D





var main = null
var tex: Texture2D = null
var frames: = 1
var columns: = 1
var fps: = 24.0
var size: = 200.0
var loop: = false
var _t: = 0.0

static var _add_mat: CanvasItemMaterial = null


func setup(a: Dictionary, pos: Vector2, k: = 1.0) -> void :
	position = pos
	tex = a.tex
	frames = maxi(int(a.get("frames", 1)), 1)
	columns = clampi(int(a.get("columns", frames)), 1, frames)
	fps = maxf(float(a.get("fps", 24.0)), 1.0)
	size = float(a.get("size", 200.0)) * k
	loop = bool(a.get("loop", false))
	rotation = randf_range(0.0, TAU) if bool(a.get("random_rotation", false)) else 0.0
	if String(a.get("blend", "mix")) == "add":
		if _add_mat == null:
			_add_mat = CanvasItemMaterial.new()
			_add_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		material = _add_mat
	else:
		material = null
	_t = 0.0
	visible = true
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void :
	_t += delta
	if not loop and _t * fps >= float(frames):
		set_process(false)
		if main != null and main.has_method("_release_anim"):
			main._release_anim(self)
		else:
			queue_free()
		return
	queue_redraw()


func _draw() -> void :
	if tex == null:
		return
	var frame: = int(_t * fps) % frames
	var rows: = int(ceil(float(frames) / float(columns)))
	var fw: = tex.get_width() / float(columns)
	var fh: = tex.get_height() / float(rows)
	var region: = Rect2((frame % columns) * fw, (frame / columns) * fh, fw, fh)
	var h: = size * fh / maxf(fw, 1.0)
	draw_texture_rect_region(tex, Rect2( - size * 0.5, - h * 0.5, size, h), region)
