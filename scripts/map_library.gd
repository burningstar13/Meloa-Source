extends Node






























signal library_changed

const USER_ROOT: = "user://maps"
const USER_PREFIX: = "user:"





const STATUS_OFFICIAL: = "official"
const STATUS_DRAFT: = "draft"
const STATUS_PUBLISHED: = "published"
const STATUS_DOWNLOADED: = "downloaded"




const AUDIO_EXT: = ["mp3", "ogg", "wav"]




const IMAGE_EXT: = ["jpg", "jpeg", "png", "webp"]








const IMG_COVER: = "cover"
const IMG_BACKGROUND: = "background"



var _maps: Dictionary = {}


func _ready() -> void :
	rescan()






func rescan() -> void :
	_maps.clear()
	var root: = DirAccess.open(USER_ROOT)
	if root == null:
		DirAccess.make_dir_recursive_absolute(USER_ROOT)
		library_changed.emit()
		return
	for id in root.get_directories():
		var dir: = "%s/%s" % [USER_ROOT, id]
		var meta: = _read_meta(dir)
		if meta.is_empty():
			continue
		meta["id"] = id






		var ordered: Array = []
		for i in meta.difficulties.size():
			var d: Dictionary = meta.difficulties[i]
			var lvl: float = float(d.get("rated", 0.0))
			if lvl <= 0.0:
				lvl = float(d.get("level", 0.0))
			ordered.append([lvl, i, d])
		ordered.sort_custom( func(a, b):
			return a[0] < b[0] if a[0] != b[0] else a[1] < b[1])
		var diffs: = {}
		for od in ordered:
			var d: Dictionary = od[2]
			var path: String = "%s/%s" % [dir, String(d.file)]
			if FileAccess.file_exists(path):
				diffs[String(d.key)] = path
		if diffs.is_empty():
			continue
		_maps[USER_PREFIX + id] = {"id": id, "dir": dir, "meta": meta, 
			"diffs": diffs}
	library_changed.emit()




func _read_meta(dir: String) -> Dictionary:
	var f: = FileAccess.open(dir + "/map.json", FileAccess.READ)
	if f == null:
		return {}
	var data = JSON.parse_string(f.get_as_text())
	f.close()
	if not (data is Dictionary):
		return {}
	return _normalise(data)






func _normalise(d: Dictionary) -> Dictionary:
	var m: = d.duplicate(true)
	m["format"] = int(m.get("format", 1))
	m["title"] = String(m.get("title", "UNTITLED"))
	m["artist"] = String(m.get("artist", ""))
	m["title_romanised"] = String(m.get("title_romanised", ""))
	m["artist_romanised"] = String(m.get("artist_romanised", ""))
	m["creator"] = String(m.get("creator", ""))
	m["audio"] = String(m.get("audio", ""))
	m["cover"] = String(m.get("cover", ""))



	m["background"] = String(m.get("background", ""))


	m["video"] = String(m.get("video", ""))
	m["video_offset"] = float(m.get("video_offset", 0.0))
	m["duration"] = float(m.get("duration", 0.0))
	m["preview_time"] = float(m.get("preview_time", 0.0))


	m["status"] = String(m.get("status", STATUS_DRAFT))




	m["online_id"] = String(m.get("online_id", ""))
	m["online_version"] = int(m.get("online_version", 0))





	m.erase("online_ranking")
	m.erase("online_latest")





	m.erase("online_meloved")






	if String(m.status) == STATUS_DOWNLOADED:
		m.erase("online_wip")
	else:
		m["online_wip"] = bool(m.get("online_wip", false))



	m["wip_of"] = String(m.get("wip_of", ""))
	m["created"] = String(m.get("created", ""))
	m["modified"] = String(m.get("modified", ""))
	var diffs: Array = []
	for e in m.get("difficulties", []):
		if not (e is Dictionary) or not e.has("file"):
			continue
		var key: = String(e.get("key", String(e.file).get_basename()))
		diffs.append({
			"key": key, 
			"name": String(e.get("name", key.to_upper())), 

			"level": float(e.get("level", 0.0)), 




			"rated": float(e.get("rated", 0.0)), 
			"file": String(e.file), 
			"modified": String(e.get("modified", "")), 
		})
	m["difficulties"] = diffs
	return m




