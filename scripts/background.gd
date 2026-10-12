class_name Background
extends Node2D
const PerfFlags = preload("res://scripts/perf_flags.gd")
const Spectrum = preload("res://scripts/spectrum.gd")
const DrawBatch = preload("res://scripts/draw_batch.gd")






var _qk: = 1.0

func _qn(n: int) -> int:
	return maxi(int(float(n) * _qk), 0)






var main



var pulse: = 0.0




var warp: = 0.0




var beat_hit: = 0.0



var home_reveal: = 1.0




var results_mode: = false



var hit_flash: = 0.0
var hit_flash_col: = Color(1.35, 1.33, 1.25)




var _fire: = 0.0





var theme_a: = "rings"
var theme_b: = "rings"
var theme_mix: = 1.0
var theme_col_a: = Color(0, 0, 0, 0)
var theme_col_b: = Color(0, 0, 0, 0)






var ambient_col: = Color(0.6, 0.38, 1.0)
var ambient_w: = 0.0


const PALETTE: = [
	Color(0.3, 1.0, 0.85), Color(0.72, 0.45, 1.0), 
	Color(1.0, 0.78, 0.25), Color(1.0, 1.0, 1.0), 
]

var _parts: Array = []
var _last_beat: = -999
var _eq: Array = []




var _spec_frame: = -100
var _side_lvls: = PackedFloat32Array()
var _home_lvls: = PackedFloat32Array()




func _spec_refresh() -> bool:
	var t: = Spectrum.tick()
	if t != _spec_frame:
		_spec_frame = t
		return true
	return false


func _spec_level(f0: float, f1: float) -> float:
	return Spectrum.level(f0, f1)


func _ready() -> void :
	for i in 28:
		_eq.append(0.0)
	_side_lvls.resize(16)
	_home_lvls.resize(7)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 20260710
	for i in 46:
		_parts.append({
			"x": rng.randf(), 
			"y": rng.randf(), 
			"spd": rng.randf_range(0.012, 0.05), 
			"size": rng.randf_range(1.5, 4.5), 
			"tint": rng.randf(), 
			"cix": rng.randi_range(0, 3), 
		})





func _beats() -> float:
	if main != null and main.beat_bus != null:
		return main.beat_bus.beats()
	if main != null and main.conductor.playing:
		var t: float = main.conductor.get_song_time()
		if t > 0.0:
			return t * main.chart_bpm / 60.0
	return Time.get_ticks_msec() / 1000.0 * 2.0





func on_beat(strength: float) -> void :
	beat_hit = maxf(beat_hit, clampf(strength, 0.0, 1.0))


func _process(delta: float) -> void :
	var beats: = _beats()
	var bi: = int(floor(beats))
	if bi != _last_beat:
		_last_beat = bi
		pulse = 1.0
	pulse = maxf(0.0, pulse - delta * 3.0)
	beat_hit = maxf(0.0, beat_hit - delta * 2.0)
	hit_flash = maxf(0.0, hit_flash - delta * 7.0)
	var fire_target: = 1.0 if (main != null and main.on_fire
		and SettingsManager.fx_fire) else 0.0
	_fire = minf(fire_target, _fire + delta * 2.5) if fire_target > _fire\
	else maxf(fire_target, _fire - delta * 1.2)
	var np: = int(float(_parts.size()) * SettingsManager.quality_density()) if SettingsManager.vis_on("bg_particles") else 0
	for pi in np:
		var p: Dictionary = _parts[pi]

		p.y -= p.spd * delta * (1.0 + pulse * 1.5 + 2.5 * _fire)
		if p.y < -0.05:
			p.y += 1.1
			p.x = fmod(p.x + 0.37, 1.0)
	queue_redraw()


