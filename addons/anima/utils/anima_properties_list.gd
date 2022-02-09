extends Object
class_name AnimaPropertyList

var _properties := {}
var _initial_valus := {}

func add(property: Dictionary) -> void:
	_properties[property.name] = {
		"hint": property.hint if property.has("hint") else PROPERTY_HINT_NONE,
		"hint_string": property.hint_string if property.has("hint_string") else null,
		"usage": PROPERTY_USAGE_DEFAULT,
		"name": property.name,
		"type": property.type,
		"value": property.default,
		"initialValue": property.default,
		"visible": true,
		"animatable": property.animatable if property.has("animatable") else true
	}

func add_properties(properties: Dictionary) -> void:
	for property in properties:
		add(property)

func hide(name: String) -> void:
	_properties[name].visible = false

func get(name: String):
	if _properties.has(name):
		return _properties[name].value

	return null
	
func set(name: String, value) -> void:
	_properties[name].value = value

func exists(name: String) -> bool:
	return _properties.has(name)

func is_animatable(name: String) -> bool:
	return _properties[name].animatable

func get_property_list() -> Array:
	var list: Array
	
	for property in _properties.values():
		if property.has("type") and property.visible:
			list.push_back(property)
	
	return list

func get_initial_value(name: String):
	return _properties[name].initialValue
