class_name MascotBody
extends Node2D



















signal entrance_started
signal landed(strength: float)
signal posed

var shown: = false
var _c: = {}
var _stand: = Vector2.ZERO


var _glide: Tween
var _meta: = {}
var _height: = 600.0
var _art: Node2D
var _hips: Node2D
var _neck: Node2D
var _mirror: Node2D
var _hips_over: Node2D = null
var _spring_grps: Array = []
var _spring_side: Array = []
var _arms: Array = []
var _eyes: Array = []
var _eyes_over: Array = []
var _pupils: Array = []
var _brows: Array = []
var _brow_base: Array = []
var _mouth: Node2D
var _deco_grp: Node2D
var _slot_neutral: = {}
var _sets: = {}
var _face: StringName = &""
var _face_tw: Tween
var _next_face: = 6.0
var _idle_faces_on: = false
var _face_queue: Array = []
var _grade: = "B"
var _shiver: = 0.0
var _wink_hold: = -1
var _giggle: = 0.0
var _chest: = 0.0
var _chest_target: = 0.0
var _lean: = 0.0
var _lean_target: = 0.0
var _mood_mouth: = 0.0


var _t: = 0.0
var _punch: = Vector2.ONE
var _punch_vel: = Vector2.ZERO
var _tilt: = 0.0
var _tilt_target: = 0.0
var _brow_off: = Vector2.ZERO
var _brow_off_target: = Vector2.ZERO
var _brow_ang: = 0.0
var _brow_ang_target: = 0.0
var _mouth_open: = 0.0
var _mouth_open_target: = 0.0
var _sag: = 0.0
var _sag_target: = 0.0
var _arm_rot: = [0.0, 0.0]
var _arm_target: = [0.0, 0.0]
var _spring_ang: Array = []
var _spring_vel: Array = []
var _spring_rest: = 0.0
var _airborne: = false
var _prev_y: = 0.0
var _vel_y: = 0.0
var _blink: = 0.0
var _next_blink: = 1.8
var _pupil: = Vector2.ZERO
var _look_point: = Vector2.INF
var _look_targets: Array = []
var _next_glance: = 2.5
var _tw: Tween
















func _cfg() -> Dictionary:
	return {}


func _ready() -> void :
	_c = _cfg()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_build()
	set_stand(_height)


func character() -> String:
	return String(_c.get("name", "mascot"))



func top_aspect() -> float:
	return float(_c.get("top_aspect", 0.4))


func instant_entrance() -> bool:
	return String(_c.get("entrance", "rise")) == "present"


func _tex(slug: String) -> Texture2D:
	var p: = String(_c.dir) + slug + ".png"
	if ResourceLoader.exists(p):
		var r = load(p)
		if r is Texture2D:
			return r

	var img: = Image.load_from_file(ProjectSettings.globalize_path(p))
	if img == null:
		push_warning("%s : calque introuvable %s" % [character(), p])
		return null
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)


func _group(parent: Node2D, pivot: Vector2, parent_pivot: Vector2) -> Node2D:
	var g: = Node2D.new()
	g.position = pivot - parent_pivot
	g.set_meta("pivot", pivot)
	parent.add_child(g)
	return g


func _sprite(parent: Node2D, slug: String) -> Sprite2D:
	var parts: Dictionary = _meta.get("parts", {})
	if not parts.has(slug):
		push_warning("%s : calque absent de body.json : %s" % [character(), slug])
		return null
	var p: Dictionary = parts[slug]
	var s: = Sprite2D.new()
	s.centered = false
	s.texture = _tex(slug)
	var inv: = 1.0 / float(_meta.get("scale", 0.25))
	s.scale = Vector2(inv, inv)
	var pivot: Vector2 = parent.get_meta("pivot", Vector2.ZERO)
	s.position = Vector2(float(p.x), float(p.y)) - pivot
	parent.add_child(s)
	var slots: Dictionary = _c.get("face_slots", {})
	for slot in slots:
		if slug in (slots[slot] as Array):
			if not _slot_neutral.has(slot):
				_slot_neutral[slot] = []
			(_slot_neutral[slot] as Array).append(s)
	return s


