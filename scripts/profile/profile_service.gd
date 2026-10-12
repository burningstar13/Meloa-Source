extends Node






















signal profile_changed(p: PlayerProfile)

signal unlock_events(events: Array)


const USE_MOCK: = true
const MOCK_DEFAULT: = "benson"

var profile: PlayerProfile = PlayerProfile.loading()


var network_calls: = 0
var mock_key: = MOCK_DEFAULT
var _refresh_token: = 0
var _pending_events: Array = []


func _ready() -> void :
	if USE_MOCK:
		profile = ProfileMockData.build(mock_key)
		profile_changed.emit.call_deferred(profile)
	else:
		Backend.auth_changed.connect( func(_logged: bool, _u: String) -> void : refresh(true))
		refresh.call_deferred(true)





func dev_controls_visible() -> bool:
	return USE_MOCK and (OS.has_feature("editor")
		or OS.get_environment("RYTHM_PROFILE_DEV").strip_edges() == "1")


func is_mock() -> bool:
	return USE_MOCK





func refresh(force: = false) -> void :
	if USE_MOCK:
		_adopt(ProfileMockData.build(mock_key), not force)
		return
	_refresh_token += 1
	var token: = _refresh_token
	if not await Backend.wait_session():
		_adopt(PlayerProfile.signed_out(), false)
		return
	if profile.state in ["signed_out", "error", "loading"]:
		var l: = PlayerProfile.loading()
		l.username = Backend.username
		_adopt(l, false)
	network_calls += 1
	var r: Dictionary = await Backend.api_profile_me()
	if token != _refresh_token:
		return
	if r.ok and r.data is Dictionary:
		_adopt(PlayerProfile.from_dict(r.data), true)
		return
	if r.code == 404 or r.code == 501:

		network_calls += 1
		var g: Dictionary = await Backend.global_me()
		if token != _refresh_token:
			return
		var gd: Dictionary = g.data if g.ok and g.data is Dictionary else {}
		_adopt(PlayerProfile.from_legacy(Backend.username, gd, true), true)
		return
	if r.code == 401:
		_adopt(PlayerProfile.signed_out(), false)
		return
	_adopt(PlayerProfile.errored("server unreachable" if r.code == 0 else "error %d" % r.code, 
		Backend.username), false)




func on_legacy_rank(logged: bool, uname: String, global_rank: Dictionary) -> void :
	if USE_MOCK:
		return
	if not logged:
		_adopt(PlayerProfile.signed_out(), false)
		return
	if profile.state == "ready":


		if not global_rank.is_empty() and int(global_rank.get("rank", 0)) > 0:
			var np: = profile.duplicate_profile()
			np.has_rank = true
			np.rank = int(global_rank.get("rank", 0))
			np.players = int(global_rank.get("players", 0))
			np.rp = float(global_rank.get("totalPp", np.rp))
			if np.players > 0:
				np.percentile = float(np.rank) / float(np.players) * 100.0
			np.milestones = ProfileRules.milestones_reached(np.rank)
			_adopt(np, true)
		return
	_adopt(PlayerProfile.from_legacy(uname, global_rank, true), true)






func equip(kind: String, id: String) -> bool:
	if not profile.is_unlocked(kind, id):
		return false
	var np: = profile.duplicate_profile()
	match kind:
		"avatar": np.avatar_id = id
		"title": np.title_id = id
		"frame": np.frame_id = id
		_: return false
	np.mark_seen(kind, id)
	_adopt(np, false)
	if not USE_MOCK:
		network_calls += 1
		var payload: = {"avatarId": np.avatar_id, "titleId": np.title_id, "frameId": np.frame_id}
		var r: Dictionary = await Backend.api_profile_identity(payload)
		if not r.ok:
			refresh(true)
			return false
	return true



func unequip_title() -> void :
	var np: = profile.duplicate_profile()
	np.title_id = ""
	_adopt(np, false)
	if not USE_MOCK:
		network_calls += 1
		await Backend.api_profile_identity({"avatarId": np.avatar_id, "titleId": "", "frameId": np.frame_id})



func mark_seen(kind: String, id: String) -> void :
	if not profile.is_new(kind, id):
		return
	var np: = profile.duplicate_profile()
	np.mark_seen(kind, id)
	_adopt(np, false)
	if not USE_MOCK:
		network_calls += 1
		await Backend.api_profile_seen([{"kind": kind, "id": id}])






