class_name ProfileRules
extends RefCounted














const ACC_TIERS: = [
	{"key": "bronze", "name": "BRONZE", "min": 0.0, "color": Color(0.8, 0.5, 0.28)}, 
	{"key": "silver", "name": "SILVER", "min": 80.0, "color": Color(0.8, 0.84, 0.9)}, 
	{"key": "gold", "name": "GOLD", "min": 85.0, "color": Color(1.0, 0.82, 0.3)}, 
	{"key": "emerald", "name": "EMERALD", "min": 90.0, "color": Color(0.24, 0.9, 0.58)}, 
	{"key": "diamond", "name": "DIAMOND", "min": 95.0, "color": Color(0.62, 0.9, 1.0)}, 
	{"key": "prism", "name": "PRISM", "min": 98.0, "color": Color(0.85, 0.65, 1.0)}, 
]




const ACC_MIN_PLAYS: = 10


static func acc_tier_index(acc: float) -> int:
	if acc < 0.0 or is_nan(acc):
		return -1
	var idx: = 0
	for i in ACC_TIERS.size():
		if acc >= float(ACC_TIERS[i]["min"]):
			idx = i
	return idx


static func acc_tier(acc: float) -> Dictionary:
	var i: = acc_tier_index(acc)
	return ACC_TIERS[i] if i >= 0 else {}



static func next_acc_tier(acc: float) -> Dictionary:
	var i: = acc_tier_index(acc)
	if i < 0:
		return ACC_TIERS[1]
	return ACC_TIERS[i + 1] if i + 1 < ACC_TIERS.size() else {}


static func acc_tier_by_key(key: String) -> Dictionary:
	for t in ACC_TIERS:
		if t["key"] == key:
			return t
	return {}



static func acc_tier_progress(acc: float) -> float:
	var cur: = acc_tier(acc)
	var nxt: = next_acc_tier(acc)
	if cur.is_empty() or nxt.is_empty():
		return 1.0 if not cur.is_empty() else 0.0
	var lo: = float(cur["min"])
	var hi: = float(nxt["min"])
	return clampf((acc - lo) / maxf(hi - lo, 0.001), 0.0, 1.0)







const RANK_LADDER: = [5000, 2000, 1000, 500, 250, 100, 50, 25, 10, 5, 3, 1]




const RANK_REWARDS: = {
	100: {"kind": "title", "id": "top_100", "name": "TOP 100 TITLE"}, 
	50: {"kind": "avatar", "id": "avatar_06", "name": "AVATAR VI"}, 
	10: {"kind": "title", "id": "rhythm_vanguard", "name": "RHYTHM VANGUARD TITLE"}, 
	5: {"kind": "frame", "id": "celestial", "name": "CELESTIAL FRAME"}, 
	3: {"kind": "frame", "id": "top3", "name": "TOP 3 FRAME"}, 
	1: {"kind": "frame", "id": "top1", "name": "TOP 1 FRAME"}, 
}



static func milestones_reached(rank: int) -> Array:
	var out: Array = []
	if rank <= 0:
		return out
	for m in RANK_LADDER:
		if rank <= int(m):
			out.append(int(m))
	return out



static func ring_lit_count(rank: int) -> int:
	return milestones_reached(rank).size()




static func next_milestone(rank: int) -> int:
	if rank <= 0:
		return int(RANK_LADDER[0])
	for m in RANK_LADDER:
		if rank > int(m):
			return int(m)
	return 0



static func last_milestone(rank: int) -> int:
	var r: = milestones_reached(rank)
	return int(r[-1]) if not r.is_empty() else 0





static func path_window(rank: int, count: = 5) -> Array:
	var pts: Array = []
	if rank <= 0:
		for i in mini(count, RANK_LADDER.size()):
			pts.append({"rank": int(RANK_LADDER[i]), "state": "next" if i == 0 else "locked"})
		return pts
	var last: = last_milestone(rank)
	if last > 0 and last != rank:
		pts.append({"rank": last, "state": "reached"})
	pts.append({"rank": rank, "state": "current"})
	var first_next: = true
	for m in RANK_LADDER:
		if pts.size() >= count:
			break
		if int(m) < rank:
			pts.append({"rank": int(m), "state": "next" if first_next else "locked"})
			first_next = false
	return pts






