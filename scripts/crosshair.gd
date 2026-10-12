class_name Crosshair
extends Node2D













const MAX_EMBERS: = 40




var main

var _hist: Array = []
var _embers: Array = []
var _rng: = RandomNumberGenerator.new()



var _ping: = 0.0
var _ping_at: = Vector2.ZERO


func _process(delta: float) -> void :
	if main != null:



		var p: Vector2 = main.auto_cursor if _auto_active() else main.aim_position()
		_hist.append(p)
		var fever: = _fever()
		var keep: int = 30 if _auto_active() else 16 + int(12.0 * fever)
		while _hist.size() > keep:
			_hist.pop_front()
		_update_embers(p, fever, delta)
	_ping = maxf(0.0, _ping - delta * 3.4)
	queue_redraw()




func ping() -> void :
	_ping = 1.0
	_ping_at = main.aim_position() if main != null else Vector2.ZERO



func _auto_active() -> bool:
	return main.auto_mode and main.screen == main.Screen.PLAYING




func _fever() -> float:
	if main.auto_mode or main.screen != main.Screen.PLAYING:
		return 0.0
	return main.fever





func _update_embers(p: Vector2, fever: float, delta: float) -> void :
	if fever > 0.25:
		var moving: = _hist.size() > 1\
		and (_hist[_hist.size() - 2] as Vector2).distance_to(p) > 1.5
		var births: = 1 + int(fever * 2.0) + (2 if moving else 0)
		for i in births:
			if _embers.size() >= MAX_EMBERS:
				break
			_embers.append({
				"p": p + Vector2(_rng.randf_range(-7.0, 7.0), _rng.randf_range(-7.0, 7.0)), 
				"v": Vector2(_rng.randf_range(-28.0, 28.0), 
					_rng.randf_range(-95.0, -35.0) - 55.0 * fever), 
				"life": 0.0, 
				"max": _rng.randf_range(0.22, 0.5), 
			})
	for e in _embers:
		e.life += delta
		e.p += e.v * delta
		e.v.x += sin((e.life + e.max * 10.0) * 26.0) * 55.0 * delta
		if fever <= 0.01:
			e.max = minf(e.max, e.life + 0.08)
	_embers = _embers.filter( func(e): return e.life < e.max)


func _draw() -> void :
	if main == null or _hist.is_empty():
		return
	var auto: bool = _auto_active()
	var fever: = _fever()
	var p: Vector2 = _hist[_hist.size() - 1]
	var col: = Skins.col("cursor_auto") if auto\
	else Skins.col("cursor").lerp(Skins.col("cursor_hot"), fever)


	if _ping > 0.01:
		var pk: = 1.0 - _ping
		draw_arc(_ping_at, 6.0 + 26.0 * ease(pk, 0.35), 0.0, TAU, 28, 
			Color(col.r, col.g, col.b, 0.45 * _ping * _ping), 1.4, true)


	for e in _embers:
		var k: float = 1.0 - e.life / e.max
		var ec: = Skins.col("ember_die").lerp(Skins.col("ember_born"), k)
		draw_circle(e.p, 1.4 + 2.4 * k, Color(ec.r, ec.g, ec.b, 0.8 * k))



	var tr_a: = 0.6 if auto else 0.38 + 0.22 * fever
	var tr_w: = 7.0 if auto else 3.5 + 3.5 * fever
	for i in range(1, _hist.size()):
		var t: = float(i) / float(_hist.size())
		draw_line(_hist[i - 1], _hist[i], 
			Color(col.r, col.g, col.b, tr_a * t * t), 1.5 + tr_w * t)
	if auto or fever > 0.45:

		var core_a: = 0.55 if auto else 0.5 * (fever - 0.45) / 0.55
		for i in range(_hist.size() / 2, _hist.size()):
			var t2: = float(i) / float(_hist.size())
			draw_line(_hist[i - 1], _hist[i], 
				Color(col.r * 1.8, col.g * 1.8, col.b * 1.8, core_a * t2 * t2), 
				1.0 + 2.0 * t2)


	for k in ([4, 9, 14, 20] if auto else [5, 10]):
		if _hist.size() > k:
			var hp: Vector2 = _hist[_hist.size() - 1 - k]
			if hp.distance_to(p) > 12.0:
				var ar: = 14.0 if auto else 10.0
				draw_arc(hp, ar, 0.0, TAU, 24, 
					Color(col.r, col.g, col.b, (0.34 if auto else 0.22) - 0.012 * k), 2.5)


	var glow_tex: Texture2D = main.game_glow()
	if glow_tex != null:
		var hs: = 150.0 if auto else 88.0 + 42.0 * fever
		draw_texture_rect(glow_tex, Rect2(p - Vector2(hs, hs) * 0.5, Vector2(hs, hs)), 
			false, Color(col.r, col.g, col.b, (0.52 if auto else 0.35 + 0.13 * fever)))


	var r: = 14.0
	if auto:

		r = 20.0 + 3.0 * main.beat_pulse()
		draw_arc(p, r + 9.0, 0.0, TAU, 40, Color(col.r, col.g, col.b, 0.38), 2.0)
	elif fever > 0.85:



		var fk: = (fever - 0.85) / 0.15
		var tms: = Time.get_ticks_msec() / 1000.0
		var wisp: Color = Skins.col("cursor_hot") * 1.5
		for i in 3:
			var a0: = tms * 4.2 + float(i) * TAU / 3.0
			draw_arc(p, r + 6.5, a0, a0 + TAU * 0.16, 10, 
				Color(wisp.r, wisp.g, wisp.b, 0.9 * fk), 2.5)
			draw_arc(p, r + 6.5, a0 + TAU * 0.16, a0 + TAU * 0.23, 6, 
				Color(wisp.r, wisp.g, wisp.b, 0.32 * fk), 2.0)


	var tx: Texture2D = Skins.tex("cursor")
	if tx != null:
		var ts: = (r + 9.0) * 1.15
		draw_texture_rect(tx, Rect2(p - Vector2(ts, ts), Vector2(ts, ts) * 2.0), 
			false, Color.WHITE)
	else:
		draw_arc(p, r, 0.0, TAU, 32, 
			Color(col.r * 1.4, col.g * 1.4, col.b * 1.4, 0.95), 4.5 if auto else 3.0)
		draw_circle(p, 4.0 if auto else 2.5, Color(col.r * 1.5, col.g * 1.5, col.b * 1.5))


	if auto:
		draw_circle(main.aim_position(), 3.0, Color(Skins.col("cursor"), 0.6))
