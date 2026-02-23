extends CustomWindow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Control.modulate.a = 0
	#$Control.position.x -= $Control.size.x
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($Control, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property($Control, "position:x", 0.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	super()
	get_and_set_shard_image()
	pass # Replace with function body.

func get_and_set_shard_image() -> void:
	var current_time = Time.get_unix_time_from_system()
	@warning_ignore("static_called_on_instance")
	var info = SkyShard.get_shard_info(current_time + 86400 * %OffsetBox.value)
	if info.has_shard:
		$Control/Background/BrokeText.text = "or it broke idk..."
		$Control/Background/LoadingText.visible = true
		var url = "https://raw.githubusercontent.com/PlutoyDev/sky-shards/refs/heads/production/public/infographics/map_clement/%s.webp" % [info.map]
		print("Requesting image...")
		%HTTPRequest.request(url)
	else:
		$Control/Background/BrokeText.text = "There is no shard this day."
		$Control/Background/LoadingText.visible = false

func _on_http_request_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var image = Image.new()
	var error = image.load_webp_from_buffer(body)
	
	if error == OK:
		image.resize(%MapImage.size.x, %MapImage.size.y)
		
		var tex = ImageTexture.create_from_image(image)
		var rect = %MapImage
		rect.texture = tex
		
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.custom_minimum_size = Vector2(592, 592)
		rect.visible = true
		
	pass # Replace with function body.

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

func _on_close_button_pressed() -> void:
	close()
	pass # Replace with function body.


func _on_offset_box_value_changed(_value: float) -> void:
	%MapImage.visible = false
	%DelayTimer.stop()
	%DelayTimer.start()
	pass # Replace with function body.


func _on_delay_timer_timeout() -> void:
	get_and_set_shard_image()
	pass # Replace with function body.
