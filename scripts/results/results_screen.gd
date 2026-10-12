class_name ResultsScreen
extends Control



















signal retry_requested
signal continue_requested
signal leaderboard_requested
signal animation_completed
signal animation_skipped

var data: RunResult = null
var header: MapResultHeader
var account: ResultsAccountCard
var core: GradeCore
var score_block: ScoreBlock
var cards: Array = []
var ranking: MapRankingPanel
var buttons: ResultActionButtons
var play_sound: Callable
var _mode_label: Label
var _status_label: Label
var _director: ResultsAnimationDirector
var _bg: ColorRect
var _root: MarginContainer
var _body: HBoxContainer
var _core_wrap: Control
var _main_row: HBoxContainer
var _selected: = 1
var _armed: = true
var _axis_armed: = true
var _slots: = {}






var _mascot_layer: Control
var _mascot: MascotBody
var _mascots: Array = []
var _mascot_choice: = ""
var _mascot_halo: Sprite2D
var _mascot_ok: = false
var _mascot_vp: = Vector2.ZERO
const MASCOT_MIN_H: = 300.0

const MASCOT_VISIBLE_FRAC: = 0.62


const HALO_ALPHA: = 0.3




func _meh_enabled() -> bool:
	var main = get_tree().current_scene if is_inside_tree() else null
	if main != null and "tuning" in main and main.tuning != null\
	and main.tuning.has_method("meh_enabled"):
		return bool(main.tuning.meh_enabled())
	return false
var _card_slots: Array = []



func _slot(parent: Control, child: Control) -> ResultsSlot:
	var s: = ResultsSlot.new()
	parent.add_child(s)
	s.add_child(child)
	return s


func _init() -> void :
	theme = ResultsTheme.theme()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP


	_bg = ColorRect.new()
	_bg.color = Color(ResultsTheme.BG, 0.66)
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)
	_root = MarginContainer.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	for m in ["margin_left", "margin_right"]:
		_root.add_theme_constant_override(m, 24)
	_root.add_theme_constant_override("margin_top", 16)
	_root.add_theme_constant_override("margin_bottom", 18)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(v)


	var top: = HBoxContainer.new()
	top.add_theme_constant_override("separation", 16)
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(top)
	header = MapResultHeader.new()
	_slots.header = _slot(top, header)
	(_slots.header as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	(_slots.header as Control).size_flags_stretch_ratio = 1.0
	var mid: = VBoxContainer.new()
	mid.alignment = BoxContainer.ALIGNMENT_BEGIN
	mid.add_theme_constant_override("separation", 6)
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.size_flags_stretch_ratio = 0.8
	mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(mid)
	_mode_label = Label.new()
	_mode_label.theme_type_variation = &"RMode"
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_mode_label.add_theme_stylebox_override("normal", 
		ResultsTheme.box(ResultsTheme.PANEL_2, ResultsTheme.LINE, 10, 1, Vector2(16, 5)))
	mid.add_child(_mode_label)
	_status_label = Label.new()
	_status_label.theme_type_variation = &"RStatus"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mid.add_child(_status_label)
	var right: = HBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_END
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 1.0
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(right)
	account = ResultsAccountCard.new()
	_slots.account = _slot(right, account)
	(_slots.account as Control).size_flags_vertical = Control.SIZE_SHRINK_BEGIN


	_body = HBoxContainer.new()
	_body.add_theme_constant_override("separation", 24)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_body)
	var left: = VBoxContainer.new()
	left.add_theme_constant_override("separation", 18)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.add_child(left)
	var main_row: = HBoxContainer.new()
	_main_row = main_row
	main_row.add_theme_constant_override("separation", 34)
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(main_row)
	_core_wrap = CenterContainer.new()
	_core_wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_row.add_child(_core_wrap)
	core = GradeCore.new()
	_slots.core = _slot(_core_wrap, core)
	score_block = ScoreBlock.new()
	_slots.score = _slot(main_row, score_block)
	(_slots.score as Control).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	(_slots.score as Control).size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var cards_row: = HBoxContainer.new()
	cards_row.add_theme_constant_override("separation", 14)
	cards_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left.add_child(cards_row)


	var specs: Array = [["PERFECT", ResultsTheme.CYAN], ["GOOD", ResultsTheme.YELLOW]]
	if _meh_enabled():
		specs.append(["MEH", Color(1.0, 0.84, 0.4)])
	specs.append(["MISS", ResultsTheme.CORAL])
	specs.append(["MAX COMBO", ResultsTheme.VIOLET_LIGHT])
	for spec in specs:
		var c: = JudgmentCard.new()
		c.setup(spec[0], spec[1])
		var s: = _slot(cards_row, c)
		s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cards.append(c)
		_card_slots.append(s)
	ranking = MapRankingPanel.new()
	ranking.leaderboard_requested.connect(_on_leaderboard)
	ranking.full_button().mouse_entered.connect( func() -> void : _select(2))
	_slots.ranking = _slot(_body, ranking)


	buttons = ResultActionButtons.new()
	buttons.retry_pressed.connect( func() -> void : _activate(0))
	buttons.continue_pressed.connect( func() -> void : _activate(1))
	buttons.retry_button.mouse_entered.connect( func() -> void : _select(0))
	buttons.continue_button.mouse_entered.connect( func() -> void : _select(1))
	_slots.buttons = _slot(v, buttons)
	gui_input.connect(_on_gui_input)


	_mascot_layer = Control.new()
	_mascot_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_mascot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_mascot_layer)
	move_child(_mascot_layer, 1)
	_mascot_halo = Sprite2D.new()
	_mascot_halo.visible = false
	_mascot_layer.add_child(_mascot_halo)

	for m in [LariBody.new(), KohaBody.new(), AmeBody.new()]:
		m.visible = false
		_mascot_layer.add_child(m)
		_mascots.append(m)
		m.visibility_changed.connect( func() -> void :
			if m == _mascot:
				_mascot_halo.visible = m.visible)
		m.entrance_started.connect( func() -> void :
			_mascot_halo.modulate = Color(ResultsTheme.CYAN, 0.0)
			var t: = _mascot_halo.create_tween()
			t.tween_property(_mascot_halo, "modulate", Color(ResultsTheme.CYAN, HALO_ALPHA), 0.9))
		m.posed.connect( func() -> void :
			_mascot_halo.modulate = Color(ResultsTheme.CYAN, HALO_ALPHA))
	_mascot = _mascots[0]

	_main_row.sort_children.connect(_place_mascot.call_deferred)
	_body.sort_children.connect(_place_mascot.call_deferred)

	_director = ResultsAnimationDirector.new(self)
	_director.completed.connect( func() -> void :
		buttons.set_interactive(true)
		animation_completed.emit())
	_director.skipped.connect( func() -> void :
		buttons.set_interactive(true)
		animation_skipped.emit())
	resized.connect(_on_resized)
	visibility_changed.connect( func() -> void :
		if not is_visible_in_tree():
			_director.stop()
			for m in _mascots:
				m.stop_anim())




