extends Node





















signal changed

const USER_DIR: = "user://skins"
const EXAMPLE_DIR: = "neon_sunset"

const EXAMPLE_VERSION: = 3




const DEFAULTS: = {

	"lane_0": Color(0.3, 1.0, 0.85), 
	"lane_1": Color(0.72, 0.45, 1.0), 
	"lane_2": Color(1.0, 0.78, 0.25), 
	"lane_shade": Color(0.008, 0.008, 0.02), 
	"timing_perfect": Color(0.45, 1.0, 0.75), 
	"timing_good": Color(1.0, 0.78, 0.25), 
	"receptor_core": Color(0.03, 0.03, 0.06), 
	"receptor_active": Color(1.5, 1.5, 1.5), 

	"parry_glow": Color(0.72, 0.95, 0.92), 
	"parry_trail": Color(0.75, 1.0, 0.95), 
	"parry_core": Color(1.45, 1.5, 1.5), 
	"parry_ring": Color(1.2, 1.25, 1.3), 

	"dodge_glow": Color(1.0, 0.28, 0.3), 
	"dodge_smoke": Color(0.9, 0.2, 0.22), 
	"dodge_trail": Color(1.0, 0.25, 0.3), 
	"dodge_body": Color(1.45, 0.32, 0.36), 
	"dodge_core": Color(0.06, 0.05, 0.08), 
	"dodge_center": Color(1.6, 1.2, 1.2), 
	"dodge_spark": Color(1.5, 0.65, 0.3), 

	"gold": Color(1.06, 0.87, 0.32), 
	"click_core": Color(0.05, 0.045, 0.02), 
	"click_inner": Color(1.35, 1.32, 1.2), 
	"click_dot": Color(1.5, 1.45, 1.3), 
	"click_flash": Color(1.5, 1.5, 1.45), 
	"click_text": Color(1.45, 1.4, 1.2), 
	"clickx_miss": Color(1.3, 0.25, 0.28), 
	"slider_core": Color(0.035, 0.032, 0.015), 
	"slider_ball_core": Color(1.5, 1.45, 1.25), 
	"slider_break": Color(1.45, 0.5, 0.32), 

	"note_outline": Color(1.0, 0.96, 0.86), 
	"note_fill": Color(1.08, 0.86, 0.36), 
	"note_text": Color(1.0, 0.97, 0.9), 
	"slider_body": Color(0.16, 0.12, 0.04), 
	"slider_ball": Color(1.0, 0.86, 0.4), 

	"hold_idle": Color(0.85, 1.0, 0.95), 
	"hold_active": Color(1.05, 1.3, 1.15), 
	"hold_free": Color(0.6, 0.72, 0.68), 
	"hold_broken": Color(0.5, 0.45, 0.48), 
	"hold_core": Color(0.04, 0.06, 0.06), 
	"beam_idle": Color(0.75, 1.0, 0.95), 
	"beam_active": Color(0.95, 1.25, 1.15), 
	"beam_broken": Color(0.55, 0.45, 0.5), 

	"cursor": Color(0.45, 1.0, 0.75), 
	"cursor_hot": Color(1.0, 0.7, 0.32), 
	"cursor_auto": Color(1.0, 0.55, 0.85), 
	"ember_born": Color(1.6, 1.25, 0.5), 
	"ember_die": Color(1.0, 0.35, 0.15), 
	"player": Color(0.45, 1.0, 0.75), 
	"player_hot": Color(1.0, 0.86, 0.42), 

	"hp_full": Color(0.3, 1.0, 0.85), 
	"hp_mid": Color(1.0, 0.82, 0.3), 
	"hp_low": Color(1.0, 0.35, 0.4), 
	"hp_track": Color(1, 1, 1, 0.08), 

	"judge_perfect": Color(0.5, 0.78, 1.38, 0.88), 
	"judge_good": Color(0.55, 1.32, 0.78, 0.85), 
	"judge_meh": Color(1.25, 1.05, 0.45, 0.82), 
	"judge_miss": Color(1.38, 0.42, 0.45, 0.9), 
	"judge_dodge": Color(1.3, 0.85, 0.45, 0.82), 

	"fx_perfect": Color(0.45, 0.82, 1.0), 
	"wave_perfect": Color(0.4, 0.8, 1.0), 
	"wave_dodge": Color(1.0, 0.35, 0.35), 
	"flash_dodge": Color(1.0, 0.45, 0.45), 
	"fx_gold": Color(1.0, 0.82, 0.3), 
	"fx_miss": Color(1.0, 0.35, 0.4), 

	"combo_10": Color(1.0, 0.88, 0.45), 
	"combo_25": Color(1.0, 0.68, 0.25), 
	"combo_50": Color(1.0, 0.45, 0.25), 
}



const TEXTURES: = [
	"glow", 
	"note_parry", 
	"note_dodge", 
	"click_circle", 
	"approach_ring", 
	"receptor", 
	"cursor", 
	"slider_ball", 
	"hp_fill", 

	"slider_tail", 
	"reverse_arrow", 
	"hold_head", 
	"hold_rail", 
	"judge_perfect", 
	"judge_good", 
	"judge_meh", 
	"judge_miss", 
	"lane_fill", 
	"impact_line", 
	"player", 
]



const SOUND_EVENTS: = ["parry_perfect", "parry_good", "click_perfect", "click_good", 
	"dodge", "miss", "slider_tick", "slider_break", "ignite"]



const ANIM_EVENTS: = ["click_hit", "click_miss", "slider_hit", "slider_tick", 
	"slider_end", "slider_break", "parry_hit", "dodge", "miss", "ignite"]

var current: = "DEFAULT"
var gameplay: = false






var style: = "classic"
const STYLES: = ["classic", "flat"]
const CLEAN_DIR: = "clean"
const CLEAN_VERSION: = 1


const PLACEHOLDER_DIR: = "placeholder"
const PLACEHOLDER_VERSION: = 2

var _skins: = {}
var _meta: = {}
var _cols: = {}
var _texs: = {}
var _sounds: = {}
var _bg: = {}
var _fg: Array = []
var _anims: = {}


func _ready() -> void :
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(USER_DIR))









	for old in [EXAMPLE_DIR, CLEAN_DIR]:
		var odir: = ProjectSettings.globalize_path(USER_DIR).path_join(old)
		if FileAccess.file_exists(odir.path_join(".generated")):
			_remove_dir(odir)
			if SettingsManager.skin_name == old:
				SettingsManager.skin_name = "DEFAULT"
	if not _has_any_skin():
		_ensure_placeholder()


	var ph_readme: = ProjectSettings.globalize_path(USER_DIR).path_join(PLACEHOLDER_DIR).path_join("README.md")
	if FileAccess.file_exists(ph_readme):
		DirAccess.remove_absolute(ph_readme)
	rescan()
	apply(SettingsManager.skin_name)



func _remove_dir(path: String) -> void :
	var d: = DirAccess.open(path)
	if d == null:
		return
	for f in d.get_files():
		DirAccess.remove_absolute(path.path_join(f))
	for sub in d.get_directories():
		_remove_dir(path.path_join(sub))
	DirAccess.remove_absolute(path)




