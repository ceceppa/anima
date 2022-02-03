extends Object

var properties := {}

func add(name, type, default_value) -> void:
	properties[name] = {
		"hint": PROPERTY_HINT_NONE,
		"usage": PROPERTY_USAGE_DEFAULT,
		"name": name,
		"type": type,
		"value": default_value 
	}

func get(name):
	if properties.has(name):
		return properties[name].value

	return null

func set(name, value) -> void:
	if properties.has(name):
		properties[name].value = value

func get_property_list() -> Array:
	return properties.values()

func _init(list) -> void:
	for prop in list:
		add(prop[0], prop[1], prop[2])
