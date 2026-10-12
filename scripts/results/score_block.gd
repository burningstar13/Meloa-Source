class_name ScoreBlock
extends VBoxContainer






var _acc: GlowLabel
var _cleared: Label
var _score: Label
var _best: Label
var _best_v: Label
var _badge: Label
var _bar: Control
var _ratio: = 0.0
var _best_ratio: = -1.0
var _result: RunResult
var _tw: Tween


func _init() -> void :
	add_theme_constant_override("separation", 2)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var spec: Array = ResultsTheme.role("RAccuracy")
	_acc = GlowLabel.new()
	_acc.font = ResultsTheme.font(int(spec[0]))
	_acc.font_size = int(spec[1])
	_acc.color = spec[2]
	_acc.glow_strength = 0.0
	_acc.text = "0.00%"
	add_child(_acc)
	_cleared = Label.new()
	_cleared.theme_type_variation = &"RCleared"
	_cleared.text = "CLEARED  ✦"
	add_child(_cleared)
	add_child(_gap(14))
	var cap: = Label.new()
	cap.theme_type_variation = &"RCaption"
	cap.text = "SCORE"
	add_child(cap)
	_score = Label.new()
	_score.theme_type_variation = &"RScore"
	_score.text = "0"
	add_child(_score)
	add_child(_gap(4))
	var best_row: = HBoxContainer.new()
	best_row.add_theme_constant_override("separation", 10)
	best_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(best_row)
	_best = Label.new()
	_best.theme_type_variation = &"RBest"
	_best.text = "BEST SCORE"
	best_row.add_child(_best)
	_best_v = Label.new()
	_best_v.theme_type_variation = &"RBestValue"
	best_row.add_child(_best_v)
	_badge = Label.new()
	_badge.theme_type_variation = &"RBadge"
	_badge.text = "NEW BEST"
	_badge.add_theme_stylebox_override("normal", 
		ResultsTheme.box(ResultsTheme.YELLOW, ResultsTheme.YELLOW, 6, 0, Vector2(8, 1)))
	_badge.visible = false
	best_row.add_child(_badge)
	_bar = Control.new()
	_bar.custom_minimum_size = Vector2(240, 14)
	_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.draw.connect(_draw_bar)
	add_child(_bar)


func _gap(h: int) -> Control:
	var c: = Control.new()
	c.custom_minimum_size = Vector2(0, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c



func fill(r: RunResult) -> void :
	_result = r
	_acc.color = ResultsTheme.CYAN if r.cleared else ResultsTheme.CORAL
	_cleared.text = ("%s  ✦" % r.status_text) if r.cleared else r.status_text
	_cleared.add_theme_color_override("font_color", ResultsTheme.CYAN if r.cleared else ResultsTheme.CORAL)
	if r.has_previous_best():
		_best.text = "BEST SCORE"
		_best_v.text = ResultsTheme.thousands(r.previous_best)
	elif r.local_map or not r.ranked:
		_best.text = "FIRST SCORE ON THIS DIFFICULTY" if r.new_record else "BEST SCORE"
		_best_v.text = "" if r.new_record else "--"
	else:
		_best.text = "FIRST SCORE ON THIS DIFFICULTY" if r.new_record else "BEST SCORE"
		_best_v.text = "" if r.new_record else "--"
	if r.new_record and r.has_previous_best():
		_best_v.text = "%s   (+%s)" % [ResultsTheme.thousands(r.previous_best), 
			ResultsTheme.thousands(r.score - r.previous_best)]
	elif r.has_previous_best() and r.score == r.previous_best:
		_best_v.text = "%s   (tied)" % ResultsTheme.thousands(r.previous_best)
	_badge.visible = false
	_badge.scale = Vector2.ONE
	_best_ratio = r.best_ratio()
	_ratio = 0.0
	_acc.text = "0.00%"
	_score.text = "0"
	_bar.queue_redraw()




func animate(dur: = 0.85) -> Tween:
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween()
	_tw.set_parallel(true)
	_tw.tween_method(_set_acc, 0.0, _result.accuracy, dur)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tw.tween_method(_set_score, 0.0, float(_result.score), dur)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tw.tween_method(_set_ratio, 0.0, _result.score_ratio(), dur * 0.85)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tw.set_parallel(false)
	_tw.tween_callback(apply_final)
	return _tw



func show_badge(animate_pulse: = true) -> void :
	if _result == null or not _result.new_record:
		return
	_badge.visible = true
	if not animate_pulse:
		_badge.scale = Vector2.ONE
		return
	_badge.pivot_offset = _badge.size * 0.5
	_badge.scale = Vector2(0.6, 0.6)
	var t: = _badge.create_tween()
	t.tween_property(_badge, "scale", Vector2(1.12, 1.12), 0.14)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	t.tween_property(_badge, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)


func apply_final() -> void :
	if _tw != null and _tw.is_valid():
		_tw.kill()
	if _result == null:
		return
	_acc.text = "%.2f%%" % _result.accuracy
	_score.text = ResultsTheme.thousands(_result.score)
	_ratio = _result.score_ratio()
	_bar.queue_redraw()


func _set_acc(v: float) -> void :
	_acc.text = "%.2f%%" % v


func _set_score(v: float) -> void :
	_score.text = ResultsTheme.thousands(int(round(v)))


func _set_ratio(v: float) -> void :
	_ratio = v
	_bar.queue_redraw()


func _draw_bar() -> void :
	var w: = _bar.size.x
	var y: = _bar.size.y * 0.5
	_bar.draw_line(Vector2(0, y), Vector2(w, y), Color(ResultsTheme.TEXT_DIM, 0.18), 4.0, true)
	if _ratio > 0.001:

		var n: = 24
		var pts: = PackedVector2Array()
		var cols: = PackedColorArray()
		for i in n + 1:
			var u: = float(i) / n
			pts.append(Vector2(w * _ratio * u, y))
			cols.append(ResultsTheme.CYAN.lerp(ResultsTheme.VIOLET, u))
		_bar.draw_polyline_colors(pts, cols, 4.0, true)
	if _best_ratio >= 0.0:
		var x: = w * _best_ratio
		_bar.draw_line(Vector2(x, y - 6.0), Vector2(x, y + 6.0), Color(1, 1, 1, 0.9), 2.0, true)
