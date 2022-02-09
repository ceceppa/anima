tool
extends AnimaRectangle
class_name AnimaButton, "res://addons/anima/icons/button.svg"

enum Align {LEFT, CENTER, RIGHT, FILL}
enum Valign {TOP, CENTER, BOTTOM, FILL}

export var label := "Anima Button" setget set_label
export (Align) var align := Align.LEFT setget set_align
export (Valign) var valign := Valign.TOP setget set_valign

var _label := Label.new()

var _is_focused := false

const STATE := {
	NORMAL = "Normal",
	HOVERED = "Hovered",
	FOCUSED = "Focused",
	PRESSED = "Pressed"
}

const BUTTON_BASE_PROPERTIES := {
	# Button
	BUTTON_LABEL = {
		name = "Button/Label",
		type = TYPE_STRING,
		default = "Anima Button"
	},
	BUTTON_ALIGN = {
		name = "Button/Align",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Left,Center,Right,Fill",
		default = ""
	},
	BUTTON_VALIGN = {
		name = "Button/VAlign",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Left,Center,Right,Fill",
		default = 0
	},
	BUTTON_FONT = {
		name = "Button/Font",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_tooltip = "Font",
		default = 0
	},
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

	_label.size_flags_horizontal = SIZE_EXPAND_FILL
	_label.size_flags_vertical = SIZE_EXPAND_FILL
	_label.anchor_right = 1
	_label.anchor_bottom = 1

	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("mouse_down", self, "_on_mouse_down")

	add_child(_label)

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

			if final_value is String or final_value is bool or str(final_value).find("-1") >= 0:
				continue

			if current_value != final_value:
				params_to_animate.push_back({ property = rectangle_property_name, to = final_value })

	if params_to_animate.size() > 0:
		animate_params(params_to_animate)

func refresh(state: String, ignore_if_focused := true) -> void:
	if _is_focused and ignore_if_focused:
		state = STATE.FOCUSED

	_animate_state(state)

func set_label(new_label: String) -> void:
	label = new_label
	_label.text = label

func set_align(new_align: int) -> void:
	align = new_align
	_label.align = align

func set_valign(new_valign: int) -> void:
	valign = new_valign
	_label.valign = valign

func _on_mouse_entered():
	refresh(STATE.HOVERED)

func _on_mouse_exited():
	refresh(STATE.NORMAL)

func _on_mouse_down():
	refresh(STATE.PRESSED, false)

func _on_focus_entered():
	refresh(STATE.FOCUSED)
	_is_focused = true

func _on_focus_exited():
	_is_focused = false
	
	refresh(STATE.NORMAL)
