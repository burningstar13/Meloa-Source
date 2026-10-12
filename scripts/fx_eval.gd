extends RefCounted
class_name FxEval
















const NEUTRAL_SPREAD: = 1.0
const NEUTRAL_ALPHA: = 1.0
const NEUTRAL_WIDTH: = 1.0






static func build(events: Array, lane_width: = 150.0, lane_gap: = 30.0, 
		screen_w: = 1280.0) -> Dictionary:
	var out: = {"tracks": {}, "texts": [], "images": [], "breaks": [], "themes": [], 
		"pulses": []}
	for raw in events:
		var ev: Dictionary = raw
		var kind: = String(ev.get("type", ""))
		var e: = {
			"t0": float(ev.get("time", 0.0)), 
			"dur": maxf(float(ev.get("len", 0.5)), 0.001), 
			"to": float(ev.get("to", 1.0)), 
			"ease": String(ev.get("ease", "io")), 
			"ev": ev, 
		}
		var lane: = clampi(int(ev.get("lane", 1)), 0, 2)
		match kind:
			"text":
				out.texts.append(e)
			"image":
				out.images.append(e)
			"break":
				out.breaks.append(e)
			"bg_theme":
				out.themes.append(e)
			"shake", "glitch":
				e["kind"] = kind
				out.pulses.append(e)
			"spread":
				_track(out, "spread", NEUTRAL_SPREAD).append(e)
			"lane_dx":
				_track(out, "dx%d" % lane, 0.0).append(e)
			"lane_pos":
				_track(out, "pos%d" % lane, 
					screen_w * 0.5 + float(lane - 1) * (lane_width + lane_gap)).append(e)
			"lane_sway":
				_track(out, "sway%d" % lane, 0.0).append(e)
			"lane_alpha":
				_track(out, "alpha%d" % lane, NEUTRAL_ALPHA).append(e)
			"lane_color":
				_track(out, "col%d" % lane, 0.0).append(e)
			"lane_width":
				_track(out, "width%d" % lane, NEUTRAL_WIDTH).append(e)
			"lane_remove":


				_track(out, "gone%d" % lane, 0.0).append(e)
			"bg_tint":
				_track(out, "bgtint", 0.0).append(e)
			"bg_ambient":
				_track(out, "bgamb", 0.0).append(e)
			"film":
				_track(out, "film", 0.0).append(e)
			"particles":
				_track(out, "particles", 0.0).append(e)
			"lane_rotate":
				_track(out, "rot", 0.0).append(e)
	for key in out.tracks:
		var evs: Array = out.tracks[key].evs
		evs.sort_custom( func(a, b): return a.t0 < b.t0)
		var prev_to: float = out.tracks[key].neutral
		for e in evs:
			e["from"] = prev_to
			prev_to = e.to




	for i in 3:
		var pkey: = "pos%d" % i
		if not out.tracks.has(pkey):
			continue
		var pevs: Array = out.tracks[pkey].evs
		for j in pevs.size():
			if j > 0:
				var prev = pevs[j - 1]


				if not bool(prev.ev.get("release", false)):
					continue
				if float(pevs[j].t0) < float(prev.t0) + float(prev.dur):
					continue
			pevs[j]["from"] = natural_lane_x(out, i, float(pevs[j].t0), 
				lane_width, lane_gap, screen_w)
	out.texts.sort_custom( func(a, b): return a.t0 < b.t0)
	out.images.sort_custom( func(a, b): return a.t0 < b.t0)
	out.themes.sort_custom( func(a, b): return a.t0 < b.t0)
	return out





static func natural_lane_x(built: Dictionary, i: int, t: float, 
		lane_width: = 150.0, lane_gap: = 30.0, screen_w: = 1280.0) -> float:
	var sp: = NEUTRAL_SPREAD
	if built.tracks.has("spread"):
		sp = value(built, "spread", t)
	var dx: = 0.0
	if built.tracks.has("dx%d" % i):
		dx = value(built, "dx%d" % i, t)
	return screen_w * 0.5 + float(i - 1) * (lane_width + lane_gap) * sp + dx


static func _track(out: Dictionary, key: String, neutral: float) -> Array:
	if not out.tracks.has(key):
		out.tracks[key] = {"neutral": neutral, "evs": []}
	return out.tracks[key].evs








