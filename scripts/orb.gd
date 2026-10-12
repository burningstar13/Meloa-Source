class_name Orb
extends Node2D























signal expression_changed(expression: int)
signal reaction_finished(expression: int)

enum Mood{NEUTRAL, HAPPY, EXCITED, FOCUSED, NERVOUS, ANGRY, SAD, 
	HIT_LIGHT, HIT_HEAVY, STUNNED, PERFECT, COMBO_MODE, 
	BLOCK, PERFECT_BLOCK, COUNTER}
enum EyeMode{OPEN, ARC, SQUEEZE, XEYES, SPIRAL}



const BODY_FILL: = Color(0.055, 0.06, 0.085, 1.0)
const EYE_WHITE: = Color(0.97, 0.98, 1.0)



const TINT_NEUTRAL: = Color(0.8, 0.92, 1.0)
const TINT_RED: = Color(1.0, 0.38, 0.42)
const TINT_GOLD: = Color(1.0, 0.82, 0.3)
const TINT_VIOLET: = Color(0.72, 0.45, 1.0)








const PRESETS: = {
	Mood.NEUTRAL: {"mode": EyeMode.OPEN, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.0, "pupil": 1.0, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_NEUTRAL, 
		"fx": [], "impulse": 0.0}, 
	Mood.HAPPY: {"mode": EyeMode.ARC, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.0, "pupil": 1.0, "star": false, 
		"track": false, "bias": Vector2.ZERO, "tint": TINT_NEUTRAL, 
		"fx": [], "impulse": 0.0}, 
	Mood.EXCITED: {"mode": EyeMode.OPEN, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.22, "pupil": 1.3, "star": true, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_VIOLET, 
		"fx": [], "impulse": 0.0}, 
	Mood.FOCUSED: {"mode": EyeMode.OPEN, "open": 0.8, "lid": 0.35, 
		"lid_angle": 0.38, "cheek": 0.0, "pupil": 0.8, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_VIOLET, 
		"fx": [], "impulse": 0.0}, 
	Mood.NERVOUS: {"mode": EyeMode.OPEN, "open": 0.95, "lid": 0.15, 
		"lid_angle": -0.3, "cheek": 0.0, "pupil": 0.7, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_VIOLET, 
		"fx": ["sweat"], "impulse": 0.0}, 
	Mood.ANGRY: {"mode": EyeMode.OPEN, "open": 0.75, "lid": 0.5, 
		"lid_angle": 0.6, "cheek": 0.0, "pupil": 0.7, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_RED, 
		"fx": [], "impulse": 0.0}, 
	Mood.SAD: {"mode": EyeMode.OPEN, "open": 0.6, "lid": 0.4, 
		"lid_angle": -0.55, "cheek": 0.0, "pupil": 0.9, "star": false, 
		"track": false, "bias": Vector2(0.0, 7.0), "tint": TINT_VIOLET, 
		"fx": [], "impulse": 0.0}, 
	Mood.HIT_LIGHT: {"mode": EyeMode.SQUEEZE, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.0, "pupil": 1.0, "star": false, 
		"track": false, "bias": Vector2.ZERO, "tint": TINT_RED, 
		"fx": [], "impulse": 5.0}, 
	Mood.HIT_HEAVY: {"mode": EyeMode.XEYES, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.0, "pupil": 1.0, "star": false, 
		"track": false, "bias": Vector2.ZERO, "tint": TINT_RED, 
		"fx": [], "impulse": 10.0}, 
	Mood.STUNNED: {"mode": EyeMode.SPIRAL, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.0, "pupil": 1.0, "star": false, 
		"track": false, "bias": Vector2.ZERO, "tint": TINT_RED, 
		"fx": [], "impulse": 6.0}, 
	Mood.PERFECT: {"mode": EyeMode.OPEN, "open": 1.0, "lid": 0.0, 
		"lid_angle": 0.0, "cheek": 0.3, "pupil": 1.15, "star": true, 
		"track": false, "bias": Vector2.ZERO, "tint": TINT_GOLD, 
		"fx": ["sparks"], "impulse": 0.0}, 


	Mood.COMBO_MODE: {"mode": EyeMode.OPEN, "open": 0.95, "lid": 0.5, 
		"lid_angle": 0.65, "cheek": 0.15, "pupil": 1.15, "star": false, 
		"flame": true, "track": true, "bias": Vector2.ZERO, "tint": TINT_GOLD, 
		"fx": ["flame"], "impulse": 0.0}, 


	Mood.BLOCK: {"mode": EyeMode.OPEN, "open": 0.78, "lid": 0.45, 
		"lid_angle": 0.5, "cheek": 0.25, "pupil": 0.8, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_NEUTRAL, 
		"fx": [], "impulse": 0.0}, 
	Mood.PERFECT_BLOCK: {"mode": EyeMode.OPEN, "open": 0.82, "lid": 0.5, 
		"lid_angle": 0.55, "cheek": 0.35, "pupil": 0.75, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_GOLD, 
		"fx": ["sparks"], "impulse": 0.0}, 
	Mood.COUNTER: {"mode": EyeMode.OPEN, "open": 0.7, "lid": 0.55, 
		"lid_angle": 0.6, "cheek": 0.3, "pupil": 0.7, "star": false, 
		"track": true, "bias": Vector2.ZERO, "tint": TINT_GOLD, 
		"fx": ["speed_lines"], "impulse": 0.0}, 
}

