extends Node







signal settings_changed(key: String)

const PATH: = "user://settings.cfg"


const ACTIONS: = ["hit_primary", "hit_secondary"]
const ACTION_LABELS: = {
	"hit_primary": "Primary hit", 
	"hit_secondary": "Secondary hit", 
}
const DEFAULT_BINDS: = {"hit_primary": KEY_X, "hit_secondary": KEY_C}






const MANIA_ACTIONS: = ["mania_lane_0", "mania_lane_1", "mania_lane_2"]
const MANIA_LABELS: = {
	"mania_lane_0": "GRID lane 1 (left)", 
	"mania_lane_1": "GRID lane 2 (middle)", 
	"mania_lane_2": "GRID lane 3 (right)", 
}
const MANIA_DEFAULTS: = {
	"mania_lane_0": KEY_Z, "mania_lane_1": KEY_X, "mania_lane_2": KEY_C, 
}







const EXTRA_ACTIONS: = ["retry", "pause_menu", "pause_settings", "hud_toggle", 
	"offset_minus", "offset_plus", 
	"nav_up", "nav_down", "nav_left", "nav_right", "open_editor"]
const EXTRA_LABELS: = {
	"retry": "Retry (hold during a run)", 
	"pause_menu": "Pause: back to menu", 
	"pause_settings": "Pause: open settings", 
	"hud_toggle": "Hide / show the HUD", 
	"offset_minus": "Audio offset -10 ms", 
	"offset_plus": "Audio offset +10 ms", 
	"nav_up": "Map list: previous map", 
	"nav_down": "Map list: next map", 
	"nav_left": "Map list: previous difficulty", 
	"nav_right": "Map list: next difficulty", 
	"open_editor": "Open the editor on the selected map", 
}
const EXTRA_DEFAULTS: = {
	"retry": KEY_R, "pause_menu": KEY_M, "pause_settings": KEY_S, "hud_toggle": KEY_F1, 
	"offset_minus": KEY_O, "offset_plus": KEY_P, 
	"nav_up": KEY_UP, "nav_down": KEY_DOWN, "nav_left": KEY_LEFT, "nav_right": KEY_RIGHT, 
	"open_editor": KEY_E, 
}

const BIND_GROUPS: = [
	["FLOW — hit keys", ACTIONS], 
	["GRID — one key per lane", MANIA_ACTIONS], 
	["IN-GAME", ["retry", "pause_menu", "pause_settings", "hud_toggle", "offset_minus", "offset_plus"]], 
	["MENUS", ["nav_up", "nav_down", "nav_left", "nav_right", "open_editor"]], 
]




const RESERVED_KEYS: = {
	KEY_ESCAPE: "Esc (back / cancel)", 
	KEY_ENTER: "Enter (confirm)", 
	KEY_KP_ENTER: "Enter (confirm)", 
	KEY_SPACE: "Space (results screen)", 
	KEY_TAB: "Tab (results screen)", 
}


var binds: = {"hit_primary": KEY_X, "hit_secondary": KEY_C}

var mania_binds: = {"mania_lane_0": KEY_Z, "mania_lane_1": KEY_X, "mania_lane_2": KEY_C}

var extra_binds: = EXTRA_DEFAULTS.duplicate()




var game_mode: = "STANDARD"
var mods: Array = []
var input_device: = "MOUSE"
var mouse_sens: = 1.0
var tablet_area_w: = 1.0
var tablet_area_h: = 1.0
var click_hits: = true
var discord_presence: = true
var fx_fire: = true
var fx_judge_text: = true
var scroll_speed: = 1.0
var display_mode: = "BORDERLESS"
var window_res: = Vector2i(1280, 720)
var max_fps: = 0
var vsync: = false

const WINDOW_SIZES: = [Vector2i(1280, 720), Vector2i(1600, 900), 
	Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]

const FPS_CAPS: = [0, 60, 120, 144, 165, 240, 360]
var master_vol: = 1.0
var music_vol: = 1.0
var hitsound_vol: = 1.0
var audio_offset_ms: = 0
var shake_intensity: = 1.0
var note_fx_intensity: = 1.0



var menu_fx_intensity: = 1.0

var menu_intro: = true
var sfx_pack: = "OSU"


var skin_name: = "DEFAULT"



var onboarding_done: = false





var gl_perf_done: = false





















const QUALITY_LEVELS: = ["VERYLOW", "LOW", "MID", "HIGH"]
const QUALITY_LABELS: = {
	"VERYLOW": "VERY LOW", "LOW": "LOW", "MID": "MEDIUM", "HIGH": "HIGH", 
}




