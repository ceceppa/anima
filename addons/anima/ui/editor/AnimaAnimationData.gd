tool
extends AnimaAccordion

signal select_property
signal select_animation
signal select_easing
signal content_size_changed(new_size)
signal value_updated
signal select_relative_property
signal animate_as_changed(as_node)
signal updated
signal removed

var _path: String
var _property

onready var _node_or_group = find_node("NodeOrGroup")
onready var _duration = find_node("Duration")
onready var _delay = find_node("Delay")

func _ready():
	margin_right = 0

func show_group_or_node() -> void:
	_node_or_group.show()

func set_data(node: Node, path: String, property, property_value):
	set_label(node.name + ":" + property)
	
	_path = path
	_property = property

func get_data() -> Dictionary:
	var bg: ButtonGroup = _node_or_group.find_node("AsNode").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)
	var use_bg: ButtonGroup = find_node("UseAnimation").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)

	return {}
	return {
		node_path = _path,
		property_name = _property,
		duration = _duration.get_value(),
		delay = _delay.get_value(),
		animate_as = bg.get_pressed_button().name,
		use = use_bg.get_pressed_button().name
	}


func restore_data(source_node: Node, data: Dictionary) -> void:
	pass
