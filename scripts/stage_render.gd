extends RefCounted

























static func gold() -> Color:
	return Skins.col("gold")




static var tuning = null

static func _p(name: String, dflt: float) -> float:
	if tuning != null and name in tuning:
		return float(tuning.get(name))
	return dflt



static func legacy() -> bool:
	return not Skins.flat()


static func cream() -> Color:
	return Skins.col("note_outline")





static func trail(c: CanvasItem, o: Vector2, k: float, col: Color, 
		length: float, width: float) -> void :
	var w: = width * k
	var l: = length * k
	c.draw_polygon(PackedVector2Array([
		o + Vector2( - w, 0), o + Vector2(w, 0), 
		o + Vector2(w * 0.35, - l), o + Vector2( - w * 0.35, - l), 
	]), PackedColorArray([
		Color(col.r, col.g, col.b, 0.5), Color(col.r, col.g, col.b, 0.5), 
		Color(col.r, col.g, col.b, 0.0), Color(col.r, col.g, col.b, 0.0), 
	]))




static func dodge(c: CanvasItem, o: Vector2, k: float, song_t: float, 
		glow_tex: Texture2D, decor: = true) -> void :
	var instab: = clampf(0.72 + 0.22 * sin(song_t * 29.0)
		+ 0.16 * sin(song_t * 47.3), 0.4, 1.1)
	var glow: = Skins.col("dodge_glow")
	if glow_tex != null and decor:
		var gs: = 175.0 * k
		c.draw_texture_rect(glow_tex, Rect2(o - Vector2(gs * 0.5, gs * 0.5), 
			Vector2(gs, gs)), false, Color(glow, 0.32 * instab))

		for smi in 2:
			var sy: = -30.0 - fposmod(song_t * 34.0 + smi * 26.0, 52.0)
			var sx: = sin(song_t * 1.7 + smi * 2.6) * 10.0
			c.draw_texture_rect(glow_tex, Rect2(
				o + Vector2(sx - 26.0, sy - 26.0) * k, Vector2(52, 52) * k), 
				false, Color(Skins.col("dodge_smoke"), 0.1))
	trail(c, o, k, Skins.col("dodge_trail"), 120.0, 5.0)
	var tx: = Skins.tex("note_dodge")
	if tx != null:

		var ts: = 36.0 * k
		c.draw_texture_rect(tx, Rect2(o - Vector2(ts, ts), Vector2(ts, ts) * 2.0), 
			false, Color(instab, instab, instab))
	else:
		var body: = Skins.col("dodge_body")
		var s: = 26.0 * k
		c.draw_colored_polygon(PackedVector2Array([
			o + Vector2(0, - s), o + Vector2(s, 0), o + Vector2(0, s), o + Vector2( - s, 0), 
		]), Color(body.r * instab, body.g, body.b))
		var s2: = 13.0 * k
		c.draw_colored_polygon(PackedVector2Array([
			o + Vector2(0, - s2), o + Vector2(s2, 0), o + Vector2(0, s2), o + Vector2( - s2, 0), 
		]), Skins.col("dodge_core"))
		var s3: = 5.0 * k
		c.draw_colored_polygon(PackedVector2Array([
			o + Vector2(0, - s3), o + Vector2(s3, 0), o + Vector2(0, s3), o + Vector2( - s3, 0), 
		]), Skins.col("dodge_center"))
	if not decor:
		return

	var spark: = Skins.col("dodge_spark")
	for spk in 4:
		var pha: = song_t * 9.0 + spk * 1.9
		var sp: = Vector2(sin(pha * 1.31) * (20.0 + 14.0 * sin(pha * 0.7)), 
			cos(pha * 1.13) * (20.0 + 10.0 * cos(pha))) * k
		c.draw_rect(Rect2(o + sp - Vector2(1.6, 1.6) * k, Vector2(3.2, 3.2) * k), 
			Color(spark, 0.5 + 0.4 * sin(pha * 3.0)))









