class_name ProfileMockData
extends RefCounted











const PROFILES: = ["newcomer", "normal", "advanced", "benson", "elite"]
const STATES: = ["loading", "error", "signed_out", "partial"]


static func build(key: String) -> PlayerProfile:
	match key:
		"newcomer": return _newcomer()
		"normal": return _normal()
		"advanced": return _advanced()
		"elite": return _elite()
		"loading": return PlayerProfile.loading()
		"error": return PlayerProfile.errored("server unreachable", "benson")
		"signed_out": return PlayerProfile.signed_out()
		"partial":

			return PlayerProfile.from_legacy("benson", 
				{"rank": 8, "players": 641, "totalPp": 1377.0, "mapsPlayed": 61})
	return _benson()


static func _base(uname: String) -> PlayerProfile:
	var p: = PlayerProfile.new()
	p.state = "ready"
	p.user_id = "mock_" + uname
	p.username = uname
	p.online = true
	p.member_since = "2026-08-20T18:00:00Z"
	p.has_stats = true
	return p




static func _newcomer() -> PlayerProfile:
	var p: = _base("newbeat")
	p.member_since = "2026-09-06T09:00:00Z"
	p.play_time_sec = 0.0
	p._ensure_defaults()
	return p



static func _normal() -> PlayerProfile:
	var p: = _base("mira_k")
	p.has_rank = true
	p.rank = 412
	p.players = 641
	p.rp = 214.0
	p.percentile = 64.3
	p.has_rank_delta = true
	p.rank_delta_week = 12
	p.peak_rank = 398
	p.peak_rp = 214.0
	p.play_time_sec = 3.4 * 3600.0
	p.play_count = 54
	p.ranked_play_count = 31
	p.maps_played = 14
	p.clears = 19
	p.full_combos = 2
	p.s_ranks = 1
	p.community_clears = 2
	p.ranked_acc = 86.42
	p.ranked_acc_plays = 19
	p.best_acc = 96.1
	p.total_score = 11820450
	p.perfect = 6120
	p.good = 1480
	p.miss = 612
	p.favorite_mode = "FLOW"
	p.avg_level = 4.6
	p.max_level_cleared = 7.2
	p.milestones = ProfileRules.milestones_reached(p.rank)
	p.avatar_id = "avatar_02"
	p.title_id = "first_beat"
	p.frame_id = "gold"
	for a in ["avatar_02", "avatar_03"]:
		p.unlock("avatar", a, a == "avatar_03", "2026-09-01T20:00:00Z")
	for t in ["first_beat", "playtester"]:
		p.unlock("title", t, false, "2026-08-22T20:00:00Z")
	for f in ["silver", "gold", "playtester"]:
		p.unlock("frame", f, false, "2026-08-25T20:00:00Z")
	p.playtester = true
	p.recent = [
		{"kind": "peak", "text": "NEW PEAK #398", "at": "2026-09-04T21:10:00Z"}, 
		{"kind": "acc", "text": "BEST ACC 96.10%", "at": "2026-09-02T19:00:00Z"}, 
	]
	p.recent_activity = _activity(["RAVENATIC", "KAILI", "BYEBYE", "SAYONARA"], [91.2, 88.4, 84.9, 93.0])
	p._ensure_defaults()
	return p



static func _advanced() -> PlayerProfile:
	var p: = _base("sunqiuu")
	p.has_rank = true
	p.rank = 47
	p.players = 641
	p.rp = 812.0
	p.percentile = 7.3
	p.has_rank_delta = true
	p.rank_delta_week = -2
	p.peak_rank = 41
	p.peak_rp = 826.0
	p.play_time_sec = 19.5 * 3600.0
	p.play_count = 402
	p.ranked_play_count = 260
	p.maps_played = 38
	p.clears = 118
	p.full_combos = 11
	p.s_ranks = 9
	p.community_clears = 12
	p.ranked_acc = 91.75
	p.ranked_acc_plays = 38
	p.best_acc = 99.02
	p.total_score = 96310200
	p.perfect = 61400
	p.good = 9820
	p.miss = 2130
	p.favorite_mode = "FLOW"
	p.avg_level = 8.1
	p.max_level_cleared = 12.4
	p.milestones = ProfileRules.milestones_reached(p.rank)
	p.avatar_id = "avatar_05"
	p.title_id = "full_combo_hunter"
	p.frame_id = "emerald"
	p.playtester = true
	for t in ["first_beat", "playtester", "full_combo_hunter", "community_pioneer", "top_100"]:
		p.unlock("title", t, false, "2026-08-28T20:00:00Z")
	for f in ["silver", "gold", "emerald", "playtester"]:
		p.unlock("frame", f, false, "2026-08-28T20:00:00Z")
	for a in ["avatar_02", "avatar_03", "avatar_04", "avatar_05", "avatar_06"]:
		p.unlock("avatar", a, a == "avatar_06", "2026-09-05T20:00:00Z")
	p.recent = [
		{"kind": "unlock", "text": "AVATAR VI UNLOCKED", "at": "2026-09-05T20:00:00Z"}, 
		{"kind": "fc", "text": "2 NEW FCs", "at": "2026-09-03T20:00:00Z"}, 
		{"kind": "acc", "text": "BEST ACC 99.02%", "at": "2026-08-30T20:00:00Z"}, 
	]
	p.recent_activity = _activity(["ENTANGLE NIGHT", "BOOKMAKER", "KAILI", "AUGMENTED TENACITY", "RAVENATIC"], 
		[93.1, 89.8, 95.6, 97.2, 98.4])
	p._ensure_defaults()
	return p




