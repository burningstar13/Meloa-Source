class_name PlayerProfile
extends RefCounted













var state: = "ready"
var error_message: = ""


var user_id: = ""
var username: = ""
var avatar_id: = "avatar_01"
var title_id: = ""
var frame_id: = "basic"
var online: = false
var playtester: = false
var member_since: = ""


var has_rank: = false
var rank: = 0
var players: = 0
var rp: = -1.0
var percentile: = -1.0
var has_rank_delta: = false
var rank_delta_week: = 0
var peak_rank: = 0
var peak_rp: = -1.0


var has_stats: = false
var play_time_sec: = -1.0
var play_count: = 0
var ranked_play_count: = 0
var maps_played: = 0
var clears: = 0
var full_combos: = 0
var s_ranks: = 0
var community_clears: = 0
var ranked_acc: = -1.0
var ranked_acc_plays: = 0
var best_acc: = -1.0
var total_score: = 0
var perfect: = 0
var good: = 0
var miss: = 0
var favorite_mode: = ""
var avg_level: = -1.0
var max_level_cleared: = -1.0


var unlocked: = {"avatar": [], "title": [], "frame": []}
var new_items: = {"avatar": [], "title": [], "frame": []}
var unlocked_at: = {}
var milestones: Array = []


var recent: Array = []
var recent_activity: Array = []


func is_unlocked(kind: String, id: String) -> bool:
	return id != "" and (unlocked.get(kind, []) as Array).has(id)


func is_new(kind: String, id: String) -> bool:
	return (new_items.get(kind, []) as Array).has(id)


func is_equipped(kind: String, id: String) -> bool:
	match kind:
		"avatar": return avatar_id == id
		"title": return title_id == id
		"frame": return frame_id == id
	return false


func equipped_id(kind: String) -> String:
	match kind:
		"avatar": return avatar_id
		"title": return title_id
		"frame": return frame_id
	return ""


func unlock(kind: String, id: String, mark_new: = true, at: = "") -> void :
	var arr: Array = unlocked.get(kind, [])
	if not arr.has(id):
		arr.append(id)
		unlocked[kind] = arr
	if mark_new:
		var n: Array = new_items.get(kind, [])
		if not n.has(id):
			n.append(id)
			new_items[kind] = n
	unlocked_at["%s:%s" % [kind, id]] = at if at != "" else Time.get_datetime_string_from_system(true)


func mark_seen(kind: String, id: String) -> void :
	var n: Array = new_items.get(kind, [])
	n.erase(id)
	new_items[kind] = n


func new_count() -> int:
	var c: = 0
	for k in new_items:
		c += (new_items[k] as Array).size()
	return c


func is_signed_in() -> bool:
	return state != "signed_out"


func has_acc() -> bool:
	return ranked_acc >= 0.0 and ranked_acc <= 100.0


func acc_tier() -> Dictionary:
	return ProfileRules.acc_tier(ranked_acc) if has_acc() else {}


func rank_tier() -> Dictionary:
	return ProfileRules.rank_tier(rank if has_rank else 0)


func title_name() -> String:
	if title_id == "":
		return ""
	return ProfileRules.item_name("title", title_id)


func duplicate_profile() -> PlayerProfile:
	var p: = PlayerProfile.new()
	for prop in get_property_list():
		var n: = String(prop.name)
		if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var v = get(n)
			p.set(n, (v as Dictionary).duplicate(true) if v is Dictionary
				else ((v as Array).duplicate(true) if v is Array else v))
	return p






