tool
class_name AnimaLine
extends Control

export (float) var _x1 setget set_x1
export (float) var _y1 setget set_y1
export (float) var _x2 setget set_x2
export (float) var _y2 setget set_y2
export (Color) var _color setget set_color
export (float) var _line_width setget set_line_width
export (bool) var _centered setget set_is_centered
export (bool) var _full_size setget set_is_full_size

func _ready():
	connect("item_rect_changed", self, 'update')

func _draw() -> void:
	var from := Vector2(_x1, _y1)
	var to := Vector2(_x2, _y2)

	draw_line(from, to, _color, _line_width, true)

func set_x1(x1: float) -> void:
	_x1 = x1

	update()

func set_y1(y1: float) -> void:
	_y1 = y1

	update()

func set_x2(x2: float) -> void:
	_x2 = x2

	update()

func set_y2(y2: float) -> void:
	_y2 = y2

	update()

func set_color(color: Color) -> void:
	_color = color

	update()

func set_line_width(width: float) -> void:
	_line_width = width

	update()

func set_is_centered(is_centered: bool) -> void:
	_centered = is_centered

	update()

func set_is_full_size(full_size: bool) -> void:
	_full_size = full_size

	update()
