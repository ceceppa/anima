tool
extends AnimaRectangle

export var label := "Anima Button" setget set_label

var _is_focused := false

const BUTTON_BASE_PROPERTIES := {
	# Normal
	NORMAL_FILL_COLOR = {
		name = "Normal/FillColor",
		type = TYPE_COLOR,
		default = Color("314569")
	},

	# Hovered
	HOVERED_USE_STYLE = {
		name = "Hovered/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Pressed,Focused",
		default = ""
	},
	HOVERED_FILL_COLOR = {
		name = "Hovered/FillColor",
		type = TYPE_COLOR,
		default = Color("628ad1")
	},

	# Pressed
	PRESSED_USE_STYLE = {
		name = "Pressed/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Pressed,Focused",
		default = ""
	},
	PRESSED_FILL_COLOR = {
		name = "Pressed/FillColor",
		type = TYPE_COLOR,
		default = Color("428ad1")
	},

	# Focused
	FOCUSED_USE_STYLE = {
		name = "Focused/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Pressed,Focused",
		default = ""
	},
	FOCUSED_FILL_COLOR = {
		name = "Focused/FillColor",
		type = TYPE_COLOR,
		default = Color("428ad1")
	},
}

var _all_properties := BUTTON_BASE_PROPERTIES

func _init():
	._init()

	var extra_keys = ["Normal", "Hovered", "Focused", "Pressed"]

	for key in PROPERTIES:
		for extra_key_index in extra_keys.size():
			var extra_key: String = extra_keys[extra_key_index]
			var new_key = key.replace("RECTANGLE", extra_key.to_upper())

			if BUTTON_BASE_PROPERTIES.has(new_key):
				continue

			var new_value = PROPERTIES[key].duplicate()

			if extra_key_index > 0:
				if new_value.default is float:
					new_value.default = -1
				elif new_value.default is Vector2:
					new_value.default = Vector2(-1, -1)
				elif new_value.default is Rect2:
					new_value.default = Rect2(-1, -1, -1, -1)

			new_value.name = new_value.name.replace("Rectangle/", extra_key + "/")

			_all_properties[new_key] = new_value

	# We don't want to expose the Rectangulare properties as they're only used "internally"
	_hide_properties(PROPERTIES)

	_add_properties(_all_properties)
	
	_copy_properties("Normal")

func _copy_properties(from: String) -> void:
	var copy_from_key = from.to_upper()

	for key in _all_properties:
		if key.find(copy_from_key) == 0:
			var property_name: String = _all_properties[key].name
			var rectangle_property_name: String = property_name.replace(from + "/", "Rectangle/")
			var value = get_property(property_name)

			_property_list.set(rectangle_property_name, value)

func _animate_state(root_key: String) -> void:
	var override_key = get_property(root_key + "/UseSameStyleOf")

	if override_key:
		root_key = override_key

	var from: String = root_key.to_upper()
	var params_to_animate := []

	for key in _all_properties:
		if key.find(from) == 0:
			var property_name: String = _all_properties[key].name
			var rectangle_property_name: String = property_name.replace(root_key + "/", "Rectangle/")
			var current_value = get_property(rectangle_property_name)
			var final_value = get_property(property_name)

			if final_value is String or final_value is bool:
				continue

			if current_value != final_value:
				params_to_animate.push_back({ property = rectangle_property_name, to = final_value })

	if params_to_animate.size() > 0:
		animate_params(params_to_animate)

func set_label(label: String) -> void:
	find_node("Label").text = label

func _on_mouse_entered():
	if not _is_focused:
		_animate_state("Hovered")

func _on_mouse_exited():
	if not _is_focused:
		_animate_state("Normal")

func _on_mouse_down():
	if not _is_focused:
		_animate_state("Pressed")

func _on_AnimaButton_focus_entered():
	_animate_state("Focused")
	_is_focused = true

func _on_AnimaButton_focus_exited():
	_animate_state("Normal")

	_is_focused = false
