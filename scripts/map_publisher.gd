class_name MapPublisher
extends RefCounted




















const MAX_ZIP_BYTES: = 20 * 1024 * 1024
const TMP_ZIP: = "user://publish_tmp.zip"




const DL_ZIP: = "user://download_tmp"


const POLL_EVERY: = 2.0
const POLL_TRIES: = 15






static func publish(track: String, progress: = Callable()) -> Dictionary:
	if not MapLibrary.is_user_map(track):
		return _fail("only your own maps can be published")
	if MapLibrary.status_of(track) == MapLibrary.STATUS_DOWNLOADED:
		return _fail("downloaded map — only its mapper can publish it")
	if not Backend.is_logged_in():
		return _fail("log in first — publishing needs your account")
	var meta: Dictionary = MapLibrary.meta_of(track)
	var dir: = MapLibrary.map_dir(track)

	_report(progress, "packing the map…")
	var pack: = _pack(dir, meta)
	if not pack.ok:
		return pack
	var size: int = pack.size
	var checksum: String = pack.checksum
	var content: String = pack.content





	var online_id: = String(meta.online_id)
	if online_id != "" and content != ""\
	and String(meta.get("online_content", "")) == content:
		var want_wip: = bool(meta.get("online_wip", false))
		_report(progress, "no changes since v%d — updating the flag…" % int(meta.online_version))
		var w: Dictionary = await Backend.api_map_set_wip(online_id, want_wip)
		if w.code != 404:
			DirAccess.remove_absolute(TMP_ZIP)
			if not w.ok:
				return _fail(server_error(w, "the server refused the change"))


			var release: = MapLibrary.wip_of(track)
			if release != "":
				MapLibrary.set_online_wip(release, want_wip)
			var ver: = int(meta.online_version)
			if want_wip:
				return {"ok": true, "message": "no changes since v%d — marked as work in progress" % ver}
			match MapLibrary.online_ranking_of(release if release != "" else track):
				"ranked":
					return {"ok": true, "message": "no changes since v%d — already ranked" % ver}
				"unranked":
					return _fail("v%d was refused (unranked) — change something before publishing it again" % ver)
			return {"ok": true, "message": "no changes since v%d — proposed for ranking" % ver}
		online_id = ""




	_report(progress, "requesting upload…")
	var payload: = {
		"title": String(meta.title), 
		"artist": String(meta.artist), 
		"sizeBytes": size, 
		"checksumSha256": checksum, 


		"wip": bool(meta.get("online_wip", false)), 
	}
	var r: Dictionary
	if online_id != "":
		r = await Backend.api_maps_update_intent(online_id, payload)
		if r.code == 404:
			online_id = ""
	if online_id == "":
		r = await Backend.api_maps_upload_intent(payload)
	if not r.ok:
		return _fail(server_error(r, "the server refused the upload"))
	if not (r.data is Dictionary):
		return _fail("unexpected server reply — try again")
	var map_id: = String(r.data.get("mapId", ""))
	var put_url: = String(r.data.get("presignedPutUrl", ""))
	if map_id == "" or put_url == "":
		return _fail("unexpected server reply — try again")







	if String(meta.get("online_id", "")) != map_id:
		var meta_id: Dictionary = MapLibrary.meta_of(track)
		if not meta_id.is_empty():
			meta_id["online_id"] = map_id
			MapLibrary.save_meta(track, meta_id)

	_report(progress, "uploading %.1f MB…" % (size / 1048576.0))
	var zip_bytes: = FileAccess.get_file_as_bytes(TMP_ZIP)
	var up: Dictionary = await Backend.upload_raw(put_url, zip_bytes)
	DirAccess.remove_absolute(TMP_ZIP)
	if not up.ok:
		return _fail("upload to storage failed (%d) — check your connection"
			%int(up.code))

	_report(progress, "upload done — server is checking the map…")
	var cf: Dictionary = await Backend.api_maps_confirm(map_id)
	if not cf.ok:
		return _fail(server_error(cf, "the server could not confirm the upload"))



	for i in POLL_TRIES:
		await Backend.get_tree().create_timer(POLL_EVERY).timeout
		var mine: Dictionary = await Backend.api_maps_mine()
		if not mine.ok or not (mine.data is Array):
			continue
		for e in mine.data:
			if not (e is Dictionary) or String(e.get("id", "")) != map_id:
				continue
			var status: = String(e.get("status", ""))
			var updating: = bool(e.get("updating", false))
			if status == "REJECTED":


				var meta2: Dictionary = MapLibrary.meta_of(track)
				if not meta2.is_empty():
					meta2["online_id"] = map_id
					MapLibrary.save_meta(track, meta2)
				return _fail("rejected: " + String(e.get("rejectionReason", 
					"the map did not pass validation")))
			if status == "PUBLISHED" and not updating:


				var reason = e.get("rejectionReason")
				if reason is String and reason != "":
					return _fail("update rejected: " + reason)
				var ver: = int(e.get("version", 1))






				var sent: Dictionary = MapLibrary.meta_of(track)
				if not sent.is_empty():
					sent["online_content"] = content
					MapLibrary.save_meta(track, sent)
				if MapLibrary.wip_of(track) != "":
					if not MapLibrary.promote_wip(track, ver):
						return _fail("published online, but the local published copy could not be updated")
					return {"ok": true, "message":
						"update published (v%d) — your published copy is refreshed, this working copy stays editable" % ver}
				_remember_online(track, map_id, ver)
				return {"ok": true, "message": "map published — live for everyone!"}
	return {"ok": true, "message":
		"upload received — validation is taking longer than usual, " + 
		"check back in a minute"}