const QUALITY: = {
	"VERYLOW": {"density": 0.15, "max_side": 854}, 
	"LOW": {"density": 0.35, "max_side": 1280}, 
	"MID": {"density": 0.65, "max_side": 1600}, 
	"HIGH": {"density": 1.0, "max_side": 1920}, 
}




const BASE_RES: = Vector2i(1280, 720)


const QUALITY_OFF: = {
	"VERYLOW": ["fx_glitch", "fx_zoom", "fx_shockwave", "fx_shake_click", 
		"fx_shake_miss", "fx_shake_events", "fx_skin_anims", "fx_fire", 
		"bg_eq", "bg_patterns", "bg_particles", "menu_beat_fx", "fx_mascots"], 
	"LOW": ["fx_glitch", "fx_zoom", "fx_shake_click", "fx_shake_events", 
		"bg_particles", "fx_skin_anims"], 
	"MID": [], 
	"HIGH": [], 
}



var quality: = "HIGH"
var quality_base: = "HIGH"





func quality_density() -> float:
	return float(QUALITY[quality_base].get("density", 1.0))




func qn(full_count: int) -> int:
	return maxi(int(float(full_count) * quality_density()), 0)




















const RENDER_RES: = ["NATIVE", "720P"]
const RENDER_RES_LABELS: = {"NATIVE": "NATIVE", "720P": "1280x720"}


var render_res: = "NATIVE"



func render_720_effective() -> bool:
	return render_res == "720P"


func set_render_res(v: String) -> void :
	if not RENDER_RES.has(v):
		return
	render_res = v
	apply_render_scale()
	settings_changed.emit("render_res")
	_touch("render_res")


func quality_max_side() -> int:
	return int(QUALITY[quality_base].get("max_side", 1920))






static var _owned: Array = []


static func quality_owned() -> Array:
	if _owned.is_empty():
		var seen: = {}
		for lvl in QUALITY_OFF:
			for k in QUALITY_OFF[lvl]:
				seen[String(k)] = true
		_owned = seen.keys()
	return _owned




func set_quality(level: String) -> void :
	if not QUALITY.has(level):
		return
	quality = level
	quality_base = level
	var off: Array = QUALITY_OFF.get(level, [])






	for k in quality_owned():
		var on: = not off.has(k)
		if vis_on(k) != on:
			set_vis(k, on)
	_sync_engine_from_vis()
	apply_render_scale()
	settings_changed.emit("quality")
	_touch("quality")




func mark_quality_custom() -> void :
	if quality != "CUSTOM":
		quality = "CUSTOM"
		_touch("quality")


















var _in_render_scale: = false


func apply_render_scale() -> void :



	if _in_render_scale:
		return
	var tree: = Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	_in_render_scale = true
	_apply_render_scale_now(tree.root as Window)
	_in_render_scale = false








func _restore_project_stretch(win: Window) -> void :
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	win.content_scale_size = BASE_RES


func _apply_render_scale_now(win: Window) -> void :
	if not render_720_effective():
		_restore_project_stretch(win)
		return
	var wsz: = DisplayServer.window_get_size()
	if wsz.x <= BASE_RES.x and wsz.y <= BASE_RES.y:


		_restore_project_stretch(win)
		return
	win.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	win.content_scale_size = BASE_RES







const GFX_LEVELS: = ["OFF", "LOW", "MID", "FULL"]
var gfx_click: = "FULL"
var gfx_slider: = "FULL"
var gfx_burst: = "FULL"
var gfx_anim_bg: = "FULL"
var gfx_map_bg: = true
var gfx_eq: = true












const VISUAL_FLAGS: = {

	"hud_score": true, "hud_score_delta": true, "hud_combo": true, "hud_hp": true, 
	"hud_accuracy": true, "hud_time": true, "hud_judge": true, "hud_timing": true, 
	"hud_mods": true, 


	"hud_fps": false, 

	"fx_hit_glow": true, "fx_click_pop": true, "fx_glitch": true, "fx_burst": true, 
	"fx_shockwave": true, "fx_zoom": true, "fx_float_text": true, "fx_line_flash": true, 
	"fx_slider_glow": true, "fx_fire": true, "fx_mascots": true, "fx_skin_anims": true, 

	"fx_shake_click": true, "fx_shake_miss": true, "fx_shake_events": true, 

	"bg_map": true, "bg_eq": true, "bg_patterns": true, "bg_particles": true, 

	"menu_beat_fx": true, "menu_intro": true, 
}
var vis: = {}


