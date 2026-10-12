class_name VirtualList
extends ScrollContainer




























const SCROLL_SPEED: = 18.0

const WHEEL_STEP: = 118.0

const DRAG_THRESHOLD: = 11.0

const FLICK_WEIGHT: = 0.14

var item_height: = 76.0
var make_item: Callable
var bind_item: Callable

var _count: = 0
var _body: Control
var _rows: Array = []
var _row_index: Array = []
var _target_scroll: = 0.0
var _smoothing: = false


var _press_active: = false
var _dragging: = false
var _press_y: = 0.0
var _press_scroll: = 0.0
var _drag_velocity: = 0.0
var _last_drag_y: = 0.0
var _last_drag_time: = 0.0
var _click_shield_until: = 0.0




func click_suppressed() -> bool:
	return _dragging or Time.get_ticks_msec() / 1000.0 < _click_shield_until


func _ready() -> void :
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	clip_contents = true
	_body = Control.new()
	_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_body)
	get_v_scroll_bar().value_changed.connect( func(_v: float) -> void : _place())
	resized.connect(_rebuild_pool)
	_rebuild_pool()


func set_count(n: int) -> void :
	_count = maxi(n, 0)
	_body.custom_minimum_size = Vector2(0, _count * item_height)
	_rebuild_pool()
	_place()


func count() -> int:
	return _count




func refresh() -> void :
	for i in _rows.size():
		_row_index[i] = -1
	_place()





func row_for(i: int) -> Control:
	var j: = _row_index.find(i)
	return _rows[j] if j >= 0 else null




func ensure_visible(i: int) -> void :
	if _count <= 0:
		return
	var top: = i * item_height
	var bottom: = top + item_height
	var view: = size.y
	var cur: = _target_scroll
	if top < cur:
		_scroll_to(top - item_height * 0.5)
	elif bottom > cur + view:
		_scroll_to(bottom - view + item_height * 0.5)


func _scroll_to(v: float) -> void :
	var maxv: = maxf(_count * item_height - size.y, 0.0)
	_target_scroll = clampf(v, 0.0, maxv)
	_smoothing = true
	set_process(true)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed:
		var b: = event as InputEventMouseButton
		if b.button_index == MOUSE_BUTTON_WHEEL_UP:
			_scroll_to(_target_scroll - WHEEL_STEP)
			accept_event()
		elif b.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_scroll_to(_target_scroll + WHEEL_STEP)
			accept_event()




func _input(event: InputEvent) -> void :
	if not is_visible_in_tree():
		return
	if event is InputEventMouseButton:
		var b: = event as InputEventMouseButton
		if b.button_index != MOUSE_BUTTON_LEFT:
			return
		if b.pressed:




			var hovered: = get_viewport().gui_get_hovered_control()
			var ours: bool = hovered != null\
			and (hovered == self or is_ancestor_of(hovered))
			if ours and get_global_rect().has_point(b.global_position):
				_press_active = true
				_press_y = b.global_position.y
				_press_scroll = float(scroll_vertical)
				_last_drag_y = _press_y
				_last_drag_time = Time.get_ticks_msec() / 1000.0
				_drag_velocity = 0.0
		else:
			if _dragging:

				_scroll_to(_target_scroll - _drag_velocity * FLICK_WEIGHT)
				_set_rows_input(true)



				_click_shield_until = Time.get_ticks_msec() / 1000.0 + 0.15
			_press_active = false
			_dragging = false
	elif event is InputEventMouseMotion and _press_active:
		var y: float = (event as InputEventMouseMotion).global_position.y
		if not _dragging and absf(y - _press_y) >= DRAG_THRESHOLD:
			_dragging = true


			_set_rows_input(false)
		if _dragging:
			var maxv: = maxf(_count * item_height - size.y, 0.0)
			_target_scroll = clampf(_press_scroll - (y - _press_y), 0.0, maxv)
			_smoothing = false
			scroll_vertical = int(round(_target_scroll))
			_place()

			var now: = Time.get_ticks_msec() / 1000.0
			var dt: = maxf(now - _last_drag_time, 0.001)
			_drag_velocity = lerpf(_drag_velocity, (y - _last_drag_y) / dt, 0.35)
			_last_drag_y = y
			_last_drag_time = now


func _set_rows_input(on: bool) -> void :
	for row in _rows:
		(row as Control).mouse_filter = Control.MOUSE_FILTER_STOP if on\
		else Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void :
	if not _smoothing:
		set_process(false)
		return
	var cur: = float(scroll_vertical)
	var next: = lerpf(cur, _target_scroll, 1.0 - exp( - SCROLL_SPEED * delta))
	if absf(next - _target_scroll) < 0.5:
		next = _target_scroll
		_smoothing = false
	scroll_vertical = int(round(next))
	_place()




func _rebuild_pool() -> void :
	if not make_item.is_valid() or item_height <= 0.0:
		return
	var want: = mini(_count, int(ceil(size.y / item_height)) + 2)
	while _rows.size() < want:
		var row: Control = make_item.call()
		row.visible = false
		_body.add_child(row)
		_rows.append(row)
		_row_index.append(-1)
	while _rows.size() > want:
		var row: Control = _rows.pop_back()
		_row_index.pop_back()
		row.queue_free()
	_place()




func _place() -> void :
	if _rows.is_empty():
		return
	var first: = maxi(int(floor(float(scroll_vertical) / item_height)) - 1, 0)
	for j in _rows.size():
		var row: Control = _rows[j]
		var idx: = first + j
		if idx >= _count:
			row.visible = false
			_row_index[j] = -1
			continue
		row.visible = true
		row.position = Vector2(0, idx * item_height)
		row.size = Vector2(size.x, item_height)
		if _row_index[j] != idx:
			_row_index[j] = idx
			if bind_item.is_valid():
				bind_item.call(row, idx)