func tracks() -> Dictionary:
	var out: Dictionary = {}
	for t in Tuning.TRACKS:
		out[t] = Tuning.TRACKS[t]
	var user_keys: Array = _maps.keys()
	user_keys.sort_custom( func(a, b):
		return String(_maps[a].meta.modified) > String(_maps[b].meta.modified))
	for k in user_keys:
		out[k] = _maps[k].diffs
	return out


func has(track: String) -> bool:
	return _maps.has(track) or Tuning.TRACKS.has(track)


func is_user_map(track: String) -> bool:
	return _maps.has(track)



func user_tracks() -> Array:
	var keys: Array = _maps.keys()
	keys.sort_custom( func(a, b):
		return String(_maps[a].meta.modified) > String(_maps[b].meta.modified))
	return keys


func diffs_of(track: String) -> Dictionary:
	if _maps.has(track):
		return _maps[track].diffs
	return Tuning.TRACKS.get(track, {})





func chart_for(track: String, diff: String) -> String:
	var d: = diffs_of(track)
	if d.is_empty():
		return ""
	return String(d.get(diff, d[d.keys()[d.size() - 1]]))


func hardest_diff(track: String) -> String:
	var d: = diffs_of(track)
	if d.is_empty():
		return ""
	return String(d.keys()[d.size() - 1])




func meta_of(track: String) -> Dictionary:
	return _maps[track].meta if _maps.has(track) else {}


func map_dir(track: String) -> String:
	return String(_maps[track].dir) if _maps.has(track) else ""


func map_id(track: String) -> String:
	return String(_maps[track].id) if _maps.has(track) else ""


func status_of(track: String) -> String:
	if _maps.has(track):
		return String(_maps[track].meta.status)
	return STATUS_OFFICIAL




func find_online(online_id: String) -> String:
	if online_id == "":
		return ""
	for k in _maps:
		if String(_maps[k].meta.online_id) == online_id:
			return k
	return ""


func online_version_of(track: String) -> int:
	return int(_maps[track].meta.online_version) if _maps.has(track) else 0








var _online_session: = {}


func _sess(track: String) -> Dictionary:
	if not _online_session.has(track):
		_online_session[track] = {}
	return _online_session[track]


func online_ranking_of(track: String) -> String:
	if not _maps.has(track) or not _online_session.has(track):
		return ""
	return String(_online_session[track].get("ranking", ""))



func set_online_ranking(track: String, ranking: String) -> void :
	if not _maps.has(track):
		return
	var r: = ranking.to_lower()
	if online_ranking_of(track) == r:
		return
	_sess(track)["ranking"] = r
	library_changed.emit()





func online_latest_of(track: String) -> int:
	if not _maps.has(track) or not _online_session.has(track):
		return 0
	return int(_online_session[track].get("latest", 0))


func set_online_latest(track: String, version: int) -> void :
	if not _maps.has(track) or online_latest_of(track) == version:
		return
	_sess(track)["latest"] = version
	library_changed.emit()





func is_outdated(track: String) -> bool:
	if not _maps.has(track) or status_of(track) != STATUS_DOWNLOADED:
		return false
	return online_latest_of(track) > int(_maps[track].meta.get("online_version", 0))




var _meloved_session: = {}


func online_meloved_of(track: String) -> bool:
	return bool(_meloved_session.get(track, false))


func set_online_meloved(track: String, meloved: bool) -> void :
	if not _maps.has(track) or online_meloved_of(track) == meloved:
		return
	if meloved:
		_meloved_session[track] = true
	else:
		_meloved_session.erase(track)
	library_changed.emit()


func online_wip_of(track: String) -> bool:
	if not _maps.has(track):
		return false
	if status_of(track) == STATUS_DOWNLOADED:
		return bool(_online_session.get(track, {}).get("wip", false))
	return bool(_maps[track].meta.get("online_wip", false))




