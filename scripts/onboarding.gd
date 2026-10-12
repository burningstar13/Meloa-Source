extends Control















signal finished(play_tutorial: bool)

const PANEL_BG: = Color(0.055, 0.065, 0.105, 0.97)
const VEIL: = Color(0.008, 0.012, 0.026, 0.9)
const CHIP_BG: = Color(0.1, 0.12, 0.16, 0.92)
const CHIP_BG_HOVER: = Color(0.17, 0.2, 0.26, 0.95)
const MINT: = Color(0.3, 1.0, 0.85)
const VIOLET: = Color(0.72, 0.45, 1.0)
const GOLD: = Color(1.0, 0.78, 0.25)
const CYAN: = Color(0.45, 0.82, 1.0)
const LISTEN_TEXT: = "PRESS A KEY…"


const STEPS: = [
	["WELCOME", "Let's get you ready in about a minute.", MINT], 
	["YOUR AIM", "How do you point at things?", MINT], 
	["YOUR KEYS", "The two keys that hit the notes.", CYAN], 
	["YOUR SOUND", "Volumes, and syncing the game to your ears.", VIOLET], 
	["YOUR LOOK", "How much spectacle can your machine take?", GOLD], 
	["ALL SET", "One last thing before you play.", MINT], 
]

var main

var _panel: PanelContainer
var _pages: Array = []
var _step: = 0
var _dots: Array = []
var _title_label: Label
var _subtitle_label: Label
var _back_btn: Button
var _next_btn: Button
var _skip_btn: Button
var _open_tw: Tween


var _device_cards: = {}
var _sens_box: Control
var _area_w_box: Control
var _area_h_box: Control
var _device_hint: Label
var _click_toggle: Dictionary = {}


var _listen_action: = ""
var _bind_buttons: = {}
var _conflict_label: Label
var _keys_preview: Label


var _calibration: Control
var _offset_value: Label


var _preset_cards: = {}
var _preset_choice: = "FULL"
var _display_chips: = {}


var _recap_label: Label


func _ready() -> void :
	visible = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


	var veil: = ColorRect.new()
	veil.color = VEIL
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(veil)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(880, 620)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var pst: = StyleBoxFlat.new()
	pst.bg_color = PANEL_BG
	pst.border_color = Color(1, 1, 1, 0.09)
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(18)
	pst.shadow_color = Color(0, 0, 0, 0.55)
	pst.shadow_size = 48
	pst.content_margin_left = 40
	pst.content_margin_right = 40
	pst.content_margin_top = 28
	pst.content_margin_bottom = 26
	_panel.add_theme_stylebox_override("panel", pst)
	add_child(_panel)

	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	_panel.add_child(col)


	var dots_row: = HBoxContainer.new()
	dots_row.add_theme_constant_override("separation", 8)
	col.add_child(dots_row)
	for i in STEPS.size():
		var dot: = Panel.new()
		dot.custom_minimum_size = Vector2(26, 4)
		var dst: = StyleBoxFlat.new()
		dst.set_corner_radius_all(2)
		dot.add_theme_stylebox_override("panel", dst)
		dots_row.add_child(dot)
		_dots.append(dot)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 32)
	if _font_display() != null:
		_title_label.add_theme_font_override("font", _font_display())
	col.add_child(_title_label)
	_subtitle_label = Label.new()
	_subtitle_label.add_theme_font_size_override("font_size", 14)
	_subtitle_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.52))
	col.add_child(_subtitle_label)


	for i in STEPS.size():
		var sc: = ScrollContainer.new()
		sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		col.add_child(sc)
		var page: = VBoxContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.add_theme_constant_override("separation", 8)
		sc.add_child(page)
		_pages.append(sc)
	_build_welcome(_page(0))
	_build_device(_page(1))
	_build_keys(_page(2))
	_build_audio(_page(3))
	_build_visual(_page(4))
	_build_ready(_page(5))


	var foot: = HBoxContainer.new()
	foot.add_theme_constant_override("separation", 12)
	col.add_child(foot)
	_back_btn = _chip_button("BACK", Color(1, 1, 1, 0.5))
	_back_btn.pressed.connect(_go_back)
	foot.add_child(_back_btn)
	var spring: = Control.new()
	spring.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(spring)
	_skip_btn = Button.new()
	_skip_btn.text = "skip setup"
	_skip_btn.flat = true
	_skip_btn.focus_mode = Control.FOCUS_NONE
	_skip_btn.add_theme_font_size_override("font_size", 12)
	_skip_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
	_skip_btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 0.65))
	_skip_btn.pressed.connect( func() -> void :
		_ui_sound("back")
		_set_step(STEPS.size() - 1))
	foot.add_child(_skip_btn)
	_next_btn = _chip_button("NEXT  →", MINT)
	_next_btn.custom_minimum_size = Vector2(150, 0)
	_next_btn.pressed.connect(_go_next)
	foot.add_child(_next_btn)