func _has_any_skin() -> bool:
	var root: = ProjectSettings.globalize_path(USER_DIR)
	var d: = DirAccess.open(root)
	if d == null:
		return false
	for sub in d.get_directories():
		if FileAccess.file_exists(root.path_join(sub).path_join("skin.json")):
			return true
	for f in d.get_files():
		if f.get_extension().to_lower() == "zip":
			return true
	return false





func col(key: String) -> Color:
	if gameplay and not _cols.is_empty():
		return _cols.get(key, DEFAULTS[key])
	return DEFAULTS[key]




func col_over(key: String, fallback: Color) -> Color:
	if gameplay and _cols.has(key):
		return _cols[key]
	return fallback




func col_raw(key: String, fallback: Color) -> Color:
	return _cols.get(key, fallback)



func flat() -> bool:
	return gameplay and style == "flat"



func background() -> Dictionary:
	return _bg if gameplay else {}



func foregrounds(front: bool) -> Array:
	if not gameplay:
		return []
	var out: Array = []
	for it in _fg:
		if bool(it.get("front", true)) == front:
			out.append(it)
	return out



func anim(event: String) -> Dictionary:
	if not gameplay:
		return {}
	return _anims.get(event, {})



func tex(key: String) -> Texture2D:
	if gameplay:
		return _texs.get(key)
	return null





func hit_stream(event_file: String) -> AudioStream:
	return _sounds.get(event_file)



func label_of(skin: String) -> String:
	return String(_meta.get(skin, {}).get("name", skin.replace("_", " ").to_upper()))


func list() -> Array:
	var names: Array = _skins.keys()
	names.sort()
	return names








func import_dropped(path: String) -> String:
	var base: = ProjectSettings.globalize_path(USER_DIR)
	DirAccess.make_dir_recursive_absolute(base)
	var name: = path.get_file().get_basename()
	if name == "" or name.contains(".."):
		return ""
	if path.get_extension().to_lower() == "zip":
		var z: = ZIPReader.new()
		if z.open(path) != OK:
			return ""
		var has_json: = false
		for f in z.get_files():
			if f.get_file() == "skin.json":
				has_json = true
				break
		z.close()
		if not has_json:
			return ""
		var dest: = base.path_join(name + ".zip")


		_remove_dir(base.path_join(name))
		if not _copy_file(path, dest):
			return ""
	elif DirAccess.dir_exists_absolute(path):
		if not FileAccess.file_exists(path.path_join("skin.json")):
			return ""
		var dest: = base.path_join(name)
		_remove_dir(dest)
		if not _copy_dir(path, dest):
			return ""
	else:
		return ""
	rescan()
	return name if _skins.has(name) else ""


func _copy_file(from: String, to: String) -> bool:
	var src: = FileAccess.open(from, FileAccess.READ)
	if src == null:
		return false
	var dst: = FileAccess.open(to, FileAccess.WRITE)
	if dst == null:
		src.close()
		return false
	while not src.eof_reached():
		dst.store_buffer(src.get_buffer(4 << 20))
	src.close()
	dst.close()
	return true


func _copy_dir(from: String, to: String) -> bool:
	var d: = DirAccess.open(from)
	if d == null:
		return false
	DirAccess.make_dir_recursive_absolute(to)
	for f in d.get_files():
		if not _copy_file(from.path_join(f), to.path_join(f)):
			return false
	for sub in d.get_directories():
		if not _copy_dir(from.path_join(sub), to.path_join(sub)):
			return false
	return true




func rescan() -> void :
	_skins.clear()
	_meta.clear()
	var base: = ProjectSettings.globalize_path(USER_DIR)
	var d: = DirAccess.open(base)
	if d == null:
		return
	for f in d.get_files():
		if f.get_extension().to_lower() == "zip":
			_extract_zip(base.path_join(f))
	for dir in d.get_directories():
		var json_path: = base.path_join(dir).path_join("skin.json")
		if FileAccess.file_exists(json_path):
			_skins[dir] = base.path_join(dir)
			var parsed: Variant = JSON.parse_string(
				FileAccess.get_file_as_string(json_path))
			if parsed is Dictionary:
				_meta[dir] = parsed




func _extract_zip(zip_path: String) -> void :
	var out: = zip_path.get_basename()
	if DirAccess.dir_exists_absolute(out):
		return
	var z: = ZIPReader.new()
	if z.open(zip_path) != OK:
		return
	var files: = z.get_files()

	var root: = ""
	if not files.is_empty() and files[0].contains("/"):
		root = files[0].get_slice("/", 0) + "/"
		for f in files:
			if not f.begins_with(root):
				root = ""
				break
	for f in files:
		if f.ends_with("/"):
			continue
		var rel: = f.trim_prefix(root)
		if rel == "" or rel.contains(".."):
			continue
		var dest: = out.path_join(rel)
		DirAccess.make_dir_recursive_absolute(dest.get_base_dir())
		var fa: = FileAccess.open(dest, FileAccess.WRITE)
		if fa != null:
			fa.store_buffer(z.read_file(f))
	z.close()



func apply(skin: String) -> void :
	_cols.clear()
	_texs.clear()
	_sounds.clear()
	_bg = {}
	_fg = []
	_anims = {}
	style = "classic"
	if not _skins.has(skin):
		skin = "DEFAULT"
	current = skin
	if SettingsManager.skin_name != skin:
		SettingsManager.set_skin_name(skin)
	if skin != "DEFAULT":
		var dir: String = _skins[skin]
		_load_colors(dir)
		_load_textures(dir)
		_load_sounds(dir)
		_load_extras(dir)
	changed.emit()


func _load_colors(dir: String) -> void :
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(dir.path_join("skin.json")))
	if not (parsed is Dictionary):
		return
	var st: = String(parsed.get("style", "classic"))
	style = st if st in STYLES else "classic"
	var cols: Variant = parsed.get("colors", {})
	if not (cols is Dictionary):
		return
	for key in cols:
		if not DEFAULTS.has(key):
			continue
		var c: = _parse_color(cols[key])
		if c.a >= 0.0:


			if not _has_alpha(cols[key]):
				c.a = (DEFAULTS[key] as Color).a
			_cols[key] = c



func _parse_color(v: Variant) -> Color:
	if v is String:
		return Color.from_string(v, Color(0, 0, 0, -1.0))
	if v is Array and v.size() >= 3:
		return Color(float(v[0]), float(v[1]), float(v[2]), 
			float(v[3]) if v.size() > 3 else 1.0)
	return Color(0, 0, 0, -1.0)


func _has_alpha(v: Variant) -> bool:
	return (v is Array and v.size() > 3) or (v is String and String(v).length() >= 9)



func _load_png(dir: String, rel: String) -> Texture2D:
	if rel == "":
		return null
	var path: = dir.path_join(rel)
	if not FileAccess.file_exists(path):
		return null
	var img: = Image.load_from_file(path)
	return ImageTexture.create_from_image(img) if img != null else null