func set_mascot_choice(name: String) -> void :
	_mascot_choice = name


func set_glow_texture(t: Texture2D) -> void :
	core.glow_tex = t
	buttons.set_glow_texture(t)
	_mascot_halo.texture = t




func _on_resized() -> void :
	var narrow: = size.x < 1240.0
	core.custom_minimum_size = Vector2(250, 250) if narrow else Vector2(300, 300)
	ranking.set_compact(narrow)
	_body.add_theme_constant_override("separation", 16 if narrow else 24)
	_place_mascot.call_deferred()






func _place_mascot() -> void :
	if _mascot == null or not is_inside_tree():
		return



	var sb: = score_block.get_global_rect()
	var rk: = (_slots.ranking as Control).get_global_rect()
	var row: = _main_row.get_global_rect()
	var core_r: = _core_wrap.get_global_rect()


	var h: = row.size.y / MASCOT_VISIBLE_FRAC
	h = minf(h, (rk.position.x - core_r.end.x) / 0.75)




	var vp: = get_viewport_rect().size
	if _mascot.shown and vp == _mascot_vp:
		return
	_mascot_vp = vp
	_mascot_ok = h >= MASCOT_MIN_H
	_mascot.visible = _mascot_ok and _mascot.shown


	var flags: = Control.SIZE_SHRINK_BEGIN if _mascot_ok else Control.SIZE_EXPAND_FILL
	if (_slots.score as Control).size_flags_horizontal != flags:
		(_slots.score as Control).size_flags_horizontal = flags
	if not _mascot_ok:
		return
	var inv: = _mascot_layer.get_global_transform().affine_inverse()
	_mascot.set_stand(h)

	var cx: = rk.position.x - 12.0 - 0.5 * h * _mascot.top_aspect()
	var feet_y: = row.position.y + h * float(_mascot._cfg().head_top_frac) + 6.0
	_mascot.set_stand_point(inv * Vector2(cx, feet_y))

	_mascot_halo.position = inv * Vector2(cx, row.position.y + h * 0.42)
	if _mascot_halo.texture != null:
		var ts: = _mascot_halo.texture.get_size()
		_mascot_halo.scale = Vector2(h * 0.95 / ts.x, h * 1.05 / ts.y)
	_mascot.set_look_targets([core.get_global_rect().get_center(), 
		sb.get_center()])


	if _mascot.instant_entrance() and not _mascot.shown and _director.playing and data != null:
		_mascot.play_entrance(data.grade)





