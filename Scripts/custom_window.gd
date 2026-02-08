extends Window
class_name CustomWindow

@export var id: String
@export var passthrough_path: Path2D

func _ready() -> void:
	print("window %s ready" % [id])
	if passthrough_path:
		mouse_passthrough_polygon = passthrough_path.curve.get_baked_points()
	Config.value_changed.connect(conf_changed)
	set_colors()

func add() -> void:
	WindowHandler.add_window(id, self)

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

var closing = false
func close() -> void:
	print("closing window %s" % [id])
	if not closing:
		closing = true
		WindowHandler.close_window(id)

func set_colors() -> void:
	for node in get_all_themeable_children(self):
		if node is Label:
			node.add_theme_color_override("font_color", Config.get_value("global", "color"))
		elif node is CanvasItem:
			node.self_modulate = Config.get_value("global", "color")

# https://www.reddit.com/r/godot/comments/40cm3w/looping_through_all_children_and_subchildren_of_a/
# AayiramSooriyan
func get_all_themeable_children(in_node,arr:=[]):
	if in_node.has_meta("unthemeable"):
		if not in_node.get_meta("unthemeable"):
			arr.push_back(in_node)
	for child in in_node.get_children():
		if in_node.has_meta("unthemeable"):
			if not in_node.get_meta("unthemeable"):
				arr = get_all_themeable_children(child,arr)
	return arr
