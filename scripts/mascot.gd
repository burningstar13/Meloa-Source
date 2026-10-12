class_name Mascot
extends Node2D





























signal expression_changed(id: StringName)
signal reaction_finished(id: StringName)


signal spin_stage_changed(stage: int)

enum Look{MOUSE, FORWARD, CENTER, LEFT, RIGHT, POSITION, NODE, CUSTOM}

const FACE_FILL: = Color(0.055, 0.06, 0.085, 1.0)
const EYE_WHITE: = Color(0.97, 0.98, 1.0)
const INK: = Color(0.1, 0.1, 0.16)


@export var data: MascotData

@export_group("Regard")


@export var max_pupil_offset_x: = 0.0
@export var max_pupil_offset_y: = 0.0

@export var pupil_smoothing: = 9.0

@export var pupil_follow_speed: = 260.0

@export var gaze_falloff: = 160.0

@export_group("Vie de la tête")
@export var idle_bob_amp: = 1.8
@export var idle_bob_speed: = 2.0

@export var beat_scale_amp: = 0.018
@export var blink_enabled: = true


@export var display_scale: = 1.0


@export var hover_glow_enabled: = false


var beat_pulse: = 0.0
var mouse_pos: = Vector2.ZERO
var lane: = 0



var _shield: = 0.0
var _shield_fx: ShieldFX





var playful: = false

var spin_enabled: = true


var hover_stages: Array = [
	[0.5, [&"chipie", &"malice", &"annoyed"]], 
	[5.5, [&"angry", &"annoyed", &"disgust"]], 
	[10.5, [&"blank", &"indi", &"tired"]], 
	[15.5, [&"uwu", &"joueuse", &"happy"]], 
]


var eye_reveal: = 1.0


var body_alpha: = 1.0


var gaze_centered: = false

var ease_speed: float:
	get:
		return pupil_smoothing
	set(v):
		pupil_smoothing = v


var body_radius: float:
	get:
		if data != null and data.has_art():
			return data.canvas_px * 0.48 * data.art_scale * display_scale
		return (data.head_radius if data != null else 36.0) * display_scale

var look_mode: int = Look.MOUSE
var _look_point: = Vector2.ZERO
var _look_node: Node2D = null
var _look_call: = Callable()

var expression: StringName = &"neutral"
var _base_expression: StringName = &"neutral"
var _expressions: = {}
var _expr: MascotExpression
var _reaction_gen: = 0
var _lock_until_ms: = 0


var _eye_open: = 1.0
var _brow_off: = Vector2.ZERO
var _brow_ang: = 0.0
var _mouth_curve: = 0.0
var _mouth_open: = 0.0
var _head_tilt: = 0.0


var _punch: = Vector2.ONE
var _recoil: = Vector2.ZERO
var _impulse: = 0.0
var _blink: = 0.0
var _next_blink: = 2.5
var _bob_phase: = 0.0
var _spin_rot: = 0.0
var _dizzy: = 0.0
var _dizzy_dir: = 1.0
var _hover_glow: = 0.0
var _halo: Sprite2D


var _pl_prev_angle: = 0.0
var _pl_hover: = 0.0
var _pl_stage: = 0
var _pl_spinning: = false
var _spin_vel: = 0.0
var _spin_total: = 0.0
var _spin_time: = 0.0
var _spin_stage: = 0

var _orbit_charge: = 0.0


var _pupil_off: = Vector2.ZERO

var _overlay_active: = false

var _rig: Node2D
var _art: Node2D
var _head: MPart
var _accessory: MPart
var _eyes: Array = []
var _pupil_grps: Array = []
var _pupil_sprites: Array = []
var _cils_up: Array = []
var _cils_low: Array = []
var _paupieres: Array = []
var _eyes_full: Array = []
var _whites: Array = []
var _brows: Array = []
var _brow_sprites: Array = []
var _brow_base: Array = []
var _blush: Sprite2D
var _mouth: MPart
var _mouth_base: = Vector2.ZERO
var _nose: Sprite2D
var _deco_root: Node2D
var _deco_sprites: Array = []
var _overlay: Sprite2D
var _swap_gen: = 0
var _pop_tw: Tween


