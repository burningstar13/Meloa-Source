class_name MapRow
extends Button








const COVER: = 52.0
const PAD: = 14.0


const VIO: = Color(0.62, 0.34, 1.0)





func draw_rounded(r: Rect2, rad: float, col: Color) -> void :
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	draw_rect(Rect2(r.position.x + rad, r.position.y, 
		r.size.x - rad * 2.0, r.size.y), col)
	draw_rect(Rect2(r.position.x, r.position.y + rad, 
		rad, r.size.y - rad * 2.0), col)
	draw_rect(Rect2(r.end.x - rad, r.position.y + rad, 
		rad, r.size.y - rad * 2.0), col)
	for i in 4:
		var cx: float = r.position.x + rad if i % 2 == 0 else r.end.x - rad
		var cy: float = r.position.y + rad if i < 2 else r.end.y - rad
		draw_circle(Vector2(cx, cy), rad, col)



func draw_rounded_outline(r: Rect2, rad: float, col: Color, w: float) -> void :
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var pts: = PackedVector2Array()
	for corner in 4:
		var cx: float = r.end.x - rad if corner < 2 else r.position.x + rad
		var cy: float = r.position.y + rad if corner == 0 or corner == 3\
		else r.end.y - rad
		var a0: = - PI * 0.5 + corner * PI * 0.5
		for k in 7:
			var a: = a0 + PI * 0.5 * float(k) / 6.0
			pts.append(Vector2(cx + cos(a) * rad, cy + sin(a) * rad))
	pts.append(pts[0])
	draw_polyline(pts, col, w, true)

var font_bold: Font
var font_display: Font

var title: = ""
var artist: = ""
var pips: = 0
var pips_max: = 5
var grade: = ""
var grade_col: = Color(1, 1, 1, 0.3)
var accent: = Color(0.72, 0.45, 1.0)
var selected: = false
var locked: = false
var favorite: = false


var draft: = false
var ranking: = ""


var wip: = false
var meloved: = false
var outdated: = false

var _frame: Panel
var _cover: TextureRect
var _hover: = 0.0
var _sel: = 0.0


func _ready() -> void :
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(st, empty)


	_frame = Panel.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.custom_minimum_size = Vector2(COVER, COVER)
	_frame.size = Vector2(COVER, COVER)
	var st: = StyleBoxFlat.new()
	st.bg_color = Color(0.055, 0.045, 0.1, 1.0)
	st.set_corner_radius_all(10)
	st.border_color = Color(1, 1, 1, 0.09)
	st.set_border_width_all(1)
	_frame.add_theme_stylebox_override("panel", st)
	_frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	add_child(_frame)
	_cover = TextureRect.new()
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cover.clip_contents = true
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_cover)



func bind(d: Dictionary) -> void :
	title = String(d.get("title", ""))
	artist = String(d.get("artist", ""))
	pips = int(d.get("pips", 0))
	grade = String(d.get("grade", ""))
	grade_col = d.get("grade_col", Color(1, 1, 1, 0.3))
	accent = d.get("accent", Color(0.72, 0.45, 1.0))
	selected = bool(d.get("selected", false))
	locked = bool(d.get("locked", false))
	favorite = bool(d.get("favorite", false))
	draft = bool(d.get("badge", false))
	ranking = String(d.get("ranking", ""))
	wip = bool(d.get("wip", false))
	meloved = bool(d.get("meloved", false))
	outdated = bool(d.get("outdated", false))
	_cover.texture = d.get("cover")
	_cover.visible = _cover.texture != null
	_sel = 1.0 if selected else 0.0
	queue_redraw()


func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	var k: = 1.0 - exp(-16.0 * delta)
	var hp: = _hover
	var sp: = _sel
	_hover = lerpf(_hover, 1.0 if is_hovered() else 0.0, k)
	_sel = lerpf(_sel, 1.0 if selected else 0.0, k)
	if absf(_hover - hp) > 0.001 or absf(_sel - sp) > 0.001:
		queue_redraw()



	var shift: = 5.0 * _sel + 3.0 * _hover
	_frame.position = Vector2(PAD + shift, (size.y - COVER) * 0.5)


