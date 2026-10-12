extends RefCounted











const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")
const FxFonts = preload("res://scripts/fx_fonts.gd")

const EASES: = ["linear", "in", "out", "io", "elastic"]
const ANIMS: = ["pop", "slam", "slide", "bounce", "shake", "rise", "zoom", 
	"spin", "flicker", "type", "float"]
const THEMES: = ["rings", "none", "matrix", "waves", "orbit", "shards", "stardust"]
const SIDES: = ["", "left", "right"]



const TYPES: = {
	"text": {
		"label": "TEXT", "family": "text", "color": Color(0.72, 0.45, 1.0), 
		"anim": false, 
		"fields": [
			{"key": "text", "label": "TEXT", "kind": "text", "def": "yeah"}, 
			{"key": "size", "label": "SIZE", "kind": "int", "def": 64}, 
			{"key": "font", "label": "FONT", "kind": "choice:fonts", "def": "fredoka"}, 
			{"key": "anim", "label": "ANIM", "kind": "choice:anims", "def": "pop"}, 
			{"key": "color", "label": "COLOR", "kind": "color", "def": "#e8e6ff"}, 
			{"key": "color_b", "label": "ECHO", "kind": "color", "def": "#b48cff"}, 
			{"key": "x", "label": "X", "kind": "float", "def": 0.5}, 
			{"key": "y", "label": "Y", "kind": "float", "def": 0.3}, 
			{"key": "side", "label": "SIDE", "kind": "choice:sides", "def": ""}, 
			{"key": "ring", "label": "RING", "kind": "bool", "def": false}, 
		], 
	}, 
	"image": {
		"label": "IMAGE", "family": "text", "color": Color(1.0, 0.55, 0.85), 
		"anim": false, 
		"fields": [
			{"key": "file", "label": "IMAGE", "kind": "image", "def": ""}, 
			{"key": "width", "label": "WIDTH", "kind": "float", "def": 0.35}, 
			{"key": "x", "label": "X", "kind": "float", "def": 0.5}, 
			{"key": "y", "label": "Y", "kind": "float", "def": 0.5}, 
			{"key": "rotation", "label": "ANGLE", "kind": "float", "def": 0.0}, 
			{"key": "opacity", "label": "OPACITY", "kind": "float", "def": 1.0}, 
			{"key": "anim_in", "label": "IN", "kind": "choice:img_in", "def": "pop"}, 
			{"key": "in_len", "label": "IN TIME", "kind": "float", "def": 0.4}, 
			{"key": "anim_out", "label": "OUT", "kind": "choice:img_out", "def": "fade"}, 
			{"key": "out_len", "label": "OUT TIME", "kind": "float", "def": 0.4}, 
			{"key": "anim_hold", "label": "WHILE", "kind": "choice:img_hold", "def": "none"}, 
			{"key": "hold_amt", "label": "WHILE AMT", "kind": "float", "def": 1.0}, 
			{"key": "hold_from", "label": "WHILE FROM", "kind": "float", "def": 0.0}, 
			{"key": "hold_to", "label": "WHILE TO", "kind": "float", "def": 0.0}, 
			{"key": "color", "label": "TINT", "kind": "color", "def": ""}, 
			{"key": "glow", "label": "GLOW", "kind": "bool", "def": false}, 
			{"key": "fps", "label": "GIF FPS", "kind": "float", "def": 0.0, "opt": true}, 
		], 
		"hint": "Shows a picture (png/jpg/webp, or a GIF: converted to a sprite "
			+ "sheet, GIF FPS sets its speed) for LENGTH seconds. WIDTH is a "
			+ "fraction of the screen width (0.35 = a third), X/Y the center "
			+ "(0..1). IN and OUT are the entrance and exit animations. WHILE "
			+ "plays between WHILE FROM and WHILE TO (seconds after the start; "
			+ "TO = 0 means until the end). The file is copied into the map folder.", 
	}, 
	"break": {
		"label": "BREAK SCREEN", "family": "text", "color": Color(0.55, 0.7, 1.0), 
		"anim": false, 
		"fields": [
			{"key": "top", "label": "OVERLINE", "kind": "text", "def": ""}, 
			{"key": "text", "label": "TITLE", "kind": "text", "def": "are you ready ?"}, 
			{"key": "sub", "label": "SUBTITLE", "kind": "text", "def": ""}, 
			{"key": "color", "label": "COLOR", "kind": "color", "def": "#b48cff"}, 
			{"key": "timer", "label": "TIMER", "kind": "bool", "def": true, 
				"hint": "Show the countdown. Off = the scene just clears, no digits."}, 
		], 
	}, 
	"particles": {
		"label": "PARTICLES", "family": "background", "color": Color(1.0, 0.62, 0.2), 
		"anim": true, "to_label": "INTENSITY", "to_def": 1.0, "lane": false, 
		"fields": [
			{"key": "params.kind", "label": "KIND", "kind": "choice:particles", "def": "snow"}, 
			{"key": "params.color", "label": "COLOR", "kind": "color", "def": ""}, 
			{"key": "params.density", "label": "DENSITY", "kind": "float", "def": 1.0}, 
			{"key": "params.speed", "label": "SPEED", "kind": "float", "def": 1.0}, 
			{"key": "params.size", "label": "SIZE", "kind": "float", "def": 1.0}, 
			{"key": "params.dir", "label": "DIRECTION", "kind": "float", "def": -1.0}, 
		], 
		"hint": "Rain, snow, embers, stars, bubbles, petals or dust, behind the "
			+ "lanes. Lasts LENGTH seconds at INTENSITY, with a short fade in "
			+ "and out. DENSITY / SPEED / SIZE "
			+ "multiply the kind's defaults. DIRECTION in degrees (90 = down, "
			+ "270 = up, 0 = right); -1 = the kind's own. Empty COLOR = the "
			+ "kind's own.", 
	}, 
	"lane_rotate": {
		"label": "ROTATE FIELD", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "ANGLE (DEG)", "to_def": 8.0, "lane": false, 
		"hint": "Rotates the whole play field (lanes, notes, impact line, "
			+ "mascots) around the middle of the impact line. ANGLE in degrees, "
			+ "animated from the previous value; set it back to 0 to straighten. "
			+ "Background and HUD stay level. In the editor the drawing rotates "
			+ "but clicks still pick in the straight layout.", 
	}, 
	"spread": {
		"label": "LANE SPREAD", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "MULTIPLIER", "to_def": 1.0, "lane": false, 
		"hint": "1.0 = normal spacing. Above 1 the lanes move apart.", 
	}, 
	"lane_dx": {
		"label": "LANE OFFSET", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "OFFSET X", "to_def": 0.0, "lane": true, 
		"hint": "Offset in pixels, relative to the natural position.", 
	}, 
	"lane_pos": {
		"label": "LANE ABSOLUTE X", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "ABSOLUTE X", "to_def": 640.0, "lane": true, 
		"fields": [{"key": "release", "label": "RELEASE", "kind": "bool", 
			"def": false}], 
		"hint": "Absolute X in pixels. Outside [0, 1280] the lane leaves the "
			+ "screen and the mascots stop targeting it. The lane stays "
			+ "PINNED at that X until an event with RELEASE = YES is "
			+ "reached: at the end of that one the natural layout takes "
			+ "over again (LANE SPREAD / LANE OFFSET / LANE SWAY). Without "
			+ "a RELEASE the lane never comes back.", 
	}, 
	"lane_sway": {
		"label": "LANE SWAY", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "AMPLITUDE", "to_def": 20.0, "lane": true, 
		"fields": [{"key": "params.freq", "label": "FREQUENCY", "kind": "float", "def": 0.5}], 
		"hint": "The lane sways for the event's duration, then settles back (0.5 s).", 
	}, 
	"lane_alpha": {
		"label": "LANE OPACITY", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "OPACITY", "to_def": 1.0, "lane": true, 
		"hint": "0 = the lane fades out in place (its notes stay playable).", 
	}, 
	"lane_remove": {
		"label": "REMOVE LANE", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": false, "lane": true, 
		"hint": "The lane is REMOVED for the event's length: it folds away "
			+ "(0.45 s), does not exist while the event lasts (the ball cannot "
			+ "stand on it, no note can be played there), then unfolds back at "
			+ "the end. Remove one, two or all three. Unlike ABSOLUTE X off-screen, "
			+ "the lane is really gone. Notes left on a removed lane are flagged "
			+ "at load.", 
	}, 
	"lane_color": {
		"label": "LANE COLOR", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "WEIGHT", "to_def": 1.0, "lane": true, 
		"fields": [{"key": "params.color", "label": "COLOR", "kind": "color", 
			"def": "#ffffff"}], 
		"hint": "Blend weight 0 to 1 towards the given color.", 
	}, 
	"lane_width": {
		"label": "LANE WIDTH", "family": "lanes", "color": Color(0.3, 1.0, 0.85), 
		"anim": true, "to_label": "MULTIPLIER", "to_def": 1.0, "lane": true, 
	}, 
	"bg_tint": {
		"label": "BACKGROUND TINT", "family": "background", "color": Color(1.0, 0.62, 0.2), 
		"anim": true, "to_label": "INTENSITY", "to_def": 0.7, "lane": false, 
		"fields": [{"key": "params.color", "label": "COLOR", "kind": "color", 
			"def": "#ff9d2e"}], 
	}, 
	"bg_ambient": {
		"label": "BACKGROUND MOOD", "family": "background", "color": Color(1.0, 0.62, 0.2), 
		"anim": true, "to_label": "INTENSITY", "to_def": 0.6, "lane": false, 
		"fields": [{"key": "params.color", "label": "COLOR", "kind": "color", 
			"def": "#ff2ea8"}], 
		"hint": "Sustained phase color: recolors the world's dominant hue (rings, halo, dust). Hold it through a hard section, release to 0 on the calm.", 
	}, 
	"bg_theme": {
		"label": "BACKGROUND PATTERN", "family": "background", "color": Color(1.0, 0.62, 0.2), 
		"anim": false, 
		"fields": [
			{"key": "params.theme", "label": "PATTERN", "kind": "choice:themes", 
				"def": "rings"}, 
			{"key": "params.color", "label": "COLOR", "kind": "color", "def": ""}, 
		], 
		"hint": "Crossfades over `length` seconds to the requested pattern.", 
	}, 
	"film": {
		"label": "OLD FILM", "family": "impact", "color": Color(0.85, 0.85, 0.8), 
		"anim": true, "to_label": "INTENSITY", "to_def": 1.0, "lane": false, 
		"fields": [
			{"key": "params.grain", "label": "GRAIN", "kind": "float", "def": 1.0}, 
			{"key": "params.sepia", "label": "SEPIA", "kind": "bool", "def": false}, 
		], 
		"hint": "Old camera look on the whole screen: black & white, film grain, "
			+ "vignette, projector flicker, scratches and dust. Lasts LENGTH "
			+ "seconds at INTENSITY, with a short fade in and out — like SHAKE "
			+ "and GLITCH. GRAIN 0..2. SEPIA tints it warm.", 
	}, 
	"shake": {
		"label": "SHAKE", "family": "impact", "color": Color(1.0, 0.36, 0.36), 
		"anim": true, "to_label": "AMPLITUDE", "to_def": 18.0, "lane": false, 
		"hint": "Impulse: full strength at the start, decays over the length.", 
	}, 
	"glitch": {
		"label": "GLITCH", "family": "impact", "color": Color(1.0, 0.36, 0.36), 
		"anim": true, "to_label": "AMPLITUDE", "to_def": 26.0, "lane": false, 
		"hint": "Impulse: full strength at the start, decays over the length.", 
	}, 
}






