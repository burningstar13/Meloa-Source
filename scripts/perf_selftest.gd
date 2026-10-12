extends Node


















const CHARTS: = [
	["chart facile", "res://charts/ravenatic_easy.json", 20.0], 
	["chart dense", "res://charts/galaxy_impossible.json", 60.0], 
	["visees jaunes", "res://charts/freedomdive_impossible.json", 100.0], 
	["chore lourde", "res://charts/bookmaker_corrupt.json", 40.0], 
]
const SECS: = 20.0

var main: Node = null
var _lines: Array = []


static func requested() -> bool:
	for a in OS.get_cmdline_args():
		if String(a).begins_with("--perf-report"):
			return true
	return false


static func forced_quality() -> String:
	for a in OS.get_cmdline_args():
		var s: = String(a)
		if s.begins_with("--quality="):
			return s.substr(10).to_upper()
	return ""


func _ready() -> void :
	_run()


func _say(line: String) -> void :
	_lines.append(line)
	print(line)



func _measure(label: String) -> void :
	var dt: = PackedFloat32Array()
	var t0: = Time.get_ticks_usec()

	while (Time.get_ticks_usec() - t0) / 1000000.0 < 1.0:
		await get_tree().process_frame
	var last: = Time.get_ticks_usec()
	t0 = last
	var dc: = 0
	while (Time.get_ticks_usec() - t0) / 1000000.0 < SECS:
		await get_tree().process_frame
		var now: = Time.get_ticks_usec()
		dt.append((now - last) / 1000.0)
		last = now
		dc = maxi(dc, int(RenderingServer.get_rendering_info(
			RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)))
	var a: = Array(dt)
	a.sort()
	if a.is_empty():
		return
	var sum: = 0.0
	for v in a:
		sum += v
	var med: float = a[a.size() / 2]
	var hitch: = 0
	for v in a:
		if v > maxf(med * 2.0, 20.0):
			hitch += 1
	_say("%-16s fps moyen %4.0f | ms p50 %5.2f  p95 %5.2f  p99 %5.2f  pire %6.1f | hoquets %3d | draw calls %4d | vram %4.0f Mo" % [
		label, 1000.0 / maxf(sum / a.size(), 0.001), med, 
		a[int(a.size() * 0.95)], a[int(a.size() * 0.99)], a[a.size() - 1], 
		hitch, dc, 
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0])


func _run() -> void :
	await get_tree().process_frame
	var boot: = Time.get_ticks_msec()
	var q: = forced_quality()
	if q != "" and SettingsManager.QUALITY.has(q):

		SettingsManager.quality_base = q
		SettingsManager.quality = q
		for key in SettingsManager.VISUAL_FLAGS:
			var k: = String(key)
			if not k.begins_with("hud_"):
				SettingsManager.vis[k] = not (
					SettingsManager.QUALITY_OFF.get(q, []) as Array).has(k)
		SettingsManager.fx_fire = bool(SettingsManager.vis.get("fx_fire", true))
		SettingsManager.gfx_map_bg = bool(SettingsManager.vis.get("bg_map", true))
		SettingsManager.gfx_eq = bool(SettingsManager.vis.get("bg_eq", true))
		SettingsManager._sync_engine_from_vis()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var vp: = get_tree().root.get_viewport_rid()
	RenderingServer.viewport_set_measure_render_time(vp, true)
	_say("=== MELOA — auto-test de performance ===")
	_say("date        : %s" % Time.get_datetime_string_from_system())
	_say("version     : %s" % ProjectSettings.get_setting("application/config/version", "?"))
	_say("carte       : %s (%s)" % [RenderingServer.get_video_adapter_name(), 
		RenderingServer.get_video_adapter_vendor()])
	_say("rendu       : %s / %s" % [
		RenderingServer.get_current_rendering_driver_name(), 
		ProjectSettings.get_setting("rendering/renderer/rendering_method", "?")])
	_say("fenetre     : %dx%d   ecran %dx%d @ %.0f Hz" % [
		DisplayServer.window_get_size().x, DisplayServer.window_get_size().y, 
		DisplayServer.screen_get_size().x, DisplayServer.screen_get_size().y, 
		DisplayServer.screen_get_refresh_rate()])
	_say("processeur  : %s (%d coeurs)" % [OS.get_processor_name(), OS.get_processor_count()])
	_say("qualite     : %s (decor %d %%, rendu %s)" % [
		SettingsManager.quality, int(SettingsManager.quality_density() * 100.0), 
		"1280x720" if SettingsManager.render_720_effective() else "natif"])
	_say("demarrage   : %d ms jusqu'au menu" % boot)
	_say("")

	await get_tree().create_timer(1.5).timeout
	await _measure("menu accueil")

	for c in CHARTS:
		main.tuning.chart_path = String(c[1])
		main._load_chart()
		main.screen = main.Screen.PLAYING
		main.menu_root.visible = false
		main.world.visible = true
		main.hud_root.visible = true
		main._toggle_auto(true)
		main._toggle_invincible(true)
		AudioServer.set_bus_mute(0, true)
		main.start_game(float(c[2]))
		while main._pre_roll:
			await get_tree().process_frame
		await _measure(String(c[0]))
	_say("")


	var ram: = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	_say("memoire     : %s (RAM) / %.0f Mo (video)" % [
		("%.0f Mo" % ram) if ram > 1.0 else "non mesuree (build release)", 
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0])
	_say("")
	_say("CE QUI COMPTE : p99 sous 16,7 ms = 60 images/s tenues.")
	_say("Un p50 bas avec des hoquets reste un mauvais resultat.")
	var f: = FileAccess.open("user://perf_report.txt", FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(_lines) + "\n")
		f.close()
		print("-> rapport ecrit dans : ", 
			ProjectSettings.globalize_path("user://perf_report.txt"))
	get_tree().quit(0)
