extends RefCounted









const BG: = Color(0.012, 0.016, 0.038)
const PANEL: = Color(0.028, 0.035, 0.07)
const PANEL_HI: = Color(0.045, 0.055, 0.1)
const FIELD: = Color(0.02, 0.026, 0.055)
const LINE: = Color(1, 1, 1, 0.065)
const LINE_HI: = Color(1, 1, 1, 0.15)





const LINE_SOFT: = Color(1, 1, 1, 0.032)


const TXT: = Color(0.9, 0.93, 1.0)
const TXT_DIM: = Color(0.62, 0.67, 0.82)
const TXT_FAINT: = Color(1, 1, 1, 0.3)


const CYAN: = Color(0.3, 1.0, 0.85)
const VIOLET: = Color(0.72, 0.45, 1.0)
const GOLD: = Color(1.0, 0.78, 0.25)
const RED: = Color(1.0, 0.36, 0.36)
const MINT: = Color(0.45, 1.0, 0.75)
const WARM: = Color(1.0, 0.62, 0.2)


const S_MICRO: = 9
const S_SMALL: = 10
const S_BODY: = 11
const S_VALUE: = 13
const S_HEAD: = 15
const S_TITLE: = 20


static func accent_for(note_type: String) -> Color:
	match note_type:
		"dodge":
			return RED
		"click", "clickx", "sliderg":
			return GOLD
		"sliderm", "beam":
			return Color(0.86, 0.9, 1.0)
	return Color(0.86, 0.9, 1.0)


static func type_label(note_type: String) -> String:
	match note_type:
		"parry":
			return "WHITE (PARRY)"
		"dodge":
			return "DODGE (RED)"
		"click":
			return "AIM (YELLOW)"
		"clickx":
			return "AIM ×N (COUNTER)"
		"sliderm":
			return "HOLD"
		"sliderg":
			return "SLIDER (YELLOW)"
		"beam":
			return "BEAM"
	return note_type.to_upper()




static func is_aim_type(note_type: String) -> bool:
	return note_type in ["click", "clickx", "sliderg"]





static func has_duration(note_type: String) -> bool:
	return note_type in ["sliderm", "sliderg", "beam"]




static func is_chain(note_type: String) -> bool:
	return note_type == "clickx"




static func flat(bg: Color, border: = Color.TRANSPARENT, radius: = 4, 
		bw: = 1) -> StyleBoxFlat:
	var sb: = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(radius)
	if border.a > 0.0:
		sb.set_border_width_all(bw)
		sb.border_color = border
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 3
	sb.content_margin_bottom = 3
	return sb



static func make_panel(radius: = 5) -> PanelContainer:
	var p: = PanelContainer.new()
	p.add_theme_stylebox_override("panel", flat(PANEL, LINE, radius))
	return p




static func skin_panel(p: PanelContainer, primary: = false, radius: = 5) -> void :
	p.add_theme_stylebox_override("panel", 
		flat(PANEL, LINE if primary else LINE_SOFT, radius))


static func make_label(text: String, size: = S_BODY, col: = TXT, 
		font: Font = null) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	if font != null:
		l.add_theme_font_override("font", font)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l



static func section(text: String, font: Font = null) -> Label:
	var l: = make_label(text, S_MICRO, Color(1, 1, 1, 0.38), font)
	return l









static func make_section(title: String, font: Font, start_open: = true, 
		tip: = "") -> Section:
	var s: = Section.new()
	s.add_theme_constant_override("separation", 2)

	var head: = Button.new()
	head.text = "     " + title
	head.alignment = HORIZONTAL_ALIGNMENT_LEFT
	head.tooltip_text = tip if tip != "" else "Show / hide this section"
	head.custom_minimum_size.y = 15
	style_button(head, Color.TRANSPARENT, font, S_MICRO)

	head.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	head.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	head.add_theme_color_override("font_color", Color(1, 1, 1, 0.38))
	head.add_theme_color_override("font_hover_color", Color(1, 1, 1, 0.72))
	var caret: = Glyph.new()
	caret.glyph = "caret"
	caret.radius = 5.0
	caret.color = Color(1, 1, 1, 0.32)
	caret.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caret.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	caret.offset_left = 2.0
	caret.offset_top = -6.0
	caret.offset_right = 14.0
	caret.offset_bottom = 6.0
	head.add_child(caret)
	s.add_child(head)

	var body: = VBoxContainer.new()
	body.add_theme_constant_override("separation", 2)
	s.add_child(body)

	s.body = body
	s.caret = caret
	head.pressed.connect(s.toggle)
	s.set_open(start_open)
	return s