func _ready() -> void :
	if data == null:
		data = MascotData.new()
	lane = data.lane
	_bob_phase = float(lane) * 2.1
	for e in data.expressions:
		if e != null:
			_expressions[e.id] = e
	if _expressions.is_empty():
		_expressions[&"neutral"] = MascotExpression.new()
	_base_expression = &"neutral" if _expressions.has(&"neutral")\
	else _expressions.keys()[0]
	_rig = Node2D.new()
	add_child(_rig)


	var grad: = Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.85))
	grad.set_color(1, Color(1, 1, 1, 0.0))
	grad.add_point(0.35, Color(1, 1, 1, 0.35))
	var gt: = GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.5)
	gt.fill_to = Vector2(0.5, 0.02)
	gt.width = 256
	gt.height = 256
	_halo = Sprite2D.new()
	_halo.texture = gt
	_halo.modulate.a = 0.0
	_rig.add_child(_halo)
	_art = Node2D.new()
	_art.scale = Vector2.ONE * display_scale\
	* (data.art_scale if data.has_art() else 1.0)
	_rig.add_child(_art)
	if data.has_art():
		_build_layered()
	else:
		_build_placeholder()
	_overlay = Sprite2D.new()
	_overlay.visible = false
	_art.add_child(_overlay)
	_shield_fx = ShieldFX.new()
	_shield_fx.m = self
	_rig.add_child(_shield_fx)
	_expr = _expressions[_base_expression]
	expression = _base_expression
	_apply_textures()







func _build_layered() -> void :
	_head = _part(&"head", - data.canvas_anchor + _tex_c(data.head_tex), 
		data.head_tex, _art)

	_accessory = _part(&"accessory", 
		- data.canvas_anchor + _tex_c(data.accessory_tex), 
		data.accessory_tex, _art)
	_accessory.placeholder_enabled = false

	_blush = Sprite2D.new()
	_blush.visible = false
	_art.add_child(_blush)




	for b in [[data.sourcil_g_tex, data.sourcil_center_g], 
			[data.sourcil_d_tex, data.sourcil_center_d]]:
		var pivot: = Node2D.new()
		var base: Vector2 = (b[1] as Vector2) - data.canvas_anchor
		pivot.position = base
		_art.add_child(pivot)
		_brows.append(pivot)
		_brow_sprites.append(_aligned_sprite(b[0], b[1], pivot))
		_brow_base.append(base)
	var sides: = [
		[data.eye_center_g, data.pupille_g_tex, data.cil_g_tex, data.cil_bas_g_tex, 
			data.paupiere_g_tex], 
		[data.eye_center_d, data.pupille_d_tex, data.cil_d_tex, data.cil_bas_d_tex, 
			data.paupiere_d_tex], 
	]
	for s in sides:
		var center: Vector2 = s[0]
		var eye: = Node2D.new()
		eye.position = center - data.canvas_anchor
		_art.add_child(eye)
		_eyes.append(eye)
		var grp: = Node2D.new()
		eye.add_child(grp)
		_pupil_grps.append(grp)
		_pupil_sprites.append(_aligned_sprite(s[1], center, grp))
		_cils_low.append(_aligned_sprite(s[3], center, eye))
		_cils_up.append(_aligned_sprite(s[2], center, eye))
		_paupieres.append(_aligned_sprite(s[4], center, eye) if s[4] != null
			else null)


		var full: = Sprite2D.new()
		full.visible = false
		eye.add_child(full)
		_eyes_full.append(full)



	_mouth = _part(&"mouth", - data.canvas_anchor + Vector2.ZERO, null, _art)
	_mouth.placeholder_enabled = false
	_set_tex(_mouth, data.mouth_tex, _tex_c(data.mouth_tex))
	_nose = Sprite2D.new()
	_set_tex(_nose, data.nose_tex, _tex_c(data.nose_tex))
	if data.nose_tex != null:
		_nose.position = _tex_c(data.nose_tex) - data.canvas_anchor
	_art.add_child(_nose)

	_deco_root = Node2D.new()
	_art.add_child(_deco_root)




func _aligned_sprite(tex: Texture2D, pivot: Vector2, parent: Node2D) -> Sprite2D:
	var sp: = Sprite2D.new()
	_set_tex(sp, tex, pivot)
	parent.add_child(sp)
	return sp





func _tex_c(tex: Texture2D) -> Vector2:
	if tex == null:
		return Vector2.ZERO
	if data != null and data.has_art():
		return Vector2.ONE * data.canvas_px * 0.5
	return tex.get_size() * 0.5




func _tex_k(tex: Texture2D) -> float:
	if tex == null or data == null or not data.has_art():
		return 1.0
	var w: = tex.get_size().x
	return data.canvas_px / w if w > 0.0 else 1.0





func _set_tex(sp: Sprite2D, tex: Texture2D, pivot: Vector2) -> void :
	sp.texture = tex
	if tex == null:
		return
	var k: = _tex_k(tex)
	sp.scale = Vector2.ONE * k
	sp.offset = (_tex_c(tex) - pivot) / k