func vis_on(key: String) -> bool:
	match key:
		"hud_judge": return fx_judge_text
		"fx_fire": return fx_fire
		"bg_map": return gfx_map_bg
		"bg_eq": return gfx_eq
		"menu_intro": return menu_intro
	return bool(vis.get(key, VISUAL_FLAGS.get(key, true)))


func set_vis(key: String, on: bool) -> void :
	match key:
		"hud_judge": set_fx_judge_text(on);return
		"fx_fire": set_fx_fire(on);return
		"bg_map": set_gfx_map_bg(on);return
		"bg_eq": set_gfx_eq(on);return
		"menu_intro": set_menu_intro(on);return
	vis[key] = on
	_sync_engine_from_vis()
	mark_quality_custom()
	_touch("vis_" + key)



func _sync_engine_from_vis() -> void :
	gfx_click = "FULL" if vis_on("fx_hit_glow") else "OFF"
	gfx_slider = "FULL" if vis_on("fx_slider_glow") else "OFF"
	gfx_burst = "FULL"
	gfx_anim_bg = "FULL" if (vis_on("bg_patterns") or vis_on("bg_particles")) else "OFF"
	menu_fx_intensity = 1.0 if vis_on("menu_beat_fx") else 0.0
	note_fx_intensity = 1.0
	shake_intensity = 1.0




func apply_visual_preset(which: String) -> void :
	var full: = which != "PERF"
	for key in VISUAL_FLAGS:
		var k: = String(key)
		var on: = full
		if k == "hud_fps":
			continue
		if k.begins_with("hud_") or k.begins_with("menu_"):
			on = true
		if vis_on(k) != on:
			set_vis(k, on)
	_sync_engine_from_vis()
	_touch("vis_preset")















const GPU_APIS: = ["d3d12", "vulkan", "opengl3"]
const GPU_API_LABELS: = {
	"d3d12": "D3D12", "vulkan": "VULKAN", "opengl3": "OPENGL 3", 
}


const GPU_OVERRIDE_KEYS: = ["renderer/rendering_method", 
	"rendering_device/driver.windows", "gl_compatibility/driver.windows"]


static func gpu_api_method(api: String) -> String:
	return "gl_compatibility" if api == "opengl3" else "forward_plus"




static func gpu_api_current() -> String:
	var d: = RenderingServer.get_current_rendering_driver_name()
	return "opengl3" if d.begins_with("opengl3") else d



static func gpu_is_compat() -> bool:
	return gpu_api_current() == "opengl3"


static func gpu_adapter_name() -> String:
	return RenderingServer.get_video_adapter_name()

static func gpu_is_software() -> bool:
	var n: = gpu_adapter_name().to_lower()
	return n.contains("basic render") or n.contains("warp") or n.contains("llvmpipe")\
	or n.contains("software")

static func _override_path() -> String:
	return OS.get_executable_path().get_base_dir().path_join("override.cfg")



static func gpu_api_requested() -> String:
	var cf: = ConfigFile.new()
	if cf.load(_override_path()) != OK:
		return ""
	var method: = str(cf.get_value("rendering", "renderer/rendering_method", ""))
	if method == "gl_compatibility":
		return str(cf.get_value("rendering", "gl_compatibility/driver.windows", "opengl3"))
	return str(cf.get_value("rendering", "rendering_device/driver.windows", ""))




static func set_gpu_api(api: String) -> bool:
	if OS.has_feature("editor"):
		return false
	var path: = _override_path()
	var cf: = ConfigFile.new()
	cf.load(path)
	for key in GPU_OVERRIDE_KEYS:
		if cf.has_section_key("rendering", key):
			cf.erase_section_key("rendering", key)
	if api != "":
		cf.set_value("rendering", "renderer/rendering_method", gpu_api_method(api))
		if api == "opengl3":
			cf.set_value("rendering", "gl_compatibility/driver.windows", "opengl3")
		else:
			cf.set_value("rendering", "rendering_device/driver.windows", api)
	return cf.save(path) == OK





static func gpu_api_restart_args(api: String) -> PackedStringArray:
	if api == "":
		return PackedStringArray()
	var driver: = "opengl3" if api == "opengl3" else api
	return PackedStringArray(["--rendering-method", gpu_api_method(api), 
		"--rendering-driver", driver])




static func gfx_k(level: String) -> float:
	match level:
		"OFF":
			return 0.0
		"LOW":
			return 0.35
		"MID":
			return 0.65
	return 1.0




var favorites: Array = []
var recent_maps: Array = []
const RECENT_MAX: = 40


var best_score: = 0
var best_combo: = 0
var map_records: = {}



var _save_timer: Timer


