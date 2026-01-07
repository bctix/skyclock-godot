extends Node

# Handles everything timezone

func get_sky_datetime_dict_from_unix_time() -> Dictionary:
	var utc_unix = Time.get_unix_time_from_system()
	var la_unix = utc_unix - 8 * 3600
	var t = Time.get_datetime_dict_from_unix_time(int(la_unix))
	return t
	
func get_sky_datetime_string_from_unix_time() -> String:
	var utc_unix = Time.get_unix_time_from_system()
	var la_unix = utc_unix - 8 * 3600
	var t = Time.get_datetime_string_from_unix_time(int(la_unix))
	return t