func _build() -> void :
	var f: = FileAccess.open(String(_c.dir) + "body.json", FileAccess.READ)
	if f == null:
		push_warning("%s : body.json introuvable (lancer tools/build_body.gd)" % character())
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		return
	_meta = parsed
	var p_hips: Vector2 = _c.p_hips
	var p_neck: Vector2 = _c.p_neck
	_art = Node2D.new()
	_art.set_meta("pivot", Vector2.ZERO)
	add_child(_art)

	var springs: Array = _c.get("springs", [])
	_mirror = Node2D.new()
	_mirror.set_meta("pivot", p_neck)
	_art.add_child(_mirror)
	for sp in springs:
		if String(sp.get("where", "behind")) != "behind":
			continue
		_add_spring(_mirror, sp, p_neck)


	var legs_front: bool = bool(_c.get("legs_front", false))
	var legs: Node2D = null
	if not legs_front:
		legs = _group(_art, p_hips, Vector2.ZERO)
		for slug in _c.l_legs:
			_sprite(legs, slug)
	_hips = _group(_art, p_hips, Vector2.ZERO)

	var behind_g: bool = bool(_c.get("arm_g_behind", true))
	var arm_g: Node2D = null
	var arm_d: Node2D = null
	if behind_g:
		arm_g = _group(_hips, _c.p_arm_g, p_hips)
		for slug in _c.l_arm_g:
			_sprite(arm_g, slug)
	else:
		arm_d = _group(_hips, _c.p_arm_d, p_hips)
		for slug in _c.l_arm_d:
			_sprite(arm_d, slug)
	for slug in _c.l_torso:
		_sprite(_hips, slug)
	if behind_g:
		arm_d = _group(_hips, _c.p_arm_d, p_hips)
		for slug in _c.l_arm_d:
			_sprite(arm_d, slug)
	else:
		arm_g = _group(_hips, _c.p_arm_g, p_hips)
		for slug in _c.l_arm_g:
			_sprite(arm_g, slug)
	_arms = [arm_g, arm_d]
	if legs_front:
		legs = _group(_art, p_hips, Vector2.ZERO)
		for slug in _c.l_legs:
			_sprite(legs, slug)


		var over: = _group(_art, p_hips, Vector2.ZERO)
		over.set_meta("follow_hips", true)
		for slug in _c.get("l_torso_over", []):
			_sprite(over, slug)
		_hips_over = over
	_neck = _group(_hips, p_neck, p_hips)
	for slug in _c.l_head_back:
		_sprite(_neck, slug)
	_mouth = _group(_neck, _c.mouth, p_neck)
	_sprite(_mouth, "mouth")
	var eyes: Array = _c.l_eyes
	for i in 2:
		var eye: = _group(_neck, _c.eye[i], p_neck)
		var pup: = _group(eye, _c.eye[i], _c.eye[i])
		_sprite(pup, eyes[i][0])
		for j in range(1, (eyes[i] as Array).size()):
			_sprite(eye, eyes[i][j])
		_eyes.append(eye)
		_pupils.append(pup)
	var brows_over: bool = bool(_c.get("brows_over", false))
	if not brows_over:
		_build_brows(p_neck)
	for slug in _c.l_head_front:
		_sprite(_neck, slug)




	for sp in springs:
		if String(sp.get("where", "behind")) == "front":
			_add_spring(_neck, sp, p_neck)
	for slug in _c.get("l_head_over", []):
		_sprite(_neck, slug)
	var eyes_over: Array = _c.get("l_eyes_over", [])
	for i in 2:
		var g: = _group(_neck, _c.eye[i], p_neck)
		if eyes_over.size() > i:
			for slug in eyes_over[i]:
				_sprite(g, slug)
		_eyes_over.append(g)
	if brows_over:
		_build_brows(p_neck)
	_deco_grp = _group(_neck, p_neck, p_neck)
	_build_face_sets()


func _build_brows(p_neck: Vector2) -> void :
	for i in 2:
		var b: = _group(_neck, _c.brow[i], p_neck)
		_sprite(b, _c.l_brows[i])
		_brows.append(b)
		_brow_base.append(b.position)


