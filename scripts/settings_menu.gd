extends Control








const TAB_DEFS: = [
	["GAMEPLAY", Color(0.3, 1.0, 0.85)], 
	["AUDIO", Color(0.72, 0.45, 1.0)], 
	["VISUAL", Color(1.0, 0.78, 0.25)], 
]
const PANEL_BG: = Color(0.055, 0.065, 0.105, 0.97)
const VEIL: = Color(0.012, 0.018, 0.038, 0.74)
const CHIP_BG: = Color(0.1, 0.12, 0.16, 0.92)
const CHIP_BG_HOVER: = Color(0.17, 0.2, 0.26, 0.95)
const LISTEN_TEXT: = "PRESS A KEY…"

var main

var _panel: PanelContainer
var _tab_buttons: Array = []
var _tab_underlines: Array = []
var _tab_pages: Array = []
var _current_tab: = 0


var _listen_action: = ""
var _bind_buttons: = {}
var _conflict_label: Label
var _swapped: Array = []
var _swap_timer: SceneTreeTimer
const COL_SWAP: = Color(1.0, 0.62, 0.2)
var _device_chips: = {}
var _toggles: Array = []
var _sens_box: Control
var _scroll_box: Control
var _display_chips: = {}
var _res_chips: = {}


var _render_res_chips: = {}
var _render_res_note: Label = null
var _fps_chips: = {}
var _vsync_chips: = {}
var _quality_rows: = []

var _quality_chips: = {}
var _quality_note: Label = null
var _quality_accent: = Color.WHITE
var _area_w_box: Control
var _area_h_box: Control
var _device_hint: Label
var _debug_label: Label
var _sfx_preview_at: = -10.0
var _skin_row: HFlowContainer
var _open_tw: Tween
var _calibration: Control



var _gpu_pending: = ""


func _ready() -> void :
	visible = false


	SettingsManager.settings_changed.connect( func(key: String) -> void :
		if key == "master_vol" and visible:
			_refresh_all())
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var veil: = ColorRect.new()
	veil.color = VEIL
	veil.set_anchors_preset(Control.PRESET_FULL_RECT)
	veil.gui_input.connect( func(e: InputEvent) -> void :
		if e is InputEventMouseButton and e.pressed:
			close())
	add_child(veil)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(920, 634)
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var pst: = StyleBoxFlat.new()
	pst.bg_color = PANEL_BG
	pst.border_color = Color(1, 1, 1, 0.09)
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(18)
	pst.shadow_color = Color(0, 0, 0, 0.5)
	pst.shadow_size = 42
	pst.content_margin_left = 34
	pst.content_margin_right = 34
	pst.content_margin_top = 24
	pst.content_margin_bottom = 26
	_panel.add_theme_stylebox_override("panel", pst)
	add_child(_panel)

	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	_panel.add_child(col)


	var head: = HBoxContainer.new()
	head.add_theme_constant_override("separation", 14)
	col.add_child(head)
	var title: = Label.new()
	title.text = "SETTINGS"
	title.add_theme_font_size_override("font_size", 30)
	if _font_display() != null:
		title.add_theme_font_override("font", _font_display())
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var esc_hint: = Label.new()
	esc_hint.text = "ESC TO CLOSE"
	esc_hint.add_theme_font_size_override("font_size", 12)
	esc_hint.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	esc_hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	head.add_child(esc_hint)
	var close_b: = Button.new()
	close_b.text = "×"
	close_b.focus_mode = Control.FOCUS_NONE
	close_b.flat = true
	close_b.add_theme_font_size_override("font_size", 22)
	close_b.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	close_b.add_theme_color_override("font_hover_color", Color.WHITE)
	close_b.pressed.connect(close)
	head.add_child(close_b)



	var tab_bar: = HBoxContainer.new()
	tab_bar.add_theme_constant_override("separation", 26)
	col.add_child(tab_bar)
	for i in TAB_DEFS.size():
		var tb: = VBoxContainer.new()
		tb.add_theme_constant_override("separation", 5)
		tab_bar.add_child(tb)
		var b: = Button.new()
		b.text = TAB_DEFS[i][0]
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_size_override("font_size", 16)
		if _font_display() != null:
			b.add_theme_font_override("font", _font_display())
		b.pressed.connect(_set_tab.bind(i))
		tb.add_child(b)
		var line: = Panel.new()
		line.custom_minimum_size = Vector2(0, 3)
		var lst: = StyleBoxFlat.new()
		lst.set_corner_radius_all(2)
		line.add_theme_stylebox_override("panel", lst)
		tb.add_child(line)
		_tab_buttons.append(b)
		_tab_underlines.append(line)


	for i in TAB_DEFS.size():
		var sc: = ScrollContainer.new()
		sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
		sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		col.add_child(sc)
		var page: = VBoxContainer.new()
		page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		page.add_theme_constant_override("separation", 8)
		sc.add_child(page)
		_tab_pages.append(sc)
	_build_gameplay(_page(0), TAB_DEFS[0][1])
	_build_audio(_page(1), TAB_DEFS[1][1])
	_build_visual(_page(2), TAB_DEFS[2][1])
	_set_tab(0)