func _build_placeholder() -> void :
	_head = _part(&"head", Vector2.ZERO, null, _art)
	_accessory = _part(&"accessory", data.accessory_offset, null, _art)
	for side in [-1.0, 1.0]:
		var eye: = Node2D.new()
		eye.position = Vector2(data.eye_offset.x * side, data.eye_offset.y)
		_art.add_child(eye)
		_eyes.append(eye)
		var white: = _part(&"eye_white", Vector2.ZERO, null, eye)
		_whites.append(white)
		var grp: = Node2D.new()
		eye.add_child(grp)
		_pupil_grps.append(grp)
		_part(&"iris", Vector2.ZERO, null, grp)
		_pupil_sprites.append(_part(&"pupil", Vector2.ZERO, null, grp))
		_part(&"highlight", Vector2(-1.8, -2.4), null, grp)
		var brow: = _part(&"brow", 
			Vector2(data.brow_offset.x * side, data.brow_offset.y), null, _art)
		brow.side = side
		_brows.append(brow)
		_brow_sprites.append(brow)
		_brow_base.append(brow.position)
	_mouth = _part(&"mouth", data.mouth_offset, null, _art)



func _part(kind: StringName, pos: Vector2, tex: Texture2D, parent: Node2D) -> MPart:
	var p: = MPart.new()
	p.kind = kind
	p.m = self
	p.position = pos
	_set_tex(p, tex, _tex_c(tex))
	parent.add_child(p)
	return p






func _is_locked() -> bool:
	return Time.get_ticks_msec() < _lock_until_ms




func set_expression(id: StringName) -> void :
	if not _expressions.has(id):
		push_warning("Mascotte %s : expression inconnue '%s'" % [data.character_id, id])
		return
	if _is_locked():
		return
	_base_expression = id
	_reaction_gen += 1
	_apply_expression(id)




func play_reaction(id: StringName, duration: = 0.6, lock: = false) -> void :
	if not _expressions.has(id):
		return
	if _is_locked() and not lock:
		return
	if lock:
		_lock_until_ms = Time.get_ticks_msec() + int(duration * 1000.0)
	_reaction_gen += 1
	var gen: = _reaction_gen
	_apply_expression(id)
	await get_tree().create_timer(duration).timeout
	if gen != _reaction_gen or not is_inside_tree():
		return
	_apply_expression(_base_expression)
	reaction_finished.emit(id)


func has_expression(id: StringName) -> bool:
	return _expressions.has(id)




func _pick_expr(prefs: Array) -> StringName:
	for id in prefs:
		if _expressions.has(id):
			return id
	return _base_expression




func idle_flourish() -> void :
	var pool: Array = []
	for id in [&"uwu", &"smile", &"chipie", &"blank", &"excited", 
			&"joueuse", &"malice", &"intrigued"]:
		if _expressions.has(id):
			pool.append(id)
	if pool.is_empty():
		return
	play_reaction(pool.pick_random(), 1.2)




func set_look_target(target) -> void :
	if target == null:
		set_look(Look.MOUSE)
	elif target is Vector2:
		set_look(Look.POSITION, target)
	elif target is Node2D:
		set_look(Look.NODE, target)




func beat_kick(strength: = 1.0) -> void :
	beat_pulse = maxf(beat_pulse, clampf(strength, 0.0, 1.0))




func set_look(mode: int, target = null) -> void :
	look_mode = mode
	match mode:
		Look.POSITION:
			_look_point = target if target is Vector2 else Vector2.ZERO
		Look.NODE:
			_look_node = target if target is Node2D else null
			if _look_node == null:
				look_mode = Look.MOUSE
		Look.CUSTOM:
			_look_call = target if target is Callable else Callable()
			if not _look_call.is_valid():
				look_mode = Look.MOUSE






func react_hit() -> void :
	_punch = Vector2(1.05, 1.09)


func react_perfect() -> void :
	_punch = Vector2(1.09, 1.16)

	play_reaction(_pick_expr([&"excited", &"lmfao", &"joueuse", &"smile"]), 0.45)



func react_shock() -> void :
	play_reaction(_pick_expr([&"surprised", &"panic", &"stunned"]), 0.55)


func react_dodge() -> void :
	_shield = 1.0
	_recoil = Vector2(0.0, 2.5)

	play_reaction(_pick_expr([&"laugh", &"happy", &"joueuse", &"smile"]), 0.5)



func react_break() -> void :
	_punch = Vector2(1.06, 0.92)
	play_reaction(_pick_expr([&"annoyed", &"disgust", &"sad"]), 0.8)



func react_glance() -> void :
	play_reaction(_pick_expr([&"smile", &"happy", &"joueuse"]), 1.2)