@export var body_radius: = 40.0

@export var ease_speed: = 10.0




@export var show_line: = true


@export var show_gem: = true



var body_alpha: = 1.0







var eye_reveal: = 1.0



var blink_enabled: = true





var gaze_centered: = false



var beat_kick_amount: = 0.0

var expression: int = Mood.NEUTRAL
var _base_expression: int = Mood.NEUTRAL





var hype: = 0.0
var _reaction_gen: = 0

var _look_target = null




@export var playful: = false
var _pl_prev_angle: = 0.0
var _pl_wind: = 0.0
var _pl_hover: = 0.0
var _pl_warned: = false
var _pl_next_growl: = 0.0
var _pl_spinning: = false


var _open: = 1.0
var _lid: = 0.0
var _lid_angle: = 0.0
var _cheek: = 0.0
var _pupil: = 1.0
var _tint: = TINT_NEUTRAL
var _mode_blend: = 1.0
var _dash_bias: = Vector2.ZERO
var _saccade: = Vector2.ZERO

var _rig: Node2D
var _eyes: Array = []
var _fx: = {}
var _fx_forced: = {}
var _impulse: = 0.0
var _blink: = 0.0
var _next_blink: = 2.0
var _glow_tex: Texture2D


func _ready() -> void :

	var grad: = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.8))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	grad.add_point(0.45, Color(1, 1, 1, 0.25))
	var gt: = GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.02)
	gt.width = 128
	gt.height = 128
	_glow_tex = gt
	_rig = OrbRig.new()
	_rig.orb = self
	add_child(_rig)
	_build_fx()
	for side in [-1.0, 1.0]:
		var eye: = OrbEye.new()
		eye.orb = self
		eye.side = side
		eye.position = Vector2(side * body_radius * 0.4, - body_radius * 0.14)
		_rig.add_child(eye)
		_eyes.append(eye)





func set_expression(e: int) -> void :
	_base_expression = e
	_reaction_gen += 1
	_apply_expression(e)




func play_reaction(e: int, duration: = 0.8) -> void :
	_reaction_gen += 1
	var gen: = _reaction_gen
	_apply_expression(e)
	await get_tree().create_timer(duration).timeout
	if gen != _reaction_gen or not is_inside_tree():
		return
	_apply_expression(_base_expression)
	reaction_finished.emit(e)




func set_look_target(target) -> void :
	assert (target == null or target is Vector2 or target is Node2D, 
		"look_target : Vector2, Node2D ou null")
	_look_target = target




func set_effect(effect: String, enabled: bool) -> void :
	_fx_forced[effect] = enabled
	_apply_effects()


func clear_effect(effect: String) -> void :
	_fx_forced.erase(effect)
	_apply_effects()





func fire_mode() -> bool:
	return hype > 0.6





func pupil_is_flame() -> bool:
	var p: Dictionary = PRESETS[expression]
	if bool(p.get("flame", false)):
		return true
	return fire_mode() and p["mode"] == EyeMode.OPEN and not p["star"]




func beat_kick(strength: = 1.0) -> void :
	beat_kick_amount = maxf(beat_kick_amount, clampf(strength, 0.0, 1.0))




func set_hype(h: float) -> void :
	var was: = hype
	hype = clampf(h, 0.0, 1.0)
	if (was > 0.6) != (hype > 0.6):
		_apply_effects()





