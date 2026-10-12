class_name Conductor
extends AudioStreamPlayer








var song_offset: = 0.0


var _cached_latency: = 0.0







var _sm_t: = 0.0
var _sm_us: = 0
var _sm_valid: = false








var _lead_active: = false
var _lead_from: = 0.0
var _lead_total: = 0.0
var _lead_elapsed: = 0.0



func play_with_lead(from: float, lead: float) -> void :
	_sm_valid = false
	if lead <= 0.02:
		_lead_active = false
		play(from)
		return
	_lead_active = true
	_lead_from = from
	_lead_total = lead
	_lead_elapsed = 0.0


func cancel_lead() -> void :
	_lead_active = false


func in_lead() -> bool:
	return _lead_active and not playing



func tick_lead(delta: float) -> void :
	if not _lead_active:
		return
	if playing:
		_lead_active = false
		return
	_lead_elapsed += delta
	if _lead_elapsed >= _lead_total:
		_lead_active = false
		_sm_valid = false
		play(_lead_from)


func _ready() -> void :
	_cached_latency = AudioServer.get_output_latency()



func get_song_time() -> float:
	if not playing:
		_sm_valid = false
		if _lead_active:

			return _lead_from + song_offset - (_lead_total - _lead_elapsed)

		return -1000.0



	var since_mix: = minf(AudioServer.get_time_since_last_mix(), 0.1)
	var raw: = get_playback_position() + since_mix - _cached_latency + song_offset
	if stream_paused:
		_sm_valid = false
		return raw
	var now: = Time.get_ticks_usec()
	if not _sm_valid:
		_sm_t = raw
		_sm_us = now
		_sm_valid = true
		return raw
	var est: = _sm_t + float(now - _sm_us) / 1000000.0 * pitch_scale
	var err: = raw - est
	if absf(err) > 0.08:
		est = raw
	else:
		est += err * 0.08
	_sm_t = est
	_sm_us = now
	return est
