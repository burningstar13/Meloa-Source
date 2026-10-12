extends RefCounted

































const HZ: = 30.0


static var analyzer: AudioEffectSpectrumAnalyzerInstance = null

static var _cache: = {}
static var _tick: = 0
static var _tick_us: = 0



static var dbg_asked: = 0
static var dbg_fft: = 0




static func tick() -> int:
	var now: = Time.get_ticks_usec()
	if now - _tick_us >= int(1000000.0 / HZ):
		_tick_us = now
		_tick += 1
		_cache.clear()
	return _tick






static func level(f0: float, f1: float) -> float:
	dbg_asked += 1
	if analyzer == null:
		return 0.0
	tick()
	var key: = Vector2(f0, f1)
	var hit: Variant = _cache.get(key)
	if hit != null:
		return float(hit)
	dbg_fft += 1
	var mag: float = analyzer.get_magnitude_for_frequency_range(f0, f1).length()
	var lvl: = clampf((60.0 + linear_to_db(maxf(mag, 1e-05))) / 60.0, 0.0, 1.0)
	_cache[key] = lvl
	return lvl




static func reset() -> void :
	_cache.clear()
	_tick_us = 0