func _draw() -> void :
	if not PerfFlags.bg_draw:
		return
	_qk = SettingsManager.quality_density()
	var vs: = get_viewport_rect().size







	var is_home: bool = main != null and (main.screen != main.Screen.PLAYING or results_mode)



	var bg_tex: Texture2D = null
	var is_video: = false
	if main != null:

		if SettingsManager.gfx_map_bg:

			bg_tex = main.bg_video_texture()
			is_video = bg_tex != null
			if bg_tex == null:




				bg_tex = main.track_bgs.tex(main.tuning.current_track)\
				if main.screen == main.Screen.PLAYING\
				else main.track_covers.tex(main.tuning.current_track)


		if is_home and main.menu_bg_tex != null:
			bg_tex = main.menu_bg_tex
			is_video = false
	if bg_tex != null and bg_tex.get_size().x < 1.0:
		bg_tex = null
		is_video = false


	var sbg: Dictionary = Skins.background()
	var skin_replace: = not sbg.is_empty() and String(sbg.get("mode", "replace")) == "replace"
	if skin_replace:
		bg_tex = sbg.tex
		is_video = false
	if bg_tex != null:
		var ts: Vector2 = bg_tex.get_size()
		var sc: = maxf(vs.x / ts.x, vs.y / ts.y)
		var dsz: = ts * sc




		var tint: = Color(0.62, 0.62, 0.66) if is_video\
		else Color(0.38, 0.38, 0.46)
		if is_home and main != null and bg_tex == main.menu_bg_tex:
			tint = Color(0.92, 0.92, 0.95)
		if skin_replace:
			var dk: float = 1.0 - float(sbg.get("dim", 0.0))
			tint = Color(dk, dk, dk, float(sbg.get("opacity", 1.0)))
		draw_texture_rect(bg_tex, Rect2((vs - dsz) * 0.5, dsz), false, tint)
	if not sbg.is_empty() and not skin_replace:
		var stx: Texture2D = sbg.tex
		var sts: Vector2 = stx.get_size()
		var ssc: = maxf(vs.x / sts.x, vs.y / sts.y)
		var sdsz: = sts * ssc
		var sdk: float = 1.0 - float(sbg.get("dim", 0.0))
		draw_texture_rect(stx, Rect2((vs - sdsz) * 0.5, sdsz), false, 
			Color(sdk, sdk, sdk, float(sbg.get("opacity", 1.0))))





	var grad_a: = 1.0
	if bg_tex != null:
		grad_a = 0.45 if is_video else 0.8




	var gd: = 0.45 if is_home else 1.0
	if is_home and main != null and main.menu_bg_tex != null:
		grad_a = 0.22
		gd = 0.6
	draw_polygon(
		PackedVector2Array([Vector2.ZERO, Vector2(vs.x, 0), vs, Vector2(0, vs.y)]), 
		PackedColorArray([
			Color(0.012 * gd, 0.026 * gd, 0.058 * gd, grad_a), 
			Color(0.036 * gd, 0.02 * gd, 0.07 * gd, grad_a), 
			Color(0.078 * gd, 0.026 * gd, 0.062 * gd, grad_a), 
			Color(0.022 * gd, 0.03 * gd, 0.082 * gd, grad_a), 
		]))



	if hit_flash > 0.01:
		draw_rect(Rect2(Vector2.ZERO, vs), Color(hit_flash_col.r, hit_flash_col.g, 
			hit_flash_col.b, 0.035 * hit_flash))






	if _fire > 0.01:


		draw_polygon(
			PackedVector2Array([Vector2.ZERO, Vector2(vs.x, 0), vs, Vector2(0, vs.y)]), 
			PackedColorArray([
				Color(0.45, 0.12, 0.04, 0.0), Color(0.45, 0.12, 0.04, 0.0), 
				Color(0.6, 0.18, 0.06, 0.05 * _fire), Color(0.55, 0.15, 0.05, 0.05 * _fire), 
			]))
		if main != null and main.glow_tex != null:
			var fw: = vs.x * 1.5
			var fh: = 460.0
			draw_texture_rect(main.glow_tex, 
				Rect2(Vector2((vs.x - fw) * 0.5, vs.y - fh * 0.52), Vector2(fw, fh)), 
				false, Color(1.2, 0.52, 0.16, (0.12 + 0.06 * pulse) * _fire))


		var tb: = Time.get_ticks_msec() / 1000.0
		for e in (_qn(16) if SettingsManager.vis_on("bg_particles") else 0):
			var eph: = float(e) * 39.77
			var climb: = fposmod(tb * (55.0 + 20.0 * sin(eph)) + eph * 13.1, vs.y * 0.85)
			var ey: = vs.y - 30.0 - climb
			var ex: = fposmod(eph * 7.31, vs.x) + sin(tb * 1.6 + eph) * 26.0
			var ek: = 1.0 - climb / (vs.y * 0.85)
			draw_circle(Vector2(ex, ey), 1.5 + 2.0 * ek, 
				Color(1.4, 0.75, 0.3, (0.08 + 0.3 * ek) * _fire))



	var hue: = 0.5
	var heat: = 0.0
	var in_game: = false
	var home: = false
	if main != null:
		hue = float(posmod(hash(main.tuning.current_track), 360)) / 360.0
		heat = clampf(main.combo / 50.0, 0.0, 1.0)
		in_game = main.screen == main.Screen.PLAYING
		home = is_home
	var viol: = Color(0.6, 0.38, 1.0)
	if home:



		viol = Color(0.42, 0.24, 0.8)
	elif ambient_w > 0.001:



		var amb: = Color(ambient_col.r, ambient_col.g, ambient_col.b)
		viol = viol.lerp(amb, clampf(ambient_w, 0.0, 1.0) * 0.85)
	var acc: = viol.lerp(Color.from_hsv(hue, 0.55, 1.0), 0.4)










	var home_c: = Vector2(vs.x * 0.5, vs.y * 0.44)
	var menu_c: = Vector2(vs.x * 0.5, vs.y * 0.42)
	var rc: = menu_c
	if main != null and main.screen == main.Screen.HOME:
		rc = home_c
	elif main != null and main.screen == main.Screen.SELECT:



		rc = _menu_focus(vs)
	else:
		rc = menu_c.lerp(home_c, warp)
	var rot: = _beats() * 0.02
	var rose: = Color(1.0, 0.45, 0.75)










	var abg: = 1.0 if SettingsManager.vis_on("bg_patterns") else 0.0
	if home:
		_draw_home_light(vs, rc, viol)
	elif abg > 0.01:
		if theme_mix < 0.999 and (theme_a != theme_b or theme_col_a != theme_col_b):
			_draw_motif(theme_a, theme_col_a, (1.0 - theme_mix) * abg, vs, rc, rot, viol, heat)
		_draw_motif(theme_b, theme_col_b, minf(theme_mix, 1.0) * abg, vs, rc, rot, viol, heat)







	if not home and abg >= 0.3:
		var c: = Vector2(vs.x * 0.5, vs.y * 0.78)
		var halo_c: = viol.lerp(Color(1.0, 0.5, 0.18), 0.6 * _fire)
		for i in 3:
			var r: = (260.0 + 90.0 * i) * (1.0 + 0.05 * pulse)
			draw_circle(c, r, Color(halo_c.r, halo_c.g, halo_c.b, 
				(0.008 + 0.008 * heat + 0.01 * _fire)
					* (1.0 + pulse * 0.5) / (i + 1.0)))





	var beats_now: = _beats()



	var np: = _qn(_parts.size()) if not home and SettingsManager.vis_on("bg_particles") else 0
	for pi2 in np:
		var p: Dictionary = _parts[pi2]
		var pos: = Vector2(p.x * vs.x, p.y * vs.y)
		var pc2: Color = PALETTE[p.cix].lerp(acc, 0.25)
		pc2 = pc2.lerp(Color(1.35, 0.72, 0.28), 0.35 * _fire)
		var twinkle: = 0.55 + 0.45 * sin(beats_now * PI + p.tint * TAU)
		var a: float = (0.05 + 0.11 * p.tint) * (1.0 + pulse * 0.8) * twinkle
		var s: float = p.size * (1.0 + pulse * 0.35)
		if p.tint > 0.45:
			draw_colored_polygon(PackedVector2Array([
				pos + Vector2(0, - s), pos + Vector2(s, 0), 
				pos + Vector2(0, s), pos + Vector2( - s, 0), 
			]), Color(pc2.r, pc2.g, pc2.b, a))
		else:
			draw_circle(pos, s * 0.8, Color(pc2.r, pc2.g, pc2.b, a))




	var spec_refresh: = _spec_refresh()


	if main != null and main.spectrum != null and not home\
	and SettingsManager.gfx_eq:
		if spec_refresh:
			for i in _qn(16):
				var f0: = 70.0 * pow(60.0, float(i) / 16.0)
				_side_lvls[i] = _spec_level(f0, f0 * 1.5)
		for side in 2:
			var edge_x: = 12.0 if side == 0 else vs.x - 12.0
			for i in _qn(16):
				var lvl: = _side_lvls[i]
				var by: = vs.y * 0.28 + i * 13.0
				var bw: = 6.0 + lvl * 54.0
				var bx: = edge_x if side == 0 else edge_x - bw
				draw_rect(Rect2(bx, by, bw, 3.0), 
					Color(acc.r, acc.g, acc.b, 0.05 + 0.13 * lvl))



	if not in_game and not home:
		var hy: = vs.y * 0.74
		var vp: = Vector2(vs.x * 0.5, hy)
		var grid: = Color(viol.r, viol.g, viol.b, 0.1)
		draw_line(Vector2(0, hy), Vector2(vs.x, hy), 
			Color(viol.r, viol.g, viol.b, 0.22 + 0.1 * pulse), 1.5)
		for k in range(1, maxi(_qn(8), 2)):
			var gy: = hy + pow(float(k) / 7.0, 1.8) * (vs.y - hy)
			grid.a = 0.1 - 0.008 * k
			draw_line(Vector2(0, gy), Vector2(vs.x, gy), grid, 1.0)
		for k in range( - _qn(9), _qn(9) + 1):
			var bx: = vs.x * 0.5 + k * (vs.x / 9.0)
			draw_line(vp, Vector2(bx, vs.y), Color(viol.r, viol.g, viol.b, 0.07), 1.0)






	if main != null and main.screen == main.Screen.HOME and main.spectrum != null\
	and warp > 0.02:


		var wk: = 1.0 + 2.6 * warp * warp
		var wa: = clampf(1.0 - warp * 1.35, 0.0, 1.0)
		var wc: = rc
		if main.glow_tex != null:
			var gr: = 260.0 * wk
			draw_texture_rect(main.glow_tex, Rect2(wc - Vector2(gr, gr), 
				Vector2(gr, gr) * 2.0), false, 
				Color(viol.r, viol.g, viol.b, (0.22 + 0.08 * pulse) * wa))
		draw_arc(wc, (168.0 + 7.0 * pulse) * wk, 0.0, TAU, 80, 
			Color(viol.r * 1.25, viol.g * 1.25, viol.b * 1.25, 
				(0.55 + 0.25 * pulse) * wa), 2.5)

		var wrot: = _beats() * 0.05 + warp * 0.9
		for sgi in _qn(20):
			var a0: = wrot + float(sgi) * TAU / 20.0
			draw_arc(wc, (206.0 + 9.0 * pulse) * wk, a0, a0 + TAU / 20.0 * 0.45, 6, 
				Color(acc.r, acc.g, acc.b, 0.3 * wa), 2.0)



		var bars: = maxi(_qn(13), 3)
		var mid: = bars / 2
		if spec_refresh:
			for k in 7:
				var f0: = 90.0 * pow(22.0, float(k) / float(mid))
				_home_lvls[k] = _spec_level(f0, f0 * 1.6)
		for i in bars:
			var k: = absi(i - mid)
			var lvl: = _home_lvls[k]
			var bh: = (16.0 + lvl * lvl * (150.0 - k * 14.0)) * wk
			var bx: = wc.x + (float(i) - bars / 2.0) * 19.0 * wk
			var gt2: = float(i) / float(bars - 1)
			var bcol: = Color(0.4, 0.85, 1.05).lerp(viol, gt2 * 2.0) if gt2 < 0.5\
			else viol.lerp(Color(1.05, 0.55, 0.9), gt2 * 2.0 - 1.0)
			bcol = Color(bcol.r * 1.45, bcol.g * 1.45, bcol.b * 1.45, 
				(0.8 + 0.2 * lvl) * wa)

			var bw: = 4.5
			draw_rect(Rect2(bx - bw, wc.y - bh * 0.5, bw * 2.0, bh), bcol)
			draw_circle(Vector2(bx, wc.y - bh * 0.5), bw, bcol)
			draw_circle(Vector2(bx, wc.y + bh * 0.5), bw, bcol)


	draw_polygon(
		PackedVector2Array([Vector2.ZERO, Vector2(vs.x, 0), 
			Vector2(vs.x, 170), Vector2(0, 170)]), 
		PackedColorArray([Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.5), 
			Color(0, 0, 0, 0), Color(0, 0, 0, 0)]))
	draw_polygon(
		PackedVector2Array([Vector2(0, vs.y - 170), Vector2(vs.x, vs.y - 170), 
			Vector2(vs.x, vs.y), Vector2(0, vs.y)]), 
		PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0), 
			Color(0, 0, 0, 0.5), Color(0, 0, 0, 0.5)]))
	draw_polygon(
		PackedVector2Array([Vector2.ZERO, Vector2(230, 0), 
			Vector2(230, vs.y), Vector2(0, vs.y)]), 
		PackedColorArray([Color(0, 0, 0, 0.38), Color(0, 0, 0, 0), 
			Color(0, 0, 0, 0), Color(0, 0, 0, 0.38)]))
	draw_polygon(
		PackedVector2Array([Vector2(vs.x - 230, 0), Vector2(vs.x, 0), 
			Vector2(vs.x, vs.y), Vector2(vs.x - 230, vs.y)]), 
		PackedColorArray([Color(0, 0, 0, 0), Color(0, 0, 0, 0.38), 
			Color(0, 0, 0, 0.38), Color(0, 0, 0, 0)]))




