func _ready() -> void :

	process_mode = Node.PROCESS_MODE_ALWAYS
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.timeout.connect(_write_file)
	add_child(_save_timer)
	_setup_buses()
	_load_file()
	_apply_binds()
	_apply_volumes()
	_gl_compat_first_run()
	_quality_first_run()







func _gl_compat_first_run() -> void :
	if gl_perf_done or not gpu_is_compat():
		return
	gl_perf_done = true
	apply_visual_preset("PERF")
	push_warning("Rendu OpenGL 3 (compatibilité) — preset PERFORMANCE appliqué une fois")
	_queue_save()













func detect_quality() -> String:
	if gpu_is_software():
		return "VERYLOW"
	var cores: = OS.get_processor_count()
	var atype: = RenderingServer.get_video_adapter_type()
	if atype == RenderingDevice.DEVICE_TYPE_CPU\
	or atype == RenderingDevice.DEVICE_TYPE_VIRTUAL_GPU:
		return "VERYLOW"
	if atype == RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU or gpu_is_compat():


		return "VERYLOW" if cores <= 4 else "LOW"
	return "MID" if cores <= 4 else "HIGH"




var quality_auto_applied: = ""
var quality_auto_done: = false


func _quality_first_run() -> void :
	if quality_auto_done:
		return
	quality_auto_done = true
	var want: = detect_quality()


	if want == "HIGH" or quality != "HIGH":
		_queue_save()
		return
	set_quality(want)
	quality_auto_applied = want
	_queue_save()



func _exit_tree() -> void :
	if _save_timer != null and not _save_timer.is_stopped():
		_write_file()







func _setup_buses() -> void :
	for bus_name in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			var i: = AudioServer.bus_count
			AudioServer.add_bus(i)
			AudioServer.set_bus_name(i, bus_name)
			AudioServer.set_bus_send(i, "Master")





var music_duck: = 1.0

func set_music_duck(f: float) -> void :
	music_duck = clampf(f, 0.0, 1.0)
	_apply_volumes()


func _apply_volumes() -> void :
	_set_bus_linear(0, master_vol)
	_set_bus_linear(AudioServer.get_bus_index("Music"), music_vol * music_duck)
	_set_bus_linear(AudioServer.get_bus_index("SFX"), hitsound_vol)



func _set_bus_linear(idx: int, v: float) -> void :
	AudioServer.set_bus_mute(idx, v <= 0.001)
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(v, 0.001)))







func _apply_binds() -> void :
	for action in ACTIONS:
		_bind_action(action, int(binds[action]))
	for action in MANIA_ACTIONS:
		_bind_action(action, int(mania_binds[action]))
	for action in EXTRA_ACTIONS:
		_bind_action(action, int(extra_binds[action]))


func _bind_action(action: String, keycode: int) -> void :
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	InputMap.action_erase_events(action)
	var ev: = InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action, ev)




func bind_conflict(action: String, keycode: Key) -> String:
	if RESERVED_KEYS.has(keycode):
		return RESERVED_KEYS[keycode]




	var other: = _bind_clash(action, keycode)
	return bind_label(other) if other != "" else ""



func _bind_clash(action: String, keycode: Key) -> String:
	var mania: = MANIA_ACTIONS.has(action)
	var pool: Array = (MANIA_ACTIONS if mania else ACTIONS) + EXTRA_ACTIONS
	if EXTRA_ACTIONS.has(action):
		pool = ACTIONS + MANIA_ACTIONS + EXTRA_ACTIONS
	for other in pool:
		if other != action and bind_of(other) == keycode:
			return other
	return ""


func set_bind(action: String, keycode: Key) -> void :
	if MANIA_ACTIONS.has(action):
		mania_binds[action] = keycode
	elif EXTRA_ACTIONS.has(action):
		extra_binds[action] = keycode
	else:
		binds[action] = keycode
	_apply_binds()
	_touch("bind_" + action)






func rebind(action: String, keycode: Key) -> String:
	if RESERVED_KEYS.has(keycode):
		return "!" + String(RESERVED_KEYS[keycode])
	var other: = _bind_clash(action, keycode)
	var old: = bind_of(action)
	set_bind(action, keycode)
	if other != "":
		set_bind(other, old)
		return bind_label(other)
	return ""



func reset_binds() -> void :
	binds = DEFAULT_BINDS.duplicate()
	mania_binds = MANIA_DEFAULTS.duplicate()
	extra_binds = {}
	for action in EXTRA_ACTIONS:
		extra_binds[action] = extra_default(action)
	_apply_binds()
	_touch("bind_reset")






