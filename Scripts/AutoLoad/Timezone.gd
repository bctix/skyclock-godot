extends Node

# Handles everything timezone

func is_daylight_savings() -> bool:
	var datetime = Time.get_datetime_dict_from_system()
	return datetime["dst"]

func get_sky_datetime_dict_from_unix_time(unix_time) -> Dictionary:
	var isDST = is_daylight_savings()
	var la_unix = unix_time - 8 * 3600
	if isDST:
		la_unix += 3600
	var t = Time.get_datetime_dict_from_unix_time(int(la_unix))
	return t
	
func get_sky_datetime_string_from_unix_time() -> String:
	var isDST = is_daylight_savings()
	var utc_unix = Time.get_unix_time_from_system()
	var la_unix = utc_unix - 8 * 3600
	if isDST:
		la_unix += 3600
	var t = Time.get_datetime_string_from_unix_time(int(la_unix))
	return t

func get_sky_date_string_from_system() -> String:
	var isDST = is_daylight_savings()
	var utc_unix = Time.get_unix_time_from_system()
	var la_unix = utc_unix - 8 * 3600
	if isDST:
		la_unix += 3600
	var t = Time.get_date_string_from_unix_time(int(la_unix))
	return t
	
func get_sky_unix_time_from_system() -> float:
	var isDST = is_daylight_savings()
	var utc_unix = Time.get_unix_time_from_system()
	var la_unix = utc_unix - 8 * 3600
	if isDST:
		la_unix += 3600
	return la_unix
	
func get_sky_datetime_dict_from_datetime_string(iso_date) -> Dictionary:
	var isDST = is_daylight_savings()
	var utc_unix = Time.get_unix_time_from_datetime_string(iso_date)
	var la_unix = utc_unix - 8 * 3600
	if isDST:
		la_unix += 3600
	return Time.get_datetime_dict_from_unix_time(la_unix)
