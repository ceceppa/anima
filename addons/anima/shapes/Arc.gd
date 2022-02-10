tool
class_name AnimaArc
extends AnimaShape

export (Vector2) var center setget set_center
export (Anima.VALUES_IN) var values_in setget set_values_in
export (float) var radius setget set_radius
export (float) var from_angle setget set_from_angle
export (float) var to_angle setget set_to_angle
export (bool) var centered setget set_is_centered
export (int) var arc_points = 360 setget set_arc_points
export (Color) var color setget set_color
export (float) var border_width = 1.0 setget set_border_width

func _draw() -> void:
	var position: Vector2 = center

	if centered:
		position = rect_size / 2

	draw_arc(position, radius, deg2rad(from_angle - 90), deg2rad(to_angle - 90), max(2, arc_points), color, border_width, true)

func set_center(new_rect: Rect2) -> void:
	center = new_rect

	update()

func set_values_in(new_values_in: int) -> void:
	values_in = new_values_in

	update()

func set_color(new_color: Color) -> void:
	color = new_color

	update()

func set_border_width(new_width: float) -> void:
	border_width = new_width

	update()

func set_is_centered(new_is_centered: bool) -> void:
	centered = new_is_centered

	update()

func set_radius(new_radius: float) -> void:
	radius = new_radius

	update()

func set_from_angle(angle: float) -> void:
	from_angle = angle

	update()

func set_to_angle(angle: float) -> void:
	to_angle = angle

	update()

func set_arc_points(points: int) -> void:
	arc_points = points

	update()