func set_online_wip(track: String, wip: bool) -> void :
	if not _maps.has(track) or online_wip_of(track) == wip:
		return
	if status_of(track) == STATUS_DOWNLOADED:
		_sess(track)["wip"] = wip
		library_changed.emit()
		return
	var meta: Dictionary = _maps[track].meta
	meta["online_wip"] = wip
	save_meta(track, meta)




func is_shared(track: String) -> bool:
	if not _maps.has(track):
		return false
	var meta: Dictionary = _maps[track].meta


	return String(meta.get("online_id", "")) != ""\
	and String(meta.get("status", STATUS_DRAFT)) != STATUS_DRAFT



func wip_of(track: String) -> String:
	if not _maps.has(track):
		return ""
	return String(_maps[track].meta.get("wip_of", ""))



func wip_for(release_track: String) -> String:
	for k in _maps:
		if String(_maps[k].meta.get("wip_of", "")) == release_track:
			return k
	return ""






func fork_wip(release_track: String) -> String:
	if not _maps.has(release_track):
		return ""
	var existing: = wip_for(release_track)
	if existing != "":
		return existing
	var src_dir: String = _maps[release_track].dir
	var wip_id: String = String(_maps[release_track].id) + "-wip"
	var dst_dir: = "%s/%s" % [USER_ROOT, wip_id]
	if DirAccess.make_dir_recursive_absolute(dst_dir) != OK:
		return ""
	var d: = DirAccess.open(src_dir)
	if d == null:
		return ""
	for f in d.get_files():
		if f.ends_with(".tmp"):
			continue
		if not _copy_file("%s/%s" % [src_dir, f], "%s/%s" % [dst_dir, f]):
			return ""
	var meta: Dictionary = (_maps[release_track].meta as Dictionary).duplicate(true)
	meta["status"] = STATUS_DRAFT
	meta["wip_of"] = release_track
	meta["modified"] = now_stamp()
	if not write_meta(wip_id, meta):
		return ""
	rescan()
	return USER_PREFIX + wip_id





func promote_wip(wip_track: String, version: int) -> bool:
	if not _maps.has(wip_track):
		return false
	var release: = String(_maps[wip_track].meta.get("wip_of", ""))
	if release == "" or not _maps.has(release):
		return false
	var src_dir: String = _maps[wip_track].dir
	var dst_dir: String = _maps[release].dir
	var d: = DirAccess.open(src_dir)
	if d == null:
		return false
	for f in d.get_files():
		if f.ends_with(".tmp") or f == "map.json":
			continue
		if not _copy_file("%s/%s" % [src_dir, f], "%s/%s" % [dst_dir, f]):
			return false
	var rel_meta: Dictionary = (_maps[wip_track].meta as Dictionary).duplicate(true)
	rel_meta["status"] = STATUS_PUBLISHED
	rel_meta["wip_of"] = ""
	rel_meta["online_version"] = version
	rel_meta["modified"] = now_stamp()
	if not write_meta(String(_maps[release].id), rel_meta):
		return false
	var wip_meta: Dictionary = _maps[wip_track].meta
	wip_meta["online_version"] = version
	write_meta(String(_maps[wip_track].id), wip_meta)
	rescan()
	set_online_ranking(release, "pending")
	return true


func title_of(track: String) -> String:
	if _maps.has(track):
		var m: Dictionary = _maps[track].meta
		var t: = String(m.title_romanised) if String(m.title_romanised) != ""\
		else String(m.title)
		if t == "":
			t = "UNTITLED"


		if String(m.get("wip_of", "")) != "":
			t += " (WIP)"
		return t
	return track


func artist_of(track: String) -> String:
	if _maps.has(track):
		var m: Dictionary = _maps[track].meta
		return String(m.artist_romanised) if String(m.artist_romanised) != ""\
		else String(m.artist)
	return ""




func audio_path(track: String) -> String:
	if not _maps.has(track):
		return ""
	var a: = String(_maps[track].meta.audio)
	return "" if a == "" else "%s/%s" % [_maps[track].dir, a]




func diff_name(track: String, diff: String) -> String:
	if _maps.has(track):
		for d in _maps[track].meta.difficulties:
			if String(d.key) == diff:
				return String(d.name)
	return diff.to_upper()






