tool
class_name AnimaTriangle
extends AnimaShape

enum Types {
	Equilater,
	Isosceles,
	Scalene,
	Right,
	Acute,
	Oblique
}

const BorderType := {
	Bevel = Line2D.LINE_JOINT_BEVEL,
	Round = Line2D.LINE_JOINT_ROUND,
}

onready var _border_line: Line2D = Line2D.new()

const PROPERTIES := {
	POINT1 = {
		name = "Triangle/Point1",
		type = TYPE_VECTOR2,
		default = Vector2.ZERO
	},
	POINT2 = {
		name = "Triangle/Point2",
		type = TYPE_VECTOR2,
		default = Vector2(100, 100)
	},
	POINT3 = {
		name = "Triangle/Point3",
		type = TYPE_VECTOR2,
		default = Vector2(0, 100)
	},
	FILL_COLOR = {
		name = "Triangle/FillColor",
		type = TYPE_COLOR,
		default = Color.aqua
	},
	BORDER_WIDTH = {
		name = "Triangle/Border/Width",
		type = TYPE_REAL,
		default = 0
	},
	BORDER_COLOR = {
		name = "Triangle/Border/Color",
		type = TYPE_COLOR,
		default = Color.black
	},
	BORDER_TYPE = {
		name = "Triangle/Border/Type",
		type = TYPE_INT,
		hint = PROPERTY_HINT_ENUM,
		hint_string = "Bevel,Round",
		default = 1
	},
#	BORDER_OFFSET = {
#		name = "Triangle/Border/Offset",
#		type = TYPE_REAL,
#		default = 0
#	},
}

func _init() -> void:
	._init()

	_add_properties(PROPERTIES)

func _ready():
	add_child(_border_line)

func _draw() -> void:
	var p1: Vector2 = _convert_to_percentage(get_property(PROPERTIES.POINT1.name))
	var p2: Vector2 = _convert_to_percentage(get_property(PROPERTIES.POINT2.name))
	var p3: Vector2 = _convert_to_percentage(get_property(PROPERTIES.POINT3.name))
	var fill_color: Color = get_property(PROPERTIES.FILL_COLOR.name)
	var border_width: float = get_property(PROPERTIES.BORDER_WIDTH.name)
	var border_type: int = int(get_property(PROPERTIES.BORDER_TYPE.name)) + 1
	var border_color: Color = get_property(PROPERTIES.BORDER_COLOR.name)
	
	# TODO: To implement this
	var border_offset: float = 0 #get_property(PROPERTIES.BORDER_OFFSET.name)

	var points: PoolVector2Array

	points.push_back(p1)
	points.push_back(p2)
	points.push_back(p3)
	points.push_back(p1)

	if fill_color.a > 0.0:
		draw_polygon(points, [fill_color], [], null, null, true)

	var border_points: PoolVector2Array = points

	if border_offset > 0:
		var offset := Vector2(border_offset, border_offset)

		border_points = PoolVector2Array([p1 - offset, p2 + offset, p3 + offset, p1 - offset])

	_border_line.set_points(border_points)
	_border_line.set_joint_mode(border_type)
	_border_line.set_begin_cap_mode(border_type)
	_border_line.set_end_cap_mode(border_type)
	_border_line.set_width(border_width)
	_border_line.default_color = border_color
	_border_line.show()
