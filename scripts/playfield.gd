class_name Playfield
extends Node2D




const StageRender = preload("res://scripts/stage_render.gd")
const PerfFlags = preload("res://scripts/perf_flags.gd")

var tuning: Tuning
var main




func _diamond(c: Vector2, r: float, col: Color) -> void :
	StageRender.diamond(self, c, r, col)


var _lane_layers: Array = []


func _ensure_lane_layers() -> void :
	if _lane_layers.size() == 3:
		return
	for l in _lane_layers:
		if is_instance_valid(l):
			l.queue_free()
	_lane_layers.clear()
	for i in 3:
		var layer: = LaneLayer.new()
		layer.field = self
		layer.lane = i
		layer.show_behind_parent = true
		add_child(layer)
		_lane_layers.append(layer)


func _draw() -> void :
	if tuning == null or main == null or not PerfFlags.field_draw:
		return
	var size: = get_viewport_rect().size
	var half: = tuning.lane_width * 0.5
	var half_top: float = half * main.LANE_PERSPECTIVE
	var active: int = main.player.lane
	var pulse: float = main.beat_pulse()



	var sweep: float = main.lane_clear * main.lane_clear\
	* (3.0 - 2.0 * main.lane_clear)



	_ensure_lane_layers()
	for i in 3:
		var layer: LaneLayer = _lane_layers[i]
		var fxa: float = clampf(minf(float(main.fx_alpha[i]), 1.0 - float(main.fx_gone[i])), 0.0, 1.0)
		layer.visible = fxa > 0.004 and sweep < 0.999
		layer.modulate = Color(1, 1, 1, fxa)
		layer.queue_redraw()



	var y: = tuning.hit_y
	var flash: float = main.line_flash
	var fcol: Color = main.line_flash_col
	var la: = 0.85 + 0.15 * pulse
	var glow_k: = 1.35 + 0.25 * pulse


	var cl: Color = main.neon(main.LANE_COLS[0], glow_k).lerp(fcol, flash * 0.8)
	var cm: Color = main.neon(main.LANE_COLS[1], glow_k).lerp(fcol, flash * 0.8)
	var cr: Color = main.neon(main.LANE_COLS[2], glow_k).lerp(fcol, flash * 0.8)
	var th: = 2.0 + 1.2 * pulse + 2.6 * flash
	var x0: float = main.lane_x(0) - half - 30.0
	var x1: float = main.lane_x(2) + half + 30.0
	var edge_a: = la * 0.22
	var line_tx: Texture2D = Skins.tex("impact_line")
	if line_tx != null:


		var lh_px: float = maxf(size.x * float(line_tx.get_height()) / maxf(float(line_tx.get_width()), 1.0), 4.0)
		var ltint: = Color(1, 1, 1, la).lerp(Color(fcol.r, fcol.g, fcol.b, 1.0), flash * 0.8)
		draw_texture_rect(line_tx, Rect2(0.0, y - lh_px * 0.5, size.x, lh_px), false, ltint)
	var segs_line: Array = [] if line_tx != null else [
		[0.0, x0, Color(cl.r, cl.g, cl.b, edge_a), Color(cl.r, cl.g, cl.b, la)], 
		[x0, size.x * 0.5, Color(cl.r, cl.g, cl.b, la), Color(cm.r, cm.g, cm.b, la)], 
		[size.x * 0.5, x1, Color(cm.r, cm.g, cm.b, la), Color(cr.r, cr.g, cr.b, la)], 
		[x1, size.x, Color(cr.r, cr.g, cr.b, la), Color(cr.r, cr.g, cr.b, edge_a)], 
	]
	for sl in segs_line:
		draw_polygon(PackedVector2Array([
			Vector2(sl[0], y - th), Vector2(sl[1], y - th), 
			Vector2(sl[1], y + th), Vector2(sl[0], y + th), 
		]), PackedColorArray([sl[2], sl[3], sl[3], sl[2]]))





	if main.on_fire and SettingsManager.fx_fire and main.screen == main.Screen.PLAYING:
		var tf: = Time.get_ticks_msec() / 1000.0
		var _embers: = SettingsManager.qn(8)
		for i in 3:
			var fxb: float = main.lane_x(i)

			if main.game_glow() != null:
				var gw: float = tuning.lane_width * 1.9
				draw_texture_rect(main.game_glow(), 
					Rect2(Vector2(fxb - gw * 0.5, y - gw * 0.3), Vector2(gw, gw * 0.6)), 
					false, Color(1.3, 0.85, 0.35, 0.24 + 0.1 * pulse))


			for j in _embers:
				var ph: = float(j) * 1.73 + float(i) * 2.31
				var rise: = fposmod(tf * (46.0 + 10.0 * sin(ph * 3.7)) + ph * 53.0, 150.0)
				var px: = fxb + ((float(j) + 0.5) / float(maxi(_embers, 1)) - 0.5) * tuning.lane_width * 0.84\
				+ sin(tf * 2.2 + ph) * 7.0
				var pk: = 1.0 - rise / 150.0
				draw_circle(Vector2(px, y - 5.0 - rise), 1.7 + 1.9 * pk, 
					Color(1.5, 1.05, 0.45, 0.62 * pk))




	var last_ms: float = tuning.last_window_ms()
	var bar_c: = Vector2(size.x * 0.5, tuning.hit_y + 84.0)
	var bar_w: = 300.0
	draw_line(bar_c + Vector2( - bar_w * 0.5, 0), bar_c + Vector2(bar_w * 0.5, 0), 
		Color(1, 1, 1, 0.12), 2.0)
	var pw: = bar_w * (tuning.perfect_window_ms / last_ms) * 0.5
	draw_line(bar_c + Vector2( - pw, 0), bar_c + Vector2(pw, 0), 
		Color(Skins.col("timing_perfect"), 0.22), 4.0)
	draw_line(bar_c + Vector2(0, -7), bar_c + Vector2(0, 7), Color(1, 1, 1, 0.5), 2.0)
	var now: = Time.get_ticks_msec()
	for h in main.hit_deltas:
		var age: float = (now - h.t) / 3000.0
		if age >= 1.0:
			continue
		var frac: float = clampf(h.d / last_ms, -1.0, 1.0)
		var tick_col: Color = Skins.col("timing_perfect")\
		if absf(h.d) <= tuning.perfect_window_ms\
		else (Skins.col("timing_good") if absf(h.d) <= tuning.good_window_ms
			else Skins.col("judge_meh"))
		tick_col.a = (1.0 - age) * 0.85
		var tx: = bar_c.x + frac * bar_w * 0.5
		draw_line(Vector2(tx, bar_c.y - 6), Vector2(tx, bar_c.y + 6), tick_col, 2.0)




	if main.settings_ui != null and main.settings_ui.visible\
	and SettingsManager.input_device == "TABLET":
		var zsize: = Vector2(size.x * SettingsManager.tablet_area_w, 
			size.y * SettingsManager.tablet_area_h)
		draw_rect(Rect2((size - zsize) * 0.5, zsize), Color(0.45, 1.0, 0.75, 0.55), false, 2.0)









