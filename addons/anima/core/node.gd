class_name AnimaNode
extends Node

signal animation_started
signal animation_completed
signal loop_started
signal loop_completed

var _anima_tween := AnimaTween.new()

var _total_animation := 0.0
var _last_animation_duration := 0.0

var _timer := Timer.new()
var _loop_times := 0
var _loop_count := 0
var _should_loop := false
var _loop_strategy = Anima.LOOP.USE_EXISTING_RELATIVE_DATA

var __do_nothing := 0.0

func _ready():
	if _timer.get_parent() != self:
		_init_node(self)

func _exit_tree():
	_timer.stop()
	_anima_tween.stop_all()

	_timer.queue_free()
	_anima_tween.queue_free()

func _init_node(node: Node):
	_timer.one_shot = true
	_timer.autostart = false
	_timer.connect("timeout", self, '_on_timer_timeout')

	_anima_tween.connect("tween_all_completed", self, '_on_all_tween_completed')

	add_child(_timer)
	add_child(_anima_tween)

	if node != self:
		node.add_child(self)

func then(data: Dictionary) -> float:
	data._wait_time = _total_animation

	_last_animation_duration = _setup_animation(data)

	var delay = data.delay if data.has('delay') else 0.0
	_total_animation += _last_animation_duration + delay

	return _last_animation_duration

func with(data: Dictionary) -> float:
	var start_time := 0.0
	var delay = data.delay if data.has('delay') else 0.0

	start_time = max(0, _total_animation - _last_animation_duration)

	if not data.has('duration'):
		if _last_animation_duration > 0:
			data.duration = _last_animation_duration
		else:
			data.duration = Anima.DEFAULT_DURATION

	if not data.has('_wait_time'):
		data._wait_time = start_time

	return _setup_animation(data)

func wait(seconds: float) -> void:
	then({
		node = self,
		property = '__do_nothing',
		from = 0.0,
		to = 1.0,
		duration = seconds,
	})

func set_visibility_strategy(strategy: int) -> void:
	_anima_tween.set_visibility_strategy(strategy)
	
func clear() -> void:
	stop()

	_anima_tween.clear_animations()

	_total_animation = 0.0
	_last_animation_duration = 0.0

func play() -> void:
	_loop_times = 1
	_timer.wait_time = 0.00001
	_timer.one_shot = true

	_timer.start()

func stop() -> void:
	_timer.stop()
	_anima_tween.stop_all()

func loop(times: int = -1) -> void:
	_loop_times = times
	_timer.wait_time = 0.00001
	_should_loop = times == -1

	# Can't use _anima_tween.repeat
	# as the tween_all_completed is never called :(
	# But we need it to reset some stuff
	_do_play()

func loop_with_delay(delay: float, times: int = -1) -> void:
	_loop_times = times
	_timer.wait_time = 0.00001
	_should_loop = true

	# Can't use _anima_tween.repeat
	# as the tween_all_completed is never called :(
	# But we need it to reset some stuff
	_do_play()
	
	_timer.wait_time = max(0.00001, delay)

func loop_times_with_delay(times: float, delay: float) -> void:
	_loop_times = times
	_timer.wait_time = 0.00001
	_should_loop = times == -1

	# Can't use _anima_tween.repeat
	# as the tween_all_completed is never called :(
	# But we need it to reset some stuff
	_do_play()
	
	_timer.wait_time = max(0.00001, delay)

func play_with_delay(delay: float) -> void:
	_loop_times = 1

	_timer.set_wait_time(delay)
	_timer.start()

func get_length() -> float:
	return _total_animation

func _do_play() -> void:
	# Allows to reset the "relative" properties to the value of the 1st loop
	# before doing another loop
	_anima_tween.reset_data(_loop_strategy)

	_loop_count += 1

	_anima_tween.play()
	
	emit_signal("animation_started")
	emit_signal("loop_started", _loop_count)

func set_loop_strategy(strategy: int):
	_loop_strategy = strategy

func _setup_animation(data: Dictionary) -> float:
	if data.has('grid'):
		if not data.has('grid_size'):
			printerr('Please specify the grid size, or use `group` instead')

			return 0.0

		return _setup_grid_animation(data)
	elif data.has('group'):
		if not data.has('grid_size'):
			data.grid_size = Vector2(1, data.group.get_children_count())

		return _setup_grid_animation(data)
	elif not data.has('node'):
		 data.node = self.get_parent()

	return _setup_node_animation(data)

func _setup_node_animation(data: Dictionary) -> float:
	var node = data.node
	var delay = data.delay if data.has('delay') else 0.0
	var duration = data.duration if data.has('duration') else Anima.DEFAULT_DURATION

	node.set_meta('__pivot_applied', null)
	data._wait_time = max(0.0, data._wait_time + delay)

	if data.has('property') and not data.has('animation'):
		data._is_first_frame = true
		data._is_last_frame = true

	if data.has('animation'):
		var script = Anima.get_animation_script(data.animation)

		if not script:
			printerr('animation not found: %s' % data.animation)

			return duration

		var real_duration = script.generate_animation(_anima_tween, data)
		if real_duration is float:
			duration = real_duration
	else:
		_anima_tween.add_animation_data(data)

	return duration

