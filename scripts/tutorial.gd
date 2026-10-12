extends Control














const BPM: = 120.0
const SPB: = 60.0 / BPM
const MUSIC_LEN: = 48.0
const PANEL_BG: = Color(0.055, 0.065, 0.105, 0.97)



const VEIL_TEACH: = Color(0.008, 0.012, 0.026, 0.72)
const VEIL_VERDICT: = Color(0.008, 0.012, 0.026, 0.3)
const CHIP_BG: = Color(0.1, 0.12, 0.16, 0.92)
const MINT: = Color(0.3, 1.0, 0.85)
const VIOLET: = Color(0.72, 0.45, 1.0)
const GOLD: = Color(1.0, 0.78, 0.25)
const CYAN: = Color(0.45, 0.82, 1.0)
const RED: = Color(1.0, 0.35, 0.4)




const PHASES: = [
	["LANE NOTES", MINT, 5], 
	["DODGES", RED, 5], 
	["CLICK TARGETS", GOLD, 4], 
	["SLIDERS", GOLD, 1], 



	["HOLD NOTES", MINT, 3], 
	["GHOST CIRCLES", GOLD, 1], 
	["THE FINALE", VIOLET, 0], 
]



const FIRST_MAP: = "RAVENATIC"

var main

static var _music: AudioStreamWAV

var _phase: = 0
var _running: = false
var _ok: = 0
var _fail: = 0
var _total: = 0
var _end_t: = 0.0
var _grand_ok: = 0
var _grand_fail: = 0
var _quit_open: = false
var _verdict_open: = false

var _card: Control
var _veil: ColorRect
var _card_box: VBoxContainer
var _panel: PanelContainer
var _hint_panel: PanelContainer
var _hint_bar: Label
var _progress: Label
var _card_tw: Tween


func _ready() -> void :
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE



	_card = Control.new()
	_card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card.visible = false
	add_child(_card)
	_veil = ColorRect.new()
	_veil.color = VEIL_TEACH
	_veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	_card.add_child(_veil)
	var center: = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card.add_child(center)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(640, 0)
	var pst: = StyleBoxFlat.new()
	pst.bg_color = PANEL_BG
	pst.border_color = Color(1, 1, 1, 0.09)
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(18)
	pst.shadow_color = Color(0, 0, 0, 0.55)
	pst.shadow_size = 42
	pst.content_margin_left = 36
	pst.content_margin_right = 36
	pst.content_margin_top = 26
	pst.content_margin_bottom = 26
	_panel.add_theme_stylebox_override("panel", pst)
	center.add_child(_panel)
	_card_box = VBoxContainer.new()
	_card_box.add_theme_constant_override("separation", 10)
	_panel.add_child(_card_box)





	_hint_panel = PanelContainer.new()
	_hint_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_hint_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_hint_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hint_panel.offset_bottom = -30.0
	_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hst: = StyleBoxFlat.new()
	hst.bg_color = Color(0.03, 0.04, 0.072, 0.78)
	hst.border_color = Color(1, 1, 1, 0.1)
	hst.set_border_width_all(1)
	hst.set_corner_radius_all(11)
	hst.content_margin_left = 18
	hst.content_margin_right = 18
	hst.content_margin_top = 7
	hst.content_margin_bottom = 8
	_hint_panel.add_theme_stylebox_override("panel", hst)
	_hint_panel.visible = false
	add_child(_hint_panel)
	var hint_row: = HBoxContainer.new()
	hint_row.add_theme_constant_override("separation", 14)
	_hint_panel.add_child(hint_row)
	_hint_bar = Label.new()
	_hint_bar.add_theme_font_size_override("font_size", 16)
	_hint_bar.add_theme_color_override("font_color", Color(1, 1, 1, 0.88))
	hint_row.add_child(_hint_bar)
	_progress = Label.new()
	_progress.add_theme_font_size_override("font_size", 16)
	_progress.add_theme_color_override("font_color", MINT)
	hint_row.add_child(_progress)




func begin() -> void :
	visible = true
	_verdict_open = false
	_veil.color = VEIL_TEACH
	_phase = 0
	_grand_ok = 0
	_grand_fail = 0
	_quit_open = false
	_show_intro_card()




