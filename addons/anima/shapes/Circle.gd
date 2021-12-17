tool
class_name AnimaCircle
extends "res://addons/anima/shapes/Base.gd"

export (Vector2) var center setget set_center
export (Anima.VALUES_IN) var values_in setget set_values_in
export (float) var radius setget set_radius
export (bool) var centered setget set_is_centered
export (Color) var color setget set_color
export (bool) var is_filled = true setget set_is_filled
export (float) var border_width = 0.0 setget set_border_width
export (Color) var border_color = Color.black setget set_border_color
export (float) var border_offset = 0 setget set_border_offset

var _old_radius: float
var _old_position: Vector2
var _old_points: PoolVector2Array

func _draw() -> void:
	var position: Vector2 = center

	if centered:
		position = rect_size / 2

	if is_filled:
		# NOTE: Draw method is not antialised and also we do not have control on how many points
		# to use. That's why we use `draw_polygon` instead as is more flexible
		var points := _get_points(position)

		draw_polygon(points, [color], PoolVector2Array(), null, null, true)

	if border_width > 0:
		draw_arc(position, radius + border_offset, 0, TAU, 180, border_color, border_width, true)

func _get_points(position: Vector2) -> PoolVector2Array:
	if radius == _old_radius and position == _old_position:
		return _old_points

	var points: PoolVector2Array

	for i in range(0, 360, 3):
		var angle = deg2rad(i)

		points.push_back(position + Vector2(radius * sin(angle), radius * cos(angle)))

	_old_radius = radius
	_old_points = points
	_old_position = position

	return _old_points

func set_center(new_rect: Rect2) -> void:
	center = new_rect

	update()

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

func set_border_offset(offset: float) -> void:
	border_offset = offset

	update()

func set_is_centered(new_is_centered: bool) -> void:
	centered = new_is_centered

	update()

func set_radius(new_radius: float) -> void:
	radius = new_radius

	update()
