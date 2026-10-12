extends Control
















const BPM: = 120.0
const SPB: = 60.0 / BPM
const TOTAL_BEATS: = 64
const LEAD_BEATS: = 4
const TAPS_NEEDED: = 16
const BAR_RANGE_MS: = 150.0
const PERFECT_MS: = 25.0
const ACCENT: = Color(0.72, 0.45, 1.0)
const MINT: = Color(0.3, 1.0, 0.85)
const GOLD: = Color(1.0, 0.78, 0.25)
const RED: = Color(1.0, 0.35, 0.4)

enum State{IDLE, TAPPING, DONE}

var settings

var state: int = State.IDLE
var _player: AudioStreamPlayer
var _latency: = 0.0
var _taps: Array[float] = []
var _tap_marks: Array = []
var _last_tap_wall: = 0
var _last_delta: = NAN
var _result: = {}

var _panel: PanelContainer
var _subtitle: Label
var _visual: Control
var _delta_label: Label
var _stats_label: Label
var _progress_label: Label
var _btn_start: Button
var _btn_cancel: Button
var _btn_accept: Button
var _btn_redo: Button
var _btn_back: Button
var _open_tw: Tween


func _ready() -> void :
	visible = false



	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)




	var veil: = ColorRect.new()
	veil.color = Color(0.01, 0.014, 0.03, 0.94)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.gui_input.connect( func(e: InputEvent) -> void :
		if e is InputEventMouseButton and e.pressed\
		and e.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			_tap())
	add_child(veil)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(720, 560)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var pst: = StyleBoxFlat.new()
	pst.bg_color = Color(0.055, 0.065, 0.105, 0.97)
	pst.border_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.3)
	pst.set_border_width_all(1)
	pst.set_corner_radius_all(18)
	pst.shadow_color = Color(ACCENT.r, ACCENT.g, ACCENT.b, 0.1)
	pst.shadow_size = 38
	pst.content_margin_left = 36
	pst.content_margin_right = 36
	pst.content_margin_top = 26
	pst.content_margin_bottom = 28
	_panel.add_theme_stylebox_override("panel", pst)

	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_panel)

	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(col)

	var title: = Label.new()
	title.text = "CALIBRATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	if _font_display() != null:
		title.add_theme_font_override("font", _font_display())
	title.add_theme_color_override("font_color", ACCENT)
	col.add_child(title)

	_subtitle = Label.new()
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_subtitle.add_theme_font_size_override("font_size", 14)
	_subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	col.add_child(_subtitle)

	_visual = BeatVisual.new()
	_visual.cal = self
	_visual.custom_minimum_size = Vector2(0, 230)
	_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(_visual)

	_delta_label = Label.new()
	_delta_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_delta_label.add_theme_font_size_override("font_size", 40)
	if _font_display() != null:
		_delta_label.add_theme_font_override("font", _font_display())
	col.add_child(_delta_label)

	_stats_label = Label.new()
	_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_stats_label.add_theme_font_size_override("font_size", 15)
	_stats_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	col.add_child(_stats_label)

	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress_label.add_theme_font_size_override("font_size", 14)
	_progress_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	col.add_child(_progress_label)

	var spacer: = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(spacer)


	var btn_row: = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	col.add_child(btn_row)
	_btn_start = _button(btn_row, "START  ·  ENTER", _start)
	_btn_cancel = _button(btn_row, "CANCEL  ·  ESC", _cancel)
	_btn_accept = _button(btn_row, "ACCEPT", _accept)
	_btn_redo = _button(btn_row, "REDO  ·  R", _restart)
	_btn_back = _button(btn_row, "BACK", close)

	_player = AudioStreamPlayer.new()


	add_child(_player)
	_player.finished.connect( func() -> void :
		if state == State.TAPPING:
			_player.play()
	)


func _button(parent: Control, text: String, handler: Callable) -> Button:
	var b: Button = settings._chip_button(text, ACCENT)
	b.pressed.connect( func() -> void :
		if _main() != null:
			_main().sfx.play_ui("click")
		handler.call())
	parent.add_child(b)
	return b







func _make_metronome() -> AudioStreamWAV:
	var rate: = 44100
	var frames: = int(rate * SPB * TOTAL_BEATS)
	var data: = PackedByteArray()
	data.resize(frames * 2)
	var click_len: = int(rate * 0.05)
	for b in TOTAL_BEATS:
		var freq: = 2600.0 if b % 4 == 0 else 1800.0
		var start: = int(rate * SPB * b)
		for i in click_len:
			var t: = float(i) / rate
			var v: = int(clampf(sin(TAU * freq * t) * exp( - t / 0.012), -1.0, 1.0)\
			* 0.85 * 32767.0)
			var idx: = (start + i) * 2
			data[idx] = v & 255
			data[idx + 1] = (v >> 8) & 255
	var wav: = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav




func _song_time() -> float:
	return _player.get_playback_position()\
	+ AudioServer.get_time_since_last_mix() - _latency