const DUST: = 90




func _menu_focus(vs: Vector2) -> Vector2:
	if results_mode and main != null and main.results_screen != null:
		var core: Control = main.results_screen.core
		if core.size.x > 10.0:
			return core.global_position + core.size * 0.5
	if main != null and main.screen == main.Screen.SELECT\
	and main.map_select != null and main.map_select.cover_ring != null:
		var cr: Control = main.map_select.cover_ring
		if cr.size.x > 10.0:
			return cr.global_position + cr.size * 0.5
	return Vector2(vs.x * 0.5, vs.y * 0.44)


func _menu_focus_radius() -> float:
	if main == null:
		return 54.0
	if results_mode and main.results_screen != null:
		return maxf(main.results_screen.core.radius() * 0.6, 54.0)
	if main.screen == main.Screen.SELECT and main.map_select != null\
	and main.map_select.cover_ring != null:
		var r: float = main.map_select.cover_ring.radius
		if r > 10.0:
			return r
	if main.orb_menu != null:
		return float(main.orb_menu.body_radius) * main.orb_menu.scale.x
	return 54.0


func _draw_home_light(vs: Vector2, rc: Vector2, viol: Color) -> void :
	var rev: = clampf(home_reveal, 0.0, 1.0)
	if rev <= 0.004 or main == null or main.glow_tex == null:
		return
	var s: = SettingsManager.menu_fx_intensity
	var kick: = beat_hit * s
	var bass: float = main.beat_bus.bass if main.beat_bus != null else 0.0
	var high: float = main.beat_bus.high if main.beat_bus != null else 0.0
	var glow: Texture2D = main.glow_tex
	var t: = Time.get_ticks_msec() / 1000.0


	var mr: = _menu_focus_radius()


	var reach: = lerpf(mr * 1.2, maxf(vs.x, vs.y) * 0.62, ease(rev, 0.45))




	var gk: = 1.0 + (0.04 * kick + 0.03 * bass) * s
	for i in 2:
		var gr: = minf((mr * 3.2 + i * 210.0) * gk, reach * (1.0 + 0.5 * i))
		draw_texture_rect(glow, Rect2(rc - Vector2(gr, gr), Vector2(gr, gr) * 2.0), 
			false, Color(viol.r, viol.g, viol.b, 
				(0.11 + (0.045 * kick + 0.025 * bass) * s) / (1.0 + i * 2.2)))
	var cr: = (mr + 26.0) * gk
	draw_texture_rect(glow, Rect2(rc - Vector2(cr, cr), Vector2(cr, cr) * 2.0), 
		false, Color(viol.r * 2.1, viol.g * 1.5, viol.b * 2.0, 
			(0.24 + (0.1 * kick + 0.05 * bass) * s) * rev))

















	var bus: BeatBus = main.beat_bus
	if bus != null and main.screen == main.Screen.HOME:
		var nb: = 96
		var bar_max: = vs.y * 0.22
		var half: = nb * 0.5


		var hp: = PackedVector2Array()
		var hc: = PackedColorArray()
		var kp: = PackedVector2Array()
		var kc: = PackedColorArray()
		var tp: = PackedVector2Array()
		var tr: = PackedFloat32Array()
		var tc: = PackedColorArray()
		for i in (nb if PerfFlags.bg_bars else 0):
			var cx: = (float(i) + 0.5) / nb * vs.x
			var u: = absf(float(i) - half) / half

			var lvl: = bus.band(int((1.0 - u) * (BeatBus.BANDS - 1)))
			var bh: = pow(lvl, 1.5) * bar_max * (0.35 + 0.85 * s)
			if bh < 2.0:
				continue


			var top_y: = rc.y - bh
			var dx: = absf(cx - rc.x)
			var guard: = mr * 1.55
			if dx < guard:
				top_y = maxf(top_y, rc.y + sqrt(maxf(guard * guard - dx * dx, 0.0)))
				if top_y >= rc.y - 2.0:
					continue

			var lit: = clampf(1.0 - dx / maxf(reach * 1.35, 1.0), 0.0, 1.0)
			if lit <= 0.02:
				continue

			var col: = Color(0.62, 0.34, 1.05).lerp(Color(0.2, 0.62, 1.05), u)



			var taper: = pow(sin(PI * (float(i) + 0.5) / nb), 0.45)
			var a: = (0.15 + 0.28 * lvl) * lit * rev * taper
			if PerfFlags.bg_batch:
				hp.append(Vector2(cx, rc.y));hp.append(Vector2(cx, top_y))
				hc.append(Color(col.r, col.g, col.b, a * 0.14))
				kp.append(Vector2(cx, rc.y));kp.append(Vector2(cx, top_y))
				kc.append(Color(col.r * 1.6, col.g * 1.6, col.b * 1.6, a))
				tp.append(Vector2(cx, top_y))
				tr.append(1.1)
				tc.append(Color(col.r * 1.9, col.g * 1.9, col.b * 1.9, a * 0.75))
			else:
				draw_line(Vector2(cx, rc.y), Vector2(cx, top_y), 
					Color(col.r, col.g, col.b, a * 0.14), 5.0)
				draw_line(Vector2(cx, rc.y), Vector2(cx, top_y), 
					Color(col.r * 1.6, col.g * 1.6, col.b * 1.6, a), 1.1)

				draw_circle(Vector2(cx, top_y), 1.1, 
					Color(col.r * 1.9, col.g * 1.9, col.b * 1.9, a * 0.75))
		if PerfFlags.bg_batch and not hp.is_empty():
			DrawBatch.lines(self, hp, hc, 5.0)
			DrawBatch.lines(self, kp, kc, 1.1)
			DrawBatch.dots(self, tp, tr, tc)











	var dp: = PackedVector2Array()
	var dr: = PackedFloat32Array()
	var dc: = PackedColorArray()
	for i in (_qn(DUST) if PerfFlags.bg_dust else 0):
		var ph: = float(i) * 12.9
		var dx: = _h(ph) * vs.x + sin(t * 0.06 + ph) * 14.0
		var dy: = fposmod(_h(ph * 2.3) * vs.y - t * (2.0 + 5.0 * _h(ph * 4.1)), vs.y)
		var p: = Vector2(dx, dy)
		var dist: = p.distance_to(rc)
		if dist > reach or dist < mr * 1.25:
			continue

		var fall: = 1.0 - dist / reach
		fall = fall * fall
		var tw: = 0.55 + 0.45 * sin(t * (0.7 + _h(ph * 7.7)) + ph)
		var a2: = (0.11 * tw + 0.09 * high * s) * fall * rev
		if a2 < 0.004:
			continue
		var rad: = (0.9 + 1.0 * _h(ph * 3.3)) * (1.0 + 0.35 * high * s)
		if PerfFlags.bg_batch:
			dp.append(p)
			dr.append(rad)
			dc.append(Color(0.9, 0.84, 1.05, a2))
		else:
			draw_circle(p, rad, Color(0.9, 0.84, 1.05, a2))
	if PerfFlags.bg_batch and not dp.is_empty():
		DrawBatch.dots(self, dp, dr, dc)