func extra_default(action: String) -> int:
	var kc: = int(EXTRA_DEFAULTS[action])
	if kc < KEY_A or kc > KEY_Z or DisplayServer.get_name() == "headless":
		return kc
	for phys in range(KEY_A, KEY_Z + 1):
		if DisplayServer.keyboard_get_keycode_from_physical(phys) == kc:
			return phys
	for phys in [KEY_COMMA, KEY_SEMICOLON, KEY_PERIOD, KEY_SLASH, KEY_APOSTROPHE]:
		if DisplayServer.keyboard_get_keycode_from_physical(phys) == kc:
			return phys
	return kc



func bind_label(action: String) -> String:
	return String(ACTION_LABELS.get(action, MANIA_LABELS.get(action, EXTRA_LABELS.get(action, action))))



func bind_of(action: String) -> int:
	return int(mania_binds.get(action, extra_binds.get(action, binds.get(action, KEY_NONE))))




func set_game_mode(m: String) -> void :
	game_mode = m
	_touch("game_mode")


func set_mods(list: Array) -> void :
	mods = list.duplicate()
	_touch("mods")





const SESSION_ONLY_MODS: = ["auto", "invincible"]

static func _persistable_mods(list: Array) -> Array:
	var out: Array = []
	for m in list:
		if not (String(m) in SESSION_ONLY_MODS):
			out.append(m)
	return out




func key_label(keycode: Key) -> String:
	var visible: = keycode

	if DisplayServer.get_name() != "headless":
		var mapped: = DisplayServer.keyboard_get_keycode_from_physical(keycode)
		if mapped != KEY_NONE:
			visible = mapped
	var s: = OS.get_keycode_string(visible)
	return s if s != "" else "?"




func set_input_device(dev: String) -> void :
	input_device = dev
	_touch("input_device")


func set_mouse_sens(v: float) -> void :
	mouse_sens = clampf(v, 0.1, 4.0)
	_touch("mouse_sens")


func set_tablet_area_w(v: float) -> void :
	tablet_area_w = clampf(v, 0.2, 1.0)
	_touch("tablet_area_w")


func set_tablet_area_h(v: float) -> void :
	tablet_area_h = clampf(v, 0.2, 1.0)
	_touch("tablet_area_h")


func set_click_hits(v: bool) -> void :
	click_hits = v
	_touch("click_hits")


func set_discord_presence(v: bool) -> void :
	discord_presence = v
	_touch("discord_presence")


func set_fx_fire(v: bool) -> void :
	fx_fire = v
	_touch("fx_fire")


func set_fx_judge_text(v: bool) -> void :
	fx_judge_text = v
	_touch("fx_judge_text")


func is_favorite(track: String) -> bool:
	return favorites.has(track)


func toggle_favorite(track: String) -> void :
	if favorites.has(track):
		favorites.erase(track)
	else:
		favorites.append(track)
	_touch("favorites")



func push_recent(track: String) -> void :
	recent_maps.erase(track)
	recent_maps.push_front(track)
	while recent_maps.size() > RECENT_MAX:
		recent_maps.pop_back()
	_touch("recent_maps")


func set_menu_fx_intensity(v: float) -> void :
	menu_fx_intensity = clampf(v, 0.0, 1.0)
	_touch("menu_fx_intensity")


func set_menu_intro(v: bool) -> void :
	menu_intro = v
	_touch("menu_intro")


func set_onboarding_done(v: bool) -> void :
	onboarding_done = v
	_touch("onboarding_done")


func set_scroll_speed(v: float) -> void :
	scroll_speed = clampf(v, 0.5, 1.5)
	_touch("scroll_speed")


func set_display_mode(m: String) -> void :
	display_mode = m
	_apply_display()


	apply_render_scale.call_deferred()
	_touch("display_mode")





func _apply_display() -> void :
	match display_mode:
		"FULLSCREEN":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		"WINDOWED":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var scr: = DisplayServer.screen_get_size()


			var res: = Vector2i(mini(window_res.x, scr.x), mini(window_res.y, scr.y))
			DisplayServer.window_set_size(res)
			DisplayServer.window_set_position(Vector2i((scr.x - res.x) / 2, (scr.y - res.y) / 2))
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func set_window_res(r: Vector2i) -> void :
	window_res = r
	if display_mode == "WINDOWED":
		_apply_display()
		apply_render_scale.call_deferred()
	_touch("window_res")



func set_max_fps(v: int) -> void :
	max_fps = maxi(v, 0)
	_apply_fps()
	_touch("max_fps")


func _apply_fps() -> void :
	Engine.max_fps = max_fps