const MENU_ORDER: = ["text", "image", "break", "bg_theme", "bg_ambient", "bg_tint", "particles", 
	"shake", "glitch", "film", 
	"spread", "lane_pos", "lane_dx", "lane_alpha", "lane_color", 
	"lane_width", "lane_sway"]


static func spec(type: String) -> Dictionary:
	return TYPES.get(type, {})


static func label(type: String) -> String:
	return String(TYPES.get(type, {}).get("label", type.to_upper()))


static func color(type: String) -> Color:
	return TYPES.get(type, {}).get("color", Color(0.7, 0.7, 0.8))


static func family(type: String) -> String:
	return String(TYPES.get(type, {}).get("family", "other"))



static func short(ev: Dictionary) -> String:
	var type: = String(ev.get("type", ""))
	match type:
		"text":
			return String(ev.get("text", "text"))
		"image":
			var f: = String(ev.get("file", ""))
			return "image" if f == "" else f.get_basename().trim_prefix("fx_")
		"break":
			return "BREAK"
		"bg_theme":
			return "pattern " + String(ev.get("params", {}).get("theme", "?"))
		"bg_tint":
			return "tint"
		"shake":
			return "shake"
		"glitch":
			return "glitch"
		"film":
			return "film %.0f%%" % (float(ev.get("to", 1.0)) * 100.0)
		"particles":
			return "%s %.0f%%" % [String(ev.get("params", {}).get("kind", "snow")), 
				float(ev.get("to", 1.0)) * 100.0]
		"lane_rotate":
			return "rotate %.0f°" % float(ev.get("to", 0.0))
		"spread":
			return "spread %.2f" % float(ev.get("to", 1.0))
	if TYPES.get(type, {}).get("lane", false):
		var names: = ["L", "C", "R"]
		var li: int = clampi(int(ev.get("lane", 1)), 0, 2)
		return "%s %s" % [names[li], type.trim_prefix("lane_")]
	return type


