extends Control

func _process(_delta: float) -> void:
	$local_time_label.text = get_local_time_string()
	$sky_time_label.text = get_sky_time_string()
	$next_event_label.text = get_next_event_string()

func get_next_event_string() -> String:
	var key = "geyser"
	@warning_ignore("narrowing_conversion")
	var ev = SkyEvents.closest_event(Time.get_unix_time_from_system())
	return "%s  %s" % [SkyEvents.DATA[ev.key].prefix, pretty_format(ev.sec)]

func get_local_time_string() -> String:
	var t = Time.get_time_dict_from_system()
	var h = t.hour
	var suffix = "am" if h < 12 else "pm"
	h = h % 12
	if h == 0: h = 12
	var time = "%d:%02d:%02d %s" % [h, t.minute, t.second, suffix]
	return time

func get_sky_time_string() -> String:
	var utc_unix = Time.get_unix_time_from_system()
	var la_unix = utc_unix - 8 * 3600
	var t = Time.get_datetime_dict_from_unix_time(int(la_unix))
	var h = t.hour % 12
	var suffix = "am" if t.hour < 12 else "pm"
	if h == 0: h = 12
	var time = "%d:%02d:%02d %s" % [h, t.minute, t.second, suffix]
	return time

func pretty_format(sec: int) -> String:
	sec = max(0, sec)          # never negative
	@warning_ignore("integer_division")
	var h := sec / 3600
	@warning_ignore("integer_division")
	var m := (sec / 60) % 60
	var s := sec % 60
	var out := "%02d:%02d:%02d" % [h, m, s]
	if h == 0: out = out.substr(3)   # drop "00:" if no hours
	return out