static func _pack(dir: String, meta: Dictionary) -> Dictionary:
	var files: Array[String] = ["map.json"]
	for d in meta.get("difficulties", []):
		files.append(String(d.file))
	if String(meta.audio) == "":
		return _fail("this map has no audio yet")
	files.append(String(meta.audio))
	for kind in [MapLibrary.IMG_COVER, MapLibrary.IMG_BACKGROUND]:
		var img: = String(meta.get(kind, ""))
		if img != "":
			files.append(img)





	for d in meta.get("difficulties", []):
		var data = JSON.parse_string(FileAccess.get_file_as_string(
			"%s/%s" % [dir, String(d.file)]))
		if not (data is Dictionary):
			continue
		for ev in data.get("fx", []):
			if not (ev is Dictionary) or String(ev.get("type", "")) != "image":
				continue
			var f: = String(ev.get("file", ""))
			if f == "":
				continue


			var sheets: = maxi(int(ev.get("sheets", 1)), 1)
			for si in sheets:
				var sf: = f if si == 0 else "%s_%d.%s" % [f.get_basename(), si + 1, 
					f.get_extension()]
				if files.has(sf):
					continue
				if not FileAccess.file_exists("%s/%s" % [dir, sf]):
					return _fail("choreography image missing from the map folder: %s — " % sf
						+ "pick it again on its IMAGE event, then publish")
				files.append(sf)

	var zp: = ZIPPacker.new()
	if zp.open(TMP_ZIP) != OK:
		return _fail("could not create the zip file")


	var hc: = HashingContext.new()
	hc.start(HashingContext.HASH_SHA256)
	var total: = 0
	for f in files:
		var path: = "%s/%s" % [dir, f]
		var bytes: = FileAccess.get_file_as_bytes(path)
		if f == "map.json":




			var clean: Dictionary = meta.duplicate(true)
			for k in ["status", "online_id", "online_version", "online_ranking", 
					"online_wip", "online_content", "wip_of", "id"]:
				clean.erase(k)


			clean.erase("video")
			clean.erase("video_offset")


			var fp: Dictionary = clean.duplicate(true)
			fp.erase("modified")
			for d in fp.get("difficulties", []):
				if d is Dictionary:
					d.erase("modified")
			hc.update(f.to_utf8_buffer())
			hc.update(JSON.stringify(fp).to_utf8_buffer())
			bytes = (JSON.stringify(clean, "  ") + "\n").to_utf8_buffer()
		if bytes.is_empty():
			zp.close()
			return _fail("missing file in the map folder: " + f)
		total += bytes.size()
		if f != "map.json":
			hc.update(f.to_utf8_buffer())
			hc.update(bytes)
		zp.start_file(f)
		zp.write_file(bytes)
		zp.close_file()
	zp.close()

	var size: = _file_size(TMP_ZIP)
	if size <= 0:
		return _fail("could not create the zip file")
	if size > MAX_ZIP_BYTES:
		return _fail("map is too big (%.1f MB, max 20 MB) — use a compressed " %
			(size / 1048576.0) + "audio format (mp3/ogg)")
	return {"ok": true, "size": size, 
		"checksum": FileAccess.get_sha256(TMP_ZIP), 
		"content": hc.finish().hex_encode()}



static func _remember_online(track: String, online_id: String, version: int) -> void :
	var meta: Dictionary = MapLibrary.meta_of(track)
	if meta.is_empty():
		return
	meta["status"] = MapLibrary.STATUS_PUBLISHED
	meta["online_id"] = online_id
	meta["online_version"] = version
	MapLibrary.save_meta(track, meta)
	MapLibrary.set_online_ranking(track, "pending")





