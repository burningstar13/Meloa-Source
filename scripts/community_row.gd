class_name CommunityRow
extends Button









signal action_pressed(online_id: String)
signal moderate_pressed(online_id: String, at: Vector2)
signal preview_pressed(online_id: String)
signal like_pressed(online_id: String)

const H: = 84.0
const COVER: = 58.0
const PAD: = 14.0
const ACTION_W: = 116.0
const ACTION_H: = 34.0
const MOD_W: = 26.0
const LIKE_W: = 60.0
const PINK: = Color(1.0, 0.42, 0.72)


const CYAN: = Color(0.196, 0.902, 1.0)
const VIO: = Color(0.659, 0.333, 0.969)
const VIO_L: = Color(0.761, 0.4, 1.0)
const GREEN: = Color(0.259, 0.961, 0.655)
const AMBER: = Color(1.0, 0.788, 0.29)
const RED: = Color(1.0, 0.322, 0.404)
const ORANGE: = Color(1.0, 0.6, 0.25)
const TXT: = Color(0.969, 0.961, 0.988)
const TXT2: = Color(0.667, 0.647, 0.71)
const UNRANKED: = Color(0.62, 0.52, 0.8)

var f_semi: Font
var f_body: Font
var f_medium: Font

var online_id: = ""
var title: = ""
var sub: = ""
var meta: = ""

var diffs: Array = []
var ranking: = ""


var wip: = false

var likes: = 0
var liked: = false
var meloved: = false
var selected: = false
var admin: = false
var reports: = 0
var action_kind: = "download"
var mod_open: = false
var mod_busy: = false
var preview_state: = "idle"

var _frame: Panel
var _cover: TextureRect
var _initial: Label
var _pv: Button
var _pv_icon: UiIcon
var _pv_pulse: = 0.0
var _action: Button
var _like: Button
var _mod: Button
var _mod_icon: UiIcon
var _hover: = 0.0
var _sel: = 0.0
var _mod_hover: = false
var _action_kind_prev: = ""
var _pulse: = 0.0






static func rounded_points(r: Rect2, rad: float) -> PackedVector2Array:
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var pts: = PackedVector2Array()
	for corner in 4:
		var cx: float = r.end.x - rad if corner < 2 else r.position.x + rad
		var cy: float = r.position.y + rad if corner == 0 or corner == 3 else r.end.y - rad
		var a0: = - PI * 0.5 + corner * PI * 0.5
		for k in 7:
			var a: = a0 + PI * 0.5 * float(k) / 6.0
			pts.append(Vector2(cx + cos(a) * rad, cy + sin(a) * rad))
	return pts



static func draw_rounded_on(ci: CanvasItem, r: Rect2, rad: float, col: Color) -> void :
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	ci.draw_colored_polygon(rounded_points(r, rad), col)



static func draw_outline_on(ci: CanvasItem, r: Rect2, rad: float, col: Color, w: float) -> void :
	var pts: = rounded_points(r, rad)
	pts.append(pts[0])
	ci.draw_polyline(pts, col, w, true)


static func ranking_color(rk: String) -> Color:
	match rk:
		"ranked":
			return GREEN
		"reviewing":
			return VIO_L
		"pending":
			return AMBER
	return UNRANKED


