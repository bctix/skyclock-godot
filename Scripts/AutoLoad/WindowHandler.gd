extends Node

class WindowSlot:
	var id: String
	var window: Window
	func _init(i: String, w: Window):
		id = i
		window = w

var windows:Array[WindowSlot] = []
var root_window:Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func set_root_window(id: String) -> void:
	var window = find_by_id(id)
	root_window = window

func add_window(id:String, window: Window) -> void:
	windows.push_front(WindowSlot.new(id,window))
	if root_window != null:
		root_window.add_child(window)

func close_window(id: String) -> Tween:
	var window = find_by_id(id)
	var tween = create_tween()
	tween.tween_property(window.get_child(0), "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	window.queue_free()
	return tween

func close_all_windows() -> Tween:
	var tween = create_tween()
	tween.set_parallel(true)
	for window in get_all_windows():
		var child = window.get_child(0)
		tween.tween_property(child, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	for window in get_all_windows():
		window.queue_free()
	return tween

func window_exists(id: String) -> bool:
	return find_by_id(id) != null
	
func get_all_windows() -> Array[Window]:
	var arr:Array[Window] = []
	for slot in windows:
		arr.push_front(slot.window)
	return arr

func find_by_id(id: String) -> Window:
	for slot in windows:
		if slot.id == id:
			return slot.window
	return null
