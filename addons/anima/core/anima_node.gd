tool
class_name AnimaNode
extends Node

signal animation_started
signal animation_completed
signal loop_started
signal loop_completed

var _anima_tween := AnimaTween.new()
var _anima_backwards_tween := AnimaTween.new()
var _timer := Timer.new()

var _total_animation_length := 0.0
var _last_animation_duration := 0.0

var _loop_times := 0
var _loop_count := 0
var _should_loop := false
var _play_mode: int = AnimaTween.PLAY_MODE.NORMAL
var _default_duration = Anima.DEFAULT_DURATION
var _apply_visibility_strategy_on_play := true
var _play_speed := 1.0
var _current_play_mode: int = AnimaTween.PLAY_MODE.NORMAL
var _is_single_shot := false
var _visibility_strategy: int = Anima.VISIBILITY.IGNORE

var __do_nothing := 0.0
var _last_tween_data: Dictionary

func _exit_tree():
	if _anima_tween == null or not is_instance_valid(_anima_tween):
		return

	for child in get_children():
		child.free()

func _ready():
	if not _anima_tween.is_connected("animation_completed", self, "_on_all_tween_completed"):
		init_node(self)

	_timer.one_shot = true
	_timer.connect("timeout", self, "_on_timer_completed")

	add_child(_timer)

func init_node(node: Node):
	_anima_tween.connect("animation_completed", self, '_on_all_tween_completed')
	_anima_backwards_tween.connect("animation_completed", self, '_on_all_tween_completed')

	add_child(_anima_tween)
	add_child(_anima_backwards_tween)

	if node != self:
		node.add_child(self)

func then(data) -> AnimaNode:
	if not data is Dictionary:
		data = data.get_data()
		data.__ignore_warning = true
	elif not data.has("__ignore_warning"):
		printerr(
			"Passing data as Dictionary has been deprecated and will be removed in the future versions.",
			"\n",
			"Visit https://anima.ceceppa.me/docs/docs/anima-declaration for more info"
		)
		print_stack()
		print(data)
		print("\n")

	if data.has("group") and data.group is Array:
		return _group(data.group, data)

	data._wait_time = _total_animation_length

	_last_tween_data = data.duplicate()
	_last_animation_duration = _setup_animation(data)

	var delay = data.delay if data.has('delay') else 0.0
	_total_animation_length += _last_animation_duration + delay

	return self

func with(data) -> AnimaNode:
	if not data is Dictionary:
		data = data.get_data()
		data.__ignore_warning = true
	elif not data.has("__ignore_warning"):
		printerr(
			"Passing data as Dictionary has been deprecated and will be removed in the future versions.",
			"\n",
			"Visit https://anima.ceceppa.me/docs/docs/anima-declaration for more info"
		)
		print(data)
		print("\n")
		print_stack()

	var start_time := 0.0
	var delay = data.delay if data.has('delay') else 0.0

	start_time = max(0, _total_animation_length - _last_animation_duration)

	if not data.has("duration"):
		if _last_animation_duration > 0:
			data.duration = _last_animation_duration
		else:
			data.duration = _default_duration

	if not data.has('_wait_time'):
		data._wait_time = start_time

	if not data.has("__do_not_update_last_tween_data"):
		_last_tween_data = data

	_setup_animation(data)

	return self

func _group(group_data: Array, animation_data: Dictionary) -> AnimaNode:
	var delay_index := 0

	_total_animation_length += animation_data.duration

	if not animation_data.has('items_delay'):
		printerr('Please specify the `items_delay` value')

		return self

	var items = group_data.size() - 1
	var on_completed = animation_data.on_completed if animation_data.has('on_completed') else null
	var on_started = animation_data.on_started if animation_data.has('on_started') else null

	animation_data.erase("group")
	animation_data.erase('on_completed')
	animation_data.erase('on_started')

	for index in group_data.size():
		var group_item: Dictionary = group_data[index]
		var data = animation_data.duplicate()

		data._wait_time = animation_data.items_delay * delay_index

		if group_item.has('node'):
			data.node = group_item.node
			delay_index += 1
		else:
			data.group = group_item.group
			delay_index += data.group.get_child_count()

		if index == 0 and on_started:
			data.on_started = on_started

		if index == items and on_completed:
			data.on_completed = on_completed

		with(data)

	_total_animation_length += animation_data.items_delay * (delay_index - 1)

	return self

func wait(seconds: float) -> AnimaNode:
	return then({
		node = self,
		property = '__do_nothing',
		from = 0.0,
		to = 1.0,
		duration = seconds,
	})

func set_single_shot(single_shot: bool) -> AnimaNode:
	_is_single_shot = single_shot

	if _is_single_shot:
		_anima_tween.set_repeat(false)

	return self

func is_single_shot() -> bool:
	return _is_single_shot

func set_visibility_strategy(strategy: int, always_apply_on_play := true) -> AnimaNode:
	_visibility_strategy = strategy

	_anima_tween.set_visibility_strategy(strategy)
	_anima_backwards_tween.set_visibility_strategy(strategy)

	if always_apply_on_play:
		_apply_visibility_strategy_on_play = true

	return self