func set_mood(prefs: Array) -> void :
	var id: = _pick_expr(prefs + [&"neutral"])
	if id != _base_expression:
		set_expression(id)




func react_miss(red: = false) -> void :
	_punch = Vector2(1.12, 0.85)
	_recoil = Vector2(0.0, 6.0)
	_impulse = 4.0
	if red:
		play_reaction(_pick_expr([&"annoyed", &"hurt", &"sad"]), 0.8)
	else:
		play_reaction(_pick_expr([&"hurt", &"sad"]), 0.8)




func react_incoming() -> void :
	play_reaction(_pick_expr([&"joueuse", &"scared"]), 0.6)


func react_combo(_milestone: int) -> void :
	_punch = Vector2(1.1, 1.18)
	play_reaction(_pick_expr([&"idol", &"excited", &"joueuse", &"smile"]), 0.9)


func react_map_complete() -> void :
	set_expression(_pick_expr([&"idol", &"happy", &"joueuse", &"laugh", &"smile"]))


func react_game_over() -> void :
	set_expression(_pick_expr([&"ko", &"hurt", &"tired"]))




func _apply_expression(id: StringName) -> void :
	if id == expression:
		return
	var next: MascotExpression = _expressions[id]




	var bridge: = data.has_art() and _eye_swap_needed(_expr, next)
	expression = id
	_expr = next
	if bridge:
		_blink = 1.0
		_swap_gen += 1
		var gen: = _swap_gen
		get_tree().create_timer(0.07).timeout.connect( func() -> void :
			if gen == _swap_gen and is_inside_tree():
				_apply_textures()
				_swap_pop())
	else:
		_apply_textures()
		_swap_pop()
	expression_changed.emit(id)




func _eye_swap_needed(a: MascotExpression, b: MascotExpression) -> bool:
	return a.eyes_g_tex != b.eyes_g_tex or a.eyes_d_tex != b.eyes_d_tex\
	or a.pupille_g_tex != b.pupille_g_tex\
	or a.pupille_d_tex != b.pupille_d_tex\
	or a.cil_g_tex != b.cil_g_tex or a.cil_d_tex != b.cil_d_tex\
	or a.cil_bas_g_tex != b.cil_bas_g_tex\
	or a.cil_bas_d_tex != b.cil_bas_d_tex





func _swap_pop() -> void :
	if _pop_tw != null and _pop_tw.is_valid():
		_pop_tw.kill()
	_pop_tw = create_tween()
	var popped: = false
	if _mouth != null and _mouth.visible and _mouth.texture != null:
		_mouth.position = _mouth_base + Vector2(0.0, 6.0)
		_mouth.modulate.a = 0.3
		_pop_tw.tween_property(_mouth, "position", _mouth_base, 0.15)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		_pop_tw.parallel().tween_property(_mouth, "modulate:a", 1.0, 0.1)
		popped = true
	if _blush != null and _blush.visible:
		_blush.modulate.a = 0.0
		var t: = _pop_tw.parallel() if popped else _pop_tw
		t.tween_property(_blush, "modulate:a", 1.0, 0.16)
		popped = true
	if _deco_root != null and _deco_root.visible and not _expr.decos.is_empty():
		_deco_root.modulate.a = 0.0
		var td: = _pop_tw.parallel() if popped else _pop_tw
		td.tween_property(_deco_root, "modulate:a", 1.0, 0.16)
		popped = true
	if not popped:
		_pop_tw.kill()




func _has_full_eyes() -> bool:
	return _expr.eyes_g_tex != null or _expr.eyes_d_tex != null




