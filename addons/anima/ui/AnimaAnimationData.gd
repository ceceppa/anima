tool
extends VBoxContainer

signal select_property
signal select_animation
signal select_easing
signal content_size_changed(new_size)
signal value_updated
signal select_relative_property
signal animate_as_changed(as_node)

onready var _animation_type_button: Button = find_node('AnimationTypeButton')
onready var _property_type_button: Button = find_node('PropertyTypeButton')
onready var _animation_container: GridContainer = find_node('AnimationContainer')
onready var _animation_button: Button = find_node('AnimationButton')
onready var _property_container: GridContainer = find_node('PropertyContainer')
onready var _property_button: Button = find_node('PropertyButton')
onready var _animation_type: Control = find_node('AnimationType')

onready var _from_value: Control = find_node('FromValue')
onready var _to_value: Control = find_node('ToValue')
onready var _initial_value: Control = find_node('InitialValue')
onready var _relative_check: CheckBox = find_node('RelativeCheck')
onready var _property_values: VBoxContainer = find_node('PropertyValues')
onready var _pivot_button: Control = find_node('PivotButton')
onready var _easing_button: Button = find_node('EasingButton')
onready var _node_or_group: VBoxContainer = find_node('NodeOrGroup')
onready var _node_or_group_controls: HBoxContainer = _node_or_group.find_node('Controls')

var _animation_name: String
var _data_to_restore: Dictionary
var _property_type: int
var _anima_content_type: AnimaNode
var _anima_property_values: AnimaNode
var _previous_animation_type: int
var _is_restoring_values := false

func _ready():
	_property_container.hide()
	$Wrapper.rect_position.y *= AnimaUI.get_dpi_scale()
	$AnimationType.rect_min_size.y *= AnimaUI.get_dpi_scale()

	_maybe_init_anima_node()

func show_group_or_node() -> void:
	_node_or_group.show()

func get_animation_data() -> Dictionary:
	var type: int = AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION

	if _property_type_button.is_pressed():
		type = AnimaUI.VISUAL_ANIMATION_TYPE.PROPERTY

	var data := {
		type = type
	}

	var as_group: ButtonGroup = _node_or_group_controls.get_child(0).group
	data.animate_as = as_group.get_pressed_button().get_index()

	if type == AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION:
		data.animation = {
			label = _animation_button.text,
			name = _animation_name
		}
	else:
		data.property = {
			name = _property_button.text,
			type = _property_type,
			relative = _relative_check.pressed,
			pivot = _pivot_button.get_value(),
			easing = _easing_button.get_meta('_value') if _easing_button.has_meta('_value') else null,
		}

		var from = _from_value.get_value()
		var to = _to_value.get_value()
		var initial_value = _initial_value.get_value()

		if from != null:
			data.property.from = from

		if to != null:
			data.property.to = to

		if initial_value != null:
			data.property.initial_value = _initial_value.get_value()

		if data.animate_as == 1:
			data.property.items_delay = _node_or_group.find_node("GroupItemsDelay").get_value()

			var animation_type: OptionButton = _node_or_group.find_node("GroupAnimationType")
			data.property.animation_type = animation_type.get_selected_id()

	AnimaUI.debug(self, "get_animation_data", data)
	return data

