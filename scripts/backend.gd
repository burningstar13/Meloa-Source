extends Node











signal auth_changed(logged: bool, username: String)

const SESSION_FILE: = "user://session.cfg"

var username: = ""
var user_id: = ""




var role: = "USER"
var _access: = ""
var _refresh: = ""



signal _session_settled
var _session_checked: = false


func _ready() -> void :
	_load_session()
	if _refresh != "":
		_auto_login()
	else:
		_session_checked = true




func wait_session() -> bool:
	if not _session_checked:
		await _session_settled
	return is_logged_in()


func is_logged_in() -> bool:
	return _access != ""



func is_mod() -> bool:
	return is_logged_in() and role == "MOD"



func is_reviewer() -> bool:
	return is_logged_in() and (role == "REVIEWER" or role == "MOD")



func is_admin() -> bool:
	return is_mod()




func api_register(email: String, uname: String, password: String) -> Dictionary:
	var r: = await _request(HTTPClient.METHOD_POST, "/auth/register", 
		{"email": email, "username": uname, "password": password})
	if r.ok:
		_adopt_tokens(r.data)
		await _fetch_me()
	return r



func api_login(identifier: String, password: String) -> Dictionary:
	var r: = await _request(HTTPClient.METHOD_POST, "/auth/login", 
		{"identifier": identifier, "password": password})
	if r.ok:
		_adopt_tokens(r.data)
		await _fetch_me()
	return r


func api_logout() -> void :
	if _refresh != "":
		await _request(HTTPClient.METHOD_POST, "/auth/logout", 
			{"refreshToken": _refresh})
	_clear_session()






func chart_hash(chart_path: String) -> String:
	return FileAccess.get_sha256(chart_path)


func submit_score(map_id: String, difficulty: String, payload: Dictionary) -> Dictionary:
	payload["mapId"] = map_id
	payload["difficulty"] = difficulty
	return await _authed(HTTPClient.METHOD_POST, "/scores", payload)









func _mode() -> String:
	return Mods.mode_key()


func map_top(map_id: String, difficulty: String, limit: = 10) -> Dictionary:
	return await _request(HTTPClient.METHOD_GET, 
		"/leaderboards/maps/%s?difficulty=%s&limit=%d&mode=%s"
		%[map_id.uri_encode(), difficulty.uri_encode(), limit, _mode()])



func map_me(map_id: String, difficulty: String) -> Dictionary:
	return await _authed(HTTPClient.METHOD_GET, 
		"/leaderboards/maps/%s/me?difficulty=%s&mode=%s"
		%[map_id.uri_encode(), difficulty.uri_encode(), _mode()])


func global_top(limit: = 10) -> Dictionary:
	return await _request(HTTPClient.METHOD_GET, 
		"/leaderboards/global?limit=%d&mode=%s" % [limit, _mode()])



func global_me() -> Dictionary:
	return await _authed(HTTPClient.METHOD_GET, 
		"/leaderboards/global/me?mode=%s" % _mode())










func api_profile_me() -> Dictionary:
	return await _authed(HTTPClient.METHOD_GET, "/profile/me?mode=%s" % _mode())




func api_profile_identity(payload: Dictionary) -> Dictionary:
	return await _authed(HTTPClient.METHOD_PUT, "/profile/identity", payload)



func api_profile_seen(items: Array) -> Dictionary:
	return await _authed(HTTPClient.METHOD_POST, "/profile/seen", {"items": items})










func api_maps_search(q: = "", cursor: = "", limit: = 30) -> Dictionary:
	var path: = "/maps?limit=%d" % limit
	if q != "":
		path += "&q=" + q.uri_encode()
	if cursor != "":
		path += "&cursor=" + cursor.uri_encode()
	return await _authed(HTTPClient.METHOD_GET, path)



func api_maps_upload_intent(payload: Dictionary) -> Dictionary:
	return await _authed(HTTPClient.METHOD_POST, "/maps/upload-intent", payload)



func api_maps_update_intent(map_id: String, payload: Dictionary) -> Dictionary:
	return await _authed(HTTPClient.METHOD_PUT, "/maps/" + map_id.uri_encode(), 
		payload)