func _ready() -> void :
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	var empty: = StyleBoxEmpty.new()
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(st, empty)


	_frame = Panel.new()
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.size = Vector2(COVER, COVER)
	var st: = StyleBoxFlat.new()
	st.bg_color = Color(0.11, 0.08, 0.2, 1.0)
	st.set_corner_radius_all(10)
	st.corner_detail = 12
	st.anti_aliasing = true
	st.border_color = Color(VIO, 0.22)
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

	_initial = Label.new()
	_initial.set_anchors_preset(Control.PRESET_FULL_RECT)
	_initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_initial.add_theme_font_size_override("font_size", 22)
	_initial.add_theme_color_override("font_color", Color(VIO_L, 0.55))
	_initial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_initial)


	_pv = Button.new()
	_pv.focus_mode = Control.FOCUS_NONE
	_pv.size = Vector2(28, 28)
	_pv.position = Vector2((COVER - 28.0) * 0.5, (COVER - 28.0) * 0.5)
	_pv.tooltip_text = "Listen to a preview"
	var pst: = StyleBoxFlat.new()
	pst.bg_color = Color(0.02, 0.02, 0.06, 0.62)
	pst.border_color = Color(CYAN, 0.55)
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(14)
	pst.corner_detail = 12
	pst.anti_aliasing = true
	_pv.add_theme_stylebox_override("normal", pst)
	var psh: StyleBoxFlat = pst.duplicate()
	psh.bg_color = Color(CYAN.r * 0.25, CYAN.g * 0.35, CYAN.b * 0.4, 0.95)
	psh.border_color = CYAN
	_pv.add_theme_stylebox_override("hover", psh)
	_pv.add_theme_stylebox_override("pressed", psh)
	_pv.pressed.connect( func() -> void : preview_pressed.emit(online_id))
	_frame.add_child(_pv)
	_pv_icon = UiIcon.new()
	_pv_icon.kind = "media_play"
	_pv_icon.tint = CYAN
	_pv_icon.position = Vector2(8, 7)
	_pv_icon.size = Vector2(13, 13)
	_pv_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pv.add_child(_pv_icon)


	_action = Button.new()
	_action.focus_mode = Control.FOCUS_NONE
	_action.size = Vector2(ACTION_W, ACTION_H)
	_action.add_theme_font_size_override("font_size", 11)
	_action.pressed.connect( func() -> void : action_pressed.emit(online_id))
	_action.draw.connect(_draw_action_icon)
	add_child(_action)


	_like = Button.new()
	_like.focus_mode = Control.FOCUS_NONE
	_like.size = Vector2(LIKE_W, ACTION_H)
	_like.flat = true
	_like.tooltip_text = "Like this map"
	var lst: = StyleBoxFlat.new()
	lst.bg_color = Color(1, 1, 1, 0.03)
	lst.border_color = Color(1, 1, 1, 0.08)
	lst.set_border_width_all(1)
	lst.set_corner_radius_all(10)
	var lsh: StyleBoxFlat = lst.duplicate()
	lsh.bg_color = Color(PINK, 0.1)
	lsh.border_color = Color(PINK, 0.55)
	_like.add_theme_stylebox_override("normal", lst)
	_like.add_theme_stylebox_override("hover", lsh)
	_like.add_theme_stylebox_override("pressed", lsh)
	_like.pressed.connect( func() -> void : like_pressed.emit(online_id))
	_like.draw.connect(_draw_like)
	add_child(_like)


	_mod = Button.new()
	_mod.focus_mode = Control.FOCUS_NONE
	_mod.size = Vector2(MOD_W, 34)
	_mod.visible = false
	_mod.tooltip_text = "Moderate this map"
	var mst: = StyleBoxFlat.new()
	mst.bg_color = Color(0, 0, 0, 0)
	mst.set_corner_radius_all(8)
	_mod.add_theme_stylebox_override("normal", mst)
	var msh: StyleBoxFlat = mst.duplicate()
	msh.bg_color = Color(VIO, 0.14)
	_mod.add_theme_stylebox_override("hover", msh)
	_mod.add_theme_stylebox_override("pressed", msh)
	_mod.pressed.connect( func() -> void :
		moderate_pressed.emit(online_id, _mod.get_global_rect().position
			+ Vector2(-4.0, _mod.size.y + 2.0)))
	_mod.draw.connect(_draw_mod_extras)
	add_child(_mod)
	_mod_icon = UiIcon.new()
	_mod_icon.kind = "dots"
	_mod_icon.tint = Color(VIO, 0.85)
	_mod_icon.position = Vector2(4, 8)
	_mod_icon.size = Vector2(18, 18)
	_mod_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mod.add_child(_mod_icon)
	resized.connect(_place_children)



func bind(d: Dictionary) -> void :
	online_id = String(d.get("id", ""))
	title = String(d.get("title", ""))
	sub = String(d.get("sub", ""))
	meta = String(d.get("meta", ""))
	diffs = d.get("diffs", [])
	ranking = String(d.get("ranking", ""))
	wip = bool(d.get("wip", false))
	likes = int(d.get("likes", 0))
	liked = bool(d.get("liked", false))
	meloved = bool(d.get("meloved", false))
	_like.tooltip_text = "Unlike" if liked else "Like this map"
	_like.queue_redraw()
	selected = bool(d.get("selected", false))
	admin = bool(d.get("admin", false))
	reports = int(d.get("reports", 0))
	mod_open = bool(d.get("mod_open", false))
	mod_busy = bool(d.get("mod_busy", false))
	var kind: = String(d.get("action_kind", "download"))
	_action.text = String(d.get("action_label", "DOWNLOAD"))
	_action.tooltip_text = String(d.get("action_tip", ""))
	if f_semi != null:
		_action.add_theme_font_override("font", f_semi)
		_initial.add_theme_font_override("font", f_semi)
	if kind != _action_kind_prev:
		_style_action(kind)
	action_kind = kind
	_action.disabled = kind in ["busy", "off"]
	_cover.texture = d.get("cover")
	_cover.visible = _cover.texture != null
	_initial.visible = _cover.texture == null
	_initial.text = title.substr(0, 1).to_upper()
	_mod.visible = admin
	preview_state = String(d.get("preview", "idle"))
	_pv.visible = bool(d.get("preview_ok", true))
	_pv_icon.kind = "media_pause" if preview_state == "playing" else "media_play"
	_pv_icon.tint = Color(CYAN, 0.6) if preview_state == "loading" else CYAN
	_pv_icon.queue_redraw()
	_pv.tooltip_text = {"idle": "Listen to a preview", "loading": "Loading the preview…", 
		"playing": "Stop the preview"}[preview_state]
	_pv.modulate.a = 1.0
	_sel = 1.0 if selected else 0.0
	_place_children()
	_update_mod_tint()
	_mod.queue_redraw()
	queue_redraw()