func show_results(r: RunResult, animate: = true) -> void :
	data = r
	_armed = true
	visible = true
	header.fill(r)
	account.fill(r)
	_mode_label.text = r.mode_name
	_status_label.text = ("✦  %s  ✦" % r.status_text) if r.cleared else r.status_text
	_status_label.add_theme_color_override("font_color", 
		ResultsTheme.CYAN if r.cleared else ResultsTheme.CORAL)
	core.set_grade(r.grade, true)
	score_block.fill(r)
	var vals: Array = ["%d" % r.perfect, "%d" % r.good]
	if _meh_enabled():
		vals.append("%d" % r.meh)
	vals.append("%d" % r.miss)
	vals.append("%d×" % r.max_combo)
	for i in mini(vals.size(), cards.size()):
		(cards[i] as JudgmentCard).set_value(String(vals[i]))
	ranking.fill(r)
	_select(1)
	buttons.set_interactive(false)


	var pick: MascotBody = _mascots[randi() % _mascots.size()]
	for m in _mascots:
		if _mascot_choice != "" and (m as MascotBody).character().to_lower() == _mascot_choice.to_lower():
			pick = m
	_mascot = pick
	for m in _mascots:
		m.shown = false
		m.visible = false
	_place_mascot.call_deferred()
	if animate:
		_director.play(_parts(), r, play_sound)
	else:
		_director.skip(_parts(), r)
		buttons.set_interactive(true)



func apply_ranking(r: RunResult) -> void :
	if r != data:
		return
	ranking.fill(r)
	if r.ranking_status == RunResult.RankingStatus.READY and is_visible_in_tree():
		ranking.animate_in()


func apply_account(r: RunResult) -> void :
	if r != data:
		return
	account.fill(r)


func _parts() -> Dictionary:
	return {"slots": _slots, "cards": _card_slots, "core": core, "score": score_block, 
		"mascot": _mascot}




func _on_gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed and _director.playing:
		skip()
		accept_event()


func is_animating() -> bool:
	return _director.playing


func skip() -> void :
	if data != null and _director.playing:
		_director.skip(_parts(), data)




func _select(i: int) -> void :
	_selected = clampi(i, 0, 2)
	buttons.select(_selected if _selected < 2 else -1)
	ranking.set_selected(_selected == 2)


func _activate(i: int) -> void :
	if _director.playing:
		skip()
		return
	if not _armed:
		return
	_armed = false
	match i:
		0:
			buttons.press_visual(0)
			retry_requested.emit()
		1:
			buttons.press_visual(1)
			continue_requested.emit()
		2:
			_armed = true
			leaderboard_requested.emit()


func _on_leaderboard() -> void :
	if _director.playing:
		skip()
		return
	leaderboard_requested.emit()


func _unhandled_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or data == null:
		return
	if event is InputEventKey and event.pressed and not event.echo:


		if event.physical_keycode == KEY_ESCAPE or event.is_action_pressed("retry"):
			return
		if event.is_action_pressed("nav_left") or event.is_action_pressed("nav_up"):
			_select(_selected - 1 if _selected > 0 else 2)
		elif event.is_action_pressed("nav_right") or event.is_action_pressed("nav_down"):
			_select((_selected + 1) % 3)
		elif event.physical_keycode == KEY_TAB:
			_select((_selected + (2 if event.shift_pressed else 1)) % 3)
		elif event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]:
			_activate(_selected)
		elif _director.playing:
			skip()
		else:
			return
		get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_UP:
				_select(_selected - 1 if _selected > 0 else 2)
			JOY_BUTTON_DPAD_RIGHT, JOY_BUTTON_DPAD_DOWN:
				_select((_selected + 1) % 3)
			JOY_BUTTON_A, JOY_BUTTON_START:
				_activate(_selected)
			JOY_BUTTON_B:
				if _director.playing:
					skip()
				else:
					_activate(1)
			JOY_BUTTON_Y:
				_activate(2)
			JOY_BUTTON_X:
				_activate(0)
			_:
				return
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion:
		var v: float = event.axis_value
		if absf(v) < 0.35:
			_axis_armed = true
			return
		if not _axis_armed or absf(v) < 0.65:
			return
		_axis_armed = false
		if event.axis == JOY_AXIS_LEFT_X or event.axis == JOY_AXIS_LEFT_Y:
			_select((_selected + 1) % 3 if v > 0.0 else (_selected - 1 if _selected > 0 else 2))
