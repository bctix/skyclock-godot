extends Control

# im sorry for what you have to see in this

@onready var offset_box: SpinBox = $OffsetLabel/OffsetBox

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
	get_tree().get_root().set_transparent_background(true)
	set_colors()
	Config.value_changed.connect(conf_changed)

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

func _process(_delta):
	var current_time = Timezone.get_sky_unix_time_from_system()
	
	@warning_ignore("static_called_on_instance")
	var info = SkyShard.get_shard_info(current_time + 86400 * Globals.SHARD_OFFSET)
	
	process_shard_info(info)
	process_shard_time_info(info)
	$ShardStatus.text = get_shard_status_string(current_time, info)

func process_shard_info(info) -> void:
	$ShardStatus.visible = info.has_shard
	%ShardTimes.visible = info.has_shard
	if not info.has_shard:
		$ShardInfo.modulate = Color("ffffffff")
		if $OffsetLabel/OffsetBox.value != 0:
			$ShardInfo.text = "There is no shard this day."
		else:
			$ShardInfo.text = "There is no shard today."
		return
	
	if info.is_red:
		$ShardInfo.modulate = Color("d96f6f")
	else:
		$ShardInfo.modulate = Color("ffffffff")
		
	$ShardInfo.text = "%s at %s, %s" % [("Red Shard" if info.is_red else "Black Shard"), lang["skyMaps"][info.map], lang["skyRealms"][info.realm + ".short"]]
	
	if info.is_red:
		$ShardInfo.text = $ShardInfo.text + " giving %s red candles" % [str(info.reward_ac)]

func process_shard_time_info(info) -> void:
	var current_time = Time.get_unix_time_from_system() + 3600
	
	if not info.has_shard:
		%ShardTimes.visible = false
		return
	else:
		%ShardTimes.visible = true
	
	for i in range(3):
		var occ = info.occurrences[i]
		var land_time = format_to_time(occ.land)
		var end_time = format_to_time(occ.end)
		var has_ended = current_time >= occ.end
		if i == 0:
			$ShardTimes/FirstShardLabel/Strikethrough.visible = has_ended
			$ShardTimes/FirstShardLabel/Time.text = "%s - %s" % [land_time, end_time]
		elif i == 1:
			$ShardTimes/SecondShardLabel/Strikethrough.visible = has_ended
			$ShardTimes/SecondShardLabel/Time.text = "%s - %s" % [land_time, end_time]
		elif i == 2:
			$ShardTimes/ThirdShardLabel/Strikethrough.visible = has_ended
			$ShardTimes/ThirdShardLabel/Time.text = "%s - %s" % [land_time, end_time]

func format_to_time(unix_time) -> String:
	var tz = Time.get_time_zone_from_system()
	var local_unix = unix_time + tz.bias * 60
	var t = Time.get_datetime_dict_from_unix_time(int(local_unix))
	var h = t.hour
	if Time.get_datetime_dict_from_system()["dst"]:
		h = h - 1
	var suffix = "am" if h < 12 else "pm"
	h = h % 12
	if h == 0: h = 12
	var time = "%d:%02d:%02d %s" % [h, t.minute, t.second, suffix]
	return time

func get_shard_status_string(current_time, info) -> String:
	if not info.has_shard:
		return "No more shards for today"

	for occurrence in info.occurrences:
		@warning_ignore("unused_variable")
		var start = occurrence.start
		var land = occurrence.land
		var end = occurrence.end

		if current_time >= land and current_time < end:
			var time_until_end = end - current_time
			return "Current shard ends in " + _format_duration(time_until_end)

		if current_time < land:
			var time_until_land = land - current_time
			return "Next shard lands in " + _format_duration(time_until_land)

	return "No more shards for today"

func _format_duration(seconds: float) -> String:
	var total_seconds = int(seconds)
	@warning_ignore("integer_division")
	var hours = total_seconds / 3600
	@warning_ignore("integer_division")
	var minutes = (total_seconds % 3600) / 60
	var secs = total_seconds % 60

	if hours > 0:
		return "%dh %dm %ds" % [hours, minutes, secs]
	elif minutes > 0:
		return "%dm %ds" % [minutes, secs]
	else:
		return "%ds" % secs

func set_colors() -> void:
	for node in $".".get_children():
		if node is Label:
			if node.name == "ShardInfo": continue
			node.add_theme_color_override("font_color", Config.get_value("global", "color"))
		elif node is CanvasItem:
			node.self_modulate = Config.get_value("global", "color")
