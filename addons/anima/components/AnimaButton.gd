tool
extends AnimaRectangle
class_name AnimaButton, "res://addons/anima/icons/button.svg"

signal button_down
signal button_up
signal toggled(button_pressed)

enum STATE {
	NORMAL,
	HOVERED,
	FOCUSED,
	PRESSED
}

const STATES := {
	STATE.NORMAL: "Normal",
	STATE.HOVERED: "Hovered",
	STATE.FOCUSED: "Focused",
	STATE.PRESSED: "Pressed"
}

export (STATE) var _test_state = STATE.NORMAL setget _set_test_state

const BUTTON_BASE_PROPERTIES := {
	# Button
	BUTTON_LABEL = {
		name = "Button/Text",
		type = TYPE_STRING,
		default = "Anima Button",
		animatable = false
	},
	BUTTON_ICON = {
		name = "Button/ICON",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Texture",
		default = null,
		animatable = false
	},
	BUTTON_ALIGN = {
		name = "Button/Align",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Left,Center,Right",
		default = 1,
		animatable = false
	},
	BUTTON_FONT = {
		name = "Button/Font",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "Font",
		default = null,
		animatable = false
	},
	BUTTON_DISABLED = {
		name = "Button/Disabled",
		type = TYPE_BOOL,
		default = false,
	},
	BUTTON_TOGGLE_MODE = {
		name = "Button/ToggleMode",
		type = TYPE_BOOL,
		default = false,
	},
	BUTTON_SHORTCUT_IN_TOOLTIP = {
		name = "Button/ShortcutInTooltip",
		type = TYPE_BOOL,
		default = true,
	},
	BUTTON_PRESSED = {
		name = "Button/Pressed",
		type = TYPE_BOOL,
		default = false,
	},
	BUTTON_CONTENT_MARGIN = {
		name = "Button/ContentMargin",
		type = TYPE_INT,
		default = 12,
	},
	BUTTON_GROUP = {
		name = "Button/Group",
		type = TYPE_OBJECT,
		hint = PROPERTY_HINT_RESOURCE_TYPE,
		hint_string = "ButtonGroup",
		default = null
	},

	# Normal
	NORMAL_FILL_COLOR = {
		name = "Normal/FillColor",
		type = TYPE_COLOR,
		default = Color("314569")
	},
	NORMAL_FONT_COLOR = {
		name = "Normal/FontColor",
		type = TYPE_COLOR,
		default = Color("fff")
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
	HOVERED_FONT_COLOR = {
		name = "Hovered/FontColor",
		type = TYPE_COLOR,
		default = Color.transparent
	},
	HOVERED_SCALE = {
		name = "Hovered/Scale",
		type = TYPE_VECTOR2,
		default = Vector2.ONE,
	},

	# Pressed
	PRESSED_USE_STYLE = {
		name = "Pressed/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Hovered,Focused",
		default = ""
	},
	PRESSED_FILL_COLOR = {
		name = "Pressed/FillColor",
		type = TYPE_COLOR,
		default = Color("428ad1")
	},
	PRESSED_FONT_COLOR = {
		name = "Pressed/FontColor",
		type = TYPE_COLOR,
		default = Color.transparent
	},

	# Focused
	FOCUSED_USE_STYLE = {
		name = "Focused/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Hovered,Pressed",
		default = ""
	},
	FOCUSED_FILL_COLOR = {
		name = "Focused/FillColor",
		type = TYPE_COLOR,
		default = Color("428ad1")
	},
	FOCUSED_FONT_COLOR = {
		name = "Focused/FontColor",
		type = TYPE_COLOR,
		default = Color.transparent
	},
}

var _all_properties := BUTTON_BASE_PROPERTIES
var _button := Button.new()

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
				if new_value.default is float or new_value.default is int:
					new_value.default = -1
				elif new_value.default is Vector2:
					new_value.default = Vector2(-1, -1)
				elif new_value.default is Rect2:
					new_value.default = Rect2(-1, -1, -1, -1)
				elif new_value.default is Color:
					new_value.default = Color.transparent
					new_value.default.a = 0.00

			new_value.name = new_value.name.replace("Rectangle/", extra_key + "/")

			_all_properties[new_key] = new_value

	# We don't want to expose the Rectangulare properties as they're only used "internally"
	_hide_properties(PROPERTIES)

	_add_properties(_all_properties)

	_copy_properties("Normal")

	_test_state = STATE.NORMAL
	
	_init_button()

func _ready():
	_set(BUTTON_BASE_PROPERTIES.BUTTON_LABEL.name, get_property(BUTTON_BASE_PROPERTIES.BUTTON_LABEL.name))
	_set(BUTTON_BASE_PROPERTIES.BUTTON_ALIGN.name, get_property(BUTTON_BASE_PROPERTIES.BUTTON_ALIGN.name))
	_set(BUTTON_BASE_PROPERTIES.BUTTON_FONT.name, get_property(BUTTON_BASE_PROPERTIES.BUTTON_FONT.name))
	_set(BUTTON_BASE_PROPERTIES.BUTTON_TOGGLE_MODE.name, get_property(BUTTON_BASE_PROPERTIES.BUTTON_TOGGLE_MODE.name))

	_copy_properties("Normal")
	
	connect("item_rect_changed", self, "_on_resize_me")

func _init_button() -> void:
	var style := StyleBoxEmpty.new()

	for s in ["normal", "hover", "pressed", "disabled", "focus"]:
		_button.add_stylebox_override(s, style)

	for c in ["font_color_disabled", "font_color_focus", "font_color", "font_color_hover", "font_color_pressed"]:
		_button.add_color_override(c, Color.white)

	_button.connect("focus_entered", self, "_on_focus_entered")
	_button.connect("focus_exited", self, "_on_focus_exited")
	_button.connect("mouse_entered", self, "_on_mouse_entered")
	_button.connect("mouse_exited", self, "_on_mouse_exited")
	_button.connect("button_down", self, "_on_mouse_down")
	_button.connect("pressed", self, "_on_pressed")

	add_child(_button)

	_on_resize_me()

func _copy_properties(from: String) -> void:
	var copy_from_key = from.to_upper()

	for key in _all_properties:
		if key.find(copy_from_key) == 0:
			var property_name: String = _all_properties[key].name
			var rectangle_property_name: String = property_name.replace(from + "/", "Rectangle/")
			var value = get_property(property_name)

			if _property_exists(rectangle_property_name):
				_property_list.set(rectangle_property_name, value)
			elif property_name.find("/FontColor") > 0:
				_button.add_color_override("font_color", value)

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

			if final_value is String \
				or final_value is bool \
				or str(final_value).find("-1") >= 0 \
				or (final_value is Color and final_value.a == 0):
				continue

			if current_value != final_value:
				params_to_animate.push_back({ property = rectangle_property_name, to = final_value })

	if root_key == "Normal" and rect_scale != Vector2.ONE:
		params_to_animate.push_back({ property = "scale", to = Vector2.ONE })

	if params_to_animate.size() > 0:
		animate_params(params_to_animate)

func refresh(state: int, ignore_if_focused := true) -> void:
	if _button.has_focus() and ignore_if_focused:
		state = STATE.FOCUSED

	if _button.toggle_mode and _button.pressed:
		state = STATE.PRESSED

	if _button.disabled:
		state = STATE.NORMAL

	_animate_state(STATES[state])

func _set(property: String, value) -> void:
	if Engine.editor_hint and property.find("Rectangle/") < 0:
		prevent_animate_property_change()

	._set(property, value)

	if property.find("Button/") == 0:
		if property == BUTTON_BASE_PROPERTIES.BUTTON_CONTENT_MARGIN.name:
			var style: StyleBoxEmpty = _button.get_stylebox("normal")
			
			style.content_margin_bottom = value
			style.content_margin_top = value
			style.content_margin_left = value
			style.content_margin_right = value

			_on_resize_me()
		else:
			var p: String = property.replace("Button/", "").capitalize().replace(" ", "_").to_lower()
			_button.set(p.replace(" ", "_").to_lower(), value)
	elif property.find("FontColor") > 0:
		_button.add_color_override("font_color", value)
	elif property == "Rectangle/Scale":
		rect_scale = value

	restore_animate_property_change()

	if Engine.editor_hint and property.find(STATES[_test_state]) >= 0 and is_inside_tree():
		_animate_state(STATES[_test_state])

func get(property):
	if property.find("FontColor") >= 0:
		var color = _button.get_color("font_color")

		return color
	elif property.find("/Scale") > 0:
		return Vector2.ONE

	return .get(property)

func set_label(label: String) -> void:
	set(BUTTON_BASE_PROPERTIES.BUTTON_LABEL.name, label)

func get_label() -> String:
	return get(BUTTON_BASE_PROPERTIES.BUTTON_LABEL.name)

func set_icon(icon: Texture) -> void:
	set(BUTTON_BASE_PROPERTIES.BUTTON_ICON.name, icon)

func _on_mouse_entered():
	refresh(STATE.HOVERED)

func _on_mouse_exited():
	refresh(STATE.NORMAL)

func _on_mouse_down():
	refresh(STATE.PRESSED, false)

func _on_focus_entered():
	refresh(STATE.FOCUSED)

func _on_focus_exited():
	refresh(STATE.NORMAL)

func _on_pressed() -> void:
	refresh(STATE.PRESSED)

	emit_signal("pressed")

func _set_test_state(new_state) -> void:
	if Engine.editor_hint:
		_test_state = new_state
		_animate_state(STATES[new_state])

func _on_resize_me() -> void:
	_button.rect_size = rect_size

	if rect_size < _button.rect_size:
		rect_size = _button.rect_size
