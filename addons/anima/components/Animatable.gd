tool
extends Control
class_name AnimaAnimatable

const BASE_PROPERTIES := {
	ANIMATE_PROPERTY_CHANGE = {
		name = "Animation/AnimatePropertyChange",
		type = TYPE_BOOL,
		default = true
	},
	ANIMATION_SPEED = {
		name = "Animation/Speed",
		type = TYPE_REAL,
		default = 0.3
	},
	ANIMATION_EASING = {
		name = "Animation/Easing",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = AnimaEasing.EASING,
		default = Anima.EASING.LINEAR
	},
}

var _property_list := AnimaPropertyList.new()
var _is_animating_property_change := false
var _old_animate_property_change: bool

func _init():
	_add_properties(BASE_PROPERTIES)

func _add_properties(properties: Dictionary) -> void:
	for key in properties:
		_property_list.add(properties[key])

func _add_property(name: String, value: Dictionary) -> void:
	value.name = name

	_property_list.add(value)

func _property_exists(name: String) -> bool:
	return _property_list.exists(name)

func _hide_properties(properties: Dictionary) -> void:
	for key in properties:
		_property_list.hide(properties[key].name)

func _get(property: String):
	return _property_list.get(property)

func _set(property: String, value):
	if not _property_list.exists(property):
		return

	var old_value = _property_list.get(property)
	var is_animatable = _property_list.is_animatable(property)

	_property_list.set(property, value)

	if value is bool or value is String or value is Resource or not is_animatable:
		return update()

	var has_value_changed = old_value != value

	if not is_inside_tree() or \
		not has_value_changed:
			return

	var animate_property_change = get_property(BASE_PROPERTIES.ANIMATE_PROPERTY_CHANGE.name)

	if _is_animating_property_change or not animate_property_change:
		update()
	else:
		var from = old_value if Engine.editor_hint else null

		animate_param(property, value, from)

func prevent_animate_property_change() -> void:
	_old_animate_property_change = get_property(BASE_PROPERTIES.ANIMATE_PROPERTY_CHANGE.name)

	_property_list.set(BASE_PROPERTIES.ANIMATE_PROPERTY_CHANGE.name, false)

func restore_animate_property_change() -> void:
	if not _old_animate_property_change:
		return

	_property_list.set(BASE_PROPERTIES.ANIMATE_PROPERTY_CHANGE.name, _old_animate_property_change)

func set(name: String, value) -> void:
	prevent_animate_property_change()

	.set(name, value)

	restore_animate_property_change()

func _get_property_list() -> Array:
	if _property_list:
		return _property_list.get_property_list()

	return []

func get_property(name: String):
	return _get(name)

func get_property_initial_value(key: String):
	return _property_list.get_initial_value(key)

func animate_param(property: String, value, from = null) -> void:
	animate_params([{ property = property, to = value, from = from }])

func animate_params(params: Array) -> void:
	var animations := []
	var easing: int = get_property(BASE_PROPERTIES.ANIMATION_EASING.name)
	var duration: float = get_property(BASE_PROPERTIES.ANIMATION_SPEED.name)

	for param in params:
		var animation := Anima.Node(self).anima_property(param.property, param.to, duration)

		if param.has("from"):
			animation.anima_from(param.from)

		animation.anima_easing(easing)
		animations.push_back(animation)

	_animate(animations)

func _animate(anima_data: Array) -> AnimaNode:
	var anima: AnimaNode = Anima.begin_single_shot(self)

	for data in anima_data:
		anima.with(data)

	_is_animating_property_change = true

	anima.play()
	yield(anima, "animation_completed")

	_is_animating_property_change = false

	return anima

func set_position(position: Vector2, default := false) -> void:
	animate_param("position", position)

func set_size(size: Vector2, default := false) -> void:
	animate_param("size", size)

func set_scale(scale: Vector2, default := false) -> void:
	animate_param("scale", scale)

func should_animate_property_change() -> bool:
	return get_property(BASE_PROPERTIES.ANIMATE_PROPERTY_CHANGE.name)

func get_easing() -> int:
	return get_property(BASE_PROPERTIES.ANIMATION_EASING.name)

func get_duration() -> int:
	return get_property(BASE_PROPERTIES.ANIMATION_SPEED.name)
