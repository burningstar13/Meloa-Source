class_name AscensionRing
extends Control















signal unlock_finished

var lit: = 0
var segments: int = ProfileRules.RANK_LADDER.size()
var thickness: = 3.0
var gap_deg: = 5.0
var breathe: = true

var intensity: = 1.0

var _phase: = 0.0
var _flash: = 0.0
var _pulse_pos: = -1.0
var _shimmer: = 0.0
var _light: = 0.0
var _burst: = 0.0
var _reveal: = 1.0
var _unlocking: = false
var _tw: Tween


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _ready() -> void :
	_update_processing()
	visibility_changed.connect(_update_processing)


func set_lit(n: int, reveal: = false) -> void :
	lit = clampi(n, 0, segments)
	if reveal:
		_reveal = 0.0
		if _tw != null and _tw.is_valid():
			_tw.kill()
		_tw = create_tween()
		_tw.tween_property(self, "_reveal", 1.0, 0.55).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tw.tween_callback(queue_redraw)
	queue_redraw()
	_update_processing()


func _update_processing() -> void :
	set_process(is_visible_in_tree() and (breathe and lit < segments or _unlocking or _reveal < 1.0 or _flash > 0.0))


func _process(delta: float) -> void :
	_phase += delta
	if _flash > 0.0:
		_flash = maxf(_flash - delta * 3.0, 0.0)
	queue_redraw()
	if not (breathe and lit < segments) and not _unlocking and _reveal >= 1.0 and _flash <= 0.0:
		set_process(false)



func flash_last() -> void :
	_flash = 1.0
	set_process(true)


func _seg_angles(i: int) -> Array:

	var span: = TAU / float(segments)
	var g: = deg_to_rad(gap_deg) * 0.5
	var a0: = - PI * 0.5 + span * i + g
	return [a0, a0 + span - 2.0 * g]


func segment_center(i: int) -> Vector2:
	var a: Array = _seg_angles(i)
	var mid: = (float(a[0]) + float(a[1])) * 0.5
	return size * 0.5 + Vector2(cos(mid), sin(mid)) * _radius()


func _radius() -> float:
	return minf(size.x, size.y) * 0.5 - thickness * 0.5 - 1.0


func _draw() -> void :
	var c: = size * 0.5
	var r: = _radius()
	if r <= 2.0:
		return
	var pts: = 14
	for i in segments:
		var a: Array = _seg_angles(i)
		var a0: = float(a[0])
		var a1: = float(a[1])
		var is_lit: = i < lit
		var is_last: = i == lit - 1
		var is_next: = i == lit
		if is_lit:
			var col: = ProfileRules.ring_segment_color(i)
			var alpha: = (0.62 if not is_last else 0.95) * intensity


			if _reveal < 1.0:
				var t: = clampf((_reveal * float(lit) - float(i)), 0.0, 1.0)
				alpha *= t
			if is_last and _flash > 0.0:
				alpha = minf(alpha + 0.5 * _flash, 1.0)
			var w: = thickness + (0.8 if is_last else 0.0)
			if _pulse_pos >= 0.0:
				var d: = absf(_pulse_pos - float(i))
				if d < 1.2:
					alpha = minf(alpha + (1.2 - d) * 0.5, 1.0)
					w += (1.2 - d) * 1.2
			draw_arc(c, r, a0, a1, pts, Color(col, alpha), w, true)
			if is_last and intensity >= 0.9:

				draw_arc(c, r, a0, a1, pts, Color(col, 0.16 + 0.25 * _flash), w + 3.0, true)
		elif is_next:
			var col: = ProfileRules.ring_segment_color(i)
			var base: = 0.1
			if breathe:
				base += 0.1 * (0.5 + 0.5 * sin(_phase * 1.6))
			if _shimmer > 0.0:
				base += 0.55 * _shimmer * (0.5 + 0.5 * sin(_phase * 22.0))
			if _light > 0.0:
				base = maxf(base, _light)
			draw_arc(c, r, a0, a1, pts, Color(1, 1, 1, 0.1), thickness, true)
			draw_arc(c, r, a0, a1, pts, Color(col, base * intensity), thickness + _light * 1.5, true)
			if _burst > 0.0:
				var sc: = segment_center(i)
				var bt: = ProfileTheme.fx_tex("burst_soft")
				var bs: = (18.0 + 36.0 * _burst) * (r / 40.0)
				if bt != null:
					draw_texture_rect(bt, Rect2(sc - Vector2(bs, bs), Vector2(bs, bs) * 2.0), false, 
						Color(col, (1.0 - _burst) * 0.85))
				else:
					draw_circle(sc, bs * 0.5, Color(col, (1.0 - _burst) * 0.5))
		else:
			draw_arc(c, r, a0, a1, pts, Color(1, 1, 1, 0.07), thickness, true)





func play_unlock(new_lit: int) -> void :
	new_lit = clampi(new_lit, lit, segments)
	if _unlocking or new_lit <= lit:


		unlock_finished.emit.call_deferred()
		return
	_unlocking = true
	set_process(true)
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween()

	_tw.tween_property(self, "_shimmer", 1.0, 0.12)
	_tw.tween_interval(0.3)

	_tw.tween_property(self, "_pulse_pos", float(lit), 0.42).from(-0.5)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

	_tw.tween_callback( func() -> void :
		_pulse_pos = -1.0
		_shimmer = 0.0)
	_tw.tween_property(self, "_light", 1.0, 0.16).set_ease(Tween.EASE_OUT)

	_tw.tween_callback( func() -> void :
		_burst = 0.001)
	_tw.tween_property(self, "_burst", 1.0, 0.45).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	_tw.tween_callback( func() -> void :
		lit = new_lit
		_burst = 0.0
		_light = 0.0
		_flash = 1.0
		_unlocking = false
		queue_redraw()
		_update_processing()
		unlock_finished.emit())