func _load_extras(dir: String) -> void :
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(dir.path_join("skin.json")))
	if not (parsed is Dictionary):
		return
	var bg: Variant = parsed.get("background", null)
	if bg is Dictionary:
		var t: = _load_png(dir, String(bg.get("image", "")))
		if t != null:
			_bg = {"tex": t, "mode": String(bg.get("mode", "replace")), 
				"opacity": clampf(float(bg.get("opacity", 1.0)), 0.0, 1.0), 
				"dim": clampf(float(bg.get("dim", 0.0)), 0.0, 1.0)}
	var fg: Variant = parsed.get("foreground", [])
	if fg is Array:
		for e in fg:
			if not (e is Dictionary):
				continue
			var t2: = _load_png(dir, String(e.get("image", "")))
			if t2 == null:
				continue
			var it: Dictionary = e.duplicate()
			it["tex"] = t2
			it["front"] = String(e.get("layer", "front")) != "back"
			_fg.append(it)
	var an: Variant = parsed.get("animations", {})
	if an is Dictionary:
		for key in an:
			if not (String(key) in ANIM_EVENTS) or not (an[key] is Dictionary):
				continue
			var t3: = _load_png(dir, String(an[key].get("image", "")))
			if t3 == null:
				continue
			var a: Dictionary = an[key].duplicate()
			a["tex"] = t3
			_anims[String(key)] = a





	for ev in ANIM_EVENTS:
		var t4: = _load_png(dir, "anim_%s.png" % ev)
		if t4 == null:
			continue
		var a2: Dictionary
		if _anims.has(ev):
			a2 = (_anims[ev] as Dictionary).duplicate()
		else:
			var n: = maxi(1, roundi(float(t4.get_width()) / maxf(float(t4.get_height()), 1.0)))
			a2 = {"frames": n, "columns": n, "fps": 16, "size": 200, "blend": "mix"}
		a2["tex"] = t4
		a2["image"] = "anim_%s.png" % ev
		_anims[ev] = a2


func _load_textures(dir: String) -> void :
	for key in TEXTURES:
		var path: = dir.path_join(key + ".png")
		if not FileAccess.file_exists(path):
			continue
		var img: = Image.load_from_file(path)
		if img != null:
			_texs[key] = ImageTexture.create_from_image(img)


func _load_sounds(dir: String) -> void :
	for event in SOUND_EVENTS:
		for sub in ["sfx/", ""]:
			var wav: = dir.path_join(sub + event + ".wav")
			if FileAccess.file_exists(wav):
				var s: = AudioStreamWAV.load_from_file(wav)
				if s != null:
					_sounds[event] = s
					break
			var mp3: = dir.path_join(sub + event + ".mp3")
			if FileAccess.file_exists(mp3):
				var m: = AudioStreamMP3.new()
				m.data = FileAccess.get_file_as_bytes(mp3)
				if m.data.size() > 0:
					_sounds[event] = m
					break



func open_folder() -> void :
	var p: = ProjectSettings.globalize_path(USER_DIR)
	DirAccess.make_dir_recursive_absolute(p)
	OS.shell_open(p)







func _ensure_example() -> void :
	var dir: = ProjectSettings.globalize_path(USER_DIR).path_join(EXAMPLE_DIR)
	var marker: = dir.path_join(".generated")
	if FileAccess.file_exists(marker)\
	and FileAccess.get_file_as_string(marker).strip_edges()\
	== str(EXAMPLE_VERSION):
		return
	DirAccess.make_dir_recursive_absolute(dir.path_join("sfx"))
	_write_example_json(dir)
	_write_example_readme(dir)
	_write_example_textures(dir)
	_write_example_sounds(dir)
	var fa: = FileAccess.open(marker, FileAccess.WRITE)
	if fa != null:
		fa.store_string(str(EXAMPLE_VERSION))




func _ensure_clean() -> void :
	var dir: = ProjectSettings.globalize_path(USER_DIR).path_join(CLEAN_DIR)
	var marker: = dir.path_join(".generated")
	if FileAccess.file_exists(marker)\
	and FileAccess.get_file_as_string(marker).strip_edges()\
	== str(CLEAN_VERSION):
		return
	DirAccess.make_dir_recursive_absolute(dir)
	var fa: = FileAccess.open(dir.path_join("skin.json"), FileAccess.WRITE)
	if fa != null:
		fa.store_string("\n".join(["{", 
			"\t\"name\": \"CLEAN\",", 
			"\t\"author\": \"rythm-game (pack généré)\",", 
			"\t\"style\": \"flat\",", 
			"\t\"colors\": {", 
			"\t\t\"note_outline\": \"#fff5db\",", 
			"\t\t\"note_fill\": [1.08, 0.86, 0.36],", 
			"\t\t\"note_text\": \"#fff7e6\",", 
			"\t\t\"slider_body\": [0.16, 0.12, 0.04],", 
			"\t\t\"slider_ball\": [1.00, 0.86, 0.40],", 
			"\t\t\"gold\": [1.06, 0.87, 0.32]", 
			"\t}", "}"]) + "\n")
	var rd: = FileAccess.open(dir.path_join("README.md"), FileAccess.WRITE)
	if rd != null:
		rd.store_string("# CLEAN\n\nLe rendu PLAT des cibles jaunes et des sliders : "
			+ "contour crème épais, liseré or, disque or semi-transparent, numéro "
			+ "d'ordre au centre, rail à contour continu et intérieur sombre "
			+ "translucide, balle cerclée de crème. Aucun halo, aucun éclat.\n\n"
			+ "C'est la clé \"style\": \"flat\" du skin.json qui l'active — "
			+ "n'importe quel skin peut la reprendre (\"classic\" = look d'origine). "
			+ "Les couleurs note_outline, note_fill, note_text, slider_body, "
			+ "slider_ball ne servent qu'à ce style.\n")
	var mk: = FileAccess.open(marker, FileAccess.WRITE)
	if mk != null:
		mk.store_string(str(CLEAN_VERSION))





