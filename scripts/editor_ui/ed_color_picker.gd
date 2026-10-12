extends Control














const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

const W: = 232.0
const PAD: = 10.0
const SV_H: = 118.0
const HUE_H: = 14.0
const SW: = 22.0
const SW_GAP: = 4.0



const PALETTE: = [
	"#ffffff", "#e8e6ff", "#b48cff", "#ff2ea8", "#ff4d6d", "#ff9d2e", "#ffe14d", "#4dff88", 
	"#2effd9", "#3ec8ff", "#5a7bff", "#8b5cf6", "#ff7ad9", "#ffb38a", "#9ad0ff", "#0a0a14", 
]

static var _recent: Array = []

var _font: Font
var _cb: Callable
var _allow_clear: = false
var _h: = 0.0
var _s: = 0.0
var _v: = 1.0
var _drag: = ""
var _pos: = Vector2.ZERO
var _hex: LineEdit
var _hover_sw: = -1
var _rects: = {}



static func open(host: Control, at: Vector2, font: Font, start: Color, 
		cb: Callable, allow_clear: = false) -> Control:
	close_all(host)
	var p = load("res://scripts/editor_ui/ed_color_picker.gd").new()
	p._font = font
	p._cb = cb
	p._allow_clear = allow_clear
	p._h = start.h
	p._s = start.s
	p._v = start.v
	if start.a <= 0.0:
		p._h = 0.75
		p._s = 0.4
		p._v = 1.0
	p.add_to_group("ed_menu")
	host.add_child(p)
	p.place(at)
	return p


static func close_all(host: Node) -> void :
	for n in host.get_tree().get_nodes_in_group("ed_menu"):
		n.queue_free()


static func remember(c: Color) -> void :
	var hex: = "#" + c.to_html(false)
	_recent.erase(hex)
	_recent.push_front(hex)
	if _recent.size() > 8:
		_recent.resize(8)


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 100


func _ready() -> void :
	_hex = LineEdit.new()
	_hex.placeholder_text = "#rrggbb"
	_hex.max_length = 7
	EdTheme.style_line_edit(_hex, _font, EdTheme.S_SMALL)
	_hex.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_hex.text_submitted.connect(_on_hex)
	add_child(_hex)
	_layout()
	_sync_hex()


func place(at: Vector2) -> void :
	var vs: = get_viewport_rect().size
	var h: = _total_h()
	_pos = Vector2(clampf(at.x, 4.0, vs.x - W - 4.0), clampf(at.y, 4.0, vs.y - h - 4.0))
	_layout()
	queue_redraw()


func _total_h() -> float:
	var rows: = 2 + (1 if not _recent.is_empty() else 0)
	return PAD + 16.0 + SV_H + 6.0 + HUE_H + 8.0 + float(rows) * (SW + SW_GAP)\
	+ 6.0 + 22.0 + PAD


func _layout() -> void :
	var x: = _pos.x + PAD
	var y: = _pos.y + PAD + 16.0
	var inner: = W - PAD * 2.0
	_rects["panel"] = Rect2(_pos, Vector2(W, _total_h()))
	_rects["sv"] = Rect2(x, y, inner, SV_H)
	y += SV_H + 6.0
	_rects["hue"] = Rect2(x, y, inner, HUE_H)
	y += HUE_H + 8.0
	_rects["pal"] = Rect2(x, y, inner, 2.0 * (SW + SW_GAP))
	y += 2.0 * (SW + SW_GAP)
	if not _recent.is_empty():
		_rects["recent"] = Rect2(x, y, inner, SW + SW_GAP)
		y += SW + SW_GAP
	else:
		_rects.erase("recent")
	y += 6.0
	if _hex != null:
		_hex.position = Vector2(x, y)
		_hex.size = Vector2(inner - (58.0 if _allow_clear else 0.0), 22.0)
	if _allow_clear:
		_rects["clear"] = Rect2(x + inner - 52.0, y, 52.0, 22.0)
	else:
		_rects.erase("clear")


func color() -> Color:
	return Color.from_hsv(_h, _s, _v)


func _sync_hex() -> void :
	if _hex != null and not _hex.has_focus():
		_hex.text = "#" + color().to_html(false)


