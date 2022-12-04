extends Control

var BALL_ITEM = preload('res://demos/components/HoverableBall.tscn')

const FIRST_BALL_Y = 50

var _rows: int
var _columns: int

func _ready() -> void:
	for distance in ANIMA.DISTANCE.keys():
		$HBoxContainer/Formula.add_item(distance)

	AnimaAnimationsUtils.register_animation('grid_test_in', {
		from = {
			scale = Vector2.ONE,
			modulate = Color.WHITE,
		},
		to = {
			scale = Vector2.ZERO,
			modulate = Color(1, 0, 0.49, 0)
		},
		pivot = ANIMA.PIVOT.CENTER
	})
	AnimaAnimationsUtils.register_animation('grid_test_out', {
		from = {
			scale = Vector2.ZERO,
			modulate = Color(0.33, 0.66, 0.49, 0),
		},
		to = {
			scale = Vector2.ONE,
			modulate = Color.WHITE
		}
	})

	_init_balls()

func _init_balls() -> void:
	var ball = BALL_ITEM.instantiate()
	
	var window_size := size
	var ball_size: Vector2 = ball.get_size()
	
	var columns = floor(window_size.x / ball_size.x) - 6
	
	var available_height: float = window_size.y - FIRST_BALL_Y
	var rows = floor(available_height / ball_size.y) - 3

	columns = min(20, columns)
	rows = min(10, rows)

	var gap_x = (window_size.x - (ball_size.x * columns)) / columns
	var gap_y = (available_height - (ball_size.y * rows)) / rows

	ball.position.x = gap_x / 8
	ball.position.y = FIRST_BALL_Y
	
	_rows = rows
	_columns = columns

	for column in columns:
		for row in rows:
			var clone = ball.duplicate()

			clone.position = ball.position
			clone.position.x = ball.position.x + (column * ball_size.x + gap_x * column)
			clone.position.y = ball.position.y + (row  * ball_size.y + gap_y * row)

			$Grid.add_child(clone)

			clone.connect('pressed',Callable(self,'_on_ball_pressed').bind(Vector2(column, row)))

func _on_ball_pressed(from: Vector2) -> void:
	var anima := Anima.begin(self)
	var formula = $HBoxContainer/Formula.get_selected_id()

	anima.then(
		Anima.Grid($Grid, Vector2(_columns, _rows), 0.05, ANIMA.GRID.FROM_POINT, from) \
			.anima_distance_formula(formula) \
			.anima_animation("grid_test_in", 0.6)
	) \
	.wait(0.2) \
	.then(
		Anima.Grid($Grid, Vector2(_columns, _rows), 0.05, ANIMA.GRID.FROM_POINT, from) \
			.anima_distance_formula(formula) \
			.anima_animation("grid_test_out", 0.3) \
	) \
	.play()

func _on_OptionButton_item_selected(index):
	pass # Replace with function body.