func set_vsync(on: bool) -> void :
	vsync = on
	_apply_vsync()
	_touch("vsync")


func _apply_vsync() -> void :
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync
		else DisplayServer.VSYNC_DISABLED)


func set_master_vol(v: float) -> void :
	master_vol = clampf(v, 0.0, 1.0)
	_apply_volumes()
	_touch("master_vol")


func set_music_vol(v: float) -> void :
	music_vol = clampf(v, 0.0, 1.0)
	_apply_volumes()
	_touch("music_vol")


func set_hitsound_vol(v: float) -> void :
	hitsound_vol = clampf(v, 0.0, 1.0)
	_apply_volumes()
	_touch("hitsound_vol")


func set_audio_offset_ms(v: int) -> void :
	audio_offset_ms = clampi(v, -200, 200)
	_touch("audio_offset_ms")


func set_shake_intensity(v: float) -> void :
	shake_intensity = clampf(v, 0.0, 1.0)
	_touch("shake_intensity")


func set_note_fx_intensity(v: float) -> void :
	note_fx_intensity = clampf(v, 0.0, 1.0)
	_touch("note_fx_intensity")


func set_sfx_pack(p: String) -> void :
	sfx_pack = p
	_touch("sfx_pack")


func set_skin_name(s: String) -> void :
	skin_name = s
	_touch("skin_name")


func _set_gfx_level(key: String, v: String) -> void :
	if not GFX_LEVELS.has(v):
		return
	set(key, v)
	_touch(key)


func set_gfx_click(v: String) -> void : _set_gfx_level("gfx_click", v)
func set_gfx_slider(v: String) -> void : _set_gfx_level("gfx_slider", v)
func set_gfx_burst(v: String) -> void : _set_gfx_level("gfx_burst", v)
func set_gfx_anim_bg(v: String) -> void : _set_gfx_level("gfx_anim_bg", v)


func set_gfx_map_bg(v: bool) -> void :
	gfx_map_bg = v
	_touch("gfx_map_bg")


func set_gfx_eq(v: bool) -> void :
	gfx_eq = v
	_touch("gfx_eq")




func save_records(score: int, combo: int, maps: Dictionary) -> void :
	best_score = score
	best_combo = combo
	map_records = maps.duplicate()
	_queue_save()








static var no_persist: = false


func _touch(key: String) -> void :
	settings_changed.emit(key)
	if no_persist:
		return
	_queue_save()




func _queue_save() -> void :
	_save_timer.start(0.4)