static func milestone_progress(rank: int) -> float:
	if rank <= 0:
		return 0.0
	var nxt: = next_milestone(rank)
	if nxt <= 0:
		return 1.0
	var prev: = last_milestone(rank)
	if prev <= 0:

		prev = nxt * 2
	return clampf(float(prev - rank) / float(maxi(prev - nxt, 1)), 0.0, 1.0)




static func ring_segment_color(index: int) -> Color:
	var m: = int(RANK_LADDER[clampi(index, 0, RANK_LADDER.size() - 1)])
	if m <= 5:
		return Color(1.0, 0.82, 0.3)
	if m <= 50:
		return Color(0.66, 0.33, 0.97)
	return Color(0.21, 0.85, 0.95)







static func rank_tier(rank: int) -> Dictionary:
	if rank <= 0:
		return {"key": "unranked", "name": "UNRANKED", "color": Color(1, 1, 1, 0.45), 
			"color2": Color(1, 1, 1, 0.45), "glow": 0.0}
	if rank == 1:
		return {"key": "top1", "name": "#1 IN THE WORLD", "color": Color(1.0, 0.86, 0.4), 
			"color2": Color(1.0, 0.98, 0.85), "glow": 1.0}
	if rank == 2:
		return {"key": "top3", "name": "TOP 3 · SILVER", "color": Color(0.86, 0.9, 0.96), 
			"color2": Color(0.7, 0.76, 0.86), "glow": 0.85}
	if rank == 3:
		return {"key": "top3", "name": "TOP 3 · BRONZE", "color": Color(0.9, 0.6, 0.36), 
			"color2": Color(1.0, 0.78, 0.55), "glow": 0.85}
	if rank <= 5:
		return {"key": "top5", "name": "TOP 5 · CELESTIAL", "color": Color(0.45, 0.9, 1.0), 
			"color2": Color(0.75, 0.45, 1.0), "glow": 0.75}
	if rank <= 10:
		return {"key": "top10", "name": "TOP 10", "color": Color(1.0, 0.82, 0.3), 
			"color2": Color(1.0, 0.92, 0.65), "glow": 0.6}
	if rank <= 25:
		return {"key": "top25", "name": "TOP 25", "color": Color(0.55, 0.6, 1.0), 
			"color2": Color(0.3, 0.85, 0.98), "glow": 0.45}
	if rank <= 50:
		return {"key": "top50", "name": "TOP 50", "color": Color(0.35, 0.92, 1.0), 
			"color2": Color(0.55, 0.96, 1.0), "glow": 0.35}
	if rank <= 100:
		return {"key": "top100", "name": "TOP 100", "color": Color(0.21, 0.8, 0.9), 
			"color2": Color(0.3, 0.85, 0.95), "glow": 0.2}
	return {"key": "ordinary", "name": "RANKED", "color": Color(0.95, 0.94, 0.98), 
		"color2": Color(0.66, 0.33, 0.97), "glow": 0.0}












const AVATARS: = [
	{"id": "avatar_01", "name": "AVATAR I", "unlock": {"kind": "default"}}, 
	{"id": "avatar_02", "name": "AVATAR II", "unlock": {"kind": "first_clear"}}, 
	{"id": "avatar_03", "name": "AVATAR III", "unlock": {"kind": "clears", "value": 10}}, 
	{"id": "avatar_04", "name": "AVATAR IV", "unlock": {"kind": "clears", "value": 25}}, 
	{"id": "avatar_05", "name": "AVATAR V", "unlock": {"kind": "acc_tier", "value": "emerald"}}, 
	{"id": "avatar_06", "name": "AVATAR VI", "unlock": {"kind": "rank", "value": 50}}, 
	{"id": "avatar_07", "name": "AVATAR VII", "unlock": {"kind": "fc", "value": 50}}, 
	{"id": "avatar_08", "name": "AVATAR VIII", "unlock": {"kind": "rank", "value": 10}}, 
]

