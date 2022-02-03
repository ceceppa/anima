tool
class_name AnimaRectangle
extends "res://addons/anima/shapes/Base.gd"

signal pressed
signal mouse_down

export (Anima.VALUES_IN) var size_values_in = Anima.VALUES_IN.PERCENTAGE setget set_size_values_in
export (bool) var draw_from_center setget set_draw_from_center

var _is_mouse_down := false

func _init():
	property_list = PropertyList.new([
		["Rectangle/Size", TYPE_RECT2, Rect2(Vector2.ZERO, Vector2.ZERO)],
		["Rectangle/FillColor", TYPE_COLOR, Color("314569")],
		["Rectangle/BorderWidh/Left", TYPE_INT, 0],
		["Rectangle/BorderWidh/Top", TYPE_INT, 0],
		["Rectangle/BorderWidh/Right", TYPE_INT, 0],
		["Rectangle/BorderWidh/Bottom", TYPE_INT, 0],
		["Rectangle/Border/Color", TYPE_COLOR, Color.black],
		["Rectangle/Border/Blend", TYPE_BOOL, false],
		["Rectangle/Border/Offset", TYPE_VECTOR2, Vector2.ZERO],
		["Rectangle/CornerRadius/TopLeft", TYPE_INT, 0],
		["Rectangle/CornerRadius/TopRight", TYPE_INT, 0],
		["Rectangle/CornerRadius/BottomRight", TYPE_INT, 0],
		["Rectangle/CornerRadius/BottomLeft", TYPE_INT, 0],
		["Rectangle/Shadow/Color", TYPE_COLOR, Color.transparent],
		["Rectangle/Shadow/Size", TYPE_INT, 0],
		["Rectangle/Shadow/Offset", TYPE_VECTOR2, Vector2.ZERO],
	])

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
	var rect_to_draw: Rect2 = get_property("Rectangle/Size")
	var border_offset: Vector2 = get_property("Rectangle/Border/Offset")

	var has_border_offset = border_offset.x != 0 or border_offset.y != 0
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	
	stylebox.bg_color = Color.transparent
	stylebox.set_corner_radius_individual(
		get_property("Rectangle/CornerRadius/TopLeft"),
		get_property("Rectangle/CornerRadius/TopRight"),
		get_property("Rectangle/CornerRadius/BottomRight"),
		get_property("Rectangle/CornerRadius/BottomLeft")
	)

	stylebox.border_color = get_property("Rectangle/Border/Color")
	stylebox.border_blend = get_property("Rectangle/Border/Blend")

	if size_values_in == Anima.size_values_in.PERCENTAGE:
		rect_to_draw.size.x = rect_size.x * (rect_to_draw.size.x / 100)
		rect_to_draw.size.y = rect_size.y * (rect_to_draw.size.y / 100)
		rect_to_draw.position.x = rect_size.x * (rect_to_draw.position.x / 100)
		rect_to_draw.position.y = rect_size.y * (rect_to_draw.position.y / 100)

	if draw_from_center:
		rect_to_draw.position.x = (rect_size.x - rect_to_draw.size.x) / 2
		rect_to_draw.position.y = (rect_size.y - rect_to_draw.size.y) / 2

	stylebox.bg_color = get_property("Rectangle/FillColor")

	if not has_border_offset:
		stylebox.border_width_bottom = get_property("Rectangle/BorderWidh/Bottom")
		stylebox.border_width_left = get_property("Rectangle/BorderWidh/Left")
		stylebox.border_width_right = get_property("Rectangle/BorderWidh/Right")
		stylebox.border_width_top = get_property("Rectangle/BorderWidh/Top")

	draw_style_box(stylebox, rect_to_draw)

	if not has_border_offset:
		return

	var border_rect: Rect2 = Rect2(rect_to_draw.position - border_offset, rect_to_draw.size + (border_offset * 2))
	var stylebox_border: StyleBoxFlat = stylebox.duplicate()
	
	stylebox_border.bg_color = Color.transparent
	stylebox_border.border_color = get_property("Rectangle/Border/Color")
	stylebox.border_width_bottom = get_property("Rectangle/BorderWidh/Bottom")
	stylebox.border_width_left = get_property("Rectangle/BorderWidh/Left")
	stylebox.border_width_right = get_property("Rectangle/BorderWidh/Right")
	stylebox.border_width_top = get_property("Rectangle/BorderWidh/Top")

	draw_style_box(stylebox_border, border_rect)

func set_size_values_in(new_size_values_in: int) -> void:
	size_values_in = new_size_values_in

	update()

func set_draw_from_center(new_is_draw_from_center: bool) -> void:
	draw_from_center = new_is_draw_from_center

	update()
