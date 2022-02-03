extends Object
class_name AnimaPropertyList

var _properties := {}
var _initial_valus := {}

func add(name, type, default_value) -> void:
	_properties[name] = {
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
		"name": name,
		"type": type,
		"value": default_value,
		"initialValue": null
	}

func get(name: String):
	return _properties[name].value

func set(name: String, value) -> void:
	if exists(name):
		_properties[name].value = value
		_properties[name].initialValue = value
		
func exists(name: String) -> bool:
	return _properties.has(name)

func get_property_list() -> Array:
	return _properties.values()

func is_initial_value(name: String, value) -> bool:
	return _properties[name].initialValue == null