func _page(i: int) -> VBoxContainer:
	return _pages[i].get_child(0)




func _build_welcome(page: VBoxContainer) -> void :
	_gap(page, 14)
	var big: = Label.new()
	big.text = "M E L O A"
	big.add_theme_font_size_override("font_size", 52)
	big.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if _font_display() != null:
		big.add_theme_font_override("font", _font_display())
	big.add_theme_color_override("font_color", Color(1.04, 1.04, 1.07))
	page.add_child(big)
	_gap(page, 8)
	var pitch: = Label.new()
	pitch.text = "A rhythm game about aiming, tapping and dodging —\nall at once, all on the beat."
	pitch.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pitch.add_theme_font_size_override("font_size", 17)
	pitch.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	page.add_child(pitch)
	_gap(page, 18)
	for line in [
		["1", "Pick your device and sensitivity", MINT], 
		["2", "Choose your keys", CYAN], 
		["3", "Set your sound and sync", VIOLET], 
		["4", "Pick a graphics preset", GOLD], 
		["5", "Learn the game in a 2-minute tutorial", MINT], 
	]:
		var row: = HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		page.add_child(row)
		var num: = Label.new()
		num.text = line[0]
		num.custom_minimum_size = Vector2(22, 0)
		num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		num.add_theme_font_size_override("font_size", 15)
		if _font_bold() != null:
			num.add_theme_font_override("font", _font_bold())
		var ac: Color = line[2]
		num.add_theme_color_override("font_color", Color(ac.r, ac.g, ac.b, 0.95))
		row.add_child(num)
		var txt: = Label.new()
		txt.text = line[1]
		txt.add_theme_font_size_override("font_size", 15)
		txt.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
		row.add_child(txt)
	_gap(page, 16)
	_hint_center(page, "Everything here can be changed later in SETTINGS.")


func _build_device(page: VBoxContainer) -> void :
	var accent: Color = STEPS[1][2]
	_gap(page, 4)
	var cards: = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 14)
	page.add_child(cards)
	_device_cards["MOUSE"] = _big_card(cards, "MOUSE", 
		"Relative aim — the cursor moves\nby (motion × sensitivity).", accent, 
		func() -> void :
			SettingsManager.set_input_device("MOUSE")
			_refresh_device())
	_device_cards["TABLET"] = _big_card(cards, "GRAPHICS TABLET", 
		"Absolute aim, osu! style — the pen\narea maps to the whole screen.", accent, 
		func() -> void :
			SettingsManager.set_input_device("TABLET")
			_refresh_device())

	_gap(page, 6)
	_sens_box = _slider_row(page, "Mouse sensitivity", 0.1, 4.0, 0.01, accent, 
		func(v: float) -> String: return "×%.2f" % v, 
		func(v: float) -> void : SettingsManager.set_mouse_sens(v))
	_area_w_box = _slider_row(page, "Tablet area — width (centered)", 
		0.2, 1.0, 0.01, accent, 
		func(v: float) -> String: return "%d %%" % roundi(v * 100.0), 
		func(v: float) -> void : SettingsManager.set_tablet_area_w(v))
	_area_h_box = _slider_row(page, "Tablet area — height (centered)", 
		0.2, 1.0, 0.01, accent, 
		func(v: float) -> String: return "%d %%" % roundi(v * 100.0), 
		func(v: float) -> void : SettingsManager.set_tablet_area_h(v))
	_device_hint = _hint(page, "", Color(1, 1, 1, 0.38))

	_gap(page, 6)
	_toggle_row(page, "Mouse & pen clicks hit notes", accent, _click_toggle, 
		func() -> bool: return SettingsManager.click_hits, 
		func(v: bool) -> void : SettingsManager.set_click_hits(v))
	_hint(page, "ON: clicking hits notes, on top of the keyboard. Most players keep this ON.", 
		Color(1, 1, 1, 0.38))
	_hint(page, "Move your cursor around — the mint crosshair IS your aim. You can\nfine-tune sensitivity any time in SETTINGS, even mid-session.", 
		Color(accent.r, accent.g, accent.b, 0.45))