static func _h(n: float) -> float:
	return fposmod(sin(n * 12.9898) * 43758.5453, 1.0)




func _draw_motif(name: String, cov: Color, k: float, vs: Vector2, rc: Vector2, 
		rot: float, viol: Color, heat: float) -> void :
	if k <= 0.01:
		return
	match name:
		"none":
			return
		"matrix":
			_motif_matrix(cov, k, vs)
		"waves":
			_motif_waves(cov, k, vs)
		"orbit":
			_motif_orbit(cov, k, vs, rc)
		"shards":
			_motif_shards(cov, k, vs)
		"stardust":
			_motif_stardust(cov, k, vs)
		_:
			_motif_rings(cov, k, vs, rc, rot, viol, heat)



func _motif_rings(cov: Color, k: float, _vs: Vector2, rc: Vector2, rot: float, 
		viol: Color, heat: float) -> void :
	var rose: = Color(1.0, 0.45, 0.75)
	var bleu: = Color(0.4, 0.7, 1.0)
	for i in 6:
		var ring_r: = (170.0 + i * 105.0) * (1.0 + 0.55 * warp) + 6.0 * pulse
		var ring_a: = maxf(0.085 - i * 0.011, 0.018)\
		* (1.0 + 0.6 * pulse + 0.4 * heat + 1.6 * warp) * (1.0 + 0.7 * _fire) * k


		var ring_base: = viol.lerp(bleu, 0.35 - i * 0.07) if i < 3\
		else viol.lerp(rose, (i - 2) * 0.16)
		if cov.a > 0.0:
			ring_base = ring_base.lerp(Color(cov.r, cov.g, cov.b), 0.55)
		ring_base = ring_base.lerp(Color(1.0, 0.5, 0.18), 0.4 * _fire)
		var rcol: = Color(ring_base.r, ring_base.g, ring_base.b, ring_a)
		if i % 2 == 0:
			draw_arc(rc, ring_r, 0.0, TAU, 96, rcol, 1.5)
		else:


			var segs: = 28
			var dir: = -1.0 if i % 4 == 1 else 1.0
			var pts: = PackedVector2Array()
			pts.resize(segs * 2)
			for sgi in segs:
				var a0: = dir * rot + float(sgi) * TAU / segs
				pts[sgi * 2] = rc + Vector2.from_angle(a0) * ring_r
				pts[sgi * 2 + 1] = rc + Vector2.from_angle(a0 + TAU / segs * 0.55) * ring_r
			draw_multiline(pts, rcol, 2.0)
	var tick_r: = (170.0 + 2.0 * 105.0 + 52.0) * (1.0 + 0.55 * warp)
	var tick_c: = viol.lerp(Color(1.0, 0.6, 0.22), 0.4 * _fire)
	if cov.a > 0.0:
		tick_c = tick_c.lerp(Color(cov.r, cov.g, cov.b), 0.55)
	for tkn in _qn(48):
		var ta: = rot * 1.5 + float(tkn) * TAU / 48.0
		var tp: = rc + Vector2.from_angle(ta) * tick_r
		draw_rect(Rect2(tp - Vector2(1.5, 1.5), Vector2(3, 3)), 
			Color(tick_c.r, tick_c.g, tick_c.b, 
				(0.08 + 0.22 * pulse + 0.1 * _fire) * k))



