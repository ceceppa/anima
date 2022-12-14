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
onready var _skip_delay = find_node("SkipDelay")

func get_data() -> Dictionary:
	return {
		type = "delay",
		_skip = _skip_delay.pressed,
		_collapsed = not _title.pressed,
		data = {
			delay = _delay.get_value(),
			_skip = _skip_delay.pressed,
		},
	}

func set_collapsed(collapsed: bool) -> void:
	if _title == null:
		_title = find_node("ToggleButton")

	_title.pressed = not collapsed

func restore_data(data: Dictionary) -> void:
	if _delay == null:
		_delay = find_node("DelayValue")
		_skip_delay = find_node("SkipDelay")

	_delay.set_value(data.delay)

	if data.has("_skip"):
		_skip_delay.pressed = data._skip

func _on_Delete_pressed():
	queue_free()
	emit_signal("frame_deleted")

func _on_DelayValue_changed():
	emit_signal("frame_updated")

func set_has_previous(has: bool, direction: int) -> void:
	pass

func set_has_next(has: bool, direction: int) -> void:
	pass

func _maybe_set_visible(node_name: String, visible: bool) -> void:
	pass
#	var node = find_node(node_name)
#
#	if node:
#		node.visible = visible

func _on_MoveRight_pressed():
	emit_signal("move_one_right")

func _on_MoveLeft_pressed():
	emit_signal("move_one_left")

func _on_ToggleButton_pressed():
	emit_signal("frame_updated")


func _on_AnimaFrameDelay_resized():
	$Control/BG.rect_size = rect_size

func _on_OptionsMenu_item_selected(id):
	if id == 0:
		emit_signal("move_one_left")
	elif id == 1:
		emit_signal("move_one_right")
	else:
		_on_Delete_pressed()

func _on_SkipDelay_pressed():
	emit_signal("frame_updated")

func _on_SkipDelay_toggled(button_pressed):
	var icon = "Skip.svg" if button_pressed else "CanPlay.svg"
	var hint = "Use delay" if button_pressed else "Ignore delay"

	_skip_delay.icon = load("res://addons/anima/visual-editor/icons/" + icon)
	_skip_delay.hint_tooltip = hint

func set_skip(skip: bool):
	_skip_delay.pressed = skip
