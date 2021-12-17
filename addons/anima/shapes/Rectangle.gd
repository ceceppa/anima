tool
class_name AnimaRectangle
extends "res://addons/anima/shapes/Base.gd"

export (Rect2) var rect setget set_rect
export (Anima.VALUES_IN) var values_in setget set_values_in
export (Color) var color setget set_color
export (bool) var is_filled = true setget set_is_filled
export (float) var border_width = 1.0 setget set_border_width
export (Color) var border_color = Color.black setget set_border_color
export (Vector2) var border_offset = Vector2.ZERO setget set_border_offset
export (bool) var centered setget set_is_centered
export (bool) var is_full_size setget set_is_full_size
export (int) var border_radius = 0 setget set_border_radius

func _draw() -> void:
	var rect_to_draw: Rect2 = rect
	var has_border_offset = border_offset.x != 0 or border_offset.y != 0
	var stylebox: StyleBoxFlat = StyleBoxFlat.new()
	
	stylebox.bg_color = Color.transparent
	stylebox.set_corner_radius_all(border_radius)
	stylebox.border_color = border_color

	if values_in == Anima.VALUES_IN.PERCENTAGE:
		rect_to_draw.size.x = rect_size.x * (rect.size.x / 100)
		rect_to_draw.size.y = rect_size.y * (rect.size.y / 100)
		rect_to_draw.position.x = rect_size.x * (rect.position.x / 100)
		rect_to_draw.position.y = rect_size.y * (rect.position.y / 100)

	if centered:
		rect_to_draw.position.x = (rect_size.x - rect_to_draw.size.x) / 2
		rect_to_draw.position.y = (rect_size.y - rect_to_draw.size.y) / 2

	if is_full_size:
		rect_to_draw = Rect2(Vector2.ZERO, rect_size)

	if is_filled:
		stylebox.bg_color = color

	if not has_border_offset:
		stylebox.set_border_width_all(border_width)

	draw_style_box(stylebox, rect_to_draw)

	if not has_border_offset:
		return

	var border_rect: Rect2 = Rect2(rect_to_draw.position - border_offset, rect_to_draw.size + (border_offset * 2))
	var stylebox_border: StyleBoxFlat = stylebox.duplicate()
	
	stylebox_border.bg_color = Color.transparent
	stylebox_border.border_color = border_color
	stylebox_border.set_border_width_all(border_width)

	draw_style_box(stylebox_border, border_rect)

func set_rect(new_rect: Rect2) -> void:
	rect = new_rect

	update()

func set_rect_from_px_to_percentage(new_rect: Rect2) -> void:
	new_rect = get_rect_from_px_to_percentage(new_rect)

	values_in = Anima.VALUES_IN.PERCENTAGE

	set_rect(new_rect)

func get_rect_from_px_to_percentage(new_rect: Rect2) -> Rect2:
	new_rect.position.x = (new_rect.position.x / rect_size.x) * 100
	new_rect.position.y = (new_rect.position.y / rect_size.y) * 100

	new_rect.size.x = (new_rect.size.x / rect_size.x) * 100
	new_rect.size.y = (new_rect.size.y / rect_size.y) * 100

	return new_rect

func set_values_in(new_values_in: int) -> void:
	values_in = new_values_in

	update()

func set_color(new_color: Color) -> void:
	color = new_color

	update()

func set_is_filled(new_filled: bool) -> void:
	is_filled = new_filled

	update()

func set_border_width(new_width: float) -> void:
	border_width = new_width

	update()

func set_border_color(color: Color) -> void:
	border_color = color

	update()

func set_border_offset(offset: Vector2) -> void:
	border_offset = offset

	update()

func set_is_centered(new_is_centered: bool) -> void:
	centered = new_is_centered

	update()

func set_is_full_size(new_full_size: bool) -> void:
	is_full_size = new_full_size

	update()

func set_border_radius(radius: int) -> void:
	border_radius = radius

	update()