func mock_select(key: String) -> void :
	if not USE_MOCK:
		return
	mock_key = key
	_adopt(ProfileMockData.build(key), false)





func mock_simulate_rank_up() -> void :
	if not USE_MOCK or not profile.has_rank:
		return
	var nxt: = ProfileRules.next_milestone(profile.rank)
	if nxt <= 0:
		return
	var np: = profile.duplicate_profile()
	np.rank_delta_week += np.rank - nxt
	np.rank = nxt
	np.peak_rank = nxt if np.peak_rank <= 0 else mini(np.peak_rank, nxt)
	np.rp += 40.0
	if np.players > 0:
		np.percentile = float(np.rank) / float(np.players) * 100.0
	np.milestones = ProfileRules.milestones_reached(np.rank)
	var reward: Dictionary = ProfileRules.RANK_REWARDS.get(nxt, {})
	if not reward.is_empty():
		np.unlock(String(reward["kind"]), String(reward["id"]), true)
	np.recent.push_front({"kind": "peak", "text": "NEW PEAK #%d" % nxt, 
		"at": Time.get_datetime_string_from_system(true)})
	_adopt(np, true)



func mock_simulate_acc_tier_up() -> void :
	if not USE_MOCK:
		return
	var np: = profile.duplicate_profile()
	var nxt: = ProfileRules.next_acc_tier(np.ranked_acc if np.has_acc() else -1.0)
	if nxt.is_empty():
		return
	np.has_stats = true
	if np.ranked_acc_plays < ProfileRules.ACC_MIN_PLAYS:
		np.ranked_acc_plays = ProfileRules.ACC_MIN_PLAYS
	np.ranked_acc = float(nxt["min"]) + 0.12
	np.best_acc = maxf(np.best_acc, np.ranked_acc)
	var frame_id: = String(nxt["key"])
	if not ProfileRules.item("frame", frame_id).is_empty():
		np.unlock("frame", frame_id, true)
	np.recent.push_front({"kind": "acc", "text": "%s ACCURACY" % String(nxt["name"]), 
		"at": Time.get_datetime_string_from_system(true)})
	_adopt(np, true)




func mock_unlock_next_frame() -> void :
	if not USE_MOCK:
		return
	for f in ProfileRules.FRAMES:
		var id: = String(f["id"])
		if not profile.is_unlocked("frame", id):
			var np: = profile.duplicate_profile()
			np.unlock("frame", id, true)
			np.recent.push_front({"kind": "unlock", "text": "%s FRAME UNLOCKED" % String(f["name"]), 
				"at": Time.get_datetime_string_from_system(true)})
			_adopt(np, true)
			return






func _adopt(np: PlayerProfile, detect: bool) -> void :
	var old: = profile
	profile = np
	var events: Array = []
	if detect and old != null and old.state in ["ready", "partial"] and np.state in ["ready", "partial"]\
	and old.username == np.username:
		events = _diff_events(old, np)



	if not events.is_empty():
		unlock_events.emit(events)
	profile_changed.emit(np)


func _diff_events(old: PlayerProfile, np: PlayerProfile) -> Array:
	var ev: Array = []

	var before: = ProfileRules.milestones_reached(old.rank if old.has_rank else 0)
	var after: = ProfileRules.milestones_reached(np.rank if np.has_rank else 0)
	for m in after:
		if not before.has(m):
			ev.append({"kind": "rank", "milestone": int(m), "from": old.rank if old.has_rank else 0, 
				"to": np.rank, "reward": ProfileRules.RANK_REWARDS.get(int(m), {})})

	var ti_old: = ProfileRules.acc_tier_index(old.ranked_acc if old.has_acc() else -1.0)
	var ti_new: = ProfileRules.acc_tier_index(np.ranked_acc if np.has_acc() else -1.0)
	if ti_new > ti_old and ti_old >= 0:
		ev.append({"kind": "acc_tier", "from_index": ti_old, "to_index": ti_new, 
			"from_acc": old.ranked_acc, "to_acc": np.ranked_acc})

	for kind in ["avatar", "title", "frame"]:
		for id in (np.unlocked.get(kind, []) as Array):
			if not old.is_unlocked(kind, String(id)):
				ev.append({"kind": "cosmetic", "cosmetic_kind": kind, "id": String(id)})
	return ev
