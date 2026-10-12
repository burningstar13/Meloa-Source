class_name Tuning
extends Node


















const TRACKS_SHIPPED: = {
	"EXTRA MODE": {"impossible": "res://charts/extra_mode_impossible.json"}, 
	"BYE BYE": {
		"easy": "res://charts/byebye_easy.json", 
		"normal": "res://charts/byebye_normal.json", 
		"impossible": "res://charts/byebye_impossible.json", 
	}, 
	"SAYONARA": {
		"easy": "res://charts/sayonara_easy.json", 
		"impossible": "res://charts/sayonara_impossible.json", 
	}, 
	"GALAXY COLLAPSE": {"impossible": "res://charts/galaxy_impossible.json"}, 
	"DEEP SEA": {"impossible": "res://charts/deepsea_impossible.json"}, 
	"SHIAWASE": {
		"easy": "res://charts/shiawase_easy.json", 
		"normal": "res://charts/shiawase_normal.json", 
		"impossible": "res://charts/shiawase_impossible.json", 
	}, 
	"JUST DANCE": {"impossible": "res://charts/justdance_impossible.json"}, 
	"YOUNG GIRL A": {"impossible": "res://charts/shoujoa_impossible.json"}, 
	"DEAR YOU": {
		"easy": "res://charts/dearyou_easy.json", 
		"impossible": "res://charts/dearyou_impossible.json", 
	}, 
	"YARARARA": {"impossible": "res://charts/yararara_impossible.json"}, 
	"RENAI CIRCULATION": {"impossible": "res://charts/renai_impossible.json"}, 
	"CARAMELL XMAS": {
		"easy": "res://charts/caramell_xmas_easy.json", 
		"impossible": "res://charts/caramell_xmas_impossible.json", 
	}, 
	"KAILI": {"impossible": "res://charts/kaili_impossible.json"}, 



	"FREEDOM DIVE": {"impossible": "res://charts/freedomdive_impossible.json"}, 


	"AUGMENTED TENACITY": {"impossible": "res://charts/augmented_impossible.json"}, 
	"CHOCOLATE SCRAMBLE": {"impossible": "res://charts/chocolate_impossible.json"}, 




	"LOOPING THE ROOMS": {"impossible": "res://charts/looping_impossible.json"}, 




	"INTERNET YAMERO": {"impossible": "res://charts/yamero_impossible.json"}, 






	"RAVENATIC": {"easy": "res://charts/ravenatic_easy.json"}, 







	"ENTANGLE NIGHT": {"corrupt": "res://charts/entangle_corrupt.json"}, 




	"BOOKMAKER": {"corrupt": "res://charts/bookmaker_corrupt.json"}, 







}










const DEV_TRACKS: = {
	"INTO THE FLOW": {"normal": "res://charts/into_the_flow_normal.json"}, 
}
const DEV_FEATURED: = ["INTO THE FLOW"]





const FEATURED_SHIPPED: = [
	"KAILI", 
	"AUGMENTED TENACITY", 
	"RAVENATIC", 
]




static func dev_maps_enabled() -> bool:
	return OS.has_feature("editor")\
	and not OS.get_cmdline_user_args().has("--no-dev-maps")



static func is_dev_track(track: String) -> bool:
	return DEV_TRACKS.has(track)


static func _runtime_tracks() -> Dictionary:
	var out: Dictionary = TRACKS_SHIPPED.duplicate()
	if dev_maps_enabled():
		for t in DEV_TRACKS:
			out[t] = DEV_TRACKS[t]
	return out


static func _runtime_featured() -> Array:
	var out: Array = FEATURED_SHIPPED.duplicate()
	if dev_maps_enabled():
		out.append_array(DEV_FEATURED)
	return out






static var TRACKS: Dictionary = _runtime_tracks()
static var FEATURED: Array = _runtime_featured()

var current_track: = "KAILI"
var current_diff: = "impossible"
var chart_path: String = TRACKS["KAILI"]["impossible"]





func chart_for(track: String, diff: String) -> String:
	return MapLibrary.chart_for(track, diff)