func _build_keys(page: VBoxContainer) -> void :
	var accent: Color = STEPS[2][2]
	_gap(page, 4)
	_hint(page, "Notes are hit with TWO keys so you can alternate on fast streams —\nlike osu!. Click to rebind. Mouse clicks also hit (previous step).", 
		Color(1, 1, 1, 0.6))
	_gap(page, 8)
	for action in SettingsManager.ACTIONS:
		_bind_row(page, action, accent)
	_conflict_label = _hint(page, "", Color(1.0, 0.42, 0.45))
	_conflict_label.visible = false
	_gap(page, 10)
	_keys_preview = Label.new()
	_keys_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_keys_preview.add_theme_font_size_override("font_size", 26)
	if _font_display() != null:
		_keys_preview.add_theme_font_override("font", _font_display())
	_keys_preview.add_theme_color_override("font_color", 
		Color(accent.r, accent.g, accent.b, 0.92))
	page.add_child(_keys_preview)
	_gap(page, 10)
	_hint_center(page, "Tip: keep two neighbouring keys under your index and middle finger.")
	_hint(page, "GRID mode (one key per lane) has its own keys (Z/X/C by default) —\nrebindable in SETTINGS if you ever try that mode.", Color(1, 1, 1, 0.34))


func _build_audio(page: VBoxContainer) -> void :
	var accent: Color = STEPS[3][2]
	_section(page, "VOLUMES", accent)
	_slider_row(page, "Master volume", 0.0, 1.0, 0.01, accent, _pct, 
		func(v: float) -> void : SettingsManager.set_master_vol(v))
	_slider_row(page, "Music", 0.0, 1.0, 0.01, accent, _pct, 
		func(v: float) -> void : SettingsManager.set_music_vol(v))
	_slider_row(page, "Hitsounds & effects", 0.0, 1.0, 0.01, accent, _pct, 
		func(v: float) -> void :
			SettingsManager.set_hitsound_vol(v)
			_preview_hitsound())

	_section(page, "SYNC — THE ONE THAT MATTERS", accent)
	_hint(page, "Every setup has audio latency. A 30-second metronome test measures\nyours and applies the right offset — strongly recommended on wireless\nheadphones and TVs.", Color(1, 1, 1, 0.55))
	_gap(page, 4)
	var cal_row: = HBoxContainer.new()
	cal_row.add_theme_constant_override("separation", 12)
	page.add_child(cal_row)
	var cal_btn: = _chip_button("CALIBRATE NOW  ·  30 s", accent)
	cal_btn.pressed.connect(_open_calibration)
	cal_row.add_child(cal_btn)
	_offset_value = Label.new()
	_offset_value.add_theme_font_size_override("font_size", 14)
	if _font_bold() != null:
		_offset_value.add_theme_font_override("font", _font_bold())
	_offset_value.add_theme_color_override("font_color", accent)
	_offset_value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cal_row.add_child(_offset_value)
	_hint(page, "You can skip this and calibrate later (SETTINGS → AUDIO), or nudge\nthe sync by ear in game with O / P.", Color(1, 1, 1, 0.38))


func _build_visual(page: VBoxContainer) -> void :
	var accent: Color = STEPS[4][2]
	_gap(page, 4)
	var cards: = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 14)
	page.add_child(cards)
	_preset_cards["FULL"] = _big_card(cards, "THE FULL SHOW", 
		"Halos, particles, flames, shakes —\nMELOA as designed. For most GPUs.", accent, 
		func() -> void : _apply_preset("FULL"))
	_preset_cards["PERF"] = _big_card(cards, "PERFORMANCE", 
		"Minimal particles, no flames, no\nfreeze frames. Laptops, iGPUs.", accent, 
		func() -> void : _apply_preset("PERF"))
	_hint(page, "Every layer can then be tuned one by one in SETTINGS → VISUAL.\nReadability never changes: targets and judgements stay identical.", 
		Color(1, 1, 1, 0.38))

	_section(page, "DISPLAY", accent)
	var disp_row: = HBoxContainer.new()
	disp_row.add_theme_constant_override("separation", 8)
	page.add_child(disp_row)
	for mode in ["BORDERLESS", "FULLSCREEN", "WINDOWED"]:
		var chip: = _chip_button(mode, accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_display_mode(mode)
			_refresh_display())
		disp_row.add_child(chip)
		_display_chips[mode] = chip
	_hint(page, "BORDERLESS: fullscreen window, instant alt-tab (default). FULLSCREEN:\nexclusive, lowest latency. WINDOWED: 1280×720 window.", 
		Color(1, 1, 1, 0.38))