func animate_action_change() -> void :
	if not is_visible_in_tree():
		return
	_action.pivot_offset = _action.size * 0.5
	var tw: = _action.create_tween()
	tw.tween_property(_action, "scale", Vector2(1.07, 1.07), 0.09)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(_action, "scale", Vector2.ONE, 0.14)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _place_children() -> void :
	var w: = size.x
	_frame.position = Vector2(PAD, (H - COVER) * 0.5)
	_frame.size = Vector2(COVER, COVER)
	var right: = w - PAD
	if admin:
		_mod.position = Vector2(right - MOD_W, (H - 34.0) * 0.5)
		right -= MOD_W + 8.0
	_action.position = Vector2(right - ACTION_W, (H - ACTION_H) * 0.5)
	_action.size = Vector2(ACTION_W, ACTION_H)
	_like.position = Vector2(right - ACTION_W - 8.0 - LIKE_W, (H - ACTION_H) * 0.5)
	_like.size = Vector2(LIKE_W, ACTION_H)





func _style_action(kind: String) -> void :
	_action_kind_prev = kind
	var bg: Color
	var border: Color
	var bg_h: Color
	var border_h: Color
	var txt: Color
	match kind:
		"play":
			bg = Color(VIO.r * 0.35, VIO.g * 0.22, VIO.b * 0.45, 0.95)
			border = Color(VIO_L, 0.85)
			bg_h = Color(VIO.r * 0.5, VIO.g * 0.32, VIO.b * 0.62, 0.98)
			border_h = Color(CYAN, 0.95)
			txt = TXT
		"retry":
			bg = Color(RED, 0.1)
			border = Color(RED, 0.6)
			bg_h = Color(RED, 0.2)
			border_h = Color(RED, 0.95)
			txt = RED
		"update":

			bg = Color(AMBER, 0.12)
			border = Color(AMBER, 0.65)
			bg_h = Color(AMBER, 0.22)
			border_h = Color(AMBER, 1.0)
			txt = AMBER
		"busy":
			bg = Color(1, 1, 1, 0.04)
			border = Color(CYAN, 0.28)
			bg_h = bg
			border_h = border
			txt = Color(CYAN, 0.85)
		"off":
			bg = Color(1, 1, 1, 0.03)
			border = Color(1, 1, 1, 0.1)
			bg_h = bg
			border_h = border
			txt = Color(1, 1, 1, 0.38)
		_:
			bg = Color(CYAN, 0.1)
			border = Color(CYAN, 0.55)
			bg_h = Color(CYAN, 0.2)
			border_h = Color(CYAN, 1.0)
			txt = CYAN
	var mk: = func(b: Color, bo: Color) -> StyleBoxFlat:
		var st: = StyleBoxFlat.new()
		st.bg_color = b
		st.border_color = bo
		st.set_border_width_all(1)
		st.set_corner_radius_all(10)
		st.corner_detail = 12
		st.anti_aliasing = true

		st.content_margin_left = 30 if kind in ["download", "play"] else 12
		st.content_margin_right = 12
		st.content_margin_top = 6
		st.content_margin_bottom = 6
		return st
	_action.add_theme_stylebox_override("normal", mk.call(bg, border))
	_action.add_theme_stylebox_override("hover", mk.call(bg_h, border_h))
	_action.add_theme_stylebox_override("pressed", mk.call(bg_h, border_h))
	_action.add_theme_stylebox_override("disabled", mk.call(bg, border))
	_action.add_theme_color_override("font_color", txt)
	_action.add_theme_color_override("font_hover_color", Color(txt, 1.0) if kind != "download" else Color(0.75, 0.97, 1.0))
	_action.add_theme_color_override("font_pressed_color", txt)
	_action.add_theme_color_override("font_disabled_color", txt)


