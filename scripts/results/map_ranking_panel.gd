class_name MapRankingPanel
extends PanelContainer






signal leaderboard_requested

const ROWS: = 5
const POOL: = ROWS + 2

var _your_rank: Label
var _delta: Label
var _rows_box: VBoxContainer
var _rows: Array = []
var _note: Label
var _full: Button
var _compact: = false


func _init() -> void :
	theme_type_variation = &"RPanel"
	custom_minimum_size = Vector2(380, 0)
	var v: = VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(v)
	var head: = Label.new()
	head.theme_type_variation = &"RRankHeader"
	head.text = "MAP RANKING"
	v.add_child(head)
	var yr: = HBoxContainer.new()
	yr.add_theme_constant_override("separation", 12)
	yr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(yr)
	var yl: = Label.new()
	yl.theme_type_variation = &"RYourRank"
	yl.text = "YOUR RANK"
	yl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	yr.add_child(yl)
	_your_rank = Label.new()
	_your_rank.theme_type_variation = &"RYourRankValue"
	_your_rank.text = "#--"
	yr.add_child(_your_rank)
	_delta = Label.new()
	_delta.theme_type_variation = &"RNote"
	_delta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_delta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_delta.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	yr.add_child(_delta)
	_rows_box = VBoxContainer.new()
	_rows_box.add_theme_constant_override("separation", 6)
	_rows_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_rows_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_rows_box)
	for i in POOL:
		var r: = ResultsLeaderboardRow.new()
		r.visible = false
		_rows_box.add_child(r)
		_rows.append(r)
	_note = Label.new()
	_note.theme_type_variation = &"RNote"
	_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.visible = false
	v.add_child(_note)
	var spacer: = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(spacer)
	_full = Button.new()
	_full.theme_type_variation = &"RButton"
	_full.text = "VIEW FULL LEADERBOARD"
	_full.focus_mode = Control.FOCUS_NONE
	_full.custom_minimum_size = Vector2(0, 40)
	_full.pressed.connect( func() -> void : leaderboard_requested.emit())
	v.add_child(_full)
	set_selected(false)


func set_compact(on: bool) -> void :
	_compact = on
	custom_minimum_size = Vector2(340 if on else 380, 0)



func set_selected(on: bool) -> void :
	var st: = ResultsTheme.box(ResultsTheme.PANEL_2, 
		ResultsTheme.CYAN if on else ResultsTheme.LINE, 20, 2 if on else 1, 
		Vector2(16, 8))
	_full.add_theme_stylebox_override("normal", st)
	_full.add_theme_stylebox_override("hover", 
		ResultsTheme.box(ResultsTheme.PANEL_2, ResultsTheme.CYAN, 20, 2 if on else 1, 
			Vector2(16, 8)))
	_full.add_theme_stylebox_override("pressed", st)
	_full.add_theme_stylebox_override("focus", st)


func full_button() -> Button:
	return _full


func fill(r: RunResult) -> void :
	for row in _rows:
		(row as ResultsLeaderboardRow).visible = false
	_note.visible = false
	_delta.text = r.rank_delta_text
	_delta.add_theme_color_override("font_color", r.rank_delta_color)
	if r.player_rank > 0:
		_your_rank.text = "#%d" % r.player_rank
		_your_rank.add_theme_color_override("font_color", ResultsTheme.CYAN)
	elif r.signed_in and r.ranking_status == RunResult.RankingStatus.READY:
		_your_rank.text = "UNRANKED"
		_your_rank.add_theme_color_override("font_color", ResultsTheme.TEXT_FAINT)
	else:
		_your_rank.text = "#--"
		_your_rank.add_theme_color_override("font_color", ResultsTheme.TEXT_FAINT)
	match r.ranking_status:
		RunResult.RankingStatus.LOADING, RunResult.RankingStatus.SUBMITTING:
			if r.entries.is_empty():
				for i in 3:
					var row: ResultsLeaderboardRow = _rows[i]
					row.set_skeleton()
					row.visible = true
			else:
				_show_entries(r)
			_show_note("submitting score…" if r.ranking_status == RunResult.RankingStatus.SUBMITTING
				else "loading ranking…")
		RunResult.RankingStatus.READY:
			_show_entries(r)
			if r.entries.is_empty():
				_show_note("no online scores yet — be the first!")
			elif not r.signed_in:
				_show_note("sign in to rank your score")
			elif not r.ranked:
				_show_note("this run is not ranked (assisted / unranked mods)")
		RunResult.RankingStatus.EMPTY:
			_show_note("no online scores yet — be the first!")
		RunResult.RankingStatus.OFFLINE:
			_show_note("offline — ranking unavailable", true)
		RunResult.RankingStatus.ERROR:
			_show_note(r.ranking_message if r.ranking_message != "" else "ranking unavailable", true)
		RunResult.RankingStatus.LOCAL_MAP:
			_show_note("local map — no online ranking")
		RunResult.RankingStatus.SIGNED_OUT:
			_show_entries(r)
			_show_note("sign in to rank your score")
		RunResult.RankingStatus.REJECTED:
			_show_entries(r)
			_show_note("score not ranked: " + r.ranking_message, true)


func _show_entries(r: RunResult) -> void :
	var w: = RankingWindow.compact(r.entries, r.player_rank, r.player_entry, ROWS)
	var rows: Array = w.rows
	var i: = 0
	for e in rows:
		var row: ResultsLeaderboardRow = _rows[i]
		row.bind(e, r.signed_in and str(e.get("username", "")) == r.player_name, _compact)
		row.visible = true
		i += 1
	var pinned: Dictionary = w.pinned
	if not pinned.is_empty() and i + 1 < POOL:
		var sep: ResultsLeaderboardRow = _rows[i]
		sep.set_separator()
		sep.visible = true
		var me: ResultsLeaderboardRow = _rows[i + 1]
		me.bind(pinned, true, _compact)
		me.visible = true


func _show_note(text: String, error: = false) -> void :
	_note.text = text
	_note.theme_type_variation = &"RNoteError" if error else &"RNote"
	_note.visible = true



func animate_in() -> void :
	var i: = 0
	for row in _rows:
		var rr: = row as ResultsLeaderboardRow
		if not rr.visible:
			continue
		var a: = rr.modulate.a
		rr.modulate.a = 0.0
		var t: = rr.create_tween()
		t.tween_interval(0.04 * i)
		t.tween_property(rr, "modulate:a", a, 0.18)
		i += 1