static func is_installed(online_id: String, version: int) -> bool:
	var track: = MapLibrary.find_online(online_id)
	return track != "" and MapLibrary.online_version_of(track) >= version



static func download(entry: Dictionary, progress: = Callable()) -> Dictionary:
	var online_id: = String(entry.get("id", ""))
	if online_id == "":
		return _fail("broken catalog entry")
	if is_installed(online_id, int(entry.get("version", 1))):
		return {"ok": true, "message": "already installed"}

	_report(progress, "requesting download…")
	var r: Dictionary = await Backend.api_maps_download_url(online_id)
	if not r.ok:
		return _fail(server_error(r, "this map is not downloadable right now"))
	if not (r.data is Dictionary):
		return _fail("unexpected server reply — try again")
	var url: = String(r.data.get("presignedGetUrl", ""))
	var version: = int(r.data.get("version", 1))
	var checksum: = String(r.data.get("checksumSha256", "")).to_lower()

	_report(progress, "downloading…")
	var expected: = int(entry.get("size_bytes", 0))
	var on_bytes: = func(got: int, total: int) -> void :
		var size: = total if total > 0 else expected
		if got <= 0:
			_report(progress, "downloading…")
		elif size > 0:
			_report(progress, "downloading %d%%" % clampi(int(got * 100.0 / size), 1, 99))
		else:
			_report(progress, "downloading %.1f MB" % (got / 1048576.0))
	var zip_path: = "%s_%s.zip" % [DL_ZIP, online_id.validate_filename()]
	var dl: Dictionary = await Backend.download_to_file(url, zip_path, on_bytes)
	_report(progress, "installing…")
	if not dl.ok:
		DirAccess.remove_absolute(zip_path)
		return _fail("download failed (%d) — check your connection" % int(dl.code))



	if FileAccess.get_sha256(zip_path) != checksum:
		DirAccess.remove_absolute(zip_path)
		return _fail("corrupted download (checksum mismatch) — try again")

	var res: = _install(zip_path, online_id, version, 
		String(entry.get("ranking", "pending")), bool(entry.get("wip", false)))
	DirAccess.remove_absolute(zip_path)
	if res.ok:
		MapLibrary.rescan()


		var installed: = MapLibrary.find_online(online_id)
		if installed != "":
			MapLibrary.set_online_ranking(installed, String(entry.get("ranking", "pending")))
			MapLibrary.set_online_wip(installed, bool(entry.get("wip", false)))
			MapLibrary.set_online_latest(installed, version)
	return res




static func _install(zip_path: String, online_id: String, version: int, 
		ranking: = "pending", wip: = false) -> Dictionary:
	var zr: = ZIPReader.new()
	if zr.open(zip_path) != OK:
		return _fail("the downloaded file is not a valid map")
	var dir: = "%s/%s" % [MapLibrary.USER_ROOT, online_id]
	DirAccess.make_dir_recursive_absolute(dir)
	for name in zr.get_files():


		if name.contains("/") or name.contains("\\") or name.contains(".."):
			continue
		var f: = FileAccess.open("%s/%s" % [dir, name], FileAccess.WRITE)
		if f == null:
			zr.close()
			return _fail("could not write the map files")
		f.store_buffer(zr.read_file(name))
		f.close()
	zr.close()


	var mf: = FileAccess.open(dir + "/map.json", FileAccess.READ)
	if mf == null:
		return _fail("the map has no map.json")
	var meta = JSON.parse_string(mf.get_as_text())
	mf.close()
	if not (meta is Dictionary):
		return _fail("the map's map.json is unreadable")
	meta["status"] = MapLibrary.STATUS_DOWNLOADED
	meta["online_id"] = online_id
	meta["online_version"] = version




	meta["wip_of"] = ""
	var out: = FileAccess.open(dir + "/map.json", FileAccess.WRITE)
	if out == null:
		return _fail("could not write the map files")
	out.store_string(JSON.stringify(meta, "  ") + "\n")
	out.close()
	return {"ok": true, "message": "map installed!"}




static func _file_size(path: String) -> int:
	var f: = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return -1
	var n: = f.get_length()
	f.close()
	return n


static func _report(progress: Callable, msg: String) -> void :
	if progress.is_valid():
		progress.call(msg)





static func server_error(r: Dictionary, fallback: String) -> String:
	if r.code == 0:
		return "server unreachable — check your connection"
	if r.data is Dictionary:
		var m = r.data.get("message", "")
		if m is Array and m.size() > 0:
			return str(m[0])
		if str(m) != "":
			return str(m)
	return "%s (%d)" % [fallback, int(r.code)]


static func _fail(message: String) -> Dictionary:
	return {"ok": false, "message": message}