const TITLES: = [
	{"id": "first_beat", "name": "FIRST BEAT", "unlock": {"kind": "first_clear"}}, 
	{"id": "playtester", "name": "PLAYTESTER", "unlock": {"kind": "playtest"}}, 
	{"id": "full_combo_hunter", "name": "FULL COMBO HUNTER", "unlock": {"kind": "fc", "value": 10}}, 
	{"id": "community_pioneer", "name": "COMMUNITY PIONEER", "unlock": {"kind": "community_clears", "value": 5}}, 
	{"id": "top_100", "name": "TOP 100", "unlock": {"kind": "rank", "value": 100}}, 
	{"id": "rhythm_vanguard", "name": "RHYTHM VANGUARD", "unlock": {"kind": "rank", "value": 10}}, 
]

const FRAMES: = [
	{"id": "basic", "name": "BASIC", "unlock": {"kind": "default"}}, 
	{"id": "silver", "name": "SILVER", "unlock": {"kind": "acc_tier", "value": "silver"}}, 
	{"id": "gold", "name": "GOLD", "unlock": {"kind": "acc_tier", "value": "gold"}}, 
	{"id": "emerald", "name": "EMERALD", "unlock": {"kind": "acc_tier", "value": "emerald"}}, 
	{"id": "diamond", "name": "DIAMOND", "unlock": {"kind": "acc_tier", "value": "diamond"}}, 
	{"id": "celestial", "name": "CELESTIAL", "unlock": {"kind": "rank", "value": 5}}, 
	{"id": "top3", "name": "TOP 3", "unlock": {"kind": "rank", "value": 3}}, 
	{"id": "top1", "name": "TOP 1", "unlock": {"kind": "rank", "value": 1}}, 
	{"id": "playtester", "name": "PLAYTESTER", "unlock": {"kind": "playtest"}}, 
]


static func catalogue(kind: String) -> Array:
	match kind:
		"avatar": return AVATARS
		"title": return TITLES
		"frame": return FRAMES
	return []


static func item(kind: String, id: String) -> Dictionary:
	for it in catalogue(kind):
		if it["id"] == id:
			return it
	return {}


static func item_name(kind: String, id: String) -> String:
	var it: = item(kind, id)
	return String(it.get("name", id.to_upper())) if not it.is_empty() else ""



static func unlock_text(it: Dictionary) -> String:
	var u: Dictionary = it.get("unlock", {})
	match String(u.get("kind", "")):
		"default": return "UNLOCKED BY DEFAULT"
		"rank": return "REACH GLOBAL TOP %d" % int(u.get("value", 0))
		"clears": return "CLEAR %d RANKED MAPS" % int(u.get("value", 0))
		"fc": return "%d FULL COMBOS" % int(u.get("value", 0))
		"acc_tier": return "REACH %s ACCURACY" % String(acc_tier_by_key(String(u.get("value", ""))).get("name", "?"))
		"s_ranks": return "%d S RANKS" % int(u.get("value", 0))
		"playtest": return "PLAYTEST PARTICIPANT"
		"community_clears": return "CLEAR %d COMMUNITY MAPS" % int(u.get("value", 0))
		"first_clear": return "CLEAR YOUR FIRST MAP"
	return "LOCKED"




static func meets(it: Dictionary, p) -> bool:
	var u: Dictionary = it.get("unlock", {})
	match String(u.get("kind", "")):
		"default": return true
		"rank": return p.has_rank and p.rank > 0 and p.rank <= int(u.get("value", 0))
		"clears": return p.clears >= int(u.get("value", 0))
		"fc": return p.full_combos >= int(u.get("value", 0))
		"acc_tier":
			var want: = acc_tier_by_key(String(u.get("value", "")))
			return p.ranked_acc >= 0.0 and not want.is_empty() and p.ranked_acc >= float(want["min"])
		"s_ranks": return p.s_ranks >= int(u.get("value", 0))
		"playtest": return p.playtester
		"community_clears": return p.community_clears >= int(u.get("value", 0))
		"first_clear": return p.clears >= 1
	return false