static func from_dict(d: Dictionary) -> PlayerProfile:
	var p: = PlayerProfile.new()
	p.state = "ready"
	p.user_id = str(d.get("id", ""))
	p.username = str(d.get("username", ""))
	p.member_since = str(d.get("createdAt", ""))
	p.playtester = bool(d.get("playtester", false))
	var idn: Dictionary = d.get("identity", {}) if d.get("identity") is Dictionary else {}
	p.avatar_id = str(idn.get("avatarId", p.avatar_id))
	p.title_id = str(idn.get("titleId", ""))
	p.frame_id = str(idn.get("frameId", p.frame_id))
	var rk: Variant = d.get("ranking")
	if rk is Dictionary and int(rk.get("rank", 0)) > 0:
		p.has_rank = true
		p.rank = int(rk.get("rank", 0))
		p.players = int(rk.get("players", 0))
		p.rp = _num(rk.get("totalPp"), -1.0)
		p.percentile = _num(rk.get("percentile"), -1.0)
		if p.percentile < 0.0 and p.players > 0:
			p.percentile = float(p.rank) / float(p.players) * 100.0
		if rk.has("weekDelta") and rk.get("weekDelta") != null:
			p.has_rank_delta = true
			p.rank_delta_week = int(rk.get("weekDelta", 0))
		p.peak_rank = int(rk.get("peakRank", 0))
		p.peak_rp = _num(rk.get("peakPp"), -1.0)
	var st: Variant = d.get("stats")
	if st is Dictionary and not st.is_empty():
		p.has_stats = true
		p.play_time_sec = _num(st.get("playTimeSec"), -1.0)
		p.play_count = int(st.get("playCount", 0))
		p.ranked_play_count = int(st.get("rankedPlayCount", 0))
		p.maps_played = int(st.get("mapsPlayed", 0))
		p.clears = int(st.get("clears", 0))
		p.full_combos = int(st.get("fullCombos", 0))
		p.s_ranks = int(st.get("sRanks", 0))
		p.community_clears = int(st.get("communityClears", 0))
		p.ranked_acc = _num(st.get("rankedAccuracy"), -1.0)
		p.ranked_acc_plays = int(st.get("rankedAccuracyPlays", 0))
		p.best_acc = _num(st.get("bestAccuracy"), -1.0)
		p.total_score = int(st.get("totalScore", 0))
		p.perfect = int(st.get("perfect", 0))
		p.good = int(st.get("good", 0))
		p.miss = int(st.get("miss", 0))
		p.favorite_mode = str(st.get("favoriteMode", ""))
		p.avg_level = _num(st.get("avgLevel"), -1.0)
		p.max_level_cleared = _num(st.get("maxLevelCleared"), -1.0)
	var cos: Variant = d.get("cosmetics")
	if cos is Dictionary:
		for kind: String in ["avatar", "title", "frame"]:
			var key: String = kind + "s"
			for it in (cos.get(key, []) as Array):
				if it is Dictionary:
					var id: = str(it.get("id", ""))
					p.unlock(kind, id, bool(it.get("isNew", false)), str(it.get("unlockedAt", "")))
	for m in (d.get("milestones", []) as Array):
		p.milestones.append(int(m))
	for r in (d.get("recent", []) as Array):
		if r is Dictionary:
			p.recent.append({"kind": str(r.get("kind", "")), "text": str(r.get("text", "")), 
				"at": str(r.get("at", ""))})
	for r in (d.get("recentActivity", []) as Array):
		if r is Dictionary:
			p.recent_activity.append({"map": str(r.get("map", "")), "difficulty": str(r.get("difficulty", "")), 
				"accuracy": _num(r.get("accuracy"), -1.0), "grade": str(r.get("grade", "")), 
				"at": str(r.get("at", ""))})
	p._ensure_defaults()
	return p





static func from_legacy(uname: String, global_rank: Dictionary, logged: = true) -> PlayerProfile:
	var p: = PlayerProfile.new()
	p.username = uname
	if not logged:
		p.state = "signed_out"
		return p
	p.state = "partial"
	if not global_rank.is_empty() and int(global_rank.get("rank", 0)) > 0:
		p.has_rank = true
		p.rank = int(global_rank.get("rank", 0))
		p.players = int(global_rank.get("players", 0))
		p.rp = _num(global_rank.get("totalPp"), -1.0)
		if p.players > 0:
			p.percentile = float(p.rank) / float(p.players) * 100.0
		p.maps_played = int(global_rank.get("mapsPlayed", 0))
		p.milestones = ProfileRules.milestones_reached(p.rank)
	p._ensure_defaults()
	return p


static func signed_out() -> PlayerProfile:
	var p: = PlayerProfile.new()
	p.state = "signed_out"
	return p


static func loading() -> PlayerProfile:
	var p: = PlayerProfile.new()
	p.state = "loading"
	return p


static func errored(msg: String, uname: = "") -> PlayerProfile:
	var p: = PlayerProfile.new()
	p.state = "error"
	p.error_message = msg
	p.username = uname
	return p




func _ensure_defaults() -> void :
	for kind in ["avatar", "title", "frame"]:
		for it in ProfileRules.catalogue(kind):
			if String((it["unlock"] as Dictionary).get("kind", "")) == "default":
				unlock(kind, String(it["id"]), false, "")
	if not is_unlocked("avatar", avatar_id):
		avatar_id = "avatar_01"
	if not is_unlocked("frame", frame_id):
		frame_id = "basic"
	if title_id != "" and not is_unlocked("title", title_id):
		title_id = ""


static func _num(v: Variant, fallback: float) -> float:
	if v == null:
		return fallback
	if v is float or v is int:
		var f: = float(v)
		return fallback if is_nan(f) or is_inf(f) else f
	if v is String and (v as String).is_valid_float():
		return float(v)
	return fallback
