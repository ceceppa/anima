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
var _animation_name: String
var _relative_source: Node

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

	_node_or_group.visible = node.get_child_count() > 1

func get_data() -> Dictionary:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)
	var use_property_or_animation: String = find_node("UseAnimation").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name).get_pressed_button().get_parent().name
	var use_animation = use_property_or_animation == find_node("UseAnimation").name
	var _property_values = find_node("PropertyValues")

	var animate_as_button: Button = animate_as_group.get_pressed_button()
	if animate_as_button == null:
		animate_as_button = animate_as_group.get_buttons()[0]
		animate_as_button.pressed = true

	var easing_value = ANIMA.EASING.LINEAR
	var easing_button: Button = _property_values.find_node("EasingButton")

	if easing_button.has_meta("easing_value"):
		easing_value = int(easing_button.get_meta("easing_value"))

	var data =  {
		node_path = _path,
		property_name = _property,
		property_type = _property_type,
		duration = _duration.get_value(),
		delay = _delay.get_value(),
		animate_as = animate_as_button.get_parent().name,
		use = use_property_or_animation,
		animation_name = _animation_name,
		from = _property_values.find_node("FromValue").get_value(),
		to = _property_values.find_node("ToValue").get_value(),
		initialValue = _property_values.find_node("InitialValue").get_value(),
		relative = _property_values.find_node("RelativeCheck").pressed,
		pivot = _property_values.find_node("PivotButton").get_value(),
		easing = [easing_button.text, easing_value]
	}

	return data

func restore_data(data: Dictionary) -> void:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)
	var use_property_or_animation: ButtonGroup = find_node("UseAnimation").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)

	_press_button_in_group(use_property_or_animation, data.use)
	_press_button_in_group(animate_as_group, data.animate_as)

	find_node("Duration").set_value(data.duration)
	find_node("Delay").set_value(data.delay)

	var animate_as: AnimaButton = _node_or_group.find_node(data.animate_as)
	animate_as.set(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_PRESSED.name, true)
	animate_as._on_pressed()

	var use: AnimaButton = find_node(data.use)
	use.set(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_PRESSED.name, true)
	
	find_node("AnimateWith").set_index(use.get_index())

	if data.has("animation_name"):
		selected_animation(data.animation_name, data.animation_name)

#		from = _property_values.find_node("FromValue").get_value(),
#		to = _property_values.find_node("ToValue").get_value(),
#		initialValue = _property_values.find_node("InitialValue").get_value(),
#		relative = _property_values.find_node("RelativeCheck").pressed,
#		pivot = _property_values.find_node("PivotButton").get_value(),
#		easing = easing_value
	var _property_values = find_node("PropertyValues")

	if data.has("from"):
		_property_values.find_node("FromValue").set_value(data.from)

	if data.has("to"):
		_property_values.find_node("ToValue").set_value(data.to)

	if data.has("initialValue"):
		_property_values.find_node("InitialValue").set_value(data.initialValue)

	if data.has("relative"):
		_property_values.find_node("RelativeCheck").pressed = data.relative

	if data.has("pivot"):
		_property_values.find_node("PivotButton").set_value(data.pivot)

	if data.has("easing"):
		set_easing(data.easing[0], data.easing[1])

func set_relative_property(node_path: String, property: String) -> void:
	var value = _relative_source.get_value()

	if value == null:
		value = ""

	_relative_source.set_value(value + " " + node_path + ":" + property)

func _press_button_in_group(group: ButtonGroup, selected_button_name: String) -> void:
	var buttons = group.get_buttons()

	for button in buttons:
		button.pressed = button.name == selected_button_name

func _on_UseAnimation_pressed():
	emit_signal("updated")

func _on_PropertyButton_pressed():
	emit_signal("select_property")

func _on_AnimaAnimationData_mouse_entered():
	emit_signal("highlight_node", _source_node)

func _on_Title_toggled(button_pressed):
	$Content.visible = button_pressed

func _on_RemoveButton_pressed():
	emit_signal("removed", self)

func selected_animation(label, name) -> void:
	if name:
		_animation_name = name
		find_node("SelectAnimation").set_label(name)

		emit_signal("updated")

func set_easing(name: String, value: int) -> void:
	var button: Button = find_node("EasingButton")

	button.text = name
	button.set_meta("easing_value", value)

	emit_signal("updated")

func _on_AnimateProperty_pressed():
	emit_signal("updated")

func _on_SelectAnimation_pressed():
	emit_signal("select_animation")

func _on_Duration_value_updated():
	emit_signal("updated")

func _on_Delay_value_updated():
	emit_signal("updated")

func _on_AsNode_pressed():
	_update_animate_as_label()

func _on_AsGroup_pressed():
	_update_animate_as_label()

func _on_AsGrid_pressed():
	_update_animate_as_label()

func _update_animate_as_label() -> void:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").get(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_GROUP.name)
	var selected = animate_as_group.get_pressed_button().get_parent().name

	_node_or_group.set_label("Animate as:   " + selected.replace("As", ""))

	emit_signal("updated")

func _on_Title_mouse_entered():
	_on_AnimaAnimationData_mouse_entered()

func _update_me():
	emit_signal("updated")

func _on_RelativeCheck_toggled(_button_pressed):
	_update_me()

func _on_FromValue_select_relative_property():
	_relative_source = find_node("FromValue")

	emit_signal("select_relative_property")

func _on_ToValue_select_relative_property():
	_relative_source = find_node("ToValue")

	emit_signal("select_relative_property")

func _on_InitialValue_select_relative_property():
	_relative_source = find_node("InitialValue")

	emit_signal("select_relative_property")

func _on_EasingButton_pressed():
	emit_signal("select_easing")
