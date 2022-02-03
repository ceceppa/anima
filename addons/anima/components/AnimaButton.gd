tool
extends AnimaRectangle

export var label := "Anima Button" setget set_label

var _original_bg_color: Color

const BUTTON_PROPERTIES := {
	BUTTON_FONT_COLOR = {
		name = "Button/FontColor",
		type = TYPE_COLOR,
		default = Color("ffffff")
	},
	
	# Hovered
	HOVERED_FONT_COLOR = {
		name = "Hovered/FontColor",
		type = TYPE_COLOR,
		default = Color("ffffff")
	},
	HOVERED_FILL_COLOR = {
		name = "Hovered/FillColor",
		type = TYPE_COLOR,
		default = Color("628ad1")
	},
	HOVERED_BORDER_WIDTH_LEFT = {
		name = "Hovered/BorderWidh/Left",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_BORDER_WIDTH_TOP = {
		name = "Hovered/BorderWidh/Top",
		type = TYPE_INT, 
		default = -1
	},
	HOVERED_BORDER_WIDTH_RIGHT = {
		name = "Hovered/BorderWidh/Right",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_BORDER_WIDTH_BOTTOM = {
		name = "Hovered/BorderWidh/Bottom",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_BORDER_COLOR = {
		name = "Hovered/Border/Color",
		type = TYPE_COLOR,
		default = Color.transparent,
	},
	HOVERED_BORDER_OFFSET = {
		name = "Hovered/Border/Offset",
		type = TYPE_VECTOR2,
		default = Vector2(-1, -1)
	},
	HOVERED_CORNER_RADIUS_TOP_LEFT = {
		name = "Hovered/CornerRadius/TopLeft",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_CORNER_RADIUS_TOP_RIGHT = {
		name ="Hovered/CornerRadius/TopRight",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_CORNER_RADIUS_BOTTOM_RIGHT = {
		name = "Hovered/CornerRadius/BottomRight",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_CORNER_RADIUS_BOTTOM_LEFT = {
		name = "Hovered/CornerRadius/BottomLeft",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_SHADOW_COLOR = {
		name = "Hovered/Shadow/Color",
		type = TYPE_COLOR,
		default = Color.transparent,
	},
	HOVERED_SHADOW_SIZE = {
		name = "Hovered/Shadow/Size",
		type = TYPE_INT,
		default = -1,
	},
	HOVERED_SHADOW_OFFSET = {
		name = "Hovered/Shadow/Offset",
		type = TYPE_VECTOR2,
		default = Vector2(-1, -1),
	},

	# Pressed
	PRESSED_FONT_COLOR = {
		name = "Pressed/FontColor",
		type = TYPE_COLOR,
		default = Color("ffffff")
	},
	PRESSED_FILL_COLOR = {
		name = "Pressed/FillColor",
		type = TYPE_COLOR,
		default = Color("628ad1")
	},
	PRESSED_BORDER_WIDTH_LEFT = {
		name = "Pressed/BorderWidh/Left",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_BORDER_WIDTH_TOP = {
		name = "Pressed/BorderWidh/Top",
		type = TYPE_INT, 
		default = -1
	},
	PRESSED_BORDER_WIDTH_RIGHT = {
		name = "Pressed/BorderWidh/Right",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_BORDER_WIDTH_BOTTOM = {
		name = "Pressed/BorderWidh/Bottom",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_BORDER_COLOR = {
		name = "Pressed/Border/Color",
		type = TYPE_COLOR,
		default = Color.transparent,
	},
	PRESSED_BORDER_OFFSET = {
		name = "Pressed/Border/Offset",
		type = TYPE_VECTOR2,
		default = Vector2(-1, -1)
	},
	PRESSED_CORNER_RADIUS_TOP_LEFT = {
		name = "Pressed/CornerRadius/TopLeft",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_CORNER_RADIUS_TOP_RIGHT = {
		name ="Pressed/CornerRadius/TopRight",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_CORNER_RADIUS_BOTTOM_RIGHT = {
		name = "Pressed/CornerRadius/BottomRight",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_CORNER_RADIUS_BOTTOM_LEFT = {
		name = "Pressed/CornerRadius/BottomLeft",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_SHADOW_COLOR = {
		name = "Pressed/Shadow/Color",
		type = TYPE_COLOR,
		default = Color.transparent,
	},
	PRESSED_SHADOW_SIZE = {
		name = "Pressed/Shadow/Size",
		type = TYPE_INT,
		default = -1,
	},
	PRESSED_SHADOW_OFFSET = {
		name = "Pressed/Shadow/Offset",
		type = TYPE_VECTOR2,
		default = Vector2(-1, -1),
	}
}

func _init():
	_add_properties(BUTTON_PROPERTIES)

	_original_bg_color = get_property("Rectangle/FillColor")

func set_label(label: String) -> void:
	find_node("Label").text = label

func _on_mouse_entered():
	set_with_animation("Hovered/FillColor", _original_bg_color)

func _on_mouse_exited():
	set_with_animation("Rectangle/FillColor", _original_bg_color)

func _on_mouse_down():
	set_with_animation("Pressed/FillColor", _original_bg_color)
