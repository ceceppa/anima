class_name AnimaGrid

signal animation_started
signal animation_completed
signal loop_started
signal loop_completed

var _anima_node: AnimaNode

var _grid_size: Vector2
var _children := []
var _initil_delay: float = 0.0
var _children_delay := 0.1
var _animation_name: String
var _animation_type: int = Anima.GRID.SEQUENCE_TOP_LEFT
var _visibility_strategy: int
var _duration: float = Anima.DEFAULT_DURATION
var _end_called: bool = false

var _last_then_duration: float
var _last_then_delay := 0.0
var _animation_total_duration := 0.0

func init(grid_node: Node, grid_size: Vector2) -> void:
	_grid_size = grid_size

	var rows = grid_size.x
	var columns = grid_size.y

	var row_items := []
	var index = 0

	for child in grid_node.get_children():
		row_items.push_back(child)

		index += 1
		if index >= columns:
			_children.push_back(row_items)
			row_items = []
			index = 0

	if row_items.size() > 0:
		_children.push_back(row_items)

	_anima_node = Anima.begin(grid_node, 'grid_sequence_top_left')

	_anima_node.connect("animation_completed", self, '_on_anima_animation_completed')
	_anima_node.connect("animation_started", self, '_on_anima_animation_started')
	_anima_node.connect("loop_started", self, '_on_anima_loop_started')
	_anima_node.connect("loop_completed", self, '_on_anima_loop_completed')

func play() -> void:
	if not _end_called:
		printerr('AnimaGrid.end() not called')

		return

	_anima_node.play()

func play_with_delay(delay: float) -> void:
	if not _end_called:
		printerr('AnimaGrid.end() not called')

		return

	_anima_node.play_with_delay(delay)

func loop() -> void:
	_anima_node.loop()

func set_animation(animation_name: String) -> void:
	_animation_name = animation_name

func set_start_delay(initial_delay: float) -> void:
	_initil_delay = initial_delay

func set_items_delay(item_delay: float) -> void:
	_children_delay = item_delay

func set_animation_type(animation_type: int) -> void:
	_animation_type = animation_type

	if animation_type == Anima.GRID.TOGETHER:
		set_items_delay(0)

func set_visibility_strategy(strategy: int) -> void:
	_visibility_strategy = strategy

func set_duration(duration: float) -> void:
	_duration = duration

func set_loop_strategy(stategy: int) -> void:
	_anima_node.set_loop_strategy(stategy)

func wait(seconds: float) -> void:
	_anima_node._setup_animation({
		node = _anima_node,
		property = '__do_nothing',
		duration = seconds,
		_wait_time = _animation_total_duration
	})

	_last_then_delay = 0
	_last_then_duration = seconds
	_animation_total_duration += seconds

func then(data: Dictionary) -> void:
	var type = _animation_type

	if data.has('animation_type'):
		type = data.animation_type

	if not data.has('delay'):
		data.delay = 0
	else:
		_last_then_delay = data.delay

	if _animation_total_duration:
		data.delay += _animation_total_duration

	_add_parallel_animation_by_animation_type(type, data)

	if data.has('duration'):
		_last_then_duration = data.duration
	else:
		_last_then_duration = Anima.DEFAULT_DURATION

	_animation_total_duration += _last_then_duration

func with(data: Dictionary) -> void:
	var type = _animation_type

	if data.has('animation_type'):
		type = data.animation_type

	if not data.has('delay'):
		data.delay = _last_then_delay

	if _last_then_duration:
		data.delay += max(0, _animation_total_duration - _last_then_duration)

	_add_parallel_animation_by_animation_type(type, data)

func end() -> void:
	_end_called = true

	if _animation_name:
		var animation_data = {}

		animation_data.animation = _animation_name

		if _duration:
			animation_data.duration = _duration

		_add_parallel_animation_by_animation_type(_animation_type, animation_data)

	_anima_node.set_visibility_strategy(_visibility_strategy)