func _emit(final: bool) -> void :
	var c: = color()
	if final:
		remember(c)
		_layout()
	if _cb.is_valid():
		_cb.call(c, final)
	_sync_hex()
	queue_redraw()


func _on_hex(txt: String) -> void :
	var raw: = txt.strip_edges()
	if not raw.begins_with("#"):
		raw = "#" + raw
	var c: = Color.from_string(raw, Color(0, 0, 0, 0))
	if c.a <= 0.0:
		return
	_h = c.h
	_s = c.s
	_v = c.v
	_emit(true)


func _gui_input(event: InputEvent) -> void :
	var panel: Rect2 = _rects.get("panel", Rect2())
	if event is InputEventMouseButton:
		var mb: = event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			accept_event()
			return
		if mb.pressed:
			if not panel.has_point(mb.position):
				queue_free()
				accept_event()
				return
			if (_rects.sv as Rect2).has_point(mb.position):
				_drag = "sv"
				_pick_sv(mb.position)
			elif (_rects.hue as Rect2).has_point(mb.position):
				_drag = "hue"
				_pick_hue(mb.position)
			elif _rects.has("clear") and (_rects.clear as Rect2).has_point(mb.position):
				if _cb.is_valid():
					_cb.call(Color(0, 0, 0, 0), true)
				queue_free()
			else:
				var sw: = _swatch_at(mb.position)
				if sw != "":
					var c: = Color.from_string(sw, Color.WHITE)
					_h = c.h
					_s = c.s
					_v = c.v
					_emit(true)
		elif _drag != "":
			_drag = ""
			_emit(true)
		accept_event()
	elif event is InputEventMouseMotion:
		var mm: = event as InputEventMouseMotion
		if _drag == "sv":
			_pick_sv(mm.position)
			_emit(false)
		elif _drag == "hue":
			_pick_hue(mm.position)
			_emit(false)
		else:
			var hv: = _swatch_at(mm.position)
			var idx: = -1 if hv == "" else hv.hash()
			if idx != _hover_sw:
				_hover_sw = idx
				queue_redraw()
		accept_event()


func _unhandled_key_input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		queue_free()
		get_viewport().set_input_as_handled()


func _pick_sv(p: Vector2) -> void :
	var r: Rect2 = _rects.sv
	_s = clampf((p.x - r.position.x) / r.size.x, 0.0, 1.0)
	_v = 1.0 - clampf((p.y - r.position.y) / r.size.y, 0.0, 1.0)


func _pick_hue(p: Vector2) -> void :
	var r: Rect2 = _rects.hue
	_h = clampf((p.x - r.position.x) / r.size.x, 0.0, 0.9999)



func _swatch_at(p: Vector2) -> String:
	for entry in _swatch_rects():
		if (entry[1] as Rect2).has_point(p):
			return String(entry[0])
	return ""


func _swatch_rects() -> Array:
	var out: Array = []
	var pal: Rect2 = _rects.pal
	var per_row: = 8
	var step: = (pal.size.x - SW) / float(per_row - 1)
	for i in PALETTE.size():
		var cx: float = pal.position.x + float(i % per_row) * step
		var cy: float = pal.position.y + floorf(float(i) / float(per_row)) * (SW + SW_GAP)
		out.append([PALETTE[i], Rect2(cx, cy, SW, SW)])
	if _rects.has("recent"):
		var rr: Rect2 = _rects.recent
		for i in _recent.size():
			out.append([_recent[i], Rect2(rr.position.x + float(i) * step, rr.position.y, 
				SW, SW)])
	return out


