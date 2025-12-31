extends Control

const lang = {
	"skyRealms": {
		"prairie.long": "Daylight Prairie",
		"prairie.short": "Prairie",
		"forest.long": "Hidden Forest",
		"forest.short": "Forest",
		"valley.long": "Valley of Triumph",
		"valley.short": "Valley",
		"wasteland.long": "Golden Wasteland",
		"wasteland.short": "Wasteland",
		"vault.long": "Vault of Knowledge",
		"vault.short": "Vault"
	},
	"skyMaps": {
		"prairie.butterfly": "Butterfly Fields",
		"prairie.village": "Village Islands",
		"prairie.cave": "Cave",
		"prairie.bird": "Bird Nest",
		"prairie.island": "Sanctuary Island",
		"forest.brook": "Brook",
		"forest.boneyard": "Boneyard",
		"forest.end": "Forest Garden",
		"forest.tree": "Treehouse",
		"forest.sunny": "Elevated Clearing",
		"valley.rink": "Ice Rink",
		"valley.dreams": "Village of Dreams",
		"valley.hermit": "Hermit valley",
		"wasteland.temple": "Broken Temple",
		"wasteland.battlefield": "Battlefield",
		"wasteland.graveyard": "Graveyard",
		"wasteland.crab": "Crab Field",
		"wasteland.ark": "Forgotten Ark",
		"vault.starlight": "Starlight Desert",
		"vault.jelly": "Jellyfish Cove"
	},
}

func _process(_delta):
	var today_shard_info = SkyEvents.shard_for(Time.get_datetime_string_from_system())
	if today_shard_info.is_red:
		$ShardInfo.modulate = Color("d96f6f")
	else:
		$ShardInfo.modulate = Color("ffffffff")
	$ShardInfo.text = "%s at %s, %s" % [("Red Shard" if today_shard_info.is_red else "Black Shard"), lang["skyMaps"][today_shard_info.map], lang["skyRealms"][today_shard_info.realm + ".short"]]
	if today_shard_info.is_red:
		$ShardInfo.text = $ShardInfo.text + " giving %s red candles" % [str(today_shard_info.reward_ac)]
	$ShardTimeInfo.text = process_shard_time(today_shard_info)

func process_shard_time(today_shard_info):
	# ---- inline shard_timer ----
	var now := Time.get_unix_time_from_system()
	var base := Time.get_unix_time_from_datetime_string(Time.get_date_string_from_system() + "T00:00:00")
	var meta = today_shard_info

	# 1) look for active window
	for occ in meta.occurrences:
		var st = base + occ.start
		var ed = base + occ.end
		if st <= now and now < ed:
			return "Current shard ends in " + pretty_format(ed - now)   # live countdown

	# 2) find next start
	for occ in meta.occurrences:
		var st = base + occ.start
		if st > now:
			return "Next shard landing in " + pretty_format(st - now)   # time till start

	# 3) no more today
	return "no more for today"

var shard_day := ""
var cached_info := {}


func pretty_format(sec: int) -> String:
	sec = int(sec)
	@warning_ignore("integer_division")
	var h := sec / 3600
	@warning_ignore("integer_division")
	var m := (sec / 60) % 60
	var s := sec % 60
	var out := "%02d:%02d:%02d" % [h, m, s]
	if h == 0: out = out.substr(3)
	return out
