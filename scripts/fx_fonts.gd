extends RefCounted










const DEFAULT: = "fredoka"


const FONTS: = {
	"fredoka": {"file": "res://fonts/Fredoka-Variable.ttf", "label": "Fredoka (round)", 
		"axes": {"wght": 560, "wdth": 104}}, 
	"chakra": {"file": "res://fonts/ChakraPetch-Bold.ttf", "label": "Chakra Petch (tech)", 
		"axes": {}}, 
	"audiowide": {"file": "res://fonts/Audiowide-Regular.ttf", "label": "Audiowide (wide)", 
		"axes": {}}, 
	"rajdhani": {"file": "res://fonts/Rajdhani-Bold.ttf", "label": "Rajdhani (sharp)", 
		"axes": {}}, 
	"exo": {"file": "res://fonts/Exo2.ttf", "label": "Exo 2 (futur)", 
		"axes": {"wght": 700}}, 
	"inter": {"file": "res://fonts/Inter-Variable.ttf", "label": "Inter (clean)", 
		"axes": {"wght": 800}}, 
	"nunito": {"file": "res://fonts/NunitoSans-Variable.ttf", "label": "Nunito (soft)", 
		"axes": {"wght": 900}}, 
	"patrick": {"file": "res://fonts/PatrickHand-Regular.ttf", "label": "Patrick Hand (script)", 
		"axes": {}}, 
}


const ORDER: = ["fredoka", "chakra", "audiowide", "rajdhani", "exo", "inter", 
	"nunito", "patrick"]

static var _cache: = {}


static func ids() -> Array:
	return ORDER


static func labels() -> Array:
	var out: Array = []
	for id in ORDER:
		out.append(String(FONTS[id].label))
	return out




static func get_font(id: String) -> Font:
	if not FONTS.has(id):
		id = DEFAULT
	if _cache.has(id):
		return _cache[id]
	var spec: Dictionary = FONTS[id]
	var base: Font = load(String(spec.file))
	if base == null:
		return null
	var axes: Dictionary = spec.axes
	var f: Font = base
	if not axes.is_empty():
		var fv: = FontVariation.new()
		fv.base_font = base
		var ts: = TextServerManager.get_primary_interface()
		var tagged: = {}
		for k in axes:
			tagged[ts.name_to_tag(String(k))] = axes[k]
		fv.variation_opentype = tagged
		f = fv
	_cache[id] = f
	return f
