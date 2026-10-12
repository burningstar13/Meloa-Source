class_name OrbitMenu
extends Control















signal activated(id: String)
signal button_hovered(index: int)

const IDS: = ["multiplayer", "play", "editor"]



const SIDE_ANGLE: = 0.64


const ARC_SPAN: = 1.05

var center: = Vector2.ZERO
var rx: = 420.0
var ry: = 344.0
var glow_tex: Texture2D
var buttons: Array = []

var is_open: = false

var draw_span: = 0.0:
	set(v):
		draw_span = v
		queue_redraw()

var _beat: = 0.0
var _strong: = 0.0
var _hover_idx: = -1
var _hover_glow: = 0.0
var _pulses: Array = []
var _spin: = 0.0
var _open_tw: Tween


func _ready() -> void :
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in IDS.size():
		var b: = OrbitButton.new()
		b.caption = ["MULTIPLAYER", "PLAY", "EDITOR"][i]
		b.icon_kind = ["multiplayer", "play", "editor"][i]
		b.accent = [Color(0.45, 0.86, 1.0), Color(0.78, 0.5, 1.0), 
			Color(0.95, 0.55, 0.88)][i]
		b.weight = 1.15 if i == 1 else 1.0
		b.radius = 38.0 if i == 1 else 33.0
		b.float_phase = float(i) * 2.35
		b.glow_tex = glow_tex
		b.pressed.connect(_on_activated.bind(i))
		b.mouse_entered.connect(_on_button_hover.bind(i))
		b.mouse_exited.connect(_on_button_hover.bind(-1))
		add_child(b)
		buttons.append(b)
	layout()



func angle_of(i: int) -> float:
	return PI * 0.5 + (1 - i) * SIDE_ANGLE



func point_at(a: float) -> Vector2:
	return center + Vector2(rx * cos(a), ry * sin(a))



func button_center(i: int) -> Vector2:
	return point_at(angle_of(i))




func button_global(i: int) -> Vector2:
	return get_global_transform() * button_center(i)





func layout() -> void :
	for i in buttons.size():
		var b: OrbitButton = buttons[i]
		var p: = point_at(angle_of(i))


		b.base_pos = p - Vector2(b.radius, b.radius)
		b.position = b.base_pos
		b.pivot_offset = Vector2(b.radius, b.radius)
	queue_redraw()


func set_font(f: Font) -> void :
	for b in buttons:
		b.set_font(f)







