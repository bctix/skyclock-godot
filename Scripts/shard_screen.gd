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

func _ready() -> void:
	set_colors()
	Config.value_changed.connect(conf_changed)

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

func _process(_delta):
	var sky_time = Timezone.get_sky_datetime_string_from_unix_time()
	var today_shard_info = SkyEvents.shard_for(sky_time)
	if today_shard_info.is_red:
		$ShardInfo.modulate = Color("d96f6f")
	else:
		$ShardInfo.modulate = Color("ffffffff")
	$ShardInfo.text = "%s at %s, %s" % [("Red Shard" if today_shard_info.is_red else "Black Shard"), lang["skyMaps"][today_shard_info.map], lang["skyRealms"][today_shard_info.realm + ".short"]]
	if today_shard_info.is_red:
		$ShardInfo.text = $ShardInfo.text + " giving %s red candles" % [str(today_shard_info.reward_ac)]
	$ShardTimeInfo.text = process_shard_time(today_shard_info)

func process_shard_time(today_shard_info):
	var now := Time.get_unix_time_from_system()
	var base := Time.get_unix_time_from_datetime_string(Time.get_date_string_from_system() + "T00:00:00")
	var meta = today_shard_info

	for occ in meta.occurrences:
		var st = base + occ.start
		var ed = base + occ.end
		if st <= now and now < ed:
			print(pretty_format(occ.start))
			return "Current shard ends in " + pretty_format(ed - now)

	for occ in meta.occurrences:
		if occ.start > now:
			return "Next shard landing in " + pretty_format(occ.start - now)

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

func set_colors() -> void:
	for node in $".".get_children():
		if node is Label:
			node.add_theme_color_override("font_color", Config.get_value("global", "color"))
		elif node is CanvasItem:
			node.self_modulate = Config.get_value("global", "color")