class Section extends VBoxContainer:
	signal toggled(open)

	var body: VBoxContainer
	var caret
	var open: = true

	func set_open(v: bool) -> void :
		open = v
		if body != null:
			body.visible = v
		if caret != null:
			caret.angle = PI * 0.5 if v else 0.0
			caret.queue_redraw()
		toggled.emit(v)

	func toggle() -> void :
		set_open( not open)


	func add(c: Control) -> Control:
		body.add_child(c)
		return c




static func style_button(b: Button, accent: = Color.TRANSPARENT, font: Font = null, 
		size: = S_BODY, radius: = 4) -> Button:
	var base_bg: = PANEL_HI
	var base_bd: = LINE
	var fg: = TXT_DIM
	if accent.a > 0.0:
		base_bg = Color(accent.r, accent.g, accent.b, 0.14)
		base_bd = Color(accent.r, accent.g, accent.b, 0.55)
		fg = accent
	b.add_theme_stylebox_override("normal", flat(base_bg, base_bd, radius))
	b.add_theme_stylebox_override("hover", 
		flat(base_bg.lightened(0.1), Color(base_bd.r, base_bd.g, base_bd.b, 
			minf(base_bd.a + 0.18, 1.0)), radius))
	b.add_theme_stylebox_override("pressed", 
		flat(base_bg.lightened(0.2), base_bd, radius))
	b.add_theme_stylebox_override("disabled", 
		flat(Color(0.03, 0.035, 0.06), Color(1, 1, 1, 0.04), radius))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", fg)
	b.add_theme_color_override("font_hover_color", accent if accent.a > 0.0 else TXT)
	b.add_theme_color_override("font_pressed_color", accent if accent.a > 0.0 else TXT)
	b.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.18))
	b.add_theme_font_size_override("font_size", size)
	if font != null:
		b.add_theme_font_override("font", font)
	b.focus_mode = Control.FOCUS_NONE
	return b


static func text_button(text: String, tip: = "", accent: = Color.TRANSPARENT, 
		font: Font = null, size: = S_BODY) -> Button:
	var b: = Button.new()
	b.text = text
	b.tooltip_text = tip
	return style_button(b, accent, font, size)



static func icon_button(glyph: String, tip: = "", accent: = Color.TRANSPARENT, 
		px: = 22.0, gsize: = 11.0) -> Button:
	var b: = Button.new()
	b.tooltip_text = tip
	b.custom_minimum_size = Vector2(px, px)
	style_button(b, accent)
	var g: = Glyph.new()
	g.glyph = glyph
	g.radius = gsize
	g.color = accent if accent.a > 0.0 else TXT_DIM
	g.set_anchors_preset(Control.PRESET_FULL_RECT)
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(g)
	b.set_meta("glyph", g)
	return b


static func style_line_edit(le: LineEdit, font: Font = null, size: = S_VALUE) -> LineEdit:
	le.add_theme_stylebox_override("normal", flat(FIELD, LINE, 3))
	le.add_theme_stylebox_override("focus", flat(FIELD, Color(CYAN.r, CYAN.g, CYAN.b, 0.6), 3))
	le.add_theme_stylebox_override("read_only", flat(Color(0.02, 0.024, 0.045), LINE, 3))
	le.add_theme_color_override("font_color", TXT)
	le.add_theme_color_override("font_uneditable_color", TXT_FAINT)
	le.add_theme_color_override("caret_color", CYAN)
	le.add_theme_color_override("selection_color", Color(CYAN.r, CYAN.g, CYAN.b, 0.25))
	le.add_theme_font_size_override("font_size", size)
	if font != null:
		le.add_theme_font_override("font", font)
	le.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	le.custom_minimum_size.y = 20
	return le



static func separator(vertical: = false) -> Control:
	var c: = ColorRect.new()
	c.color = LINE
	if vertical:
		c.custom_minimum_size = Vector2(1, 0)
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	else:
		c.custom_minimum_size = Vector2(0, 1)
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c


static func spacer(px: = 0.0, expand: = false) -> Control:
	var c: = Control.new()
	c.custom_minimum_size = Vector2(px, px)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if expand:
		c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return c




static func fmt_time(s: float) -> String:
	var m: = int(s) / 60
	return "%02d:%06.3f" % [m, s - m * 60]


static func fmt_pct(v: float) -> String:
	return "%.1f%%" % (v * 100.0)







static func make_glyph(name: String, r: = 11.0, col: = TXT) -> Control:
	var g: = Glyph.new()
	g.glyph = name
	g.radius = r
	g.color = col
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g