func open() -> void :
	if is_open:
		return
	is_open = true
	if _open_tw:
		_open_tw.kill()
	_open_tw = create_tween()
	_open_tw.tween_interval(0.15)
	_open_tw.tween_property(self, "draw_span", 1.0, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	for pair in [[1, 0.3], [0, 0.36], [2, 0.42]]:
		var b: OrbitButton = buttons[pair[0]]
		var tw: = b.create_tween()
		tw.tween_interval(float(pair[1]))
		tw.tween_property(b, "appear", 1.0, 0.26)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


	for i in 3:
		_pulses.append({"idx": i, "t": -0.16 - i * 0.04, "dur": 0.42, 
			"col": (buttons[i] as OrbitButton).accent})


func close() -> void :
	if not is_open:
		return
	is_open = false
	_hover_idx = -1
	if _open_tw:
		_open_tw.kill()
	for i in [2, 0, 1]:
		var b: OrbitButton = buttons[i]
		var tw: = b.create_tween()
		tw.tween_property(b, "appear", 0.0, 0.16).set_ease(Tween.EASE_IN)
	_open_tw = create_tween()
	_open_tw.tween_interval(0.1)
	_open_tw.tween_property(self, "draw_span", 0.0, 0.22)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


func toggle() -> void :
	if is_open:
		close()
	else:
		open()




func converge_to(index: int) -> void :
	is_open = false
	var target: = button_center(index)
	for i in buttons.size():
		var b: OrbitButton = buttons[i]
		b.frozen = true
		var tw: = b.create_tween()
		if i == index:
			tw.tween_property(b, "scale", b.scale * 1.7, 0.28)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tw.parallel().tween_property(b, "modulate:a", 0.0, 0.28).set_delay(0.06)
		else:
			tw.tween_property(b, "position", 
				target - Vector2(b.radius, b.radius), 0.26)\
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
			tw.parallel().tween_property(b, "modulate:a", 0.0, 0.24)
	if _open_tw:
		_open_tw.kill()
	_open_tw = create_tween()
	_open_tw.tween_property(self, "draw_span", 0.0, 0.26).set_ease(Tween.EASE_IN)
	_pulses.append({"idx": index, "t": 0.0, "dur": 0.26, 
		"col": (buttons[index] as OrbitButton).accent})




func reset() -> void :
	is_open = false
	draw_span = 0.0
	_pulses.clear()
	_hover_idx = -1
	_hover_glow = 0.0
	for b in buttons:
		var ob: OrbitButton = b
		ob.modulate.a = 1.0
		ob.appear = 0.0
		ob.frozen = false
		ob.scale = Vector2.ONE * ob.weight * 0.001
	layout()




func on_beat(strength: float) -> void :
	_beat = maxf(_beat, strength)
	for b in buttons:
		(b as OrbitButton).on_beat(strength * 0.6)


func on_strong_beat(strength: float) -> void :
	_strong = maxf(_strong, strength)


func _on_activated(i: int) -> void :
	_pulses.append({"idx": i, "t": 0.0, "dur": 0.34, 
		"col": (buttons[i] as OrbitButton).accent})
	activated.emit(IDS[i])


func _on_button_hover(i: int) -> void :
	if i == _hover_idx:
		return



	if i == -1:
		var still: = -1
		for k in buttons.size():
			if (buttons[k] as OrbitButton).is_hovered():
				still = k
		if still != -1:
			return
	_hover_idx = i
	if i >= 0:

		_pulses.append({"idx": i, "t": 0.0, "dur": 0.4, 
			"col": (buttons[i] as OrbitButton).accent})
	button_hovered.emit(i)




func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	var s: = SettingsManager.menu_fx_intensity
	_beat = maxf(0.0, _beat - delta * 2.2)
	_strong = maxf(0.0, _strong - delta * 1.6)
	_hover_glow = lerpf(_hover_glow, 1.0 if _hover_idx >= 0 else 0.0, 
		1.0 - exp(-14.0 * delta))
	_spin += delta * (0.1 + 0.05 * _beat * s)
	var alive: = []
	for p in _pulses:
		p.t += delta
		if p.t < p.dur:
			alive.append(p)
	_pulses = alive
	if draw_span > 0.002 or not _pulses.is_empty():
		queue_redraw()


func _draw() -> void :








	for p in _pulses:
		var k: = clampf(p.t / p.dur, 0.0, 1.0)
		if k <= 0.0:
			continue
		var col: Color = p.col
		var dst: = button_center(int(p.idx))

		var ctrl: = center.lerp(dst, 0.55) + Vector2(0, - ry * 0.16)
		var head: = _bezier(center, ctrl, dst, ease(k, 0.4))
		var fade: = 1.0 - k * k
		for t in 5:
			var kt: = maxf(0.0, ease(k, 0.4) - t * 0.055)
			var q: = _bezier(center, ctrl, dst, kt)
			draw_circle(q, (2.4 - t * 0.35) * (0.6 + 0.4 * fade), 
				Color(col.r * 1.2, col.g * 1.2, col.b * 1.2, 
					(0.55 - t * 0.1) * fade))
		if glow_tex != null:
			draw_texture_rect(glow_tex, Rect2(head - Vector2(16, 16), 
				Vector2(32, 32)), false, 
				Color(col.r, col.g, col.b, 0.35 * fade))




func _under_button(p: Vector2) -> bool:
	for k in buttons.size():
		var ob: OrbitButton = buttons[k]
		if ob.appear <= 0.02:
			continue
		if p.distance_to(button_center(k)) < ob.radius * ob.scale.x + 7.0:
			return true
	return false


static func _bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: = 1.0 - t
	return a * (u * u) + b * (2.0 * u * t) + c * (t * t)