func _motif_matrix(cov: Color, k: float, vs: Vector2) -> void :
	var mc: = Color(cov.r, cov.g, cov.b) if cov.a > 0.0 else Color(0.35, 1.0, 0.63)
	var bts: = _beats()
	for ci in _qn(24):
		var cx: = (float(ci) + 0.5) * vs.x / 24.0 + sin(float(ci) * 7.3) * 9.0
		var spd: = 0.1 + 0.06 * _h(float(ci) * 1.7)
		for di in 3:
			var ph: = fposmod(bts * spd + _h(float(ci) * 3.1 + float(di) * 7.7), 1.0)
			var dy: = ph * (vs.y + 80.0) - 40.0
			var dlen: = 14.0 + 26.0 * _h(float(ci * 3 + di) * 0.77)
			draw_line(Vector2(cx, dy), Vector2(cx, dy + dlen), 
				Color(mc.r, mc.g, mc.b, 
					(0.04 + 0.09 * (1.0 - ph) + 0.06 * pulse) * k), 2.0)



func _motif_waves(cov: Color, k: float, vs: Vector2) -> void :
	var wc: = Color(cov.r, cov.g, cov.b) if cov.a > 0.0 else Color(0.3, 0.55, 1.0)
	var bts: = _beats()
	for wi in 6:
		var wy: = vs.y * (0.16 + 0.64 * float(wi) / 5.0)
		var amp: = (10.0 + 15.0 * pulse) * (1.0 - 0.09 * float(wi))
		var pts: = PackedVector2Array()
		for xi in maxi(_qn(41), 6):
			var wx: = vs.x * float(xi) / 40.0
			pts.append(Vector2(wx, 
				wy + sin(wx * 0.008 + bts * 0.8 + float(wi) * 1.1) * amp))
		draw_polyline(pts, Color(wc.r, wc.g, wc.b, 
			(0.08 + 0.03 * float(wi % 2) + 0.06 * pulse) * k), 2.0)