func on_judged(_kind: String, ok: bool) -> void :
	if not _running:
		return
	if ok:
		_ok += 1
		_grand_ok += 1
	else:
		_fail += 1
		_grand_fail += 1
	_progress.text = "%d / %d" % [_ok, _total]



func on_escape() -> void :
	if _quit_open:
		_quit_open = false
		_show_phase_card()
		return
	_quit_open = true
	if _running:
		_stop_pattern()
	_show_card("", "LEAVE THE TUTORIAL?", 
			"You can come back any time — the “?” icon on the home screen.", 
			Color(1, 1, 1, 0.8), [
		["KEEP LEARNING", MINT, func() -> void :
			_quit_open = false
			_show_phase_card()], 
		["LEAVE", Color(1, 1, 1, 0.45), func() -> void : _exit()], 
	])




func on_track_end() -> void :
	if _running:
		_finish_phase()


func _exit() -> void :
	_running = false
	visible = false
	_card.visible = false
	_hint_panel.visible = false
	main.end_tutorial()




func _show_intro_card() -> void :
	var k1: String = SettingsManager.key_label(SettingsManager.binds["hit_primary"])
	var k2: String = SettingsManager.key_label(SettingsManager.binds["hit_secondary"])
	_show_card("TUTORIAL", "WELCOME TO MELOA", 
			"The mint crosshair is YOU.\n\n" + 
			"• Three mascots hold the three lanes at the bottom — the one under\n" + 
			"  your cursor is your lane, and they react to everything you do.\n" + 
			"• Notes fall down the lanes — hit them with %s, %s or a click.\n" % [k1, k2] + 
			"• Yellow circles appear anywhere — aim and click them, osu! style.\n\n" + 
			"Seven short steps, about three minutes. Music starts when you do.", 
			Color(1, 1, 1, 0.8), [
		["START  →", MINT, func() -> void : _show_phase_card()], 
	])



func _show_phase_card() -> void :
	var accent: Color = PHASES[_phase][1]
	var k1: String = SettingsManager.key_label(SettingsManager.binds["hit_primary"])
	var k2: String = SettingsManager.key_label(SettingsManager.binds["hit_secondary"])
	var body: = ""
	match _phase:
		0:
			body = "White notes slide down the three lanes.\n\n" + """1.  Move your cursor over the note's lane — that lane's mascot lights up.
""" + """2.  When the note reaches the bottom line, press %s or %s (or click).

""" %[k1, k2] + \
			"Hit it dead-on for a PERFECT, close for a GOOD."
		1:
			body = "The RED notes are attacks. Don't press anything —\n" + \
			"just move your cursor OFF their lane before they land.\n\n" + \
			"Standing on a red note when it hits = damage. Dodging heals."
		2:
			body = "Yellow circles appear anywhere on screen.\n\n" + """1.  Put your cursor on the circle.
""" + """2.  Press %s / %s or click exactly when the shrinking ring closes on it.

""" %[k1, k2] + \
			"Careful: aiming a circle also moves you between lanes."
		3:
			body = "Sliders are yellow circles with a rail.\n\n" + """1.  Hit the head like a normal circle…
""" + \
			"2.  …then HOLD the key and follow the slider ball along the rail.\n" + \
			"3.  Release at the end.\n\nLetting go early breaks the slider."
		4:
			body = "A WHITE bar means hold, not tap.\n\n" + """1.  Press %s or %s when its head reaches the line…
""" %[k1, k2] + """2.  …and keep the key down while it passes, cursor on its lane.

""" + \
			"Same idea as a slider — but you stay in your lane, no aiming."
		5:
			body = "A yellow circle with a NUMBER wants several clicks.\n\n" + """1.  The number is how many hits are left.
""" + """2.  Click in rhythm — it slides to a new spot after each one.

""" + \
			"Follow it until the counter reaches zero."
		6:
			body = "Everything at once — lanes, dodges, circles, both kinds of hold,\n" + \
			"and the counter.\n\n" + \
			"This one is just to feel the flow. You can't fail it.\n" + \
			"Enjoy."
	_show_card("STEP %d / %d" % [_phase + 1, PHASES.size()], 
			PHASES[_phase][0], body, accent, [
		["GO  →", accent, func() -> void : _start_phase()], 
	])