@export_group("Synchro")



@export var global_offset_ms: = -40.0

@export_group("Jugement (fenêtres de timing)")
@export var perfect_window_ms: = 50.0
@export var good_window_ms: = 120.0




@export var meh_window_ms: = 160.0






@export var early_miss_window_ms: = 0.0

@export_group("Descente des notes")



@export var travel_time: = 0.6


@export var kiai_velocity_mult: = 1.12

@export var click_approach_time: = 0.55
@export var click_ring_start_radius: = 175.0
@export var click_hit_radius: = 58.0

@export_group("Rendu des cibles (style flat, skin CLEAN)")




@export var note_outline_width: = 7.0
@export var note_ring_width: = 3.0
@export var note_fill_alpha: = 0.76
@export var note_center_dot: = 3.0
@export var approach_width: = 3.0
@export var approach_alpha: = 0.55
@export var approach_ease: = 1.0
@export var slider_outline_width: = 6.0
@export var slider_body_alpha: = 0.32
@export var future_dim: = 0.16
@export var hit_anim_time: = 0.14
@export var hit_flash: = 0.8
@export var max_fx_alive: = 6
@export var show_order_numbers: = true
@export var order_reset_gap: = 1.0

@export_group("Juice")
@export var shockwave_duration: = 0.3
@export var shockwave_radius_perfect: = 240.0
@export var shockwave_radius_good: = 110.0
@export var player_flash_duration: = 0.18
@export var shake_miss_intensity: = 6.0

@export var shake_decay: = 10.0

@export_group("Sliders")


@export var sliderg_approach_time: = 0.6



@export var slider_rail_tolerance: = 140.0


@export var slider_rail_width: = 6.0


@export var slider_hold_window_ms: = 150.0

@export var slider_tick: = 0.25


@export var slider_grace: = 0.25




@export var slider_end_lenience: = 0.15


@export var slider_perfect_ratio: = 0.75
@export var slider_good_ratio: = 0.45


@export var slider_off_rail_max: = 0.6

@export_group("Volumes")



@export var music_volume_db: = -2.0
@export var sfx_volume_db: = 0.0

@export_group("Mode auto")


@export var auto_cursor_speed: = 15000.0

@export_group("Layout")
@export var lane_width: = 150.0
@export var lane_gap: = 30.0

@export var hit_y: = 600.0

@export var spawn_y: = -60.0

@export_group("Vie (barre façon osu)")



@export var hp_max: = 100.0
@export var hp_miss_parry: = 14.0
@export var hp_miss_click: = 10.0
@export var hp_miss_dodge: = 6.0
@export var hp_miss_hold: = 12.0
@export var hp_regen_perfect: = 2.6
@export var hp_regen_good: = 1.2
@export var hp_regen_dodge: = 0.0
@export var hp_regen_tick: = 0.3

@export var hp_streak_bonus: = 1.0


func apply_track(name: String, diff: String = "") -> void :
	current_track = name
	if diff != "":
		current_diff = diff

	var diffs: Dictionary = MapLibrary.diffs_of(current_track)
	if not diffs.is_empty() and not diffs.has(current_diff):
		current_diff = String(diffs.keys()[diffs.size() - 1])
	chart_path = chart_for(current_track, current_diff)


func perfect_s() -> float:
	return perfect_window_ms / 1000.0


func good_s() -> float:
	return good_window_ms / 1000.0



func meh_enabled() -> bool:
	return meh_window_ms > good_window_ms


func meh_s() -> float:
	return meh_window_ms / 1000.0




func last_window_ms() -> float:
	return meh_window_ms if meh_enabled() else good_window_ms


func last_s() -> float:
	return last_window_ms() / 1000.0


func early_miss_s() -> float:
	return early_miss_window_ms / 1000.0




func tier_for_delta(d_abs: float) -> String:
	if d_abs <= perfect_s():
		return "PERFECT"
	if d_abs <= good_s():
		return "GOOD"
	if meh_enabled() and d_abs <= meh_s():
		return "MEH"
	return ""