func _add_spring(parent: Node2D, sp: Dictionary, parent_pivot: Vector2) -> void :
	var g: = _group(parent, sp.pivot, parent_pivot)
	_sprite(g, String(sp.slug))
	_spring_grps.append(g)
	_spring_side.append(float(sp.get("side", 1.0)))
	_spring_ang.append(0.0)
	_spring_vel.append(0.0)






func _build_face_sets() -> void :


	var groups: = {"eye_g": _eyes[0], "eye_d": _eyes[1], "sourcil_g": _brows[0], 
		"sourcil_d": _brows[1], "mouth": _mouth, "deco": _deco_grp}
	var files: Dictionary = _c.get("face_files", {})
	var eyes_over: Array = _c.get("l_eyes_over", [])
	for id in _meta.get("sets", []):
		var set: = {}
		for key in files:
			var slug: = "%s_%s" % [id, key]
			if not (_meta.parts as Dictionary).has(slug):
				continue
			var slot: String = files[key]
			var g: Node2D = groups.get(slot, _neck)
			for i in 2:
				if eyes_over.size() > i and key in (eyes_over[i] as Array):
					g = _eyes_over[i]
			var s: = _sprite(g, slug)
			if s == null:
				continue
			s.visible = false
			if g == _neck and _slot_neutral.has(slot):

				var last: Sprite2D = (_slot_neutral[slot] as Array).back()
				if last.get_parent() == _neck:
					_neck.move_child(s, last.get_index() + 1)
			if not set.has(slot):
				set[slot] = []
			(set[slot] as Array).append(s)
		if not set.is_empty():
			_sets[String(id)] = set





func set_face(id: StringName, skip: Array = []) -> void :
	_face = id
	for slot in _slot_neutral:
		for s in _slot_neutral[slot]:
			(s as Sprite2D).visible = true
	for sid in _sets:
		for slot in _sets[sid]:
			for s in _sets[sid][slot]:
				(s as Sprite2D).visible = false
	if id == &"" or not _sets.has(String(id)):
		return
	var hide: Dictionary = _c.get("face_hide", {})
	for slot in hide.get(String(id), []):
		for s in _slot_neutral.get(slot, []):
			(s as Sprite2D).visible = false
	var set: Dictionary = _sets[String(id)]
	for slot in set:
		if slot in skip:
			continue
		for s in _slot_neutral.get(slot, []):
			(s as Sprite2D).visible = false
		for s in set[slot]:
			(s as Sprite2D).visible = true


func has_face(id: StringName) -> bool:
	return _sets.has(String(id))