const EXAMPLE_COLORS: = {
	"lane_0": "#ff4f9a", "lane_1": "#ffa040", "lane_2": "#b06bff", 
	"lane_shade": "#050208", 
	"timing_perfect": "#ffb060", "timing_good": "#ff4f9a", 
	"receptor_core": "#14060e", "receptor_active": [1.6, 1.4, 1.3], 
	"parry_glow": "#ffd8c0", "parry_trail": "#ffe0c8", 
	"parry_core": [1.55, 1.35, 1.15], "parry_ring": [1.4, 1.1, 0.9], 
	"dodge_glow": "#20d8ff", "dodge_smoke": "#18a0d0", "dodge_trail": "#30e0ff", 
	"dodge_body": [0.35, 1.45, 1.65], "dodge_core": "#04121a", 
	"dodge_center": [1.2, 1.6, 1.7], "dodge_spark": [0.5, 1.5, 1.6], 
	"gold": [1.35, 0.62, 0.3], "click_core": "#180a04", 
	"click_inner": [1.5, 1.2, 0.95], "click_dot": [1.6, 1.3, 1.0], 
	"click_flash": [1.6, 1.4, 1.2], "click_text": [1.55, 1.25, 0.95], 
	"clickx_miss": [0.3, 1.35, 1.55], 
	"slider_core": "#160a05", "slider_ball_core": [1.6, 1.3, 1.0], 
	"slider_break": [0.35, 1.45, 1.6], 
	"hold_idle": "#ffd0e8", "hold_active": [1.4, 1.05, 1.25], 
	"hold_free": "#a07890", "hold_broken": "#705060", "hold_core": "#140810", 
	"beam_idle": "#ffd0e8", "beam_active": [1.4, 1.05, 1.25], 
	"beam_broken": "#705060", 
	"cursor": "#ffcf70", "cursor_hot": [1.5, 0.55, 0.85], 
	"cursor_auto": "#70e8ff", 
	"ember_born": [1.6, 0.9, 1.2], "ember_die": [1.0, 0.25, 0.55], 
	"player": "#ffcf70", "player_hot": [1.5, 0.55, 0.85], 
	"hp_full": "#ff4f9a", "hp_mid": "#ffa040", "hp_low": [1.4, 0.25, 0.35], 
	"hp_track": [1.0, 0.7, 0.85, 0.1], 
	"judge_perfect": [1.45, 0.85, 0.5, 0.9], 
	"judge_good": [1.35, 0.55, 1.1, 0.85], 
	"judge_meh": [1.3, 0.95, 0.55, 0.82], 
	"judge_miss": [0.4, 1.3, 1.5, 0.9], 
	"judge_dodge": [0.55, 1.35, 1.45, 0.82], 
	"fx_perfect": "#ffb060", "wave_perfect": "#ff9040", 
	"wave_dodge": "#30d0f0", "flash_dodge": "#40c8e8", 
	"fx_gold": "#ff6a8a", "fx_miss": "#30d0f0", 
	"combo_10": [1.0, 0.75, 0.95], "combo_25": [1.2, 0.55, 0.9], 
	"combo_50": [1.45, 0.4, 0.75], 
}


func _write_example_json(dir: String) -> void :


	var lines: = ["{", 
		"\t\"name\": \"NEON SUNSET\",", 
		"\t\"author\": \"rythm-game (pack d'exemple généré)\",", 
		"\t\"colors\": {"]
	var keys: = DEFAULTS.keys()
	for i in keys.size():
		var k: String = keys[i]
		var v: Variant = EXAMPLE_COLORS.get(k, _hex_of(DEFAULTS[k]))
		var vs: String
		if v is String:
			vs = "\"%s\"" % v
		else:
			var parts: = []
			for x in v:
				parts.append("%.2f" % float(x))
			vs = "[%s]" % ", ".join(parts)
		lines.append("\t\t\"%s\": %s%s" % [k, vs, "," if i < keys.size() - 1 else ""])
	lines.append("\t},")


	lines.append("\t\"background\": {\"image\": \"background.png\", \"mode\": \"over\", \"opacity\": 0.55, \"dim\": 0.0},")
	lines.append("\t\"foreground\": [")
	lines.append("\t\t{\"image\": \"foreground.png\", \"x\": 0.07, \"y\": 1.0, \"anchor\": \"bottom\", \"scale\": 0.62, \"opacity\": 0.85, \"beat_bounce\": 0.04, \"layer\": \"front\"},")
	lines.append("\t\t{\"image\": \"foreground.png\", \"x\": 0.93, \"y\": 1.0, \"anchor\": \"bottom\", \"scale\": 0.62, \"opacity\": 0.85, \"beat_bounce\": 0.04, \"layer\": \"front\"}")
	lines.append("\t],")
	lines.append("\t\"animations\": {")
	lines.append("\t\t\"click_hit\": {\"image\": \"anim_burst.png\", \"frames\": 8, \"columns\": 8, \"fps\": 30, \"size\": 260, \"blend\": \"add\"},")
	lines.append("\t\t\"slider_end\": {\"image\": \"anim_burst.png\", \"frames\": 8, \"columns\": 8, \"fps\": 30, \"size\": 300, \"blend\": \"add\"},")
	lines.append("\t\t\"parry_hit\": {\"image\": \"anim_burst.png\", \"frames\": 8, \"columns\": 8, \"fps\": 30, \"size\": 220, \"blend\": \"add\"}")
	lines.append("\t}")
	lines.append("}")
	var fa: = FileAccess.open(dir.path_join("skin.json"), FileAccess.WRITE)
	if fa != null:
		fa.store_string("\n".join(lines) + "\n")


func _hex_of(c: Color) -> String:
	return "#" + c.to_html(false)


