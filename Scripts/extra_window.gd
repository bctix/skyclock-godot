extends Window

func _ready():
	$Control.modulate.a = 0
	$"Control/Background/24hr_toggle".button_pressed = GlobalSettings.TWENTY_FOUR_HR_MODE
	var tween = create_tween()
	tween.tween_property($Control, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

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
	GlobalSettings.TWENTY_FOUR_HR_MODE = toggled_on