func _build_ready(page: VBoxContainer) -> void :
	var accent: Color = STEPS[5][2]
	_gap(page, 6)
	_recap_label = Label.new()
	_recap_label.add_theme_font_size_override("font_size", 15)
	_recap_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.72))
	page.add_child(_recap_label)
	_gap(page, 18)
	var tut: = _chip_button("PLAY THE TUTORIAL  ·  2 MIN  (RECOMMENDED)", accent)
	tut.custom_minimum_size = Vector2(0, 52)
	tut.add_theme_font_size_override("font_size", 17)
	if _font_display() != null:
		tut.add_theme_font_override("font", _font_display())
	tut.pressed.connect( func() -> void : _finish(true))
	page.add_child(tut)
	_gap(page, 4)
	var skip: = _chip_button("SKIP — I KNOW RHYTHM GAMES, LET ME PLAY", Color(1, 1, 1, 0.45))
	skip.custom_minimum_size = Vector2(0, 40)
	skip.pressed.connect( func() -> void : _finish(false))
	page.add_child(skip)
	_gap(page, 10)
	_hint_center(page, "The tutorial stays one click away — the “?” icon, top right of the home screen.")




func open() -> void :
	visible = true
	_set_step(0)
	_refresh_all()
	_ui_sound("whoosh")
	if _open_tw:
		_open_tw.kill()
	modulate.a = 0.0
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(1.05, 1.05)
	_open_tw = create_tween().set_parallel()
	_open_tw.tween_property(self, "modulate:a", 1.0, 0.22)
	_open_tw.tween_property(_panel, "scale", Vector2.ONE, 0.26)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _finish(play_tutorial: bool) -> void :
	SettingsManager.set_onboarding_done(true)
	_ui_sound("impact")
	if _open_tw:
		_open_tw.kill()
	_open_tw = create_tween()
	_open_tw.tween_property(self, "modulate:a", 0.0, 0.16)
	_open_tw.tween_callback( func() -> void :
		visible = false
		finished.emit(play_tutorial))


func _set_step(i: int) -> void :
	_stop_listen()
	_step = clampi(i, 0, STEPS.size() - 1)
	_title_label.text = STEPS[_step][0]
	_subtitle_label.text = STEPS[_step][1]
	var accent: Color = STEPS[_step][2]
	_title_label.add_theme_color_override("font_color", 
		Color(accent.r * 1.04, accent.g * 1.04, accent.b * 1.04))
	for j in _pages.size():
		_pages[j].visible = j == _step
	for j in _dots.size():
		var dst: StyleBoxFlat = _dots[j].get_theme_stylebox("panel")
		var dc: Color = STEPS[j][2]
		dst.bg_color = Color(dc.r, dc.g, dc.b, 0.95) if j <= _step\
		else Color(1, 1, 1, 0.1)
	_back_btn.visible = _step > 0

	_next_btn.visible = _step < STEPS.size() - 1
	_skip_btn.visible = _step < STEPS.size() - 1
	_next_btn.text = "LET'S GO  →" if _step == 0 else "NEXT  →"
	_paint_chip(_next_btn, accent, true)
	if _step == STEPS.size() - 1:
		_refresh_recap()
	_refresh_all()


func _go_next() -> void :
	_ui_sound("click")
	_set_step(_step + 1)


func _go_back() -> void :
	_ui_sound("back")
	_set_step(_step - 1)


func _apply_preset(which: String) -> void :
	_preset_choice = which

	SettingsManager.apply_visual_preset("PERF" if which == "PERF" else "FULL")
	_refresh_preset()


func _open_calibration() -> void :
	if _calibration == null:
		_calibration = preload("res://scripts/calibration.gd").new()
		_calibration.settings = self
		add_child(_calibration)
	_calibration.open()




