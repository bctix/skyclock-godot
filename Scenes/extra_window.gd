extends Window

var funny_window = preload("res://Scenes/funny.tscn")
var funny_window_instance = null

func _ready():
	$Control.modulate.a = 0
	$"Control/Background/24hr_label/24hr_toggle".button_pressed = Config.get_value("clock", "24h")
	$Control/Background/notif_label/notif_toggle.button_pressed = Config.get_value("clock", "notifications")
	$Control/Background/color_label/ColorPickerButton.color = Config.get_value("global", "color")
	$Control.position.y = $Control.size.y
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Control, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Control, "position:y", 0.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	$Control/Background/version.text = "version: %s" % [ProjectSettings.get_setting("application/config/version")]
	set_colors()
	Config.value_changed.connect(conf_changed)

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

var drag_offset = Vector2.ZERO
var is_dragging = false
func _input(_event):
	if is_dragging:
		var current_mouse_pos: Vector2 = DisplayServer.mouse_get_position()
		var window_pos: Vector2 = current_mouse_pos - drag_offset
		self.position =  window_pos

func _on_drag_button_button_down() -> void:
	is_dragging = true
	drag_offset = get_viewport().get_mouse_position()

func _on_drag_button_button_up() -> void:
	is_dragging = false
	drag_offset = Vector2.ZERO

var closing = false
func _on_close_button_pressed() -> void:
	if not closing:
		closing = true
		var tween = create_tween()
		tween.tween_property($Control, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		self.queue_free()
	pass # Replace with function body.

func _on_hr_toggle_toggled(toggled_on: bool) -> void:
	Config.set_value("clock", "24h", toggled_on)
	
func _on_notif_toggle_toggled(toggled_on: bool) -> void:
	Config.set_value("clock", "notifications", toggled_on)

func _on_funnybutton_pressed() -> void:
	if funny_window_instance == null:
		funny_window_instance = funny_window.instantiate()
		funny_window_instance.position = Vector2i(get_window().position.x, get_window().position.y - funny_window_instance.size.y)
		add_child(funny_window_instance)
	pass # Replace with function body.

func set_colors() -> void:
	for node in $Control/Background.get_children():
		if node is Label:
			node.add_theme_color_override("font_color", Config.get_value("global", "color"))
		elif node is CanvasItem:
			node.self_modulate = Config.get_value("global", "color")

func _on_color_picker_button_color_changed(color: Color) -> void:
	Config.set_value("global", "color", color)
	pass


func _on_reset_color_pressed() -> void:
	$Control/Background/color_label/ColorPickerButton.color = Color("#e5e3cf")
	Config.set_value("global", "color", $Control/Background/color_label/ColorPickerButton.color)
	pass # Replace with function body.
