extends Control

var twenty_four_hr: bool = false

func _ready() -> void:
	twenty_four_hr = Config.get_value("clock", "24h")
	Config.value_changed.connect(conf_change)
	set_colors()
	Config.value_changed.connect(conf_changed)

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

func conf_change(_section, _key, _val) -> void:
	twenty_four_hr = Config.get_value("clock", "24h")

func _process(_delta: float) -> void:
	$local_time_label.text = get_local_time_string()
	$sky_time_label.text = get_sky_time_string()
	$next_event_label.text = get_next_event_string()
	

var did_notif: bool = false
func get_next_event_string() -> String:
	var key = "geyser"
	@warning_ignore("narrowing_conversion", "static_called_on_instance")
	var ev = SkyWax.closest_event(Time.get_unix_time_from_system())
	
	if 300 == ev.sec:
		if not did_notif:
			do_notif()
			did_notif = true
	else:
		did_notif = false

	return "%s %s" % [SkyWax.DATA[ev.key].prefix, pretty_format(ev.sec)]

func do_notif() -> void:
	if Config.get_value("clock", "notifications"):
		$notif_animation.play("RESET")
		$notif_animation.play("notif")

func get_local_time_string() -> String:
	if twenty_four_hr:
		var t = Time.get_time_dict_from_system()
		var time = "%d:%02d:%02d" % [t.hour, t.minute, t.second]
		return time
	else:
		var t = Time.get_time_dict_from_system()
		var h = t.hour
		var suffix = "am" if h < 12 else "pm"
		h = h % 12
		if h == 0: h = 12
		var time = "%d:%02d:%02d %s" % [h, t.minute, t.second, suffix]
		return time

func get_sky_time_string() -> String:
	if twenty_four_hr:
		var t = Timezone.get_sky_datetime_dict_from_unix_time(Time.get_unix_time_from_system())
		var time = "%d:%02d:%02d" % [t.hour, t.minute, t.second]
		return time
	else:
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

func set_colors() -> void:
	for node in $".".get_children():
		if node is Label:
			if node.name == "ShardInfo":
				return
			node.add_theme_color_override("font_color", Config.get_value("global", "color"))
		elif node is CanvasItem:
			node.self_modulate = Config.get_value("global", "color")