func dash(dir: int, strength: = 9.0) -> void :
	_dash_bias = Vector2(signf(dir) * strength * (1.0 + 0.7 * hype), 0.0)
	var lines: GPUParticles2D = _fx["speed_lines"]
	(lines.process_material as ParticleProcessMaterial).direction = \
	Vector3( - signf(dir), 0.0, 0.0)
	if not _fx_forced.get("speed_lines", false):
		lines.restart()
		lines.emitting = true




func _apply_expression(e: int) -> void :
	if e == expression:
		return
	var was_mode: int = PRESETS[expression]["mode"]
	expression = e
	if PRESETS[e]["mode"] != was_mode:
		_mode_blend = 0.0
	_impulse = maxf(_impulse, PRESETS[e]["impulse"] * (1.0 + 0.8 * hype))
	_apply_effects()
	expression_changed.emit(e)





func _apply_effects() -> void :
	var preset_fx: Array = PRESETS[expression]["fx"]
	for fx_name in _fx:
		var auto: bool = fx_name in preset_fx\
		or (fx_name == "flame" and hype > 0.6)
		var want: bool = _fx_forced.get(fx_name, auto)
		var p: GPUParticles2D = _fx[fx_name]
		if p.one_shot:
			if want and not p.emitting:
				p.restart()
		elif p.emitting != want:
			p.emitting = want


func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	var preset: Dictionary = PRESETS[expression]

	var k: = 1.0 - exp( - ease_speed * (1.0 + 0.8 * hype) * delta)



	var t_open: float = preset["open"]
	var t_lid: float = preset["lid"]
	var t_angle: float = preset["lid_angle"]
	var t_pupil: float = preset["pupil"]
	var t_tint: Color = preset["tint"]
	if fire_mode() and preset["mode"] == EyeMode.OPEN:
		t_open = maxf(t_open, 0.92)
		t_lid = maxf(t_lid, 0.5)
		t_angle = maxf(t_angle, 0.6)
		t_pupil = maxf(t_pupil, 1.12)
		t_tint = t_tint.lerp(Color(1.0, 0.55, 0.18), 0.45)
	_open = lerpf(_open, t_open, k)
	_lid = lerpf(_lid, t_lid, k)
	_lid_angle = lerpf(_lid_angle, t_angle, k)
	_cheek = lerpf(_cheek, preset["cheek"], k)
	_pupil = lerpf(_pupil, t_pupil, k)
	_tint = _tint.lerp(t_tint, k)
	_mode_blend = minf(1.0, _mode_blend + delta * 6.0)


	_dash_bias *= exp(-9.0 * delta)
	if _dash_bias.length() < 0.8 and _fx.has("speed_lines")\
	and not _fx_forced.get("speed_lines", false)\
	and not ("speed_lines" in preset["fx"]):
		(_fx["speed_lines"] as GPUParticles2D).emitting = false
	if _impulse > 0.05:
		_impulse *= exp(-8.0 * delta)
	beat_kick_amount = maxf(0.0, beat_kick_amount - delta * 2.8)


	if blink_enabled and preset["mode"] == EyeMode.OPEN and not preset["star"]:
		_next_blink -= delta
		if _next_blink <= 0.0:
			_next_blink = randf_range(2.2, 4.8) * (1.0 - 0.55 * hype)
			_blink = 1.0
	_blink = maxf(0.0, _blink - delta * (7.0 + 4.0 * hype))

	var tsec: = Time.get_ticks_msec() / 1000.0
	_saccade = Vector2(sin(tsec * 11.3) + sin(tsec * 27.1) * 0.5, 
		cos(tsec * 15.7)) * 2.6 * hype

	var look: = _resolve_look_local()
	var er: = clampf(eye_reveal, 0.0, 1.0)







	var needs_clip: = eye_openness() < 0.99 or _cheek > 0.01 or _lid > 0.01
	var want_clip: = CanvasItem.CLIP_CHILDREN_AND_DRAW if needs_clip\
	else CanvasItem.CLIP_CHILDREN_DISABLED
	for eye in _eyes:


		eye.visible = er > 0.015
		eye.scale = Vector2(1.0, er)
		if eye.clip_children != want_clip:
			eye.clip_children = want_clip
		eye.set_look(look, k)
	if playful:
		_playful_update(delta, look)
	queue_redraw()
	_rig.queue_redraw()



