extends Control

signal pressed

@onready var _half_ball_size: Vector2 = $ball.texture.get_size() * $ball.scale / 2.0
@onready var _ball_radius: float = $ball.texture.get_size().x * $ball.scale.x / 2.0
@onready var texture = $ball.texture

var _hovered := false
var _was_hovered := false

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position: Vector2 = (event.position - _half_ball_size) - ($ball.offset / 2.0) - position
		var length: float = mouse_position.length()

		_hovered = length <= _ball_radius
		if _hovered and not _was_hovered:
			_was_hovered = true
			queue_redraw()
		elif _was_hovered and not _hovered:
			_was_hovered = false
			queue_redraw()
	elif event is InputEventMouseButton:
		if event.is_pressed() and _hovered:
			emit_signal('pressed')

func _draw():
	var color := Color.TRANSPARENT

	if _hovered:
		color = Color('#ff4b4b')

	var half_radius = _ball_radius / 2.0
	var pos: Vector2 = Vector2($ball.offset.x + _ball_radius - 5.0, $ball.offset.y + _ball_radius - 5.0)
	draw_arc(pos, _ball_radius * 1.1, 0, PI * 2, 360, color, 16.0, true)

func get_size() -> Vector2:
	return $ball.texture.get_size() * $ball.scale
