extends Node














const APP_ID: = 1545598893746819173

const LARGE_IMAGE: = "meloa"
const POLL_SEC: = 1.0

var _rpc: Object
var _last_key: = ""


var _session_since: = 0
var _poll: = 0.0


func _ready() -> void :
	if not enabled_here():
		return
	_rpc = Engine.get_singleton("DiscordRPC")
	_rpc.app_id = APP_ID
	_rpc.large_image = LARGE_IMAGE
	_rpc.large_image_text = "Meloa"
	_session_since = int(Time.get_unix_time_from_system())
	SettingsManager.settings_changed.connect(_on_setting)




static func enabled_here() -> bool:
	return APP_ID != 0 and Engine.has_singleton("DiscordRPC")\
	and DisplayServer.get_name() != "headless"


func _process(delta: float) -> void :
	if _rpc == null:
		return
	_rpc.run_callbacks()
	_poll += delta
	if _poll < POLL_SEC:
		return
	_poll = 0.0
	if not SettingsManager.discord_presence:
		if _last_key != "":
			_rpc.clear()
			_last_key = ""
		return
	var p: = compose(_snapshot())
	var key: = "%s|%s|%d" % [p.details, p.state, int(p.start)]
	if key == _last_key:
		return
	_rpc.details = p.details
	_rpc.state = p.state
	_rpc.start_timestamp = int(p.start)
	_rpc.refresh()
	_last_key = key


func _on_setting(k: String) -> void :
	if k == "discord_presence" and _rpc != null and not SettingsManager.discord_presence:
		_rpc.clear()
		_last_key = ""




func _snapshot() -> Dictionary:
	var main = get_tree().current_scene
	if main == null or not ("screen" in main):
		return {}
	var s: = {
		"screen": int(main.screen), 
		"home": int(main.Screen.HOME), "select": int(main.Screen.SELECT), 
		"playing": int(main.Screen.PLAYING), "editor": int(main.Screen.EDITOR), 


		"track": String(main.track_title(main.tuning.current_track)), 
		"diff": String(main.tuning.current_diff).to_upper(), 
		"mode": Mods.mode_name(), 
		"paused": bool(main.game_paused), 
		"over": bool(main.game_over), 
		"done": bool(main.track_done), 
		"playtest": float(main.playtest_from) >= 0.0, 
		"tutorial": bool(main.tutorial_active), 
	}
	s["since"] = _session_since
	return s



static func compose(s: Dictionary) -> Dictionary:
	var since: int = int(s.get("since", 0))
	if s.is_empty():
		return {"details": "In the menus", "state": "", "start": since}
	var screen: int = s.get("screen", -1)
	var mode: String = String(s.get("mode", "FLOW")).to_upper()
	if screen == s.get("editor", -2) or bool(s.get("playtest", false)):
		return {"details": "Mapping %s" % _title(s), "state": "In the editor", "start": since}
	if screen == s.get("playing", -2):
		if bool(s.get("tutorial", false)):
			return {"details": "Learning the ropes", "state": "Tutorial", "start": since}
		var details: = "%s  ·  %s" % [_title(s), String(s.get("diff", ""))]
		var state: = "Playing %s" % mode
		if bool(s.get("over", false)):
			state = "Game over  ·  %s" % mode
		elif bool(s.get("done", false)):
			state = "Results  ·  %s" % mode
		elif bool(s.get("paused", false)):
			state = "Paused  ·  %s" % mode
		return {"details": details, "state": state, "start": since}
	if screen == s.get("select", -2):
		return {"details": "Picking a map", "state": "%s mode" % mode, "start": since}
	return {"details": "In the menus", "state": "Main menu", "start": since}


static func _title(s: Dictionary) -> String:
	var t: = String(s.get("track", ""))
	return t if t != "" else "a map"