func _resolve_look_local() -> Vector2:
	var g: Vector2
	if _look_target is Node2D and is_instance_valid(_look_target):
		g = (_look_target as Node2D).global_position
	elif _look_target is Vector2:
		g = _look_target
	else:
		g = get_global_mouse_position()
	return _rig.to_local(g)





func _playful_update(delta: float, look: Vector2) -> void :
	var dist: = look.length()




	var ang: = look.angle()
	var d_ang: = wrapf(ang - _pl_prev_angle, - PI, PI)
	_pl_prev_angle = ang
	if dist > 60.0 and dist < 420.0 and absf(d_ang) < 0.5:
		_pl_wind += d_ang
	_pl_wind = move_toward(_pl_wind, 0.0, delta * 1.8)
	if not _pl_spinning and absf(_pl_wind) > TAU * 1.5:
		_pl_spin(signf(_pl_wind))


	if dist < 55.0 and not _pl_spinning:
		_pl_hover += delta
		if _pl_hover > 2.0 and _pl_hover >= _pl_next_growl:
			_pl_next_growl = _pl_hover + 1.8
			play_reaction(Mood.ANGRY, 1.4)
		elif _pl_hover > 0.7 and not _pl_warned:
			_pl_warned = true
			play_reaction(Mood.NERVOUS, 0.8)
	elif _pl_hover > 0.0:
		if _pl_next_growl > 0.0:
			play_reaction(Mood.HAPPY, 0.7)
		_pl_hover = 0.0
		_pl_warned = false
		_pl_next_growl = 0.0



func _pl_spin(dir: float) -> void :
	_pl_spinning = true
	_pl_wind = 0.0
	play_reaction(Mood.EXCITED, 0.6)
	var tw: = create_tween()
	tw.tween_property(_rig, "rotation", TAU * dir, 0.6)\
	.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_callback( func() -> void :
		_rig.rotation = 0.0
		_pl_spinning = false
		play_reaction(Mood.STUNNED, 1.0))



func eye_openness() -> float:
	var blink_cut: = 1.0 - clampf(sin(_blink * PI), 0.0, 1.0)
	return clampf(_open * blink_cut, 0.04, 1.0)




func _build_fx() -> void :

	_fx["sparks"] = _particles(14, 0.55, true, _mat(Vector3(0, -1, 0), 200.0, 
		360.0, Vector3.ZERO, TINT_GOLD * 1.3, body_radius * 0.9))

	_fx["flame"] = _particles(26, 0.55, false, _mat(Vector3(0, -1, 0), 70.0, 
		24.0, Vector3(0, -40, 0), Color(1.3, 0.8, 0.25, 0.85), body_radius))

	var sweat: = _particles(3, 0.8, false, _mat(Vector3(0.4, -1, 0), 60.0, 
		22.0, Vector3(0, 420, 0), Color(0.55, 0.85, 1.0, 0.9), 3.0))
	sweat.position = Vector2(body_radius * 0.55, - body_radius * 0.85)
	_fx["sweat"] = sweat

	var lines: = _particles(12, 0.22, false, _mat(Vector3(-1, 0, 0), 380.0, 
		8.0, Vector3.ZERO, Color(0.55, 0.95, 1.0, 0.5), body_radius * 0.7))
	_fx["speed_lines"] = lines


func _particles(amount: int, life: float, one_shot: bool, 
		mat: ParticleProcessMaterial) -> GPUParticles2D:
	var p: = GPUParticles2D.new()
	p.amount = amount
	p.lifetime = life
	p.one_shot = one_shot
	p.explosiveness = 1.0 if one_shot else 0.0
	p.emitting = false
	p.process_material = mat


	p.show_behind_parent = true
	_rig.add_child(p)
	return p


func _mat(dir: Vector3, vel: float, spread: float, gravity: Vector3, 
		color: Color, radius: float) -> ParticleProcessMaterial:
	var m: = ParticleProcessMaterial.new()
	m.direction = dir
	m.spread = spread
	m.initial_velocity_min = vel * 0.55
	m.initial_velocity_max = vel
	m.gravity = gravity
	m.color = color
	m.scale_min = 2.8
	m.scale_max = 5.5
	m.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	m.emission_sphere_radius = radius
	return m