func _load_file() -> void :
	var cf: = ConfigFile.new()
	if cf.load(PATH) != OK:



		if FileAccess.file_exists(PATH + ".tmp") and cf.load(PATH + ".tmp") == OK:
			push_warning("settings : repris depuis la sauvegarde interrompue")
		else:
			return
	for action in ACTIONS:
		binds[action] = int(cf.get_value("keys", action, DEFAULT_BINDS[action]))
	for action in MANIA_ACTIONS:
		mania_binds[action] = int(cf.get_value("keys", action, MANIA_DEFAULTS[action]))
	for action in EXTRA_ACTIONS:
		extra_binds[action] = int(cf.get_value("keys", action, extra_default(action)))





	game_mode = "STANDARD"
	mods = _persistable_mods(Array(cf.get_value("gameplay", "mods", [])))
	input_device = cf.get_value("input", "device", "MOUSE")

	input_device = {"SOURIS": "MOUSE", "TABLETTE": "TABLET"}.get(input_device, input_device)
	mouse_sens = clampf(cf.get_value("input", "mouse_sens", 1.0), 0.1, 4.0)
	tablet_area_w = clampf(cf.get_value("input", "tablet_area_w", 1.0), 0.2, 1.0)
	tablet_area_h = clampf(cf.get_value("input", "tablet_area_h", 1.0), 0.2, 1.0)
	click_hits = bool(cf.get_value("input", "click_hits", true))


	discord_presence = true
	fx_fire = bool(cf.get_value("visual", "fx_fire", true))
	fx_judge_text = bool(cf.get_value("visual", "fx_judge_text", true))
	scroll_speed = clampf(cf.get_value("gameplay", "scroll_speed", 1.0), 0.5, 1.5)
	display_mode = str(cf.get_value("visual", "display_mode", "BORDERLESS"))
	var wr: Variant = cf.get_value("visual", "window_res", Vector2i(1280, 720))
	window_res = wr if wr is Vector2i else Vector2i(1280, 720)
	if window_res.x < 640 or window_res.y < 360:
		window_res = Vector2i(1280, 720)
	render_res = str(cf.get_value("visual", "render_res", "NATIVE"))
	if not RENDER_RES.has(render_res):
		render_res = "NATIVE"
	if display_mode != "BORDERLESS":

		_apply_display.call_deferred()
	max_fps = clampi(int(cf.get_value("visual", "max_fps", 0)), 0, 1000)
	vsync = bool(cf.get_value("visual", "vsync", false))
	if max_fps != 0:
		_apply_fps.call_deferred()
	if vsync:
		_apply_vsync.call_deferred()
	master_vol = clampf(cf.get_value("audio", "master_vol", 1.0), 0.0, 1.0)
	music_vol = clampf(cf.get_value("audio", "music_vol", 1.0), 0.0, 1.0)

	hitsound_vol = clampf(cf.get_value("audio", "hitsound_vol", 
		cf.get_value("audio", "sfx_vol", 1.0)), 0.0, 1.0)
	audio_offset_ms = clampi(int(cf.get_value("audio", "offset_ms", 0)), -200, 200)

	sfx_pack = cf.get_value("audio", "sfx_pack", "OSU")
	if not Sfx.PACKS.has(sfx_pack):
		sfx_pack = "OSU"
	skin_name = str(cf.get_value("visual", "skin", "DEFAULT"))
	menu_intro = bool(cf.get_value("visual", "menu_intro", true))
	onboarding_done = bool(cf.get_value("meta", "onboarding_done", false))
	gl_perf_done = bool(cf.get_value("meta", "gl_perf_done", false))
	quality_auto_done = bool(cf.get_value("meta", "quality_auto_done", false))
	quality = str(cf.get_value("graphics", "quality", "HIGH"))
	quality_base = str(cf.get_value("graphics", "quality_base", "HIGH"))
	if not QUALITY.has(quality_base):
		quality_base = "HIGH"
	gfx_map_bg = bool(cf.get_value("graphics", "gfx_map_bg", true))
	gfx_eq = bool(cf.get_value("graphics", "gfx_eq", true))




	vis = VISUAL_FLAGS.duplicate()
	var old_click: = str(cf.get_value("graphics", "gfx_click", "FULL"))
	var old_slider: = str(cf.get_value("graphics", "gfx_slider", "FULL"))
	var old_bg: = str(cf.get_value("graphics", "gfx_anim_bg", "FULL"))
	vis["fx_hit_glow"] = not (old_click in ["LOW", "OFF"])
	vis["fx_slider_glow"] = not (old_slider in ["LOW", "OFF"])
	vis["bg_patterns"] = old_bg != "OFF"
	vis["bg_particles"] = old_bg != "OFF"
	vis["menu_beat_fx"] = float(cf.get_value("visual", "menu_fx_intensity", 1.0)) > 0.05
	for key in VISUAL_FLAGS:
		vis[key] = bool(cf.get_value("visuals", String(key), vis[key]))


	vis["menu_beat_fx"] = true
	menu_intro = true
	_sync_engine_from_vis()
	favorites = Array(cf.get_value("library", "favorites", []))
	recent_maps = Array(cf.get_value("library", "recent", []))
	best_score = cf.get_value("records", "best_score", 0)
	best_combo = cf.get_value("records", "best_combo", 0)
	if cf.has_section("maps"):
		for key in cf.get_section_keys("maps"):
			map_records[key] = cf.get_value("maps", key)


