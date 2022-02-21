tool
class_name AnimaRectangle
extends AnimaShape

signal pressed
signal mouse_down

export (Anima.VALUES_IN) var size_values_in = Anima.VALUES_IN.PERCENTAGE setget set_size_values_in
export (bool) var draw_from_center setget set_draw_from_center

var _is_mouse_down := false

const PROPERTIES := {
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
	RECTANGLE_BORDER_WIDTH_LEFT = {
		name = "Rectangle/Border/Widh/Left",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_BORDER_WIDTH_TOP = {
		name = "Rectangle/Border/Widh/Top",
		type = TYPE_INT, 
		default = 0
	},
	RECTANGLE_BORDER_WIDTH_RIGHT = {
		name = "Rectangle/Border/Widh/Right",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_BORDER_WIDTH_BOTTOM = {
		name = "Rectangle/Border/Widh/Bottom",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_DETAILS = {
		name ="Rectangle/Border/Radius/Details",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "-1,20,1",
		default = 8,
	},
	RECTANGLE_RADIUS_TOP_LEFT = {
		name = "Rectangle/Border/Radius/TopLeft",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_RADIUS_TOP_RIGHT = {
		name ="Rectangle/Border/Radius/TopRight",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_RADIUS_BOTTOM_RIGHT = {
		name = "Rectangle/Border/Radius/BottomRight",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_RADIUS_BOTTOM_LEFT = {
		name = "Rectangle/Border/Radius/BottomLeft",
		type = TYPE_INT,
		default = 0,
	},
	RECTANGLE_OFFSET_DETAILS = {
		name ="Rectangle/Border/Offset/Radius/Details",
		type = TYPE_INT,
		hint = PROPERTY_HINT_RANGE,
		hint_string = "0,20,1",
		default = 8,
	},
	RECTANGLE_OFFSET_RADIUS_TOP_LEFT = {
		name = "Rectangle/Border/Offset/Radius/TopLeft",
		type = TYPE_INT,
		default = -1,
	},
	RECTANGLE_OFFSET_RADIUS_TOP_RIGHT = {
		name ="Rectangle/Border/Offset/Radius/TopRight",
		type = TYPE_INT,
		default = -1,
	},
	RECTANGLE_OFFSET_RADIUS_BOTTOM_RIGHT = {
		name = "Rectangle/Border/Offset/Radius/BottomRight",
		type = TYPE_INT,
		default = -1,
	},
	RECTANGLE_OFFSET_RADIUS_BOTTOM_LEFT = {
		name = "Rectangle/Border/Offset/Radius/BottomLeft",
		type = TYPE_INT,
		default = -1,
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

func _init():
	._init()
	_add_properties(PROPERTIES)

func _ready():
	connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event):
	var rectangle: Rect2 = get_property("Rectangle/Size")

	if event is InputEventMouseButton and event.button_index == 1:
		var my_size = Rect2(rectangle.position + rect_position, rectangle.size + rect_position)

		if not _is_mouse_down:
			emit_signal("mouse_down")
		else: #if my_size.intersects(Rect2(event.position, Vector2(2, 2))):
			emit_signal("pressed")

		_is_mouse_down = not _is_mouse_down

func _draw() -> void:
	var rect_to_draw: Rect2 = get_property(PROPERTIES.RECTANGLE_SIZE.name)
	var border_offset: Vector2 = get_property(PROPERTIES.RECTANGLE_BORDER_OFFSET.name)

	var has_border_offset = border_offset.x > 0 or border_offset.y > 0
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()

	stylebox.corner_detail = max(0, get_property(PROPERTIES.RECTANGLE_DETAILS.name))
	stylebox.set_corner_radius_individual(
		get_property(PROPERTIES.RECTANGLE_RADIUS_TOP_LEFT.name),
		get_property(PROPERTIES.RECTANGLE_RADIUS_TOP_RIGHT.name),
		get_property(PROPERTIES.RECTANGLE_RADIUS_BOTTOM_RIGHT.name),
		get_property(PROPERTIES.RECTANGLE_RADIUS_BOTTOM_LEFT.name)
	)

	stylebox.border_color = get_property(PROPERTIES.RECTANGLE_BORDER_COLOR.name)
	stylebox.border_blend = get_property(PROPERTIES.RECTANGLE_BORDER_BLEND.name)

	if size_values_in == Anima.VALUES_IN.PERCENTAGE:
		rect_to_draw.size.x = rect_size.x * (rect_to_draw.size.x / 100)
		rect_to_draw.size.y = rect_size.y * (rect_to_draw.size.y / 100)
		rect_to_draw.position.x = rect_size.x * (rect_to_draw.position.x / 100)
		rect_to_draw.position.y = rect_size.y * (rect_to_draw.position.y / 100)

	if draw_from_center:
		rect_to_draw.position.x = (rect_size.x - rect_to_draw.size.x) / 2
		rect_to_draw.position.y = (rect_size.y - rect_to_draw.size.y) / 2

	stylebox.bg_color = get_property("Rectangle/FillColor")

	if not has_border_offset:
		stylebox.border_width_bottom = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_BOTTOM.name)
		stylebox.border_width_left = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_LEFT.name)
		stylebox.border_width_right = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_RIGHT.name)
		stylebox.border_width_top = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_TOP.name)

		stylebox.shadow_color = get_property(PROPERTIES.RECTANGLE_SHADOW_COLOR.name)
		stylebox.shadow_size = get_property(PROPERTIES.RECTANGLE_SHADOW_SIZE.name)
		stylebox.shadow_offset = get_property(PROPERTIES.RECTANGLE_SHADOW_OFFSET.name)

	draw_style_box(stylebox, rect_to_draw)

	if not has_border_offset:
		return

	var border_rect: Rect2 = Rect2(rect_to_draw.position - border_offset, rect_to_draw.size + (border_offset * 2))
	var stylebox_border: StyleBoxFlat = stylebox.duplicate()
	
	stylebox_border.bg_color = Color.transparent

	stylebox_border.border_width_bottom = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_BOTTOM.name)
	stylebox_border.border_width_left = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_LEFT.name)
	stylebox_border.border_width_right = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_RIGHT.name)
	stylebox_border.border_width_top = get_property(PROPERTIES.RECTANGLE_BORDER_WIDTH_TOP.name)

	stylebox_border.shadow_color = get_property(PROPERTIES.RECTANGLE_SHADOW_COLOR.name)
	stylebox_border.shadow_size = get_property(PROPERTIES.RECTANGLE_SHADOW_SIZE.name)
	stylebox_border.shadow_offset = get_property(PROPERTIES.RECTANGLE_SHADOW_OFFSET.name)

	var offset_radius := {
			"corner_radius_top_left": PROPERTIES.RECTANGLE_OFFSET_RADIUS_TOP_LEFT.name,
			"corner_radius_top_right": PROPERTIES.RECTANGLE_OFFSET_RADIUS_TOP_RIGHT.name,
			"corner_radius_bottom_right": PROPERTIES.RECTANGLE_OFFSET_RADIUS_BOTTOM_RIGHT.name,
			"corner_radius_bottom_left": PROPERTIES.RECTANGLE_OFFSET_RADIUS_BOTTOM_LEFT.name,
			"corner_detail": PROPERTIES.RECTANGLE_OFFSET_DETAILS.name
	}

	for radius_key in offset_radius:
		var radius: int = get_property(offset_radius[radius_key])

		if radius > -1:
			stylebox_border[radius_key] = radius

	draw_style_box(stylebox_border, border_rect)

func set_size_values_in(new_size_values_in: int) -> void:
	size_values_in = new_size_values_in

	update()

func set_draw_from_center(new_is_draw_from_center: bool) -> void:
	draw_from_center = new_is_draw_from_center

	update()
