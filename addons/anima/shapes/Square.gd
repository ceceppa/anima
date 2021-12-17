tool
class_name AnimaSquare
extends Control

export (Rect2) var rect setget set_rect
export (Color) var color setget set_color
export (bool) var is_filled setget set_is_filled
export (float) var border_width = 1.0 setget set_border_width
export (bool) var centered setget set_is_centered
export (bool) var full_size setget set_is_full_size

func _draw() -> void:
	var r: Rect2 = rect

	if centered:
		r.position.x = (rect_size.x - rect.size.x) / 2
		r.position.y = (rect_size.y - rect.size.y) / 2
	if full_size:
		r = Rect2(Vector2.ZERO, rect_size)

	draw_rect(r, color, is_filled, border_width)

func set_rect(new_rect: Rect2) -> void:
	rect = new_rect

	update()

func set_color(new_color: Color) -> void:
	color = new_color

	update()

func set_is_filled(filled: bool) -> void:
	is_filled = filled

	update()

func set_border_width(new_width: float) -> void:
	border_width = new_width

	update()

func set_is_centered(is_centered: bool) -> void:
	centered = is_centered

	update()

func set_is_full_size(full_size: bool) -> void:
	full_size = full_size

	update()