static func wall(c: CanvasItem, o: Vector2, k: float, song_t: float, 
		glow_tex: Texture2D, decor: = true, danger: = 0.0) -> void :
	var lethal: = danger >= 1.0
	var pulse: = 0.5 + 0.5 * sin(song_t * 6.0)

	var t: = clampf((danger - 0.12) / 0.82, 0.0, 1.0)
	var body: = Color(0.55 - 0.27 * t, 0.045 - 0.025 * t, 0.06 - 0.03 * t)
	var inner: = Color(0.16 - 0.1 * t, 0.01, 0.015)
	var rim: = Color(0.95, 0.14, 0.18, 0.9)
	var glow: = Color(0.7, 0.05, 0.08)
	if lethal:
		body = Color(0.05, 0.02, 0.03)
		inner = Color(0.0, 0.0, 0.0)
		rim = Color(1.35 + 0.25 * pulse, 0.05, 0.08, 1.0)
		glow = Color(0.85, 0.0, 0.03)
	if glow_tex != null and decor:
		var gs: = 210.0 * k
		c.draw_texture_rect(glow_tex, Rect2(o - Vector2(gs * 0.5, gs * 0.5), 
			Vector2(gs, gs)), false, Color(glow, 0.3 + 0.12 * pulse))
	trail(c, o, k, Color(glow, 0.9), 130.0, 8.0)
	var tx: = Skins.tex("note_wall_black" if lethal else "note_wall")
	if tx != null:
		c.draw_texture_rect(tx, Rect2(o - Vector2(40.0, 20.0) * k, Vector2(80.0, 40.0) * k), 
			false, Color.WHITE)
		return

	var w: = 36.0 * k
	var h: = 15.0 * k
	var ch: = 6.0 * k
	var plate: = PackedVector2Array([
		o + Vector2( - w + ch, - h), o + Vector2(w - ch, - h), o + Vector2(w, - h + ch), 
		o + Vector2(w, h - ch), o + Vector2(w - ch, h), o + Vector2( - w + ch, h), 
		o + Vector2( - w, h - ch), o + Vector2( - w, - h + ch), 
	])
	c.draw_colored_polygon(plate, body)

	var iw: = w - 7.0 * k
	var ih: = h - 6.0 * k
	c.draw_colored_polygon(PackedVector2Array([
		o + Vector2( - iw + ch, - ih), o + Vector2(iw - ch, - ih), o + Vector2(iw, - ih + ch), 
		o + Vector2(iw, ih - ch), o + Vector2(iw - ch, ih), o + Vector2( - iw + ch, ih), 
		o + Vector2( - iw, ih - ch), o + Vector2( - iw, - ih + ch), 
	]), inner)

	var outline: = PackedVector2Array(plate)
	outline.append(plate[0])
	c.draw_polyline(outline, rim, (2.6 if lethal else 1.8) * k, true)
	if lethal:

		var fw: = (iw - 6.0 * k) * (0.85 + 0.15 * pulse)
		c.draw_rect(Rect2(o + Vector2( - fw, -1.6 * k), Vector2(fw * 2.0, 3.2 * k)), 
			Color(1.6, 0.1, 0.12, 0.95))
	else:

		for i in 3:
			var x: = (float(i) - 1.0) * 14.0 * k
			c.draw_rect(Rect2(o + Vector2(x - 1.2 * k, - ih + 3.0 * k), 
				Vector2(2.4 * k, ih * 2.0 - 6.0 * k)), Color(0, 0, 0, 0.45))
	if not decor:
		return

	var spark: = Color(1.2, 0.25, 0.2) if lethal else Skins.col("dodge_spark")
	for spk in 6:
		var pha: = song_t * 8.0 + spk * 1.7
		var sp: = Vector2(sin(pha * 1.31) * (36.0 + 12.0 * sin(pha * 0.7)), 
			cos(pha * 1.13) * (16.0 + 8.0 * cos(pha))) * k
		c.draw_rect(Rect2(o + sp - Vector2(1.6, 1.6) * k, Vector2(3.2, 3.2) * k), 
			Color(spark, 0.5 + 0.4 * sin(pha * 3.0)))



static func parry(c: CanvasItem, o: Vector2, k: float, song_t: float, 
		glow_tex: Texture2D, decor: = true) -> void :
	if glow_tex != null and decor:
		var gs: = 165.0 * k
		c.draw_texture_rect(glow_tex, Rect2(o - Vector2(gs * 0.5, gs * 0.5), 
			Vector2(gs, gs)), false, Color(Skins.col("parry_glow"), 0.26))
	trail(c, o, k, Skins.col("parry_trail"), 110.0, 5.0)
	var tx: = Skins.tex("note_parry")
	if tx != null:

		var ts: = 36.0 * k
		c.draw_texture_rect(tx, Rect2(o - Vector2(ts, ts), Vector2(ts, ts) * 2.0), 
			false, Color.WHITE)
		return
	c.draw_circle(o, 15.0 * k, Skins.col("parry_core"))

	var rot: = song_t * 2.2
	var ring: = Skins.col("parry_ring")
	for seg in 6:
		var a0: = rot + float(seg) * TAU / 6.0
		c.draw_arc(o, 23.0 * k, a0, a0 + TAU / 6.0 * 0.62, 10, 
			Color(ring, 0.9), 2.5 * k)






static func lane_note(c: CanvasItem, o: Vector2, k: float, type: String, 
		song_t: float, glow_tex: Texture2D, decor: = true, stack: = 1, 
		danger: = 0.0) -> void :
	if type == "dodge":
		if stack >= 2:
			wall(c, o, k, song_t, glow_tex, decor, danger)
		else:
			dodge(c, o, k, song_t, glow_tex, decor)
	else:
		parry(c, o, k, song_t, glow_tex, decor)








static func aim_glow(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		glow_tex: Texture2D, alpha: float, spread: = 4.2) -> void :
	if glow_tex == null or alpha <= 0.001:
		return
	var g: = gold()
	var gs: = hit_r * k * spread
	c.draw_texture_rect(glow_tex, Rect2(o - Vector2(gs * 0.5, gs * 0.5), 
		Vector2(gs, gs)), false, Color(g.r, g.g, g.b, alpha))