static func _benson() -> PlayerProfile:
	var p: = _base("benson")
	p.has_rank = true
	p.rank = 8
	p.players = 641
	p.rp = 1377.0
	p.percentile = 1.2
	p.has_rank_delta = true
	p.rank_delta_week = 4
	p.peak_rank = 8
	p.peak_rp = 1377.0
	p.play_time_sec = 42.0 * 3600.0
	p.play_count = 1206
	p.ranked_play_count = 780
	p.maps_played = 74
	p.clears = 229
	p.full_combos = 18
	p.s_ranks = 26
	p.community_clears = 21
	p.ranked_acc = 93.84
	p.ranked_acc_plays = 74
	p.best_acc = 99.81
	p.total_score = 231940800
	p.perfect = 188200
	p.good = 21300
	p.miss = 4870
	p.favorite_mode = "FLOW"
	p.avg_level = 10.4
	p.max_level_cleared = 17.1
	p.milestones = ProfileRules.milestones_reached(p.rank)
	p.avatar_id = "avatar_01"
	p.title_id = "rhythm_vanguard"
	p.frame_id = "basic"
	p.playtester = true
	for t in ["first_beat", "playtester", "full_combo_hunter", "community_pioneer", "top_100", "rhythm_vanguard"]:
		p.unlock("title", t, false, "2026-08-30T20:00:00Z")
	for f in ["silver", "gold", "emerald", "playtester"]:
		p.unlock("frame", f, false, "2026-08-30T20:00:00Z")
	for a in ["avatar_02", "avatar_03", "avatar_04", "avatar_05", "avatar_06", "avatar_08"]:
		p.unlock("avatar", a, false, "2026-08-30T20:00:00Z")
	p.recent = [
		{"kind": "peak", "text": "NEW PEAK #8", "at": "2026-09-05T22:40:00Z"}, 
		{"kind": "acc", "text": "BEST ACC 99.81%", "at": "2026-09-04T21:00:00Z"}, 
		{"kind": "fc", "text": "3 NEW FCs", "at": "2026-09-03T20:00:00Z"}, 
	]
	p.recent_activity = _activity(["ENTANGLE NIGHT", "BOOKMAKER", "KAILI", "SHIAWASE", "GALAXY COLLAPSE", "RAVENATIC"], 
		[91.4, 94.2, 97.8, 99.81, 92.0, 98.9])
	p._ensure_defaults()
	return p



static func _elite() -> PlayerProfile:
	var p: = _base("ravenatic")
	p.has_rank = true
	p.rank = 2
	p.players = 641
	p.rp = 2412.0
	p.percentile = 0.3
	p.has_rank_delta = true
	p.rank_delta_week = 1
	p.peak_rank = 1
	p.peak_rp = 2460.0
	p.play_time_sec = 131.0 * 3600.0
	p.play_count = 3980
	p.ranked_play_count = 2410
	p.maps_played = 96
	p.clears = 704
	p.full_combos = 63
	p.s_ranks = 88
	p.community_clears = 40
	p.ranked_acc = 98.31
	p.ranked_acc_plays = 96
	p.best_acc = 100.0
	p.total_score = 812500100
	p.perfect = 690000
	p.good = 31000
	p.miss = 6400
	p.favorite_mode = "FLOW"
	p.avg_level = 13.2
	p.max_level_cleared = 20.15
	p.milestones = ProfileRules.milestones_reached(p.rank)
	p.avatar_id = "avatar_08"
	p.title_id = "rhythm_vanguard"
	p.frame_id = "top3"
	p.playtester = true
	for t in ProfileRules.TITLES:
		p.unlock("title", String(t["id"]), false, "2026-08-30T20:00:00Z")
	for f in ["silver", "gold", "emerald", "diamond", "celestial", "top3", "playtester"]:
		p.unlock("frame", f, f == "top3", "2026-09-05T23:00:00Z")
	for a in ProfileRules.AVATARS:
		p.unlock("avatar", String(a["id"]), false, "2026-08-30T20:00:00Z")
	p.recent = [
		{"kind": "unlock", "text": "TOP 3 FRAME UNLOCKED", "at": "2026-09-05T23:00:00Z"}, 
		{"kind": "acc", "text": "PRISM ACCURACY", "at": "2026-09-04T21:00:00Z"}, 
		{"kind": "fc", "text": "5 NEW FCs", "at": "2026-09-03T20:00:00Z"}, 
	]
	p.recent_activity = _activity(["ENTANGLE NIGHT", "BOOKMAKER", "FREEDOM DIVE", "GALAXY COLLAPSE", "KAILI"], 
		[97.9, 98.6, 96.4, 99.2, 100.0])
	p._ensure_defaults()
	return p


static func _activity(maps: Array, accs: Array) -> Array:
	var out: Array = []
	for i in maps.size():
		var acc: float = accs[i]
		var grade: = "SS" if acc >= 100.0 else ("S" if acc >= 95.0 else ("A" if acc >= 90.0 else "B"))
		out.append({"map": maps[i], "difficulty": "IMPOSSIBLE" if i % 2 == 0 else "HARD", 
			"accuracy": acc, "grade": grade, 
			"at": "2026-09-%02dT20:00:00Z" % (5 - i)})
	return out
