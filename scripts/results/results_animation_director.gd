class_name ResultsAnimationDirector
extends RefCounted











signal completed
signal skipped

const PROFILES: = {
	"SS": {"fall": 170.0, "overshoot": 1.48, "squash": 0.09, "flash": 0.8, "shake": 3.2, "lit": 0.25}, 
	"S": {"fall": 150.0, "overshoot": 1.4, "squash": 0.08, "flash": 0.6, "shake": 2.6, "lit": 0.3}, 
	"A": {"fall": 130.0, "overshoot": 1.28, "squash": 0.07, "flash": 0.45, "shake": 1.5, "lit": 0.35}, 
	"B": {"fall": 110.0, "overshoot": 1.18, "squash": 0.06, "flash": 0.32, "shake": 0.8, "lit": 0.4}, 
	"C": {"fall": 90.0, "overshoot": 1.1, "squash": 0.04, "flash": 0.22, "shake": 0.0, "lit": 0.45}, 
	"D": {"fall": 170.0, "overshoot": 1.04, "squash": 0.05, "flash": 0.12, "shake": 1.8, "lit": 0.6, "heavy": true}, 
}

var screen: Control
var playing: = false
var _master: Tween
var _tweens: Array = []


func _init(s: Control) -> void :
	screen = s


func _track(t: Tween) -> Tween:
	if t != null:
		_tweens.append(t)
	return t


func stop() -> void :
	if _master != null and _master.is_valid():
		_master.kill()
	for t in _tweens:
		if t != null and (t as Tween).is_valid():
			(t as Tween).kill()
	_tweens.clear()
	playing = false




func play(parts: Dictionary, r: RunResult, play_sound: Callable) -> void :
	stop()
	playing = true
	var slots: Dictionary = parts.slots
	var cards: Array = parts.cards
	var core: GradeCore = parts.core
	var score: ScoreBlock = parts.score
	for key in slots:
		(slots[key] as ResultsSlot).modulate.a = 0.0
	for c in cards:
		(c as ResultsSlot).modulate.a = 0.0
	core.hide_letter()
	_master = screen.create_tween()

	_master.tween_callback( func() -> void :

		var m0 = parts.get("mascot")
		if m0 != null and m0.instant_entrance() and (m0 as Node).is_inside_tree()\
		and screen.get("_mascot_ok"):
			m0.play_entrance(r.grade)
		_slide(slots.header, Vector2(-8, 0), 0.22)
		_slide(slots.account, Vector2(8, 0), 0.22)
		_slide(slots.core, Vector2(-8, 0), 0.24)
		_slide(slots.score, Vector2(8, 0), 0.24)
		_slide(slots.ranking, Vector2(10, 0), 0.26)
		_slide(slots.buttons, Vector2(0, 8), 0.26))

	_master.tween_interval(0.1)
	_master.tween_callback( func() -> void : _track(score.animate(0.85)))

	_master.tween_interval(0.3)
	_master.tween_callback( func() -> void :
		var i: = 0
		for c in cards:
			_slide(c as ResultsSlot, Vector2(0, 10), 0.2, 0.065 * i)
			i += 1)


	_master.tween_callback( func() -> void :
		var m = parts.get("mascot")


		if m != null and not m.shown and (m as Node).is_inside_tree()\
		and m.get_parent().visible and screen.get("_mascot_ok"):
			m.play_entrance(r.grade, 0.6))

	_master.tween_interval(0.55)
	_master.tween_callback( func() -> void :
		var prof: Dictionary = PROFILES.get(r.grade, PROFILES["B"])
		_track(core.play_drop(prof, func() -> void :
			if play_sound.is_valid():
				play_sound.call("impact"))))

	_master.tween_interval(0.35)
	_master.tween_callback( func() -> void :
		if r.new_record:
			score.show_badge(true)
			if play_sound.is_valid():
				play_sound.call("menu_play"))
	_master.tween_interval(0.12)
	_master.tween_callback( func() -> void :
		playing = false
		completed.emit())


func _slide(slot: ResultsSlot, from: Vector2, dur: float, delay: = 0.0) -> void :
	if slot == null:
		return
	slot.offset = from
	var t: = _track(slot.create_tween())
	t.tween_interval(delay)
	t.tween_property(slot, "modulate:a", 1.0, dur)
	t.parallel().tween_property(slot, "offset", Vector2.ZERO, dur)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)



func skip(parts: Dictionary, r: RunResult) -> void :
	var was: = playing
	stop()
	var slots: Dictionary = parts.slots
	for key in slots:
		var s: ResultsSlot = slots[key]
		s.modulate.a = 1.0
		s.offset = Vector2.ZERO
	for c in parts.cards:
		(c as ResultsSlot).modulate.a = 1.0
		(c as ResultsSlot).offset = Vector2.ZERO
	(parts.core as GradeCore).apply_final()
	(parts.score as ScoreBlock).apply_final()
	(parts.score as ScoreBlock).show_badge(false)
	var m = parts.get("mascot")
	if m != null:
		m.apply_final(r.grade)
		m.visible = bool(screen.get("_mascot_ok"))
	if was:
		skipped.emit()