func clear() -> void:
	stop()

	_anima_tween.clear_animations()
	_anima_backwards_tween.clear_animations()

	_total_animation_length = 0.0
	_last_animation_duration = 0.0
	_visibility_strategy = Anima.VISIBILITY.IGNORE

func play() -> void:
	_play(AnimaTween.PLAY_MODE.NORMAL)

func play_with_delay(delay: float) -> void:
	_play(AnimaTween.PLAY_MODE.NORMAL, delay)

func play_with_speed(speed: float) -> void:
	_play(AnimaTween.PLAY_MODE.NORMAL, 0.0, speed)

func play_backwards() -> void:
	_play(AnimaTween.PLAY_MODE.BACKWARDS)

func play_backwards_with_delay(delay: float) -> void:
	_play(AnimaTween.PLAY_MODE.BACKWARDS, delay)

func play_backwards_with_speed(speed: float) -> void:
	_play(AnimaTween.PLAY_MODE.BACKWARDS, 0.0, speed)

func _play(mode: int, delay: float = 0, speed := 1.0) -> void:
	if not is_inside_tree():
		return

	_loop_times = 1
	_play_mode = mode
	_current_play_mode = mode
	_play_speed = speed

	if _apply_visibility_strategy_on_play and mode == AnimaTween.PLAY_MODE.NORMAL:
		set_visibility_strategy(_visibility_strategy)

	_timer.wait_time = max(Anima.MINIMUM_DURATION, delay)
	_timer.start()

func _on_timer_completed() -> void:
	_do_play()
	_maybe_play()

func stop() -> void:
	_anima_tween.stop_all()
	_anima_backwards_tween.stop_all()

func loop(times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL)

func loop_in_circle(times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE)

func loop_in_circle_with_delay(delay: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE, delay)

func loop_in_circle_with_speed(speed: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE, Anima.MINIMUM_DURATION, speed)

func loop_in_circle_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE, delay, speed)

func loop_backwards(times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.BACKWARDS)

func loop_backwards_with_speed(speed: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.BACKWARDS, Anima.MINIMUM_DURATION, speed)

func loop_backwards_with_delay(delay: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay)

func loop_backwards_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay, speed)

func loop_with_delay(delay: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay)

func loop_with_speed(speed: float, times: int = -1) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL, Anima.MINIMUM_DURATION, speed)

func loop_times_with_delay(times: float, delay: float) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay)

func loop_times_with_delay_and_speed(times: int, delay: float, speed: float) -> void:
	_do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay, speed)

func _do_loop(times: int, mode: int, delay: float = Anima.MINIMUM_DURATION, speed := 1.0) -> void:
	_loop_times = times
	_should_loop = times == -1
	_play_mode = mode

	if mode != AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE:
		_current_play_mode = mode
	else:
		_current_play_mode = AnimaTween.PLAY_MODE.NORMAL

	_play_speed = speed

	_timer.wait_time = max(Anima.MINIMUM_DURATION, delay)
	_timer.start()

func get_length() -> float:
	return _total_animation_length

func set_root_node(node) -> void:
	_anima_tween.set_root_node(node)

func _do_play() -> void:
	var play_mode: int = _play_mode
	var is_loop_in_circle = _play_mode == AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE

	if is_loop_in_circle:
		play_mode = _current_play_mode

	_loop_count += 1

	var tween: AnimaTween = _anima_tween
	if play_mode == AnimaTween.PLAY_MODE.BACKWARDS:
		if not _anima_backwards_tween.has_data():
			_anima_backwards_tween.reverse_animation(_anima_tween.get_animation_data(), _total_animation_length, _default_duration)

		tween = _anima_backwards_tween

	tween.play(_play_speed)

	emit_signal("animation_started")
	emit_signal("loop_started", _loop_count)

	if not is_loop_in_circle:
		return

	if _current_play_mode == AnimaTween.PLAY_MODE.NORMAL:
		_current_play_mode = AnimaTween.PLAY_MODE.BACKWARDS
	else:
		_current_play_mode = AnimaTween.PLAY_MODE.NORMAL

func set_loop_strategy(strategy: int):
	_anima_tween.set_loop_strategy(strategy)
	_anima_backwards_tween.set_loop_strategy(strategy)

func set_default_duration(duration: float) -> AnimaNode:
	_default_duration = duration

	return self

func _setup_animation(data: Dictionary) -> float:
	if not data.has('duration'):
		 data.duration = _default_duration

	if not data.has('property') and not data.has("animation"):
		printerr('Please specify the property to animate or the animation to use!', data)

		return 0.0

	if data.has('grid'):
		if not data.has('grid_size'):
			printerr('Please specify the grid size, or use `group` instead')

			return 0.0

		return _setup_grid_animation(data)
	elif data.has("group"):
		if not data.has('grid_size'):
			data.grid_size = Vector2(1, data.group.get_children().size())

		return _setup_grid_animation(data)
	elif not data.has("node"):
		 data.node = self.get_parent()

	if data.node == null:
		printerr("Invalid node!")

		return 0.0

	return _setup_node_animation(data)