func open() -> void :
	if _player.stream == null:
		_player.stream = _make_metronome()
	visible = true
	_reset_to_idle()


	SettingsManager.set_music_duck(0.08)
	if _open_tw:
		_open_tw.kill()
	modulate.a = 0.0
	_open_tw = create_tween()
	_open_tw.tween_property(self, "modulate:a", 1.0, 0.15)
	if _main() != null:
		_main().sfx.play_ui("whoosh")


func close() -> void :
	if not visible:
		return
	_player.stop()
	state = State.IDLE
	SettingsManager.set_music_duck(1.0)
	if _main() != null:
		_main().sfx.play_ui("back")
	if _open_tw:
		_open_tw.kill()
	_open_tw = create_tween()
	_open_tw.tween_property(self, "modulate:a", 0.0, 0.12)
	_open_tw.tween_callback( func() -> void : visible = false)


func _reset_to_idle() -> void :
	_player.stop()
	state = State.IDLE
	_taps.clear()
	_tap_marks.clear()
	_last_delta = NAN
	_result = {}
	_apply_state()


func _start() -> void :
	_taps.clear()
	_tap_marks.clear()
	_last_delta = NAN
	_result = {}
	state = State.TAPPING
	_latency = AudioServer.get_output_latency()
	_player.play()
	_apply_state()


func _cancel() -> void :
	_reset_to_idle()


func _restart() -> void :
	_start()


func _finish() -> void :
	_player.stop()
	_result = _compute(_taps)
	state = State.DONE
	if _main() != null:
		_main().sfx.play_ui("impact")
	_apply_state()




func _accept() -> void :
	if _result.is_empty():
		return
	SettingsManager.set_audio_offset_ms(roundi( - _result.median))
	if settings != null:
		settings._refresh_all()
	close()



func _apply_state() -> void :
	_btn_start.visible = state == State.IDLE
	_btn_cancel.visible = state == State.TAPPING
	_btn_accept.visible = state == State.DONE
	_btn_redo.visible = state == State.DONE
	_btn_back.visible = state != State.TAPPING
	match state:
		State.IDLE:
			_subtitle.text = """A metronome plays at 120 BPM. Tap %s for %d beats:
the median of your offsets (outliers excluded) becomes the audio offset.""" %[_keys_hint(), TAPS_NEEDED]
			_delta_label.text = ""
			_stats_label.text = "Current offset: %+d ms" % SettingsManager.audio_offset_ms
			_progress_label.text = ""
		State.TAPPING:
			_subtitle.text = "Tap %s right on every click." % _keys_hint()
			_delta_label.text = ""
			_stats_label.text = ""
			_progress_label.text = ""
		State.DONE:
			var m: float = _result.median
			var verdict: = "late" if m > 0.0 else "early"
			_subtitle.text = "Result over %d kept taps (%d outlier%s discarded)."\
			%[_result.kept, _result.rejected, 
				"s" if _result.rejected > 1 else ""]
			_delta_label.text = "%+d ms" % roundi( - m)
			_delta_label.add_theme_color_override("font_color", 
				_delta_color(absf(m)) * 1.2)
			_stats_label.text = """You tap %.0f ms %s on median (spread ±%.0f ms).
Proposed offset: %+d ms  (current: %+d ms)""" %[absf(m), verdict, _result.std, roundi( - m), 
				SettingsManager.audio_offset_ms]
			_progress_label.text = ""
			_btn_accept.text = "ACCEPT %+d ms  ·  ENTER" % roundi( - m)




func _tap() -> void :
	if state != State.TAPPING:
		return
	var now: = Time.get_ticks_msec()
	if now - _last_tap_wall < 150:
		return
	_last_tap_wall = now
	var t: = _song_time()

	if t < (LEAD_BEATS - 0.5) * SPB:
		return
	var d: = (t - roundf(t / SPB) * SPB) * 1000.0
	_last_delta = d
	_taps.append(d)
	_tap_marks.append({"d": d, "t": now})
	if _tap_marks.size() > 24:
		_tap_marks.pop_front()
	if _taps.size() >= TAPS_NEEDED:
		_finish()





func _compute(taps: Array[float]) -> Dictionary:
	var mean: = 0.0
	for d in taps:
		mean += d
	mean /= taps.size()
	var var_sum: = 0.0
	for d in taps:
		var_sum += (d - mean) * (d - mean)
	var std: = sqrt(var_sum / taps.size())
	var kept: Array[float] = []
	for d in taps:
		if std < 0.001 or absf(d - mean) <= 2.0 * std:
			kept.append(d)
	kept.sort()
	var n: = kept.size()
	var median: float = kept[n / 2] if n % 2 == 1\
	else (kept[n / 2 - 1] + kept[n / 2]) * 0.5
	var kmean: = 0.0
	for d in kept:
		kmean += d
	kmean /= n
	var kvar: = 0.0
	for d in kept:
		kvar += (d - kmean) * (d - kmean)
	return {"median": median, "kept": n, "rejected": taps.size() - n, 
		"std": sqrt(kvar / n)}



