extends RefCounted








const BUILTIN_DIR: = "res://tracks/fx"



static func dir_for(track: String) -> String:
	if track != "" and MapLibrary.is_user_map(track):
		return MapLibrary.map_dir(track)
	return BUILTIN_DIR




static func load_texture(dir: String, file: String) -> Texture2D:
	if dir == "" or file == "" or file.contains("/") or file.contains("\\")\
	or file.contains(".."):
		return null
	var path: = "%s/%s" % [dir, file]
	if path.begins_with("res://"):
		if ResourceLoader.exists(path):
			var res = load(path)
			return res if res is Texture2D else null
		return null
	if not FileAccess.file_exists(path):
		return null
	var img: = Image.new()
	if img.load(path) != OK:
		return null
	return ImageTexture.create_from_image(img)






static func frame_of(ev: Dictionary, el: float) -> Dictionary:
	var frames: = int(ev.get("frames", 1))
	if frames <= 1:
		return {"idx": 0, "sheet": 0}
	var idx: = 0
	var delays = ev.get("delays", null)
	if delays is Array and (delays as Array).size() == frames:
		var total: = 0.0
		for d in delays:
			total += float(d)
		var tt: = fposmod(maxf(el, 0.0), maxf(total, 0.001))
		var acc: = 0.0
		idx = frames - 1
		for i in frames:
			acc += float(delays[i])
			if tt < acc:
				idx = i
				break
	else:
		var fps: = maxf(float(ev.get("fps", 10.0)), 0.1)
		idx = int(floor(maxf(el, 0.0) * fps)) % frames
	var per: = maxi(int(ev.get("per", frames)), 1)
	return {"idx": idx, "sheet": floori(float(idx) / float(per))}



static func sheet_file(ev: Dictionary, sheet: int) -> String:
	var f: = String(ev.get("file", ""))
	if sheet <= 0 or f == "":
		return f
	return "%s_%d.%s" % [f.get_basename(), sheet + 1, f.get_extension()]




static func region_of(ev: Dictionary, tex: Texture2D, idx: int) -> Dictionary:
	var full: = Rect2(Vector2.ZERO, tex.get_size())
	var frames: = int(ev.get("frames", 1))
	if frames <= 1:
		return {"region": full, "size": full.size}
	var cols: = maxi(int(ev.get("cols", 1)), 1)
	var per: = maxi(int(ev.get("per", frames)), 1)
	var local: = idx % per
	var cw: = float(ev.get("cw", full.size.x / float(cols)))
	var ch: = float(ev.get("ch", cw))
	return {
		"region": Rect2(Vector2(float(local % cols) * cw, 
			floorf(float(local) / float(cols)) * ch), Vector2(cw, ch)), 
		"size": Vector2(cw, ch), 
	}