func _draw_action_icon() -> void :
	var c: = Vector2(18.0, _action.size.y * 0.5)
	if action_kind == "download":
		UiIcon.draw_kind(_action, "download", c, 15.0, 
			Color(0.75, 0.97, 1.0) if _action.is_hovered() else CYAN, 1.6)
	elif action_kind == "update":
		UiIcon.draw_kind(_action, "download", c, 15.0, AMBER, 1.6)
	elif action_kind == "play":
		UiIcon.draw_kind(_action, "media_play", c + Vector2(1, 0), 13.0, TXT, 1.6)



func _draw_like() -> void :
	var c: = Vector2(16.0, _like.size.y * 0.5 + 0.5)
	var col: = PINK if liked else Color(1, 1, 1, 0.55 if _like.is_hovered() else 0.35)
	_draw_heart(_like, c, 6.5, col, liked)
	if f_medium != null:
		var txt: = str(likes) if likes < 10000 else "%.1fk" % (likes / 1000.0)
		_like.draw_string(f_medium, Vector2(28.0, _like.size.y * 0.5 + 4.0), txt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(col, 0.95 if liked else 0.85))





static func _draw_heart(c: CanvasItem, o: Vector2, r: float, col: Color, filled: bool) -> void :
	var rl: = r * 0.5
	var lobe: = Vector2(rl, - r * 0.42)
	var tip: = Vector2(0.0, r * 1.02)

	var v: = tip - lobe
	var a0: = v.angle()
	var da: = acos(clampf(rl / v.length(), -1.0, 1.0))
	var t1: = a0 - da
	var t2: = a0 + da
	var ta: = t1 if cos(t1) > cos(t2) else t2

	var half: = PackedVector2Array([tip])
	var steps: = 14
	var sweep: = ta - ( - PI)
	if sweep < 0.0:
		sweep += TAU
	for i in steps + 1:
		var ang: = ta - sweep * float(i) / float(steps)
		half.append(lobe + Vector2(cos(ang), sin(ang)) * rl)

	var pts: = PackedVector2Array()
	for p in half:
		pts.append(o + p)
	for i in range(half.size() - 2, 0, -1):
		pts.append(o + Vector2( - half[i].x, half[i].y))
	if filled:
		c.draw_colored_polygon(pts, col)
	pts.append(pts[0])
	c.draw_polyline(pts, col, 1.2 if filled else 1.5, true)


func _draw_mod_extras() -> void :
	if reports > 0:
		_mod.draw_circle(Vector2(MOD_W - 4.0, 8.0), 3.0, AMBER)


func _update_mod_tint() -> void :
	var col: Color
	if mod_busy:
		col = Color(ORANGE, 0.45 + 0.35 * (0.5 + 0.5 * sin(_pulse * 7.0)))
	elif mod_open:
		col = ORANGE
	elif _mod_hover:
		col = Color(VIO_L.r * 1.15, VIO_L.g * 1.15, VIO_L.b * 1.15)
	else:
		col = Color(VIO, 0.85)
	if _mod_icon.tint != col:
		_mod_icon.tint = col
		_mod_icon.queue_redraw()


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
	if admin:
		var mh: = _mod.is_hovered()
		if mh != _mod_hover or mod_busy:
			_mod_hover = mh
			_pulse += delta
			_update_mod_tint()
	if preview_state == "loading":
		_pv_pulse += delta
		_pv.modulate.a = 0.55 + 0.45 * (0.5 + 0.5 * sin(_pv_pulse * 6.0))


