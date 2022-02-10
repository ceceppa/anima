tool
class_name AnimaLine
extends AnimaShape

const HANDLE = preload("./handle.gd")

export (Vector2) var from = Vector2(0, 0) setget set_from
export (Vector2) var to = Vector2(100, 100) setget set_to
export (Anima.VALUES_IN) var values_in = Anima.VALUES_IN.PERCENTAGE setget set_values_in
export (bool) var from_center setget set_from_center
export (Color) var color setget set_color
export (float) var line_width setget set_line_width

func _ready():
	connect("item_rect_changed", self, 'update')
	
	if Engine.editor_hint:
		var c = HANDLE.new()

		add_child(c)

func _draw() -> void:
	var draw_from: Vector2 = from
	var draw_to: Vector2 = to

	if from_center:
		draw_from = rect_size / 2

		if values_in == Anima.VALUES_IN.PERCENTAGE:
			draw_from = Vector2(50, 50)

		draw_from -= draw_to / 2

	if values_in == Anima.VALUES_IN.PERCENTAGE:
		draw_from.x = rect_size.x * (draw_from.x / 100)
		draw_from.y = rect_size.y * (draw_from.y / 100)
		draw_to.x = rect_size.x * (draw_to.x / 100)
		draw_to.y = rect_size.y * (draw_to.y / 100)

	if from_center:
		draw_to.x += draw_from.x
		draw_to.y += draw_from.y

	draw_line(draw_from, draw_to, color, line_width, true)

func set_from(new_from: Vector2) -> void:
	from = new_from

	update()

func set_to(new_to: Vector2) -> void:
	to = new_to

	update()

func set_values_in(new_values_in: int) -> void:
	values_in = new_values_in

	update()

func set_from_center(center: bool) -> void:
	from_center = center

	update()

func set_color(new_color: Color) -> void:
	color = new_color

	update()

func set_line_width(new_width: float) -> void:
	line_width = new_width

	update()