static func progress_toward(it: Dictionary, p) -> Array:
	var u: Dictionary = it.get("unlock", {})
	var v: = int(u.get("value", 0))
	match String(u.get("kind", "")):
		"rank":
			if not p.has_rank or p.rank <= 0:
				return [0, 1]
			var prev: = last_milestone(p.rank)
			if prev <= 0:
				prev = v * 2
			return [maxi(prev - p.rank, 0), maxi(prev - v, 1)]
		"clears": return [mini(p.clears, v), v]
		"fc": return [mini(p.full_combos, v), v]
		"s_ranks": return [mini(p.s_ranks, v), v]
		"community_clears": return [mini(p.community_clears, v), v]
		"acc_tier":


			var want: = acc_tier_by_key(String(u.get("value", "")))
			if want.is_empty() or p.ranked_acc < 0.0:
				return [0, 1]
			var idx: = ACC_TIERS.find(want)
			var lo: = float(ACC_TIERS[maxi(idx - 1, 0)]["min"])
			var hi: = float(want["min"])
			var t: = clampf((p.ranked_acc - lo) / maxf(hi - lo, 0.001), 0.0, 1.0)
			return [int(round(t * 100.0)), 100]
	return [1 if meets(it, p) else 0, 1]







static func next_unlock(p) -> Dictionary:
	if p.has_rank and p.rank > 0:
		var nxt: = next_milestone(p.rank)
		var reward: Dictionary = RANK_REWARDS.get(nxt, {})
		if not reward.is_empty() and not p.is_unlocked(String(reward["kind"]), String(reward["id"])):
			var it: = item(String(reward["kind"]), String(reward["id"]))
			if not it.is_empty():
				var pr: = progress_toward(it, p)
				return {"kind": String(reward["kind"]), "item": it, "current": pr[0], "target": pr[1], 
					"ratio": float(pr[0]) / float(maxi(int(pr[1]), 1))}
	var best: = {}
	var best_ratio: = -1.0
	for kind in ["frame", "title", "avatar"]:
		for it in catalogue(kind):
			if p.is_unlocked(kind, String(it["id"])):
				continue
			var u: Dictionary = it.get("unlock", {})
			if String(u.get("kind", "")) in ["playtest", "default"]:
				continue
			var pr: = progress_toward(it, p)
			var ratio: = float(pr[0]) / float(maxi(int(pr[1]), 1))
			if ratio > best_ratio + 0.0001\
			or (absf(ratio - best_ratio) <= 0.0001 and kind == "frame" and best.get("kind", "") != "frame"):
				best_ratio = ratio
				best = {"kind": kind, "item": it, "current": pr[0], "target": pr[1], "ratio": ratio}
	return best






static func fmt_rank(rank: int, prefix: = "#") -> String:
	return (prefix + thousands(rank)) if rank > 0 else "—"


static func fmt_rp(rp: float) -> String:
	if is_nan(rp) or rp < 0.0:
		return "— MP"
	return "%s MP" % thousands(int(round(rp)))


static func fmt_acc(acc: float, decimals: = 2) -> String:
	if is_nan(acc) or acc < 0.0 or acc > 100.0:
		return "—"
	return ("%." + str(decimals) + "f%%") % acc


static func fmt_percentile(pct: float) -> String:
	if is_nan(pct) or pct <= 0.0 or pct > 100.0:
		return "—"
	if pct < 10.0:
		return "TOP %.1f%%" % pct
	return "TOP %d%%" % int(ceil(pct))


static func fmt_hours(sec: float) -> String:
	if is_nan(sec) or sec < 0.0:
		return "—"
	var h: = sec / 3600.0
	if h < 1.0:
		return "%dm" % int(sec / 60.0)
	if h < 10.0:
		return "%.1fh" % h
	return "%dh" % int(h)


static func fmt_delta(delta: int) -> String:
	if delta > 0:
		return "+%d THIS WEEK" % delta
	if delta < 0:
		return "%d THIS WEEK" % delta
	return "STEADY THIS WEEK"


static func thousands(n: int) -> String:
	var neg: = n < 0
	var s: = str(absi(n))
	var out: = ""
	var count: = 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "," + out
	return ("-" if neg else "") + out