func _show_retry_card() -> void :
	var accent: Color = PHASES[_phase][1]
	_show_card("STEP %d / %d" % [_phase + 1, PHASES.size()], "ALMOST!", 
			"You landed %d of %d. One more try?\nRepetition is exactly how rhythm games click." % [_ok, _total], 
			accent, [
		["TRY AGAIN", accent, func() -> void : _start_phase()], 
		["KEEP GOING ANYWAY", Color(1, 1, 1, 0.45), func() -> void : _next_phase()], 
	])


func _show_clear_card() -> void :
	var accent: Color = PHASES[_phase][1]
	var praise: = "CLEAN!" if _fail == 0 else "NICE!"
	_show_card("STEP %d / %d" % [_phase + 1, PHASES.size()], praise, 
			"%d of %d — that's the whole mechanic.\nReady for the next one?" % [_ok, _total], 
			accent, [
		["NEXT  →", accent, func() -> void : _next_phase()], 
		["REPLAY THIS STEP", Color(1, 1, 1, 0.45), func() -> void : _start_phase()], 
	])





func _show_done_card() -> void :
	var total: = _grand_ok + _grand_fail
	var pc: = 100.0 * float(_grand_ok) / float(maxi(total, 1))
	_show_card("TUTORIAL COMPLETE", "LET'S SEE WHAT YOU'VE GOT", 
			"%d%% of everything the game threw at you.\n\n" % roundi(pc) + 
			"That's every mechanic. Time for the real thing —\n" + 
			"a calm little track to warm up on. Nothing you can't handle.", 
			VIOLET, [
		["DROP ME IN  →", VIOLET, func() -> void : _exit_into_gauntlet()], 
		["BACK TO THE MENU", Color(1, 1, 1, 0.45), func() -> void : _exit()], 
	])
	if main != null:
		main.sfx.play_ui("impact")


func _exit_into_gauntlet() -> void :
	_running = false
	visible = false
	_card.visible = false
	_hint_panel.visible = false
	main.start_gauntlet()






func show_verdict(survived: bool) -> void :
	_running = false
	_quit_open = false
	_verdict_open = true
	visible = true
	_veil.color = VEIL_VERDICT
	_hint_panel.visible = false
	if survived:
		_show_card("Uhhh ?", "What happend ?", 
				"You just survived ???\n" + 
				"The hardest chart in the game. Right after a tutorial.\n\n" + 
				"Nobody does that. Nobody.\n\n" + 
				"So… what exactly were you doing in here? Scammer ???", 
				VIOLET, [
			["…OKAY THEN  →", VIOLET, func() -> void : main.gauntlet_exit()], 
			["GIVE ME A REAL MAP", MINT, func() -> void : main.gauntlet_exit(FIRST_MAP)], 
		], false)
	else:
		_show_card("WELL.", "MAYBE NOT YET", 
				"We may have skipped a few steps.\n\n" + 
					"practice before that one.", 
				GOLD, [
			["SOMETHING EASIER  →", MINT, func() -> void : main.gauntlet_exit(FIRST_MAP)], 
			["LET ME TRY AGAIN", GOLD, func() -> void : _verdict_retry()], 
			["MENU", Color(1, 1, 1, 0.45), func() -> void : main.gauntlet_exit()], 
		], false)


func _verdict_retry() -> void :
	_verdict_open = false
	visible = false
	_card.visible = false
	main.gauntlet_retry()





