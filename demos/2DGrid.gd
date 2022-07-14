extends Control

var BALL_ITEM = preload('res://demos/components/HoverableBall.tscn')

const FIRST_BALL_Y = 50

var _rows: int
var _columns: int

func _ready() -> void:
	Anima.register_animation(self, 'grid_test_in')
	Anima.register_animation(self, 'grid_test_out')

	_init_balls()

func _init_balls() -> void:
	var ball = BALL_ITEM.instance()
	
	var window_size := OS.get_window_size()
	var ball_size: Vector2 = ball.get_size()
	
	var columns = floor(window_size.x / ball_size.x) - 6
	
	var available_height: float = window_size.y - FIRST_BALL_Y
	var rows = floor(available_height / ball_size.y) - 3

	columns = min(20, columns)
	rows = min(10, rows)

	var gap_x = (window_size.x - (ball_size.x * columns)) / columns
	var gap_y = (available_height - (ball_size.y * rows)) / rows

	ball.rect_position.x = gap_x / 8
	ball.rect_position.y = FIRST_BALL_Y
	
	_rows = rows
	_columns = columns

	for column in columns:
		for row in rows:
			var clone = ball.duplicate()

			clone.rect_position = ball.rect_position
			clone.rect_position.x = ball.rect_position.x + (column * ball_size.x + gap_x * column)
			clone.rect_position.y = ball.rect_position.y + (row  * ball_size.y + gap_y * row)

			$Grid.add_child(clone)

			clone.connect('pressed', self, '_on_ball_pressed', [Vector2(column, row)])

func _on_ball_pressed(from: Vector2) -> void:
	var anima := Anima.begin(self)
	
	anima.then({
		grid = $Grid,
		grid_size = Vector2(_columns, _rows),
		animation_type = Anima.GRID.FROM_POINT,
		point = from,
		duration = 0.6,
		items_delay = 0.05,
		animation = "grid_test_in",
		pivot = ANIMA.PIVOT.CENTER
	})
	anima.wait(0.2)
	anima.then({
		grid = $Grid,
		grid_size = Vector2(_columns, _rows),
		animation_type = Anima.GRID.FROM_POINT,
		point = from,
		duration = 0.6,
		items_delay = 0.05,
		animation = "grid_test_out",
		pivot = ANIMA.PIVOT.CENTER
	})
	anima.play()


func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var scale_frames := []
	var modulate_frames := []

	if data.animation == 'grid_test_in':
		scale_frames = [
			{ from = Vector2(1, 1), to = Vector2(0, 0) }
		]
		modulate_frames = [
			{ from = Color.white, to = Color(1, 0, 0.49, 0) }
		]
	else:
		scale_frames = [
			{ from = Vector2(0, 0), to = Vector2(1, 1) }
		]
		modulate_frames = [
			{ from = Color(0.33, 0.66, 0.49, 0), to = Color.white }
		]

	anima_tween.add_frames(data, 'scale', scale_frames)
	anima_tween.add_frames(data, 'modulate', modulate_frames)
