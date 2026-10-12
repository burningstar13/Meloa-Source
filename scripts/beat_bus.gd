class_name BeatBus
extends Node
const Spectrum = preload("res://scripts/spectrum.gd")
















signal beat(index: int)
signal strong_beat(index: int)

const IDLE_BPM: = 120.0
const BEATS_PER_BAR: = 4



const BANDS: = 24

var main

var bands: = PackedFloat32Array()


var bass: = 0.0
var mid: = 0.0
var high: = 0.0

var _last_beat: = -99999
var _spec_frame: = -100


func _ready() -> void :
	bands.resize(BANDS)


func bpm() -> float:
	if main != null and main.conductor.playing:
		return maxf(40.0, main.chart_bpm)
	return IDLE_BPM




func beats() -> float:
	if main != null and main.conductor.playing:
		var t: float = main.conductor.get_song_time()
		if t > 0.0:
			return t * maxf(40.0, main.chart_bpm) / 60.0
	return Time.get_ticks_msec() / 1000.0 * (IDLE_BPM / 60.0)



func strength() -> float:
	return SettingsManager.menu_fx_intensity


func _process(_delta: float) -> void :
	var bi: = int(floor(beats()))
	if bi != _last_beat:


		_last_beat = bi
		beat.emit(bi)
		if posmod(bi, BEATS_PER_BAR) == 0:
			strong_beat.emit(bi)
	_refresh_bands()




func _refresh_bands() -> void :
	if main == null or main.spectrum == null:
		return
	if main.screen == main.Screen.PLAYING:
		return
	var f: = Engine.get_process_frames()
	if f - _spec_frame < 3:
		return
	_spec_frame = f


	var lo: = 0.0
	var md: = 0.0
	var hi: = 0.0
	for i in BANDS:
		var f0: = 55.0 * pow(12000.0 / 55.0, float(i) / BANDS)
		var f1: = 55.0 * pow(12000.0 / 55.0, float(i + 1) / BANDS)
		var v: = _fold(bands[i], _level(f0, f1))
		bands[i] = v
		if i < 4:
			lo = maxf(lo, v)
		elif i < 14:
			md = maxf(md, v)
		else:
			hi = maxf(hi, v)
	bass = lo
	mid = md
	high = hi




func band(i: int) -> float:
	if bands.is_empty():
		return 0.0
	return bands[posmod(i, bands.size())]


func _fold(prev: float, now: float) -> float:
	return maxf(now, lerpf(prev, now, 0.22))


func _level(f0: float, f1: float) -> float:
	return Spectrum.level(f0, f1)