func play_face(id: StringName, dur: = 2.0, skip: Array = []) -> void :
	if not has_face(id):
		return
	if _face_tw != null and _face_tw.is_valid():
		_face_tw.kill()
	var styles: Dictionary = _c.get("face_style", {})
	var style: String = styles.get(String(id), "laugh")
	var amp: = float(_c.get("amp", 1.0))
	var saved_brow: = _brow_off_target
	var saved_brow_ang: = _brow_ang_target
	var saved_sag: = _sag_target
	var saved_arms: = _arm_target.duplicate()
	_face_tw = create_tween()
	_face_tw.tween_callback( func() -> void : _blink = 0.16)
	_face_tw.tween_interval(0.08)
	match style:
		"nervous":



			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_tilt_target = 0.12
				_punch = Vector2(1.02, 0.97)
				_brow_off_target = Vector2(0.0, -6.0)
				_brow_ang_target = 0.18
				_mouth_open_target = 0.1
				_arm_target = [0.1, -0.1]
				_sag_target = 0.45
				_giggle = 1.0
				_shiver = 0.35
				_spring_impulse(-1.2))
			_face_tw.tween_interval(maxf(dur - 0.08, 0.2))
		"panic":
			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_tilt_target = -0.05
				_punch = Vector2(0.97, 1.04)
				_brow_off_target = Vector2(0.0, -18.0)
				_mouth_open_target = 0.2
				_arm_target = [-0.16, 0.16]
				_shiver = 1.0
				_spring_impulse(-2.2))
			_face_tw.tween_interval(maxf(dur - 0.08, 0.2))
		"mock":



			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_lean_target = 0.05
				_tilt_target = 0.14
				_brow_off_target = Vector2(0.0, 6.0)
				_brow_ang_target = -0.12
				_mouth_open_target = 0.3
				_giggle = 1.0
				_spring_impulse(-1.4))
			_face_tw.tween_interval(maxf(dur - 0.5, 0.2))
			_face_tw.tween_callback( func() -> void :
				_giggle = 0.0
				_lean_target = -0.03
				_tilt_target = -0.08)
			_face_tw.tween_interval(0.42)
		"smug":


			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_lean_target = -0.035
				_tilt_target = -0.09
				_chest_target = 0.5
				_brow_off_target = Vector2(0.0, -6.0)
				_brow_ang_target = -0.16
				_mouth_open_target = 0.0)
			_face_tw.tween_interval(maxf(dur - 0.08, 0.2))
		"startled":



			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_lean_target = -0.06
				_tilt_target = -0.12
				_punch = Vector2(0.98, 1.03)
				_brow_off_target = Vector2(0.0, -26.0)
				_mouth_open_target = 0.6
				_shiver = 0.6)
			_face_tw.tween_interval(0.55)
			_face_tw.tween_callback( func() -> void :
				_shiver = 0.0
				_lean_target = 0.04
				_tilt_target = 0.05)
			_face_tw.tween_interval(maxf(dur - 0.63, 0.2))
		"disgust":


			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_lean_target = -0.05
				_tilt_target = -0.11
				_punch = Vector2(1.02, 0.98)
				_brow_off_target = Vector2(0.0, -10.0)
				_mouth_open_target = 0.0
				_arm_target = [0.06, -0.06]
				_shiver = 0.5
				_spring_impulse(-1.0))
			_face_tw.tween_interval(0.5)
			_face_tw.tween_callback( func() -> void : _shiver = 0.12)
			_face_tw.tween_interval(maxf(dur - 0.58, 0.2))
		"sulk":



			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_tilt_target = -0.06
				_brow_off_target = Vector2(0.0, 6.0)
				_mouth_open_target = 0.0
				_arm_target = [0.12, -0.12]
				_spring_impulse(0.8))
			_face_tw.tween_interval(0.28)
			_face_tw.tween_callback( func() -> void :
				_tilt_target = 0.13
				_sag_target = 0.5
				_lean_target = 0.02)
			_face_tw.tween_interval(maxf(dur - 0.36, 0.2))
		"proud":


			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_chest_target = 1.0
				_lean_target = -0.03
				_tilt_target = -0.1
				_punch = Vector2(0.98, 1.03)
				_brow_off_target = Vector2(0.0, -4.0)
				_mouth_open_target = 0.05
				_arm_target = [-0.06, 0.06]
				_spring_impulse(-1.4))
			_face_tw.tween_interval(maxf(dur - 0.08, 0.2))
		_:

			_face_tw.tween_callback( func() -> void :
				set_face(id, skip)
				_tilt_target = 0.1
				_punch = Vector2(1.02, 0.98)
				_mouth_open_target = 0.15
				_spring_impulse(-1.6))
			_face_tw.tween_interval(0.35)
			_face_tw.tween_callback( func() -> void : _tilt_target = 0.05)
			_face_tw.tween_interval(maxf(dur - 0.43, 0.2))
	_face_tw.tween_callback( func() -> void : _blink = 0.16)
	_face_tw.tween_interval(0.08)
	_face_tw.tween_callback( func() -> void :
		set_face(&"")
		_wink_hold = -1
		_tilt_target = 0.0
		_shiver = 0.0
		_giggle = 0.0
		_chest_target = 0.0
		_lean_target = 0.0
		_brow_ang_target = saved_brow_ang
		_sag_target = saved_sag
		_brow_off_target = saved_brow
		_arm_target = saved_arms
		_mouth_open_target = _mood_mouth)





