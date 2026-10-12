class_name ResultsTheme
extends RefCounted














const BG: = Color("#05050d")
const BG_2: = Color("#080812")
const PANEL: = Color("#0b0b16")
const PANEL_2: = Color("#0d0d1a")
const LINE: = Color("#71409a")
const LINE_SOFT: = Color("#3c2458")
const VIOLET_LIGHT: = Color("#a855f7")
const VIOLET: = Color("#6d36d9")
const CYAN: = Color("#36d8f2")
const CYAN_LIGHT: = Color("#62e6f5")
const BLUE: = Color("#4f8cff")
const TEXT: = Color("#f2eff7")
const TEXT_DIM: = Color("#aaa4b5")
const TEXT_FAINT: = Color("#aaa4b5", 0.55)
const YELLOW: = Color("#ffe477")
const CORAL: = Color("#ff5364")
const ME_BG: = Color("#0a1a1f")



const PATH_FONT: = "res://fonts/Inter-Variable.ttf"



const GRADE_COLORS: = {
	"SS": Color("#fff6dc"), 
	"S": Color("#f9e9a3"), "A": CYAN, "B": Color("#7fb0ff"), "C": VIOLET_LIGHT, "D": CORAL, 
}


static func grade_color(grade: String) -> Color:
	return GRADE_COLORS.get(grade, CYAN)



const LABELS: = {
	"RTitle": [500, 18, TEXT], 
	"RArtist": [400, 13, TEXT_DIM], 
	"RChip": [500, 11, CYAN], 
	"RMode": [500, 13, TEXT], 
	"RStatus": [500, 14, CYAN], 
	"RAccuracy": [700, 66, CYAN], 
	"RCleared": [500, 15, CYAN], 
	"RCaption": [500, 12, TEXT_DIM], 
	"RScore": [700, 46, TEXT], 
	"RBest": [400, 13, TEXT_DIM], 
	"RBestValue": [500, 13, TEXT], 
	"RBadge": [600, 10, Color("#1a1607")], 
	"RCardCap": [500, 12, TEXT], 
	"RCardValue": [700, 30, TEXT], 
	"RRankHeader": [600, 15, TEXT], 
	"RYourRank": [500, 15, TEXT_DIM], 
	"RYourRankValue": [700, 26, CYAN], 
	"RRowRank": [500, 13, TEXT_DIM], 
	"RRowName": [500, 13, TEXT], 
	"RRowSub": [400, 11, TEXT_DIM], 
	"RRowSubStrong": [500, 12, TEXT], 
	"RRowScore": [500, 13, TEXT], 
	"RNote": [400, 12, TEXT_DIM], 
	"RNoteError": [500, 12, CORAL], 
	"RAccountName": [600, 13, TEXT], 
	"RAccountCap": [400, 9, TEXT_DIM], 
	"RAccountRank": [500, 12, TEXT], 
	"RGrade": [600, 128, TEXT], 
	"RButton": [600, 15, VIOLET_LIGHT], 
	"RButtonMain": [600, 15, Color.WHITE], 
}

static var _theme: Theme = null
static var _fonts: = {}
static var _fredoka: Font = null


static func base_font() -> Font:
	if _fredoka == null:
		_fredoka = load(PATH_FONT) if ResourceLoader.exists(PATH_FONT)\
		else ThemeDB.fallback_font
	return _fredoka





static func font(weight: int) -> Font:
	if not _fonts.has(weight):
		var fv: = FontVariation.new()
		fv.base_font = base_font()
		var ts: = TextServerManager.get_primary_interface()
		fv.variation_opentype = {ts.name_to_tag("wght"): weight}
		_fonts[weight] = fv
	return _fonts[weight]



static func role(name: String) -> Array:
	return LABELS.get(name, [500, 13, TEXT])


static func theme() -> Theme:
	if _theme != null:
		return _theme
	var t: = Theme.new()
	t.default_font = font(500)
	t.default_font_size = 13
	for role in LABELS:
		var spec: Array = LABELS[role]
		var n: = StringName(role)
		var base: = &"Button" if role.begins_with("RButton") else &"Label"
		t.set_type_variation(n, base)
		t.set_font(&"font", n, font(int(spec[0])))
		t.set_font_size(&"font_size", n, int(spec[1]))
		t.set_color(&"font_color", n, spec[2])
		if base == &"Button":
			for c in [&"font_hover_color", &"font_pressed_color", &"font_focus_color", 
					&"font_hover_pressed_color"]:
				t.set_color(c, n, Color.WHITE)
			t.set_color(&"font_disabled_color", n, Color(spec[2], 0.4))
			var empty: = StyleBoxEmpty.new()
			for s in [&"normal", &"hover", &"pressed", &"focus", &"disabled", &"hover_pressed"]:
				t.set_stylebox(s, n, empty)
	_panels(t)
	_theme = t
	return t



static func box(bg: Color, border: Color, radius: = 14, border_w: = 1, 
		margin: = Vector2(12, 8)) -> StyleBoxFlat:
	var s: = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.corner_detail = 10
	s.content_margin_left = margin.x
	s.content_margin_right = margin.x
	s.content_margin_top = margin.y
	s.content_margin_bottom = margin.y
	s.anti_aliasing = true
	return s


static func _panels(t: Theme) -> void :
	for pair in [
			["RPanel", box(PANEL, LINE, 16, 1, Vector2(18, 16))], 
			["RCard", box(PANEL, LINE_SOFT, 12, 1, Vector2(10, 8))], 
			["RRow", box(PANEL_2, LINE_SOFT, 12, 1, Vector2(10, 6))], 
			["RRowMe", box(ME_BG, Color(CYAN, 0.8), 12, 1, Vector2(10, 6))], 
			["RCover", box(PANEL_2, LINE_SOFT, 10, 1, Vector2(0, 0))], 
			["RChipPanel", box(Color("#081a20"), Color(CYAN, 0.6), 8, 1, Vector2(9, 2))], 
			["RModeChip", box(PANEL_2, LINE, 10, 1, Vector2(16, 5))], 
			["RAccount", box(PANEL, LINE, 14, 1, Vector2(10, 6))], 
			["RSkeleton", box(Color(1, 1, 1, 0.04), Color(0, 0, 0, 0), 10, 0, Vector2(0, 0))], 
			["RBarTrack", box(Color(1, 1, 1, 0.08), Color(0, 0, 0, 0), 3, 0, Vector2(0, 0))], 
			]:
		var n: = StringName(pair[0])
		t.set_type_variation(n, &"PanelContainer")
		t.set_stylebox(&"panel", n, pair[1])
		var np: = StringName(String(pair[0]) + "Plain")
		t.set_type_variation(np, &"Panel")
		t.set_stylebox(&"panel", np, pair[1])
	var sb: = &"RScroll"
	t.set_type_variation(sb, &"VScrollBar")
	t.set_stylebox(&"scroll", sb, box(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 4, 0, Vector2(0, 0)))
	t.set_stylebox(&"grabber", sb, box(Color(1, 1, 1, 0.14), Color(0, 0, 0, 0), 4, 0, Vector2(0, 0)))
	t.set_stylebox(&"grabber_highlight", sb, box(Color(1, 1, 1, 0.24), Color(0, 0, 0, 0), 4, 0, Vector2(0, 0)))
	t.set_stylebox(&"grabber_pressed", sb, box(Color(1, 1, 1, 0.3), Color(0, 0, 0, 0), 4, 0, Vector2(0, 0)))



static func thousands(n: int) -> String:
	var neg: = n < 0
	var s: = str(absi(n))
	var out: = ""
	var count: = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if neg else "") + out