func _apply_textures() -> void :
	var ov: = _expr.overlay_tex != null
	_overlay_active = ov
	_set_tex(_overlay, _expr.overlay_tex, _tex_c(_expr.overlay_tex))
	if ov:
		_overlay.position = _tex_c(_expr.overlay_tex)\
		- (data.canvas_anchor if data.has_art() else Vector2.ZERO)
	_overlay.visible = ov
	for eye in _eyes:
		(eye as Node2D).visible = not ov
	for brow in _brows:
		(brow as Node2D).visible = not ov
	_mouth.visible = not ov
	if data.has_art():
		var over: = [
			[_expr.pupille_g_tex, data.pupille_g_tex, _pupil_sprites, 0, data.eye_center_g], 
			[_expr.pupille_d_tex, data.pupille_d_tex, _pupil_sprites, 1, data.eye_center_d], 
			[_expr.cil_g_tex, data.cil_g_tex, _cils_up, 0, data.eye_center_g], 
			[_expr.cil_d_tex, data.cil_d_tex, _cils_up, 1, data.eye_center_d], 
			[_expr.cil_bas_g_tex, data.cil_bas_g_tex, _cils_low, 0, data.eye_center_g], 
			[_expr.cil_bas_d_tex, data.cil_bas_d_tex, _cils_low, 1, data.eye_center_d], 
			[_expr.paupiere_g_tex, data.paupiere_g_tex, _paupieres, 0, data.eye_center_g], 
			[_expr.paupiere_d_tex, data.paupiere_d_tex, _paupieres, 1, data.eye_center_d], 
		]
		for o in over:
			var sp: Sprite2D = o[2][o[3]]
			if sp == null:
				continue
			var tex: Texture2D = o[0] if o[0] != null else o[1]
			_set_tex(sp, tex, o[4] as Vector2)


		for i in 2:
			var ft: Texture2D = _expr.eyes_g_tex if i == 0 else _expr.eyes_d_tex
			var ec: Vector2 = data.eye_center_g if i == 0 else data.eye_center_d


			var closed: bool = _expr.close_eye_g if i == 0 else _expr.close_eye_d
			var fs: Sprite2D = _eyes_full[i]
			_set_tex(fs, ft, ec)
			fs.visible = ft != null
			(_pupil_grps[i] as Node2D).visible = ft == null and not closed
			(_cils_up[i] as Sprite2D).visible = ft == null
			(_cils_low[i] as Sprite2D).visible = ft == null and not closed
			if _paupieres[i] != null:
				(_paupieres[i] as Sprite2D).visible = ft == null and not closed


		for i in 2:
			var bt: Texture2D = _expr.sourcil_g_tex if i == 0 else _expr.sourcil_d_tex
			if bt == null:
				bt = data.sourcil_g_tex if i == 0 else data.sourcil_d_tex
			var bs: Sprite2D = _brow_sprites[i]
			_set_tex(bs, bt, data.sourcil_center_g if i == 0 else data.sourcil_center_d)

		_set_tex(_blush, _expr.blush_tex, _tex_c(_expr.blush_tex))
		if _expr.blush_tex != null:
			_blush.position = _tex_c(_expr.blush_tex) - data.canvas_anchor
		_blush.visible = _expr.blush_tex != null and not ov
		var mtex: Texture2D = _expr.mouth_tex if _expr.mouth_tex != null else data.mouth_tex
		_set_tex(_mouth, mtex, _tex_c(mtex))
		if mtex != null:
			_mouth_base = _tex_c(mtex) - data.canvas_anchor
			_mouth.position = _mouth_base
			_mouth.modulate.a = 1.0
		_mouth.visible = mtex != null and not ov
		var atex: Texture2D = _expr.accessory_tex if _expr.accessory_tex != null\
		else data.accessory_tex
		_set_tex(_accessory, atex, _tex_c(atex))
		if atex != null:
			_accessory.position = _tex_c(atex) - data.canvas_anchor
		_accessory.visible = atex != null
		var ntex: Texture2D = _expr.nose_tex if _expr.nose_tex != null else data.nose_tex
		if _expr.hide_nose and _expr.nose_tex == null:
			ntex = null
		_set_tex(_nose, ntex, _tex_c(ntex))
		if ntex != null:
			_nose.position = _tex_c(ntex) - data.canvas_anchor
		_nose.visible = ntex != null and not ov

		while _deco_sprites.size() < _expr.decos.size():
			var nds: = Sprite2D.new()
			_deco_root.add_child(nds)
			_deco_sprites.append(nds)
		for i in _deco_sprites.size():
			var ds: Sprite2D = _deco_sprites[i]
			var dtex: Texture2D = _expr.decos[i] if i < _expr.decos.size() else null
			_set_tex(ds, dtex, _tex_c(dtex))
			if dtex != null:
				ds.position = _tex_c(dtex) - data.canvas_anchor
			ds.visible = dtex != null
		_deco_root.visible = not ov
		_deco_root.modulate.a = 1.0
	else:
		for i in 2:
			(_pupil_sprites[i] as MPart).texture = \
			_expr.pupille_g_tex if i == 0 and _expr.pupille_g_tex != null\
			else (_expr.pupille_d_tex if i == 1 else null)
		_mouth.texture = _expr.mouth_tex