func api_maps_confirm(map_id: String) -> Dictionary:
	return await _authed(HTTPClient.METHOD_POST, 
		"/maps/%s/confirm-upload" % map_id.uri_encode())




func api_maps_mine() -> Dictionary:
	return await _authed(HTTPClient.METHOD_GET, "/maps/mine")


func api_maps_download_url(map_id: String) -> Dictionary:
	return await _authed(HTTPClient.METHOD_GET, 
		"/maps/%s/download-url" % map_id.uri_encode())




func api_maps_preview_url(map_id: String) -> Dictionary:
	return await _authed(HTTPClient.METHOD_GET, 
		"/maps/%s/preview-url" % map_id.uri_encode())





func api_map_set_wip(map_id: String, wip: bool) -> Dictionary:
	return await _authed(HTTPClient.METHOD_PATCH, 
		"/maps/%s/wip" % map_id.uri_encode(), {"wip": wip})




func api_map_like(map_id: String, on: bool) -> Dictionary:
	return await _authed(HTTPClient.METHOD_POST if on else HTTPClient.METHOD_DELETE, 
		"/maps/%s/like" % map_id.uri_encode())





func api_maps_status(ids: Array) -> Dictionary:
	var enc: Array = []
	for id in ids:
		enc.append(String(id).uri_encode())
	return await _authed(HTTPClient.METHOD_GET, "/maps/status?ids=" + ",".join(enc))


func api_maps_delete(map_id: String) -> Dictionary:
	return await _authed(HTTPClient.METHOD_DELETE, "/maps/" + map_id.uri_encode())





func api_map_submit_for_review(map_id: String) -> Dictionary:
	return await _authed(HTTPClient.METHOD_POST, 
		"/maps/%s/submit-for-review" % map_id.uri_encode())



func api_maps_report(map_id: String, reason: String, comment: = "") -> Dictionary:
	var payload: = {"reason": reason}
	if comment != "":
		payload["comment"] = comment
	return await _authed(HTTPClient.METHOD_POST, 
		"/maps/%s/report" % map_id.uri_encode(), payload)





func upload_raw(url: String, bytes: PackedByteArray) -> Dictionary:
	var http: = HTTPRequest.new()
	http.timeout = 180.0
	add_child(http)
	var err: = http.request_raw(url, 
		PackedStringArray(["content-type: application/zip"]), 
		HTTPClient.METHOD_PUT, bytes)
	if err != OK:
		http.queue_free()
		return {"ok": false, "code": 0, "data": null}
	var res: Array = await http.request_completed
	http.queue_free()
	var code: int = res[1]
	return {"ok": code >= 200 and code < 300, "code": code, "data": null}




func download_to_file(url: String, dest_path: String, progress: = Callable()) -> Dictionary:
	var http: = HTTPRequest.new()
	http.timeout = 180.0
	http.download_file = dest_path
	add_child(http)
	var err: = http.request(url)
	if err != OK:
		http.queue_free()
		return {"ok": false, "code": 0, "data": null}



	var done: = [false]
	var res_holder: = [null]
	http.request_completed.connect( func(result: int, code: int, h: PackedStringArray, 
			b: PackedByteArray) -> void :
		res_holder[0] = [result, code, h, b]
		done[0] = true)
	while not done[0]:
		if progress.is_valid():
			var total: = http.get_body_size()
			var got: = http.get_downloaded_bytes()



			if FileAccess.file_exists(dest_path):
				var f: = FileAccess.open(dest_path, FileAccess.READ)
				if f != null:
					got = maxi(got, int(f.get_length()))
					f.close()
			progress.call(got, total)
		await get_tree().create_timer(0.1).timeout
	http.queue_free()
	var res: Array = res_holder[0]
	var code: int = res[1]
	return {"ok": code >= 200 and code < 300, "code": code, "data": null}










func api_admin_reports() -> Dictionary:
	return await _admin(HTTPClient.METHOD_GET, "/admin/reports")