func _show_card(tag: String, title: String, body: String, accent: Color, 
		buttons: Array, esc_hint: = true) -> void :
	for c in _card_box.get_children():
		c.queue_free()
	if tag != "":
		var tl: = Label.new()
		tl.text = tag
		tl.add_theme_font_size_override("font_size", 12)
		if main != null and main.font_bold != null:
			tl.add_theme_font_override("font", main.font_bold)
		tl.add_theme_color_override("font_color", 
			Color(accent.r, accent.g, accent.b, 0.75))
		_card_box.add_child(tl)
	var t: = Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 30)
	if main != null and main.font_display != null:
		t.add_theme_font_override("font", main.font_display)
	t.add_theme_color_override("font_color", 
		Color(accent.r * 1.04, accent.g * 1.04, accent.b * 1.04))
	_card_box.add_child(t)
	var b: = Label.new()
	b.text = body
	b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.add_theme_font_size_override("font_size", 15)
	b.add_theme_color_override("font_color", Color(1, 1, 1, 0.78))
	_card_box.add_child(b)
	var gap: = Control.new()
	gap.custom_minimum_size = Vector2(0, 8)
	_card_box.add_child(gap)
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	_card_box.add_child(row)
	for spec in buttons:
		var btn: = Button.new()
		btn.text = spec[0]
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(0, 44)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 15)
		if main != null and main.font_display != null:
			btn.add_theme_font_override("font", main.font_display)
		var ac: Color = spec[1]
		var st: = StyleBoxFlat.new()
		st.bg_color = Color(ac.r, ac.g, ac.b, 0.16)
		st.border_color = Color(ac.r, ac.g, ac.b, 0.75)
		st.set_border_width_all(1)
		st.set_corner_radius_all(11)
		btn.add_theme_stylebox_override("normal", st)
		var hv: StyleBoxFlat = st.duplicate()
		hv.bg_color = Color(ac.r, ac.g, ac.b, 0.3)
		btn.add_theme_stylebox_override("hover", hv)
		btn.add_theme_stylebox_override("pressed", hv)
		btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.92))
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		var cb: Callable = spec[2]
		btn.pressed.connect( func() -> void :
			if main != null:
				main.sfx.play_ui("click")
			cb.call())
		row.add_child(btn)
	if esc_hint:
		var esc: = Label.new()
		esc.text = "ESC — leave the tutorial"
		esc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		esc.add_theme_font_size_override("font_size", 11)
		esc.add_theme_color_override("font_color", Color(1, 1, 1, 0.28))
		_card_box.add_child(esc)

	_card.visible = true
	_hint_panel.visible = false
	if _card_tw:
		_card_tw.kill()
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(1.04, 1.04)
	_panel.modulate.a = 0.0
	_card_tw = create_tween().set_parallel()
	_card_tw.tween_property(_panel, "modulate:a", 1.0, 0.16)
	_card_tw.tween_property(_panel, "scale", Vector2.ONE, 0.2)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)




func _start_phase() -> void :
	_quit_open = false
	_card.visible = false
	_ok = 0
	_fail = 0
	var notes: = _phase_notes(_phase)
	_total = notes.size()
	_end_t = 0.0
	for n in notes:
		_end_t = maxf(_end_t, float(n.time) + float(n.get("duration", 0.0)))
	_end_t += 1.8
	_setup_chart(notes)

	_hint_bar.text = _phase_hint(_phase)
	_hint_panel.visible = true
	_progress.text = "0 / %d" % _total
	_progress.visible = _phase < PHASES.size() - 1
	main.start_game(0.0)
	_running = true


func _stop_pattern() -> void :
	_running = false
	main.conductor.stop()
	_hint_panel.visible = false


func _finish_phase() -> void :
	_stop_pattern()
	var need: int = PHASES[_phase][2]
	if _phase >= PHASES.size() - 1:
		_show_done_card()
	elif _ok >= need:
		_show_clear_card()
	else:
		_show_retry_card()


func _next_phase() -> void :
	_phase += 1
	if _phase >= PHASES.size():
		_show_done_card()
	else:
		_show_phase_card()


func _process(_delta: float) -> void :
	if not visible or not _running or main == null:
		return
	var t: float = main.conductor.get_song_time()
	if t > _end_t:
		_finish_phase()



