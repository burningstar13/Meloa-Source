class_name ProfileTheme
extends RefCounted









const ASSETS: = "res://assets/profile_placeholders/"


const GOLD: = Color(1.0, 0.82, 0.3)
const CYAN: = Color(0.45, 0.82, 1.0)
const MINT: = Color(0.45, 1.0, 0.75)
const VIOLET: = Color(0.85, 0.62, 1.05)
const RED: = Color(1.0, 0.35, 0.4)
const TEXT: = Color(1, 1, 1, 0.92)
const DIM: = Color(1, 1, 1, 0.42)
const FAINT: = Color(1, 1, 1, 0.28)
const ZONE_BG: = Color(0.022, 0.017, 0.042, 0.8)
const ZONE_LINE: = Color(0.55, 0.4, 0.9, 0.16)
const PANEL_BG: = Color(0.045, 0.055, 0.1, 0.97)


const SOUNDS: = {
	"hover": "hover", "open": "menu_open", "close": "back", "equip": "click", 
	"milestone": "ignite", "tier_up": "menu_play", "unlock": "click", 
}

static var _display: Font = null
static var _bold: Font = null
static var _body: Font = null
static var _cache: = {}



static func setup(main) -> void :
	if main == null:
		return
	_display = main.font_display
	_bold = main.font_bold
	_body = main.font_body


static func _axis(name: String) -> int:
	return TextServerManager.get_primary_interface().name_to_tag(name)


static func _load_var(path: String, axes: Dictionary) -> Font:
	var base: Font = load(path) if ResourceLoader.exists(path) else null
	if base == null:
		return ThemeDB.fallback_font
	var fv: = FontVariation.new()
	fv.base_font = base
	var tagged: = {}
	for k in axes:
		tagged[_axis(k)] = axes[k]
	fv.variation_opentype = tagged
	return fv


static func display() -> Font:
	if _display == null:
		_display = _load_var("res://fonts/Fredoka-Variable.ttf", {"wght": 500, "wdth": 100})
	return _display


static func bold() -> Font:
	if _bold == null:
		_bold = _load_var("res://fonts/NunitoSans-Variable.ttf", {"wght": 700, "wdth": 100, "opsz": 12})
	return _bold


static func body() -> Font:
	if _body == null:
		_body = _load_var("res://fonts/NunitoSans-Variable.ttf", {"wght": 400, "wdth": 100, "opsz": 12})
	return _body



static func font(weight: int) -> Font:
	return bold() if weight >= 600 else body()


static func play(main, key: String) -> void :
	var s: = String(SOUNDS.get(key, ""))
	if s == "" or main == null or not ("sfx" in main) or main.sfx == null:
		return
	main.sfx.play_ui(s)




static func tex(rel: String) -> Texture2D:
	if _cache.has(rel):
		return _cache[rel]
	var path: = ASSETS + rel
	var t: Texture2D = load(path) if ResourceLoader.exists(path) else null
	_cache[rel] = t
	return t


static func avatar_tex(id: String) -> Texture2D:
	return tex("avatars/%s.png" % id) if id != "" else null


static func frame_tex(id: String) -> Texture2D:
	return tex("frames/frame_%s.png" % id) if id != "" and id != "basic" else null


static func tier_tex(key: String) -> Texture2D:
	return tex("tiers/tier_%s.png" % key) if key != "" else null


static func icon_tex(key: String) -> Texture2D:
	return tex("icons/icon_%s.png" % key)


static func fx_tex(key: String) -> Texture2D:
	return tex("fx/%s.png" % key)





static func label(text: String, size: int, color: Color, parent: Node = null, 
		f: Font = null) -> Label:
	var l: = Label.new()
	l.text = text
	l.add_theme_font_override("font", f if f != null else bold())
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if parent != null:
		parent.add_child(l)
	return l


static func cap(text: String, parent: Node = null, color: = DIM, size: = 10) -> Label:
	return label(text, size, color, parent)



static func chip(bg: Color, border: Color, radius: = 9, margin: = Vector2(14, 6)) -> StyleBoxFlat:
	var sb: = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(radius)
	sb.corner_detail = 10
	sb.anti_aliasing = true
	sb.content_margin_left = margin.x
	sb.content_margin_right = margin.x
	sb.content_margin_top = margin.y
	sb.content_margin_bottom = margin.y
	return sb



static func button(text: String, accent: Color, parent: Node = null, size: = 12) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_override("font", bold())
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_stylebox_override("normal", chip(Color(0.1, 0.12, 0.16, 0.92), Color(1, 1, 1, 0.1), 9, Vector2(12, 5)))
	b.add_theme_stylebox_override("hover", chip(Color(0.17, 0.2, 0.26, 0.95), Color(accent, 0.6), 9, Vector2(12, 5)))
	b.add_theme_stylebox_override("pressed", chip(Color(accent, 0.85), Color(1, 1, 1, 0.15), 9, Vector2(12, 5)))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.add_theme_color_override("font_color", Color(1, 1, 1, 0.78))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color(0.05, 0.1, 0.08))
	if parent != null:
		parent.add_child(b)
	return b


static func hsep(parent: Node) -> Control:
	var c: = ColorRect.new()
	c.color = Color(1, 1, 1, 0.07)
	c.custom_minimum_size = Vector2(0, 1)
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


static func vsep(parent: Node, height: = 26.0) -> Control:
	var c: = ColorRect.new()
	c.color = Color(1, 1, 1, 0.08)
	c.custom_minimum_size = Vector2(1, height)
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


static func spacer(parent: Node) -> Control:
	var c: = Control.new()
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


static func icon(key: String, size: float, color: Color, parent: Node = null) -> TextureRect:
	var r: = TextureRect.new()
	r.texture = icon_tex(key)
	r.custom_minimum_size = Vector2(size, size)
	r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	r.modulate = color
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if parent != null:
		parent.add_child(r)


	r.size = Vector2(size, size)
	return r



static func bar(width: float, height: float, color: Color, parent: Node = null) -> Control:
	var c: = Control.new()
	c.custom_minimum_size = Vector2(width, height)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.set_meta("fill", 0.0)
	c.set_meta("color", color)
	c.draw.connect( func() -> void :
		var f: = float(c.get_meta("fill", 0.0))
		var col: Color = c.get_meta("color", color)
		var r: = c.size.y * 0.5
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(1, 1, 1, 0.08)
		sb.set_corner_radius_all(int(r))
		c.draw_style_box(sb, Rect2(Vector2.ZERO, c.size))
		if f > 0.0:
			var fb: = StyleBoxFlat.new()
			fb.bg_color = col
			fb.set_corner_radius_all(int(r))
			c.draw_style_box(fb, Rect2(Vector2.ZERO, Vector2(maxf(c.size.x * f, c.size.y), c.size.y))))
	if parent != null:
		parent.add_child(c)
	return c


static func set_bar(b: Control, fill: float, color: Variant = null) -> void :
	b.set_meta("fill", clampf(fill, 0.0, 1.0))
	if color != null:
		b.set_meta("color", color)
	b.queue_redraw()