func api_admin_resolve(report_id: String, action: String, reason: = "") -> Dictionary:
	var payload: = {"action": action}
	if reason != "":
		payload["reason"] = reason
	return await _admin(HTTPClient.METHOD_POST, 
		"/admin/reports/%s/resolve" % report_id.uri_encode(), payload)



func api_admin_set_ranking(map_id: String, ranking: String) -> Dictionary:
	return await _admin(HTTPClient.METHOD_POST, 
		"/admin/maps/%s/ranking" % map_id.uri_encode(), {"ranking": ranking})







func api_admin_triage(map_id: String, decision: String, reason: = "") -> Dictionary:
	var payload: = {"decision": decision}
	if reason != "":
		payload["reason"] = reason
	return await _admin(HTTPClient.METHOD_POST, 
		"/admin/maps/%s/triage" % map_id.uri_encode(), payload)



func api_admin_remove_map(map_id: String, reason: String) -> Dictionary:
	return await _admin(HTTPClient.METHOD_DELETE, 
		"/admin/maps/" + map_id.uri_encode(), {"reason": reason})


func api_admin_shared_maps() -> Dictionary:
	return await _admin(HTTPClient.METHOD_GET, "/admin/shared-maps")










func api_admin_presence() -> Dictionary:
	return await _admin(HTTPClient.METHOD_GET, "/admin/presence")


func _admin(method: int, path: String, body: Variant = null) -> Dictionary:


	return await _authed(method, path, body)




func _auto_login() -> void :
	if await _do_refresh():
		await _fetch_me()
	_session_checked = true
	_session_settled.emit()


func _fetch_me() -> void :
	var r: = await _authed(HTTPClient.METHOD_GET, "/auth/me")
	if r.ok and r.data is Dictionary:
		username = str(r.data.get("username", ""))
		user_id = str(r.data.get("id", ""))
		role = str(r.data.get("role", "USER"))
		auth_changed.emit(true, username)







var _refreshing: = false
signal _refresh_settled(ok: bool)





func _do_refresh() -> bool:
	if _refreshing:
		return await _refresh_settled
	_refreshing = true
	var r: = await _request(HTTPClient.METHOD_POST, "/auth/refresh", 
		{"refreshToken": _refresh})
	var ok: = false
	if r.ok:
		_adopt_tokens(r.data)
		ok = true
	elif r.code == 401:
		_clear_session()
	_refreshing = false
	_refresh_settled.emit(ok)
	return ok


func _adopt_tokens(data: Variant) -> void :
	if data is Dictionary:
		_access = str(data.get("accessToken", ""))
		_refresh = str(data.get("refreshToken", ""))
		_save_session()



func _authed(method: int, path: String, body: Variant = null) -> Dictionary:
	var r: = await _request(method, path, body, true)
	if r.code == 401 and _refresh != "":
		if await _do_refresh():
			r = await _request(method, path, body, true)
	return r




func _request(method: int, path: String, body: Variant = null, 
		authed: = false, extra_headers: = PackedStringArray()) -> Dictionary:
	var http: = HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var headers: = PackedStringArray([
		"content-type: application/json", 
		"x-client-version: " + Telemetry.game_version(), 
	])
	if authed and _access != "":
		headers.append("authorization: Bearer " + _access)
	headers.append_array(extra_headers)
	var body_s: = "" if body == null else JSON.stringify(body)
	var err: = http.request(Telemetry.base_url() + path, headers, method, body_s)
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




func _load_session() -> void :
	var cf: = ConfigFile.new()
	if cf.load(SESSION_FILE) != OK:
		return
	_refresh = cf.get_value("auth", "refresh_token", "")
	username = cf.get_value("auth", "username", "")


func _save_session() -> void :
	var cf: = ConfigFile.new()
	cf.set_value("auth", "refresh_token", _refresh)
	cf.set_value("auth", "username", username)
	cf.save(SESSION_FILE)


func _clear_session() -> void :
	_access = ""
	_refresh = ""
	username = ""
	user_id = ""
	role = "USER"
	var d: = DirAccess.open("user://")
	if d != null and d.file_exists(SESSION_FILE.get_file()):
		d.remove(SESSION_FILE.get_file())
	auth_changed.emit(false, "")