static func sway_envelope(t: float, t0: float, dur: float) -> float:
	if t < t0:
		return 0.0
	var rise: = minf(0.3, maxf(dur, 0.05) * 0.5)
	var up: = clampf((t - t0) / rise, 0.0, 1.0)
	var end: = t0 + maxf(dur, 0.05)
	var down: = 1.0 - clampf((t - end) / 0.5, 0.0, 1.0)
	return up * down


static func sway_value(built: Dictionary, key: String, t: float) -> float:
	if not built.tracks.has(key):
		return 0.0
	var cur = null
	for e in built.tracks[key].evs:
		if e.t0 <= t:
			cur = e
		else:
			break
	if cur == null:
		return 0.0
	return float(cur.to) * sway_envelope(t, float(cur.t0), float(cur.dur))


static func value(built: Dictionary, key: String, t: float) -> float:
	if not built.tracks.has(key):
		return 0.0
	var track: Dictionary = built.tracks[key]
	var cur = null
	for e in track.evs:
		if e.t0 <= t:
			cur = e
		else:
			break
	if cur == null:
		return track.neutral
	var u: = clampf((t - cur.t0) / cur.dur, 0.0, 1.0)
	return lerpf(cur.from, cur.to, ease_at(u, cur.ease))





static func ease_at(u: float, kind: String) -> float:
	match kind:
		"hold":
			return 0.0
		"in":
			return u * u
		"out":
			return 1.0 - (1.0 - u) * (1.0 - u)
		"io":
			return u * u * (3.0 - 2.0 * u)
		"elastic":
			if u <= 0.0 or u >= 1.0:
				return clampf(u, 0.0, 1.0)
			return pow(2.0, -10.0 * u) * sin((u * 10.0 - 0.75) * TAU / 3.0) + 1.0
	return u











static func lane_color(evs: Array, base: Color, t: float) -> Color:
	var cur = null
	var prev = null
	for e in evs:
		if e.t0 <= t:
			prev = cur
			cur = e
		else:
			break
	if cur == null:
		return base
	var c_from: Color = base if prev == null else _ev_color(prev, base)
	var c_to: Color = _ev_color(cur, base)
	var u: = clampf((t - float(cur.t0)) / maxf(float(cur.dur), 0.001), 0.0, 1.0)
	return c_from.lerp(c_to, ease_at(u, String(cur.ease)))




static func _ev_color(e, base: Color) -> Color:
	var target: = Color.from_string(
		String(e.ev.get("params", {}).get("color", "#ffffff")), base)
	return base.lerp(target, clampf(float(e.to), 0.0, 1.0))




static func last_started(built: Dictionary, key: String, t: float):
	if not built.tracks.has(key):
		return null
	var cur = null
	for e in built.tracks[key].evs:
		if e.t0 <= t:
			cur = e
		else:
			break
	return cur



const REMOVE_ANIM: = 0.45






const FILM_SHADER: = "\nshader_type canvas_item;\nuniform sampler2D scr : hint_screen_texture, filter_linear;\nuniform float amt = 0.0;\nuniform float tt = 0.0;\nuniform float grain = 1.0;\nuniform float sepia = 0.0;\nfloat h(float n) { return fract(sin(n * 127.1) * 43758.5453); }\nfloat h2(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }\nvoid fragment() {\n\tfloat frame = floor(tt * 24.0);\n\t// gate weave : l'image tremble d'un demi-pixel, comme dans le projecteur\n\tvec2 uv = SCREEN_UV + vec2(h(frame) - 0.5, h(frame + 7.0) - 0.5) * 0.0025 * amt;\n\tvec3 c = texture(scr, uv).rgb;\n\tfloat lum = dot(c, vec3(0.299, 0.587, 0.114));\n\t// courbe de film : blancs qui brûlent un peu, noirs bouchés\n\tlum = clamp((lum - 0.05) * 1.18, 0.0, 1.0);\n\tlum = pow(lum, 0.92);\n\tvec3 mono = mix(vec3(lum), vec3(lum * 1.08, lum * 0.94, lum * 0.72), sepia);\n\t// grain : bruit par pixel, renouvelé à chaque image de film\n\tfloat g = (h2(floor(uv * vec2(640.0, 360.0)) + frame * 17.3) - 0.5) * 0.22 * grain;\n\tmono += g * (0.35 + 0.65 * (1.0 - lum));\n\t// scintillement de projecteur\n\tmono *= 0.92 + 0.08 * h(frame * 3.1) + 0.04 * sin(tt * 47.0);\n\t// rayures verticales : une ou deux lignes claires qui vivent quelques images\n\tfloat sx = h(floor(frame / 3.0) * 5.3);\n\tfloat scratch = step(0.75, h(floor(frame / 3.0) + 2.0)) * (1.0 - smoothstep(0.0, 0.0018, abs(uv.x - sx)));\n\tfloat sx2 = h(floor(frame / 5.0) * 9.1 + 1.0);\n\tscratch += step(0.85, h(floor(frame / 5.0) + 4.0)) * (1.0 - smoothstep(0.0, 0.0012, abs(uv.x - sx2)));\n\tmono += scratch * 0.45;\n\t// poussières : quelques taches sombres par image\n\tvec2 cell = floor(uv * vec2(24.0, 14.0));\n\tfloat dust = step(0.985, h2(cell + frame * 2.7)) * (1.0 - smoothstep(0.0, 0.018, length(fract(uv * vec2(24.0, 14.0)) - vec2(0.5)) ));\n\tmono -= dust * 0.6;\n\t// vignettage\n\tvec2 d = uv - vec2(0.5);\n\tfloat vig = 1.0 - smoothstep(0.35, 0.95, length(d * vec2(1.0, 1.25)));\n\tmono *= mix(0.55, 1.0, vig);\n\tCOLOR = vec4(mix(c, mono, amt), 1.0);\n}"













