static func aim_circle_legacy(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		ring_r: float, a: = 1.0, quality: = 1.0, double_rim: = false) -> void :
	var hr: = hit_r * k
	var g: = gold()
	var segs: = 48 if quality >= 0.5 else 28


	var tx: = Skins.tex("click_circle")
	if tx != null:
		c.draw_texture_rect(tx, Rect2(o - Vector2(hr, hr), Vector2(hr, hr) * 2.0), 
			false, Color(1, 1, 1, a))
		if double_rim:
			c.draw_arc(o, hr + 6.0 * k, 0.0, TAU, segs, 
				Color(g.r, g.g, g.b, 0.5 * a), 2.0 * k)
		aim_ring_legacy(c, o, k, hit_r, ring_r, a, quality)
		return
	var core: = Skins.col("click_core")
	c.draw_circle(o, hr, Color(core.r, core.g, core.b, 0.88 * a))
	c.draw_arc(o, hr - 3.0 * k, 0.0, TAU, segs, 
		Color(g.r * 1.25, g.g * 1.25, g.b * 1.25, a), 6.0 * k)
	if double_rim:


		c.draw_arc(o, hr + 6.0 * k, 0.0, TAU, segs, 
			Color(g.r, g.g, g.b, 0.5 * a), 2.0 * k)
	else:
		c.draw_arc(o, hr * 0.6, 0.0, TAU, mini(segs, 40), 
			Color(Skins.col("click_inner"), 0.85 * a), 2.0 * k)
		c.draw_circle(o, 3.5 * k, Color(Skins.col("click_dot"), a))
	aim_ring_legacy(c, o, k, hit_r, ring_r, a, quality)





static func aim_ring_legacy(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		ring_r: float, a: = 1.0, quality: = 1.0) -> void :
	if ring_r <= hit_r + 1.0:
		return
	var tx: = Skins.tex("approach_ring")
	if tx != null:
		var rr: = ring_r * k
		c.draw_texture_rect(tx, Rect2(o - Vector2(rr, rr), Vector2(rr, rr) * 2.0), 
			false, Color(1, 1, 1, 0.9 * a))
		return










	var g: = gold()

	var close: float = clampf(1.0 - (ring_r - hit_r) / maxf(hit_r * 1.6, 1.0), 
		0.0, 1.0)
	c.draw_arc(o, ring_r * k, 0.0, TAU, 64 if quality >= 0.5 else 40, 
		Color(g.r * (1.1 + 0.35 * close), g.g * (1.1 + 0.35 * close), 
			g.b * (1.1 + 0.3 * close), (0.62 + 0.33 * close) * a), 
		(3.2 + 2.4 * close) * k)



static func aim_flash_legacy(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		flash: float, quality: = 1.0, strong: = false) -> void :
	if flash <= 0.0 or quality <= 0.0:
		return
	var hr: = hit_r * k
	var q: = 1.0 if strong else quality
	var f: = Skins.col("click_flash")
	c.draw_circle(o, hr, Color(f, (0.4 if strong else 0.5) * flash * q))
	c.draw_arc(o, hr, 0.0, TAU, 48, 
		Color(f.r * 1.13, f.g * 1.13, f.b * 1.14, (0.7 if strong else 0.8) * flash * q), 
		5.0 * k)










static func aim_path(c: CanvasItem, from: Vector2, to: Vector2, k: float, 
		hit_r: float, a: float) -> void :
	var seg: = to - from
	var dist: = seg.length()


	if dist <= hit_r * 1.9 * k or a <= 0.01:
		return
	var dir: = seg / dist
	var start: float = hit_r * k + 12.0 * k
	var stop: float = dist - hit_r * 0.9 * k - 8.0 * k
	if stop <= start:
		return
	var g: = gold()


	var n: int = clampi(int((stop - start) / (17.0 * k)), 2, 14)


	var segs: = PackedVector2Array()
	var cols: = PackedColorArray()
	for i in n:
		var u: float = float(i) / float(n - 1)
		var p: Vector2 = from + dir * lerpf(start, stop, u)

		var half: float = (1.3 + 1.5 * u) * k
		segs.append(p - dir * half)
		segs.append(p + dir * half)
		cols.append(Color(g.r, g.g, g.b, a * (0.18 + 0.34 * u)))
	c.draw_multiline_colors(segs, cols, 3.4 * k)



static func aim_pips(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		rem: int, a: = 1.0) -> void :
	var pip: = Skins.col("click_text")
	for i in rem:
		var ang: = - PI * 0.5 + (float(i) - float(rem - 1) * 0.5) * 0.3
		c.draw_circle(o + Vector2(cos(ang), sin(ang)) * (hit_r + 14.0) * k, 
			3.0 * k, Color(pip, 0.9 * a))



