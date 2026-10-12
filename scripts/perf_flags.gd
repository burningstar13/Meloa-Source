extends RefCounted
















static var lane_cache: = true



static var field_cache: = true




static var bg_batch: = true




static var field_draw: = true
static var bg_draw: = true
static var bg_dust: = true
static var bg_bars: = true
static var hit_fx: = true



static func set_flag(name: String, on: bool) -> void :
	match name:
		"lane_cache":
			lane_cache = on
		"field_cache":
			field_cache = on
		"bg_batch":
			bg_batch = on
		"field_draw":
			field_draw = on
		"bg_draw":
			bg_draw = on
		"bg_dust":
			bg_dust = on
		"bg_bars":
			bg_bars = on
		"hit_fx":
			hit_fx = on
		_:
			push_error("drapeau de perf inconnu : " + name)