func _phase_hint(i: int) -> String:
	var k1: String = SettingsManager.key_label(SettingsManager.binds["hit_primary"])
	var k2: String = SettingsManager.key_label(SettingsManager.binds["hit_secondary"])
	match i:
		0:
			return "Cursor on the lane  ·  %s / %s or click when the note hits the line" % [k1, k2]
		1:
			return "RED = move OFF the lane  ·  WHITE = hit it"
		2:
			return "Aim the circle  ·  press when the ring closes"
		3:
			return "Hit the head, then HOLD and follow the rail"
		4:
			return "Press on the head  ·  HOLD the key, stay on the lane"
		5:
			return "Click in rhythm  ·  follow the number down to zero"
	return "Everything you've learned — go!"







func _setup_chart(notes: Array) -> void :
	main.conductor.stop()
	if _music == null:
		_music = _make_music()
	main.conductor.stream = _music
	main._chart_offset = 0.0
	main.chart_bpm = BPM
	main._apply_offset()
	main.chart_velocity = 1.0
	main.chart_end = 0.0
	main.chart_practice = -1.0
	main.auto_start = 0.0
	main.auto_end = 0.0
	main.kiai_sections = []
	main._load_lane_fx([])
	notes.sort_custom( func(a, b): return a.time < b.time)
	main.chart_notes = notes
	main._compute_yellow_spans()
	main._build_breaks()


func _note(time: float, type: String, lane: = 1) -> Dictionary:
	return {"time": time, "lane": lane, "type": type, "v": 1.0}


func _click_note(time: float, pos: Vector2) -> Dictionary:
	return {"time": time, "lane": 1, "type": "click", "v": 1.0, 
		"x": pos.x, "y": pos.y}





func _phase_notes(i: int) -> Array:
	var vs: Vector2 = main.get_viewport_rect().size
	var cx: = vs.x * 0.5
	var cy: float = clampf(main.tuning.hit_y - 280.0, 140.0, vs.y - 280.0)
	var notes: Array = []
	match i:
		0:

			var lanes: = [1, 1, 0, 2, 1, 0, 2, 1]
			for j in lanes.size():
				notes.append(_note(2.0 + j, "parry", lanes[j]))
		1:

			notes.append(_note(2.0, "parry", 1))
			notes.append(_note(3.0, "parry", 1))
			notes.append(_note(4.5, "dodge", 1))
			notes.append(_note(6.0, "dodge", 0))
			notes.append(_note(7.0, "parry", 2))
			notes.append(_note(8.5, "dodge", 2))
			notes.append(_note(9.5, "parry", 1))
			notes.append(_note(11.0, "dodge", 1))
		2:

			var offs: = [Vector2(0, 0), Vector2(-180, -40), Vector2(180, -40), 
				Vector2(-120, 90), Vector2(120, 90), Vector2(0, -80)]
			for j in offs.size():
				notes.append(_click_note(2.0 + 1.5 * j, Vector2(cx, cy) + offs[j]))
		3:

			notes.append({"time": 2.0, "lane": 1, "type": "sliderg", "v": 1.0, 
				"duration": 2.0, "points": [
					[0.0, cx - 260.0, cy + 40.0], 
					[0.33, cx - 90.0, cy - 50.0], 
					[0.66, cx + 90.0, cy - 50.0], 
					[1.0, cx + 260.0, cy + 40.0]]})
			notes.append({"time": 7.0, "lane": 1, "type": "sliderg", "v": 1.0, 
				"duration": 2.0, "points": [
					[0.0, cx + 260.0, cy + 40.0], 
					[0.33, cx + 90.0, cy - 50.0], 
					[0.66, cx - 90.0, cy - 50.0], 
					[1.0, cx - 260.0, cy + 40.0]]})
		4:


			notes.append(_note(2.0, "parry", 1))
			notes.append({"time": 4.0, "lane": 1, "type": "sliderm", "v": 1.0, 
				"duration": 2.0})
			notes.append(_note(7.5, "parry", 0))
			notes.append({"time": 9.5, "lane": 0, "type": "sliderm", "v": 1.0, 
				"duration": 2.0})
			notes.append(_note(13.0, "parry", 2))
			notes.append({"time": 15.0, "lane": 2, "type": "sliderm", "v": 1.0, 
				"duration": 2.5})
		5:



			var ring: = [Vector2(-150, 20), Vector2(-30, -60), Vector2(110, 0), 
				Vector2(0, 70)]
			for c in 2:
				var t0: = 2.0 + 7.0 * float(c)
				var extra: Array = []
				for k in range(1, ring.size()):
					var p: Vector2 = Vector2(cx, cy) + ring[(k + c) % ring.size()]
					extra.append([t0 + 0.5 * k, p.x, p.y])
				var head: Vector2 = Vector2(cx, cy) + ring[c % ring.size()]
				notes.append({"time": t0, "lane": 1, "type": "clickx", "v": 1.0, 
					"x": head.x, "y": head.y, "extra": extra})
		6:

			notes.append(_note(2.0, "parry", 1))
			notes.append(_note(3.0, "parry", 0))
			notes.append(_note(4.0, "parry", 2))
			notes.append(_click_note(5.5, Vector2(cx - 150.0, cy)))
			notes.append(_note(6.5, "parry", 1))
			notes.append(_note(7.5, "dodge", 1))
			notes.append({"time": 9.0, "lane": 2, "type": "sliderm", "v": 1.0, 
				"duration": 1.5})
			notes.append(_click_note(11.5, Vector2(cx + 150.0, cy)))
			notes.append({"time": 13.0, "lane": 1, "type": "sliderg", "v": 1.0, 
				"duration": 1.5, "points": [
					[0.0, cx - 180.0, cy + 20.0], 
					[0.5, cx, cy - 60.0], 
					[1.0, cx + 180.0, cy + 20.0]]})
			notes.append({"time": 16.0, "lane": 1, "type": "clickx", "v": 1.0, 
				"x": cx - 120.0, "y": cy, "extra": [
					[16.5, cx + 20.0, cy - 55.0], 
					[17.0, cx + 150.0, cy + 10.0]]})
			notes.append(_note(19.0, "parry", 0))
			notes.append(_note(20.0, "parry", 2))
			notes.append(_note(21.0, "parry", 1))
	return notes