func _process(delta: float) -> void :



	if not is_visible_in_tree():
		return
	var k: = 1.0 - exp(-10.0 * delta)

	_eye_open = lerpf(_eye_open, _expr.eye_open, k)
	_brow_off = _brow_off.lerp(_expr.brow_offset, k)
	_brow_ang = lerpf(_brow_ang, _expr.brow_angle, k)
	_mouth_curve = lerpf(_mouth_curve, _expr.mouth_curve, k)
	_mouth_open = lerpf(_mouth_open, _expr.mouth_open, k)
	_head_tilt = lerpf(_head_tilt, _expr.head_tilt, k)


	if blink_enabled and _expr.eye_open > 0.5 and not _has_full_eyes():
		_next_blink -= delta
		if _next_blink <= 0.0:
			_next_blink = randf_range(2.4, 5.2)
			_blink = 1.0
	_blink = maxf(0.0, _blink - delta * 7.0)
	var blink_cut: = 1.0 - clampf(sin(_blink * PI), 0.0, 1.0)


	beat_pulse = maxf(0.0, beat_pulse - delta * 2.8)


	_head.self_modulate.a = body_alpha
	_mouth.self_modulate.a = body_alpha
	if _accessory != null:
		_accessory.self_modulate.a = body_alpha
	if _blush != null:
		_blush.self_modulate.a = body_alpha
	if _nose != null:
		_nose.self_modulate.a = body_alpha
	for ds in _deco_sprites:
		(ds as Sprite2D).self_modulate.a = body_alpha
	for bs in _brow_sprites:
		(bs as Sprite2D).self_modulate.a = body_alpha

	var t: = Time.get_ticks_msec() / 1000.0
	_punch = _punch.lerp(Vector2.ONE, 1.0 - exp(-9.0 * delta))
	_recoil *= exp(-8.0 * delta)
	if _impulse > 0.05:
		_impulse *= exp(-8.0 * delta)

	if _shield > 0.003:
		_shield = maxf(0.0, _shield - delta * 3.4)
		_shield_fx.queue_redraw()
	_rig.position = Vector2(0.0, sin(t * idle_bob_speed + _bob_phase) * idle_bob_amp)\
	+ _recoil
	if _impulse > 0.05:
		_rig.position += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _impulse




	_orbit_charge = move_toward(_orbit_charge, 0.0, delta * 3.0)
	if absf(_spin_vel) > 0.05:
		_spin_rot += _spin_vel * delta
		_spin_total += absf(_spin_vel) * delta
		_spin_time += delta



		_spin_vel *= exp(-1.4 * delta)



		var stage: = 0
		if _spin_time >= 6.0:
			stage = 3
		elif _spin_time >= 3.0:
			stage = 2
		elif absf(_spin_vel) > 6.0:
			stage = 1
		if stage != _spin_stage and not _is_locked():
			_spin_stage = stage
			spin_stage_changed.emit(stage)
			match stage:
				1:
					set_expression(_pick_expr([&"excited", &"joueuse"]))
				2:
					set_expression(_pick_expr([&"tired", &"stunned", &"surprised"]))
				3:
					set_expression(_pick_expr([&"scared", &"surprised"]))
		if _spin_time >= 3.0:
			_dizzy = maxf(_dizzy, 0.1)
			_dizzy_dir = signf(_spin_vel) if _spin_vel != 0.0 else 1.0
		if absf(_spin_vel) <= 2.5:
			var end_time: = _spin_time
			var end_total: = _spin_total
			var end_dir: = signf(_spin_vel) if _spin_vel != 0.0 else 1.0
			_spin_vel = 0.0
			_spin_total = 0.0
			_spin_time = 0.0
			if _spin_stage > 0:
				set_expression(&"neutral" if has_expression(&"neutral") else expression)
			if _spin_stage != 0:
				_spin_stage = 0
				spin_stage_changed.emit(0)
			if end_total > TAU * 2.0:
				_dizzy = 1.6
				_dizzy_dir = end_dir
				if end_time >= 10.0:


					_punch = Vector2(1.12, 0.85)
					_recoil = Vector2(0.0, 6.0)
					_impulse = 4.0
					play_reaction(_pick_expr([&"scared", &"tired"]), 1.8, true)
				else:

					play_reaction(_pick_expr([&"tired", &"stunned", &"surprised"]), 1.5, true)
	else:

		_spin_rot = wrapf(_spin_rot, - PI, PI) * exp(-6.0 * delta)
	_rig.rotation = _head_tilt + sin(t * 0.9 + _bob_phase) * 0.012 + _spin_rot


	var hover_want: = 0.0
	if hover_glow_enabled and get_global_mouse_position()\
	.distance_to(_rig.global_position) < body_radius * 1.15:
		hover_want = 1.0
	_hover_glow = lerpf(_hover_glow, hover_want, 1.0 - exp(-8.0 * delta))
	if _hover_glow > 0.003:
		var tint: = data.tint
		_halo.scale = Vector2.ONE * (body_radius * 3.4 / 256.0)\
		* (1.0 + 0.05 * sin(t * 3.0))
		_halo.modulate = Color(tint.r * 1.35, tint.g * 1.35, tint.b * 1.35, 
			0.42 * _hover_glow * body_alpha)
		var b: = 1.0 + 0.26 * _hover_glow
		_art.modulate = Color(b, b, b)
	else:
		_halo.modulate.a = 0.0
		_art.modulate = Color.WHITE
	_rig.scale = _punch * (1.0 + beat_scale_amp * beat_pulse
		+ 0.045 * _hover_glow)

	var max_off: = Vector2(
		max_pupil_offset_x if max_pupil_offset_x > 0.0 else _auto_max_x(), 
		max_pupil_offset_y if max_pupil_offset_y > 0.0 else _auto_max_y())
	var wanted: = _expr.pupil_bias
	if _dizzy > 0.0:


		_dizzy -= delta
		wanted = Vector2(cos(t * 8.0 * _dizzy_dir) * max_off.x, 
			sin(t * 8.0 * _dizzy_dir) * max_off.y) * 0.85
	elif _expr.pupil_track:
		wanted += _gaze_offset(max_off)

	var e: = Vector2(wanted.x / max_off.x, wanted.y / max_off.y)
	if e.length() > 1.0:
		e = e.normalized()
	wanted = Vector2(e.x * max_off.x, e.y * max_off.y)

	var step: = (wanted - _pupil_off) * (1.0 - exp( - pupil_smoothing * delta))
	var max_step: = pupil_follow_speed * delta
	if step.length() > max_step:
		step = step.normalized() * max_step
	_pupil_off += step

	var er: = clampf(eye_reveal, 0.0, 1.0)
	for i in 2:
		var eye: Node2D = _eyes[i]


		eye.visible = not _overlay_active and er > 0.015
		eye.scale = Vector2(1.0, maxf(_eye_open * blink_cut * er, 0.04))
		var grp: Node2D = _pupil_grps[i]
		grp.position = _pupil_off
	for i in _brows.size():
		var side: = -1.0 if i == 0 else 1.0
		var brow: Node2D = _brows[i]
		brow.position = _brow_base[i] + Vector2(_brow_off.x * side, _brow_off.y)
		brow.rotation = side * _brow_ang
	if playful:
		_playful_update(delta)
	_redraw_placeholders()


func _auto_max_x() -> float:
	return data.pupil_max.x if data.has_art()\
	else maxf(data.eye_size.x - data.iris_radius, 1.0)


func _auto_max_y() -> float:
	return data.pupil_max.y if data.has_art()\
	else maxf(data.eye_size.y - data.iris_radius, 1.0)




func _gaze_offset(max_off: Vector2) -> Vector2:
	var target = _resolve_gaze()
	if target == null:
		return Vector2.ZERO
	var dir: Vector2 = (target as Vector2) - _rig.global_position
	var sat: = dir.length() / (dir.length() + gaze_falloff)
	var n: = dir.normalized() * sat * 2.0
	return Vector2(n.x * max_off.x, n.y * max_off.y)



func _resolve_gaze():
	if gaze_centered:
		return null
	match look_mode:
		Look.FORWARD:
			return null
		Look.MOUSE:

			return get_global_mouse_position() if mouse_pos == Vector2.ZERO\
			else mouse_pos
		Look.CENTER:
			return get_viewport_rect().size * 0.5
		Look.LEFT:
			return _rig.global_position + Vector2(-1000.0, 0.0)
		Look.RIGHT:
			return _rig.global_position + Vector2(1000.0, 0.0)
		Look.POSITION:
			return _look_point
		Look.NODE:
			if is_instance_valid(_look_node):
				return _look_node.global_position
			return mouse_pos
		Look.CUSTOM:
			if _look_call.is_valid():
				var v = _look_call.call()
				if v is Vector2:
					return v
			return mouse_pos
	return mouse_pos











func _playful_update(delta: float) -> void :


	var gpos = _resolve_gaze()
	if gpos == null:
		return
	var look: = _rig.to_local(gpos as Vector2)
	var dist: = look.length()
	var r: = body_radius
	var ang: = look.angle()
	var d_ang: = wrapf(ang - _pl_prev_angle, - PI, PI)
	_pl_prev_angle = ang
	if spin_enabled and dist > r * 0.9 and dist < r * 6.0 and absf(d_ang) < 1.0:




		_orbit_charge = clampf(_orbit_charge + d_ang, - TAU, TAU)
		if absf(_orbit_charge) > 2.0:
			_spin_vel = clampf(_spin_vel + d_ang * 7.0, -34.0, 34.0)
	_pl_spinning = absf(_spin_vel) > 3.0
	if dist < r and not _pl_spinning:
		_pl_hover += delta



		var stage: = 0
		for i in hover_stages.size():
			if _pl_hover >= float(hover_stages[i][0]):
				stage = i + 1
		if stage != _pl_stage and not _is_locked():
			_pl_stage = stage
			if stage > 0:
				set_expression(_pick_expr(hover_stages[stage - 1][1]))
	elif _pl_hover > 0.0:
		if _pl_stage > 0:
			set_expression(&"neutral" if has_expression(&"neutral") else expression)
			play_reaction(_pick_expr([&"happy", &"laugh"]), 0.7)
		_pl_hover = 0.0
		_pl_stage = 0




