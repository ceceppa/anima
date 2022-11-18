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
signal select_node_property(node_path)

onready var _node_or_group = find_node("NodeOrGroup")
onready var _group_data = find_node("GroupData")
onready var _grid_data = find_node("GridData")
onready var _property_values = find_node("PropertyValues")
onready var _select_animation = find_node("SelectAnimation")
onready var _animate_property = find_node("AnimateProperty")
onready var _duration = find_node("Duration")
onready var _delay = find_node("Delay")
onready var _timer = find_node("Timer")
onready var _title = find_node("Title")
onready var _animation_type = find_node("AnimationType")
onready var _animation_type_icon = find_node("AnimationTypeIcon")
onready var _background_rect = find_node("Background")

var _path: String
var _property
var _source_node: Node
var _property_type
var _animation_name: String
var _relative_source: Node
var _animate_with: int = AnimaVisualNode.USE.ANIMATE_PROPERTY
var _animate_as: int = AnimaVisualNode.ANIMATE_AS.NODE

func _ready():
	margin_right = 0

	_node_or_group.hide()
	_group_data.hide()
	_grid_data.hide()
	_select_animation.hide()

	_setup_group_data()

func _setup_group_data() -> void:
	_animation_type.clear()

	for type in ANIMA.GROUP.keys():
		_animation_type.add_item(type, ANIMA.GROUP[type])

func show_group_or_node() -> void:
	_node_or_group.show()

func set_data(node: Node, path: String, property, property_type, toggle_title := true):
	_title.set_text(node.name + ":" + property)
	
	_path = path
	_source_node = node
	_property = property
	_property_type = property_type

	_node_or_group.visible = node.get_child_count() > 1

	find_node("PropertySelector").visible = property_type == TYPE_NIL
	find_node("PropertyData").visible = property_type != TYPE_NIL

	_set_property_type(property_type)

	if toggle_title:
		_maybe_toggle_title()

func _maybe_toggle_title() -> void:
	find_node("Title").pressed = _property_type == TYPE_NIL and _animation_name == ""

func get_data() -> Dictionary:
	if _property_values == null:
		_property_values = find_node("PropertyValues")

	var easing_value = ANIMA.EASING.LINEAR
	var easing_button: Button = _property_values.find_node("EasingButton")

	if easing_button.has_meta("easing_value"):
		easing_value = int(easing_button.get_meta("easing_value"))

	if not _node_or_group.visible:
		_animate_as = AnimaVisualNode.ANIMATE_AS.NODE

	var data =  {
		node_path = _path,
		property_name = _property,
		property_type = _property_type,
		duration = _duration.get_value(),
		delay = _delay.get_value(),
		animate_as = _animate_as,
		use = _animate_with,
		animation_name = _animation_name,
		group = {
			items_delay = float(find_node("ItemsDelay").get_value()),
			animation_type = _animation_type.get_selected_id(),
			start_index = int(find_node("StartIndex").get_value())
		},
		property = {
			from = _property_values.find_node("FromValue").get_value(),
			to = _property_values.find_node("ToValue").get_value(),
			initialValue = _property_values.find_node("InitialValue").get_value(),
			relative = _property_values.find_node("RelativeCheck").pressed,
			pivot = _property_values.find_node("PivotButton").get_value(),
			easing = [easing_button.text, easing_value]
		}
	}

	return data

func restore_data(data: Dictionary) -> void:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").group

	_press_button_in_group(_animate_property.group, data.use)
	_press_button_in_group(animate_as_group, data.animate_as)

	find_node("Duration").set_value(data.duration)
	find_node("Delay").set_value(data.delay)

	if data.has("animation_name"):
		selected_animation(data.animation_name, data.animation_name)

	if _property_values == null:
		_property_values = find_node("PropertyValues")

	_set_property_type(data.property_type)

	if data.property.has("from"):
		_property_values.find_node("FromValue").set_value(data.property.from)

	if data.property.has("to"):
		_property_values.find_node("ToValue").set_value(data.property.to)

	if data.property.has("initialValue"):
		_property_values.find_node("InitialValue").set_value(data.property.initialValue)

	if data.property.has("relative"):
		_property_values.find_node("RelativeCheck").pressed = data.property.relative

	if data.property.has("pivot"):
		_property_values.find_node("PivotButton").set_value(data.property.pivot)

	if data.property.has("easing"):
		set_easing(data.property.easing[0], data.property.easing[1])

	if data.has("group"):
		find_node("ItemsDelay").set_value(data.group.items_delay)
		find_node("StartIndex").set_value(data.group.start_index)

		var type = data.group.animation_type
		for index in _animation_type.get_item_count():
			var item_id = _animation_type.get_item_id(index)

			if item_id == data.group.animation_type:
				_animation_type.select(index)

				break

	_maybe_toggle_title()
	_update_icon(data.use, false)

