extends Control













const EdTheme = preload("res://scripts/editor_ui/ed_theme.gd")

signal chosen(id)

var _font: Font
var _rows: Array = []
var _hover: = -1
var _min_w: = 130.0




static func open(host: Control, items: Array, at: Vector2, font: Font, 
		cb: Callable, min_w: = 130.0) -> Control:
	close_all(host)


	var m = load("res://scripts/editor_ui/ed_menu.gd").new()
	m._font = font
	m._min_w = min_w
	m.set_items(items)
	m.add_to_group("ed_menu")
	host.add_child(m)
	m.place(at)
	if cb.is_valid():
		m.chosen.connect( func(id): cb.call(id))
	return m


static func close_all(host: Node) -> void :
	for n in host.get_tree().get_nodes_in_group("ed_menu"):
		n.queue_free()


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP

	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 100


func set_items(items: Array) -> void :
	_rows.clear()
	var w: = _min_w
	for it in items:
		if _font != null and it.has("text"):
			var tw: float = _font.get_string_size(String(it.text), 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_BODY).x
			var hw: = 0.0
			if it.has("hint"):
				hw = _font.get_string_size(String(it.hint), 
					HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO).x + 14.0
			w = maxf(w, tw + hw + 34.0)
	var y: = 5.0
	for it in items:
		var h: = 6.0 if it.get("sep", false) else (16.0 if it.has("title") else 21.0)
		_rows.append({"item": it, "y": y, "h": h})
		y += h
	set_meta("menu_size", Vector2(w, y + 5.0))


func place(at: Vector2) -> void :
	var vs: = get_viewport_rect().size
	var ms: Vector2 = get_meta("menu_size", Vector2(140, 100))
	var p: = at
	p.x = clampf(p.x, 4.0, vs.x - ms.x - 4.0)
	p.y = clampf(p.y, 4.0, vs.y - ms.y - 4.0)
	set_meta("menu_pos", p)
	queue_redraw()


func _menu_rect() -> Rect2:
	return Rect2(get_meta("menu_pos", Vector2.ZERO), get_meta("menu_size", Vector2(140, 100)))


func _gui_input(event: InputEvent) -> void :
	var r: = _menu_rect()
	if event is InputEventMouseMotion:
		var h: = _row_at(event.position, r)
		if h != _hover:
			_hover = h
			queue_redraw()
		accept_event()
	elif event is InputEventMouseButton and event.pressed:
		if not r.has_point(event.position):
			queue_free()
			accept_event()
			return
		var i: = _row_at(event.position, r)
		if i >= 0:
			var it: Dictionary = _rows[i].item
			chosen.emit(it.get("id", ""))
			queue_free()
		accept_event()


func _row_at(pos: Vector2, r: Rect2) -> int:
	if not r.has_point(pos):
		return -1
	for i in _rows.size():
		var row: Dictionary = _rows[i]
		var it: Dictionary = row.item
		if it.get("sep", false) or it.has("title") or it.get("disabled", false):
			continue
		if pos.y >= r.position.y + row.y and pos.y < r.position.y + row.y + row.h:
			return i
	return -1


func _unhandled_key_input(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed and event.physical_keycode == KEY_ESCAPE:
		queue_free()
		get_viewport().set_input_as_handled()


func _draw() -> void :
	var r: = _menu_rect()

	draw_rect(Rect2(r.position + Vector2(0, 3), r.size), Color(0, 0, 0, 0.45), true)
	draw_rect(r, Color(0.02, 0.026, 0.052, 0.99))
	draw_rect(r, EdTheme.LINE_HI, false, 1.0)
	if _font == null:
		return
	for i in _rows.size():
		var row: Dictionary = _rows[i]
		var it: Dictionary = row.item
		var y: float = r.position.y + row.y
		if it.get("sep", false):
			draw_line(Vector2(r.position.x + 6, y + 3), 
				Vector2(r.end.x - 6, y + 3), EdTheme.LINE, 1.0)
			continue
		if it.has("title"):
			draw_string(_font, Vector2(r.position.x + 10, y + 12), String(it.title), 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.38))
			continue
		var acc: Color = it.get("accent", EdTheme.TXT)
		var disabled: bool = it.get("disabled", false)
		if i == _hover:
			draw_rect(Rect2(r.position.x + 3, y, r.size.x - 6, row.h), 
				Color(acc.r, acc.g, acc.b, 0.13))
		var col: Color = Color(1, 1, 1, 0.2) if disabled\
		else (acc if i == _hover else EdTheme.TXT)
		var tx: = r.position.x + 12.0
		if it.get("check", false):
			draw_line(Vector2(tx, y + 11), Vector2(tx + 3, y + 14), EdTheme.CYAN, 1.6)
			draw_line(Vector2(tx + 3, y + 14), Vector2(tx + 8, y + 6), EdTheme.CYAN, 1.6)
		draw_string(_font, Vector2(tx + 12, y + 15), String(it.get("text", "")), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_BODY, col)
		if it.has("hint"):
			var hint: = String(it.hint)
			var hw: float = _font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, 
				-1, EdTheme.S_MICRO).x
			draw_string(_font, Vector2(r.end.x - 10 - hw, y + 15), hint, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, EdTheme.S_MICRO, Color(1, 1, 1, 0.28))
