class_name MapImageCache
extends RefCounted



























const COVER_MAX: = 512

const BG_MAX: = {"VERYLOW": 854, "LOW": 1280, "MID": 1600, "FULL": 1920}



const MAX_PIXELS: = 64 * 1024 * 1024 / 4

const COVER_BUDGET_MB: = 48.0

const THUMB_DIR: = "user://cache/thumbs"


var kind: = "cover"

var _src: = {}
var _tex: = {}
var _bytes: = {}
var _lru: = []
var _pending: = {}
var _ready_img: = {}
var _res_pending: = {}




var _img_mutex: = Mutex.new()
var _failed: = {}





var _arrived: Array = []
var _bg_max: = 1920


var placeholder: Texture2D = null


func _init(k: = "cover") -> void :
	kind = k


func set_quality(level: String) -> void :
	_bg_max = int(BG_MAX.get(level, 1920))







func register(track: String, path: String) -> void :
	_src[track] = path


func register_resource(track: String, res: Texture2D) -> void :
	_tex[track] = res
	_bytes[track] = 0.0


func has(track: String) -> bool:
	return _tex.has(track) or _src.has(track)


func clear() -> void :
	_src.clear()
	_tex.clear()
	_bytes.clear()
	_lru.clear()
	_failed.clear()
	_arrived.clear()


	for id in _pending.values():
		if WorkerThreadPool.is_task_completed(id):
			continue
		WorkerThreadPool.wait_for_task_completion(id)
	_pending.clear()
	_res_pending.clear()
	_img_mutex.lock()
	_ready_img.clear()
	_img_mutex.unlock()





func tex(track: String, default: Variant = null) -> Variant:
	if _tex.has(track):
		_touch(track)
		return _tex[track]
	if not _src.has(track) or _failed.has(track):
		return default
	var src: = String(_src[track])





	if src.begins_with("res://"):
		if not _res_pending.has(track):
			_res_pending[track] = true
			ResourceLoader.load_threaded_request(src)
		return placeholder if placeholder != null else default





	_queue(track)
	return placeholder if placeholder != null else default




func poll() -> void :

	for track in _res_pending.keys():
		var src: = String(_src.get(track, ""))
		if src == "":
			_res_pending.erase(track)
			continue
		var st: = ResourceLoader.load_threaded_get_status(src)
		if st == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			continue
		_res_pending.erase(track)
		var r: Variant = null
		if st == ResourceLoader.THREAD_LOAD_LOADED:
			r = ResourceLoader.load_threaded_get(src)
		if r is Texture2D:
			_store(track, r)
			_bytes[track] = 0.0
		else:
			_failed[track] = true
	if _pending.is_empty():
		return
	for track in _pending.keys():
		if not WorkerThreadPool.is_task_completed(_pending[track]):
			continue
		WorkerThreadPool.wait_for_task_completion(_pending[track])
		_pending.erase(track)


		_img_mutex.lock()
		var img: Image = _ready_img.get(track)
		_ready_img.erase(track)
		_img_mutex.unlock()
		if img != null and img.get_width() > 0:
			_store(track, ImageTexture.create_from_image(img))
		else:
			_failed[track] = true





func take_arrived() -> Array:
	if _arrived.is_empty():
		return _arrived
	var out: = _arrived
	_arrived = []
	return out




func _touch(track: String) -> void :
	var i: = _lru.find(track)
	if i >= 0:
		_lru.remove_at(i)
	_lru.append(track)


func _store(track: String, tex: Texture2D) -> void :
	if not _tex.has(track):
		_arrived.append(track)
	_tex[track] = tex
	_bytes[track] = tex.get_width() * tex.get_height() * 4.0 / 1048576.0
	_touch(track)
	_evict()




func _evict() -> void :
	if kind == "bg":
		while _lru.size() > 1:
			var old: String = _lru.pop_front()
			_tex.erase(old)
			_bytes.erase(old)
		return
	var total: = 0.0
	for v in _bytes.values():
		total += v
	while total > COVER_BUDGET_MB and _lru.size() > 1:
		var old: String = _lru.pop_front()
		total -= float(_bytes.get(old, 0.0))
		_tex.erase(old)
		_bytes.erase(old)


func _max_side() -> int:
	return _bg_max if kind == "bg" else COVER_MAX




func _thumb_path(track: String) -> String:
	var src: = String(_src.get(track, ""))
	if src == "":
		return ""
	var abs: = ProjectSettings.globalize_path(src)
	var mtime: = FileAccess.get_modified_time(src)
	var key: = "%s|%d|%d|%s" % [abs, mtime, _max_side(), kind]
	return "%s/%s.png" % [THUMB_DIR, key.sha256_text().substr(0, 24)]


func _queue(track: String) -> void :
	if _pending.has(track):
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(THUMB_DIR))
	var src: = String(_src.get(track, ""))
	var dst: = _thumb_path(track)
	var side: = _max_side()
	_pending[track] = WorkerThreadPool.add_task(
		func() -> void :
			var made: = _thumb_image(src, dst, side)
			_img_mutex.lock()
			_ready_img[track] = made
			_img_mutex.unlock(), 
		false, "miniature de map")





static func _thumb_image(src: String, dst: String, side: int) -> Image:


	if FileAccess.file_exists(dst):
		var cached: = Image.new()
		if cached.load(dst) == OK:
			return cached
		DirAccess.remove_absolute(ProjectSettings.globalize_path(dst))
	var img: = Image.new()
	if img.load(src) != OK:
		return null
	if img.get_width() * img.get_height() > MAX_PIXELS:
		push_warning("image de map démesurée (%dx%d), ignorée : %s"
			%[img.get_width(), img.get_height(), src])
		return null
	var w: = img.get_width()
	var h: = img.get_height()
	var m: = maxi(w, h)
	if m > side:
		var k: = float(side) / float(m)
		img.resize(maxi(int(w * k), 1), maxi(int(h * k), 1), Image.INTERPOLATE_LANCZOS)


	img.save_png(dst)
	return img