func _setup_node_animation(data: Dictionary) -> float:
	var node = data.node
	var delay = data.delay if data.has('delay') else 0.0
	var duration = data.duration

	data._wait_time = max(0.0, data._wait_time + delay)

	if data.has("property") and not data.has("animation"):
		data._is_first_frame = true
		data._is_last_frame = true

	if data.has("animation"):
		var keyframes = data.animation

		if keyframes is String:
			keyframes = AnimaAnimationsUtils.get_animation_keyframes(data.animation)

			if keyframes.size() == 0:
				printerr('animation not found: %s' % data.animation)

				return duration

		var real_duration = _anima_tween.add_frames(data, keyframes)

		if real_duration > 0:
			duration = real_duration
	else:
		_anima_tween.add_animation_data(data)

	return duration

func _setup_grid_animation(animation_data: Dictionary) -> float:
	var animation_type = Anima.GRID.SEQUENCE_TOP_LEFT
	
	if animation_data.has("animation_type"):
		animation_type = animation_data.animation_type

	if not animation_data.has("items_delay"):
		animation_data.items_delay = Anima.DEFAULT_ITEMS_DELAY

	if animation_data.has("grid"):
		animation_data._grid_node = animation_data.grid
	else:
		animation_data._grid_node = animation_data.group

	animation_data.erase("grid")
	animation_data.erase("group")

	var duration: float

	match animation_type:
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
		_:
			duration = _generate_animation_sequence(animation_data, animation_type)

	return animation_data.duration

func _get_children(animation_data: Dictionary, shuffle := false) -> Array:
	var grid_node = animation_data._grid_node
	var grid_size = animation_data.grid_size

	var nodes := []
	var rows: int = grid_size.x
	var columns: int = grid_size.y

	var row_items := []
	var index := 0

	var children: Array = grid_node.get_children()
	
	if shuffle:
		randomize()

		children.shuffle()

	for child in children:
		# Skip current node :)
		if '__do_nothing' in child:
			continue
		elif animation_data.has('skip_hidden') and not child.is_visible():
			continue
		elif animation_data.has("of") and child.get_class() != animation_data.of:
			continue

		row_items.push_back(child)

		index += 1
		if index >= columns:
			nodes.push_back(row_items)
			row_items = []
			index = 0

	if row_items.size() > 0:
		nodes.push_back(row_items)

	return nodes

func _generate_animation_sequence(animation_data: Dictionary, start_from: int) -> float:
	var nodes := []
	var children := _get_children(animation_data, start_from == Anima.GRID.RANDOM)
	var is_grid: bool = animation_data.grid_size.x > 1
	var grid_size: Vector2 = animation_data.grid_size
	var from_x: int
	var from_y: int

	from_y = grid_size.y / 2
	from_x = grid_size.x / 2

	if start_from == Anima.GRID.FROM_POINT and not animation_data.has('point'):
		start_from = Anima.GRID.FROM_CENTER

	for row_index in children.size():
		var row: Array = children[row_index]
		var from_index = 0

		if start_from == Anima.GRID.SEQUENCE_BOTTOM_RIGHT:
			from_index = row.size() - 1
		elif start_from == Anima.GRID.FROM_CENTER:
			from_index = (row.size() - 1) / 2
		elif start_from == Anima.GRID.FROM_POINT:
			if is_grid:
				from_y = animation_data.point.y
				from_x = animation_data.point.x
			else:
				from_index = animation_data.point.x

		for index in row.size():
			var current_index = index
			var distance: int = abs(from_index - current_index)
			
			if is_grid:
				var distance_x = index - from_y
				var distance_y = row_index - from_x

				distance = sqrt(distance_x * distance_x + distance_y * distance_y)

			var node = row[index]

			nodes.push_back({ node = node, delay_index = distance })

	return _create_grid_animation_with(nodes, animation_data)

func _generate_animation_sequence_bottom_right(animation_data: Dictionary) -> float:
	var nodes := []

	for row in _get_children(animation_data):
		for child in row:
			nodes.push_front(child)

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
	var total_nodes = nodes.size() - 1
	var on_completed = animation_data.on_completed if animation_data.has('on_completed') else null
	var on_started = animation_data.on_started if animation_data.has('on_started') else null

	animation_data.erase('on_completed')
	animation_data.erase('on_started')

	for index in nodes.size():
		var node = nodes[index]
		var delay_index = index

		if node is Dictionary:
			delay_index = node.delay_index
			node = node.node

		var data = animation_data.duplicate()

		data.node = node

		if not data.has('delay'):
			data.delay = 0

		data.delay += data.items_delay * delay_index

		if index == 0 and on_started:
			data.on_started = on_started

		if index == total_nodes and on_completed:
			data.on_completed = on_completed

		with(data)

	return animation_data.duration + (animation_data.items_delay * nodes.size())

func _maybe_play() -> void:
	_loop_times -= 1

	if _loop_times > 0 or _should_loop:
		_do_play()

func _on_all_tween_completed() -> void:
	emit_signal("animation_completed")
	emit_signal("loop_completed", _loop_count)

	if _is_single_shot:
		queue_free()

		return

	if _should_loop:
		_maybe_play()