func _write_example_readme(dir: String) -> void :
	var t: = "# NEON SUNSET — pack d'exemple ET documentation des skins\n\n"
	t += "Ce dossier est un skin complet genere par le jeu. Il montre TOUT ce\n"
	t += "qu'un skin peut changer. Pour creer le tien : copie ce dossier, renomme-le,\n"
	t += "modifie ce que tu veux, puis choisis-le dans SETTINGS > VISUAL > SKIN.\n"
	t += "Pour IMPORTER un skin telecharge : pose son .zip (ou son dossier) dans\n"
	t += "user://skins/ (bouton OPEN SKINS FOLDER des reglages) puis RELOAD.\n"
	t += "Pour PARTAGER ton skin : zippe son dossier, envoie le zip.\n\n"
	t += "Le skin ne s'applique QU'EN PARTIE : menus, atelier et mascottes ne\n"
	t += "changent jamais. Les flammes du mode ON FIRE gardent leurs couleurs, et\n"
	t += "la choregraphie de lanes d'une map (lane_color) prime sur le skin.\n\n"
	t += "## skin.json\n\n"
	t += "Cle \"style\" : \"classic\" (defaut, le look d'origine) ou \"flat\" — le rendu\n"
	t += "plat des cibles jaunes et des sliders (contour creme epais, disque or\n"
	t += "semi-transparent, numeros d'ordre, rail a contour continu). Le pack genere\n"
	t += "CLEAN (user://skins/clean) en est l'exemple ; les cles note_outline,\n"
	t += "note_fill, note_text, slider_body, slider_ball ne servent qu'a ce style.\n\n"
	t += "Toutes les cles sont OPTIONNELLES : une cle absente garde le look du jeu.\n"
	t += "Deux formats de couleur :\n"
	t += "- \"#rrggbb\" ou \"#rrggbbaa\" (hex classique)\n"
	t += "- [r, g, b] ou [r, g, b, a] en flottants — ils peuvent DEPASSER 1.0 :\n"
	t += "  au-dela de ~1.15 la couleur rayonne (glow HDR du jeu).\n"
	t += "Sans alpha fourni, l'alpha d'origine de la cle est conserve.\n\n"
	t += "### Les cles, avec leur valeur d'origine\n\n"
	var groups: = {
		"lane_": "Lanes & terrain (timing_*, receptor_* inclus)", 
		"parry_": "Note blanche de lane (parry)", 
		"dodge_": "Note rouge de lane (dodge)", 
		"gold": "Cibles jaunes, sliders, chiffres (click_*, slider_*, clickx_*)", 
		"hold_": "Tenues de lane (sliderm) et faisceaux (beam_*)", 
		"cursor": "Curseur, braises de fievre, point joueur (ember_*, player*)", 
		"hp_": "Barre de vie", 
		"judge_": "Textes de jugement (PERFECT / GOOD / MISS / dodge)", 
		"fx_": "Ondes, gerbes et flashes de la ligne (wave_*, flash_*)", 
		"combo_": "Compteur de combo qui chauffe", 
	}
	for k in DEFAULTS:
		var c: Color = DEFAULTS[k]
		t += "- `%s` : `[%.2f, %.2f, %.2f, %.2f]`\n" % [k, c.r, c.g, c.b, c.a]
	t += "\nReperes : %s\n\n" % ", ".join(groups.values())
	t += "## Textures (PNG optionnels, a la racine du skin)\n\n"
	t += "Chaque PNG present REMPLACE le dessin d'origine de l'element (les halos\n"
	t += "et trainees restent, aux couleurs du skin). Toutes les tailles sont\n"
	t += "acceptees (l'image est mise a l'echelle) ; le pack utilise du 256x256.\n\n"
	t += "- `glow.png` — le halo doux utilise partout (blanc, teinte au dessin)\n"
	t += "- `note_parry.png` — la note blanche (affichee sur ~72 px)\n"
	t += "- `note_dodge.png` — la note rouge (affichee sur ~72 px)\n"
	t += "- `click_circle.png` — le cercle des cibles jaunes (diametre de jeu ~116 px)\n"
	t += "- `approach_ring.png` — l'anneau d'approche osu (etire en retrecissant)\n"
	t += "- `receptor.png` — le receptacle en bas de lane (TEINTE par la couleur de lane)\n"
	t += "- `cursor.png` — le curseur (la trainee et le halo restent dessines)\n"
	t += "- `slider_ball.png` — la balle du slider guide\n"
	t += "- `hp_fill.png` — le remplissage de la barre de vie (etire sur la jauge)\n"
	t += "- `slider_tail.png` — la queue du slider jaune (~50 px)\n"
	t += "- `reverse_arrow.png` — la fleche de demi-tour (pointe vers la DROITE dans le PNG,\n"
	t += "  le jeu la tourne dans le sens de la reprise)\n"
	t += "- `hold_head.png` — la tete d'une tenue BLANCHE (sliderm), sur la ligne\n"
	t += "- `hold_rail.png` — le ruban d'une tenue blanche, REPETE le long de la lane\n"
	t += "- `judge_perfect.png`, `judge_good.png`, `judge_miss.png` — remplacent le TEXTE\n"
	t += "  de jugement geant (affiches sur ~520x64, ratio conserve)\n"
	t += "- `lane_fill.png` — l'image d'une LANE, etiree sur son quadrilatere (haut de\n"
	t += "  l'image = haut de la lane), teintee par la couleur de la lane\n"
	t += "- `impact_line.png` — la ligne d'impact, etiree sur toute la largeur\n"
	t += "- `player.png` — le point joueur sur la ligne (~64 px, teinte)\n\n"
	t += "Le pack PLACEHOLDER (user://skins/placeholder) montre CHAQUE element etiquete\n"
	t += "de son nom : active-le pour voir ou chaque image s'affiche.\n\n"
	t += "## Fond, images de scene, animations (skin.json)\n\n"
	t += "`\"background\": {\"image\": \"background.png\", \"mode\": \"replace\"|\"over\",\n"
	t += "\"opacity\": 0..1, \"dim\": 0..1}` — image plein ecran (cover) en partie :\n"
	t += "`replace` prend la place du fond de la map, `over` se pose par-dessus.\n\n"
	t += "`\"foreground\": [{...}, ...]` — des images posees sur la scene (personnages,\n"
	t += "decor) : `image`, `x`/`y` en fractions d'ecran (0..1), `anchor` (bottom,\n"
	t += "center, top, bottom_left, bottom_right), `scale` = hauteur en fraction de\n"
	t += "l'ecran, `opacity`, `layer` (`front` = devant le terrain sous le HUD,\n"
	t += "`back` = derriere le terrain), `beat_bounce` (rebond au beat, ex 0.04), et\n"
	t += "pour une image ANIMEE : `frames`, `columns` (sprite-sheet en grille), `fps`.\n\n"
	t += "`\"animations\": {\"event\": {...}}` — une sprite-sheet jouee UNE fois a\n"
	t += "l'endroit de l'evenement : `image`, `frames`, `columns`, `fps`, `size` (px,\n"
	t += "largeur d'une frame a l'ecran), `blend` (`mix` ou `add` = lumineux),\n"
	t += "`random_rotation` (true/false). Evenements : click_hit, click_miss, slider_hit,\n"
	t += "slider_tick, slider_end, slider_break, parry_hit, dodge, miss, ignite.\n"
	t += "Le pack utilise anim_burst.png (8 frames de 128 px en ligne).\n"
	t += "JAUNES = click_hit / click_miss, BLANCS = parry_hit / dodge / miss. Un fichier\n"
	t += "anim_<event>.png a la racine du skin PRIME sur l'image du skin.json.\n\n"
	t += "## Hitsounds (dossier sfx/, optionnels)\n\n"
	t += "wav ou mp3, noms exacts : `parry_perfect`, `parry_good`, `click_perfect`,\n"
	t += "`click_good`, `dodge`, `miss`, `slider_tick`, `slider_break`, `ignite`.\n"
	t += "Sans fichier *_good, le GOOD joue le perfect (regle du jeu) ; slider_tick,\n"
	t += "slider_break et ignite ne jouent QUE si le skin les fournit.\n\n"
	t += "## Priorites\n\n"
	t += "hitsounds : skin > user://hitsounds/ (reglages) > sons du jeu.\n"
	t += "couleurs/textures : skin > jeu. Chart lane_color > skin (lanes).\n\n"
	t += "Ce pack se regenere si tu le supprimes — pour experimenter dessus,\n"
	t += "copie-le d'abord sous un autre nom.\n"
	var fa: = FileAccess.open(dir.path_join("README.md"), FileAccess.WRITE)
	if fa != null:
		fa.store_string(t)




func _write_example_textures(dir: String) -> void :
	_png(dir, "glow", 256, _px_glow)
	_png(dir, "note_parry", 256, _px_parry)
	_png(dir, "note_dodge", 256, _px_dodge)
	_png(dir, "click_circle", 256, _px_click)
	_png(dir, "approach_ring", 256, _px_ring)
	_png(dir, "receptor", 256, _px_receptor)
	_png(dir, "cursor", 256, _px_cursor)
	_png(dir, "slider_ball", 128, _px_ball)
	_png_rect(dir, "hp_fill", 220, 14, _px_hp)
	_png_rect(dir, "background", 512, 288, _px_background)
	_png_rect(dir, "foreground", 128, 384, _px_foreground)
	_png_rect(dir, "anim_burst", 1024, 128, _px_burst)