func _spring_impulse(v: float) -> void :
	v *= float(_c.get("spring_kick", 1.0))
	for i in _spring_grps.size():
		_spring_vel[i] = float(_spring_vel[i]) + ( - v if float(_spring_side[i]) < 0.0 else v)




func set_stand(height_px: float) -> void :
	_height = maxf(height_px, 1.0)
	if _art == null:
		return
	var s: = _height / float(_c.canvas_h)
	_art.scale = Vector2(s, s)
	_art.position = - (_c.feet as Vector2) * s


func height() -> float:
	return _height





func set_stand_point(p: Vector2) -> void :
	_stand = p
	if not shown or not visible:
		position = p
		return
	if is_entering():
		return
	if position.distance_to(p) < 0.5:
		return
	if _glide != null and _glide.is_valid():
		_glide.kill()
	_glide = create_tween()
	_glide.tween_property(self, "position", p, 0.35)\
	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)



func set_look_targets(points: Array) -> void :
	_look_targets = points


func stop_anim() -> void :
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = null
	if _glide != null and _glide.is_valid():
		_glide.kill()
	_glide = null
	if _face_tw != null and _face_tw.is_valid():
		_face_tw.kill()
	_face_tw = null
	set_face(&"")
	_airborne = false









func play_entrance(grade: String, fall_dur: = 0.6) -> void :
	_grade = grade
	if shown:
		push_warning("%s : play_entrance alors qu'elle est déjà en scène — ignoré" % character())
		return
	stop_anim()
	if _art == null:
		return
	shown = true
	visible = true
	_reset_pose()
	position = _stand
	entrance_started.emit()
	var amp: = float(_c.get("amp", 1.0))
	_tw = create_tween()
	if instant_entrance():

		modulate.a = 0.0
		_prev_y = position.y
		rotation = 0.0
		_tw.tween_property(self, "modulate:a", 1.0, 0.25)
		_tw.tween_callback( func() -> void :
			_look_first()
			landed.emit(1.0))
		_tw.tween_interval(0.45)
	else:


		var vp_h: = get_viewport().get_visible_rect().size.y if is_inside_tree() else 1080.0
		var below: = (vp_h - global_position.y) + _height * float(_c.head_top_frac) + 8.0
		var start: = _stand + Vector2(0.0, below)
		position = start
		_prev_y = position.y
		rotation = 0.0
		_airborne = true
		_arm_target = [0.18, -0.18]
		_tilt_target = -0.06
		for i in _spring_grps.size():
			_spring_ang[i] = 0.55 * float(_spring_side[i])
		_brow_off_target = Vector2(0.0, -10.0)
		_mouth_open_target = 0.4
		_tw.tween_method( func(k: float) -> void :
			position = start.lerp(_stand, k), 0.0, 1.0, fall_dur)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		_tw.tween_callback(_on_land)
		_tw.tween_interval(0.2)


	_tw.tween_callback( func() -> void :
		_tilt_target = -0.1 * amp
		_brow_off_target = Vector2(0.0, -20.0 * amp)
		_mouth_open_target = 0.7 * amp
		_look_first())
	_tw.tween_interval(0.75)
	_tw.tween_callback( func() -> void :
		_tilt_target = 0.07 * amp
		_brow_off_target = Vector2(0.0, -8.0 * amp))
	_tw.tween_interval(0.3)
	_tw.tween_callback( func() -> void :
		_tilt_target = 0.0
		_react(grade))


func _on_land() -> void :
	_airborne = false
	_punch = Vector2(0.96, 1.05)
	_punch_vel = Vector2.ZERO
	_arm_target = [0.0, 0.0]
	_spring_impulse(-4.5)
	_tilt = -0.06
	_tilt_target = 0.0
	_brow_off_target = Vector2(0.0, -12.0)
	_mouth_open_target = 0.5
	_look_first()
	landed.emit(1.0)



func _look_first() -> void :
	if _look_targets.size() > 0:
		_look_point = _look_targets[0]
		_next_glance = 1.3
	else:
		_look_point = Vector2.INF
		_next_glance = 2.5


