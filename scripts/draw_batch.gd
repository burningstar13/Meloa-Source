extends RefCounted



















static var _UV: = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), 
	Vector2(1, 1), Vector2(0, 1)])












static func dots(ci: CanvasItem, pos: PackedVector2Array, 
		rad: PackedFloat32Array, col: PackedColorArray, 
		tex: Texture2D = null) -> void :
	var n: = pos.size()
	if n == 0:
		return
	var pts: = PackedVector2Array()
	var uvs: = PackedVector2Array()
	var cols: = PackedColorArray()
	var idx: = PackedInt32Array()
	pts.resize(n * 4)
	uvs.resize(n * 4)
	cols.resize(n * 4)
	idx.resize(n * 6)
	for i in n:
		var p: = pos[i]
		var r: = rad[i]
		var c: = col[i]
		var v: = i * 4
		pts[v] = p + Vector2( - r, - r)
		pts[v + 1] = p + Vector2(r, - r)
		pts[v + 2] = p + Vector2(r, r)
		pts[v + 3] = p + Vector2( - r, r)
		for k in 4:
			uvs[v + k] = _UV[k]
			cols[v + k] = c
		var e: = i * 6
		idx[e] = v
		idx[e + 1] = v + 1
		idx[e + 2] = v + 2
		idx[e + 3] = v
		idx[e + 4] = v + 2
		idx[e + 5] = v + 3
	var rid: = tex.get_rid() if tex != null else RID()
	RenderingServer.canvas_item_add_triangle_array(
		ci.get_canvas_item(), idx, pts, cols, uvs, [], [], rid)




static func lines(ci: CanvasItem, pts: PackedVector2Array, 
		col: PackedColorArray, w: float) -> void :
	if pts.size() < 2:
		return
	ci.draw_multiline_colors(pts, col, w)