func _motif_orbit(cov: Color, k: float, _vs: Vector2, rc: Vector2) -> void :
	var oc: = Color(cov.r, cov.g, cov.b) if cov.a > 0.0 else Color(0.25, 0.95, 0.85)
	var bts: = _beats()
	for oi in 4:
		var rx: = 220.0 + 130.0 * float(oi) + 8.0 * pulse
		var ry: = rx * 0.32
		var tilt: = -0.35 + 0.16 * float(oi)
		var pts: = PackedVector2Array()
		for sgi in maxi(_qn(49), 8):
			var a0: = TAU * float(sgi) / 48.0
			pts.append(rc + Vector2(cos(a0) * rx, sin(a0) * ry).rotated(tilt))
		draw_polyline(pts, Color(oc.r, oc.g, oc.b, 
			(0.1 - 0.016 * float(oi)) * (1.0 + 0.5 * pulse) * k), 1.5)

		var sa: = bts * (0.07 + 0.03 * float(oi)) * TAU * 0.5 + float(oi) * 2.1
		var sp: = rc + Vector2(cos(sa) * rx, sin(sa) * ry).rotated(tilt)
		draw_circle(sp, 3.0 + 1.5 * pulse, 
			Color(oc.r * 1.3, oc.g * 1.3, oc.b * 1.3, 0.55 * k))



