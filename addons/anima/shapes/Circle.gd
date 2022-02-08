tool
class_name AnimaCircle
extends AnimaShape

var _old_radius: float
var _old_position: Vector2
var _old_points: PoolVector2Array

const PROPERTIES := {
	RADIUS = {
		name = "Circle/Radius",
		type = TYPE_REAL,
		default = 100,
	},
	FILL_COLOR = {
		name = "Circle/FillColor",
		type = TYPE_COLOR,
		default = Color.aqua
	},
	BORDER_WIDTH = {
		name = "Circle/Border/Width",
		type = TYPE_REAL,
		default = 0.0
	},
	BORDER_COLOR = {
		name = "Circle/Border/Color",
		type = TYPE_COLOR,
		default = Color.transparent
	},
	BORDER_OFFSET = {
		name = "Circle/Border/Offset",
		type = TYPE_REAL,
		default = 0
	}
}

func _init():
	._init()

	_add_properties(PROPERTIES)

func _draw() -> void:
	var position: Vector2 = rect_size / 2
	var fill_color: Color = get_property(PROPERTIES.FILL_COLOR.name)
	var border_width: float = get_property(PROPERTIES.BORDER_WIDTH.name)
	var radius: float = get_property(PROPERTIES.RADIUS.name)
	var border_offset: float = get_property(PROPERTIES.BORDER_OFFSET.name)
	var border_color: Color = get_property(PROPERTIES.BORDER_COLOR.name)

	if fill_color.a > 0.0:
		# NOTE: Draw method is not antialised and also we do not have control on how many points
		# to use. That's why we use `draw_polygon` instead as is more flexible
		var points := _get_points(position)

		draw_polygon(points, [fill_color], PoolVector2Array(), null, null, true)

	if border_width > 0:
		draw_arc(position, radius + border_offset, 0, TAU, 180, border_color, border_width, true)

func _get_points(position: Vector2) -> PoolVector2Array:
	var radius: float = get_property(PROPERTIES.RADIUS.name)

	if radius == _old_radius and position == _old_position:
		return _old_points

	var points: PoolVector2Array

	for i in range(0, 360, 4):
		var angle = deg2rad(i)

		points.push_back(position + Vector2(radius * sin(angle), radius * cos(angle)))

	_old_radius = radius
	_old_points = points
	_old_position = position

	return _old_points
