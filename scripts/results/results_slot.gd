class_name ResultsSlot
extends Container






var offset: = Vector2.ZERO:
	set(v):
		offset = v
		queue_sort()


func _init() -> void :
	mouse_filter = Control.MOUSE_FILTER_PASS


func _get_minimum_size() -> Vector2:
	var m: = Vector2.ZERO
	for c in get_children():
		if c is Control and (c as Control).visible:
			m = m.max((c as Control).get_combined_minimum_size())
	return m


func _notification(what: int) -> void :
	if what == NOTIFICATION_SORT_CHILDREN:
		for c in get_children():
			if c is Control:
				fit_child_in_rect(c, Rect2(offset, size))
