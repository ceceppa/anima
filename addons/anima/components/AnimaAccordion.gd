tool
extends AnimaAnimatable
class_name AnimaAccordion

export var label := "Accordion" setget set_label
export (Font) var font setget set_font
export var expanded := true setget set_expanded

var _title: AnimaButton
var _wrapper: VBoxContainer
var _icon: Sprite
var _content_control: Control

const BUTTON_BASE_PROPERTIES := {
	# Normal
	NORMAL_FILL_COLOR = {
		name = "ButtonNormal/FillColor",
		type = TYPE_COLOR,
		default = Color("314569")
	},

	# Hovered
	HOVERED_USE_STYLE = {
		name = "ButtonHovered/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Pressed,Focused",
		default = ""
	},
	HOVERED_FILL_COLOR = {
		name = "ButtonHovered/FillColor",
		type = TYPE_COLOR,
		default = Color("628ad1")
	},

	# Pressed
	PRESSED_USE_STYLE = {
		name = "ButtonPressed/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Pressed,Focused",
		default = ""
	},
	PRESSED_FILL_COLOR = {
		name = "ButtonPressed/FillColor",
		type = TYPE_COLOR,
		default = Color("428ad1")
	},

	# Focused
	FOCUSED_USE_STYLE = {
		name = "ButtonFocused/UseSameStyleOf",
		type = TYPE_STRING,
		hint = PROPERTY_HINT_ENUM,
		hint_string = ",Normal,Pressed,Focused",
		default = ""
	},
	FOCUSED_FILL_COLOR = {
		name = "ButtonFocused/FillColor",
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
	# Panel
	PANEL_FILL_COLOR = {
		name = "Panel/FillColor",
		type = TYPE_COLOR,
		default = Color("1b212e")
	}
}

var _all_properties := BUTTON_BASE_PROPERTIES
var _is_ready := false

func _enter_tree():
	set_expanded(expanded, false)

func _init():
	._init()

	_init_layout()

	var extra_keys = ["ButtonNormal", "ButtonHovered", "ButtonFocused", "ButtonPressed"]

	for key in AnimaRectangle.PROPERTIES:
		for extra_key_index in extra_keys.size():
			var extra_key: String = extra_keys[extra_key_index]
			var new_key = key.replace("RECTANGLE", extra_key.to_upper())

			if BUTTON_BASE_PROPERTIES.has(new_key):
				continue

			var new_value = AnimaRectangle.PROPERTIES[key].duplicate()

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
	rect_clip_content = true

func _ready():
	_content_control = get_child(1)

	set_expanded(expanded)
	set_label(label)

	_is_ready = true

func _draw():
	draw_rect(Rect2(Vector2(0, 0), rect_size), get_property(CUSTOM_PROPERTIES.PANEL_FILL_COLOR.name), true)

func _get_configuration_warning():
	if get_child_count() != 2:
		if _content_control:
			_on_content_control_removed()

		return "You must add 1 child component"

	_content_control = get_child(1)
	_on_content_control_added()

	return ""

func _init_layout() -> void:
	_wrapper = VBoxContainer.new()
	_icon = Sprite.new()
	
	_title = AnimaButton.new()

	_icon.texture = load("res://addons/anima/icons/collapse.svg")
	_icon.position = Vector2(16, 16)

	_title.anchor_right = 1
	_title.anchor_bottom = 1
	_title.rect_min_size.y = 32
	_title.rect_size.y = 32
	_title.set(_title.BUTTON_BASE_PROPERTIES.BUTTON_ALIGN.name, 1)
	_title.connect("pressed", self, "_on_Title_pressed")

	_title.add_child(_icon)

	_wrapper.anchor_right = 1
	_wrapper.add_child(_title)

	add_child(_wrapper)

func set_expanded(is_expanded: bool, animate := true) -> void:
	expanded = is_expanded

	if not is_inside_tree():
		return

	if _is_ready and animate and should_animate_property_change():
		_on_content_control_added()
		_animate_height_change()

		return

	var y: float = _get_expanded_height() if is_expanded else _get_collapsed_height()

	rect_min_size.y = y
	rect_size.y = y
	# In case there was a fading animation applied
	if _content_control:
		_content_control.modulate.a = 1.0
		_content_control.rect_scale = Vector2.ONE

func _get_collapsed_height() -> float:
	return _title.rect_min_size.y

func _get_expanded_height() -> float:
	if _content_control == null:
		for child in get_children():
			if child is VBoxContainer and not child == _wrapper:
				_content_control = child
				
				break

	if not _content_control:
		return _get_collapsed_height()

	_content_control.margin_bottom = 0
	return _get_collapsed_height() + _content_control.rect_size.y

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
			.anima_property("min_size:y", _get_expanded_height()) \
			.anima_from(_get_collapsed_height()) \
			.anima_easing(easing)
	)
	anima.with(
		Anima.Node(self) \
			.anima_property("size:y", _get_expanded_height()) \
			.anima_from(_get_collapsed_height()) \
			.anima_easing(easing)
	)

	anima.with(
		Anima.Node(_content_control) \
			.anima_animation(get_property(CUSTOM_PROPERTIES.ANIMATION_NAME.name), null, true)
	)
	anima.with(
		Anima.Node(_icon) \
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

	_title.set(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_LABEL.name, label)

func set_font(new_font: Font) -> void:
	font = new_font

	_title.set(AnimaButton.BUTTON_BASE_PROPERTIES.BUTTON_FONT.name, font)

func _on_Title_pressed():
	set_expanded(!expanded)

func _on_content_control_added() -> void:
	if _content_control == null:
		return

	_content_control.set_position(Vector2(0, _title.rect_min_size.y))
	_content_control.size_flags_horizontal = SIZE_EXPAND_FILL
	_content_control.size_flags_vertical = SIZE_EXPAND_FILL
	_content_control.anchor_right = 1
	_content_control.anchor_bottom = 1
	_content_control.margin_right = 0
	_content_control.margin_bottom = 0
	_content_control.margin_top = _title.rect_min_size.y

func _on_content_control_removed() -> void:
	_content_control = null