func _react(grade: String) -> void :
	var amp: = float(_c.get("amp", 1.0))
	_tw = create_tween()
	match grade:
		"SS", "S":



			_tw.tween_callback( func() -> void :
				_tilt_target = -0.14 * amp
				_lean_target = -0.03 * amp
				_brow_off_target = Vector2(0.0, -24.0 * amp)
				_mouth_open_target = 0.9 * amp
				_arm_target = [-0.14 * amp, 0.14 * amp]
				_spring_impulse(-2.0))
			_tw.tween_interval(0.26)
			_tw.tween_callback( func() -> void :
				_arm_target = [-0.06 * amp, 0.06 * amp]
				_tilt_target = -0.06 * amp)
			_tw.tween_interval(0.2)
			_tw.tween_callback( func() -> void :
				_arm_target = [-0.14 * amp, 0.14 * amp]
				_tilt_target = -0.14 * amp
				_spring_impulse(-2.0))
			_tw.tween_interval(0.3)
			_tw.tween_callback( func() -> void :
				_arm_target = [0.0, 0.0]
				_tilt_target = 0.0
				_lean_target = 0.0
				_mood(Vector2(0.0, -14.0 * amp), -0.06 * amp, 0.55 * amp, 0.0))
		"A", "B":

			for a in [0.09, -0.08, 0.05]:
				_tw.tween_callback( func() -> void : _tilt_target = float(a) * amp)
				_tw.tween_interval(0.22)
			_tw.tween_callback( func() -> void :
				_tilt_target = 0.0
				_mood(Vector2(0.0, -9.0 * amp), -0.04 * amp, 0.35 * amp, 0.0))
		"C":

			_tw.tween_callback( func() -> void : _arm_target = [-0.18 * amp, 0.18 * amp])
			_tw.tween_interval(0.28)
			_tw.tween_callback( func() -> void :
				_arm_target = [0.0, 0.0]
				_mood(Vector2(0.0, -2.0 * amp), 0.0, 0.15 * amp, 0.0))
		_:

			_tw.tween_callback( func() -> void :
				_mood(Vector2(0.0, 6.0 * amp), 0.22 * amp, 0.0, 1.0)
				_tilt_target = 0.13 * amp
				_arm_target = [0.08 * amp, -0.08 * amp])





func _mood(brow_off: Vector2, brow_ang: float, mouth: float, sag: float) -> void :
	_brow_off_target = brow_off
	_brow_ang_target = brow_ang
	_mouth_open_target = mouth
	_mood_mouth = mouth
	_sag_target = sag
	_spring_rest = 0.3 * sag
	_idle_faces_on = true
	_face_queue = []
	var gfs: Dictionary = _c.get("grade_face", {})
	var gf: Array = gfs.get(_grade, gfs.get("B", []))
	if gf.size() >= 2 and has_face(gf[0]):
		_face_queue.append([gf[0], float(gf[1]), []])
	_next_face = 1.0




func wink_at_player(dur: = 1.6) -> void :
	_look_point = Vector2.INF
	_next_glance = dur + 1.2
	var w: Array = _c.get("wink", [])
	if w.size() >= 1 and has_face(w[0]):
		play_face(w[0], dur, w[1] if w.size() > 1 else [])



func apply_final(grade: String) -> void :
	_grade = grade
	stop_anim()
	if _art == null:
		return
	shown = true
	visible = true
	modulate.a = 1.0
	_reset_pose()
	rotation = 0.0
	position = _stand
	posed.emit()
	var amp: = float(_c.get("amp", 1.0))
	match grade:
		"SS", "S":
			_mood(Vector2(0.0, -14.0 * amp), -0.06 * amp, 0.55 * amp, 0.0)
		"A", "B":
			_mood(Vector2(0.0, -9.0 * amp), -0.04 * amp, 0.35 * amp, 0.0)
		"C":
			_mood(Vector2(0.0, -2.0 * amp), 0.0, 0.15 * amp, 0.0)
		_:
			_mood(Vector2(0.0, 6.0 * amp), 0.22 * amp, 0.0, 1.0)
			_tilt_target = 0.13 * amp
			_arm_target = [0.08 * amp, -0.08 * amp]
	_tilt = _tilt_target
	_brow_off = _brow_off_target
	_brow_ang = _brow_ang_target
	_mouth_open = _mouth_open_target
	_sag = _sag_target
	_arm_rot = _arm_target.duplicate()
	_look_first()


