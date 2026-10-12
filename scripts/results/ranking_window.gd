class_name RankingWindow
extends RefCounted













static func compact(rows: Array, my_rank: int, my_entry: Dictionary, n: = 5) -> Dictionary:
	var out: = {"rows": [], "pinned": {}}
	if rows.is_empty():
		return out
	if my_rank > 0 and my_rank <= rows.size():
		var idx: = my_rank - 1
		var start: = clampi(idx - int(n / 2), 0, maxi(rows.size() - n, 0))
		out.rows = rows.slice(start, mini(start + n, rows.size()))
	elif my_rank > rows.size() and not my_entry.is_empty():
		out.rows = rows.slice(0, mini(n - 1, rows.size()))
		out.pinned = my_entry
	else:
		out.rows = rows.slice(0, mini(n, rows.size()))
	return out


static func full(rows: Array, my_rank: int, my_entry: Dictionary, signed_in: bool, 
		limit: = 50) -> Dictionary:
	var shown: Array = rows.slice(0, mini(limit, rows.size()))
	var pinned: = {}
	if my_rank > shown.size() and not my_entry.is_empty():
		pinned = my_entry
	return {"rows": shown, "pinned": pinned, 
		"unranked": signed_in and my_rank <= 0}
