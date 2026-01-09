extends Control

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
	set_colors()
	Config.value_changed.connect(conf_changed)

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

func _process(_delta):
	var current_time = Time.get_unix_time_from_system()
	
	@warning_ignore("static_called_on_instance")
	var info = SkyShard.get_shard_info(current_time + 86400 * offset_box.value)
	
	if not info.has_shard:
		$ShardInfo.modulate = Color("ffffffff")
		$ShardInfo.text = "There is no shard this day."
		$ShardTimeInfo.text = ""
		return
		
	if info.is_red:
		$ShardInfo.modulate = Color("d96f6f")
	else:
		$ShardInfo.modulate = Color("ffffffff")
		
	$ShardInfo.text = "%s at %s, %s" % [("Red Shard" if info.is_red else "Black Shard"), lang["skyMaps"][info.map], lang["skyRealms"][info.realm + ".short"]]
	
	if info.is_red:
		$ShardInfo.text = $ShardInfo.text + " giving %s red candles" % [str(info.reward_ac)]
		
	$ShardTimeInfo.text = get_shard_status_string(current_time, info)

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