func _reset_pose() -> void :
	if _face_tw != null and _face_tw.is_valid():
		_face_tw.kill()
	set_face(&"")
	_idle_faces_on = false
	_face_queue.clear()
	_shiver = 0.0
	_wink_hold = -1
	_giggle = 0.0
	_chest = 0.0
	_chest_target = 0.0
	_lean = 0.0
	_lean_target = 0.0
	_mood_mouth = 0.0
	_vel_y = 0.0
	_prev_y = position.y
	_punch = Vector2.ONE
	_punch_vel = Vector2.ZERO
	_tilt = 0.0
	_tilt_target = 0.0
	_brow_off = Vector2.ZERO
	_brow_off_target = Vector2.ZERO
	_brow_ang = 0.0
	_brow_ang_target = 0.0
	_mouth_open = 0.0
	_mouth_open_target = 0.0
	_sag = 0.0
	_sag_target = 0.0
	_spring_rest = 0.0
	_arm_rot = [0.0, 0.0]
	_arm_target = [0.0, 0.0]
	for i in _spring_grps.size():
		_spring_ang[i] = 0.0
		_spring_vel[i] = 0.0
	_blink = 0.0
	_next_blink = randf_range(1.5, 3.0)
	_pupil = Vector2.ZERO
	_look_point = Vector2.INF
	modulate.a = 1.0




