class_name MapResultHeader
extends HBoxContainer




const COVER: = 64.0

var _frame: Panel
var _cover: TextureRect
var _title: Label
var _artist: Label
var _chip: Label
var _initial: = ""


func _init() -> void :
	add_theme_constant_override("separation", 12)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame = Panel.new()
	_frame.theme_type_variation = &"RCoverPlain"
	_frame.custom_minimum_size = Vector2(COVER, COVER)
	_frame.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.draw.connect(_draw_initial)
	add_child(_frame)
	_cover = TextureRect.new()
	_cover.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cover.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_frame.add_child(_cover)
	var col: = VBoxContainer.new()
	col.add_theme_constant_override("separation", 1)
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(col)
	_title = Label.new()
	_title.theme_type_variation = &"RTitle"
	_title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title.clip_text = true
	_title.custom_minimum_size = Vector2(0, 0)
	col.add_child(_title)
	_artist = Label.new()
	_artist.theme_type_variation = &"RArtist"
	_artist.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_artist.clip_text = true
	col.add_child(_artist)
	var chip_row: = HBoxContainer.new()
	chip_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(chip_row)
	_chip = Label.new()
	_chip.theme_type_variation = &"RChip"
	_chip.theme_type_variation = &"RChip"
	chip_row.add_child(_chip)


func fill(r: RunResult) -> void :
	_cover.texture = r.cover
	_cover.visible = r.cover != null
	_initial = r.map_title.substr(0, 1).to_upper()
	_frame.queue_redraw()
	_title.text = r.map_title
	_title.tooltip_text = r.map_title
	_artist.text = r.map_artist if r.map_artist != "" else ("Your map" if r.local_map else "")
	_artist.tooltip_text = r.map_artist
	var name: = r.difficulty_name.to_upper()
	_chip.text = ("%s  %.1f" % [name, r.difficulty_level]) if r.difficulty_level >= 0.0 else name


	_chip.add_theme_color_override("font_color", r.difficulty_color.lerp(ResultsTheme.TEXT, 0.15))
	_chip.add_theme_stylebox_override("normal", 
		ResultsTheme.box(ResultsTheme.PANEL_2, Color(r.difficulty_color, 0.55), 8, 1, 
			Vector2(9, 2)))


func _draw_initial() -> void :
	if _cover.texture != null or _initial == "":
		return
	var f: = ResultsTheme.font(700)
	var s: = f.get_string_size(_initial, HORIZONTAL_ALIGNMENT_LEFT, -1, 26)
	_frame.draw_string(f, _frame.size * 0.5 + Vector2( - s.x * 0.5, 9.0), _initial, 
		HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color(ResultsTheme.VIOLET_LIGHT, 0.8))
