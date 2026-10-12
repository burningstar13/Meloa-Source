extends RefCounted






















const BUCKETS_PER_SEC: = 300.0



const FRAME_BUDGET_US: = 5000


const CHUNK: = 8192



const SKIP: = 4
const DIR: = "user://peaks"
const MAGIC: = "SPK1"




static func fingerprint(path: String) -> String:
	if path == "":
		return ""
	var md5: = FileAccess.get_md5(path)
	if md5 != "":
		return md5



	return path.md5_text()


static func cache_path(print_: String) -> String:
	return "%s/%s.peaks" % [DIR, print_]




static func load_cached(print_: String) -> PackedFloat32Array:
	if print_ == "":
		return PackedFloat32Array()
	var f: = FileAccess.open(cache_path(print_), FileAccess.READ)
	if f == null:
		return PackedFloat32Array()
	if f.get_buffer(4).get_string_from_ascii() != MAGIC:
		return PackedFloat32Array()
	var n: = f.get_32()
	if n <= 0 or n > 20000000:
		return PackedFloat32Array()
	var out: = f.get_buffer(n * 4).to_float32_array()
	f.close()
	return out if out.size() == n else PackedFloat32Array()


static func save_cached(print_: String, peaks: PackedFloat32Array) -> void :
	if print_ == "" or peaks.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(DIR)
	var f: = FileAccess.open(cache_path(print_), FileAccess.WRITE)
	if f == null:
		return
	f.store_buffer(MAGIC.to_ascii_buffer())
	f.store_32(peaks.size())
	f.store_buffer(peaks.to_byte_array())
	f.close()







class Scan extends RefCounted:
	var peaks: = PackedFloat32Array()
	var done: = false
	var progress: = 0.0
	var _pb: AudioStreamPlayback
	var _rate: = 44100.0
	var _bucket_frames: = 147.0
	var _idx: = 0
	var _acc: = 0.0
	var _acc_n: = 0.0



	var print_: = ""

	func _init(stream: AudioStream, fp: String) -> void :
		print_ = fp
		var length: = stream.get_length() if stream != null else 0.0
		if stream == null or length <= 0.05:
			done = true
			return
		_pb = stream.instantiate_playback()
		if _pb == null or not _pb.has_method("mix_audio"):

			done = true
			return
		_rate = maxf(AudioServer.get_mix_rate(), 8000.0)
		_bucket_frames = _rate / BUCKETS_PER_SEC
		peaks.resize(maxi(int(ceil(length * BUCKETS_PER_SEC)), 1))
		peaks.fill(0.0)
		_pb.start(0.0)


	func step() -> bool:
		if done:
			return true
		var until: = Time.get_ticks_usec() + FRAME_BUDGET_US
		while Time.get_ticks_usec() < until:
			var buf: PackedVector2Array = _pb.mix_audio(1.0, CHUNK)
			if buf.is_empty():
				return _finish()
			var n: = buf.size()
			var i: = 0
			while i < n:
				var v: Vector2 = buf[i]
				var amp: float = maxf(absf(v.x), absf(v.y))
				if amp > _acc:
					_acc = amp
				_acc_n += float(SKIP)
				if _acc_n >= _bucket_frames:
					if _idx < peaks.size():
						peaks[_idx] = minf(_acc, 1.0)
					_idx += 1
					_acc = 0.0
					_acc_n -= _bucket_frames
					if _idx >= peaks.size():
						return _finish()
				i += SKIP
			progress = float(_idx) / float(maxi(peaks.size(), 1))
			if not _pb.is_playing():
				return _finish()
		return false

	func _finish() -> bool:
		if _idx < peaks.size() and _acc > 0.0:
			peaks[_idx] = minf(_acc, 1.0)
		done = true
		progress = 1.0
		if _pb != null:
			_pb.stop()
		return true






static func begin(stream: AudioStream, audio_path: String) -> Dictionary:
	var fp: = fingerprint(audio_path)
	var cached: = load_cached(fp)
	if not cached.is_empty():
		return {"peaks": cached, "scan": null}
	var scan: = Scan.new(stream, fp)
	return {"peaks": scan.peaks, "scan": null if scan.done else scan}



static func at(peaks: PackedFloat32Array, tt: float) -> float:
	if peaks.is_empty():
		return 0.0
	var i: = int(tt * BUCKETS_PER_SEC)
	if i < 0 or i >= peaks.size():
		return 0.0
	return peaks[i]






static func peak_between(peaks: PackedFloat32Array, t0: float, t1: float) -> float:
	if peaks.is_empty():
		return 0.0
	var a: = int(minf(t0, t1) * BUCKETS_PER_SEC)
	var b: = int(maxf(t0, t1) * BUCKETS_PER_SEC)
	a = clampi(a, 0, peaks.size() - 1)
	b = clampi(b, a, peaks.size() - 1)
	var out: = 0.0
	for i in range(a, b + 1):
		if peaks[i] > out:
			out = peaks[i]
	return out