func _px_background(u: Vector2) -> Color:
	var sky: = Color(0.1, 0.04, 0.22).lerp(Color(0.95, 0.35, 0.3), pow(u.y, 1.6))
	var sun: = clampf(1.0 - Vector2(u.x - 0.5, (u.y - 0.62) * 1.8).length() * 3.2, 0.0, 1.0)
	return sky.lerp(Color(1.0, 0.75, 0.35), sun * sun)



func _px_foreground(u: Vector2) -> Color:
	var cx: = absf(u.x - 0.5) * 2.0
	var a: = clampf(1.0 - cx * cx, 0.0, 1.0) * (1.0 - u.y * 0.85)
	return Color(1.0, 0.55, 0.75, a * 0.7)



func _px_burst(u: Vector2) -> Color:
	var frame: = floorf(u.x * 8.0)
	var p: = (frame + 0.5) / 8.0
	var v: = Vector2((u.x * 8.0 - frame) * 2.0 - 1.0, u.y * 2.0 - 1.0)
	var r: = v.length()
	var ring: = _ring_a(r, 0.25 + 0.7 * p, 0.1 + 0.06 * p)
	return Color(1.0, 0.72, 0.3, ring * (1.0 - p))



func _png(dir: String, name: String, size: int, f: Callable) -> void :
	var img: = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		for x in size:
			var v: = Vector2(x + 0.5, y + 0.5) / size * 2.0 - Vector2.ONE
			img.set_pixel(x, y, f.call(v))
	img.save_png(dir.path_join(name + ".png"))


func _png_rect(dir: String, name: String, w: int, h: int, f: Callable) -> void :
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			img.set_pixel(x, y, f.call(Vector2((x + 0.5) / w, (y + 0.5) / h)))
	img.save_png(dir.path_join(name + ".png"))


static func _ring_a(r: float, at: float, w: float) -> float:
	return clampf(1.0 - absf(r - at) / w, 0.0, 1.0)


func _px_glow(v: Vector2) -> Color:

	var r: = v.length()
	var a: = clampf(1.0 - r, 0.0, 1.0)
	a = a * a * (0.5 + 0.5 * a)
	return Color(1.0, 0.94, 0.9, a)


func _px_parry(v: Vector2) -> Color:

	var r: = v.length()
	var ang: = atan2(v.y, v.x)
	var core: = clampf(1.0 - r / 0.42, 0.0, 1.0)
	var ring: = _ring_a(r, 0.68, 0.1)
	var petals: = clampf(0.5 + 0.5 * cos(ang * 4.0), 0.0, 1.0)\
	* _ring_a(r, 0.68, 0.24) * 0.6
	var a: = clampf(core + ring + petals, 0.0, 1.0)
	var col: = Color(1.0, 0.88, 0.78).lerp(Color(1.0, 0.72, 0.55), r)
	return Color(col.r, col.g, col.b, a)


func _px_dodge(v: Vector2) -> Color:


	var av: = v.abs()
	var star: = pow(av.x, 0.6) + pow(av.y, 0.6)
	var body: = clampf((0.97 - star) * 9.0, 0.0, 1.0)
	var core: = clampf((0.52 - star) * 5.0, 0.0, 1.0)
	var edge: = clampf(1.0 - absf(star - 0.9) / 0.09, 0.0, 1.0)
	var col: = Color(0.15, 0.78, 0.98).lerp(Color(0.02, 0.1, 0.16), core)
	col = col.lerp(Color(0.6, 1.0, 1.0), edge)
	return Color(col.r, col.g, col.b, body)


func _px_click(v: Vector2) -> Color:

	var r: = v.length()
	var ang: = atan2(v.y, v.x)
	if r > 1.0:
		return Color(0, 0, 0, 0)
	var disc: = clampf((0.97 - r) * 14.0, 0.0, 1.0)
	var ring: = _ring_a(r, 0.86, 0.11)
	var inner: = _ring_a(r, 0.52, 0.045)
	var rays: = clampf(0.5 + 0.5 * cos(ang * 12.0), 0.0, 1.0)
	rays = pow(rays, 3.0) * _ring_a(r, 0.68, 0.14) * 0.8
	var dot: = clampf(1.0 - r / 0.07, 0.0, 1.0)
	var col: = Color(0.09, 0.04, 0.02, 0.88 * disc)
	col = col.lerp(Color(1.0, 0.55, 0.22), maxf(ring, rays))
	col = col.lerp(Color(1.0, 0.85, 0.65), maxf(inner, dot))
	col.a = maxf(col.a, maxf(maxf(ring, rays), maxf(inner, dot)))
	return col


func _px_ring(v: Vector2) -> Color:


	var r: = v.length()
	var ang: = atan2(v.y, v.x)
	var dash: = 0.0 if fposmod(ang * 8.0 / PI, 1.0) > 0.72 else 1.0
	var a: = _ring_a(r, 0.9, 0.07) * dash
	return Color(1.0, 0.62, 0.3, a)


func _px_receptor(v: Vector2) -> Color:

	var av: = v.abs()
	var d: = av.x + av.y
	var edge: = clampf(1.0 - absf(d - 0.8) / 0.14, 0.0, 1.0)
	var core: = clampf((0.52 - d) * 5.0, 0.0, 1.0)
	var a: = maxf(edge, core * 0.35)
	return Color(1.0, 1.0, 1.0, a)


func _px_cursor(v: Vector2) -> Color:

	var r: = v.length()
	var ang: = atan2(v.y, v.x)
	var ring: = _ring_a(r, 0.55, 0.09)
	var spikes: = pow(clampf(0.5 + 0.5 * cos(ang * 8.0), 0.0, 1.0), 4.0)\
	* clampf(1.0 - absf(r - 0.78) / 0.22, 0.0, 1.0)
	var dot: = clampf(1.0 - r / 0.16, 0.0, 1.0)
	var a: = clampf(ring + spikes + dot, 0.0, 1.0)
	var col: = Color(1.0, 0.82, 0.45).lerp(Color(1.0, 0.6, 0.75), r)
	return Color(col.r, col.g, col.b, a)


func _px_ball(v: Vector2) -> Color:
	var r: = v.length()
	var a: = clampf((0.95 - r) * 8.0, 0.0, 1.0)
	var col: = Color(1.0, 0.9, 0.7).lerp(Color(1.0, 0.5, 0.35), clampf(r * 1.3, 0.0, 1.0))
	return Color(col.r, col.g, col.b, a)


func _px_hp(uv: Vector2) -> Color:

	var col: = Color(1.0, 0.31, 0.6).lerp(Color(1.0, 0.63, 0.25), uv.x)
	if uv.y < 0.25:
		col = col.lerp(Color(1.0, 0.9, 0.85), 0.35 * (1.0 - uv.y / 0.25))
	var a: = 1.0
	var ex: = minf(uv.x, 1.0 - uv.x) * 220.0
	var ey: = minf(uv.y, 1.0 - uv.y) * 14.0
	if ex < 7.0 and ey < 7.0:
		var d: = Vector2(7.0 - ex, 7.0 - ey).length()
		a = clampf(7.0 - d + 0.5, 0.0, 1.0)
	return Color(col.r, col.g, col.b, a)




