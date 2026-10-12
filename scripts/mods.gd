class_name Mods
extends RefCounted

























enum Mode{STANDARD, MANIA}

const MODE_KEYS: = ["STANDARD", "MANIA"]





const MODE_NAMES: = {"STANDARD": "FLOW", "MANIA": "GRID"}


static func mode_name(key: = "") -> String:
	var k: = key if key != "" else mode_key()
	return String(MODE_NAMES.get(k, k))








const CATALOG: = [
	{
		"id": "mirage", "name": "MIRAGE", "letter": "MI", 
		"desc": "notes fade out before the line — play from memory", 
		"color": Color(0.62, 0.45, 1.0), "ranked": true, "mult": 1.06, 
		"modes": ["STANDARD", "MANIA"], "excl": [], 
	}, 
	{
		"id": "sudden", "name": "SUDDEN DEATH", "letter": "SD", 
		"desc": "one miss or a dropped slider and the run stops — all or nothing", 
		"color": Color(1.0, 0.35, 0.4), "ranked": true, "mult": 1.03, 
		"modes": ["STANDARD", "MANIA"], "excl": ["invincible"], 
	}, 
	{
		"id": "no_yellow", "name": "NO YELLOW", "letter": "NY", 
		"desc": "yellows become lane notes — nothing left to aim", 
		"color": Color(1.0, 0.84, 0.3), "ranked": true, "mult": 0.9, 



		"mult_mania": 0.5, 
		"modes": ["STANDARD", "MANIA"], "excl": ["no_white"], 
	}, 
	{
		"id": "no_white", "name": "NO WHITE", "letter": "NW", 
		"desc": "lane notes become yellows — the whole map is aim", 


		"color": Color(0.9, 0.95, 1.0), "ranked": false, "mult": 1.08, 
		"modes": ["STANDARD"], "excl": ["no_yellow"], 
	}, 
	{
		"id": "no_red", "name": "NO RED", "letter": "NR", 
		"desc": "reds are removed — nothing left to dodge", 
		"color": Color(1.0, 0.42, 0.42), "ranked": false, "mult": 0.95, 
		"modes": ["STANDARD"], "excl": [], 
	}, 
	{
		"id": "autoclic", "name": "AUTOCLIC", "letter": "AC", 
		"desc": "hits fire on their own — you only aim and move", 
		"color": Color(0.4, 0.9, 0.8), "ranked": false, "mult": 0.6, 
		"modes": ["STANDARD", "MANIA"], "excl": ["auto"], 
	}, 
	{
		"id": "invincible", "name": "INVINCIBLE", "letter": "IN", 
		"desc": "misses cost no HP — the map always runs to the end", 
		"color": Color(1.0, 0.82, 0.3), "ranked": false, "mult": 0.6, 
		"modes": ["STANDARD", "MANIA"], "excl": ["sudden"], 
	}, 
	{
		"id": "auto", "name": "AUTO", "letter": "AU", 
		"desc": "the bot plays it in PERFECT — to watch, not to play", 
		"color": Color(1.0, 0.55, 0.85), "ranked": false, "mult": 0.0, 
		"modes": ["STANDARD", "MANIA"], "excl": ["autoclic"], 
	}, 
]




static func mode_key() -> String:
	return SettingsManager.game_mode


static func is_mania() -> bool:
	return SettingsManager.game_mode == "MANIA"


static func set_mode(key: String) -> void :
	if not MODE_KEYS.has(key) or key == SettingsManager.game_mode:
		return
	SettingsManager.set_game_mode(key)


	for id in active():
		if not info(id).modes.has(key):
			set_on(id, false)






static func letters(ids: Array) -> String:
	var out: Array = []
	for id in ids:
		var i: = info(String(id))
		out.append(String(i.get("letter", String(id).to_upper().substr(0, 2))))
	return " ".join(out)


static func info(id: String) -> Dictionary:
	for m in CATALOG:
		if m.id == id:
			return m
	return {}



static func available() -> Array:
	var out: Array = []
	for m in CATALOG:
		if m.modes.has(mode_key()):
			out.append(m)
	return out





static func active() -> Array:
	var out: Array = []
	for id in SettingsManager.mods:
		var m: = info(String(id))
		if not m.is_empty() and m.modes.has(mode_key()):
			out.append(String(id))
	return out




static func has(id: String) -> bool:
	if not SettingsManager.mods.has(id):
		return false
	var m: = info(id)
	return not m.is_empty() and m.modes.has(mode_key())


