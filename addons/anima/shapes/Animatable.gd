tool
extends Control
class_name AnimaAnimatable

export (bool) var animate_property_change := true
export (float) var animation_speed := 0.15
export (Anima.EASING) var easing = Anima.EASING.LINEAR

var _property_list := AnimaPropertyList.new()
var _is_animating_property_change := false

func _add_properties(properties: Dictionary) -> void:
	for key in properties:
		var property: Dictionary = properties[key]
	
		_property_list.add(property.name, property.type, property.default)

func _get(property: String):
	if _property_list.exists(property):
		return _property_list.get(property)

	return

func _set(property: String, value):
	if not _property_list.exists(property):
		return

	var old_value = _property_list.get(property)

	_property_list.set(property, value)

	var has_value_changed = old_value != value

	if value is bool or value is String:
		return update()

	if not _property_list.exists(property) or \
		not is_inside_tree() or \
		not has_value_changed:
			return

	if _is_animating_property_change or not animate_property_change:
		update()
	else:
		var from = old_value if Engine.editor_hint else null

		set_with_animation(property, value, from)

func set(name: String, value) -> void:
	var old_value = animate_property_change

	animate_property_change = false
	.set(name, value)

	animate_property_change = old_value

func set_with_animation(property: String, value, from = null) -> void:
	var animation := Anima.Node(self)

	animation.anima_property(property)

	if from:
		animation.anima_from(from)

	animation.anima_to(value)
	animation.anima_duration(animation_speed)
	animation.anima_easing(easing)
	animation.debug()

	_is_animating_property_change = true

	yield(animate(animation), "animation_completed")
	
	_is_animating_property_change = false

func _get_property_list() -> Array:
	if _property_list:
		return _property_list.get_property_list()

	return []

func get_property(name: String):
	return _get(name)

func animate(anima_data: AnimaDeclarationBase, auto_play := true) -> AnimaNode:
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.then(anima_data)

	if auto_play:
		anima.play()

	return anima

func set_position(position: Vector2, default := false):
	set_with_animation("position", position)