func _motif_shards(cov: Color, k: float, vs: Vector2) -> void :
	var sc: = Color(cov.r, cov.g, cov.b) if cov.a > 0.0 else Color(1.0, 0.35, 0.62)
	var bts: = _beats()
	for si in _qn(14):
		var fx: = _h(float(si) * 3.17)
		var fy: = _h(float(si) * 7.71)
		var c: = Vector2(vs.x * (0.04 + 0.92 * fx), vs.y * (0.05 + 0.85 * fy))
		var size: = 18.0 + 42.0 * _h(float(si) * 5.3)
		var ang: = bts * 0.05 * (1.0 if si % 2 == 0 else -1.0) + fx * TAU
		var tw: = 0.5 + 0.5 * sin(bts * PI + fy * TAU)
		var cc: = Color(sc.r, sc.g, sc.b, (0.05 + 0.1 * tw + 0.05 * pulse) * k)
		var p0: = c + Vector2.from_angle(ang) * size
		var p1: = c + Vector2.from_angle(ang + TAU / 3.0) * size
		var p2: = c + Vector2.from_angle(ang + TAU * 2.0 / 3.0) * size
		draw_line(p0, p1, cc, 1.5)
		draw_line(p1, p2, cc, 1.5)
		draw_line(p2, p0, cc, 1.5)