func diff_level(track: String, diff: String) -> float:
	if _maps.has(track):
		for d in _maps[track].meta.difficulties:
			if String(d.key) == diff:
				return float(d.level)
	return 0.0




func diff_rated(track: String, diff: String) -> float:
	if _maps.has(track):
		for d in _maps[track].meta.difficulties:
			if String(d.key) == diff:
				return float(d.get("rated", 0.0))
	return 0.0










static func load_audio(path: String) -> AudioStream:
	if path == "":
		return null
	if path.begins_with("res://"):
		return load(path) if ResourceLoader.exists(path) else null
	if not FileAccess.file_exists(path):
		return null
	match path.get_extension().to_lower():
		"wav":
			return AudioStreamWAV.load_from_file(path)
		"ogg", "oga":
			return AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			var m: = AudioStreamMP3.new()
			m.data = FileAccess.get_file_as_bytes(path)
			return m if m.data.size() > 0 else null
	return null


static func is_audio_file(path: String) -> bool:
	return path.get_extension().to_lower() in AUDIO_EXT






func _make_id(title: String) -> String:
	var slug: = ""
	for c in title.to_lower():
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			slug += c
		elif slug.length() > 0 and not slug.ends_with("-"):
			slug += "-"
	slug = slug.strip_edges().trim_suffix("-").substr(0, 28)
	if slug == "":
		slug = "map"
	var salt: = ""
	for i in 4:
		salt += "0123456789abcdef"[randi() % 16]
	var id: = "%s-%s" % [slug, salt]
	while DirAccess.dir_exists_absolute("%s/%s" % [USER_ROOT, id]):
		id += "x"
	return id



func _make_diff_key(meta: Dictionary, name: String) -> String:
	var slug: = ""
	for c in name.to_lower():
		if (c >= "a" and c <= "z") or (c >= "0" and c <= "9"):
			slug += c
	if slug == "":
		slug = "diff"
	slug = slug.substr(0, 20)
	var taken: = {}
	for d in meta.get("difficulties", []):
		taken[String(d.key)] = true
	var key: = slug
	var n: = 2
	while taken.has(key):
		key = "%s%d" % [slug, n]
		n += 1
	return key


static func now_stamp() -> String:
	return Time.get_datetime_string_from_system(true, true)








func new_draft(info: Dictionary) -> Dictionary:
	var stamp: = now_stamp()
	var meta: = _normalise({
		"format": 1, 
		"title": String(info.get("title", "")), 
		"artist": String(info.get("artist", "")), 
		"title_romanised": String(info.get("title_romanised", "")), 
		"artist_romanised": String(info.get("artist_romanised", "")), 
		"creator": String(info.get("creator", "")), 
		"audio": "", 
		"duration": float(info.get("duration", 0.0)), 
		"preview_time": float(info.get("preview_time", 0.0)), 
		"status": STATUS_DRAFT, 
		"created": stamp, 
		"modified": stamp, 
		"difficulties": [], 
	})
	var dname: = String(info.get("diff_name", "NORMAL"))
	var key: = _make_diff_key(meta, dname)
	meta.difficulties.append({
		"key": key, "name": dname, "level": float(info.get("diff_level", 0.0)), 
		"rated": 0.0, "file": key + ".json", "modified": stamp, 
	})
	return {
		"id": _make_id(String(info.get("title", ""))), 
		"meta": meta, 
		"source_audio": String(info.get("source_audio", "")), 
		"diff": key, 


		"default_v": {
			"lane": clampf(float(info.get("default_v_lane", 1.0)), 0.5, 2.0), 
			"aim": clampf(float(info.get("default_v_aim", 1.0)), 0.5, 2.0), 
		}, 
	}










