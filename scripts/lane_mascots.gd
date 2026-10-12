class_name LaneMascots
extends Node2D
















const MASCOT_SCENE: = preload("res://scenes/Mascot.tscn")
const LANE_NAMES: = {"cyan": 0, "violet": 1, "yellow": 2, "amber": 2}

var main
var tuning: Tuning



@export var y_offset: = 0.0

var _by_lane: Array = [null, null, null]
var _by_id: = {}
var _debug_expr_idx: = 0
var _debug_look_idx: = 0



var _glance_timer: = 8.0
var _glance_phase: = 0.0
var _glance_a: Mascot
var _glance_b: Mascot

var _watching: = [false, false, false]
var _miss_times: Array = [[], [], []]
var _afk_time: = 0.0
var _afk_stage: = 0
var _afk_last_aim: = Vector2.ZERO




func add_mascot(data: MascotData) -> Mascot:
	var old: Mascot = _by_lane[data.lane]
	if old != null:
		_by_id.erase(old.data.character_id)
		old.queue_free()
	var m: Mascot = MASCOT_SCENE.instantiate()
	m.data = data
	add_child(m)
	_by_lane[data.lane] = m
	_by_id[data.character_id] = m
	return m



func get_mascot(who) -> Mascot:
	if who is int:
		return _by_lane[who] if who >= 0 and who < 3 else null
	var key: = str(who).to_lower()
	if LANE_NAMES.has(key):
		return _by_lane[LANE_NAMES[key]]
	return _by_id.get(StringName(key))







func _react_target(lane: int) -> Mascot:
	if lane < 0:
		lane = 2
	return _by_lane[lane] if lane < 3 else null


func react_hit(lane: int) -> void :
	var m: = _react_target(lane)
	if m != null:
		m.react_hit()


func react_perfect(lane: int) -> void :
	var m: = _react_target(lane)
	if m != null:
		m.react_perfect()





func react_miss(lane: int, big_break: = false, red: = false) -> void :
	var m: = _react_target(lane)
	if m == null:
		return
	m.react_miss(red)
	var li: = 2 if lane < 0 else clampi(lane, 0, 2)
	var now: = Time.get_ticks_msec()
	var arr: Array = _miss_times[li]
	arr.append(now)
	while not arr.is_empty() and now - arr[0] > 7000:
		arr.pop_front()
	if arr.size() >= 3:
		m.play_reaction(&"angry", 1.2)
	elif big_break:
		m.react_shock()


func react_break(lane: int) -> void :
	var m: = _react_target(lane)
	if m != null:
		m.react_break()


func react_dodge(lane: int) -> void :
	var m: = _react_target(lane)
	if m != null:
		m.react_dodge()




func reset_all() -> void :
	for m in _by_id.values():
		if (m as Mascot).has_expression(&"neutral"):
			(m as Mascot).set_expression(&"neutral")
	_miss_times = [[], [], []]
	_afk_time = 0.0
	_afk_stage = 0




func react_combo_all(milestone: int) -> void :
	for m in _by_id.values():
		(m as Mascot).react_combo(milestone)


func react_map_complete_all() -> void :
	for m in _by_id.values():
		(m as Mascot).react_map_complete()


func react_game_over_all() -> void :
	for m in _by_id.values():
		(m as Mascot).react_game_over()




func set_mascot_expression(who, expr: StringName) -> void :
	var m: = get_mascot(who)
	if m != null:
		m.set_expression(expr)


func mascot_react(who, expr: StringName, duration: = 0.6) -> void :
	var m: = get_mascot(who)
	if m != null:
		m.play_reaction(expr, duration)




func mascot_look(who, target) -> void :
	var m: = get_mascot(who)
	if m == null:
		return
	if target is Vector2:
		m.set_look(Mascot.Look.POSITION, target)
		return
	if target is Node2D:
		m.set_look(Mascot.Look.NODE, target)
		return
	match str(target).to_lower():
		"mouse":
			m.set_look(Mascot.Look.MOUSE)
		"forward":
			m.set_look(Mascot.Look.FORWARD)
		"center":
			m.set_look(Mascot.Look.CENTER)
		"left":
			m.set_look(Mascot.Look.LEFT)
		"right":
			m.set_look(Mascot.Look.RIGHT)
		_:
			var other: = get_mascot(target)
			if other != null and other != m:
				m.set_look(Mascot.Look.NODE, other)