static func set_on(id: String, on: bool) -> void :
	var list: Array = SettingsManager.mods.duplicate()
	if on:
		if not list.has(id):
			list.append(id)
		for x in info(id).get("excl", []):
			list.erase(x)
	else:
		list.erase(id)
	SettingsManager.set_mods(list)


static func toggle(id: String) -> void :
	set_on(id, not SettingsManager.mods.has(id))


static func clear() -> void :
	SettingsManager.set_mods([])






static func score_mult() -> float:
	var k: = 1.0
	for id in active():
		k *= mult_of(id)
	return k



static func mult_of(id: String) -> float:
	var m: Dictionary = info(id)
	if is_mania() and m.has("mult_mania"):
		return float(m.mult_mania)
	return float(m.mult)





static func ranked() -> bool:
	for id in active():
		if not bool(info(id).ranked):
			return false
	return true



static func summary() -> String:
	var names: Array = []
	for id in active():
		names.append(String(info(id).name))
	return " · ".join(names)



















const MIRAGE_LANE_OUT: = 0.45
const MIRAGE_LANE_FADE: = 0.28
const MIRAGE_AIM_OUT: = 0.5
const MIRAGE_AIM_FADE: = 0.32

static func mirage_alpha(p: float, aim: = false) -> float:
	if not has("mirage"):
		return 1.0
	var out: float = MIRAGE_AIM_OUT if aim else MIRAGE_LANE_OUT
	var fade: float = MIRAGE_AIM_FADE if aim else MIRAGE_LANE_FADE
	return clampf((p - out) / fade, 0.0, 1.0)









static func apply_chart(notes: Array, view_w: = 1280.0) -> Array:
	var out: Array = notes




	if is_mania() or has("no_red") or has("no_white"):
		out = _drop_reds(out)
	if has("no_yellow"):
		out = _yellows_to_lanes(out, view_w)
	elif has("no_white"):
		out = _lanes_to_yellows(out)
	out.sort_custom( func(a, b): return float(a.time) < float(b.time))
	return out


static func _drop_reds(notes: Array) -> Array:
	var out: Array = []
	for n in notes:
		if String(n.type) != "dodge":
			out.append(n)
	return out



static func lane_from_x(x: float, view_w: = 1280.0) -> int:
	return clampi(int(floorf(x / maxf(view_w, 1.0) * 3.0)), 0, 2)





static func _yellows_to_lanes(notes: Array, view_w: float) -> Array:
	var out: Array = []
	for n in notes:
		var t: = String(n.type)
		if t == "click":
			var c: Dictionary = n.duplicate()
			c.type = "parry"
			c.lane = lane_from_x(float(c.get("x", view_w * 0.5)), view_w)
			c.erase("x")
			c.erase("y")
			out.append(c)
		elif t == "clickx":
			var lane: = lane_from_x(float(n.get("x", view_w * 0.5)), view_w)
			out.append({"time": float(n.time), "lane": lane, "type": "parry", 
				"v": float(n.get("v", 1.0))})
			for e in n.get("extra", []):
				out.append({"time": float(e[0]), 
					"lane": lane_from_x(float(e[1]), view_w), 
					"type": "parry", "v": float(n.get("v", 1.0))})
		elif t == "sliderg":

			var pts: Array = n.get("points", [])
			var hx: float = float(pts[0][1]) if not pts.is_empty() else view_w * 0.5
			out.append({"time": float(n.time), "lane": lane_from_x(hx, view_w), 
				"type": "sliderm", "v": float(n.get("v", 1.0)), 
				"duration": float(n.get("duration", 1.0))})
		else:
			out.append(n)
	return out










static func _lanes_to_yellows(notes: Array) -> Array:
	var out: Array = []
	for n in notes:
		var t: = String(n.type)
		if t == "parry":
			var c: Dictionary = n.duplicate()
			c.type = "click"
			out.append(c)
		elif t == "sliderm":


			var lane: int = clampi(int(n.get("lane", 1)), 0, 2)
			var x: float = _lane_center_x(lane)
			out.append({"time": float(n.time), "type": "sliderg", 
				"duration": float(n.get("duration", 1.0)), 
				"v": float(n.get("v", 1.0)), "x": x, "y": 300.0, 
				"points": [[0.0, x, 260.0], [1.0, x, 360.0]]})
		else:
			out.append(n)
	return out




static func _lane_center_x(lane: int) -> float:
	return 640.0 + float(lane - 1) * 180.0