func _draw() -> void :
	var w: = size.x
	var h: = size.y
	var shift: = 5.0 * _sel + 3.0 * _hover
	var lit: = maxf(_sel, _hover * 0.55)





	if lit > 0.01:
		var box: = Rect2(4, 4, w - 8, h - 8)
		var rad: = 14.0

		draw_rounded(box, rad, Color(VIO.r * 0.16, VIO.g * 0.1, VIO.b * 0.26, 
			(0.3 + 0.45 * _sel) * lit))


		var bc: = 1.0 + 0.55 * _sel
		draw_rounded_outline(box, rad, 
			Color(VIO.r * bc, VIO.g * bc * 0.85, VIO.b * bc, 
				(0.35 + 0.6 * _sel) * lit), 1.0)

	var tx: = PAD + shift + COVER + 14.0
	var right: = w - 16.0



	var badge_w: = 70.0 if (draft or ranking != "") else 0.0
	if wip:
		badge_w += 42.0
	if meloved:
		badge_w += 66.0
	if outdated:
		badge_w += 60.0
	var text_w: = maxf(right - tx - 44.0 - badge_w, 40.0)


	if font_display != null:
		var ta: = 0.62 + 0.38 * lit
		if locked:
			ta *= 0.45
		draw_string(font_display, Vector2(tx, h * 0.5 - 6.0), title, 
			HORIZONTAL_ALIGNMENT_LEFT, text_w, 15, 
			Color(1, 1, 1, ta), TextServer.JUSTIFICATION_NONE)

	if font_bold != null and artist != "":
		draw_string(font_bold, Vector2(tx, h * 0.5 + 11.0), artist, 
			HORIZONTAL_ALIGNMENT_LEFT, text_w, 11, 
			Color(1, 1, 1, 0.3 + 0.16 * lit))

	var dy: = h * 0.5 + 22.0
	for i in pips_max:
		var px: = tx + 5.0 + i * 12.0
		var full: = i < pips
		var c: = Color(accent.r, accent.g, accent.b, 0.85 if full else 0.16)
		var s: = 3.4 if full else 2.8
		var pts: = PackedVector2Array([Vector2(px, dy - s), Vector2(px + s, dy), 
			Vector2(px, dy + s), Vector2(px - s, dy)])
		if full:
			draw_colored_polygon(pts, c)
		else:
			draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), 
				c, 1.0, true)

	if grade != "" and font_display != null:
		var gc: = Vector2(right - 17.0, h * 0.5)
		draw_arc(gc, 15.0, 0.0, TAU, 32, 
			Color(grade_col.r, grade_col.g, grade_col.b, 0.3 + 0.45 * lit), 
			1.2, true)
		var gs: = font_display.get_string_size(grade, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15)
		draw_string(font_display, gc + Vector2( - gs.x * 0.5, 5.0), grade, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 15, 
			Color(grade_col.r * 1.25, grade_col.g * 1.25, grade_col.b * 1.25, 
				0.75 + 0.25 * lit))




	var bx: = right - 44.0
	if draft and font_bold != null:
		var bw: float = font_bold.get_string_size("DRAFT", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 12.0
		var br: = Rect2(bx - bw, h * 0.5 - 9.0, bw, 15.0)
		bx -= bw + 6.0
		var dc: = Color(1.0, 0.78, 0.25, 0.3 + 0.35 * lit)
		draw_rounded(br, 7.0, Color(dc.r * 0.35, dc.g * 0.28, dc.b * 0.12, 
			0.3 + 0.25 * lit))
		draw_rounded_outline(br, 7.0, dc, 1.0)
		draw_string(font_bold, br.position + Vector2(6.0, 11.0), "DRAFT", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 
			Color(1.0, 0.86, 0.45, 0.65 + 0.35 * lit))




	if ranking != "" and font_bold != null:
		var rtxt: = ranking.to_upper()
		var rc: = Color(0.3, 1.0, 0.6)
		if ranking == "pending":
			rc = Color(1.0, 0.82, 0.3)
		elif ranking == "unranked":
			rc = Color(1.0, 0.36, 0.4)
		var rw: float = font_bold.get_string_size(rtxt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 12.0
		var rr: = Rect2(bx - rw, h * 0.5 - 9.0, rw, 15.0)
		bx -= rw + 6.0
		draw_rounded(rr, 7.0, Color(rc.r * 0.3, rc.g * 0.3, rc.b * 0.3, 0.35 + 0.25 * lit))
		draw_rounded_outline(rr, 7.0, Color(rc.r, rc.g, rc.b, 0.55 + 0.35 * lit), 1.0)
		draw_string(font_bold, rr.position + Vector2(6.0, 11.0), rtxt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 
			Color(rc.r, rc.g, rc.b, 0.8 + 0.2 * lit))



	if meloved and font_bold != null:
		var pc: = Color(1.0, 0.42, 0.72)
		var pw: float = font_bold.get_string_size("MELOVED", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 12.0
		var pr: = Rect2(bx - pw, h * 0.5 - 9.0, pw, 15.0)
		bx -= pw + 6.0
		draw_rounded(pr, 7.0, Color(pc.r * 0.3, pc.g * 0.3, pc.b * 0.3, 0.35 + 0.25 * lit))
		draw_rounded_outline(pr, 7.0, Color(pc.r, pc.g, pc.b, 0.55 + 0.35 * lit), 1.0)
		draw_string(font_bold, pr.position + Vector2(6.0, 11.0), "MELOVED", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 
			Color(pc.r, pc.g, pc.b, 0.8 + 0.2 * lit))


	if outdated and font_bold != null:
		var uc: = Color(1.0, 0.788, 0.29)
		var uw: float = font_bold.get_string_size("UPDATE", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 12.0
		var ur: = Rect2(bx - uw, h * 0.5 - 9.0, uw, 15.0)
		bx -= uw + 6.0
		draw_rounded(ur, 7.0, Color(uc.r * 0.3, uc.g * 0.3, uc.b * 0.3, 0.45 + 0.25 * lit))
		draw_rounded_outline(ur, 7.0, Color(uc.r, uc.g, uc.b, 0.7 + 0.3 * lit), 1.0)
		draw_string(font_bold, ur.position + Vector2(6.0, 11.0), "UPDATE", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 
			Color(uc.r, uc.g, uc.b, 0.9 + 0.1 * lit))


	if wip and font_bold != null:
		var wc: = Color(1.0, 0.6, 0.25)
		var ww: float = font_bold.get_string_size("WIP", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 12.0
		var wr: = Rect2(bx - ww, h * 0.5 - 9.0, ww, 15.0)
		draw_rounded(wr, 7.0, Color(wc.r * 0.3, wc.g * 0.3, wc.b * 0.3, 0.35 + 0.25 * lit))
		draw_rounded_outline(wr, 7.0, Color(wc.r, wc.g, wc.b, 0.5 + 0.35 * lit), 1.0)
		draw_string(font_bold, wr.position + Vector2(6.0, 11.0), "WIP", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9, 
			Color(wc.r, wc.g, wc.b, 0.8 + 0.2 * lit))


	if favorite:
		draw_circle(Vector2(right - 40.0, h * 0.5 - 13.0), 2.4, 
			Color(1.0, 0.82, 0.3, 0.9))

	if locked:
		draw_rect(Rect2(PAD + shift, (h - COVER) * 0.5, COVER, COVER), 
			Color(0.02, 0.02, 0.05, 0.55))
