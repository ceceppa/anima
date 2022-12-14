tool
extends VBoxContainer

signal frame_deleted
signal frame_updated
signal move_one_left
signal move_one_right

const FINAL_WIDTH := 360.0

export var animate_entrance_exit := true

onready var _delay = find_node("DelayValue")
onready var _title = find_node("ToggleButton")

func get_data() -> Dictionary:
	return {
		type = "delay",
		data = {
			delay = _delay.get_value(),
		},
		_collapsed = not _title.pressed
	}

func set_collapsed(collapsed: bool) -> void:
	if _title == null:
		_title = find_node("ToggleButton")

	_title.pressed = not collapsed

func restore_data(data: Dictionary) -> void:
	if _delay == null:
		_delay = find_node("DelayValue")

	_delay.set_value(data.delay)

func _on_Delete_pressed():
	queue_free()
	emit_signal("frame_deleted")

func _on_DelayValue_changed():
	emit_signal("frame_updated")

func set_has_previous(has: bool, direction: int) -> void:
	var icon = "res://addons/anima/visual-editor/icons/MoveLeft.svg" if direction == 0 else "res://addons/anima/visual-editor/icons/MoveUp.svg"
	var tip = "left" if direction == 0 else "up"

	var node = find_node("MoveLeft")
	node.icon = load(icon)
	node.hint_tooltip = "Move one frame " + tip

	_maybe_set_visible("MoveLeft", has)

func set_has_next(has: bool, direction: int) -> void:
	var icon = "res://addons/anima/visual-editor/icons/MoveRight.svg" if direction == 0 else "res://addons/anima/visual-editor/icons/MoveDown.svg"
	var tip = "right" if direction == 0 else "down"

	var node = find_node("MoveRight")
	node.icon = load(icon)
	node.hint_tooltip = "Move one frame " + tip

	_maybe_set_visible("MoveRight", has)

func _maybe_set_visible(node_name: String, visible: bool) -> void:
	var node = find_node(node_name)

	if node:
		node.visible = visible

func _on_MoveRight_pressed():
	emit_signal("move_one_right")

func _on_MoveLeft_pressed():
	emit_signal("move_one_left")

func update_size_x(value: float) -> void:
	rect_size.x = value
	$Control/BG.rect_size = rect_size

func _on_ToggleButton_pressed():
	emit_signal("frame_updated")
