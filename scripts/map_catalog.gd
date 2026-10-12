class_name MapCatalog
extends RefCounted














const PAGE_SIZE: = 30


static func search(query: = "", cursor: = "", limit: = PAGE_SIZE) -> Dictionary:
	var r: Dictionary = await Backend.api_maps_search(query, cursor, limit)
	if not r.ok:
		if r.code == 0:
			return _fail("offline", "server unreachable — check your connection")
		if r.code == 401:
			return _fail("unavailable", "log in to browse the online catalog")
		if r.code == 404 or r.code == 501:
			return _fail("unavailable", 
				"the online catalog isn't open yet — coming with map publishing")
		return _fail("unavailable", "catalog error %d" % r.code)
	var raw: Array = []
	var next: = ""
	if r.data is Dictionary:
		raw = Array(r.data.get("items", []))
		next = str(r.data.get("nextCursor", ""))
		if next == "<null>":
			next = ""
	elif r.data is Array:
		raw = r.data
	var maps: Array = []
	for e in raw:
		if e is Dictionary:
			maps.append(_normalize(e))
	if maps.is_empty():
		return {"status": "empty", "message":
			"no map matches “%s”" % query if query != ""
			else "no community map published yet", "maps": [], 
			"next_cursor": ""}
	return {"status": "ok", "message": "%d map%s" % [maps.size(), 
		"s" if maps.size() > 1 else ""], "maps": maps, "next_cursor": next}





static func _normalize(e: Dictionary) -> Dictionary:
	var mapper: = ""
	var m = e.get("mapper")
	if m is Dictionary:
		mapper = str(m.get("username", ""))
	else:
		mapper = str(m) if m != null else ""
	return {
		"id": str(e.get("id", "")), 
		"title": str(e.get("title", "untitled")), 
		"artist": str(e.get("artist", "unknown artist")), 
		"mapper": mapper, 
		"level": float(e.get("difficultyRating", 0.0)), 
		"downloads": int(e.get("downloadsCount", 0)), 
		"size_bytes": int(e.get("sizeBytes", 0)), 
		"version": int(e.get("version", 1)), 

		"status": str(e.get("status", "PUBLISHED")).to_lower(), 

		"ranking": str(e.get("ranking", "PENDING")).to_lower(), 



		"wip": bool(e.get("wip", false)), 



		"created_at": _iso(e.get("createdAt")), 
		"published_at": _iso(e.get("publishedAt")), 



		"difficulties": _diffs(e.get("difficulties")), 


		"likes": int(e.get("likesCount", 0)), 
		"liked": bool(e.get("likedByMe", false)), 
		"meloved": bool(e.get("meloved", false)), 
	}


static func _diffs(v) -> Array:
	var out: Array = []
	if v is Array:
		for d in v:
			if d is Dictionary:
				out.append({"key": str(d.get("key", "")), "level": float(d.get("level", 0.0))})
	out.sort_custom( func(a, b): return a.level < b.level)
	return out


static func _iso(v) -> String:
	if v == null:
		return ""
	var s: = str(v)
	return "" if s == "<null>" else s


static func _fail(status: String, message: String) -> Dictionary:
	return {"status": status, "message": message, "maps": [], "next_cursor": ""}