func _add_parallel_animation_by_animation_type(animation_type: int, animation_data: Dictionary) -> void:
	if not animation_data.has('items_delay'):
		animation_data.items_delay = _children_delay

	match animation_type:
		Anima.GRID.SEQUENCE_TOP_LEFT:
			_generate_animation_sequence_top_left(animation_data)
		Anima.GRID.TOGETHER:
			_generate_animation_all_together(animation_data)
		Anima.GRID.COLUMNS_EVEN:
			_generate_animation_for_even_columns(animation_data)
		Anima.GRID.COLUMNS_ODD:
			_generate_animation_for_odd_columns(animation_data)
		Anima.GRID.ROWS_ODD:
			_generate_animation_for_odd_rows(animation_data)
		Anima.GRID.ROWS_EVEN:
			_generate_animation_for_even_rows(animation_data)
		Anima.GRID.ODD:
			_generate_animation_for_odd_items(animation_data)
		Anima.GRID.EVEN:
			_generate_animation_for_even_items(animation_data)

func _generate_animation_sequence_top_left(animation_data: Dictionary) -> void:
	var nodes := []
	for row in _children:
		for child in row:
			nodes.push_back(child)

	_animation_with(nodes, animation_data)

func _generate_animation_all_together(animation_data: Dictionary) -> void:
	var nodes := []
	for row in _children:
		for child in row:
			nodes.push_back(child)

	animation_data.items_delay = 0
	_animation_with(nodes, animation_data)

func _generate_animation_for_even_columns(animation_data: Dictionary) -> void:
	var columns := []
	var rows := []

	for row in _grid_size.x:
		rows.push_back(row)

	for column in _grid_size.y:
		if column % 2 == 0:
			columns.push_back(column)

	_generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_odd_columns(animation_data: Dictionary) -> void:
	var columns := []
	var rows := []

	for row in _grid_size.x:
		rows.push_back(row)

	for column in _grid_size.y:
		if column % 2 != 0:
			columns.push_back(column)

	_generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_odd_rows(animation_data: Dictionary) -> void:
	var columns := []
	var rows := []

	for row in _grid_size.x:
		if row % 2 != 0:
			rows.push_back(row)

	for column in _grid_size.y:
		columns.push_back(column)

	_generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_even_rows(animation_data: Dictionary) -> void:
	var columns := []
	var rows := []

	for row in _grid_size.x:
		if row % 2 == 0:
			rows.push_back(row)

	for column in _grid_size.y:
		columns.push_back(column)

	_generate_animation_for(rows, columns, animation_data)

func _generate_animation_for(rows: Array, columns: Array, animation_data: Dictionary) -> void:
	var nodes := []

	for row in rows:
		for column in columns:
			nodes.push_back(_children[row][column])

	_animation_with(nodes, animation_data)

func _generate_animation_for_odd_items(animation_data: Dictionary) -> void:
	var nodes := []
	
	for row_index in _children.size():
		for column_index in _children[row_index].size():
			if (column_index + row_index)  % 2 == 0:
				var child = _children[row_index][column_index]

				nodes.push_back(child)

	_animation_with(nodes, animation_data)

func _generate_animation_for_even_items(animation_data: Dictionary) -> void:
	var nodes := []
	
	for row_index in _children.size():
		for column_index in _children[row_index].size():
			if (column_index + row_index)  % 2 != 0:
				var child = _children[row_index][column_index]

				nodes.push_back(child)

	_animation_with(nodes, animation_data)

func _animation_with(nodes: Array, animation_data: Dictionary):
	var delay = _initil_delay

	var index = 0
	for node in nodes:
		var data = animation_data.duplicate()

		data.node = node
		if not data.has('delay'):
			data.delay = 0

		data.delay += _initil_delay + (data.items_delay * index)

		_anima_node.with(data)
		index += 1

func _on_anima_animation_completed() -> void:
	emit_signal("animation_completed")

func _on_anima_animation_started() -> void:
	emit_signal("animation_started")

func _on_anima_loop_started() -> void:
	emit_signal("loop_started")

func _on_anima_loop_completed() -> void:
	emit_signal("loop_completed")