func _setup_grid_animation(animation_data: Dictionary) -> float:
	var animation_type = Anima.GRID.SEQUENCE_TOP_LEFT
	
	if animation_data.has('animation_type'):
		animation_type = animation_data.animation_type

	if not animation_data.has('items_delay'):
		animation_data.items_delay = Anima.DEFAULT_ITEMS_DELAY

	if animation_data.has('grid'):
		animation_data._grid_node = animation_data.grid
	else:
		animation_data._grid_node = animation_data.group

	animation_data.erase('grid')
	animation_data.erase('group')

	var duration: float

	match animation_type:
		Anima.GRID.SEQUENCE_TOP_LEFT:
			duration = _generate_animation_sequence_top_left(animation_data)
		Anima.GRID.TOGETHER:
			duration = _generate_animation_all_together(animation_data)
		Anima.GRID.COLUMNS_EVEN:
			duration = _generate_animation_for_even_columns(animation_data)
		Anima.GRID.COLUMNS_ODD:
			duration = _generate_animation_for_odd_columns(animation_data)
		Anima.GRID.ROWS_ODD:
			duration = _generate_animation_for_odd_rows(animation_data)
		Anima.GRID.ROWS_EVEN:
			duration = _generate_animation_for_even_rows(animation_data)
		Anima.GRID.ODD:
			duration = _generate_animation_for_odd_items(animation_data)
		Anima.GRID.EVEN:
			duration = _generate_animation_for_even_items(animation_data)

	return duration

func _get_children(animation_data: Dictionary) -> Array:
	var grid_node = animation_data._grid_node
	var grid_size = animation_data.grid_size

	var children := []
	var rows: int = grid_size.x
	var columns: int = grid_size.y

	var row_items := []
	var index := 0

	for child in grid_node.get_children():
		# Skip current node :)
		if '__do_nothing' in child:
			continue

		row_items.push_back(child)

		index += 1
		if index >= columns:
			children.push_back(row_items)
			row_items = []
			index = 0

	if row_items.size() > 0:
		children.push_back(row_items)

	return children

func _generate_animation_sequence_top_left(animation_data: Dictionary) -> float:
	var nodes := []
	for row in _get_children(animation_data):
		for child in row:
			nodes.push_back(child)

	return _create_grid_animation_with(nodes, animation_data)

func _generate_animation_all_together(animation_data: Dictionary) -> float:
	var nodes := []
	for row in _get_children(animation_data):
		for child in row:
			nodes.push_back(child)

	animation_data.items_delay = 0

	return _create_grid_animation_with(nodes, animation_data)

func _generate_animation_for_even_columns(animation_data: Dictionary) -> float:
	var columns := []
	var rows := []
	var grid_size = animation_data.grid_size

	for row in grid_size.x:
		rows.push_back(row)

	for column in grid_size.y:
		if column % 2 == 0:
			columns.push_back(column)

	return _generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_odd_columns(animation_data: Dictionary) -> float:
	var columns := []
	var rows := []
	var grid_size = animation_data.grid_size

	for row in grid_size.x:
		rows.push_back(row)

	for column in grid_size.y:
		if column % 2 != 0:
			columns.push_back(column)

	return _generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_odd_rows(animation_data: Dictionary) -> float:
	var columns := []
	var rows := []
	var grid_size = animation_data.grid_size

	for row in grid_size.x:
		if row % 2 != 0:
			rows.push_back(row)

	for column in grid_size.y:
		columns.push_back(column)

	return _generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_even_rows(animation_data: Dictionary) -> float:
	var columns := []
	var rows := []
	var grid_size = animation_data.grid_size

	for row in grid_size.x:
		if row % 2 == 0:
			rows.push_back(row)

	for column in grid_size.y:
		columns.push_back(column)

	return _generate_animation_for(rows, columns, animation_data)

func _generate_animation_for(rows: Array, columns: Array, animation_data: Dictionary) -> float:
	var nodes := []
	var children = _get_children(animation_data)

	for row in rows:
		for column in columns:
			nodes.push_back(children[row][column])

	return _create_grid_animation_with(nodes, animation_data)

func _generate_animation_for_odd_items(animation_data: Dictionary) -> float:
	var nodes := []
	var children = _get_children(animation_data)

	for row_index in children.size():
		for column_index in children[row_index].size():
			if (column_index + row_index)  % 2 == 0:
				var child = children[row_index][column_index]

				nodes.push_back(child)

	return _create_grid_animation_with(nodes, animation_data)

func _generate_animation_for_even_items(animation_data: Dictionary) -> float:
	var nodes := []
	var children = _get_children(animation_data)

	for row_index in children.size():
		for column_index in children[row_index].size():
			if (column_index + row_index)  % 2 != 0:
				var child = children[row_index][column_index]

				nodes.push_back(child)

	return _create_grid_animation_with(nodes, animation_data)

func _create_grid_animation_with(nodes: Array, animation_data: Dictionary) -> float:
	var index = 0
	for node in nodes:
		var data = animation_data.duplicate()

		data.node = node
		if not data.has('delay'):
			data.delay = 0

		data.delay += data.items_delay * index

		with(data)

		index += 1

	return animation_data.duration + (animation_data.items_delay * nodes.size())

func _on_timer_timeout() -> void:
	_do_play()

	_loop_times -= 1

	if _loop_times > 0 or _should_loop:
		_do_play()

func _on_all_tween_completed() -> void:
	emit_signal("animation_completed")
	emit_signal("loop_completed", _loop_count)

	if _should_loop:
		_timer.start()
