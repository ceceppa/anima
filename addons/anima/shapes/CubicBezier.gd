tool
class_name AnimaCubicBezier
extends AnimaShape

export var test := false setget set_text

const HANDLE = preload("./handle.gd")

func _ready():
	connect("item_rect_changed", self, 'update')

func _draw() -> void:
	var curve: Curve2D = Curve2D.new()

	var easing = AnimaEasing.get_easing_points(Anima.EASING.EASE_IN_BACK)

	var p1: Vector2 = Vector2(0, rect_size.y)
	var p2: Vector2 = p1 + (Vector2(easing[0], easing[1]) * rect_size)
	var p3: Vector2 = Vector2(rect_size.x, 0)
	var p4: Vector2 = Vector2(500 * 0.65, 500 + (500 * 0.42))

	curve.add_point(p1, Vector2.ZERO, p2)
	curve.add_point(p3, p4)

	draw_circle(p2, 5.0, Color.red)
	draw_circle(p4, 5.0, Color.gold)

	var points = curve.get_baked_points()

	draw_polyline(points, Color.black, 8, true)

func set_text(a) -> void:
	update()