static func _make_music() -> AudioStreamWAV:
	var rate: = 22050
	var frames: = int(rate * MUSIC_LEN)
	var mix: = PackedFloat32Array()
	mix.resize(frames)
	var beats: = int(MUSIC_LEN / SPB)

	var kick_len: = int(rate * 0.1)
	for b in beats:
		var start: = int(rate * SPB * b)
		var amp: = 0.85 if b % 4 == 0 else 0.62
		for j in kick_len:
			var idx: = start + j
			if idx >= frames:
				break
			var tt: = float(j) / rate
			var ph: = 48.0 * tt + 150.0 * 0.03 * (1.0 - exp( - tt / 0.03))
			mix[idx] += sin(TAU * ph) * exp( - tt / 0.055) * amp

	var hat_len: = int(rate * 0.03)
	for b in beats:
		var start: = int(rate * SPB * (float(b) + 0.5))
		for j in hat_len:
			var idx: = start + j
			if idx >= frames:
				break
			var tt: = float(j) / rate
			var nz: = fmod(sin(float(idx) * 12.9898) * 43758.5453, 2.0) - 1.0
			mix[idx] += nz * exp( - tt / 0.01) * 0.16

	var roots: = [55.0, 65.41, 49.0, 43.65]
	var bass_len: = int(rate * 0.42)
	var bar: = SPB * 4.0
	for k in int(MUSIC_LEN / (bar * 0.5)):
		var start: = int(rate * bar * 0.5 * k)
		var f: float = roots[(k / 2) % roots.size()]
		for j in bass_len:
			var idx: = start + j
			if idx >= frames:
				break
			var tt: = float(j) / rate
			var env: = minf(tt / 0.012, 1.0) * exp( - tt / 0.28)
			mix[idx] += (sin(TAU * f * tt) + 0.35 * sin(TAU * f * 2.0 * tt))\
			* env * 0.26

	var data: = PackedByteArray()
	data.resize(frames * 2)
	for idx in frames:
		var v: = int(clampf(mix[idx], -1.0, 1.0) * 30000.0)
		data[idx * 2] = v & 255
		data[idx * 2 + 1] = (v >> 8) & 255
	var wav: = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav
