class_name Sfx
extends Node




const PACKS: = {
	"OSU": "res://sfx/osu", 
}

const EVENTS: = [
	"parry_perfect", 
	"parry_good", 
	"click_perfect", 
	"click_good", 
	"dodge", 
	"miss", 
]




const UI_EVENTS: = {
	"hover": -16.0, 
	"click": -8.0, 
	"back": -9.0, 




	"impact": -4.0, 
	"ignite": -3.0, 
	"count_tick": -7.0, 
	"count_go": -4.0, 
	"menu_open": -6.0, 
	"menu_play": -4.0, 
}

var volume_db_base: = -6.0
var current_pack: = "OSU"

var _players: = {}
var _ui_players: = {}


func _ready() -> void :


	for key in EVENTS:
		var p: = AudioStreamPlayer.new()
		p.max_polyphony = 4
		p.bus = "SFX"
		add_child(p)
		_players[key] = p

	if PACKS.has(SettingsManager.sfx_pack):
		current_pack = SettingsManager.sfx_pack
	set_pack(current_pack)
	for key in UI_EVENTS:
		var p: = AudioStreamPlayer.new()
		p.max_polyphony = 3
		p.bus = "SFX"
		var path: = "res://sfx/ui/%s.wav" % key
		if ResourceLoader.exists(path):
			p.stream = load(path)
		add_child(p)
		_ui_players[key] = p





const EVENT_FILES: = {
	"parry_perfect": "parry_perfect", "parry_good": "parry_perfect", 
	"click_perfect": "click_perfect", "click_good": "click_perfect", 
	"dodge": "dodge", "miss": "miss", 
}




const USER_HITSOUNDS_DIR: = "user://hitsounds"






func set_pack(pack: String) -> void :
	current_pack = pack
	for key in EVENTS:

		var stream: AudioStream = Skins.hit_stream(key)
		if stream == null:
			stream = Skins.hit_stream(EVENT_FILES[key])
		if stream == null:
			stream = _user_stream(EVENT_FILES[key])
		if stream == null:
			for ext in ["wav", "mp3"]:
				var path: String = PACKS[pack] + "/" + EVENT_FILES[key] + "." + ext
				if ResourceLoader.exists(path):
					stream = load(path)
					break
		if stream != null:
			_players[key].stream = stream



func _user_stream(event_file: String) -> AudioStream:
	var wav_p: = USER_HITSOUNDS_DIR + "/" + event_file + ".wav"
	if FileAccess.file_exists(wav_p):
		var s: = AudioStreamWAV.load_from_file(wav_p)
		if s != null:
			return s
	var mp3_p: = USER_HITSOUNDS_DIR + "/" + event_file + ".mp3"
	if FileAccess.file_exists(mp3_p):
		var m: = AudioStreamMP3.new()
		m.data = FileAccess.get_file_as_bytes(mp3_p)
		if m.data.size() > 0:
			return m
	return null


func play_sfx(key: String) -> void :
	var p: AudioStreamPlayer = _players[key]
	p.volume_db = volume_db_base
	p.play()




var _skin_players: = {}

func play_skin(event: String) -> void :
	var stream: AudioStream = Skins.hit_stream(event)
	if stream == null:
		return
	var p: AudioStreamPlayer = _skin_players.get(event)
	if p == null:
		p = AudioStreamPlayer.new()
		p.max_polyphony = 4
		p.bus = "SFX"
		add_child(p)
		_skin_players[event] = p
	if p.stream != stream:
		p.stream = stream
	p.volume_db = volume_db_base
	p.play()




func play_ui(key: String) -> void :
	if not _ui_players.has(key):
		return
	var p: AudioStreamPlayer = _ui_players[key]
	if p.stream == null:
		return
	p.volume_db = volume_db_base + UI_EVENTS[key]
	p.play()