func _draw() -> void :
	var r: Rect2 = _rects.get("panel", Rect2())
	draw_rect(Rect2(r.position + Vector2(0, 3), r.size), Color(0, 0, 0, 0.45), true)
	draw_rect(r, Color(0.02, 0.026, 0.052, 0.99))
	draw_rect(r, EdTheme.LINE_HI, false, 1.0)
	if _font != null:
		draw_string(_font, r.position + Vector2(PAD, 13), "COLOR", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.38))
		var cur: = color()
		var hx: = "#" + cur.to_html(false)
		var hw: float = _font.get_string_size(hx, HORIZONTAL_ALIGNMENT_LEFT, -1, 
			EdTheme.S_MICRO).x
		draw_string(_font, Vector2(r.end.x - PAD - hw, r.position.y + 13), hx, 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.55))

	var sv: Rect2 = _rects.sv
	var nx: = 16
	var ny: = 10
	var cw: = sv.size.x / float(nx)
	var ch: = sv.size.y / float(ny)
	for j in ny:
		for i in nx:
			var s0: = float(i) / float(nx)
			var s1: = float(i + 1) / float(nx)
			var v0: = 1.0 - float(j) / float(ny)
			var v1: = 1.0 - float(j + 1) / float(ny)
			var x0: = sv.position.x + float(i) * cw
			var y0: = sv.position.y + float(j) * ch
			var pts: = PackedVector2Array([Vector2(x0, y0), Vector2(x0 + cw, y0), 
				Vector2(x0 + cw, y0 + ch), Vector2(x0, y0 + ch)])
			var cols: = PackedColorArray([Color.from_hsv(_h, s0, v0), 
				Color.from_hsv(_h, s1, v0), Color.from_hsv(_h, s1, v1), 
				Color.from_hsv(_h, s0, v1)])
			draw_polygon(pts, cols)
	draw_rect(sv, EdTheme.LINE_HI, false, 1.0)
	var cur_p: = sv.position + Vector2(_s * sv.size.x, (1.0 - _v) * sv.size.y)
	draw_arc(cur_p, 5.0, 0.0, TAU, 20, Color.BLACK, 2.5)
	draw_arc(cur_p, 5.0, 0.0, TAU, 20, Color.WHITE, 1.2)

	var hb: Rect2 = _rects.hue
	var nh: = 24
	var hw2: = hb.size.x / float(nh)
	for i in nh:
		var h0: = float(i) / float(nh)
		var h1: = float(i + 1) / float(nh)
		var x0: = hb.position.x + float(i) * hw2
		var pts2: = PackedVector2Array([Vector2(x0, hb.position.y), 
			Vector2(x0 + hw2, hb.position.y), Vector2(x0 + hw2, hb.end.y), 
			Vector2(x0, hb.end.y)])
		var cols2: = PackedColorArray([Color.from_hsv(h0, 1, 1), Color.from_hsv(h1, 1, 1), 
			Color.from_hsv(h1, 1, 1), Color.from_hsv(h0, 1, 1)])
		draw_polygon(pts2, cols2)
	draw_rect(hb, EdTheme.LINE_HI, false, 1.0)
	var hx2: = hb.position.x + _h * hb.size.x
	draw_rect(Rect2(hx2 - 2.0, hb.position.y - 2.0, 4.0, hb.size.y + 4.0), Color.BLACK)
	draw_rect(Rect2(hx2 - 1.0, hb.position.y - 1.0, 2.0, hb.size.y + 2.0), Color.WHITE)

	var cur_hex: = "#" + color().to_html(false)
	for entry in _swatch_rects():
		var hex: = String(entry[0])
		var sr: Rect2 = entry[1]
		var c: = Color.from_string(hex, Color.WHITE)
		draw_rect(sr, c)
		var sel: = hex == cur_hex
		var hov: = hex.hash() == _hover_sw
		draw_rect(sr, Color.WHITE if sel else (Color(1, 1, 1, 0.6) if hov
			else Color(1, 1, 1, 0.14)), false, 1.5 if sel else 1.0)
	if _rects.has("recent") and _font != null:
		var rr: Rect2 = _rects.recent
		draw_string(_font, Vector2(rr.end.x - 34.0, rr.position.y + SW - 4.0), "recent", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.28))

	if _rects.has("clear") and _font != null:
		var cr: Rect2 = _rects.clear
		draw_rect(cr, Color(EdTheme.RED.r, EdTheme.RED.g, EdTheme.RED.b, 0.14))
		draw_rect(cr, Color(EdTheme.RED.r, EdTheme.RED.g, EdTheme.RED.b, 0.5), false, 1.0)
		draw_string(_font, cr.position + Vector2(8, 15), "NONE", 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, EdTheme.RED)
