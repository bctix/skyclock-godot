extends Window
class_name CustomWindow

@export var id: String
@export var passthrough_path: Path2D

func _ready() -> void:
	print("window %s ready" % [id])
	if passthrough_path:
		mouse_passthrough_polygon = passthrough_path.curve.get_baked_points()
	WindowHandler.add_window(id, self)

var closing = false
func close() -> void:
	print("closing window %s" % [id])
	if not closing:
		closing = true
		WindowHandler.close_window(id)