static func choices(kind: String) -> Array:
	match kind:
		"choice:anims":
			return ANIMS
		"choice:themes":
			return THEMES
		"choice:sides":
			return SIDES
		"choice:eases":
			return EASES
		"choice:fonts":
			return FxFonts.ids()
		"choice:img_in":
			return FxEval.IMAGE_IN
		"choice:img_out":
			return FxEval.IMAGE_OUT
		"choice:img_hold":
			return FxEval.IMAGE_HOLD
		"choice:particles":
			return preload("res://scripts/fx_particles.gd").KINDS
	return []




static func choice_labels(kind: String) -> Array:
	if kind == "choice:fonts":
		return FxFonts.labels()
	var out: Array = []
	for o in choices(kind):
		out.append("(none)" if String(o) == "" else String(o).replace("_", " "))
	return out




static func make(type: String, time: float) -> Dictionary:
	var sp: = spec(type)
	var ev: = {"time": snappedf(time, 0.001), "len": 1.0, "type": type}
	if sp.get("anim", false):
		ev["to"] = float(sp.get("to_def", 1.0))
		ev["ease"] = "io"
	if sp.get("lane", false):
		ev["lane"] = 1
	for f in sp.get("fields", []):
		var key: = String(f.key)
		var def = f.def
		if String(f.kind) in ["color", "image"] and String(def) == "":
			continue
		if bool(f.get("opt", false)):
			continue
		if key.begins_with("params."):
			if not ev.has("params"):
				ev["params"] = {}
			ev.params[key.substr(7)] = def
		else:
			ev[key] = def
	return ev





