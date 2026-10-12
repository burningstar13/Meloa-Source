class_name RunResult
extends RefCounted





enum RankingStatus{
	LOADING, 
	READY, 
	EMPTY, 
	OFFLINE, 
	ERROR, 
	LOCAL_MAP, 
	SIGNED_OUT, 
	SUBMITTING, 
	REJECTED, 
}


var map_id: = ""
var map_title: = ""
var map_artist: = ""
var cover: Texture2D = null
var difficulty_id: = ""
var difficulty_name: = ""
var difficulty_level: = -1.0
var difficulty_color: = Color(0.55, 0.32, 1.0)
var mode_key: = "STANDARD"
var mode_name: = "FLOW"
var mods: Array = []
var mods_summary: = ""
var mods_ranked: = true
var local_map: = false
var assisted: = false
var cleared: = true
var status_text: = "CLEARED"


var score: = 0
var accuracy: = 0.0
var grade: = "D"
var grade_color: = Color(1.0, 0.4, 0.42)
var perfect: = 0
var good: = 0
var meh: = 0
var miss: = 0
var max_combo: = 0
var judged: = 0
var full_combo: = false
var previous_best: = 0
var new_record: = false
var ranked: = true


var ranking_status: = RankingStatus.LOADING
var ranking_message: = ""
var entries: Array = []
var player_rank: = -1
var player_entry: = {}
var rank_delta_text: = ""
var rank_delta_color: = Color(1, 1, 1, 0.5)


var player_name: = ""
var signed_in: = false
var global_rank: = 0
var global_players: = 0
var account_state: = "loading"


static func entry(rank: int, username: String, acc: float, combo: int, 
		score_v: int) -> Dictionary:
	return {"rank": rank, "username": username, "accuracy": acc, 
		"maxCombo": combo, "score": score_v}


func has_previous_best() -> bool:
	return previous_best > 0



func score_ratio() -> float:
	var ref: = maxi(previous_best, score)
	return clampf(float(score) / float(maxi(ref, 1)), 0.0, 1.0)



func best_ratio() -> float:
	if previous_best <= 0:
		return -1.0
	var ref: = maxi(previous_best, score)
	return clampf(float(previous_best) / float(maxi(ref, 1)), 0.0, 1.0)