func _set_property_type(property_type) -> void:
	for child in _property_values.get_child(1).get_children():
		if child.has_method('set_type') and property_type != TYPE_NIL:
			child.set_type(property_type)

func set_relative_property(node_path: String, property: String) -> void:
	var value = _relative_source.get_value()

	if value == null:
		value = ""

	_relative_source.set_value(value + " " + node_path + ":" + property)

func _press_button_in_group(group: ButtonGroup, selected_button: int) -> void:
	var buttons = group.get_buttons()

	buttons[selected_button].set_pressed(true)

func _on_UseAnimation_pressed():
	emit_signal("updated")

func _on_PropertyButton_pressed():
	emit_signal("select_property")

func _on_AnimaAnimationData_mouse_entered():
	if _source_node == null:
		printerr("_on_AnimaAnimationData_mouse_entered: _source_node is null")

		return

	emit_signal("highlight_node", _source_node)

func _on_Title_toggled(button_pressed):
	$Content.visible = button_pressed

	var icon: String = "res://addons/anima/icons/Minus.svg"

	if not button_pressed:
		icon = "res://addons/anima/icons/Add.svg"

	$Title.set_icon(load(icon))

func _on_RemoveButton_pressed():
	emit_signal("removed", self)

func selected_animation(label, name) -> void:
	if name:
		_animation_name = name
		find_node("SelectAnimation").set_text(name)

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

func _emit_updated():
	emit_signal("updated")

func _on_AsNode_pressed():
	_update_animate_as_label()

func _on_AsGroup_pressed():
	_update_animate_as_label()

func _on_AsGrid_pressed():
	_update_animate_as_label()

func _update_animate_as_label() -> void:
	var animate_as_group: ButtonGroup = _node_or_group.find_node("AsNode").group
	var selected = animate_as_group.get_pressed_button().get_parent().name

	_node_or_group.set_label("Animate as:   " + selected.replace("As", ""))

	var group_data = find_node("GroupData")
	group_data.visible = selected == "AsGroup"

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

func _on_AnimationType_item_selected(_index):
	_emit_updated()

func _update_icon(button_index: int, emit := true) -> void:
	var is_property = button_index == AnimaVisualNode.USE.ANIMATE_PROPERTY
	var value = _property if is_property else _animation_name

	_title.set_text(_source_node.name + ":" + value)

	if _animate_with == button_index:
		return

	var icon := "res://addons/anima/visual-editor/icons/Animation.svg"

	if is_property:
		icon = "res://addons/anima/visual-editor/icons/Property.svg"

	_property_values.visible = is_property
	_select_animation.visible = !is_property

	_animation_type_icon.texture = load(icon)

	_animate_with = button_index


	if emit:
		emit_signal("updated")

func _on_AnimaAnimationData_item_rect_changed():
	if _background_rect:
		_background_rect.rect_size = rect_size

		_animation_type_icon.position.x = rect_size.x - 48

func _on_UseAnimation_toggled(button_pressed):
	_update_icon(AnimaVisualNode.USE.ANIMATION)

func _on_AnimateProperty_toggled(button_pressed):
	_update_icon(AnimaVisualNode.USE.ANIMATE_PROPERTY)

func _on_AsNode_toggled(button_pressed):
	_animate_as = AnimaVisualNode.ANIMATE_AS.NODE

func _on_AsGroup_toggled(button_pressed):
	_animate_as = AnimaVisualNode.ANIMATE_AS.GROUP

func _on_AsGrid_toggled(button_pressed):
	_animate_as = AnimaVisualNode.ANIMATE_AS.GRID

func _on_SelectProperty_pressed():
	emit_signal("select_node_property", self, _source_node.get_path())

func set_property_to_aniamte(property: String, property_type: int) -> void:
	set_data(_source_node, _path, property, property_type, false)

	_update_me()

func _on_Background_mouse_entered():
	pass # Replace with function body.
