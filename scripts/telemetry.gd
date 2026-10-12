extends Node















signal key_checked(valid: bool)


const BASE_URL_DEFAULT: = "https://rythm-game-backend-production.up.railway.app/v1"
const KEY_FILE: = "user://playtest_key.txt"

var difficulty: = "impossible"

const FLUSH_INTERVAL: = 15.0
const BATCH_MAX: = 50
const BUFFER_CAP: = 400










const PRESENCE_INTERVAL: = 25.0




const PRESENCE_GIVE_UP: = 3

var enabled: = false
var tester_id: = ""

var _base_url: = BASE_URL_DEFAULT
var _key: = ""
var _session_id: = ""
var _session_t0_ms: = 0
var _buffer: Array = []
var _inflight: Array = []
var _busy: = false
var _quitting: = false

var _http: HTTPRequest



var device_id: = ""


signal _claim_settled
var _claim_state: = ""
var _claim_result: = {}


var _map_active: = false
var _map_id: = ""
var _retries: = 0
var _judge: = {}
var _attempt_dead: = false
var _flag_auto: = false
var _flag_invin: = false
var _map_wall_t0_ms: = 0


var _presence_http: HTTPRequest
var _presence_busy: = false
var _presence_fails: = 0
var _presence_off: = false
var _in_editor: = false


func _ready() -> void :

	get_tree().auto_accept_quit = false
	_session_id = Crypto.new().generate_random_bytes(16).hex_encode()
	_session_t0_ms = Time.get_ticks_msec()

	_http = HTTPRequest.new()
	_http.timeout = 10.0
	_http.request_completed.connect(_on_batch_completed)
	add_child(_http)
	device_id = _load_device_id()

	var timer: = Timer.new()
	timer.wait_time = FLUSH_INTERVAL
	timer.timeout.connect(_flush)
	add_child(timer)
	timer.start()

	_base_url = _read_override("--backend-url=", "RYTHM_BACKEND_URL", "")
	if _base_url == "":
		_base_url = BASE_URL_DEFAULT





	_presence_http = HTTPRequest.new()
	_presence_http.timeout = 8.0
	_presence_http.request_completed.connect(_on_presence_completed)
	add_child(_presence_http)
	var beat: = Timer.new()
	beat.wait_time = PRESENCE_INTERVAL
	beat.timeout.connect(_presence_ping)
	add_child(beat)
	beat.start()
	_presence_ping()

	_key = _read_override("--playtest-key=", "RYTHM_PLAYTEST_KEY", KEY_FILE)
	if _key == "":




		if OS.has_feature("playtest")\
		or OS.get_cmdline_user_args().has("--force-gate"):
			print("[telemetry] pas de clé de playtest — en attente du gate d'accès")
		else:
			print("[telemetry] désactivée (build sans playtest)")
		key_checked.emit(false)
		return



	_push({"type": "SESSION_START"})
	_boot_claim()


func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()



func base_url() -> String:
	return _base_url



func game_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))




func version_check() -> Dictionary:
	return await _api(HTTPClient.METHOD_POST, "/version/check", 
		{"version": game_version(), "platform": OS.get_name()})


func has_key() -> bool:
	return _key != ""



func current_judgements() -> Dictionary:
	return _judge.duplicate()











func set_in_editor(on: bool) -> void :
	if _in_editor == on:
		return
	_in_editor = on
	_presence_ping()



func presence_state() -> String:
	if _in_editor:
		return "editor"
	return "playing" if _map_active else "menu"