static func remove_envelope(t: float, t0: float, dur: float) -> float:
	if t < t0 or t >= t0 + dur:
		return 0.0
	var anim: = minf(REMOVE_ANIM, dur * 0.5)
	var u: = minf((t - t0) / maxf(anim, 0.001), (t0 + dur - t) / maxf(anim, 0.001))
	u = clampf(u, 0.0, 1.0)
	return u * u * (3.0 - 2.0 * u)














const WINDOW_FADE: = 0.35


static func window_envelope(t: float, t0: float, dur: float, from: float, to: float) -> float:
	var dt: = t - t0
	if dt < 0.0:
		return from
	dur = maxf(dur, 0.001)
	if dt >= dur:
		return 0.0
	var fade: = minf(WINDOW_FADE, dur * 0.25)
	if fade <= 0.0:
		return to
	if dt < fade:
		var u: = dt / fade
		return lerpf(from, to, u * u * (3.0 - 2.0 * u))
	if dt > dur - fade:
		var u2: = (dt - (dur - fade)) / fade
		return lerpf(to, 0.0, u2 * u2 * (3.0 - 2.0 * u2))
	return to






static func window_value(evs: Array, t: float) -> float:
	var cur = null
	var from: = 0.0
	for e in evs:
		if float(e.t0) > t:
			break
		if cur != null:
			from = window_envelope(float(e.t0), float(cur.t0), float(cur.dur), from, float(cur.to))
		cur = e
	if cur == null:
		return 0.0
	return clampf(window_envelope(t, float(cur.t0), float(cur.dur), from, float(cur.to)), 0.0, 1.0)



static func film_at(built: Dictionary, t: float) -> float:
	if not built.tracks.has("film"):
		return 0.0
	return window_value(built.tracks["film"].evs, t)




static func particles_at(built: Dictionary, t: float) -> Dictionary:
	if not built.tracks.has("particles"):
		return {}

	var amt: = window_value(built.tracks["particles"].evs, t)
	var cur = last_started(built, "particles", t)
	if cur == null or amt <= 0.001:
		return {}
	var FxParticles = load("res://scripts/fx_particles.gd")
	return {"amt": amt, "st": FxParticles.settings(cur.ev.get("params", {}))}



static func gone_at(built: Dictionary, i: int, t: float) -> float:
	var cur = last_started(built, "gone%d" % i, t)
	if cur == null:
		return 0.0
	return remove_envelope(t, float(cur.t0), float(cur.dur))



