tool
extends AnimaAnimatable

const COLLAPSED_VALUE := "./Wrapper/Title:size:y" 
const EXPANDED_VALUE := "./Wrapper/Title:size:y + ./Wrapper/ContentWrapper/MarginContainer:size:y"

export var label := "Accordion" setget set_label
export var expanded := true setget set_expanded

onready var _title: AnimaButton = find_node("Title")

const RECTANGLE_PROPERTIES := {
	RECTANGLE_SIZE = {
		name = "Rectangle/Size",
		type = TYPE_RECT2,
		default = Rect2(Vector2.ZERO, Vector2(100, 100))
	},
	RECTANGLE_FILL_COLOR = {
		name = "Rectangle/FillColor",
		type = TYPE_COLOR,
		default = Color("314569"),
	},
	RECTANGLE_BORDER_WIDTH_LEFT = {
		name = "Rectangle/BorderWidh/Left",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_BORDER_WIDTH_TOP = {
		name = "Rectangle/BorderWidh/Top",
		type = TYPE_INT, 
		default = 0
	},
	RECTANGLE_BORDER_WIDTH_RIGHT = {
		name = "Rectangle/BorderWidh/Right",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_BORDER_WIDTH_BOTTOM = {
		name = "Rectangle/BorderWidh/Bottom",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_BORDER_COLOR = {
		name = "Rectangle/Border/Color",
		type = TYPE_COLOR,
		default = Color.transparent,
	},
	RECTANGLE_BORDER_BLEND = {
		name = "Rectangle/Border/Blend",
		type = TYPE_BOOL,
		default = false,
	},
	RECTANGLE_BORDER_OFFSET = {
		name = "Rectangle/Border/Offset",
		type = TYPE_VECTOR2,
		default = Vector2(0, 0)
	},
	RECTANGLE_CORNER_RADIUS_TOP_LEFT = {
		name = "Rectangle/CornerRadius/TopLeft",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_CORNER_RADIUS_TOP_RIGHT = {
		name ="Rectangle/CornerRadius/TopRight",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_CORNER_RADIUS_BOTTOM_RIGHT = {
		name = "Rectangle/CornerRadius/BottomRight",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_CORNER_RADIUS_BOTTOM_LEFT = {
		name = "Rectangle/CornerRadius/BottomLeft",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_SHADOW_COLOR = {
		name = "Rectangle/Shadow/Color",
		type = TYPE_COLOR,
		default = Color.transparent,
	},
	RECTANGLE_SHADOW_SIZE = {
		name = "Rectangle/Shadow/Size",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_SHADOW_OFFSET = {
		name = "Rectangle/Shadow/Offset",
		type = TYPE_VECTOR2,
		default = Vector2(0, 0),
	}
}

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

const CUSTOM_PROPERTIES := {
		# Animation
	ANIMATION_NAME = {
		name = "Animation/Name",
		type = TYPE_STRING,
		default = "fadeIn"
	},
}

var _all_properties := BUTTON_BASE_PROPERTIES
var _is_ready := false

func _enter_tree():
	set_expanded(expanded, false)

func _init():
	._init()

	var extra_keys = ["Normal", "Hovered", "Focused", "Pressed"]

	for key in RECTANGLE_PROPERTIES:
		for extra_key_index in extra_keys.size():
			var extra_key: String = extra_keys[extra_key_index]
			var new_key = key.replace("RECTANGLE", extra_key.to_upper())

			if BUTTON_BASE_PROPERTIES.has(new_key):
				continue

			var new_value = RECTANGLE_PROPERTIES[key].duplicate()

			if extra_key_index > 0:
				if new_value.default is float:
					new_value.default = -1
				elif new_value.default is Vector2:
					new_value.default = Vector2(-1, -1)
				elif new_value.default is Rect2:
					new_value.default = Rect2(-1, -1, -1, -1)

			new_value.name = new_value.name.replace("Rectangle/", extra_key + "/")

			_all_properties[new_key] = new_value

	_add_properties(CUSTOM_PROPERTIES)
	_add_properties(_all_properties)

func _ready():
	set_expanded(expanded)
	set_label(label)

	_is_ready = true

func set_expanded(is_expanded: bool, animate := true) -> void:
	expanded = is_expanded

	if get_child_count() == 0 or not is_inside_tree():
		return

	if _is_ready and animate and should_animate_property_change():
		_animate_height_change()

		return

	var value: String = EXPANDED_VALUE if is_expanded else COLLAPSED_VALUE
	var y: float = AnimaTweenUtils.maybe_calculate_value(value, { node = self, property = "min_size:y" })

	rect_min_size.y = y
	rect_size.y = y

func _set(property, value):
	._set(property, value)

	if _title and property == "label":
		_title.set(property, value)
		_title._on_mouse_exited()

func _animate_height_change() -> void:
	var anima: AnimaNode = Anima.begin_single_shot(self)
	var easing: int = get_easing()

	anima.set_default_duration(get_duration())

	anima.then(
		Anima.Node(self) \
			.anima_property("min_size:y", EXPANDED_VALUE) \
			.anima_from(COLLAPSED_VALUE) \
			.anima_easing(easing)
	)
	anima.with(
		Anima.Node(self) \
			.anima_property("size:y", EXPANDED_VALUE) \
			.anima_from(COLLAPSED_VALUE) \
			.anima_easing(easing)
	)

	anima.with(
		Anima.Node($Wrapper/ContentWrapper/MarginContainer/Content) \
			.anima_animation(get_property(CUSTOM_PROPERTIES.ANIMATION_NAME.name), true) \
			.anima_easing(easing) \
			.anima_pivot(Anima.PIVOT.CENTER) \
	)
	anima.with(
		Anima.Node($Wrapper/Title/Icon) \
			.anima_property("rotate", 0) \
			.anima_from(-90) \
			.anima_pivot(Anima.PIVOT.CENTER) \
			.anima_easing(easing)
	)

	if expanded:
		anima.play()
	else:
		anima.play_backwards_with_speed(1.5)

func set_label(new_label: String) -> void:
	label = new_label

	if get_child_count() == 0:
		return

	if _title == null:
		_title = find_node("Title")

	_title.set(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_LABEL.name, new_label)

func _on_Title_pressed():
	set_expanded(!expanded)