func restore_data(source_node: Node, data: Dictionary) -> void:
	if not data.has('type'):
		return

	_is_restoring_values = true

	if data.type == AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION:
		_animation_type_button.pressed = true
	else:
		_property_type_button.pressed = true

	AnimaUI.debug(self, 'restoring animation data', data, data.type)

	if data.has("animate_as"):
		var button_index: int = data.animate_as
		var button: Button = _node_or_group_controls.get_child(button_index)

		button.set_pressed(true)
		button.emit_signal("pressed")

	if data.type == AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION:
		_animation_button.text = data.animation.label
		_animation_name = data.animation.name

		AnimaUI.debug(self, "it's an animation")

		_is_restoring_values = false

		return

	_property_button.text = data.property.name
	_property_type = data.property.type

	if data.property.type == TYPE_VECTOR2 or data.property.type == TYPE_VECTOR3 or data.property.type == TYPE_RECT2:
		_from_value.set_type(data.property.type)
		_to_value.set_type(data.property.type)
		_initial_value.set_type(data.property.type)
	else:
		_from_value.set_type(TYPE_STRING)
		_to_value.set_type(TYPE_STRING)
		_initial_value.set_type(TYPE_STRING)

	if data.property.has('from'):
		_from_value.set_value(data.property.from)

	if data.property.has('to'):
		_to_value.set_value(data.property.to)

	if data.property.has('initial_value'):
		_initial_value.set_value(data.property.initial_value)

	if data.property.has("items_delay"):
		_node_or_group.find_node("GroupItemsDelay").set_value(str(data.property.items_delay))

	if data.property.has("animation_type"):
		var animation_type: OptionButton = _node_or_group.find_node("GroupAnimationType")
		var animation_type_index: int = data.property.animation_type

		for option_index in animation_type.get_item_count():
			if animation_type_index == animation_type.get_item_id(option_index):
				animation_type.select(option_index)

				break

	var current_value = AnimaNodesProperties.get_property_value(source_node, { property = data.property.name })

	_from_value.set_placeholder(current_value)
	_from_value.get_parent().get_child(_from_value.get_position_in_parent() - 1).hint_tooltip = "Current value: " + str(current_value)

	_to_value.set_placeholder(current_value)
	_to_value.get_parent().get_child(_to_value.get_position_in_parent() - 1).hint_tooltip = "Current value: " + str(current_value)

	_initial_value.set_placeholder(current_value)
	_initial_value.get_parent().get_child(_initial_value.get_position_in_parent() - 1).hint_tooltip = "Current value: " + str(current_value)

	if data.property.has("animate_as_node"):
		var as_group: ButtonGroup = _node_or_group_controls.get_child(0).group
		var buttons: Array = as_group.get_buttons()
		var button: Button = buttons[int(data.property.animate_as_node)]
		
		button.pressed = true
		_node_or_group.find_node("Carousel").set_index(button.get_index())

	_relative_check.pressed = data.property.relative
	_pivot_button.set_value(data.property.pivot)

	if data.property.easing != null:
		set_easing(data.property.easing)

	if _property_type_button.pressed:
		_on_PropertyTypeButton_pressed()

	AnimaUI.debug(self, 'restoring animation completed')

	_is_restoring_values = false

func set_animation_data(label: String, name: String) -> void:
	_animation_button.text = label
	_animation_name = name

func set_property_to_animate(source_node: Node, property: String, type: int) -> void:
	_property_button.text = property
	_property_type = type
	
	_previous_animation_type = -1

	var wrapper: Control = find_node('Wrapper')
	wrapper.margin_right = rect_size.x
	wrapper.rect_size.x = rect_size.x

	if type == TYPE_RECT2 or type == TYPE_VECTOR2 or type == TYPE_VECTOR3:
		_from_value.set_type(type)
		_to_value.set_type(type)
	else:
		_from_value.set_type(TYPE_STRING)
		_to_value.set_type(TYPE_STRING)

	var current_value = AnimaNodesProperties.get_property_value(source_node, { property = property })

	_from_value.set_placeholder(current_value)
	_to_value.set_placeholder(current_value)

	_on_PropertyTypeButton_pressed()

func set_easing(easing: int) -> void:
	var keys = Anima.EASING.keys()

	_easing_button.text = keys[easing].replace('_', ' ')
	_easing_button.set_meta('_value', easing)

func _maybe_find_fields() -> void:
	if is_inside_tree():
		return

	_animation_type_button = find_node('AnimationTypeButton')
	_property_type_button = find_node('PropertyTypeButton')
	_animation_button = find_node('AnimationButton')
	_animation_container = find_node('AnimationContainer')
	_property_container = find_node('PropertyContainer')
	_property_button = find_node('PropertyButton')
	_from_value = find_node('FromValue')
	_to_value = find_node('ToValue')
	_initial_value = find_node('InitialValue')
	_property_values = find_node('PropertyValues')
	_animation_type = find_node('AnimationType')
	_pivot_button = find_node('PivotButton')
	_easing_button = find_node('EasingButton')

	_ready()

func _on_PropertyButton_pressed():
	emit_signal("select_property")

func _on_AnimationButton_pressed():
	emit_signal("select_animation")

