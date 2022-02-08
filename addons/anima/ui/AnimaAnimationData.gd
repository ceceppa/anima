tool
extends VBoxContainer

signal select_property
signal select_animation
signal select_easing
signal content_size_changed(new_size)
signal value_updated
signal select_relative_property
signal animate_as_changed(as_node)

onready var _node_or_group = get_node("NodeOrGroup")

func show_group_or_node() -> void:
	_node_or_group.show()

func get_animation_data() -> Dictionary:
	return {}

func restore_data(source_node: Node, data: Dictionary) -> void:
	pass