static func aim_count(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		rem: int, font: Font, pop: = 0.0, a: = 1.0) -> void :
	var fnt: = font if font != null else ThemeDB.fallback_font
	var fs: = maxi(int(hit_r * k * (1.05 + 0.4 * pop)), 6)
	var s: = str(rem)
	var sz: = fnt.get_string_size(s, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	c.draw_string(fnt, o + Vector2( - sz.x * 0.5, sz.y * 0.34), s, 
		HORIZONTAL_ALIGNMENT_CENTER, -1, fs, Color(Skins.col("click_text"), a))





static func aim_ghost(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		number: int, a: float, font: Font) -> void :
	var g: = gold()
	for seg in 8:
		var a0: = TAU * float(seg) / 8.0 + 0.12
		c.draw_arc(o, hit_r * 0.85 * k, a0, a0 + TAU / 8.0 - 0.24, 6, 
			Color(g.r, g.g, g.b, a), 2.5 * k)
	var fnt: = font if font != null else ThemeDB.fallback_font
	var fs: = maxi(int(hit_r * 0.62 * k), 5)
	var s: = str(number)
	var sz: = fnt.get_string_size(s, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	c.draw_string(fnt, o + Vector2( - sz.x * 0.5, sz.y * 0.34), s, 
		HORIZONTAL_ALIGNMENT_CENTER, -1, fs, 
		Color(g.r * 1.2, g.g * 1.2, g.b, a))





static func aim_link(c: CanvasItem, from: Vector2, to: Vector2, k: float, 
		hit_r: float, a: float, chevron: bool, head_scale: = 1.0) -> void :
	var seg: = to - from
	if seg.length() <= hit_r * 0.6 * k:
		return
	var dir: = seg.normalized()
	var f: = from + dir * (hit_r * head_scale * k + 10.0 * k)
	var t: = to - dir * (hit_r * 0.85 * k + 8.0 * k)
	if (t - f).dot(dir) <= 0.0:
		return
	var g: = gold()
	c.draw_line(f, t, Color(g.r, g.g, g.b, a * 0.7), 2.0 * k)
	if not chevron:
		return
	var mid: = f.lerp(t, 0.55)
	var nv: = Vector2( - dir.y, dir.x)
	c.draw_line(mid - dir * 7.0 * k + nv * 7.0 * k, mid + dir * 6.0 * k, 
		Color(g.r, g.g, g.b, a), 2.0 * k)
	c.draw_line(mid - dir * 7.0 * k - nv * 7.0 * k, mid + dir * 6.0 * k, 
		Color(g.r, g.g, g.b, a), 2.0 * k)







static func slider_body(c: CanvasItem, body: PackedVector2Array, k: float, 
		hit_r: float, rail_width: float, a: = 1.0, 
		glow_tex: Texture2D = null, quality: = 1.0) -> void :
	if body.is_empty():
		return


	var hw: = hit_r * k
	var rim_w: = clampf(rail_width, 3.0, 8.0) * k
	var g: = gold()
	if glow_tex != null and quality >= 0.99:
		var gs: = hw * 2.6
		for i in range(0, body.size(), 4):
			c.draw_texture_rect(glow_tex, Rect2(body[i] - Vector2(gs, gs) * 0.5, 
				Vector2(gs, gs)), false, Color(g.r, g.g, g.b, 0.05 * a))



	slider_mesh_draw(c, slider_mesh(body, hw), slider_rim_color(a))
	slider_mesh_draw(c, slider_mesh(body, hw - rim_w), slider_core_color(a))


static func slider_rim_color(a: = 1.0) -> Color:
	var g: = gold()
	return Color(g.r * 1.14, g.g * 1.14, g.b * 1.1, 0.92 * a)


static func slider_core_color(a: = 1.0) -> Color:
	return Color(Skins.col("slider_core"), 0.86 * a)







const SLIDER_DISC_SEGS: = 20

static func slider_mesh(centers: PackedVector2Array, r: float) -> Array:
	var segs: = SLIDER_DISC_SEGS
	var n: = centers.size()
	var pts: = PackedVector2Array()
	var idx: = PackedInt32Array()
	pts.resize(n * (segs + 1))
	idx.resize(n * segs * 3)
	var ring: = PackedVector2Array()
	for s in segs:
		ring.append(Vector2.from_angle(TAU * float(s) / float(segs)) * r)
	var ii: = 0
	for i in n:
		var base: = i * (segs + 1)
		var cpt: = centers[i]
		pts[base] = cpt
		for s in segs:
			pts[base + 1 + s] = cpt + ring[s]
			idx[ii] = base
			idx[ii + 1] = base + 1 + s
			idx[ii + 2] = base + 1 + ((s + 1) % segs)
			ii += 3
	return [pts, idx]


static func slider_mesh_draw(c: CanvasItem, mesh: Array, col: Color, discs: = -1) -> void :
	if mesh.size() < 2:
		return
	var pts: PackedVector2Array = mesh[0]
	var idx: PackedInt32Array = mesh[1]
	if pts.is_empty():
		return




	if discs >= 0:
		var ni: = mini(discs * SLIDER_DISC_SEGS * 3, idx.size())
		if ni == 0:
			return
		idx = idx.slice(0, ni)
	var cols: = PackedColorArray()
	cols.resize(pts.size())
	cols.fill(col)
	RenderingServer.canvas_item_add_triangle_array(c.get_canvas_item(), idx, pts, cols)



static func slider_head_legacy(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		ring_r: float, a: = 1.0) -> void :
	var hr: = hit_r * k
	var g: = gold()
	var tx: = Skins.tex("click_circle")
	if tx != null:

		c.draw_texture_rect(tx, Rect2(o - Vector2(hr, hr), Vector2(hr, hr) * 2.0), 
			false, Color(1, 1, 1, a))
	else:
		c.draw_circle(o, hr, Color(Skins.col("click_core"), 0.88 * a))
		c.draw_arc(o, hr - 3.0 * k, 0.0, TAU, 48, 
			Color(g.r * 1.12, g.g * 1.12, g.b * 1.08, a), 5.0 * k)
		c.draw_arc(o, hr * 0.6, 0.0, TAU, 40, Color(Skins.col("click_inner"), 0.85 * a), 2.0 * k)
		c.draw_circle(o, 3.5 * k, Color(Skins.col("click_dot"), a))
	if ring_r > hit_r + 1.0:
		aim_ring_legacy(c, o, k, hit_r, ring_r, a)



static func slider_tail_legacy(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		a: = 1.0) -> void :
	if _tail_tex(c, o, k, hit_r, a):
		return
	c.draw_arc(o, hit_r * 0.38 * k, 0.0, TAU, 32, Color(gold(), 0.6 * a), 2.5 * k)







static func hold_rail(c: CanvasItem, pts: PackedVector2Array, k: float, 
		width: float, col: Color, caught: = false, pulse: = 0.0, alpha: = 1.0) -> void :
	if pts.size() < 2 or alpha <= 0.001:
		return
	var rtx: = Skins.tex("hold_rail")
	if rtx != null:

		var a0: = pts[0]
		var a1: = pts[pts.size() - 1]
		var d: = a1 - a0
		var l: = d.length()
		if l < 1.0:
			return
		var nrm: = Vector2( - d.y, d.x) / l * width * k
		var reps: = maxf(l / maxf(float(rtx.get_height()) * (width * 2.0 * k / rtx.get_width()), 1.0), 0.01)
		c.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		var tint: = Color(col.r * 1.2, col.g * 1.2, col.b * 1.2, (0.95 if caught else 0.8) * alpha)
		c.draw_polygon(PackedVector2Array([a0 - nrm, a0 + nrm, a1 + nrm, a1 - nrm]), 
			PackedColorArray([tint, tint, tint, tint]), 
			PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, reps), Vector2(0, reps)]), rtx)
		return
	c.draw_polyline(pts, Color(col.r, col.g, col.b, 0.2 * alpha), width * 2.0 * k)
	c.draw_polyline(pts, Color(col.r * 1.3, col.g * 1.3, col.b * 1.3, 0.9 * alpha), 
		width * 0.45 * k)
	if caught:
		c.draw_polyline(pts, Color(col.r * 1.5, col.g * 1.5, col.b * 1.5, pulse * alpha), 
			width * 0.9 * k)



