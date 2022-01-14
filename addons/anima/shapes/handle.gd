tool
extends Control

const HANDLE_SIZE := 10

func _ready():
	var size := Vector2(HANDLE_SIZE, HANDLE_SIZE)

	_set_size(size)
	set_custom_minimum_size(size)

	set_mouse_filter(Control.MOUSE_FILTER_STOP)

	connect("mouse_entered", self, "_on_mouse_entered")

func _draw():
	var rect: Rect2 = Rect2(Vector2(0, 0), Vector2(HANDLE_SIZE, HANDLE_SIZE))

	draw_rect(rect, Color.white)

func _on_mouse_entered() -> void:
	pass