func _motif_stardust(cov: Color, k: float, vs: Vector2) -> void :
	var stc: = Color(cov.r, cov.g, cov.b) if cov.a > 0.0 else Color(0.85, 0.88, 1.0)
	var bts: = _beats()
	for i in _qn(30):
		var p: = Vector2(vs.x * _h(float(i) * 1.31), vs.y * _h(float(i) * 4.73))
		var tw: = 0.4 + 0.6 * sin(bts * PI * (0.5 + _h(float(i) * 9.1)) + float(i))
		draw_circle(p, 1.2 + 1.6 * _h(float(i) * 2.9), 
			Color(stc.r, stc.g, stc.b, (0.06 + 0.16 * tw) * k))

	var dirv: = Vector2(-0.55, 0.84).normalized()
	for si in 6:
		var ph: = fposmod(bts * 0.055 + _h(float(si) * 6.7), 1.0)
		var start: = Vector2(vs.x * (0.3 + 0.75 * _h(float(si) * 3.3)), -40.0)
		var head: = start + dirv * ph * (vs.y + 320.0)
		var fade: = (1.0 - ph) * ph * 4.0
		draw_line(head - dirv * 90.0, head, 
			Color(stc.r, stc.g, stc.b, 0.28 * clampf(fade, 0.0, 1.0) * k), 2.0)
		draw_circle(head, 2.0, Color(stc.r * 1.3, stc.g * 1.3, stc.b * 1.3, 
			0.5 * clampf(fade, 0.0, 1.0) * k))