class OrbRig:
	extends Node2D
	var orb: Orb

	func _process(_d: float) -> void :


		var t: = Time.get_ticks_msec() / 1000.0
		var h: float = orb.hype
		position = Vector2(0.0, sin(t * (2.1 + 4.5 * h)) * (2.2 + 1.8 * h))
		if h > 0.05:
			position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 0.9 * h
		if orb._impulse > 0.05:
			position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * orb._impulse


		var kick: = orb.beat_kick_amount * SettingsManager.menu_fx_intensity
		scale = Vector2.ONE * (1.0 + (0.012 + 0.02 * h)
			* sin(t * (2.1 + 4.5 * h) + 1.3) + 0.015 * kick)

	func _draw() -> void :
		var r: = orb.body_radius
		var tint: = orb._tint
		var ba: float = orb.body_alpha
		if ba <= 0.004:
			return

		var hs: = r * (3.4 + 0.35 * orb.beat_kick_amount)
		draw_texture_rect(orb._glow_tex, Rect2(Vector2( - hs, - hs) * 0.5, 
			Vector2(hs, hs)), false, 
			Color(tint.r, tint.g, tint.b, (0.1 + 0.05 * orb.beat_kick_amount) * ba))
		var ly: = r * 0.88
		if orb.show_line:

			var lw: = r * 2.6
			draw_line(Vector2( - lw, ly), Vector2(lw, ly), 
				Color(tint.r, tint.g, tint.b, 0.55 * ba), 2.0)
			draw_line(Vector2( - lw * 1.6, ly), Vector2( - lw, ly), 
				Color(tint.r, tint.g, tint.b, 0.16 * ba), 2.0)
			draw_line(Vector2(lw, ly), Vector2(lw * 1.6, ly), 
				Color(tint.r, tint.g, tint.b, 0.16 * ba), 2.0)

		draw_circle(Vector2.ZERO, r, Color(Orb.BODY_FILL, Orb.BODY_FILL.a * ba))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, 
			Color(tint.r * 1.25, tint.g * 1.25, tint.b * 1.25, 0.95 * ba), 2.5)
		if orb.show_gem:

			var dc: = Vector2(0.0, ly)
			var s: = r * 0.14
			draw_colored_polygon(PackedVector2Array([dc + Vector2(0, - s), 
				dc + Vector2(s * 0.7, 0), dc + Vector2(0, s), 
				dc + Vector2( - s * 0.7, 0)]), 
				Color(tint.r * 1.35, tint.g * 1.35, tint.b * 1.35, ba))





class OrbEye:
	extends Node2D
	var orb: Orb
	var side: = 1.0
	var pupil: OrbPupil
	var lid: OrbLid

	func _ready() -> void :




		clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
		pupil = OrbPupil.new()
		pupil.eye = self
		add_child(pupil)
		lid = OrbLid.new()
		lid.eye = self
		add_child(lid)

	func rx() -> float:
		return orb.body_radius * 0.3

	func ry() -> float:
		return orb.body_radius * 0.36



	func set_look(look_rig: Vector2, k: float) -> void :
		var preset: Dictionary = Orb.PRESETS[orb.expression]
		var wanted: Vector2 = preset["bias"]
		if orb.gaze_centered:



			pupil.position = pupil.position.lerp(wanted, k)
			pupil.queue_redraw()
			lid.queue_redraw()
			queue_redraw()
			return
		if preset["track"]:
			wanted = look_rig - position
		wanted += orb._dash_bias
		if preset["track"]:
			wanted += orb._saccade
		var max_r: = minf(rx(), ry() * orb.eye_openness())\
		- pupil.radius() * 0.55
		wanted = wanted.limit_length(maxf(max_r, 0.0))
		pupil.position = pupil.position.lerp(wanted, k)
		pupil.queue_redraw()
		lid.queue_redraw()
		queue_redraw()

	func _draw() -> void :
		var mode: int = Orb.PRESETS[orb.expression]["mode"]
		var blend: = orb._mode_blend



		var col: = Color(Orb.EYE_WHITE.r * 1.12, Orb.EYE_WHITE.g * 1.12, 
			Orb.EYE_WHITE.b * 1.12, blend)
		match mode:
			Orb.EyeMode.OPEN:

				draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, ry() / rx()))
				draw_circle(Vector2.ZERO, rx() * blend, col)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			Orb.EyeMode.ARC:

				draw_arc(Vector2(0, 3), rx() * blend, PI, TAU, 18, col, 3.6)
			Orb.EyeMode.SQUEEZE:

				var w: = rx() * 0.9 * blend
				var pts: = PackedVector2Array([
					Vector2(side * w, - ry() * 0.6), Vector2( - side * w * 0.5, 0), 
					Vector2(side * w, ry() * 0.6)])
				draw_polyline(pts, col, 3.4)
			Orb.EyeMode.XEYES:
				var w2: = rx() * 0.85 * blend
				draw_line(Vector2( - w2, - w2), Vector2(w2, w2), col, 3.4)
				draw_line(Vector2( - w2, w2), Vector2(w2, - w2), col, 3.4)
			Orb.EyeMode.SPIRAL:

				var pts2: = PackedVector2Array()
				for i in 34:
					var a: = float(i) / 33.0
					var ang: = side * a * TAU * 2.2\
					+ Time.get_ticks_msec() / 1000.0 * 3.0 * side
					pts2.append(Vector2.from_angle(ang) * (2.0 + a * rx() * 0.85))
				draw_polyline(pts2, col, 2.2)



