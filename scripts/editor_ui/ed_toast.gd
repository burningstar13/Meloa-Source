extends Control

















const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")




const TOP: = 76.0
const FADE_IN: = 0.1
const FADE_OUT: = 0.35

var ed
var _text: = ""
var _accent: Color = EdTheme.GOLD
var _alpha: = 0.0
var _target: = 0.0
var _slide: = 0.0


func _init() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


	z_index = 40


func _ready() -> void :
	ed.status_changed.connect(_on_status)
	_on_status()




func _colour_for(msg: String) -> Color:
	var m: = msg.to_lower()
	if m.contains("failed") or m.contains("not found") or m.contains("unsaved")\
	or m.contains("unreadable") or m.contains("could not"):
		return EdTheme.RED
	if m.begins_with("saved") or m.contains("created") or m.contains("switched"):
		return EdTheme.MINT
	return EdTheme.GOLD


func _on_status() -> void :
	var msg: = String(ed.status)
	if msg == _text:
		return
	_text = msg
	if msg != "":
		_accent = _colour_for(msg)
		_slide = 1.0
	_target = 1.0 if msg != "" else 0.0
	queue_redraw()


func _process(delta: float) -> void :
	var speed: = 1.0 / (FADE_IN if _target > _alpha else FADE_OUT)
	var a: = move_toward(_alpha, _target, delta * speed)
	var s: = maxf(0.0, _slide - delta * 6.0)
	if is_equal_approx(a, _alpha) and is_equal_approx(s, _slide):
		return
	_alpha = a
	_slide = s
	queue_redraw()


func _draw() -> void :
	if _alpha <= 0.01 or _text == "":
		return
	var f: Font = ed.font
	var fs: = EdTheme.S_VALUE
	var tw: float = f.get_string_size(_text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var w: float = minf(tw + 34.0, size.x - 60.0)
	var h: = 26.0
	var r: = Rect2((size.x - w) * 0.5, TOP - _slide * 6.0, w, h)
	var a: = _alpha



	_pill(r, Color(0.02, 0.026, 0.052, 0.96 * a))
	_pill_outline(r, Color(_accent.r, _accent.g, _accent.b, 0.75 * a))


	draw_circle(Vector2(r.position.x + 13.0, r.get_center().y), 3.0, 
		Color(_accent.r, _accent.g, _accent.b, a))
	draw_string(f, Vector2(r.position.x + 24.0, r.get_center().y + 4.5), _text, 
		HORIZONTAL_ALIGNMENT_LEFT, w - 32.0, fs, 
		Color(EdTheme.TXT.r, EdTheme.TXT.g, EdTheme.TXT.b, a))



func _pill(r: Rect2, col: Color) -> void :
	var rad: float = r.size.y * 0.5
	draw_rect(Rect2(r.position.x + rad, r.position.y, r.size.x - rad * 2.0, 
		r.size.y), col)
	draw_circle(Vector2(r.position.x + rad, r.get_center().y), rad, col)
	draw_circle(Vector2(r.end.x - rad, r.get_center().y), rad, col)


func _pill_outline(r: Rect2, col: Color) -> void :
	var rad: float = r.size.y * 0.5
	var pts: = PackedVector2Array()
	for i in 13:
		var ang: = - PI * 0.5 + PI * float(i) / 12.0
		pts.append(Vector2(r.end.x - rad + cos(ang) * rad, 
			r.get_center().y + sin(ang) * rad))
	for i in 13:
		var ang2: = PI * 0.5 + PI * float(i) / 12.0
		pts.append(Vector2(r.position.x + rad + cos(ang2) * rad, 
			r.get_center().y + sin(ang2) * rad))
	pts.append(pts[0])
	draw_polyline(pts, col, 1.0, true)