static func get_field(ev: Dictionary, key: String, def = null):
	if key.begins_with("params."):
		return ev.get("params", {}).get(key.substr(7), def)
	return ev.get(key, def)


static func set_field(ev: Dictionary, key: String, value) -> void :
	if key.begins_with("params."):
		if not ev.has("params"):
			ev["params"] = {}
		ev.params[key.substr(7)] = value
	else:
		ev[key] = value






static func to_json(ev: Dictionary) -> String:
	var parts: = PackedStringArray()
	for k in ev.keys():
		if String(k).begins_with("_"):
			continue
		parts.append("\"%s\": %s" % [k, _value(ev[k])])
	return "{ " + ", ".join(parts) + " }"


static func _value(v) -> String:
	match typeof(v):
		TYPE_BOOL:
			return "true" if v else "false"
		TYPE_INT:
			return str(v)
		TYPE_FLOAT:
			return _num(v)
		TYPE_STRING, TYPE_STRING_NAME:
			return JSON.stringify(String(v))
		TYPE_DICTIONARY:
			var ps: = PackedStringArray()
			for k in (v as Dictionary).keys():
				ps.append("\"%s\": %s" % [k, _value(v[k])])
			return "{ " + ", ".join(ps) + " }"
		TYPE_ARRAY:
			var xs: = PackedStringArray()
			for item in (v as Array):
				xs.append(_value(item))
			return "[" + ", ".join(xs) + "]"
	return JSON.stringify(v)




static func _num(f: float) -> String:
	var s: = "%.3f" % f
	if s.contains("."):
		s = s.rstrip("0")
		if s.ends_with("."):
			s += "0"
	return s