func _unhandled_input(event: InputEvent) -> void :
	if not visible:
		return
	if _calibration != null and _calibration.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		if _listen_action != "":
			if event.physical_keycode == KEY_ESCAPE:
				_stop_listen()
				return
			var res: String = SettingsManager.rebind(_listen_action, event.physical_keycode)
			if res.begins_with("!"):
				_conflict_label.text = "Fixed key: %s" % res.substr(1)
				_conflict_label.visible = true
				return
			_ui_sound("click")
			_stop_listen()
			return
		match event.physical_keycode:
			KEY_ESCAPE:
				if _step > 0:
					_go_back()
			KEY_ENTER, KEY_KP_ENTER:
				if _step < STEPS.size() - 1:
					_go_next()


func _start_listen(action: String) -> void :
	_listen_action = action
	_conflict_label.visible = false
	_refresh_binds()


func _stop_listen() -> void :
	_listen_action = ""
	if _conflict_label != null:
		_conflict_label.visible = false
	_refresh_binds()


func _process(_delta: float) -> void :
	if not visible:
		return
	if _listen_action != "":
		var b: Button = _bind_buttons[_listen_action]
		b.modulate.a = 0.75 + 0.25 * sin(Time.get_ticks_msec() / 120.0)
	else:
		for action in _bind_buttons:
			_bind_buttons[action].modulate.a = 1.0




func _refresh_all() -> void :
	if _sens_box != null:
		_set_slider(_sens_box, SettingsManager.mouse_sens)
		_set_slider(_area_w_box, SettingsManager.tablet_area_w)
		_set_slider(_area_h_box, SettingsManager.tablet_area_h)
		_refresh_device()
	_refresh_binds()

	_set_sliders_in(_page(3), [SettingsManager.master_vol, 
		SettingsManager.music_vol, SettingsManager.hitsound_vol])
	if _offset_value != null:
		_offset_value.text = "current offset: %+d ms" % SettingsManager.audio_offset_ms
	_refresh_preset()
	_refresh_display()
	if not _click_toggle.is_empty():
		_paint_toggle(_click_toggle)


func _refresh_device() -> void :
	var dev: String = SettingsManager.input_device
	for dname in _device_cards:
		_paint_card(_device_cards[dname], STEPS[1][2], dname == dev)
	_sens_box.visible = dev == "MOUSE"
	_area_w_box.visible = dev == "TABLET"
	_area_h_box.visible = dev == "TABLET"
	if dev == "MOUSE":
		_device_hint.text = "In game the cursor moves relative to your motion — full desk space,\nno shrunken screen."
	else:
		_device_hint.text = "The centered tablet area maps to the whole screen. Shrink it for\nshorter flicks — the mint frame in game shows your zone."


func _refresh_binds() -> void :
	for action in _bind_buttons:
		var b: Button = _bind_buttons[action]
		if action == _listen_action:
			b.text = LISTEN_TEXT
			_paint_chip(b, STEPS[2][2], true)
		else:
			b.text = SettingsManager.key_label(SettingsManager.binds[action])
			_paint_chip(b, STEPS[2][2], false)
	if _keys_preview != null:
		_keys_preview.text = "%s   ·   %s" % [
			SettingsManager.key_label(SettingsManager.binds["hit_primary"]), 
			SettingsManager.key_label(SettingsManager.binds["hit_secondary"])]


func _refresh_preset() -> void :
	for which in _preset_cards:
		_paint_card(_preset_cards[which], STEPS[4][2], which == _preset_choice)


func _refresh_display() -> void :
	for mode in _display_chips:
		_paint_chip(_display_chips[mode], STEPS[4][2], 
			mode == SettingsManager.display_mode)


func _refresh_recap() -> void :
	var dev: = "Mouse  ×%.2f" % SettingsManager.mouse_sens\
	if SettingsManager.input_device == "MOUSE"\
	else "Tablet  %d%% × %d%%" % [roundi(SettingsManager.tablet_area_w * 100.0), 
		roundi(SettingsManager.tablet_area_h * 100.0)]
	_recap_label.text = "Aim         %s\nKeys        %s / %s%s\nSync        %+d ms\nGraphics    %s  ·  %s" % [
		dev, 
		SettingsManager.key_label(SettingsManager.binds["hit_primary"]), 
		SettingsManager.key_label(SettingsManager.binds["hit_secondary"]), 
		"  + clicks" if SettingsManager.click_hits else "", 
		SettingsManager.audio_offset_ms, 
		"The full show" if _preset_choice == "FULL" else "Performance", 
		SettingsManager.display_mode.to_lower()]