func _draw() -> void :
	var w: = size.x
	var h: = size.y
	var lit: = maxf(_sel, _hover * 0.55)
	var box: = Rect2(2, 3, w - 4, h - 6)
	var rad: = 14.0



	var base_a: = 0.55 + 0.25 * _hover
	draw_rounded_on(self, box, rad, Color(
		lerpf(0.071, VIO.r * 0.3, _sel * 0.9), 
		lerpf(0.063, VIO.g * 0.22, _sel * 0.9), 
		lerpf(0.125, VIO.b * 0.34, _sel * 0.9), base_a + 0.25 * _sel))

	if _sel > 0.01:
		draw_outline_on(self, box.grow(2.0), rad + 2.0, Color(CYAN, 0.1 * _sel), 2.0)
		draw_outline_on(self, box.grow(1.0), rad + 1.0, Color(VIO_L, 0.16 * _sel), 1.5)

	var bc: = Color(1, 1, 1, 0.06)
	bc = bc.lerp(Color(VIO_L, 0.55), _hover)
	bc = bc.lerp(Color(VIO_L.lerp(CYAN, 0.35), 0.95), _sel)
	draw_outline_on(self, box, rad, bc, 1.0)

	var tx: = PAD + COVER + 14.0
	var right: = _like.position.x - 10.0

	var badge_w: = 0.0
	if ranking != "" and f_medium != null:
		var rtxt: = ranking.to_upper()
		var rc: = ranking_color(ranking)
		badge_w = f_medium.get_string_size(rtxt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 16.0
		var rr: = Rect2(right - badge_w, h * 0.5 - 10.0, badge_w, 20.0)
		draw_rounded_on(self, rr, 10.0, Color(rc, 0.14))
		draw_outline_on(self, rr, 10.0, Color(rc, 0.55 + 0.3 * lit), 1.0)
		draw_string(f_medium, rr.position + Vector2(8.0, 14.0), rtxt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(rc, 0.95))
		badge_w += 10.0


	if meloved and f_medium != null:
		var mtxt: = "MELOVED"
		var mw: = f_medium.get_string_size(mtxt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 16.0
		var mr: = Rect2(right - badge_w - mw, h * 0.5 - 10.0, mw, 20.0)
		draw_rounded_on(self, mr, 10.0, Color(PINK, 0.14))
		draw_outline_on(self, mr, 10.0, Color(PINK, 0.55 + 0.3 * lit), 1.0)
		draw_string(f_medium, mr.position + Vector2(8.0, 14.0), mtxt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(PINK, 0.95))
		badge_w += mw + 10.0


	if wip and f_medium != null:
		var wtxt: = "WIP"
		var ww: = f_medium.get_string_size(wtxt, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 16.0
		var wr: = Rect2(right - badge_w - ww, h * 0.5 - 10.0, ww, 20.0)
		draw_rounded_on(self, wr, 10.0, Color(ORANGE, 0.12))
		draw_outline_on(self, wr, 10.0, Color(ORANGE, 0.5 + 0.3 * lit), 1.0)
		draw_string(f_medium, wr.position + Vector2(8.0, 14.0), wtxt, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(ORANGE, 0.92))
		badge_w += ww + 10.0
	var text_w: = maxf(right - badge_w - tx, 40.0)



	if f_semi != null:
		draw_string(f_semi, Vector2(tx, 28.0), title, HORIZONTAL_ALIGNMENT_LEFT, 
			text_w, 15, Color(TXT, 0.86 + 0.14 * lit), TextServer.JUSTIFICATION_NONE)
	if f_body != null and sub != "":
		draw_string(f_body, Vector2(tx, 46.0), sub, HORIZONTAL_ALIGNMENT_LEFT, 
			text_w, 12, Color(TXT2, 0.85 + 0.15 * lit), TextServer.JUSTIFICATION_NONE)
	if f_medium != null:


		var mx: = tx
		var limit: = tx + text_w - 70.0
		var shown: = 0
		for i in diffs.size():
			var dd: Array = diffs[i]
			var label: = "%s %.1f" % [String(dd[0]), float(dd[1])] if String(dd[0]) != ""\
			else "%.1f" % float(dd[1])
			var dw: = f_medium.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 10.0
			var rest: = diffs.size() - i - 1
			var plus_w: = 26.0 if rest > 0 else 0.0
			if i > 0 and mx + dw + plus_w > limit:
				var pl: = "+%d" % (diffs.size() - shown)
				draw_string(f_medium, Vector2(mx + 2.0, 65.0), pl, HORIZONTAL_ALIGNMENT_LEFT, 
					-1, 10, Color(TXT2, 0.85))
				mx += f_medium.get_string_size(pl, HORIZONTAL_ALIGNMENT_LEFT, -1, 10).x + 8.0
				break
			var dc: Color = dd[2]
			var rr: = Rect2(mx, 55.0, dw, 15.0)
			draw_rounded_on(self, rr, 7.5, Color(dc, 0.12))
			draw_outline_on(self, rr, 7.5, Color(dc, 0.55), 1.0)
			draw_string(f_medium, rr.position + Vector2(5.0, 11.0), label, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(dc, 0.95))
			mx += dw + 5.0
			shown += 1
		if meta != "":
			mx += 4.0
			draw_string(f_medium, Vector2(mx, 65.0), meta, HORIZONTAL_ALIGNMENT_LEFT, 
				maxf(tx + text_w - mx, 20.0), 11, Color(TXT2, 0.62 + 0.12 * lit), 
				TextServer.JUSTIFICATION_NONE)
