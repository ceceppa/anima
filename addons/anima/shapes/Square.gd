tool
class_name AnimaSquare
extends Control

export (Rect2) var _rect setget set_rect
export (Color) var _color setget set_color
export (bool) var _is_filled setget set_is_filled
export (float) var _border_width = 1.0 setget set_border_width
export (bool) var _centered setget set_is_centered
export (bool) var _full_size setget set_is_full_size

func _draw() -> void:
	var rect: Rect2 = _rect

	if _centered:
		rect.position.x = (rect_size.x - _rect.size.x) / 2
		rect.position.y = (rect_size.y - _rect.size.y) / 2
	if _full_size:
		rect = Rect2(Vector2.ZERO, rect_size)

	draw_rect(rect, _color, _is_filled, _border_width)

func set_rect(rect: Rect2) -> void:
	_rect = rect

	update()

func set_color(color: Color) -> void:
	_color = color

	update()

func set_is_filled(filled: bool) -> void:
	_is_filled = filled

	update()

func set_border_width(width: float) -> void:
	_border_width = width

	update()

func set_is_centered(is_centered: bool) -> void:
	_centered = is_centered

	update()

func set_is_full_size(full_size: bool) -> void:
	_full_size = full_size

	update()