func _gap(page: VBoxContainer, h: float) -> void :
	var c: = Control.new()
	c.custom_minimum_size = Vector2(0, h)
	page.add_child(c)


func _section(page: VBoxContainer, title: String, accent: Color) -> void :
	_gap(page, 8)
	var l: = Label.new()
	l.text = title
	l.add_theme_font_size_override("font_size", 13)
	if _font_bold() != null:
		l.add_theme_font_override("font", _font_bold())
	l.add_theme_color_override("font_color", 
		Color(accent.r, accent.g, accent.b, 0.9))
	page.add_child(l)
	var rule: = Panel.new()
	rule.custom_minimum_size = Vector2(0, 2)
	var rst: = StyleBoxFlat.new()
	rst.bg_color = Color(accent.r, accent.g, accent.b, 0.22)
	rst.set_corner_radius_all(1)
	rule.add_theme_stylebox_override("panel", rst)
	page.add_child(rule)


func _hint(page: VBoxContainer, text: String, color: Color) -> Label:
	var l: = Label.new()
	l.text = text
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", color)
	page.add_child(l)
	return l


func _hint_center(page: VBoxContainer, text: String) -> void :
	var l: = _hint(page, text, Color(1, 1, 1, 0.38))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER




func _big_card(row: HBoxContainer, title: String, desc: String, accent: Color, 
		action: Callable) -> Button:
	var b: = Button.new()
	b.focus_mode = Control.FOCUS_NONE
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.custom_minimum_size = Vector2(0, 108)
	b.pressed.connect( func() -> void :
		_ui_sound("click")
		action.call())
	row.add_child(b)
	var v: = VBoxContainer.new()
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 6)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var t: = Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 19)
	if _font_display() != null:
		t.add_theme_font_override("font", _font_display())
	v.add_child(t)
	b.set_meta("card_title", t)
	var d: = Label.new()
	d.text = desc
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d.add_theme_font_size_override("font_size", 12)
	d.add_theme_color_override("font_color", Color(1, 1, 1, 0.52))
	v.add_child(d)
	_paint_card(b, accent, false)
	return b


func _paint_card(b: Button, accent: Color, active: bool) -> void :
	var bg: = Color(accent.r, accent.g, accent.b, 0.14) if active\
	else Color(1, 1, 1, 0.035)
	var border: = Color(accent.r, accent.g, accent.b, 0.85) if active\
	else Color(1, 1, 1, 0.12)
	var st: = StyleBoxFlat.new()
	st.bg_color = bg
	st.border_color = border
	st.set_border_width_all(2 if active else 1)
	st.set_corner_radius_all(14)
	b.add_theme_stylebox_override("normal", st)
	var hv: = st.duplicate()
	if not active:
		hv.bg_color = Color(1, 1, 1, 0.07)
		hv.border_color = Color(1, 1, 1, 0.25)
	b.add_theme_stylebox_override("hover", hv)
	b.add_theme_stylebox_override("pressed", st)
	if b.has_meta("card_title"):
		(b.get_meta("card_title") as Label).add_theme_color_override(
			"font_color", accent if active else Color(1, 1, 1, 0.85))


func _toggle_row(page: VBoxContainer, label_text: String, accent: Color, 
		entry: Dictionary, is_on: Callable, setter: Callable) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	page.add_child(row)
	var l: = Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	row.add_child(l)
	var chip: = _chip_button("ON", accent)
	chip.custom_minimum_size = Vector2(64, 0)
	entry["chip"] = chip
	entry["is_on"] = is_on
	entry["accent"] = accent
	chip.pressed.connect( func() -> void :
		setter.call( not is_on.call())
		_paint_toggle(entry))
	row.add_child(chip)
	_paint_toggle(entry)


func _paint_toggle(entry: Dictionary) -> void :
	var on: bool = entry["is_on"].call()
	var chip: Button = entry["chip"]
	chip.text = "ON" if on else "OFF"
	_paint_chip(chip, entry["accent"], on)