func _page(i: int) -> VBoxContainer:
	return _tab_pages[i].get_child(0)




func _build_gameplay(page: VBoxContainer, accent: Color) -> void :




	for group in SettingsManager.BIND_GROUPS:
		_section(page, "KEYS  ·  %s" % String(group[0]), accent)
		for action in group[1]:
			_bind_row(page, action, accent)
	_conflict_label = _hint(page, "", Color(1.0, 0.42, 0.45))
	_conflict_label.visible = false
	var reset_btn: = _chip_button("RESET ALL KEYS", accent)
	reset_btn.pressed.connect( func() -> void :
		SettingsManager.reset_binds()
		_swapped.clear()
		_conflict_label.visible = false
		_refresh_binds()
		if main != null:
			main.sfx.play_ui("click"))
	page.add_child(reset_btn)
	_toggle_row(page, "Mouse & pen clicks hit notes", accent, 
		func() -> bool: return SettingsManager.click_hits, 
		func(v: bool) -> void : SettingsManager.set_click_hits(v))



	_section(page, "AIM", accent)
	var dev_row: = HBoxContainer.new()
	dev_row.add_theme_constant_override("separation", 10)
	page.add_child(dev_row)
	var dev_label: = Label.new()
	dev_label.text = "Device"
	dev_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dev_label.add_theme_font_size_override("font_size", 15)
	dev_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	dev_row.add_child(dev_label)
	for dev in ["MOUSE", "TABLET"]:
		var chip: = _chip_button(dev, accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_input_device(dev)
			_refresh_device())
		dev_row.add_child(chip)
		_device_chips[dev] = chip
	_device_hint = _hint(page, "", Color(1, 1, 1, 0.38))

	_sens_box = _slider_row(page, "Mouse sensitivity", 
		0.1, 4.0, 0.01, accent, 
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

	_section(page, "NOTES", accent)
	_scroll_box = _slider_row(page, "Note scroll speed", 
		0.5, 1.5, 0.01, accent, 
		func(v: float) -> String: return "×%.2f" % v, 
		func(v: float) -> void : SettingsManager.set_scroll_speed(v))

	_debug_label = _hint(page, "", Color(accent.r, accent.g, accent.b, 0.55))
	_debug_label.add_theme_font_size_override("font_size", 12)


func _build_audio(page: VBoxContainer, accent: Color) -> void :
	_section(page, "VOLUMES", accent)
	_slider_row(page, "Master volume", 0.0, 1.0, 0.01, accent, _pct, 
		func(v: float) -> void : SettingsManager.set_master_vol(v))
	_slider_row(page, "Music", 0.0, 1.0, 0.01, accent, _pct, 
		func(v: float) -> void : SettingsManager.set_music_vol(v))
	_slider_row(page, "Hitsounds & effects", 0.0, 1.0, 0.01, accent, _pct, 
		func(v: float) -> void :
			SettingsManager.set_hitsound_vol(v)
			_preview_hitsound())

	_section(page, "SYNC", accent)
	_slider_row(page, "Manual audio offset", -200.0, 200.0, 1.0, accent, 
		func(v: float) -> String: return "%+d ms" % roundi(v), 
		func(v: float) -> void : SettingsManager.set_audio_offset_ms(roundi(v)))
	var cal_row: = HBoxContainer.new()
	page.add_child(cal_row)
	var cal_btn: = _chip_button("CALIBRATE BY EAR  ·  METRONOME", accent)
	cal_btn.pressed.connect(_open_calibration)
	cal_row.add_child(cal_btn)

	_section(page, "CUSTOM HITSOUNDS", accent)
	var hs_row: = HBoxContainer.new()
	hs_row.add_theme_constant_override("separation", 10)
	page.add_child(hs_row)
	var hs_open: = _chip_button("OPEN FOLDER", accent)
	hs_open.pressed.connect( func() -> void :
		DirAccess.make_dir_recursive_absolute(
			ProjectSettings.globalize_path(Sfx.USER_HITSOUNDS_DIR))
		OS.shell_open(ProjectSettings.globalize_path(Sfx.USER_HITSOUNDS_DIR)))
	hs_row.add_child(hs_open)
	var hs_reload: = _chip_button("RELOAD", accent)
	hs_reload.pressed.connect( func() -> void :
		if main != null:
			main.sfx.set_pack(main.sfx.current_pack)
			main.sfx.play_sfx("parry_perfect"))
	hs_row.add_child(hs_reload)







func _build_visual(page: VBoxContainer, accent: Color) -> void :
	_section(page, "HUD", accent)
	_vis_row(page, "Score", accent, "hud_score")
	_vis_row(page, "Score gain popup (+200)", accent, "hud_score_delta")
	_vis_row(page, "Combo (under the score)", accent, "hud_combo")
	_vis_row(page, "HP bar", accent, "hud_hp")
	_vis_row(page, "Accuracy", accent, "hud_accuracy")
	_vis_row(page, "Time left", accent, "hud_time")
	_vis_row(page, "Judgement text (PERFECT / GOOD / MISS)", accent, "hud_judge")
	_vis_row(page, "Timing bar (+/- ms)", accent, "hud_timing")
	_vis_row(page, "Active mods reminder", accent, "hud_mods")
	_vis_row(page, "FPS counter (bottom-right, every screen)", accent, "hud_fps")

	_section(page, "GAMEPLAY EFFECTS", accent)
	_vis_row(page, "Yellow target glow (halo)", accent, "fx_hit_glow")
	_vis_row(page, "Yellow hit sparks (click pop)", accent, "fx_click_pop")
	_vis_row(page, "Chromatic glitch on hits", accent, "fx_glitch")
	_vis_row(page, "Hit bursts (particles)", accent, "fx_burst")
	_vis_row(page, "Shockwaves", accent, "fx_shockwave")
	_vis_row(page, "Zoom punch on impact", accent, "fx_zoom")
	_vis_row(page, "Floating texts at the note (PERFECT, counts)", accent, "fx_float_text")
	_vis_row(page, "Impact line flash", accent, "fx_line_flash")
	_vis_row(page, "Slider glow (rail, comet trail)", accent, "fx_slider_glow")
	_vis_row(page, "ON FIRE drop effects (flames, flash)", accent, "fx_fire")
	_vis_row(page, "Lane mascots", accent, "fx_mascots")
	_vis_row(page, "Skin animations (sprite sheets)", accent, "fx_skin_anims")

	_section(page, "SCREEN SHAKE", accent)
	_vis_row(page, "On yellow clicks (auto-muted in full-yellow phases)", accent, "fx_shake_click")
	_vis_row(page, "On miss", accent, "fx_shake_miss")
	_vis_row(page, "Drops, game over, launch, choreography", accent, "fx_shake_events")

	_section(page, "BACKGROUND", accent)
	_vis_row(page, "Beatmap background (image / video)", accent, "bg_map")
	_vis_row(page, "Side sound bars (live EQ)", accent, "bg_eq")
	_vis_row(page, "Beat patterns (rings, waves, matrix...)", accent, "bg_patterns")
	_vis_row(page, "Dust & embers", accent, "bg_particles")















	_section(page, "GRAPHICS API (restart required)", accent)
	var api_row: = HBoxContainer.new()
	api_row.add_theme_constant_override("separation", 8)
	page.add_child(api_row)
	var api_chips: = {}


	_gpu_pending = ""
	var paint_api: = func() -> void :
		var want: = _gpu_pending
		if want == "":
			want = SettingsManager.gpu_api_requested()
		if want == "":
			want = SettingsManager.gpu_api_current()
		for k in api_chips:
			_paint_chip(api_chips[k], accent, k == want)
	var restart: = _chip_button("RESTART NOW", accent)
	restart.visible = false
	restart.pressed.connect( func() -> void :
		if _gpu_pending == "":
			return


		OS.set_restart_on_exit(true, SettingsManager.gpu_api_restart_args(_gpu_pending))
		get_tree().quit())
	for api in SettingsManager.GPU_APIS:
		var label: = String(SettingsManager.GPU_API_LABELS.get(api, api.to_upper()))
		var chip: = _chip_button(label, accent)
		chip.pressed.connect( func() -> void :
			_gpu_pending = api
			restart.visible = true
			if SettingsManager.set_gpu_api(api):
				main._menu_toast("GRAPHICS API SET TO %s  ·  restart the game to apply" % label, 
					main.COL_GOLD)
			else:
				main._menu_toast("COULD NOT WRITE override.cfg (dev build, or folder not writable)  ·  use RESTART NOW", 
					main.COL_RED)
			paint_api.call())
		api_row.add_child(chip)
		api_chips[api] = chip
	api_row.add_child(restart)
	paint_api.call()
	var gpu_note: = "Now: %s on %s" % [String(SettingsManager.GPU_API_LABELS.get(
		SettingsManager.gpu_api_current(), SettingsManager.gpu_api_current().to_upper())), 
		SettingsManager.gpu_adapter_name()]
	if SettingsManager.gpu_is_software():
		gpu_note += "\n⚠ SOFTWARE RENDERING — your GPU is not being used. Switch to VULKAN, then OPENGL 3 if that fails."
	elif SettingsManager.gpu_is_compat():
		gpu_note += "\n⚠ COMPATIBILITY MODE — glow and HDR are off. Try VULKAN or D3D12 for the full look."
	_hint(page, gpu_note, 
		Color(1.0, 0.55, 0.45, 0.85) if SettingsManager.gpu_is_software() else Color(1, 1, 1, 0.38))

	_section(page, "SKIN (IN-GAME ONLY)", accent)
	_skin_row = HFlowContainer.new()
	_skin_row.add_theme_constant_override("h_separation", 8)
	_skin_row.add_theme_constant_override("v_separation", 8)
	page.add_child(_skin_row)
	_rebuild_skin_chips(accent)
	var sk_btns: = HBoxContainer.new()
	sk_btns.add_theme_constant_override("separation", 10)
	page.add_child(sk_btns)
	var sk_open: = _chip_button("OPEN SKINS FOLDER", accent)
	sk_open.pressed.connect( func() -> void : Skins.open_folder())
	sk_btns.add_child(sk_open)
	var sk_reload: = _chip_button("RELOAD", accent)
	sk_reload.pressed.connect( func() -> void :
		Skins.rescan()
		Skins.apply(SettingsManager.skin_name)
		_rebuild_skin_chips(accent))
	sk_btns.add_child(sk_reload)







	_section(page, "QUALITY", accent)
	var q_row: = HBoxContainer.new()
	q_row.add_theme_constant_override("separation", 8)
	page.add_child(q_row)
	_quality_chips.clear()
	_quality_accent = accent
	for lvl in SettingsManager.QUALITY_LEVELS:
		var q: Dictionary = SettingsManager.QUALITY[lvl]
		var chip: = _chip_button(String(SettingsManager.QUALITY_LABELS[lvl]), accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_quality(String(lvl))
			_refresh_all()
			main._menu_toast("QUALITY: %s  ·  decor %d %%  ·  map backgrounds %d px" % [
				String(SettingsManager.QUALITY_LABELS[lvl]), 
				int(float(q.density) * 100.0), int(q.max_side)], 
				accent))
		q_row.add_child(chip)
		_quality_chips[lvl] = chip
	_quality_note = _hint(page, "", Color(1, 1, 1, 0.38))
	_refresh_quality_chips()

	_section(page, "PRESET", accent)
	var preset_row: = HBoxContainer.new()
	preset_row.add_theme_constant_override("separation", 10)
	page.add_child(preset_row)
	var perf: = _chip_button("PERFORMANCE MODE", accent)
	perf.pressed.connect( func() -> void :


		SettingsManager.apply_visual_preset("PERF")
		_refresh_all())
	preset_row.add_child(perf)
	var full: = _chip_button("EVERYTHING ON", accent)
	full.pressed.connect( func() -> void :
		SettingsManager.apply_visual_preset("FULL")
		_refresh_all())
	preset_row.add_child(full)

	_section(page, "DISPLAY", accent)
	var disp_row: = HBoxContainer.new()
	disp_row.add_theme_constant_override("separation", 8)
	page.add_child(disp_row)
	for mode in ["BORDERLESS", "FULLSCREEN", "WINDOWED"]:
		var chip: = _chip_button(mode, accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_display_mode(mode)
			_refresh_display_chips())
		disp_row.add_child(chip)
		_display_chips[mode] = chip


	_section(page, "WINDOW SIZE", accent)
	var res_row: = HBoxContainer.new()
	res_row.add_theme_constant_override("separation", 8)
	page.add_child(res_row)
	var scr: = DisplayServer.screen_get_size()
	for r in SettingsManager.WINDOW_SIZES:
		var res: Vector2i = r
		if res.x > scr.x or res.y > scr.y:
			continue
		var chip: = _chip_button("%dx%d" % [res.x, res.y], accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_window_res(res)
			_refresh_display_chips())
		res_row.add_child(chip)
		_res_chips[res] = chip






	_section(page, "RENDER RESOLUTION", accent)
	var rr_row: = HBoxContainer.new()
	rr_row.add_theme_constant_override("separation", 8)
	page.add_child(rr_row)
	_render_res_chips.clear()
	for v in SettingsManager.RENDER_RES:
		var val: = String(v)
		var chip: = _chip_button(String(SettingsManager.RENDER_RES_LABELS[val]), accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_render_res(val)
			_refresh_display_chips())
		rr_row.add_child(chip)
		_render_res_chips[val] = chip
	_render_res_note = _hint(page, "", Color(1, 1, 1, 0.38))



	_section(page, "FPS LIMIT", accent)
	var fps_row: = HBoxContainer.new()
	fps_row.add_theme_constant_override("separation", 8)
	page.add_child(fps_row)
	for c in SettingsManager.FPS_CAPS:
		var cap: int = c
		var chip: = _chip_button("UNLIMITED" if cap == 0 else str(cap), accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_max_fps(cap)
			_refresh_display_chips())
		fps_row.add_child(chip)
		_fps_chips[cap] = chip

	_section(page, "VSYNC", accent)
	var vs_row: = HBoxContainer.new()
	vs_row.add_theme_constant_override("separation", 8)
	page.add_child(vs_row)
	for e in [["OFF", false], ["ON", true]]:
		var on: bool = e[1]
		var chip: = _chip_button(String(e[0]), accent)
		chip.pressed.connect( func() -> void :
			SettingsManager.set_vsync(on)
			_refresh_display_chips())
		vs_row.add_child(chip)
		_vsync_chips[on] = chip


func _pct(v: float) -> String:
	return "%d %%" % roundi(v * 100.0)



func refresh_skins() -> void :
	if _skin_row != null:
		_rebuild_skin_chips(TAB_DEFS[2][1])




func _rebuild_skin_chips(accent: Color) -> void :
	for c in _skin_row.get_children():
		c.queue_free()
	var entries: = [["DEFAULT", "DEFAULT"]]
	for s in Skins.list():
		entries.append([s, Skins.label_of(s)])
	for e in entries:
		var chip: = _chip_button(e[1], accent)
		chip.add_theme_font_size_override("font_size", 12)
		chip.pressed.connect( func() -> void :
			Skins.apply(e[0])
			_paint_skin_chips())
		chip.set_meta("skin", e[0])
		_skin_row.add_child(chip)
	_paint_skin_chips()


func _paint_skin_chips() -> void :
	for chip in _skin_row.get_children():
		if chip is Button and not chip.is_queued_for_deletion():
			_paint_chip(chip, TAB_DEFS[2][1], String(chip.get_meta("skin")) == Skins.current)




func _quality_row(page: VBoxContainer, label_text: String, accent: Color, 
		key: String) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	page.add_child(row)
	var l: = Label.new()
	l.text = label_text
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	l.add_theme_font_size_override("font_size", 15)
	l.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
	row.add_child(l)
	var entry: = {"key": key, "chips": {}}
	for level in SettingsManager.GFX_LEVELS:
		var chip: = _chip_button(level, accent)
		chip.add_theme_font_size_override("font_size", 12)
		chip.pressed.connect( func() -> void :
			SettingsManager.call("set_" + key, level)
			_paint_quality(entry))
		row.add_child(chip)
		entry["chips"][level] = chip
	_quality_rows.append(entry)
	_paint_quality(entry)


func _paint_quality(entry: Dictionary) -> void :
	var cur: = str(SettingsManager.get(entry["key"]))
	for level in entry["chips"]:
		_paint_chip(entry["chips"][level], TAB_DEFS[2][1], level == cur)




func _toggle_row(page: VBoxContainer, label_text: String, accent: Color, 
		is_on: Callable, setter: Callable) -> void :
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
	var entry: = {"chip": chip, "is_on": is_on, "accent": accent}
	chip.pressed.connect( func() -> void :
		setter.call( not is_on.call())
		_paint_toggle(entry))
	row.add_child(chip)
	_toggles.append(entry)
	_paint_toggle(entry)




func _vis_row(page: VBoxContainer, label_text: String, accent: Color, key: String) -> void :
	_toggle_row(page, label_text, accent, 
		func() -> bool: return SettingsManager.vis_on(key), 
		func(v: bool) -> void : SettingsManager.set_vis(key, v))


func _paint_toggle(entry: Dictionary) -> void :
	var on: bool = entry["is_on"].call()
	var chip: Button = entry["chip"]
	chip.text = "ON" if on else "OFF"
	_paint_chip(chip, entry["accent"], on)





func _section(page: VBoxContainer, title: String, accent: Color) -> void :
	var spacer: = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	page.add_child(spacer)
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




func _bind_row(page: VBoxContainer, action: String, accent: Color) -> void :
	var row: = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	page.add_child(row)
	var t: = Label.new()
	t.text = SettingsManager.bind_label(action)
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




func _start_listen(action: String) -> void :
	_listen_action = action
	_conflict_label.visible = false
	_refresh_binds()


func _stop_listen() -> void :
	_listen_action = ""
	_conflict_label.visible = false
	_refresh_binds()




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
			var action: = _listen_action
			var res: String = SettingsManager.rebind(action, event.physical_keycode)
			if res.begins_with("!"):

				_conflict_label.text = "Fixed key: %s" % res.substr(1)
				_conflict_label.add_theme_color_override("font_color", Color(1.0, 0.42, 0.45))
				_conflict_label.visible = true
				return
			if main != null:
				main.sfx.play_ui("click")
			_stop_listen()
			if res != "":
				_show_swap(action, res)
		elif event.physical_keycode == KEY_ESCAPE:
			close()




func open() -> void :
	visible = true
	_refresh_all()
	if main != null:
		main.sfx.play_ui("whoosh")

	if _open_tw:
		_open_tw.kill()
	modulate.a = 0.0
	_panel.pivot_offset = _panel.size * 0.5
	_panel.scale = Vector2(1.04, 1.04)
	_open_tw = create_tween().set_parallel()
	_open_tw.tween_property(self, "modulate:a", 1.0, 0.18)
	_open_tw.tween_property(_panel, "scale", Vector2.ONE, 0.22)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func close() -> void :
	if not visible:
		return
	_stop_listen()
	if main != null:
		main.sfx.play_ui("back")
	if _open_tw:
		_open_tw.kill()
	_open_tw = create_tween()
	_open_tw.tween_property(self, "modulate:a", 0.0, 0.12)
	_open_tw.tween_callback( func() -> void : visible = false)




func _refresh_all() -> void :
	_set_slider(_sens_box, SettingsManager.mouse_sens)
	_set_slider(_area_w_box, SettingsManager.tablet_area_w)
	_set_slider(_area_h_box, SettingsManager.tablet_area_h)

	_set_sliders_in(_page(1), [SettingsManager.master_vol, SettingsManager.music_vol, 
		SettingsManager.hitsound_vol, float(SettingsManager.audio_offset_ms)])
	_refresh_binds()
	_refresh_device()
	_refresh_display_chips()
	if _scroll_box != null:
		_set_slider(_scroll_box, SettingsManager.scroll_speed)
	for t in _toggles:
		_paint_toggle(t)
	for q in _quality_rows:
		_paint_quality(q)
	_refresh_quality_chips()




func _refresh_quality_chips() -> void :
	if _quality_chips.is_empty():
		return
	var cur: String = SettingsManager.quality
	for lvl in _quality_chips:
		_paint_chip(_quality_chips[lvl], _quality_accent, String(lvl) == cur)
	if _quality_note != null:
		if cur == "CUSTOM":
			_quality_note.text = ("CUSTOM — you changed a switch by hand. "
				+ "Decor and internal resolution stay on %s.") % String(
				SettingsManager.QUALITY_LABELS.get(SettingsManager.quality_base, "HIGH"))
		else:
			var q: Dictionary = SettingsManager.QUALITY.get(cur, {})
			_quality_note.text = "decor %d %%  ·  map backgrounds up to %d px" % [
				int(float(q.get("density", 1.0)) * 100.0), 
				int(q.get("max_side", 1920))]


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


func _refresh_binds() -> void :
	for action in _bind_buttons:
		var b: Button = _bind_buttons[action]
		if action == _listen_action:
			b.text = LISTEN_TEXT
			_paint_chip(b, TAB_DEFS[0][1], true)
		else:
			b.text = SettingsManager.key_label(SettingsManager.bind_of(action))
			_paint_chip(b, TAB_DEFS[0][1], false)
			if _swapped.has(action):
				b.add_theme_color_override("font_color", COL_SWAP)
				b.add_theme_color_override("font_hover_color", COL_SWAP)




func _show_swap(action: String, other_label: String) -> void :
	_swapped = [action]
	for a in _bind_buttons:
		if SettingsManager.bind_label(a) == other_label:
			_swapped.append(a)
	_conflict_label.text = "Swapped: %s now uses %s" % [other_label, 
		SettingsManager.key_label(SettingsManager.bind_of(_swapped[1] if _swapped.size() > 1 else action))]
	_conflict_label.add_theme_color_override("font_color", COL_SWAP)
	_conflict_label.visible = true
	_refresh_binds()
	_swap_timer = get_tree().create_timer(2.5)
	_swap_timer.timeout.connect( func() -> void :
		_swapped.clear()
		if _listen_action == "":
			_conflict_label.visible = false
		_refresh_binds())


func _refresh_display_chips() -> void :
	for mode in _display_chips:
		_paint_chip(_display_chips[mode], TAB_DEFS[2][1], 
			mode == SettingsManager.display_mode)
	for res in _res_chips:
		_paint_chip(_res_chips[res], TAB_DEFS[2][1], res == SettingsManager.window_res)


		_res_chips[res].disabled = SettingsManager.display_mode != "WINDOWED"
		_res_chips[res].modulate = Color(1, 1, 1, 1.0 if SettingsManager.display_mode == "WINDOWED" else 0.35)
	for v in _render_res_chips:
		_paint_chip(_render_res_chips[v], TAB_DEFS[2][1], v == SettingsManager.render_res)
	if _render_res_note != null:
		var eff: String = "1280x720 upscaled" if SettingsManager.render_720_effective()\
		else "native (%dx%d)" % [DisplayServer.window_get_size().x, 
			DisplayServer.window_get_size().y]
		_render_res_note.text = "currently rendering at %s" % eff
	for cap in _fps_chips:
		_paint_chip(_fps_chips[cap], TAB_DEFS[2][1], cap == SettingsManager.max_fps)
	for on in _vsync_chips:
		_paint_chip(_vsync_chips[on], TAB_DEFS[2][1], on == SettingsManager.vsync)


func _refresh_device() -> void :
	var dev: String = SettingsManager.input_device
	for dname in _device_chips:
		_paint_chip(_device_chips[dname], TAB_DEFS[0][1], dname == dev)
	_sens_box.visible = dev == "MOUSE"
	_area_w_box.visible = dev == "TABLET"
	_area_h_box.visible = dev == "TABLET"
	if dev == "MOUSE":
		_device_hint.text = "RELATIVE aim: in game, the cursor moves by (motion × sensitivity).\nNo surface loss — real sensitivity, not a shrunken screen."
	else:
		_device_hint.text = "ABSOLUTE aim: the central area of the tablet covers the whole screen.\nShrink the area for shorter flicks. Applies IN GAME only (menus stay 1:1) —\nstart any map to feel it, the mint frame shows your zone."


func _preview_hitsound() -> void :

	if main == null:
		return
	var now: = Time.get_ticks_msec() / 1000.0
	if now - _sfx_preview_at > 0.18:
		_sfx_preview_at = now
		main.sfx.play_sfx("parry_perfect")


func _set_tab(i: int) -> void :
	_current_tab = i
	if _listen_action != "":
		_stop_listen()
	for j in TAB_DEFS.size():
		var accent: Color = TAB_DEFS[j][1]
		var active: = j == i
		_tab_pages[j].visible = active
		var b: Button = _tab_buttons[j]
		b.add_theme_color_override("font_color", 
			accent if active else Color(1, 1, 1, 0.42))
		b.add_theme_color_override("font_hover_color", 
			accent if active else Color(1, 1, 1, 0.75))
		var lst: StyleBoxFlat = _tab_underlines[j].get_theme_stylebox("panel")
		lst.bg_color = Color(accent.r, accent.g, accent.b, 1.0 if active else 0.0)


func _process(_delta: float) -> void :
	if not visible:
		return

	if _listen_action != "":
		var b: Button = _bind_buttons[_listen_action]
		b.modulate.a = 0.75 + 0.25 * sin(Time.get_ticks_msec() / 120.0)
	else:
		for action in _bind_buttons:
			_bind_buttons[action].modulate.a = 1.0



	if _debug_label != null and main != null and _tab_pages[0].visible:
		var aim: Vector2 = main.aim_position()
		var map_s: = "off (menus are 1:1)"
		if main.aim_is_mapped():
			map_s = "ACTIVE ×%.1f/%.1f" % [1.0 / SettingsManager.tablet_area_w, 
				1.0 / SettingsManager.tablet_area_h]
		elif SettingsManager.input_device == "MOUSE":
			map_s = "n/a (mouse)"
		_debug_label.text = """debug — OS: %d, %d  ·  event %s ×%d  ·  aim: %d, %d
device %s  ·  zone %d%%×%d%%  ·  mapping %s  ·  v%s""" %[main._poll_last.x, main._poll_last.y, main._event_kind, 
			main._event_count, aim.x, aim.y, 
			SettingsManager.input_device, 
			roundi(SettingsManager.tablet_area_w * 100.0), 
			roundi(SettingsManager.tablet_area_h * 100.0), 
			map_s, Telemetry.game_version()]




func _font_display() -> Font:
	return main.font_display if main != null else null


func _font_bold() -> Font:
	return main.font_bold if main != null else null
