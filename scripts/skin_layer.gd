class_name SkinLayer
extends Node2D







var front: = true
var main = null
var _t: = 0.0
var _had: = false


func _process(delta: float) -> void :
	_t += delta
	var items: Array = Skins.foregrounds(front)
	if items.is_empty():
		if _had:
			_had = false
			queue_redraw()
		return
	_had = true
	queue_redraw()


func _draw() -> void :
	var items: Array = Skins.foregrounds(front)
	if items.is_empty():
		return
	var vs: = get_viewport_rect().size
	var beat: float = main.beat_pulse() if main != null else 0.0
	for it in items:
		var tex: Texture2D = it.tex
		if tex == null:
			continue
		var frames: int = maxi(int(it.get("frames", 1)), 1)
		var columns: int = clampi(int(it.get("columns", frames)), 1, frames)
		var rows: int = int(ceil(float(frames) / float(columns)))
		var fw: = tex.get_width() / float(columns)
		var fh: = tex.get_height() / float(rows)
		var frame: = 0
		if frames > 1:
			frame = int(_t * float(it.get("fps", 12.0))) % frames
		var region: = Rect2((frame % columns) * fw, (frame / columns) * fh, fw, fh)
		var h: float = vs.y * float(it.get("scale", 0.5))
		h *= 1.0 + float(it.get("beat_bounce", 0.0)) * beat
		var w: = h * fw / maxf(fh, 1.0)
		var px: float = vs.x * float(it.get("x", 0.5))
		var py: float = vs.y * float(it.get("y", 1.0))
		var anchor: = String(it.get("anchor", "bottom"))
		var origin: = Vector2(px - w * 0.5, py - h)
		match anchor:
			"center":
				origin = Vector2(px - w * 0.5, py - h * 0.5)
			"top":
				origin = Vector2(px - w * 0.5, py)
			"bottom_left":
				origin = Vector2(px, py - h)
			"bottom_right":
				origin = Vector2(px - w, py - h)
		draw_texture_rect_region(tex, Rect2(origin, Vector2(w, h)), region, 
			Color(1, 1, 1, float(it.get("opacity", 1.0))))