func _write_example_sounds(dir: String) -> void :
	_wav(dir, "parry_perfect", _synth_pluck(660.0, 0.2, 0.9))
	_wav(dir, "click_perfect", _synth_pluck(990.0, 0.12, 0.7))
	_wav(dir, "dodge", _synth_swish())
	_wav(dir, "miss", _synth_thud())


const SR: = 44100


func _wav(dir: String, name: String, samples: PackedFloat32Array) -> void :
	var data: = PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var fa: = FileAccess.open(dir.path_join("sfx").path_join(name + ".wav"), 
		FileAccess.WRITE)
	if fa == null:
		return
	fa.store_buffer("RIFF".to_ascii_buffer())
	fa.store_32(36 + data.size())
	fa.store_buffer("WAVE".to_ascii_buffer())
	fa.store_buffer("fmt ".to_ascii_buffer())
	fa.store_32(16)
	fa.store_16(1)
	fa.store_16(1)
	fa.store_32(SR)
	fa.store_32(SR * 2)
	fa.store_16(2)
	fa.store_16(16)
	fa.store_buffer("data".to_ascii_buffer())
	fa.store_32(data.size())
	fa.store_buffer(data)




func _synth_pluck(freq: float, dur: float, amp: float) -> PackedFloat32Array:
	var n: = int(dur * SR)
	var out: = PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t: = float(i) / SR
		var env: = exp( - t / (dur * 0.24)) * minf(t / 0.002, 1.0)
		var s: = sin(TAU * freq * t) + 0.45 * sin(TAU * freq * 1.5 * t)\
		+ 0.3 * sin(TAU * freq * 2.0 * t + 0.7)
		out[i] = s * env * amp * 0.5
	return out



func _synth_swish() -> PackedFloat32Array:
	var n: = int(0.13 * SR)
	var out: = PackedFloat32Array()
	out.resize(n)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 42
	var lp: = 0.0
	for i in n:
		var t: = float(i) / SR
		var k: = 0.1 + 0.35 * (t / 0.13)
		lp += (rng.randf_range(-1.0, 1.0) - lp) * k
		out[i] = lp * exp( - t / 0.045) * 0.8
	return out



func _synth_thud() -> PackedFloat32Array:
	var n: = int(0.22 * SR)
	var out: = PackedFloat32Array()
	out.resize(n)
	var rng: = RandomNumberGenerator.new()
	rng.seed = 7
	var lp: = 0.0
	var phase: = 0.0
	for i in n:
		var t: = float(i) / SR
		phase += TAU * lerpf(150.0, 55.0, minf(t / 0.1, 1.0)) / SR
		lp += (rng.randf_range(-1.0, 1.0) - lp) * 0.06
		out[i] = (sin(phase) * 0.85 + lp * 0.5) * exp( - t / 0.07) * 0.85
	return out









func _ensure_placeholder() -> void :
	var dir: = ProjectSettings.globalize_path(USER_DIR).path_join(PLACEHOLDER_DIR)
	var marker: = dir.path_join(".generated")
	if FileAccess.file_exists(marker)\
	and FileAccess.get_file_as_string(marker).strip_edges()\
	== str(PLACEHOLDER_VERSION):
		return
	DirAccess.make_dir_recursive_absolute(dir.path_join("sfx"))

	var sizes: = {
		"glow": Vector2i(256, 256), "note_parry": Vector2i(128, 128), "note_dodge": Vector2i(128, 128), 
		"click_circle": Vector2i(256, 256), "approach_ring": Vector2i(256, 256), 
		"receptor": Vector2i(128, 128), "cursor": Vector2i(128, 128), "slider_ball": Vector2i(128, 128), 
		"hp_fill": Vector2i(256, 24), "slider_tail": Vector2i(128, 128), "reverse_arrow": Vector2i(128, 128), 
		"hold_head": Vector2i(128, 128), "hold_rail": Vector2i(64, 128), 
		"judge_perfect": Vector2i(520, 64), "judge_good": Vector2i(520, 64), "judge_miss": Vector2i(520, 64), 
		"judge_meh": Vector2i(520, 64), 
		"lane_fill": Vector2i(160, 512), "impact_line": Vector2i(1024, 40), "player": Vector2i(128, 128), 
	}
	var hues: = {"note_parry": 0.5, "note_dodge": 0.0, "click_circle": 0.13, "approach_ring": 0.13, 
		"slider_ball": 0.13, "slider_tail": 0.13, "reverse_arrow": 0.13, "hold_head": 0.45, 
		"hold_rail": 0.45, "judge_perfect": 0.58, "judge_good": 0.36, "judge_meh": 0.14, "judge_miss": 0.0, 
		"lane_fill": 0.75, "impact_line": 0.85, "player": 0.42, "cursor": 0.42, "receptor": 0.75, 
		"hp_fill": 0.45, "glow": 0.1}
	for key in TEXTURES:
		var sz: Vector2i = sizes.get(key, Vector2i(128, 128))
		var round_shape: bool = key in ["glow", "note_parry", "note_dodge", "click_circle", 
			"approach_ring", "receptor", "cursor", "slider_ball", "slider_tail", "hold_head", "player"]
		_label_png(dir, key, sz.x, sz.y, Color.from_hsv(float(hues.get(key, 0.6)), 0.75, 1.0), 
			key.to_upper(), round_shape, key == "approach_ring")

	_label_png(dir, "background", 640, 360, Color(0.25, 0.3, 0.55), "BACKGROUND", false, false)
	_label_png(dir, "foreground_left", 160, 400, Color(0.95, 0.45, 0.75), "FOREGROUND LEFT", false, false)
	_label_png(dir, "foreground_right", 160, 400, Color(0.45, 0.85, 0.95), "FOREGROUND RIGHT", false, false)
	_label_png(dir, "foreground_back", 400, 160, Color(0.55, 0.55, 0.65), "LAYER BACK", false, false)
	for ev in ANIM_EVENTS:
		_sheet_png(dir, "anim_%s" % ev, 128, 8, ev)

	var pitches: = {"parry_perfect": 660.0, "parry_good": 560.0, "click_perfect": 990.0, 
		"click_good": 840.0, "slider_tick": 1320.0, "slider_break": 300.0, "ignite": 440.0}
	for ev in SOUND_EVENTS:
		if ev == "dodge":
			_wav(dir, ev, _synth_swish())
		elif ev == "miss":
			_wav(dir, ev, _synth_thud())
		else:
			_wav(dir, ev, _synth_pluck(float(pitches.get(ev, 700.0)), 0.16, 0.8))

	var lines: = ["{", 
		"\t\"name\": \"PLACEHOLDER\",", 
		"\t\"author\": \"rythm-game (catalogue généré : tout ce qu'un skin peut changer)\",", 
		"\t\"style\": \"classic\",", 
		"\t\"colors\": {"]
	var keys: = DEFAULTS.keys()
	for i in keys.size():
		var k: String = keys[i]
		var c: Color = DEFAULTS[k]
		lines.append("\t\t\"%s\": [%.2f, %.2f, %.2f, %.2f]%s" % [k, c.r, c.g, c.b, c.a, 
			"," if i < keys.size() - 1 else ""])
	lines.append("\t},")
	lines.append("\t\"background\": {\"image\": \"background.png\", \"mode\": \"over\", \"opacity\": 0.35, \"dim\": 0.0},")
	lines.append("\t\"foreground\": [")
	lines.append("\t\t{\"image\": \"foreground_left.png\", \"x\": 0.08, \"y\": 0.98, \"anchor\": \"bottom\", \"scale\": 0.45, \"opacity\": 0.9, \"layer\": \"front\", \"beat_bounce\": 0.05},")
	lines.append("\t\t{\"image\": \"foreground_right.png\", \"x\": 0.92, \"y\": 0.98, \"anchor\": \"bottom\", \"scale\": 0.45, \"opacity\": 0.9, \"layer\": \"front\"},")
	lines.append("\t\t{\"image\": \"foreground_back.png\", \"x\": 0.5, \"y\": 0.04, \"anchor\": \"top\", \"scale\": 0.12, \"opacity\": 0.8, \"layer\": \"back\"}")
	lines.append("\t],")
	lines.append("\t\"animations\": {")
	for i in ANIM_EVENTS.size():
		lines.append("\t\t\"%s\": {\"image\": \"anim_%s.png\", \"frames\": 8, \"columns\": 8, \"fps\": 16, \"size\": 200, \"blend\": \"mix\"}%s"
			%[ANIM_EVENTS[i], ANIM_EVENTS[i], "," if i < ANIM_EVENTS.size() - 1 else ""])
	lines.append("\t}")
	lines.append("}")
	var fa: = FileAccess.open(dir.path_join("skin.json"), FileAccess.WRITE)
	if fa != null:
		fa.store_string("\n".join(lines) + "\n")


	var mk: = FileAccess.open(marker, FileAccess.WRITE)
	if mk != null:
		mk.store_string(str(PLACEHOLDER_VERSION))