func commit_draft(draft: Dictionary) -> String:
	var id: = String(draft.id)
	var dir: = "%s/%s" % [USER_ROOT, id]
	if DirAccess.make_dir_recursive_absolute(dir) != OK:
		return ""
	var meta: Dictionary = draft.meta
	var src: = String(draft.get("source_audio", ""))
	if src != "" and String(meta.audio) == "":
		var ext: = src.get_extension().to_lower()
		var dest: = "audio." + ext
		if _copy_file(src, "%s/%s" % [dir, dest]):
			meta["audio"] = dest
		else:
			return ""
	if not write_meta(id, meta):
		return ""
	var key: = USER_PREFIX + id
	var diffs: = {}
	for d in meta.difficulties:
		diffs[String(d.key)] = "%s/%s" % [dir, String(d.file)]
	_maps[key] = {"id": id, "dir": dir, "meta": meta, "diffs": diffs}
	library_changed.emit()
	return key





func _copy_file(from: String, to: String) -> bool:
	var src: = FileAccess.open(from, FileAccess.READ)
	if src == null:
		return false
	var dst: = FileAccess.open(to, FileAccess.WRITE)
	if dst == null:
		src.close()
		return false


	while not src.eof_reached():
		dst.store_buffer(src.get_buffer(4 << 20))
	src.close()
	dst.close()
	return true











static func write_text_atomic(path: String, text: String) -> bool:
	var tmp: = path + ".tmp"
	var f: = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(text)


	f.flush()
	var err: = f.get_error()
	f.close()
	if err != OK:
		DirAccess.remove_absolute(tmp)
		return false
	if DirAccess.rename_absolute(tmp, path) != OK:
		DirAccess.remove_absolute(tmp)
		return false
	return true



func write_meta(id: String, meta: Dictionary) -> bool:
	var out: = meta.duplicate(true)
	out.erase("id")
	out["modified"] = now_stamp()
	if not write_text_atomic("%s/%s/map.json" % [USER_ROOT, id], 
			JSON.stringify(out, "  ") + "\n"):
		return false
	if _maps.has(USER_PREFIX + id):
		_maps[USER_PREFIX + id].meta = _normalise(out)
		_maps[USER_PREFIX + id].meta["id"] = id
	return true





func image_path(track: String, kind: String) -> String:
	if not _maps.has(track):
		return ""
	var file: = String(_maps[track].meta.get(kind, ""))
	if file == "":
		return ""
	var full: = "%s/%s" % [String(_maps[track].dir), file]
	return full if FileAccess.file_exists(full) else ""






func set_image(track: String, kind: String, src: String) -> bool:
	if not _maps.has(track) or src == "":
		return false
	var ext: = src.get_extension().to_lower()
	if not IMAGE_EXT.has(ext):
		return false
	var dir: = String(_maps[track].dir)
	var meta: Dictionary = _maps[track].meta
	var old: = String(meta.get(kind, ""))
	if not _copy_file(src, "%s/%s.%s" % [dir, kind, ext]):
		return false
	if old != "" and old != "%s.%s" % [kind, ext]:
		DirAccess.remove_absolute("%s/%s" % [dir, old])
	meta[kind] = "%s.%s" % [kind, ext]
	return save_meta(track, meta)





const VIDEO_EXT: = ["ogv"]

const VIDEO_SRC_EXT: = ["ogv", "mp4", "webm", "mkv", "mov", "avi", "m4v"]
const VIDEO_FILE: = "video.ogv"



func video_path(track: String) -> String:
	if not _maps.has(track):
		return ""
	var file: = String(_maps[track].meta.get("video", ""))
	if file == "":
		return ""
	var full: = "%s/%s" % [String(_maps[track].dir), file]
	return full if FileAccess.file_exists(full) else ""




func set_video(track: String, src: String) -> bool:
	if not _maps.has(track) or src == "":
		return false
	if not VIDEO_EXT.has(src.get_extension().to_lower()):
		return false
	var dir: = String(_maps[track].dir)
	var meta: Dictionary = _maps[track].meta
	var old: = String(meta.get("video", ""))
	if not _copy_file(src, "%s/%s" % [dir, VIDEO_FILE]):
		return false
	if old != "" and old != VIDEO_FILE:
		DirAccess.remove_absolute("%s/%s" % [dir, old])
	meta["video"] = VIDEO_FILE
	return save_meta(track, meta)