static func state_at(built: Dictionary, t: float, lane_width: = 150.0, 
		lane_gap: = 30.0, screen_w: = 1280.0, base_cols: = []) -> Dictionary:
	var st: = {
		"spread": value(built, "spread", t) if built.tracks.has("spread") else NEUTRAL_SPREAD, 
		"dx": [0.0, 0.0, 0.0], 
		"pos": [NAN, NAN, NAN], 
		"alpha": [1.0, 1.0, 1.0], 
		"width": [1.0, 1.0, 1.0], 
		"gone": [gone_at(built, 0, t), gone_at(built, 1, t), gone_at(built, 2, t)], 
		"sway_amp": [0.0, 0.0, 0.0], 
		"sway_freq": [0.5, 0.5, 0.5], 
		"cols": [], 
		"tint": Color.WHITE, "tint_w": 0.0, 
		"shake": Vector2.ZERO, "glitch": 0.0, 

		"film": film_at(built, t), "film_grain": 1.0, "film_sepia": 0.0, 

		"rot": value(built, "rot", t) if built.tracks.has("rot") else 0.0, 
		"particles": particles_at(built, t), 
	}
	if built.tracks.has("film"):
		var fe = last_started(built, "film", t)
		if fe != null:
			var fp: Dictionary = fe.ev.get("params", {})
			st.film_grain = clampf(float(fp.get("grain", 1.0)), 0.0, 2.0)
			st.film_sepia = 1.0 if bool(fp.get("sepia", false)) else 0.0
	for i in 3:
		st.cols.append(base_cols[i] if base_cols.size() > i else Color.WHITE)
	for i in 3:
		if built.tracks.has("dx%d" % i):
			st.dx[i] = value(built, "dx%d" % i, t)
		if built.tracks.has("alpha%d" % i):
			st.alpha[i] = clampf(value(built, "alpha%d" % i, t), 0.0, 1.0)
		if built.tracks.has("width%d" % i):
			st.width[i] = maxf(value(built, "width%d" % i, t), 0.1)
		if built.tracks.has("sway%d" % i):
			st.sway_amp[i] = sway_value(built, "sway%d" % i, t)
			var sw = last_started(built, "sway%d" % i, t)
			if sw != null:
				st.sway_freq[i] = float(sw.ev.get("params", {}).get("freq", 0.5))



		if built.tracks.has("pos%d" % i):
			var cur = last_started(built, "pos%d" % i, t)
			if cur != null and not (bool(cur.ev.get("release", false))
					and t >= cur.t0 + cur.dur):
				st.pos[i] = value(built, "pos%d" % i, t)
		if built.tracks.has("col%d" % i) and base_cols.size() > i:
			st.cols[i] = lane_color(built.tracks["col%d" % i].evs, base_cols[i], t)
	if built.tracks.has("bgtint"):
		st.tint_w = clampf(value(built, "bgtint", t), 0.0, 1.0)
		var te = last_started(built, "bgtint", t)
		if te != null:
			st.tint = Color.from_string(
				String(te.ev.get("params", {}).get("color", "#ffffff")), Color.WHITE)

	for e in built.pulses:
		if t < e.t0 or t > e.t0 + e.dur:
			continue
		var damp: = pow(1.0 - clampf((t - e.t0) / e.dur, 0.0, 1.0), 1.6)
		if String(e.kind) == "shake":
			st.shake += pulse_shake(t, float(e.t0), float(e.dur), float(e.to))
		else:
			st.glitch = maxf(st.glitch, float(e.to) * damp)
	return st









static func pulse_shake(t: float, t0: float, dur: float, amp: float) -> Vector2:
	if dur <= 0.0 or t < t0 or t > t0 + dur:
		return Vector2.ZERO
	var damp: = pow(1.0 - clampf((t - t0) / dur, 0.0, 1.0), 1.6)
	var w: = t * 57.0
	return Vector2(sin(w) + 0.5 * sin(w * 2.3), cos(w * 1.17)) * amp * damp





static func lane_center(st: Dictionary, i: int, t: float, lane_width: = 150.0, 
		lane_gap: = 30.0, screen_w: = 1280.0) -> float:
	var wob: float = float(st.sway_amp[i])\
	* sin(t * float(st.sway_freq[i]) * TAU + float(i) * 2.1)
	if float(st.glitch) > 0.1:
		wob += (floorf(fposmod(t * 27.0 + float(i) * 7.31, 3.0)) - 1.0) * float(st.glitch)
	if not is_nan(float(st.pos[i])):
		return float(st.pos[i]) + wob
	return screen_w * 0.5 + float(i - 1) * (lane_width + lane_gap) * float(st.spread)\
	+ float(st.dx[i]) + wob



static func lane_half(st: Dictionary, i: int, lane_width: = 150.0) -> float:
	return lane_width * 0.5 * float(st.width[i])




static func texts_at(built: Dictionary, t: float) -> Array:
	var out: Array = []
	for e in built.texts:
		if t < e.t0 or t > e.t0 + e.dur:
			continue
		var u: float = (t - float(e.t0)) / float(e.dur)
		out.append({
			"ev": e.ev, "u": u, 
			"alpha": clampf(minf(u / 0.08, (1.0 - u) / 0.15), 0.0, 1.0), 
		})
	return out



