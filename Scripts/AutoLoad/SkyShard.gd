extends Node

const LAND_OFFSET = 520
const END_OFFSET = 14400

const BLACK_SHARD_INTERVAL = 28800
const RED_SHARD_INTERVAL = 21600

const REALMS = ["prairie", "forest", "valley", "wasteland", "vault"]

# Shard configurations
const SHARDS_INFO = [
	{
		"no_shard_wk_day": [6, 7],
		"interval": BLACK_SHARD_INTERVAL,
		"offset": 6600,
		"maps": ["prairie.butterfly", "forest.brook", "valley.rink", "wasteland.temple", "vault.starlight"]
	},
	{
		"no_shard_wk_day": [7, 1],
		"interval": BLACK_SHARD_INTERVAL,
		"offset": 7800,
		"maps": ["prairie.village", "forest.boneyard", "valley.rink", "wasteland.battlefield", "vault.starlight"]
	},
	{
		"no_shard_wk_day": [1, 2],
		"interval": RED_SHARD_INTERVAL,
		"offset": 27600,
		"maps": ["prairie.cave", "forest.end", "valley.dreams", "wasteland.graveyard", "vault.jelly"],
		"def_reward_ac": 2.0
	},
	{
		"no_shard_wk_day": [2, 3],
		"interval": RED_SHARD_INTERVAL,
		"offset": 8400,
		"maps": ["prairie.bird", "forest.tree", "valley.dreams", "wasteland.crab", "vault.jelly"],
		"def_reward_ac": 2.5
	},
	{
		"no_shard_wk_day": [3, 4],
		"interval": RED_SHARD_INTERVAL,
		"offset": 12600,
		"maps": ["prairie.island", "forest.sunny", "valley.hermit", "wasteland.ark", "vault.jelly"],
		"def_reward_ac": 3.5
	}
]

const OVERRIDE_REWARD_AC = {
	"forest.end": 2.5,
	"valley.dreams": 2.5,
	"forest.tree": 3.5,
	"vault.jelly": 3.5
}

const NUM_MAP_VARIANTS = {
	"prairie.butterfly": 3, "prairie.village": 3, "prairie.bird": 2, "prairie.island": 3,
	"forest.brook": 2, "forest.end": 2, "valley.rink": 3, "valley.dreams": 2,
	"wasteland.temple": 3, "wasteland.battlefield": 3, "wasteland.graveyard": 2,
	"wasteland.crab": 2, "wasteland.ark": 4, "vault.starlight": 3, "vault.jelly": 2
}

static func get_la_start_of_day(unix_time: float) -> float:
	var la_time = unix_time - 8 * 3600
	var dt = Time.get_datetime_dict_from_unix_time(int(la_time))
	dt.hour = 0
	dt.minute = 0
	dt.second = 0
	var start_unix = Time.get_unix_time_from_datetime_dict(dt)
	return start_unix + 8 * 3600  # Convert back to UTC

static func is_in_dst(unix_time: float) -> bool:
	var la_time = unix_time - 8 * 3600
	var dt = Time.get_datetime_dict_from_unix_time(int(la_time))
	var year = dt.year

	var march_second_sunday = _get_nth_weekday_of_month(year, 3, 7, 2)
	var nov_first_sunday = _get_nth_weekday_of_month(year, 11, 7, 1)

	var day_of_year = Time.get_datetime_dict_from_unix_time(int(la_time)).day + \
		_days_before_month(dt.month, year)

	return day_of_year >= march_second_sunday and day_of_year < nov_first_sunday

static func _days_before_month(month: int, year: int) -> int:
	var days = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
	var result = days[month - 1]
	if month > 2 and _is_leap_year(year):
		result += 1
	return result

static func _is_leap_year(year: int) -> bool:
	return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0)

static func _get_nth_weekday_of_month(year: int, month: int, weekday: int, n: int) -> int:
	var first_day = Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": 1, "hour": 0, "minute": 0, "second": 0})
	var first_weekday = Time.get_datetime_dict_from_unix_time(int(first_day)).weekday
	if first_weekday == 0:
		first_weekday = 7

	var days_until = (weekday - first_weekday + 7) % 7
	var target_day = 1 + days_until + (n - 1) * 7
	return _days_before_month(month, year) + target_day

static func get_shard_info(unix_time: float, override: Dictionary = {}) -> Dictionary:
	var today_start = get_la_start_of_day(unix_time)
	var dt = Time.get_datetime_dict_from_unix_time(int(today_start - 8 * 3600))
	var day_of_month = dt.day
	var day_of_week = dt.weekday
	if day_of_week == 0:
		day_of_week = 7

	var is_red = override.get("is_red", day_of_month % 2 == 1)
	var realm_idx = override.get("realm", (day_of_month - 1) % 5)

	var info_index
	if override.has("group"):
		info_index = override.group
	elif day_of_month % 2 == 1:
		info_index = (((day_of_month - 1) / 2) % 3) + 2
	else:
		info_index = (day_of_month / 2) % 2

	var shard_config = SHARDS_INFO[info_index]
	var has_shard = override.get("has_shard", not shard_config.no_shard_wk_day.has(day_of_week))
	var map_name = override.get("map", shard_config.maps[realm_idx])
	var reward_ac = OVERRIDE_REWARD_AC.get(map_name, shard_config.get("def_reward_ac")) if is_red else null
	var num_variant = NUM_MAP_VARIANTS.get(map_name, 1)

	var first_start = today_start + shard_config.offset

	if day_of_week == 7 and is_in_dst(today_start) != is_in_dst(first_start):
		first_start += 3600 if is_in_dst(first_start) else -3600

	var occurrences = []
	for i in range(3):
		var start = first_start + shard_config.interval * i
		var land = start + LAND_OFFSET
		var end = start + END_OFFSET
		occurrences.append({"start": start, "land": land, "end": end})

	return {
		"date": unix_time,
		"is_red": is_red,
		"has_shard": has_shard,
		"offset": shard_config.offset,
		"interval": shard_config.interval,
		"last_end": occurrences[2].end,
		"realm": REALMS[realm_idx],
		"map": map_name,
		"num_variant": num_variant,
		"reward_ac": reward_ac,
		"occurrences": occurrences,
		"was_override": not override.is_empty()
	}


static func find_next_shard(from_unix: float, only: String = "") -> Dictionary:
	var info = get_shard_info(from_unix)

	if info.has_shard and from_unix < info.last_end:
		if only == "" or (only == "red" and info.is_red) or (only == "black" and not info.is_red):
			return info

	return find_next_shard(from_unix + 86400, only)