func _slider_row(page: VBoxContainer, title: String, mn: float, mx: float, 
		step: float, accent: Color, fmt: Callable, setter: Callable) -> Control:
	var box: = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	page.add_child(box)
	var head: = HBoxContainer.new()
	box.add_child(head)
	var t: = Label.new()
	t.text = title
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.add_theme_font_size_override("font_size", 15)
	t.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	head.add_child(t)
	var v: = Label.new()
	v.add_theme_font_size_override("font_size", 15)
	if _font_bold() != null:
		v.add_theme_font_override("font", _font_bold())
	v.add_theme_color_override("font_color", accent)
	head.add_child(v)
	var s: = HSlider.new()
	s.min_value = mn
	s.max_value = mx
	s.step = step
	s.focus_mode = Control.FOCUS_NONE
	s.custom_minimum_size = Vector2(0, 22)
	var track: = StyleBoxFlat.new()
	track.bg_color = Color(1, 1, 1, 0.08)
	track.set_corner_radius_all(3)
	track.content_margin_top = 3
	track.content_margin_bottom = 3
	s.add_theme_stylebox_override("slider", track)
	var fill: = StyleBoxFlat.new()
	fill.bg_color = Color(accent.r, accent.g, accent.b, 0.85)
	fill.set_corner_radius_all(3)
	s.add_theme_stylebox_override("grabber_area", fill)
	var fill_hl: = StyleBoxFlat.new()
	fill_hl.bg_color = accent
	fill_hl.set_corner_radius_all(3)
	s.add_theme_stylebox_override("grabber_area_highlight", fill_hl)
	s.value_changed.connect( func(val: float) -> void :
		setter.call(val)
		v.text = fmt.call(val))
	box.add_child(s)
	box.set_meta("slider", s)
	box.set_meta("value_label", v)
	box.set_meta("fmt", fmt)
	return box


func _set_slider(box: Control, val: float) -> void :
	var s: HSlider = box.get_meta("slider")
	s.set_value_no_signal(val)
	var fmt: Callable = box.get_meta("fmt")
	(box.get_meta("value_label") as Label).text = fmt.call(val)


func _set_sliders_in(page: VBoxContainer, values: Array) -> void :
	var i: = 0
	for child in page.get_children():
		if child is Control and child.has_meta("slider") and i < values.size():
			_set_slider(child, values[i])
			i += 1


func _bind_row(page: VBoxContainer, action: String, accent: Color) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	page.add_child(row)
	var t: = Label.new()
	t.text = SettingsManager.ACTION_LABELS[action]
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.add_theme_font_size_override("font_size", 15)
	t.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	row.add_child(t)
	var b: = _chip_button("", accent)
	b.custom_minimum_size = Vector2(220, 0)
	if _font_bold() != null:
		b.add_theme_font_override("font", _font_bold())
	b.pressed.connect(_start_listen.bind(action))
	row.add_child(b)
	_bind_buttons[action] = b


func _chip_button(text: String, accent: Color) -> Button:
	var b: = Button.new()
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_size_override("font_size", 14)
	_paint_chip(b, accent, false)
	return b


func _paint_chip(b: Button, accent: Color, active: bool) -> void :
	var bg: = Color(accent.r, accent.g, accent.b, 0.92) if active else CHIP_BG
	var border: = Color(1, 1, 1, 0.15) if active else Color(1, 1, 1, 0.1)
	b.add_theme_stylebox_override("normal", _chip_style(bg, border))
	b.add_theme_stylebox_override("hover", 
		_chip_style(bg if active else CHIP_BG_HOVER, Color(1, 1, 1, 0.22)))
	b.add_theme_stylebox_override("pressed", _chip_style(
		Color(accent.r, accent.g, accent.b, 0.92), Color(1, 1, 1, 0.15)))
	var ink: = Color(0.05, 0.1, 0.08) if active else Color(1, 1, 1, 0.78)
	b.add_theme_color_override("font_color", ink)
	b.add_theme_color_override("font_hover_color", 
		ink if active else Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color(0.05, 0.1, 0.08))


func _chip_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb: = StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(9)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 5
	sb.content_margin_bottom = 5
	return sb


func _pct(v: float) -> String:
	return "%d %%" % roundi(v * 100.0)


var _sfx_preview_at: = -10.0


func _preview_hitsound() -> void :
	if main == null:
		return
	var now: = Time.get_ticks_msec() / 1000.0
	if now - _sfx_preview_at > 0.18:
		_sfx_preview_at = now
		main.sfx.play_sfx("parry_perfect")


func _ui_sound(name_s: String) -> void :
	if main != null:
		main.sfx.play_ui(name_s)


func _font_display() -> Font:
	return main.font_display if main != null else null


func _font_bold() -> Font:
	return main.font_bold if main != null else null