func _write_file() -> void :
	if no_persist:
		return
	_save_timer.stop()
	var cf: = ConfigFile.new()
	for action in ACTIONS:
		cf.set_value("keys", action, int(binds[action]))
	for action in MANIA_ACTIONS:
		cf.set_value("keys", action, int(mania_binds[action]))
	for action in EXTRA_ACTIONS:
		cf.set_value("keys", action, int(extra_binds[action]))

	cf.set_value("gameplay", "mods", _persistable_mods(mods))
	cf.set_value("input", "device", input_device)
	cf.set_value("input", "mouse_sens", mouse_sens)
	cf.set_value("input", "tablet_area_w", tablet_area_w)
	cf.set_value("input", "tablet_area_h", tablet_area_h)
	cf.set_value("input", "click_hits", click_hits)
	cf.set_value("social", "discord_presence", discord_presence)
	cf.set_value("visual", "fx_fire", fx_fire)
	cf.set_value("visual", "fx_judge_text", fx_judge_text)
	cf.set_value("gameplay", "scroll_speed", scroll_speed)
	cf.set_value("visual", "display_mode", display_mode)
	cf.set_value("visual", "window_res", window_res)
	cf.set_value("visual", "render_res", render_res)
	cf.set_value("visual", "max_fps", max_fps)
	cf.set_value("visual", "vsync", vsync)
	cf.set_value("audio", "master_vol", master_vol)
	cf.set_value("audio", "music_vol", music_vol)
	cf.set_value("audio", "hitsound_vol", hitsound_vol)
	cf.set_value("audio", "offset_ms", audio_offset_ms)
	cf.set_value("audio", "sfx_pack", sfx_pack)
	cf.set_value("visual", "skin", skin_name)
	cf.set_value("visual", "menu_intro", menu_intro)
	cf.set_value("meta", "onboarding_done", onboarding_done)
	cf.set_value("meta", "gl_perf_done", gl_perf_done)
	cf.set_value("meta", "quality_auto_done", quality_auto_done)
	for key in VISUAL_FLAGS:
		cf.set_value("visuals", String(key), vis_on(String(key)))
	cf.set_value("graphics", "quality", quality)
	cf.set_value("graphics", "quality_base", quality_base)
	cf.set_value("graphics", "gfx_map_bg", gfx_map_bg)
	cf.set_value("graphics", "gfx_eq", gfx_eq)
	cf.set_value("library", "favorites", favorites)
	cf.set_value("library", "recent", recent_maps)
	cf.set_value("records", "best_score", best_score)
	cf.set_value("records", "best_combo", best_combo)
	for key in map_records:
		cf.set_value("maps", key, map_records[key])



	if cf.save(PATH + ".tmp") != OK:
		push_warning("settings : écriture impossible (" + PATH + ")")
		return
	if DirAccess.rename_absolute(PATH + ".tmp", PATH) != OK:
		DirAccess.remove_absolute(PATH + ".tmp")
		push_warning("settings : remplacement impossible (" + PATH + ")")





const VOLUME_WHEEL_STEP: = 0.05
var _vol_hud: CanvasLayer
var _vol_hud_label: Label
var _vol_hud_bar: ColorRect
var _vol_hud_tw: Tween






func _input(event: InputEvent) -> void :
	var mb: = event as InputEventMouseButton
	if mb == null or not mb.pressed or not mb.alt_pressed:
		return
	var step: = 0.0
	if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
		step = VOLUME_WHEEL_STEP
	elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		step = - VOLUME_WHEEL_STEP
	else:
		return
	set_master_vol(snappedf(master_vol + step, 0.01))
	get_viewport().set_input_as_handled()
	_show_volume_hud()




func _show_volume_hud() -> void :
	if _vol_hud == null:
		_vol_hud = CanvasLayer.new()
		_vol_hud.layer = 200
		_vol_hud.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(_vol_hud)
		var panel: = PanelContainer.new()
		var sb: = StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.05, 0.08, 0.86)
		sb.set_corner_radius_all(10)
		sb.set_content_margin_all(12.0)
		sb.content_margin_left = 18.0
		sb.content_margin_right = 18.0
		panel.add_theme_stylebox_override("panel", sb)
		panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
		panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
		panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
		panel.position.y -= 56.0
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_vol_hud.add_child(panel)
		var box: = VBoxContainer.new()
		box.add_theme_constant_override("separation", 8)
		panel.add_child(box)
		_vol_hud_label = Label.new()
		_vol_hud_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_vol_hud_label.add_theme_font_size_override("font_size", 18)
		_vol_hud_label.add_theme_color_override("font_color", Color(0.92, 0.95, 1.0))
		box.add_child(_vol_hud_label)
		var track: = ColorRect.new()
		track.color = Color(1, 1, 1, 0.12)
		track.custom_minimum_size = Vector2(220.0, 6.0)
		box.add_child(track)
		_vol_hud_bar = ColorRect.new()
		_vol_hud_bar.color = Color(0.3, 1.0, 0.85)
		_vol_hud_bar.position = Vector2.ZERO
		track.add_child(_vol_hud_bar)
	_vol_hud_label.text = "VOLUME  %d %%" % roundi(master_vol * 100.0)
	_vol_hud_bar.size = Vector2(220.0 * master_vol, 6.0)
	_vol_hud.visible = true
	var panel: Control = _vol_hud.get_child(0)
	panel.modulate.a = 1.0
	if _vol_hud_tw != null and _vol_hud_tw.is_valid():
		_vol_hud_tw.kill()
	_vol_hud_tw = create_tween()
	_vol_hud_tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_vol_hud_tw.tween_interval(0.9)
	_vol_hud_tw.tween_property(panel, "modulate:a", 0.0, 0.25)
	_vol_hud_tw.tween_callback( func() -> void : _vol_hud.visible = false)
