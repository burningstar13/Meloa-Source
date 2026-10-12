extends RefCounted










static var _on: = -1
static var _last: = 0
static var _lines: Array = []


static func enabled() -> bool:
	if _on < 0:
		_on = 1 if (OS.get_cmdline_args().has("--perf-trace")
			or OS.get_cmdline_user_args().has("perf-trace")) else 0
		_last = Time.get_ticks_usec()
	return _on == 1




static func mark(label: String) -> void :
	if not enabled():
		return
	var now: = Time.get_ticks_usec()
	var line: = "[boot %7.0f ms] +%7.1f ms  %s" % [
		Time.get_ticks_msec(), (now - _last) / 1000.0, label]
	_last = now
	_lines.append(line)
	print(line)



static func flush() -> void :
	if not enabled() or _lines.is_empty():
		return
	var f: = FileAccess.open("user://perf_boot.txt", FileAccess.WRITE)
	if f == null:
		return
	f.store_string("Meloa — trace de démarrage %s\n%s\n%s\n" % [
		Time.get_datetime_string_from_system(), 
		"%s / %s" % [RenderingServer.get_video_adapter_name(), 
			RenderingServer.get_current_rendering_driver_name()], 
		"\n".join(_lines)])
	f.close()