static func theme_at(built: Dictionary, t: float) -> Dictionary:
	var prev: = "rings"
	var prev_col: = Color(0, 0, 0, 0)
	var cur = null
	for e in built.themes:
		if e.t0 <= t:
			if cur != null:
				prev = String(cur.ev.get("params", {}).get("theme", "rings"))
				prev_col = Color.from_string(
					String(cur.ev.get("params", {}).get("color", "")), Color(0, 0, 0, 0))
			cur = e
		else:
			break
	if cur == null:
		return {"a": "rings", "b": "rings", "mix": 1.0, 
			"col_a": Color(0, 0, 0, 0), "col_b": Color(0, 0, 0, 0)}
	return {
		"a": prev, "b": String(cur.ev.get("params", {}).get("theme", "rings")), 
		"mix": clampf((t - cur.t0) / cur.dur, 0.0, 1.0), 
		"col_a": prev_col, 
		"col_b": Color.from_string(
			String(cur.ev.get("params", {}).get("color", "")), Color(0, 0, 0, 0)), 
	}






static func images_at(built: Dictionary, t: float) -> Array:
	var out: Array = []
	for e in built.images:
		if t < e.t0 or t > e.t0 + e.dur:
			continue
		var u: float = (t - float(e.t0)) / float(e.dur)
		var pose: = image_pose(e.ev, u, float(e.dur), t, float(e.t0) * 37.31)
		pose["ev"] = e.ev
		pose["u"] = u
		out.append(pose)
	return out



const IMAGE_IN: = ["fade", "pop", "zoom", "slide_left", "slide_right", "rise", 
	"drop", "spin", "glitch", "none"]

const IMAGE_OUT: = ["fade", "shrink", "zoom", "slide_left", "slide_right", "fall", 
	"spin", "glitch", "none"]

const IMAGE_HOLD: = ["none", "float", "pulse", "spin", "shake", "sway", "drift", 
	"breathe", "zoom", "glitch"]