func _live_median() -> float:
	var s: = _taps.duplicate()
	s.sort()
	var n: = s.size()
	return s[n / 2] if n % 2 == 1 else (s[n / 2 - 1] + s[n / 2]) * 0.5


func _delta_color(abs_ms: float) -> Color:
	if abs_ms <= PERFECT_MS:
		return MINT
	if abs_ms <= 60.0:
		return GOLD
	return RED


func _keys_hint() -> String:
	return "%s / %s (or click)" % [
		SettingsManager.key_label(SettingsManager.binds["hit_primary"]), 
		SettingsManager.key_label(SettingsManager.binds["hit_secondary"])]




func _unhandled_input(event: InputEvent) -> void :
	if not visible:
		return

	if event.is_action_pressed("hit_primary") or event.is_action_pressed("hit_secondary"):
		get_viewport().set_input_as_handled()
		_tap()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		if event.is_action_pressed("retry"):
			if state == State.DONE:
				_restart()
			return
		match event.physical_keycode:
			KEY_ESCAPE:
				if state == State.TAPPING:
					_cancel()
				else:
					close()
			KEY_ENTER, KEY_KP_ENTER:
				if state == State.IDLE:
					_start()
				elif state == State.DONE:
					_accept()


func _process(_delta: float) -> void :
	if not visible or state != State.TAPPING:
		return

	var t: = _song_time()
	if t < (LEAD_BEATS - 0.5) * SPB:
		_progress_label.text = "listen to the beat…"
		return
	_progress_label.text = "%d / %d" % [_taps.size(), TAPS_NEEDED]
	if is_nan(_last_delta):
		_delta_label.text = "—"
		_delta_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.3))
		_stats_label.text = ""
		return
	_delta_label.text = "%+.0f ms" % _last_delta
	_delta_label.add_theme_color_override("font_color", 
		_delta_color(absf(_last_delta)) * 1.25)
	var mean: = 0.0
	for d in _taps:
		mean += d
	mean /= _taps.size()
	_stats_label.text = "mean %+.0f ms   ·   median %+.0f ms"\
	%[mean, _live_median()]


func _main():
	return settings.main if settings != null else null


func _font_display() -> Font:
	return _main().font_display if _main() != null else null






class BeatVisual:
	extends Control
	var cal

	func _process(_delta: float) -> void :
		if cal != null and cal.visible:
			queue_redraw()

	func _draw() -> void :
		var c: = Vector2(size.x * 0.5, size.y * 0.5 - 26.0)
		var accent: Color = cal.ACCENT
		var pulse: = 0.0
		var lead: = false
		if cal._player.playing:
			var t: float = cal._song_time()
			pulse = exp( - fposmod(t, cal.SPB) / cal.SPB * 6.0)
			lead = t < (cal.LEAD_BEATS - 0.5) * cal.SPB

		var r: = 46.0 + 12.0 * pulse
		draw_circle(c, r * 0.55, 
			Color(accent.r, accent.g, accent.b, 0.1 + 0.25 * pulse))
		draw_arc(c, r, 0.0, TAU, 56, 
			Color(accent.r * (1.0 + 0.5 * pulse), accent.g * (1.0 + 0.5 * pulse), 
			accent.b * (1.0 + 0.5 * pulse), 0.9), 3.0)
		if pulse > 0.5:
			draw_arc(c, r + 10.0 * (1.0 - pulse), 0.0, TAU, 56, 
				Color(1.3, 1.3, 1.35, (pulse - 0.5) * 0.8), 2.0)
		if lead:
			return

		var bar_y: = c.y + 86.0
		var half: = minf(size.x * 0.4, 270.0)
		var perfect_w: float = half * (cal.PERFECT_MS / cal.BAR_RANGE_MS)
		draw_rect(Rect2(c.x - perfect_w, bar_y - 9, perfect_w * 2.0, 18), 
			Color(cal.MINT.r, cal.MINT.g, cal.MINT.b, 0.1))
		draw_line(Vector2(c.x - half, bar_y), Vector2(c.x + half, bar_y), 
			Color(1, 1, 1, 0.16), 2.0)
		draw_line(Vector2(c.x, bar_y - 11), Vector2(c.x, bar_y + 11), 
			Color(1, 1, 1, 0.55), 2.0)
		var now: = Time.get_ticks_msec()
		for m in cal._tap_marks:
			var age: float = (now - m.t) / 3000.0
			if age >= 1.0:
				continue
			var frac: float = clampf(m.d / cal.BAR_RANGE_MS, -1.0, 1.0)
			var col: Color = cal._delta_color(absf(m.d))
			col.a = (1.0 - age) * 0.9
			var x: float = c.x + frac * half
			draw_line(Vector2(x, bar_y - 8), Vector2(x, bar_y + 8), col, 2.0)