func _process(delta: float) -> void :
	if main == null or tuning == null:
		return


	var playing: bool = main.screen == main.Screen.PLAYING\
	and SettingsManager.vis_on("fx_mascots")
	if visible != playing:
		visible = playing
	if not playing:
		return
	_update_glances(delta)
	_update_moods(delta)
	var pulse: float = main.beat_pulse()
	var aim: Vector2 = main.auto_cursor if main.auto_mode else main.aim_position()







	var t: float = main.conductor.get_song_time()
	var watch: = [null, null, null]
	for n in main.live_notes:
		if not is_instance_valid(n) or n.judged or not (n.type == "dodge"):
			continue
		var dt: float = n.time - t
		if dt > -0.05 and dt < 0.5 and n.lane >= 0 and n.lane < 3:
			watch[n.lane] = n
	for i in 3:
		var m: Mascot = _by_lane[i]
		if m == null:
			continue


		var gone: float = main.fx_gone[i]
		m.position = Vector2(main.lane_x(i), tuning.hit_y + y_offset + 140.0 * gone * gone)
		m.visible = gone < 0.999
		m.beat_pulse = pulse
		m.mouse_pos = aim
		if watch[i] != null:
			m.set_look(Mascot.Look.NODE, watch[i])
			if not _watching[i]:
				_watching[i] = true
				m.react_incoming()
		elif _watching[i]:
			_watching[i] = false
			m.set_look(Mascot.Look.MOUSE)







func _update_moods(delta: float) -> void :
	var aim: Vector2 = main.auto_cursor if main.auto_mode else main.aim_position()
	if aim.distance_to(_afk_last_aim) > 6.0:
		_afk_last_aim = aim
		if _afk_stage > 0:
			for m in _by_id.values():
				(m as Mascot).play_reaction(&"surprised", 0.6)
		_afk_stage = 0
		_afk_time = 0.0
	else:
		_afk_time += delta
		_afk_stage = 2 if _afk_time > 22.0 else (1 if _afk_time > 10.0 else 0)
	var low_hp: bool = main.hp <= tuning.hp_max * 0.35
	for i in 3:
		var m: Mascot = _by_lane[i]
		if m == null:
			continue
		var prefs: Array = [&"neutral"]
		if _afk_stage == 2:
			prefs = [&"tired", &"blank"]
		elif _afk_stage == 1:
			prefs = [&"blank", &"tired"]
		elif low_hp:
			prefs = [&"sad", &"scared"]
		elif main.lane_clear > 0.9 and i != 2:
			prefs = [&"indi", &"blank"]
		elif main.auto_mode:
			prefs = [&"chipie", &"malice"]
		m.set_mood(prefs)




func _update_glances(delta: float) -> void :
	if _glance_phase > 0.0:
		_glance_phase -= delta
		if _glance_phase <= 0.0:
			if is_instance_valid(_glance_a):
				_glance_a.set_look(Mascot.Look.MOUSE)
			if is_instance_valid(_glance_b):
				_glance_b.set_look(Mascot.Look.MOUSE)
		return
	if main.on_fire:
		return
	_glance_timer -= delta
	if _glance_timer > 0.0:
		return
	_glance_timer = randf_range(7.0, 14.0)
	var present: Array = []
	for m in _by_lane:
		if m != null:
			present.append(m)
	if present.size() < 2:
		return
	present.shuffle()
	_glance_a = present[0]
	_glance_b = present[1]
	_glance_a.set_look(Mascot.Look.NODE, _glance_b)
	_glance_b.set_look(Mascot.Look.NODE, _glance_a)
	_glance_a.react_glance()
	_glance_b.react_glance()
	_glance_phase = 1.2






func _unhandled_key_input(event: InputEvent) -> void :
	if not OS.is_debug_build() or main == null\
	or main.screen != main.Screen.PLAYING:
		return
	var key: = event as InputEventKey
	if not key.pressed or key.echo:
		return
	if key.physical_keycode == KEY_F6:
		for m in _by_id.values():
			var ids: Array = (m as Mascot)._expressions.keys()
			var id: StringName = ids[_debug_expr_idx % ids.size()]
			(m as Mascot).set_expression(id)
			print("Mascotte %s : expression '%s'" % [(m as Mascot).data.character_id, id])
		_debug_expr_idx += 1
	elif key.physical_keycode == KEY_F7:
		var modes: Array = [Mascot.Look.MOUSE, Mascot.Look.FORWARD, 
			Mascot.Look.CENTER, Mascot.Look.LEFT, Mascot.Look.RIGHT]
		_debug_look_idx = (_debug_look_idx + 1) % modes.size()
		for m in _by_id.values():
			(m as Mascot).set_look(modes[_debug_look_idx])
		print("Mascottes : regard mode %d" % modes[_debug_look_idx])
