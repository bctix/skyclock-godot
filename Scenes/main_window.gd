extends CustomWindow

var extra_window = preload("res://Scenes/extra_window.tscn")
var shard_window = preload("res://Scenes/shard_window.tscn")

func _ready():
	get_tree().get_root().set_transparent_background(true)
	start_up()
	set_colors()
	Config.value_changed.connect(conf_changed)
	super()

func conf_changed(section: String, key: String, _value) -> void:
	if section == "global" and key == "color":
		set_colors()

func start_up():
	%Control.modulate.a = 0
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	var bottom_left_position = Vector2(60, screen_size.y - window_size.y + 140) # Adjust -30 as needed
	get_window().position = Vector2i(bottom_left_position.x - 400, bottom_left_position.y + 400)
	await get_tree().create_timer(0.8).timeout
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(%Control, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "position:x", bottom_left_position.x, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "position:y", bottom_left_position.y, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

var drag_offset = Vector2.ZERO
var is_dragging = false
func _input(_event):
	if is_dragging:
		var current_mouse_pos: Vector2 = DisplayServer.mouse_get_position()
		var window_pos: Vector2 = current_mouse_pos - drag_offset
		#DisplayServer.window_set_position(window_pos)
		position = window_pos
	
func _on_drag_button_button_down() -> void:
	is_dragging = true
	drag_offset = get_viewport().get_mouse_position()

func _on_drag_button_button_up() -> void:
	is_dragging = false
	drag_offset = Vector2.ZERO

func _on_settings_button_pressed() -> void:
	if not WindowHandler.window_exists("extra"):
		var extra_window_instance = extra_window.instantiate() as Window
		extra_window_instance.position = Vector2i(get_window().position.x, get_window().position.y - extra_window_instance.size.y)
		add_child(extra_window_instance)
	pass

func _on_shard_button_pressed() -> void:
	if not WindowHandler.window_exists("shard"):
		var shard_window_instance = shard_window.instantiate() as Window
		shard_window_instance.position = Vector2i(get_window().position.x + shard_window_instance.size.x, get_window().position.y)
		add_child(shard_window_instance)
	pass # Replace with function body.

var closingapp = false
func _on_close_button_pressed() -> void:
	if not closingapp:
		closingapp = true
		await WindowHandler.close_all_windows()
		get_tree().quit()
	pass # Replace with function body.

func set_colors() -> void:
	for node in %Control.get_children():
		if node is Label:
			node.add_theme_color_override("font_color", Config.get_value("global", "color"))
		elif node is CanvasItem:
			node.self_modulate = Config.get_value("global", "color")
