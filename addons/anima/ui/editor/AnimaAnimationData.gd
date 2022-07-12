tool
extends AnimaAccordion

signal select_animation
signal select_easing
signal content_size_changed(new_size)
signal value_updated
signal select_relative_property
signal animate_as_changed(as_node)
signal updated
signal removed
signal highlight_node(node)

var _path: String
var _property
var _source_node: Node

onready var _node_or_group = find_node("NodeOrGroup")
onready var _duration = find_node("Duration")
onready var _delay = find_node("Delay")
onready var _timer = find_node("Timer")

func _ready():
	margin_right = 0

func show_group_or_node() -> void:
	_node_or_group.show()

func set_data(node: Node, path: String, property, property_value):
	set_label(node.name + ":" + property)
	
	_path = path
	_property = property
	_source_node = node

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

func _on_UseAnimation_pressed():
	pass # Replace with function body.

func _on_AnimationButton_pressed():
	emit_signal("select_animation")

func _on_PropertyButton_pressed():
	emit_signal("select_property")

func _on_accordion_animation_completed():
	_timer.start()

func _on_Timer_timeout():
	var new_height = $AnimaAnimationDataContent.rect_size.y + _content_control.rect_size.y

	rect_size.y = new_height

func _on_AnimaAnimationData_mouse_entered():
	emit_signal("highlight_node", _source_node)