static func hold_head(c: CanvasItem, o: Vector2, k: float, col: Color, 
		caught: = false, glow_tex: Texture2D = null, alpha: = 1.0) -> void :
	if alpha <= 0.001:
		return
	var htx: = Skins.tex("hold_head")
	if htx != null:
		var hs: = (52.0 if caught else 44.0) * k
		c.draw_texture_rect(htx, Rect2(o - Vector2(hs, hs) * 0.5, Vector2(hs, hs)), false, 
			Color(col.r, col.g, col.b, alpha))
		return
	if glow_tex != null:
		var gs: = (130.0 if caught else 95.0) * k
		c.draw_texture_rect(glow_tex, Rect2(o - Vector2(gs, gs) * 0.5, 
			Vector2(gs, gs)), false, 
			Color(col.r, col.g, col.b, (0.38 if caught else 0.24) * alpha))
	c.draw_circle(o, (16.0 if caught else 13.0) * k, 
		Color(col.r * 1.4, col.g * 1.45, col.b * 1.4, alpha))
	c.draw_circle(o, 6.0 * k, Color(Skins.col("hold_core"), alpha))










static func lane_quad(cx_bot: float, half: float, screen_cx: float, 
		persp: float, top_y: float, bot_y: float) -> PackedVector2Array:
	var cx_top: = screen_cx + (cx_bot - screen_cx) * persp
	var half_top: = half * persp
	return PackedVector2Array([
		Vector2(cx_top - half_top, top_y), Vector2(cx_top + half_top, top_y), 
		Vector2(cx_bot + half, bot_y), Vector2(cx_bot - half, bot_y), 
	])



static func diamond(c: CanvasItem, o: Vector2, r: float, col: Color) -> void :
	c.draw_colored_polygon(PackedVector2Array([
		o + Vector2(0, - r), o + Vector2(r, 0), o + Vector2(0, r), o + Vector2( - r, 0), 
	]), col)



static func receptor(c: CanvasItem, o: Vector2, r: float, col: Color, 
		active: bool, neon_col: Color, neon_active: Color) -> void :
	var tx: = Skins.tex("receptor")
	if tx != null:

		var ts: = r * 1.6
		c.draw_texture_rect(tx, Rect2(o - Vector2(ts, ts), Vector2(ts, ts) * 2.0), 
			false, neon_active if active else neon_col)
		return
	if active:
		diamond(c, o, r + 5.0, Color(col.r, col.g, col.b, 0.22))
		diamond(c, o, r, neon_active)
		diamond(c, o, r * 0.62, Skins.col("receptor_core"))
		diamond(c, o, r * 0.3, Skins.col("receptor_active"))
	else:
		diamond(c, o, r, neon_col)
		diamond(c, o, r * 0.62, Skins.col("receptor_core"))