class Glyph extends Control:
	var glyph: = "play"
	var radius: = 11.0
	var color: = Color(0.9, 0.93, 1.0)

	var angle: = 0.0

	func _draw() -> void :
		var c: = size * 0.5
		var r: = radius
		var w: = maxf(1.4, r * 0.16)
		match glyph:
			"caret":


				var tri: = PackedVector2Array()
				for v in [Vector2( - r * 0.3, - r * 0.52), Vector2(r * 0.44, 0.0), 
						Vector2( - r * 0.3, r * 0.52)]:
					tri.append(c + v.rotated(angle))
				draw_colored_polygon(tri, color)
			"play":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2( - r * 0.45, - r * 0.62), c + Vector2(r * 0.62, 0), 
					c + Vector2( - r * 0.45, r * 0.62)]), color)
			"pause":
				draw_rect(Rect2(c + Vector2( - r * 0.46, - r * 0.6), 
					Vector2(r * 0.3, r * 1.2)), color)
				draw_rect(Rect2(c + Vector2(r * 0.16, - r * 0.6), 
					Vector2(r * 0.3, r * 1.2)), color)
			"stop":
				draw_rect(Rect2(c - Vector2(r * 0.5, r * 0.5), Vector2(r, r)), color)
			"prev", "next":


				var s: = 1.0 if glyph == "prev" else -1.0
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(s * r * 0.5, - r * 0.55), c + Vector2(s * - r * 0.25, 0), 
					c + Vector2(s * r * 0.5, r * 0.55)]), color)
				draw_rect(Rect2(c + Vector2(s * - r * 0.55, - r * 0.55), 
					Vector2(r * 0.18, r * 1.1)), color)
			"back", "fwd":

				var sd: = 1.0 if glyph == "back" else -1.0
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(sd * r * 0.46, - r * 0.58), c + Vector2(sd * - r * 0.42, 0), 
					c + Vector2(sd * r * 0.46, r * 0.58)]), color)
			"undo", "redo":
				var sx: = -1.0 if glyph == "undo" else 1.0
				draw_arc(c + Vector2(0, r * 0.16), r * 0.58, PI, TAU, 22, color, w)
				var tip: = c + Vector2(sx * - r * 0.58, r * 0.16)
				draw_colored_polygon(PackedVector2Array([
					tip + Vector2(0, r * 0.42), tip + Vector2(sx * - r * 0.34, - r * 0.1), 
					tip + Vector2(sx * r * 0.34, - r * 0.1)]), color)
			"save":
				draw_rect(Rect2(c - Vector2(r * 0.62, r * 0.62), 
					Vector2(r * 1.24, r * 1.24)), color, false, w)
				draw_rect(Rect2(c + Vector2( - r * 0.32, - r * 0.62), 
					Vector2(r * 0.64, r * 0.44)), color)
				draw_rect(Rect2(c + Vector2( - r * 0.38, r * 0.06), 
					Vector2(r * 0.76, r * 0.56)), color, false, w)
			"test":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2( - r * 0.42, - r * 0.6), c + Vector2(r * 0.62, 0), 
					c + Vector2( - r * 0.42, r * 0.6)]), color)
			"menu":
				for i in 3:
					var y: = c.y + (float(i) - 1.0) * r * 0.46
					draw_line(Vector2(c.x - r * 0.62, y), Vector2(c.x + r * 0.62, y), color, w)
			"select":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2( - r * 0.42, - r * 0.66), c + Vector2( - r * 0.42, r * 0.6), 
					c + Vector2( - r * 0.08, r * 0.22), c + Vector2(r * 0.16, r * 0.7), 
					c + Vector2(r * 0.4, r * 0.58), c + Vector2(r * 0.16, r * 0.12), 
					c + Vector2(r * 0.52, r * 0.06)]), color)
			"move":
				draw_line(c - Vector2(r * 0.7, 0), c + Vector2(r * 0.7, 0), color, w)
				draw_line(c - Vector2(0, r * 0.7), c + Vector2(0, r * 0.7), color, w)
				for a in [0.0, PI * 0.5, PI, PI * 1.5]:
					var d: = Vector2(cos(a), sin(a))
					var n: = Vector2( - d.y, d.x)
					draw_colored_polygon(PackedVector2Array([
						c + d * r * 0.82, c + d * r * 0.48 + n * r * 0.24, 
						c + d * r * 0.48 - n * r * 0.24]), color)
			"erase":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2( - r * 0.66, r * 0.18), c + Vector2( - r * 0.06, - r * 0.62), 
					c + Vector2(r * 0.66, r * 0.02), c + Vector2(r * 0.1, r * 0.62)]), color)
				draw_line(c + Vector2( - r * 0.66, r * 0.6), c + Vector2(r * 0.66, r * 0.6), 
					Color(color.r, color.g, color.b, color.a * 0.5), w)
			"cut":
				draw_line(c + Vector2( - r * 0.6, - r * 0.6), c + Vector2(r * 0.35, r * 0.3), color, w)
				draw_line(c + Vector2(r * 0.6, - r * 0.6), c + Vector2( - r * 0.35, r * 0.3), color, w)
				draw_arc(c + Vector2( - r * 0.42, r * 0.48), r * 0.24, 0, TAU, 14, color, w)
				draw_arc(c + Vector2(r * 0.42, r * 0.48), r * 0.24, 0, TAU, 14, color, w)
			"copy":
				draw_rect(Rect2(c + Vector2( - r * 0.66, - r * 0.66), 
					Vector2(r * 0.92, r * 0.92)), color, false, w)
				draw_rect(Rect2(c + Vector2( - r * 0.24, - r * 0.24), 
					Vector2(r * 0.92, r * 0.92)), color, false, w)
			"paste":
				draw_rect(Rect2(c + Vector2( - r * 0.6, - r * 0.52), 
					Vector2(r * 1.2, r * 1.16)), color, false, w)
				draw_rect(Rect2(c + Vector2( - r * 0.26, - r * 0.74), 
					Vector2(r * 0.52, r * 0.3)), color)
			"eye":
				draw_arc(c + Vector2(0, r * 0.55), r * 0.95, PI * 1.22, PI * 1.78, 20, color, w)
				draw_arc(c - Vector2(0, r * 0.55), r * 0.95, PI * 0.22, PI * 0.78, 20, color, w)
				draw_arc(c, r * 0.26, 0, TAU, 16, color, w)
			"target":
				draw_arc(c, r * 0.72, 0, TAU, 26, color, w)
				draw_circle(c, r * 0.22, color)
				for a in [0.0, PI * 0.5, PI, PI * 1.5]:
					var d2: = Vector2(cos(a), sin(a))
					draw_line(c + d2 * r * 0.72, c + d2 * r * 1.02, color, w)
			"chain":

				var pts: = [c + Vector2( - r * 0.62, r * 0.34), c + Vector2(0, - r * 0.5), 
					c + Vector2(r * 0.62, r * 0.34)]
				for i in 2:
					draw_line(pts[i], pts[i + 1], Color(color.r, color.g, color.b, 
						color.a * 0.55), w * 0.8)
				for i in 3:
					draw_arc(pts[i], r * 0.3, 0, TAU, 14, color, w * 0.9)
			"circle":
				draw_arc(c, r * 0.66, 0, TAU, 26, color, w * 1.15)
			"diamond":
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(0, - r * 0.76), c + Vector2(r * 0.76, 0), 
					c + Vector2(0, r * 0.76), c + Vector2( - r * 0.76, 0)]), color)
			"hold":
				draw_rect(Rect2(c + Vector2( - r * 0.34, - r * 0.78), 
					Vector2(r * 0.68, r * 1.56)), color, false, w * 1.2)
				draw_circle(c + Vector2(0, r * 0.5), r * 0.24, color)
			"slider":
				var pts: = PackedVector2Array()
				for i in 13:
					var u: = float(i) / 12.0
					pts.append(c + Vector2(lerpf( - r * 0.78, r * 0.78, u), 
						sin(u * PI * 1.6) * r * 0.44 - r * 0.1))
				draw_polyline(pts, color, w)
				draw_circle(pts[0], r * 0.24, color)
			"chevron":
				draw_line(c + Vector2( - r * 0.46, - r * 0.2), c + Vector2(0, r * 0.26), color, w)
				draw_line(c + Vector2(r * 0.46, - r * 0.2), c + Vector2(0, r * 0.26), color, w)
			"reset":
				draw_arc(c, r * 0.6, PI * 0.35, PI * 1.95, 24, color, w)
				draw_colored_polygon(PackedVector2Array([
					c + Vector2(r * 0.6, - r * 0.28), c + Vector2(r * 0.2, - r * 0.36), 
					c + Vector2(r * 0.52, - r * 0.72)]), color)
			"help":
				draw_arc(c, r * 0.78, 0, TAU, 26, color, w)
				draw_arc(c + Vector2(0, - r * 0.16), r * 0.28, PI, TAU * 0.98, 16, color, w)
				draw_line(c + Vector2(r * 0.26, - r * 0.1), c + Vector2(0, r * 0.2), color, w)
				draw_circle(c + Vector2(0, r * 0.44), r * 0.11, color)
			"rec":
				draw_circle(c, r * 0.62, color)
			"close":
				draw_line(c - Vector2(r * 0.5, r * 0.5), c + Vector2(r * 0.5, r * 0.5), color, w)
				draw_line(c + Vector2( - r * 0.5, r * 0.5), c + Vector2(r * 0.5, - r * 0.5), color, w)
			_:
				draw_arc(c, r * 0.6, 0, TAU, 20, color, w)