func _process(delta: float) -> void :
	if _art == null or not is_visible_in_tree():
		return
	delta = minf(delta, 0.05)
	_t += delta
	var k: = 1.0 - exp(-9.0 * delta)
	var p_neck: Vector2 = _c.p_neck
	var p_hips: Vector2 = _c.p_hips




	var acc: = (Vector2.ONE - _punch) * 230.0 - _punch_vel * 31.0
	_punch_vel += acc * delta
	_punch += _punch_vel * delta
	scale = _punch

	_sag = lerpf(_sag, _sag_target, 1.0 - exp(-3.0 * delta))
	_chest = lerpf(_chest, _chest_target, 1.0 - exp(-4.0 * delta))
	_lean = lerpf(_lean, _lean_target, 1.0 - exp(-5.0 * delta))
	var breath: = (0.012 + 0.01 * _chest) * sin(_t * (2.4 - 0.8 * _chest))
	_giggle = lerpf(_giggle, 0.0, 1.0 - exp(-2.0 * delta)) if _giggle < 0.999 else _giggle
	var gig: = _giggle * 0.014 * maxf(sin(_t * 19.0), 0.0)
	_hips.scale = Vector2(1.0 - breath * 0.5 - gig * 0.5 - 0.015 * _chest, 
		1.0 + breath + gig + 0.03 * _chest) * (1.0 - 0.035 * _sag)
	_hips.rotation = 0.04 * _sag + _lean
	if _hips_over != null:
		_hips_over.transform = _hips.transform

	_tilt = lerpf(_tilt, _tilt_target, k)
	_shiver = lerpf(_shiver, 0.0, 1.0 - exp(-2.0 * delta)) if _shiver < 0.999 else _shiver
	var sh: = _shiver * 0.022 * sin(_t * 41.0)
	_neck.rotation = _tilt + 0.012 * sin(_t * 1.7 + 0.8) + sh
	_neck.position = p_neck - p_hips + Vector2(_shiver * 3.0 * sin(_t * 47.0), 
		6.0 * sin(_t * 2.4 + 1.2) + 40.0 * _sag - 18.0 * _chest)
	if _shiver > 0.05 and _spring_grps.size() > 0 and randf() < 6.0 * delta:
		var j: = randi() % _spring_grps.size()
		_spring_vel[j] = float(_spring_vel[j]) + randf_range(-1.2, 1.2) * _shiver * float(_c.get("spring_kick", 1.0))


	var arm_max: = float(_c.get("arm_max", 0.16))
	for i in 2:
		var tgt: = clampf(float(_arm_target[i]), - arm_max, arm_max)
		_arm_rot[i] = lerpf(_arm_rot[i], tgt, 1.0 - exp(-7.0 * delta))
		if _arms[i] != null:
			(_arms[i] as Node2D).rotation = _arm_rot[i] + 0.015 * sin(_t * 2.4 + i * 2.0)

	var v: = (position.y - _prev_y) / maxf(delta, 0.001) / maxf(_height, 1.0)
	_prev_y = position.y
	_vel_y = lerpf(_vel_y, v, 1.0 - exp(-14.0 * delta))


	var sway: = float(_c.get("spring_sway", 0.03))
	var damp: = float(_c.get("spring_damp", 5.5))
	var drag: = float(_c.get("spring_drag", 0.22))
	for i in _spring_grps.size():
		var side: = float(_spring_side[i])
		var rest: = side * _spring_rest * float(_c.get("spring_kick", 1.0)) + sway * sin(_t * 1.6 + i * 1.3)
		rest += side * clampf( - _vel_y * drag, -0.65, 0.65)
		var a: float = (rest - float(_spring_ang[i])) * 60.0 - float(_spring_vel[i]) * damp
		_spring_vel[i] = float(_spring_vel[i]) + a * delta
		_spring_ang[i] = float(_spring_ang[i]) + float(_spring_vel[i]) * delta
		(_spring_grps[i] as Node2D).rotation = _spring_ang[i]

	_mirror.transform = _hips.transform * _neck.transform


	if _idle_faces_on and not is_entering():
		_next_face -= delta
		if _next_face <= 0.0:
			if not _face_queue.is_empty():
				var f: Array = _face_queue.pop_front()
				play_face(f[0], float(f[1]), f[2])
				_next_face = float(f[1]) + 2.5
			else:
				_next_face = randf_range(6.0, 12.0)
				if randf() < 0.55:
					wink_at_player(randf_range(1.4, 1.9))

	_next_blink -= delta
	if _next_blink <= 0.0:
		_blink = 0.16
		_next_blink = randf_range(2.0, 5.0)
	var cut: = 1.0
	if _blink > 0.0:
		_blink -= delta
		cut = clampf(absf(_blink - 0.08) / 0.08, 0.0, 1.0)

	_next_glance -= delta
	if _next_glance <= 0.0:
		_next_glance = randf_range(2.5, 5.5)
		if _look_targets.size() > 0 and randf() < 0.6:
			_look_point = _look_targets[randi() % _look_targets.size()]
		else:
			_look_point = Vector2.INF
	var wanted: = Vector2.ZERO
	var pmax: Vector2 = _c.pupil_max
	if _look_point.is_finite():
		var eye_g: Vector2 = (_eyes[0] as Node2D).global_position
		var d: = (_look_point - eye_g) / maxf(_height, 1.0)
		if d.length() > 0.25:
			d = d.normalized() * 0.25
		wanted = Vector2(d.x * pmax.x, d.y * pmax.y) * 4.0
		wanted = wanted.clamp( - pmax, pmax)
	_pupil += (wanted - _pupil) * (1.0 - exp(-8.0 * delta))
	for i in 2:
		var c: = 0.06 if i == _wink_hold else maxf(cut, 0.06)
		(_eyes[i] as Node2D).scale = Vector2(1.0, c)
		(_eyes_over[i] as Node2D).scale = (_eyes[i] as Node2D).scale
		(_pupils[i] as Node2D).position = _pupil

	_brow_off += (_brow_off_target - _brow_off) * k
	_brow_ang = lerpf(_brow_ang, _brow_ang_target, k)
	for i in 2:
		var side: = -1.0 if i == 0 else 1.0
		var b: Node2D = _brows[i]
		b.position = _brow_base[i] + _brow_off
		b.rotation = side * _brow_ang
	_mouth_open = lerpf(_mouth_open, _mouth_open_target, k)
	_mouth.scale = Vector2(1.0 + 0.25 * _mouth_open, 1.0 + 0.7 * _mouth_open)



func is_entering() -> bool:
	return _tw != null and _tw.is_valid() and _tw.is_running()