const _FONT: = {
	"A": ["010", "101", "111", "101", "101"], "B": ["110", "101", "110", "101", "110"], 
	"C": ["011", "100", "100", "100", "011"], "D": ["110", "101", "101", "101", "110"], 
	"E": ["111", "100", "110", "100", "111"], "F": ["111", "100", "110", "100", "100"], 
	"G": ["011", "100", "101", "101", "011"], "H": ["101", "101", "111", "101", "101"], 
	"I": ["111", "010", "010", "010", "111"], "J": ["001", "001", "001", "101", "010"], 
	"K": ["101", "101", "110", "101", "101"], "L": ["100", "100", "100", "100", "111"], 
	"M": ["101", "111", "111", "101", "101"], "N": ["110", "101", "101", "101", "101"], 
	"O": ["010", "101", "101", "101", "010"], "P": ["110", "101", "110", "100", "100"], 
	"Q": ["010", "101", "101", "011", "001"], "R": ["110", "101", "110", "101", "101"], 
	"S": ["011", "100", "010", "001", "110"], "T": ["111", "010", "010", "010", "010"], 
	"U": ["101", "101", "101", "101", "111"], "V": ["101", "101", "101", "101", "010"], 
	"W": ["101", "101", "111", "111", "101"], "X": ["101", "101", "010", "101", "101"], 
	"Y": ["101", "101", "010", "010", "010"], "Z": ["111", "001", "010", "100", "111"], 
	"0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"], 
	"2": ["110", "001", "010", "100", "111"], "3": ["110", "001", "010", "001", "110"], 
	"4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "110", "001", "110"], 
	"6": ["011", "100", "111", "101", "111"], "7": ["111", "001", "010", "010", "010"], 
	"8": ["111", "101", "111", "101", "111"], "9": ["111", "101", "111", "001", "110"], 
	"_": ["000", "000", "000", "000", "111"], " ": ["000", "000", "000", "000", "000"], 
}



func _blit_text(img: Image, text: String, cx: int, cy: int, scale: int, col: Color) -> void :
	var w: = text.length() * 4 * scale - scale
	var x0: = cx - w / 2
	var y0: = cy - 5 * scale / 2
	for i in text.length():
		var g: Array = _FONT.get(text[i], _FONT[" "])
		for r in 5:
			for c in 3:
				if g[r][c] != "1":
					continue
				for dy in scale:
					for dx in scale:
						var px: = x0 + (i * 4 + c) * scale + dx
						var py: = y0 + r * scale + dy
						if px >= 0 and py >= 0 and px < img.get_width() and py < img.get_height():
							img.set_pixel(px, py, col)




func _label_png(dir: String, name: String, w: int, h: int, col: Color, text: String, 
		round_shape: bool, ring_only: bool) -> void :
	var img: = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var cx: = w * 0.5
	var cy: = h * 0.5
	var rad: = minf(w, h) * 0.5
	for y in h:
		for x in w:
			var inside: = true
			var border: = false
			if round_shape:
				var d: = Vector2(x + 0.5 - cx, y + 0.5 - cy).length()
				inside = d <= rad - 1.0
				border = d > rad - 5.0 and d <= rad - 1.0
			else:
				border = x < 4 or y < 4 or x >= w - 4 or y >= h - 4
			if not inside:
				continue
			if ring_only and not border:
				continue
			img.set_pixel(x, y, Color(col.r, col.g, col.b, 1.0 if border else 0.45))
	if not ring_only:
		var words: PackedStringArray = text.split("_") if text.length() > 8 and w < 300 else PackedStringArray([text.replace("_", " ")])
		var longest: = 1
		for wd in words:
			longest = maxi(longest, wd.length())
		var scale: = clampi(int((w * 0.8) / (longest * 4)), 1, 6)
		scale = mini(scale, maxi(int((h * 0.7) / (words.size() * 6)), 1))
		var total_h: = words.size() * 6 * scale
		for li in words.size():
			_blit_text(img, words[li], int(cx), int(cy) - total_h / 2 + li * 6 * scale + 3 * scale, 
				scale, Color(0.05, 0.05, 0.08, 1.0))
	img.save_png(dir.path_join(name + ".png"))



func _sheet_png(dir: String, name: String, cell: int, frames: int, label: = "") -> void :
	var img: = Image.create(cell * frames, cell, false, Image.FORMAT_RGBA8)
	for f in frames:
		var p: = (f + 0.5) / float(frames)
		var ox: = f * cell
		for y in cell:
			for x in cell:
				var v: = Vector2((x + 0.5) / cell * 2.0 - 1.0, (y + 0.5) / cell * 2.0 - 1.0)
				var r: = v.length()
				var ring: = _ring_a(r, 0.2 + 0.75 * p, 0.09)
				if ring > 0.05:
					img.set_pixel(ox + x, y, Color(1.0, 0.6, 0.2, ring * (1.0 - p * 0.7)))
		_blit_text(img, str(f + 1), ox + cell / 2, cell / 2, 3, Color(1, 1, 1, 1))
		if label != "":
			_blit_text(img, label.to_upper().replace("_", " "), ox + cell / 2, cell / 2 + 26, 1, 
				Color(1, 1, 1, 0.9))
	img.save_png(dir.path_join(name + ".png"))