class OrbPupil:
	extends Node2D
	var eye: OrbEye

	func radius() -> float:
		return eye.rx() * 0.46 * eye.orb._pupil

	func _process(_d: float) -> void :
		if eye.orb.pupil_is_flame():
			queue_redraw()



	func _flame_poly(w: float, h: float, sway: float) -> PackedVector2Array:
		var pts: = PackedVector2Array()
		for i in 7:
			var a: = PI * float(i) / 6.0
			pts.append(Vector2(cos(a) * w, h * 0.3 + sin(a) * w * 0.9))
		pts.append(Vector2( - w * 0.55 + sway * 0.4, - h * 0.25))
		pts.append(Vector2(sway, - h))
		pts.append(Vector2(w * 0.55 + sway * 0.4, - h * 0.25))
		return pts

	func _draw() -> void :
		var preset: Dictionary = Orb.PRESETS[eye.orb.expression]
		if preset["mode"] != Orb.EyeMode.OPEN:
			return
		var r: = radius()
		if eye.orb.pupil_is_flame():



			var t: = Time.get_ticks_msec() / 1000.0
			var flicker: = sin(t * 21.0 + eye.side * 1.7) * 0.14\
			+ sin(t * 13.7 + eye.side) * 0.1
			var sway: = (sin(t * 17.0 + eye.side * 2.4)
				+ sin(t * 29.0) * 0.5) * r * 0.22
			var h: = r * 1.45 * (1.0 + flicker)
			draw_colored_polygon(_flame_poly(r * 0.68, h, sway), 
				Color(1.35, 0.72, 0.2))
			draw_colored_polygon(_flame_poly(r * 0.38, h * 0.62, sway * 0.7), 
				Color(1.6, 1.25, 0.55))
			return
		draw_circle(Vector2.ZERO, r, Color(0.06, 0.06, 0.09))
		if preset["star"]:

			var s: = r * 0.95
			draw_colored_polygon(PackedVector2Array([
				Vector2(0, - s), Vector2(s * 0.3, - s * 0.3), Vector2(s, 0), 
				Vector2(s * 0.3, s * 0.3), Vector2(0, s), 
				Vector2( - s * 0.3, s * 0.3), Vector2( - s, 0), 
				Vector2( - s * 0.3, - s * 0.3)]), Orb.EYE_WHITE)
		else:
			draw_circle(Vector2( - r * 0.3, - r * 0.35), r * 0.24, 
				Color(1, 1, 1, 0.9))





class OrbLid:
	extends Node2D
	var eye: OrbEye

	func _draw() -> void :
		if Orb.PRESETS[eye.orb.expression]["mode"] != Orb.EyeMode.OPEN:
			return


		var lc: = Orb.BODY_FILL
		var rx: = eye.rx() + 4.0
		var ry: = eye.ry() + 4.0
		var cover: = (1.0 - eye.orb.eye_openness()) * ry * 2.0
		if cover > 0.5:
			draw_rect(Rect2( - rx, - ry, rx * 2.0, cover), lc)


		var cheek: float = eye.orb._cheek
		if cheek > 0.01:
			var ch: = cheek * ry * 1.5
			draw_rect(Rect2( - rx, ry - ch, rx * 2.0, ch + 4.0), lc)
		var lid: float = eye.orb._lid
		if lid > 0.01:

			draw_set_transform(Vector2.ZERO, eye.side * eye.orb._lid_angle, 
				Vector2.ONE)
			draw_rect(Rect2( - rx - 3.0, - ry - 3.0, (rx + 3.0) * 2.0, 
				lid * ry + 3.0), lc)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