static func aim_circle(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		ring_r: float, a: = 1.0, quality: = 1.0, double_rim: = false, 
		order: = "", font: Font = null, dim: = 0.0) -> void :
	if legacy():
		aim_circle_legacy(c, o, k, hit_r, ring_r, a, quality, double_rim)
		return
	aim_ring(c, o, k, hit_r, ring_r, a * (1.0 - 0.5 * dim), quality)
	aim_body(c, o, k, hit_r, a, dim, double_rim, order == "" or not numbers_on(), quality)
	if order != "" and numbers_on():
		aim_order(c, o, k, hit_r, order, font, a)


static func numbers_on() -> bool:
	return Skins.flat() and (tuning == null or bool(tuning.show_order_numbers))





static func aim_body(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		a: = 1.0, dim: = 0.0, double_rim: = false, show_dot: = true, quality: = 1.0) -> void :
	var hr: = hit_r * k
	var tx: = Skins.tex("click_circle")
	if tx != null:
		c.draw_texture_rect(tx, Rect2(o - Vector2(hr, hr), Vector2(hr, hr) * 2.0), 
			false, Color(1, 1, 1, a))
		return
	var ow: = _p("note_outline_width", 7.0) * k
	var rw: = _p("note_ring_width", 3.0) * k
	var fa: = _p("note_fill_alpha", 0.72)
	var dot: = _p("note_center_dot", 3.0) * k
	var segs: = 48 if quality >= 0.5 else 32
	var aa: = quality >= 0.5
	var outline: = cream()
	var fill: = Skins.col("note_fill")
	var ring: = gold()
	var dk: = 1.0 - dim
	var rf: = hr - ow - rw
	c.draw_circle(o, rf + 0.6 * k, Color(fill.r * dk, fill.g * dk, fill.b * dk, fa * a))
	c.draw_arc(o, rf + rw * 0.5, 0.0, TAU, segs, 
		Color(ring.r * dk, ring.g * dk, ring.b * dk, a), rw, aa)
	c.draw_arc(o, hr - ow * 0.5, 0.0, TAU, segs, 
		Color(outline.r, outline.g, outline.b, a * (1.0 - 0.35 * dim)), ow, aa)
	if double_rim:
		c.draw_arc(o, hr + 5.0 * k, 0.0, TAU, segs, Color(ring.r, ring.g, ring.b, 0.6 * a), 2.0 * k, aa)
	if show_dot and dot > 0.0:
		c.draw_circle(o, dot, Color(outline.r, outline.g, outline.b, a))



static func aim_order(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		s: String, font: Font, a: = 1.0) -> void :
	if s == "":
		return
	var fnt: = font if font != null else ThemeDB.fallback_font
	var fs: = maxi(int(hit_r * k * 0.8), 8)
	var sz: = fnt.get_string_size(s, HORIZONTAL_ALIGNMENT_CENTER, -1, fs)
	var pos: = o + Vector2( - sz.x * 0.5, sz.y * 0.34)
	c.draw_string_outline(fnt, pos, s, HORIZONTAL_ALIGNMENT_CENTER, -1, fs, 2, 
		Color(0.05, 0.04, 0.02, 0.75 * a))
	c.draw_string(fnt, pos, s, HORIZONTAL_ALIGNMENT_CENTER, -1, fs, 
		Color(Skins.col("note_text"), a))




static func aim_ring(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		ring_r: float, a: = 1.0, quality: = 1.0) -> void :
	if ring_r <= hit_r + 1.0:
		return
	if legacy():
		aim_ring_legacy(c, o, k, hit_r, ring_r, a, quality)
		return
	var tx: = Skins.tex("approach_ring")
	if tx != null:
		var rr: = ring_r * k
		c.draw_texture_rect(tx, Rect2(o - Vector2(rr, rr), Vector2(rr, rr) * 2.0), 
			false, Color(1, 1, 1, 0.9 * a))
		return
	var g: = gold()
	c.draw_arc(o, ring_r * k, 0.0, TAU, 64 if quality >= 0.5 else 40, 
		Color(g.r, g.g, g.b, _p("approach_alpha", 0.55) * a), 
		_p("approach_width", 3.0) * k, quality >= 0.5)



static func aim_flash(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		flash: float, quality: = 1.0, strong: = false) -> void :
	if flash <= 0.0 or quality <= 0.0:
		return
	if legacy():
		aim_flash_legacy(c, o, k, hit_r, flash, quality, strong)
		return
	var hr: = hit_r * k
	var f: = cream()
	c.draw_circle(o, hr, Color(f.r, f.g, f.b, 0.55 * flash))
	c.draw_arc(o, hr - 2.0 * k, 0.0, TAU, 48, Color(f.r, f.g, f.b, 0.9 * flash), 5.0 * k, true)




static func aim_hit_ring(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		u: float, strength: = 1.0) -> void :
	var f: = cream()
	var e: = 1.0 - (1.0 - u) * (1.0 - u)
	c.draw_arc(o, hit_r * k * (1.0 + 0.32 * e * strength), 0.0, TAU, 48, 
		Color(f.r, f.g, f.b, (1.0 - u) * 0.7 * strength), 4.0 * k * (1.0 - 0.5 * u), true)