func _maybe_init_anima_node() -> void:
	if _anima_content_type != null:
		return

	_anima_content_type = Anima.begin(self)
	_anima_property_values = Anima.begin(_property_values)

	_anima_content_type.then(
		Anima.Node(_animation_container) \
			.anima_property("y") \
			.anima_from(0) \
			.anima_to(-20) \
			.anima_duration(0.3) \
			.anima_easing(Anima.EASING.EASE_IN_OUT_BACK)
	)
	_anima_content_type.also({
		property = "opacity",
		from = 1,
		to = 0
	})
	_anima_content_type.with(
		Anima.Node(_property_container) \
			.anima_property("y") \
			.anima_from(20) \
			.anima_to(0) \
			.anima_duration(0.3) \
			.anima_easing(Anima.EASING.EASE_IN_OUT_BACK) \
			.anima_on_started(funcref(self, '_adjust_height'), [true], [false])
	)
	_anima_content_type.also({
		property = "opacity",
		from = 0,
		to = 1
	})

	_anima_property_values.then(
		Anima.Group(
			[
				{ node = _property_values.find_node('Label1') },
				{ group = _property_values.find_node('AnimateGrid') },
				{ node = _property_values.find_node('Label2') },
				{ group = _property_values.find_node('Easing') },
			]
		) \
			.anima_duration(0.15) \
			.anima_items_delay(0.015) \
			.anima_animation({
				0: {
					opacity = 0,
					x = -20,
				}, 
				100: {
					opacity = 1,
					x = 0
				},
				initial_values = {
					opacity = 0,
				}
			})
	)

func _adjust_height(pivot_size: float = -1.0) -> void:
	if _property_values == null:
		_property_values = find_node("PropertyValues")

	var calculate_property_values_height = _property_values.has_meta("_will_be_visible") and _property_values.get_meta("_will_be_visible")
	var new_size := 0 # _animation_container.rect_size.y
	
	var pivot_button: Control = find_node('PivotButton')
	var pivot_height: float = max(0, pivot_button.rect_size.y - 32)

	if calculate_property_values_height and _property_type != 0:
		new_size = 20.0 * AnimaUI.get_dpi_scale()

		for child in _property_values.get_children():
			if child is Control:
				new_size += child.rect_size.y

	if pivot_size >= 0.0:
		new_size -= pivot_height

	if _node_or_group == null:
		_node_or_group = find_node("NodeOrGroup")

	new_size += _node_or_group.find_node("Carousel").get_expected_wrapper_height()

	emit_signal("content_size_changed", new_size + pivot_size)

func _on_FromValue_vale_updated():
	_on_vale_updated()

func _on_ToValue_vale_updated():
	_on_vale_updated()

func _on_CheckBox_pressed():
	_on_vale_updated()

func _on_AnimationTypeButton_pressed():
	if _previous_animation_type == AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION:
		return

	_previous_animation_type = AnimaUI.VISUAL_ANIMATION_TYPE.ANIMATION

	_animate_content_type(AnimaTween.PLAY_MODE.NORMAL, true)

func _on_PropertyTypeButton_pressed():
	if _previous_animation_type == AnimaUI.VISUAL_ANIMATION_TYPE.PROPERTY:
		return

	_previous_animation_type = AnimaUI.VISUAL_ANIMATION_TYPE.PROPERTY

	_animate_content_type(AnimaTween.PLAY_MODE.BACKWARDS, false)

func _animate_content_type(direction: int, animation_container_visible) -> void:
	_maybe_init_anima_node()

	_animation_container.visible = true
	_property_container.visible = true
	_property_values.set_meta("_will_be_visible", direction != AnimaTween.PLAY_MODE.NORMAL)

	if direction == AnimaTween.PLAY_MODE.NORMAL:
		_anima_content_type.play_backwards()

		if _property_values.get_child(0).modulate.a > 0:
			_anima_property_values.play_backwards_with_speed(1.3)
			
			yield(_anima_property_values, "animation_completed")
	else:
		_anima_content_type.play()

		if _property_type != 0:
			_anima_property_values.play()

	yield(_anima_content_type, "animation_completed")

	_animation_container.visible = animation_container_visible
	_property_container.visible = not _animation_container.visible

func _on_PivotButton_pivot_height_changed(new_size):
	_on_vale_updated()

	_adjust_height(new_size)

func _on_PivotButton_pivot_point_selected():
	_on_vale_updated()

func _on_EasingButton_pressed():
	emit_signal("select_easing")

func _on_FromValue_select_relative_property():
	emit_signal("select_relative_property", _from_value)

func _on_ToValue_select_relative_property():
	emit_signal("select_relative_property", _to_value)

func _on_AsNode_pressed():
	emit_signal("animate_as_changed", true)

	_on_vale_updated()

func _on_AsGroup_pressed():
	emit_signal("animate_as_changed", false)

	_on_vale_updated()

func _on_Carousel_carousel_height_changed(final_height):
	_adjust_height()

func _on_PropertyValues_item_rect_changed():
	$Timer.stop()
	$Timer.start()

func _on_Timer_timeout():
	_adjust_height()

func _on_InitialValue_select_relative_property():
	emit_signal("select_relative_property", _initial_value)

func _on_vale_updated():
	if not _is_restoring_values:
		emit_signal("value_updated")

func _on_GroupAnimationType_item_selected(index):
	_on_vale_updated()