static func image_pose(ev: Dictionary, u: float, dur: float, t: float, 
		seed: float) -> Dictionary:
	var in_len: = clampf(float(ev.get("in_len", 0.4)), 0.0, dur)
	var out_len: = clampf(float(ev.get("out_len", 0.4)), 0.0, dur)
	var el: = u * dur
	var rem: = (1.0 - u) * dur
	var p_in: = 1.0 if in_len <= 0.0 else clampf(el / in_len, 0.0, 1.0)
	var p_out: = 0.0 if out_len <= 0.0 else clampf(1.0 - rem / out_len, 0.0, 1.0)
	var alpha: = float(ev.get("opacity", 1.0))
	var scale: = 1.0
	var rot: = float(ev.get("rotation", 0.0))
	var off: = Vector2.ZERO

	match String(ev.get("anim_in", "pop")):
		"fade":
			alpha *= p_in
		"pop":
			scale *= _back(p_in) if p_in < 1.0 else 1.0
			alpha *= clampf(p_in * 3.0, 0.0, 1.0)
		"zoom":
			scale *= lerpf(0.15, 1.0, _back(p_in))
			alpha *= clampf(p_in * 2.0, 0.0, 1.0)
		"slide_left":
			off.x += (1.0 - _back(p_in)) * -0.7
			alpha *= clampf(p_in * 3.0, 0.0, 1.0)
		"slide_right":
			off.x += (1.0 - _back(p_in)) * 0.7
			alpha *= clampf(p_in * 3.0, 0.0, 1.0)
		"rise":
			off.y += (1.0 - _back(p_in)) * 0.45
			alpha *= clampf(p_in * 2.0, 0.0, 1.0)
		"drop":
			off.y += (1.0 - _bounce(p_in)) * -0.6
		"spin":
			scale *= lerpf(0.2, 1.0, _back(p_in))
			rot += (1.0 - _back(p_in)) * -220.0
		"glitch":
			if p_in < 1.0:
				var gate: = _hash(seed + floorf(el * 40.0))
				if gate > p_in * p_in + 0.15:
					alpha *= 0.15
				off.x += (_hash(seed + 3.0 + floorf(el * 31.0)) - 0.5) * 0.06 * (1.0 - p_in)
		_:
			pass

	match String(ev.get("anim_out", "fade")):
		"fade":
			alpha *= 1.0 - p_out
		"shrink":
			scale *= 1.0 - _ease_in(p_out)
			alpha *= 1.0 - _ease_in(p_out)
		"zoom":
			scale *= 1.0 + _ease_in(p_out) * 1.6
			alpha *= 1.0 - p_out
		"slide_left":
			off.x += _ease_in(p_out) * -0.8
			alpha *= 1.0 - clampf((p_out - 0.6) / 0.4, 0.0, 1.0)
		"slide_right":
			off.x += _ease_in(p_out) * 0.8
			alpha *= 1.0 - clampf((p_out - 0.6) / 0.4, 0.0, 1.0)
		"fall":
			off.y += p_out * p_out * 0.9
			rot += p_out * 25.0
		"spin":
			scale *= 1.0 - _ease_in(p_out)
			rot += _ease_in(p_out) * 260.0
		"glitch":
			if p_out > 0.0:
				var gate2: = _hash(seed + 7.0 + floorf(el * 40.0))
				if gate2 < p_out * p_out + 0.15:
					alpha *= 0.15
				off.x += (_hash(seed + 11.0 + floorf(el * 31.0)) - 0.5) * 0.06 * p_out
		_:
			pass



	var glitch: = 0.0
	if String(ev.get("anim_in", "pop")) == "glitch":
		glitch = maxf(glitch, 1.0 - p_in)
	if String(ev.get("anim_out", "fade")) == "glitch":
		glitch = maxf(glitch, p_out)



	var hf: = clampf(float(ev.get("hold_from", 0.0)), 0.0, dur)
	var ht: = float(ev.get("hold_to", 0.0))
	if ht <= 0.0 or ht > dur:
		ht = dur
	var henv: = 0.0
	if ht > hf:
		var ramp: = minf(0.2, (ht - hf) * 0.5)
		henv = clampf((el - hf) / maxf(ramp, 0.001), 0.0, 1.0)\
		* clampf((ht - el) / maxf(ramp, 0.001), 0.0, 1.0)
	var amp: = float(ev.get("hold_amt", 1.0)) * henv

	var hp: = clampf((el - hf) / maxf(ht - hf, 0.001), 0.0, 1.0)
	match String(ev.get("anim_hold", "none")):
		"float":
			off.y += sin(t * 2.4 + seed) * 0.02 * amp
			rot += sin(t * 1.7 + seed) * 2.0 * amp
		"pulse":
			scale *= 1.0 + 0.08 * amp * maxf(sin(t * 6.0 + seed), 0.0)
		"spin":
			rot += fposmod(hp * (ht - hf) * 90.0 * float(ev.get("hold_amt", 1.0)), 360.0)
		"shake":
			off += Vector2(sin(t * 61.0 + seed), cos(t * 53.0 + seed)) * 0.008 * amp
		"sway":
			rot += sin(t * 2.2 + seed) * 8.0 * amp
		"drift":
			off.x += (hp - 0.5) * 0.12 * float(ev.get("hold_amt", 1.0))
		"breathe":
			var b: = 0.5 + 0.5 * sin(t * 1.6 + seed)
			scale *= 1.0 + 0.06 * amp * b
			alpha *= 1.0 - 0.15 * amp * (1.0 - b)
		"zoom":
			scale *= 1.0 + 0.25 * hp * float(ev.get("hold_amt", 1.0))
		"glitch":
			glitch = maxf(glitch, amp)

			if amp > 0.05 and _hash(seed + 5.0 + floorf(el * 19.0)) < 0.25 * amp:
				alpha *= 0.5
		_:
			pass
	return {"alpha": clampf(alpha, 0.0, 1.0), "scale": maxf(scale, 0.0), 
		"rot": rot, "off": off, "glitch": clampf(glitch, 0.0, 1.5)}


static func _ease_in(u: float) -> float:
	return u * u


static func _back(u: float) -> float:
	var c: = 1.70158
	var v: = u - 1.0
	return 1.0 + v * v * ((c + 1.0) * v + c)


static func _bounce(u: float) -> float:
	var n: = 7.5625
	var d: = 2.75
	if u < 1.0 / d:
		return n * u * u
	elif u < 2.0 / d:
		u -= 1.5 / d
		return n * u * u + 0.75
	elif u < 2.5 / d:
		u -= 2.25 / d
		return n * u * u + 0.9375
	u -= 2.625 / d
	return n * u * u + 0.984375


static func _hash(n: float) -> float:
	return fposmod(sin(n * 12.9898) * 43758.5453, 1.0)