func _redraw_placeholders() -> void :
	if _mouth != null and _mouth.texture == null and _mouth.placeholder_enabled:
		_mouth.queue_redraw()





class ShieldFX:
	extends Node2D
	var m: Mascot

	func _draw() -> void :
		var k: = m._shield
		if k <= 0.003:
			return
		var r: = m.body_radius * (1.02 + 0.38 * (1.0 - k))
		var tint: = m.data.tint
		draw_arc(Vector2.ZERO, r, - PI * 0.86, - PI * 0.14, 26, 
			Color(tint.r * 1.55, tint.g * 1.55, tint.b * 1.55, 0.9 * k), 3.0)
		draw_arc(Vector2.ZERO, r * 0.88, - PI * 0.76, - PI * 0.24, 20, 
			Color(tint.r * 1.3, tint.g * 1.3, tint.b * 1.3, 0.4 * k), 2.0)







class MPart:
	extends Sprite2D
	var kind: StringName
	var m: Mascot
	var side: = 1.0
	var placeholder_enabled: = true

	func _draw() -> void :
		if texture != null or not placeholder_enabled:
			return
		var d: = m.data
		var r: = d.head_radius
		var tint: = d.tint
		match kind:
			&"head":

				var hair: = Color(tint.r * 0.45, tint.g * 0.45, tint.b * 0.45)
				for s in [-1.0, 1.0]:
					draw_circle(Vector2(s * r * 1.02, r * 0.1), r * 0.42, hair)
					draw_circle(Vector2(s * r * 1.12, r * 0.52), r * 0.3, hair)
				draw_circle(Vector2.ZERO, r, Mascot.FACE_FILL)

				draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, 
					Color(tint.r * 1.25, tint.g * 1.25, tint.b * 1.25, 0.95), 2.5)

				draw_arc(Vector2(0, - r * 0.15), r * 0.92, PI + 0.5, TAU - 0.5, 24, 
					Color(tint.r * 0.55, tint.g * 0.55, tint.b * 0.55), 5.0)
			&"accessory":

				var s: = r * 0.14
				draw_colored_polygon(PackedVector2Array([
					Vector2(0, - s), Vector2(s * 0.3, - s * 0.3), Vector2(s, 0), 
					Vector2(s * 0.3, s * 0.3), Vector2(0, s), 
					Vector2( - s * 0.3, s * 0.3), Vector2( - s, 0), 
					Vector2( - s * 0.3, - s * 0.3)]), 
					Color(tint.r * 1.35, tint.g * 1.35, tint.b * 1.35))
			&"eye_white":
				draw_set_transform(Vector2.ZERO, 0.0, 
					Vector2(1.0, d.eye_size.y / d.eye_size.x))
				draw_circle(Vector2.ZERO, d.eye_size.x, Mascot.EYE_WHITE)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			&"iris":
				draw_circle(Vector2.ZERO, d.iris_radius, 
					Color(tint.r * 0.75, tint.g * 0.75, tint.b * 0.75))
			&"pupil":
				draw_circle(Vector2.ZERO, d.iris_radius * 0.52, Mascot.INK)
			&"highlight":
				draw_circle(Vector2.ZERO, d.iris_radius * 0.3, 
					Color(1, 1, 1, 0.95))
			&"brow":
				draw_line(Vector2(-4.5, 0.5), Vector2(4.5, -0.8), Mascot.INK, 2.2)
			&"mouth":
				var w: = r * 0.3
				if m._mouth_open > 0.12:

					draw_set_transform(Vector2.ZERO, 0.0, 
						Vector2(1.0, 0.5 + 0.8 * m._mouth_open))
					draw_circle(Vector2.ZERO, w * 0.55, Mascot.INK)
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				else:

					var pts: = PackedVector2Array()
					for i in 9:
						var x: = (float(i) / 8.0 - 0.5) * 2.0
						pts.append(Vector2(x * w, 
							m._mouth_curve * w * 0.5 * (1.0 - x * x)))
					draw_polyline(pts, Mascot.INK, 2.0)
