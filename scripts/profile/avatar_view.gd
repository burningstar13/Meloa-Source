class_name AvatarView
extends Control








const FRAME_SCALE: = 1.3

var avatar_id: = ""
var frame_id: = ""
var initial: = ""
var show_frame: = false
var show_online: = false
var online: = false
var ring_color: = Color(0, 0, 0, 0)

var dim: = 0.0
var frame_alpha: = 1.0
var _hue_col: = Color(0.55, 0.32, 1.0)


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_identity(a_id: String, f_id: String, uname: String) -> void :
	avatar_id = a_id
	frame_id = f_id
	initial = uname.substr(0, 1).to_upper() if uname != "" else ""
	_hue_col = color_for(uname)
	queue_redraw()


static func color_for(uname: String) -> Color:
	if uname == "":
		return Color(0.55, 0.32, 1.0)
	var h: = float(absi(uname.hash()) % 360) / 360.0
	return Color.from_hsv(h, 0.5, 0.95)


func disc_radius() -> float:
	return minf(size.x, size.y) * 0.5


func _draw() -> void :
	var c: = size * 0.5
	var r: = disc_radius()
	if r <= 1.0:
		return
	var tex: = ProfileTheme.avatar_tex(avatar_id)
	var tint: = Color(1, 1, 1, 1).darkened(dim)
	if tex != null:
		var pts: = PackedVector2Array()
		var uvs: = PackedVector2Array()
		var cols: = PackedColorArray()
		var n: = 40
		for i in n:
			var a: = TAU * float(i) / float(n)
			pts.append(c + Vector2(cos(a), sin(a)) * r)
			uvs.append(Vector2(0.5 + cos(a) * 0.5, 0.5 + sin(a) * 0.5))
			cols.append(tint)
		draw_polygon(pts, cols, uvs, tex)
	else:
		draw_circle(c, r, Color(_hue_col, 0.28).darkened(dim))
		if initial != "":
			var f: = ProfileTheme.font(700)
			var fs: = int(r * 0.95)
			var s: = f.get_string_size(initial, HORIZONTAL_ALIGNMENT_LEFT, -1, fs)
			draw_string(f, c + Vector2( - s.x * 0.5, s.y * 0.35), initial, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, fs, _hue_col.lerp(Color.WHITE, 0.45).darkened(dim))
		else:
			draw_circle(c + Vector2(0, - r * 0.2), r * 0.3, Color(1, 1, 1, 0.45))
			draw_circle(c + Vector2(0, r * 0.62), r * 0.55, Color(1, 1, 1, 0.35))
	if ring_color.a > 0.0:
		draw_arc(c, r - 1.0, 0.0, TAU, 48, ring_color, 2.0, true)
	if show_frame:
		var ft: = ProfileTheme.frame_tex(frame_id)
		if ft != null:
			var fr: = r * FRAME_SCALE
			draw_texture_rect(ft, Rect2(c - Vector2(fr, fr), Vector2(fr, fr) * 2.0), false, 
				Color(1, 1, 1, frame_alpha))
