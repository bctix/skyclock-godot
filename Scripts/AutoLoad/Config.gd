extends Node

var file: ConfigFile = ConfigFile.new()

signal value_changed(section: String, key: String, value: Variant)

func _ready() -> void:
	file = parse_default_as_config()
	load_user_config()
	save()
	
func get_value(section: String, key: String) -> Variant:
	var value = file.get_value(section, key)
	return value

func set_value(section: String, key: String, value: Variant, autosave: bool = true) -> void:
	file.set_value(section, key, value)
	value_changed.emit(section, key, value)
	if autosave:
		save()

func load_user_config() -> Error:
	if FileAccess.file_exists("user://config.ini"):
		
		var user_cfg: ConfigFile = ConfigFile.new()
		var error: Error = user_cfg.load("user://config.ini")
		if error != OK:
			push_error("Config could not be loaded with error code %s!" % error)
			return error

		for section: String in user_cfg.get_sections():
			for key: String in user_cfg.get_section_keys(section):
				if file.has_section_key(section, key):
					file.set_value(section, key, user_cfg.get_value(section, key))

		return OK

	return ERR_FILE_NOT_FOUND
	
func parse_default_as_config() -> ConfigFile:
	var new_file: ConfigFile = ConfigFile.new()

	for section: String in default_configuration.keys():
		var section_value: Dictionary = default_configuration.get(section, {})
		for key: String in section_value.keys():
			new_file.set_value(section, key, section_value.get(key, null))

	return new_file
	
func save() -> void:
	file.save("user://config.ini")
	
var default_configuration: Dictionary = {
	"global": {
		"color": Color("#e5e3cf"),
	},
	"clock": {
		"24h": false,
		"notifications": false
	},
}
