extends Control

var extra_window = preload("res://Scenes/extra_window.tscn")
var shard_window = preload("res://Scenes/shard_window.tscn")
var extra_window_instance = null
var shard_window_instance = null

func _ready():
	start_up()

func start_up():
	$".".modulate.a = 0
	var screen_size = DisplayServer.screen_get_size()
	var window_size = get_window().size
	var bottom_left_position = Vector2(60, screen_size.y - window_size.y + 140) # Adjust -30 as needed
	get_window().position = Vector2i(bottom_left_position.x - 400, bottom_left_position.y + 400)
	await get_tree().create_timer(0.8).timeout
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($".", "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "position:x", bottom_left_position.x, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(get_window(), "position:y", bottom_left_position.y, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished

var drag_offset = Vector2.ZERO
var is_dragging = false
func _input(event):
	if is_dragging:
		var current_mouse_pos: Vector2 = DisplayServer.mouse_get_position()
		var window_pos: Vector2 = current_mouse_pos - drag_offset
		DisplayServer.window_set_position(window_pos)
	if event.is_action_pressed("ui_accept"):
		print(SkyEvents.shard_for(Time.get_datetime_string_from_system()))
	
func _on_drag_button_button_down() -> void:
	is_dragging = true
	drag_offset = get_viewport().get_mouse_position()

func _on_drag_button_button_up() -> void:
	is_dragging = false
	drag_offset = Vector2.ZERO

func _on_settings_button_pressed() -> void:
	if extra_window_instance == null:
		extra_window_instance = extra_window.instantiate()
		extra_window_instance.position = Vector2i(get_window().position.x, get_window().position.y - extra_window_instance.size.y)
		add_child(extra_window_instance)
	pass

func _on_shard_button_pressed() -> void:
	if shard_window_instance == null:
		shard_window_instance = shard_window.instantiate()
		shard_window_instance.position = Vector2i(get_window().position.x + shard_window_instance.size.x, get_window().position.y)
		add_child(shard_window_instance)
	pass # Replace with function body.

var closing = false
func _on_close_button_pressed() -> void:
	if not closing:
		closing = true
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property($".", "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		if extra_window_instance != null:
			tween.tween_property(extra_window_instance.get_child(0), "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		if shard_window_instance != null:
			tween.tween_property(shard_window_instance.get_child(0), "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tween.finished
		get_tree().quit()
	pass # Replace with function body.
