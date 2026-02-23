extends Node

class WindowSlot:
	var id: String
	var window: Window
	var content_node: Node
	var is_root: bool
	
	func _init(i: String, w: Window, c: Node = null):
		id = i
		window = w
		content_node = c if c != null else w.get_child(0)
		is_root = false

var windows:Array[WindowSlot] = []
var root_window:Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func set_root_window(id: String) -> void:
	var slot = find_slot_by_id(id)
	if slot:
		root_window = slot.window
		slot.is_root = true

func add_window(id:String, window: Window, content: Node = null) -> void:
	windows.push_front(WindowSlot.new(id,window, content))
	if root_window != null and window != root_window:
		root_window.add_child(window)

func close_window(id: String) -> Tween:
	var slot = find_slot_by_id(id)
	if not slot:
		return null
	var tween = create_tween()
	if is_instance_valid(slot.content_node):
		tween.tween_property(slot.content_node, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	if not slot.is_root:
		slot.window.queue_free()
		windows.remove_at(windows.find(slot))
	return tween

func close_all_windows() -> Tween:
	var tween = create_tween()
	tween.set_parallel(true)
	for slot in windows:
		if is_instance_valid(slot.content_node):
			tween.tween_property(slot.content_node, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	for slot in windows:
		if not slot.is_root:
			if slot:
				slot.window.queue_free()
	return tween

func window_exists(id: String) -> bool:
	return find_slot_by_id(id) != null
	
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
	
func find_slot_by_id(id: String) -> WindowSlot:
	for slot in windows:
		if slot.id == id:
			return slot	
	return null