func _presence_ping() -> void :




	if _presence_http == null or _presence_off or _presence_busy\
	or _base_url == "" or _quitting:
		return
	var body: = {"state": presence_state()}
	if _map_active and _map_id != "":
		body["mapId"] = _map_id
		body["difficulty"] = difficulty
	var err: = _presence_http.request(_base_url + "/presence/ping", _headers(), 
		HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		return
	_presence_busy = true





func _presence_bye() -> void :
	if _presence_off or _base_url == "" or device_id == "":
		return
	var http: = HTTPRequest.new()
	http.timeout = 2.0
	add_child(http)
	http.request_completed.connect(
		func(_r, _c, _h, _b) -> void : http.queue_free())
	if http.request(_base_url + "/presence/bye", _headers(), 
			HTTPClient.METHOD_POST, "{}") != OK:
		http.queue_free()


func _on_presence_completed(result: int, code: int, _h: PackedStringArray, 
		_b: PackedByteArray) -> void :
	_presence_busy = false
	if result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300:
		_presence_fails = 0
		return




	if code == 404 or code == 426:
		_presence_fails += 1
		if _presence_fails >= PRESENCE_GIVE_UP:
			_presence_off = true
			print("[telemetry] présence indisponible (%d) — heartbeat arrêté" % code)





func map_started(map_id: String, diff: String = "impossible") -> void :
	difficulty = diff
	_map_active = true
	_map_id = map_id
	_retries = 0
	_judge = {}
	_attempt_dead = false
	_flag_auto = false
	_flag_invin = false
	_map_wall_t0_ms = Time.get_ticks_msec()
	_push({
		"type": "MAP_STARTED", 
		"mapId": map_id, 
		"difficulty": difficulty, 
		"inputMode": SettingsManager.input_device, 
		"calibrationOffsetMs": float(SettingsManager.audio_offset_ms), 
	})
	_presence_ping()



func map_retried() -> void :







	if not _map_active:
		_judge = {}
		if _map_id == "":
			return
		_map_active = true
	_retries += 1
	_judge = {}
	_attempt_dead = false
	_flag_auto = false
	_flag_invin = false
	_map_wall_t0_ms = Time.get_ticks_msec()
	_push({"type": "RETRY", "mapId": _map_id, "difficulty": difficulty})



func note_judged(kind: String) -> void :
	_judge[kind] = int(_judge.get(kind, 0)) + 1




func note_flags(auto_on: bool, invin_on: bool) -> void :
	if not _map_active:
		return
	_flag_auto = _flag_auto or auto_on
	_flag_invin = _flag_invin or invin_on


func map_completed(accuracy_pct: float, max_combo: int) -> void :
	if not _map_active:
		return
	_map_active = false
	_push({
		"type": "MAP_COMPLETED", 
		"mapId": _map_id, 
		"difficulty": difficulty, 
		"accuracy": clampf(accuracy_pct, 0.0, 100.0), 
		"maxCombo": max_combo, 
		"judgements": _judge.duplicate(), 
		"autoMode": _flag_auto, 
		"invincible": _flag_invin, 
	})





func map_failed(at_sec: float) -> void :
	if not _map_active or _attempt_dead:
		return
	_attempt_dead = true
	_push({
		"type": "MAP_FAILED", 
		"mapId": _map_id, 
		"difficulty": difficulty, 
		"abandonAtSec": maxf(at_sec, 0.0), 
		"retriesBeforeAbandon": _retries, 
		"autoMode": _flag_auto, 
		"invincible": _flag_invin, 
	})








func map_closed() -> void :
	_map_active = false
	_map_id = ""
	_judge = {}
	_presence_ping()


func map_abandoned(at_sec: float) -> void :
	if not _map_active:
		return
	_map_active = false
	if _attempt_dead:
		return
	var at: = at_sec
	if at < 0.0:
		at = float(Time.get_ticks_msec() - _map_wall_t0_ms) / 1000.0
	_push({
		"type": "MAP_ABANDONED", 
		"mapId": _map_id, 
		"difficulty": difficulty, 
		"abandonAtSec": at, 
		"retriesBeforeAbandon": _retries, 
		"autoMode": _flag_auto, 
		"invincible": _flag_invin, 
	})



func quit_game() -> void :
	if _quitting:
		return
	_quitting = true
	_presence_bye()
	if _key != "":
		map_abandoned(-1.0)
		_push({
			"type": "SESSION_END", 
			"durationSec": float(Time.get_ticks_msec() - _session_t0_ms) / 1000.0, 
		})

		var deadline: = Time.get_ticks_msec() + 2500
		while enabled and (_buffer.size() + _inflight.size()) > 0\
		and Time.get_ticks_msec() < deadline:
			if not _busy:
				_flush()
			await get_tree().process_frame
	get_tree().quit()






func playtest_status() -> Dictionary:
	return await _api(HTTPClient.METHOD_GET, "/playtest/status")





func ensure_claimed() -> Dictionary:
	if _key == "":
		return {"ok": false, "code": 0, "data": null}
	if _claim_state == "ok":
		return _claim_result
	if _claim_state == "pending":
		await _claim_settled
		return _claim_result
	_claim_state = "pending"
	var r: = await _api(HTTPClient.METHOD_POST, "/playtest/claim", 
		{"deviceId": device_id})
	_claim_result = r
	if r.ok:
		_claim_state = "ok"
		if r.data is Dictionary:
			tester_id = str(r.data.get("testerId", ""))
		if not enabled:
			enabled = true
			print("[telemetry] clé validée, envoi actif")
			key_checked.emit(true)
			_flush()
	else:
		_claim_state = ""
		if r.code == 401 or r.code == 403:
			print("[telemetry] clé refusée (%d) — télémétrie désactivée" % r.code)
			enabled = false
			key_checked.emit(false)
	_claim_settled.emit()
	return _claim_result



func claim_new_key(raw: String) -> Dictionary:
	var had_key: = _key != ""
	_key = raw.strip_edges()
	_claim_state = ""
	var r: = await ensure_claimed()
	if r.ok:
		var f: = FileAccess.open(KEY_FILE, FileAccess.WRITE)
		if f != null:
			f.store_string(_key)
		if not had_key:
			_push({"type": "SESSION_START"})
			_flush()
	return r




func _boot_claim() -> void :
	var r: = await ensure_claimed()
	while r.code == 0 and not _quitting:
		await get_tree().create_timer(30.0).timeout
		r = await ensure_claimed()






func _api(method: int, path: String, body: Variant = null) -> Dictionary:
	var http: = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var body_s: = "" if body == null else JSON.stringify(body)
	var err: = http.request(_base_url + path, _headers(), method, body_s)
	if err != OK:
		http.queue_free()
		return {"ok": false, "code": 0, "data": null}
	var res: Array = await http.request_completed
	http.queue_free()
	var code: int = res[1]
	var data: Variant = null
	var bytes: PackedByteArray = res[3]
	if bytes.size() > 0:
		data = JSON.parse_string(bytes.get_string_from_utf8())
	return {"ok": code >= 200 and code < 300, "code": code, "data": data}


func _push(event: Dictionary) -> void :
	if _key == "":
		return
	event["sessionId"] = _session_id
	event["clientTs"] = Time.get_datetime_string_from_system(true) + "Z"
	_buffer.append(event)
	while _buffer.size() > BUFFER_CAP:
		_buffer.pop_front()


func _flush() -> void :
	if not enabled or _busy or _buffer.is_empty():
		return
	_busy = true
	_inflight = _buffer.slice(0, BATCH_MAX)
	_buffer = _buffer.slice(_inflight.size())
	var body: = JSON.stringify({"events": _inflight})
	var err: = _http.request(
		_base_url + "/telemetry/events", _headers(), HTTPClient.METHOD_POST, body)
	if err != OK:
		_requeue_inflight()
		_busy = false


func _on_batch_completed(result: int, code: int, _h: PackedStringArray, 
		_b: PackedByteArray) -> void :
	_busy = false
	if result == HTTPRequest.RESULT_SUCCESS and code == 202:
		_inflight.clear()
		if not _buffer.is_empty() and not _quitting:
			_flush()
	elif code == 401:

		print("[telemetry] clé révoquée — télémétrie désactivée")
		enabled = false
		_inflight.clear()
		_buffer.clear()
	else:
		_requeue_inflight()


func _requeue_inflight() -> void :
	_inflight.append_array(_buffer)
	_buffer = _inflight
	_inflight = []


func _headers() -> PackedStringArray:
	var h: = PackedStringArray([
		"content-type: application/json", 
		"x-device-id: " + device_id, 
		"x-client-version: " + game_version(), 
	])



	if _key != "":
		h.append("x-playtest-key: " + _key)
	return h






func _load_device_id() -> String:
	var sys: = OS.get_unique_id()
	if sys != "":
		return sys
	var path: = "user://device_id.txt"
	if FileAccess.file_exists(path):
		var f: = FileAccess.open(path, FileAccess.READ)
		if f != null:
			var v: = f.get_as_text().strip_edges()
			if v != "":
				return v
	var generated: = Crypto.new().generate_random_bytes(16).hex_encode()
	var w: = FileAccess.open(path, FileAccess.WRITE)
	if w != null:
		w.store_string(generated)
	return generated


func _read_override(cli_prefix: String, env_name: String, file_path: String) -> String:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with(cli_prefix):
			return arg.trim_prefix(cli_prefix).strip_edges()
	var env: = OS.get_environment(env_name)
	if env != "":
		return env.strip_edges()
	if file_path != "" and FileAccess.file_exists(file_path):
		var f: = FileAccess.open(file_path, FileAccess.READ)
		if f != null:
			return f.get_as_text().strip_edges()
	return ""