func _draw_lane(c: CanvasItem, i: int) -> void :
	if tuning == null or main == null or not PerfFlags.field_draw:
		return
	var size: = get_viewport_rect().size
	var half: = tuning.lane_width * 0.5
	var half_top: float = half * main.LANE_PERSPECTIVE
	var active: int = main.player.lane
	var pulse: float = main.beat_pulse()
	var sweep: float = main.lane_clear * main.lane_clear\
	* (3.0 - 2.0 * main.lane_clear)
	if sweep >= 0.999:
		return



	var g: float = main.fx_gone[i]
	if g >= 0.999:
		return
	var off: = Vector2.ZERO
	if sweep > 0.001:
		off = Vector2(0.0, - (tuning.hit_y + 160.0) * sweep) if i == 1\
		else Vector2(size.x * 0.55 * sweep * (1.0 if i == 2 else -1.0), 0.0)
	if g > 0.001:
		off.y += 140.0 * g * g
	if off != Vector2.ZERO:
		c.draw_set_transform(off, 0.0, Vector2.ONE)
	var col: Color = main.LANE_COLS[i]
	var xb: float = main.lane_x(i)
	var xt: float = main.lane_x_at(i, 0.0)
	var is_active: = i == active and g < 0.5


	var lh: float = half * main.fx_width[i] * (1.0 - g)
	var lh_top: float = half_top * main.fx_width[i] * (1.0 - g)



	var quad: = StageRender.lane_quad(xb, lh, size.x * 0.5, 
		main.LANE_PERSPECTIVE, 0.0, tuning.hit_y)


	var shade: Color = Skins.col("lane_shade")
	c.draw_polygon(quad, PackedColorArray([
		Color(shade, 0.3), Color(shade, 0.3), 
		Color(shade, 0.48), Color(shade, 0.48), 
	]))


	var fill_a: = 0.075 + 0.025 * pulse if is_active else 0.02
	var lane_tx: Texture2D = Skins.tex("lane_fill")
	if lane_tx != null:



		var ta: = 0.85 if is_active else 0.65
		c.draw_polygon(quad, PackedColorArray([
			Color(col.r, col.g, col.b, ta), Color(col.r, col.g, col.b, ta), 
			Color(col.r, col.g, col.b, ta), Color(col.r, col.g, col.b, ta), 
		]), PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]), 
			lane_tx)
	else:
		c.draw_polygon(quad, PackedColorArray([
			Color(col.r, col.g, col.b, fill_a), Color(col.r, col.g, col.b, fill_a), 
			Color(col.r, col.g, col.b, fill_a * 0.25), Color(col.r, col.g, col.b, fill_a * 0.25), 
		]))

	if main.game_glow() != null:
		var gw: float = tuning.lane_width * 2.6
		c.draw_texture_rect(main.game_glow(), 
			Rect2(Vector2(xt - gw * 0.5, - gw * 0.42), Vector2(gw, gw * 0.8)), 
			false, Color(col.r, col.g, col.b, (0.16 if is_active else 0.09) + 0.05 * pulse))

	for k in SettingsManager.qn(3):
		var cy: = fposmod(Time.get_ticks_msec() / 1000.0 * 55.0 + float(k) * tuning.hit_y / 3.0, 
			tuning.hit_y - 40.0) + 20.0
		var cx: float = main.lane_x_at(i, cy)
		var ca: = (0.1 if is_active else 0.05) * (1.0 - cy / tuning.hit_y)
		var cw: = 20.0
		c.draw_polyline(PackedVector2Array([
			Vector2(cx - cw, cy - 9.0), Vector2(cx, cy + 4.0), Vector2(cx + cw, cy - 9.0), 
		]), Color(col.r, col.g, col.b, ca), 2.0)

	var edge: Color = main.neon(col, 1.9) if is_active else main.neon(col, 1.3)
	edge.a = 1.0 if is_active else 0.45
	c.draw_line(Vector2(xt - lh_top, 0), Vector2(xb - lh, tuning.hit_y), edge, 2.0)
	c.draw_line(Vector2(xt + lh_top, 0), Vector2(xb + lh, tuning.hit_y), edge, 2.0)





	if main.on_fire and SettingsManager.fx_fire:
		var since: float = (Time.get_ticks_msec() - main.fire_ignite_ms) / 1000.0
		var fk: = clampf((since
			- 0.03 * absf(float(i - main.fire_ignite_lane))) / 0.18, 0.0, 1.0)
		if fk > 0.0:
			var fy: = tuning.hit_y * (1.0 - fk)
			var fcx: float = main.lane_x_at(i, fy)
			var fhw: = lh * lerpf(main.LANE_PERSPECTIVE, 1.0, fy / tuning.hit_y)


			var warm: = col.lerp(Color(1.3, 0.85, 0.35), 0.3)
			var va: = 0.016 + 0.075 * (1.0 - fk)
			var vcol: = Color(1.3, 0.9, 0.4).lerp(warm, fk)
			c.draw_polygon(PackedVector2Array([
				Vector2(fcx - fhw, fy), Vector2(fcx + fhw, fy), 
				Vector2(xb + lh, tuning.hit_y), Vector2(xb - lh, tuning.hit_y), 
			]), PackedColorArray([
				Color(vcol.r, vcol.g, vcol.b, va), Color(vcol.r, vcol.g, vcol.b, va), 
				Color(vcol.r, vcol.g, vcol.b, va * 1.7), Color(vcol.r, vcol.g, vcol.b, va * 1.7), 
			]))

			if fk < 1.0:
				var ty: = minf(fy + 90.0, tuning.hit_y)
				var tcx: float = main.lane_x_at(i, ty)
				var thw: = lh * lerpf(main.LANE_PERSPECTIVE, 1.0, ty / tuning.hit_y)
				c.draw_polygon(PackedVector2Array([
					Vector2(fcx - fhw, fy), Vector2(fcx + fhw, fy), 
					Vector2(tcx + thw, ty), Vector2(tcx - thw, ty), 
				]), PackedColorArray([
					Color(1.6, 1.15, 0.45, 0.45), Color(1.6, 1.15, 0.45, 0.45), 
					Color(1.3, 0.8, 0.3, 0.0), Color(1.3, 0.8, 0.3, 0.0), 
				]))
				c.draw_line(Vector2(fcx - fhw, fy), Vector2(fcx + fhw, fy), 
					Color(1.7, 1.35, 0.6, 0.9), 3.0)


			var ecol: Color = main.neon(col.lerp(Color(1.4, 1.0, 0.45), 0.25), 1.6)
			var ea: = 0.38 + 0.15 * pulse + 0.35 * (1.0 - fk)
			c.draw_line(Vector2(xb - lh, tuning.hit_y), Vector2(fcx - fhw, fy), 
				Color(ecol.r, ecol.g, ecol.b, ea), 3.0)
			c.draw_line(Vector2(xb + lh, tuning.hit_y), Vector2(fcx + fhw, fy), 
				Color(ecol.r, ecol.g, ecol.b, ea), 3.0)


			var tfs: = Time.get_ticks_msec() / 1000.0
			for sside in 2:
				for j in SettingsManager.qn(4):
					var ph: = float(j) * 2.13 + float(i) * 1.57 + float(sside) * 3.31
					var climb: = fposmod(tfs * (95.0 + 28.0 * sin(ph * 2.9)) + ph * 61.0, 
						tuning.hit_y - 40.0)
					if climb > fk * (tuning.hit_y - 40.0):
						continue
					var sy: = tuning.hit_y - climb
					var scx: float = main.lane_x_at(i, sy)
					var shw: = lh * lerpf(main.LANE_PERSPECTIVE, 1.0, sy / tuning.hit_y)
					var sx: = scx + (shw if sside == 1 else - shw) + sin(tfs * 3.1 + ph) * 3.0
					var sk: = 1.0 - climb / (tuning.hit_y - 40.0)
					var scol: = col.lerp(Color(1.5, 1.05, 0.45), 0.45)
					c.draw_circle(Vector2(sx, sy), 1.4 + 1.4 * sk, 
						Color(scol.r * 1.3, scol.g * 1.3, scol.b * 1.3, 0.3 + 0.4 * sk))

	var rr: = (15.0 + 3.0 * pulse) * (1.0 - g)
	var rec: = Vector2(xb, tuning.hit_y)

	if main.game_glow() != null:
		var rg: = 90.0 + 26.0 * pulse
		c.draw_texture_rect(main.game_glow(), 
			Rect2(rec - Vector2(rg * 0.5, rg * 0.5), Vector2(rg, rg)), 
			false, Color(col.r, col.g, col.b, (0.3 if is_active else 0.16) + 0.1 * pulse))
	StageRender.receptor(c, rec, rr, col, is_active, 
		main.neon(col, 1.25), main.neon(col, 1.7))





class LaneLayer extends Node2D:
	var field: Playfield
	var lane: = 0

	func _draw() -> void :
		field._draw_lane(self, lane)