func clear_video(track: String) -> bool:
	if not _maps.has(track):
		return false
	var meta: Dictionary = _maps[track].meta
	var old: = String(meta.get("video", ""))
	if old != "":
		DirAccess.remove_absolute("%s/%s" % [String(_maps[track].dir), old])
	meta["video"] = ""
	return save_meta(track, meta)




func set_video_offset(track: String, off: float) -> bool:
	if not _maps.has(track):
		return false
	var meta: Dictionary = _maps[track].meta
	meta["video_offset"] = snappedf(off, 0.001)
	return save_meta(track, meta)






func import_asset(track: String, src: String, prefix: = "fx_") -> String:
	if not _maps.has(track) or src == "":
		return ""
	var ext: = src.get_extension().to_lower()
	if not IMAGE_EXT.has(ext):
		return ""
	var name: = asset_name(src, prefix)
	if not _copy_file(src, "%s/%s" % [String(_maps[track].dir), name]):
		return ""
	return name






static func asset_name(src: String, prefix: = "fx_", ext: = "") -> String:
	if ext == "":
		ext = src.get_extension().to_lower()
	var base: = src.get_file().get_basename().to_lower()
	var clean: = ""
	for ch in base:
		var c: = String(ch)
		var code: = c.unicode_at(0)
		var ok: = (code >= 48 and code <= 57) or (code >= 97 and code <= 122)\
		or c == "-" or c == "_"
		clean += c if ok else "_"
	clean = clean.substr(0, 40).strip_edges().trim_suffix("_")
	if clean == "":
		clean = "image"
	return "%s%s.%s" % [prefix, clean, ext]


func clear_image(track: String, kind: String) -> bool:
	if not _maps.has(track):
		return false
	var meta: Dictionary = _maps[track].meta
	var old: = String(meta.get(kind, ""))
	if old == "":
		return true
	DirAccess.remove_absolute("%s/%s" % [String(_maps[track].dir), old])
	meta[kind] = ""
	return save_meta(track, meta)




func save_meta(track: String, meta: Dictionary) -> bool:
	if not _maps.has(track):
		return false
	if not write_meta(String(_maps[track].id), meta):
		return false
	rescan()
	return true




func add_difficulty(meta: Dictionary, name: String, level: float) -> String:
	if not meta.has("difficulties"):
		meta["difficulties"] = []
	var key: = _make_diff_key(meta, name)
	meta.difficulties.append({
		"key": key, "name": name, "level": level, "rated": 0.0, 
		"file": key + ".json", "modified": now_stamp(), 
	})
	return key




func remove_difficulty(track: String, diff: String) -> bool:
	if not _maps.has(track):
		return false
	var meta: Dictionary = _maps[track].meta
	if meta.difficulties.size() <= 1:
		return false
	var dir: = String(_maps[track].dir)
	var kept: Array = []
	for d in meta.difficulties:
		if String(d.key) == diff:
			DirAccess.remove_absolute("%s/%s" % [dir, String(d.file)])
		else:
			kept.append(d)
	if kept.size() == meta.difficulties.size():
		return false
	meta["difficulties"] = kept
	return save_meta(track, meta)





func rename_difficulty(track: String, diff: String, name: String, 
		level: float) -> bool:
	if not _maps.has(track):
		return false
	var meta: Dictionary = _maps[track].meta
	for d in meta.difficulties:
		if String(d.key) == diff:
			d["name"] = name
			d["level"] = level
			d["modified"] = now_stamp()
			return save_meta(track, meta)
	return false




static func diff_name_taken(meta: Dictionary, name: String, 
		except_key: = "") -> bool:
	var want: = name.strip_edges().to_lower()
	for d in meta.get("difficulties", []):
		if String(d.key) == except_key:
			continue
		if String(d.name).strip_edges().to_lower() == want:
			return true
	return false




func delete_map(track: String) -> bool:
	if not _maps.has(track):
		return false
	var dir: = String(_maps[track].dir)
	var d: = DirAccess.open(dir)
	if d != null:
		for f in d.get_files():
			d.remove(f)
	DirAccess.remove_absolute(dir)
	rescan()
	return true
