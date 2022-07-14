tool
extends VBoxContainer

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
var _property_type

onready var _node_or_group = find_node("NodeOrGroup")
onready var _duration = find_node("Duration")
onready var _delay = find_node("Delay")
onready var _timer = find_node("Timer")

func _ready():
	margin_right = 0

	_on_Title_toggled(false)

func show_group_or_node() -> void:
	_node_or_group.show()

func set_data(node: Node, path: String, property, property_type):
	$Title.set_label(node.name + ":" + property)
	
	_path = path
	_property = property
	_source_node = node
	_property_type = property_type

func get_data() -> Dictionary:
	var animate_as_group: String = _node_or_group.find_node("AsNode").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name).get_pressed_button().get_parent().name
	var use_property_or_animation: String = find_node("UseAnimation").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name).get_pressed_button().get_parent().name
	var use_animation = use_property_or_animation == find_node("UseAnimation").name

	var value = {}

	if use_animation:
		pass

	var data =  {
		node_path = _path,
		property_name = _property,
		property_type = _property_type,
		duration = _duration.get_value(),
		delay = _delay.get_value(),
		animate_as = animate_as_group,
		use = use_property_or_animation
	}

	return data

func restore_data(data: Dictionary) -> void:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)
	var use_property_or_animation: ButtonGroup = find_node("UseAnimation").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)

	_press_button_in_group(use_property_or_animation, data.use)
	_press_button_in_group(animate_as_group, data.animate_as)

	print("restoring data", data)

func _press_button_in_group(group: ButtonGroup, selected_button_name: String) -> void:
	var buttons = group.get_buttons()

	print("pressing button", group, selected_button_name)
	for button in buttons:
		button.pressed = button.name == selected_button_name

func _on_UseAnimation_pressed():
	emit_signal("updated")

func _on_AnimationButton_pressed():
	emit_signal("select_animation")

func _on_PropertyButton_pressed():
	emit_signal("select_property")

func _on_AnimaAnimationData_mouse_entered():
	emit_signal("highlight_node", _source_node)

func _on_Title_toggled(button_pressed):
	$Content.visible = button_pressed

func _on_RemoveButton_pressed():
	emit_signal("removed", self)

func selected_animation(label, name) -> void:
	prints(label, name)

func _on_AnimateProperty_pressed():
	emit_signal("updated")