static func slider_geometry(center: PackedVector2Array, hit_r: float, 
		outline_w: float) -> Dictionary:
	var geom: = {"outline": [], "fill": []}
	if center.size() < 2:
		return geom
	var hw: = hit_r
	var outer: = Geometry2D.offset_polyline(center, hw - outline_w * 0.5, 
		Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	var closed: Array = []
	for poly in outer:
		var pl: PackedVector2Array = poly.duplicate()
		if pl.size() > 1:
			pl.append(pl[0])
		closed.append(pl)
	geom["outline"] = closed
	var inner: = Geometry2D.offset_polyline(center, hw - outline_w, 
		Geometry2D.JOIN_ROUND, Geometry2D.END_ROUND)
	var shells: Array = []
	var holes: Array = []
	for poly in inner:
		if Geometry2D.is_polygon_clockwise(poly):
			holes.append(poly)
		else:
			shells.append(poly)
	var pts: = PackedVector2Array()
	var idx: = PackedInt32Array()
	for shell in shells:
		var polygon: PackedVector2Array = shell
		for h in holes:
			if Geometry2D.is_point_in_polygon(h[0], shell):
				polygon = _bridge_hole(polygon, h)
		var tri: = Geometry2D.triangulate_polygon(polygon)
		if tri.is_empty():
			continue
		var base: = pts.size()
		pts.append_array(polygon)
		for i in tri:
			idx.append(base + i)
	if idx.is_empty():


		geom["fill"] = slider_mesh(center, hw - outline_w)
	else:
		geom["fill"] = [pts, idx]
	return geom




static func _bridge_hole(shell: PackedVector2Array, hole: PackedVector2Array) -> PackedVector2Array:
	var bi: = 0
	var bj: = 0
	var bd: = INF
	for i in shell.size():
		for j in hole.size():
			var d: = shell[i].distance_squared_to(hole[j])
			if d < bd:
				bd = d
				bi = i
				bj = j
	var out: = PackedVector2Array()
	for i in bi + 1:
		out.append(shell[i])
	for j in hole.size() + 1:
		out.append(hole[(bj + j) % hole.size()])
	for i in range(bi, shell.size()):
		out.append(shell[i])
	return out





static func slider_body_draw(c: CanvasItem, geom: Dictionary, k: float, a: = 1.0, 
		dim: = 0.0, broken: = false, quality: = 1.0) -> void :
	if geom.is_empty() or a <= 0.001:
		return
	var ow: = _p("slider_outline_width", 6.0) * k
	var ba: = _p("slider_body_alpha", 0.32)
	var body: = Skins.col("slider_body")
	var outline: = cream()
	if broken:
		body = Color(0.22, 0.21, 0.2)
		outline = Color(0.62, 0.6, 0.56)
	var fill: Array = geom.get("fill", [])
	if fill.size() == 2:
		slider_mesh_draw(c, fill, Color(body.r, body.g, body.b, ba * a * (1.0 + 0.6 * dim)))
	var oc: = Color(outline.r, outline.g, outline.b, a * (0.92 - 0.3 * dim))
	for pl in geom.get("outline", []):
		c.draw_polyline(pl, oc, ow, quality >= 0.5)



static func slider_head(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		ring_r: float, a: = 1.0, order: = "", font: Font = null, dim: = 0.0) -> void :
	if legacy():
		slider_head_legacy(c, o, k, hit_r, ring_r, a)
		return
	aim_circle(c, o, k, hit_r, ring_r, a, 1.0, false, order, font, dim)



static func slider_tail(c: CanvasItem, o: Vector2, k: float, hit_r: float, 
		a: = 1.0, dim: = 0.0) -> void :
	if legacy():
		slider_tail_legacy(c, o, k, hit_r, a)
		return
	if _tail_tex(c, o, k, hit_r, a):
		return
	var f: = cream()
	c.draw_arc(o, hit_r * 0.42 * k, 0.0, TAU, 32, 
		Color(f.r, f.g, f.b, 0.85 * a * (1.0 - 0.4 * dim)), 3.0 * k, true)




static func slider_ball(c: CanvasItem, b: Vector2, k: float, hit_r: float, 
		held: bool, pulse: = 0.0, a: = 1.0) -> void :
	var r: = hit_r * 0.74 * k * (1.0 + 0.1 * pulse)
	var f: = cream()
	var g: = Skins.col("slider_ball")
	if held:
		c.draw_circle(b, r, Color(g.r, g.g, g.b, 0.92 * a))
		c.draw_arc(b, r - 2.0 * k, 0.0, TAU, 40, Color(f.r, f.g, f.b, a), 4.0 * k, true)
	else:
		c.draw_circle(b, r, Color(g.r * 0.5, g.g * 0.5, g.b * 0.5, 0.55 * a))
		c.draw_arc(b, r - 2.0 * k, 0.0, TAU, 40, Color(f.r, f.g, f.b, 0.55 * a), 3.0 * k, true)




static func slider_follow(c: CanvasItem, b: Vector2, k: float, radius: float, 
		inside: bool, grow: = 1.0, a: = 1.0) -> void :
	var f: = cream() if inside else Skins.col("slider_break")
	c.draw_arc(b, radius * k * (0.4 + 0.6 * grow), 0.0, TAU, 56, 
		Color(f.r, f.g, f.b, (0.55 if inside else 0.85) * a), 2.5 * k, true)




static func slider_arrow(c: CanvasItem, p: Vector2, dir: Vector2, k: float, 
		hit_r: float, pulse: = 0.0, a: = 1.0) -> void :
	var atx: = Skins.tex("reverse_arrow")
	if atx != null:

		var s: = hit_r * 0.9 * k * (1.0 + 0.08 * pulse)
		c.draw_set_transform(p, dir.angle(), Vector2.ONE)
		c.draw_texture_rect(atx, Rect2( - s * 0.5, - s * 0.5, s, s), false, Color(1, 1, 1, a))
		c.draw_set_transform(Vector2.ZERO)
		return
	var f: = Color(1.6, 1.6, 1.55) if legacy() else cream()
	var perp: = Vector2( - dir.y, dir.x)
	var tip: = p + dir * hit_r * 0.32 * k * (1.0 + 0.08 * pulse)
	var base_pt: = tip - dir * hit_r * 0.5 * k
	var wing: = perp * hit_r * 0.38 * k
	var col: = Color(f.r, f.g, f.b, a)
	c.draw_line(base_pt + wing, tip, col, 6.0 * k, true)
	c.draw_line(base_pt - wing, tip, col, 6.0 * k, true)





static func slider_ball_legacy(c: CanvasItem, b: Vector2, k: float, hit_r: float, 
		held: bool, glow_tex: Texture2D = null, quality: = 1.0) -> void :
	var hw: = hit_r * k
	var br: = hit_r * 0.88 * k
	var g: = gold()
	var ball_tx: Texture2D = Skins.tex("slider_ball")
	if held:
		if glow_tex != null and quality >= 0.3:
			var bs: = hw * 2.6
			c.draw_texture_rect(glow_tex, Rect2(b - Vector2(bs, bs) * 0.5, 
				Vector2(bs, bs)), false, Color(g.r, g.g, g.b, 0.26 * quality))
		if ball_tx != null:
			var ts: = br * 1.15
			c.draw_texture_rect(ball_tx, Rect2(b - Vector2(ts, ts), Vector2(ts, ts) * 2.0), 
				false, Color.WHITE)
		else:
			c.draw_circle(b, br, Color(g.r * 1.06, g.g * 1.06, g.b * 1.0))
			c.draw_circle(b, br * 0.45, Skins.col("slider_ball_core"))
	else:
		if ball_tx != null:
			var ts2: = br * 1.15
			c.draw_texture_rect(ball_tx, Rect2(b - Vector2(ts2, ts2), Vector2(ts2, ts2) * 2.0), 
				false, Color(0.6, 0.6, 0.6, 0.65))
		else:
			c.draw_circle(b, br, Color(g.r * 0.55, g.g * 0.55, g.b * 0.53, 0.65))




static func slider_follow_legacy(c: CanvasItem, b: Vector2, k: float, radius: float, 
		held: bool, inside: bool, grow: = 1.0, ball_r: = 0.0) -> void :
	if held:
		var g: = gold()
		var fc: = Color(g.r * 1.25, g.g * 1.25, g.b * 1.15) if inside else Skins.col("slider_break")
		var fr: = lerpf(ball_r, radius, grow) * k
		c.draw_arc(b, fr, 0.0, TAU, 56, Color(fc, 0.55 if inside else 0.85), 2.5 * k)
	else:
		c.draw_arc(b, radius * k, 0.0, TAU, 56, Color(1.0, 1.0, 1.0, 0.3), 2.5 * k)





static func slider_body_legacy_draw(c: CanvasItem, mesh_rim: Array, mesh_core: Array, 
		discs: int, cap: Vector2, has_cap: bool, hw: float, rim_w: float, a: = 1.0, 
		body_pts: = PackedVector2Array(), first_ahead: = 0, 
		glow_tex: Texture2D = null, quality: = 1.0) -> void :
	var g: = gold()
	if glow_tex != null and quality >= 0.99 and not body_pts.is_empty():
		var gs: = hw * 2.6
		for i in range(first_ahead, body_pts.size(), 4):
			c.draw_texture_rect(glow_tex, Rect2(body_pts[i] - Vector2(gs, gs) * 0.5, 
				Vector2(gs, gs)), false, Color(g.r, g.g, g.b, 0.05 * a))
	var rim_col: = slider_rim_color(a)
	var core_col: = slider_core_color(a)
	slider_mesh_draw(c, mesh_rim, rim_col, discs)
	if has_cap:
		c.draw_circle(cap, hw, rim_col)
	slider_mesh_draw(c, mesh_core, core_col, discs)
	if has_cap:
		c.draw_circle(cap, hw - rim_w, core_col)



static func _tail_tex(c: CanvasItem, o: Vector2, k: float, hit_r: float, a: float) -> bool:
	var ttx: = Skins.tex("slider_tail")
	if ttx == null:
		return false
	var s: = hit_r * 0.9 * k
	c.draw_texture_rect(ttx, Rect2(o - Vector2(s, s) * 0.5, Vector2(s, s)), false, Color(1, 1, 1, a))
	return true
