@tool
class_name AnimaNode
extends Node

signal animation_started
signal animation_completed
signal loop_started
signal loop_completed

var _anima_tween := AnimaTween.new()

var _timer := Timer.new()
var _anima_reverse_tween := AnimaTween.new()
var _total_animation_length := 0.0
var _last_animation_duration := 0.0

var _loop_times := 0
var _loop_count := 0
var _should_loop := false
var _play_mode: int = AnimaTween.PLAY_MODE.NORMAL
var _default_duration = ANIMA.DEFAULT_DURATION
var _apply_visibility_strategy_on_play := true
var _play_speed := 1.0
var _current_play_mode: int = AnimaTween.PLAY_MODE.NORMAL
var _is_single_shot := false
var _visibility_strategy: int = ANIMA.VISIBILITY.IGNORE
var _loop_delay := 0.0

var __do_nothing := 0.0
var _last_tween_data: Dictionary
var _has_on_completed := false

func _exit_tree():
	if _anima_tween == null or not is_instance_valid(_anima_tween):
		return

	clear()

	for child in get_children():
		child.free()

func _ready():
	if not _anima_tween.is_connected("animation_completed",Callable(self,"_on_all_tween_completed")):
		init_node(self)

	_timer.one_shot = true
	_timer.connect("timeout",Callable(self,"_on_timer_completed"))

	add_child(_timer)

func init_node(node: Node):
	_anima_tween.connect("animation_completed",Callable(self,'_on_all_tween_completed'))

	add_child(_anima_tween)
	add_child(_anima_reverse_tween)

	if node != self:
		node.add_child(self)

func then(data) -> AnimaNode:
	if not data is Dictionary:
		data = data.get_data()

	data._wait_time = _total_animation_length

	_last_tween_data = data.duplicate()
	_last_animation_duration = _setup_animation(data)

	var delay = data.delay if data.has('delay') else 0.0
	_total_animation_length += _last_animation_duration + delay

	return self

func with(data) -> AnimaNode:
	if not data is Dictionary:
		data = data.get_data()

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

func wait(seconds: float) -> AnimaNode:
	return then({
		node = self,
		property = '__do_nothing',
		from = 0.0,
		to = 1.0,
		duration = seconds,
	})

func skip(_ignore) -> AnimaNode:
	return self

func set_single_shot(single_shot: bool) -> AnimaNode:
	_is_single_shot = single_shot

	if _is_single_shot:
		_anima_tween.set_repeat(false)

	return self

func is_single_shot() -> bool:
	return _is_single_shot

func set_visibility_strategy(strategy: int, always_apply_on_play := true) -> AnimaNode:
	_visibility_strategy = strategy

	if not is_instance_valid(_anima_tween):
		return self

	_anima_tween.set_visibility_strategy(strategy)
	_anima_reverse_tween.set_visibility_strategy(strategy)

	if always_apply_on_play:
		_apply_visibility_strategy_on_play = true

	return self

func clear() -> void:
	if not is_instance_valid(_anima_tween) or _anima_tween.is_queued_for_deletion():
		return

	stop()

	_anima_tween.clear_animations()
	_anima_reverse_tween.clear_animations()

	_total_animation_length = 0.0
	_last_animation_duration = 0.0

	_loop_delay = 0.0

	_visibility_strategy = ANIMA.VISIBILITY.IGNORE

func play() -> AnimaNode:
	return _play(AnimaTween.PLAY_MODE.NORMAL)

func play_with_delay(delay: float) -> AnimaNode:
	return _play(AnimaTween.PLAY_MODE.NORMAL, delay)

func play_with_speed(speed: float) -> AnimaNode:
	return _play(AnimaTween.PLAY_MODE.NORMAL, 0.0, speed)

func play_backwards() -> AnimaNode:
	return _play(AnimaTween.PLAY_MODE.BACKWARDS)

func play_backwards_with_delay(delay: float) -> AnimaNode:
	return _play(AnimaTween.PLAY_MODE.BACKWARDS, delay)

func play_backwards_with_speed(speed: float) -> AnimaNode:
	return _play(AnimaTween.PLAY_MODE.BACKWARDS, 0.0, speed)

func play_as_backwards_when(when: bool) -> AnimaNode:
	if when:
		return _play(AnimaTween.PLAY_MODE.BACKWARDS)

	return _play(AnimaTween.PLAY_MODE.NORMAL)

func _play(mode: int, delay: float = 0.0, speed := 1.0) -> AnimaNode:
	if not is_inside_tree():
		return self

	if _anima_tween.get_animation_data().size() == 0:
		return self

	_loop_times = 1
	_play_mode = mode
	_current_play_mode = mode
	_play_speed = speed

	if _apply_visibility_strategy_on_play and mode == AnimaTween.PLAY_MODE.NORMAL:
		set_visibility_strategy(_visibility_strategy)

	_timer.wait_time = max(ANIMA.MINIMUM_DURATION, delay)
	_timer.start()

	return self

func _on_timer_completed() -> void:
	_do_play()
	_maybe_play()

func stop() -> AnimaNode:
	_should_loop = false
	_loop_count = 0

	if is_instance_valid(_anima_tween):
		_anima_tween.stop()
		_anima_reverse_tween.stop()

	return self

func loop(times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL)

func loop_in_circle(times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE)

func loop_in_circle_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE, delay)

func loop_in_circle_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE, ANIMA.MINIMUM_DURATION, speed)

func loop_in_circle_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE, delay, speed)

func loop_backwards(times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.BACKWARDS)

func loop_backwards_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.BACKWARDS, ANIMA.MINIMUM_DURATION, speed)

func loop_backwards_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay)

func loop_backwards_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> AnimaNode:
	_loop_delay = 0.0
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay, speed)

func loop_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay)

func loop_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL, ANIMA.MINIMUM_DURATION, speed)

func loop_times_with_delay(times: float, delay: float) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay)

func loop_times_with_delay_and_speed(times: int, delay: float, speed: float) -> AnimaNode:
	return _do_loop(times, AnimaTween.PLAY_MODE.NORMAL, delay, speed)

func _do_loop(times: int, mode: int, delay_between_loops: float = ANIMA.MINIMUM_DURATION, speed := 1.0) -> AnimaNode:
	_loop_times = times
	_should_loop = times == -1
	_play_mode = mode

	if _loop_times < 0 and _is_single_shot:
		printerr("Cannot use single shot with loop! The animation will be played only once.\nUse the 'normal' AnimaNode instead")

	if mode != AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE:
		_current_play_mode = mode
	else:
		_current_play_mode = AnimaTween.PLAY_MODE.NORMAL

	_play_speed = speed
	_loop_delay = delay_between_loops

	_do_play()

	return self

func get_duration() -> float:
	return _total_animation_length

func set_root_node(node) -> void:
	if is_instance_valid(_anima_tween) and not _anima_tween.is_queued_for_deletion():
		_anima_tween.set_root_node(node)

func _do_play() -> void:
	var play_mode: int = _play_mode
	var is_loop_in_circle = _play_mode == AnimaTween.PLAY_MODE.LOOP_IN_CIRCLE

	if is_loop_in_circle:
		play_mode = _current_play_mode

	_loop_count += 1
	_anima_tween.is_playing_backwards = false

	var tween: AnimaTween = _anima_tween
	var duration = _anima_tween.get_duration()

	if play_mode == AnimaTween.PLAY_MODE.BACKWARDS:
		_anima_reverse_tween.is_playing_backwards = true

		if not _anima_reverse_tween.has_data():
			_anima_reverse_tween.reverse_animation(_anima_tween, _default_duration)

		tween = _anima_reverse_tween
	else:
		_anima_tween.do_apply_initial_values()

	tween.play(_play_speed)

	emit_signal("animation_started")
	emit_signal("loop_started", _loop_count)

	if not is_loop_in_circle:
		return

	if _current_play_mode == AnimaTween.PLAY_MODE.NORMAL:
		_current_play_mode = AnimaTween.PLAY_MODE.BACKWARDS
	else:
		_current_play_mode = AnimaTween.PLAY_MODE.NORMAL

func set_default_duration(duration: float) -> AnimaNode:
	_default_duration = duration

	return self

func set_apply_initial_values(when: int) -> AnimaNode:
	_anima_tween.set_apply_initial_values(when)

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

	var node: Node = data.node
	var meta_key: String = ""

	if data.has("property"):
		meta_key = "AnimaInitial%s%s" % [str(node.name).replace("-", "").replace(" ", ""), str(data.property).replace("_", "")]

	if meta_key.length() > 0 and not data.has("from") and data.has("property") and not node.has_meta(meta_key):
		data.node.set_meta(meta_key, AnimaNodesProperties.get_property_value(node, data, data.property))

	return _setup_node_animation(data)

func _setup_node_animation(data: Dictionary) -> float:
	var n = data.node
	var are_multiple_nodes :=  data.has("nodes")
	var nodes: Array = data.nodes if are_multiple_nodes else []
	var delay = data.delay if data.has('delay') else 0.0
	var duration = data.duration

	data._wait_time = max(0.0, data._wait_time + delay)

	if not are_multiple_nodes and n:
		nodes.push_back(n)

	data.erase("nodes")

	for node_index in nodes.size():
		var node = nodes[node_index]
		data.node = node
		data._is_first_frame = true

		if are_multiple_nodes:
			data._wait_time += data.items_delay * node_index

		if data.has("on_started"):
			_anima_tween.add_event_frame(data, "on_started", data._wait_time)

		if data.has("animation"):
			var keyframes = data.animation

			if keyframes is String:
				keyframes = AnimaAnimationsUtils.get_animation_keyframes(keyframes)

				if keyframes.size() == 0:
					printerr('animation not found: %s' % keyframes)

					continue

			var the_data = data.duplicate()
			the_data.erase("animation")

			var real_duration = _anima_tween.add_frames(the_data, keyframes)

			if real_duration > 0:
				duration = real_duration
		else:
			if is_instance_valid(_anima_tween):
				_anima_tween.add_animation_data(data)

		if are_multiple_nodes:
			delay += data.items_delay

		if data.has("on_completed"):
			_has_on_completed = true
			_anima_tween.add_event_frame(data, "on_completed", data._wait_time + data.duration)

	return duration

func _setup_grid_animation(animation_data: Dictionary) -> float:
	var animation_type = ANIMA.GRID.SEQUENCE_TOP_LEFT

	if animation_data.has("animation_type"):
		animation_type = animation_data.animation_type

	if not animation_data.has("items_delay"):
		animation_data.items_delay = ANIMA.DEFAULT_ITEMS_DELAY

	if animation_data.has("grid"):
		animation_data._grid_node = animation_data.grid
	else:
		animation_data._grid_node = animation_data.group

	animation_data.erase("grid")
	animation_data.erase("group")

	var duration: float

	match animation_type:
		ANIMA.GRID.TOGETHER:
			duration = _generate_animation_all_together(animation_data)
		ANIMA.GRID.COLUMNS_EVEN:
			duration = _generate_animation_for_even_columns(animation_data)
		ANIMA.GRID.COLUMNS_ODD:
			duration = _generate_animation_for_odd_columns(animation_data)
		ANIMA.GRID.ROWS_ODD:
			duration = _generate_animation_for_odd_rows(animation_data)
		ANIMA.GRID.ROWS_EVEN:
			duration = _generate_animation_for_even_rows(animation_data)
		ANIMA.GRID.ODD_ITEMS:
			duration = _generate_animation_for_odd_items(animation_data)
		ANIMA.GRID.EVEN_ITEMS:
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
		if '__do_nothing' in child or not (child is Node3D or child is CanvasItem):
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
	var children := _get_children(animation_data, start_from == ANIMA.GRID.RANDOM)
	var is_grid: bool = animation_data.grid_size.x > 1
	var grid_size: Vector2 = animation_data.grid_size
	var start_point: Vector2 = Vector2(floor(grid_size.x / 2), floor(grid_size.y / 2))

	if start_from == ANIMA.GRID.FROM_POINT and not animation_data.has('point'):
		start_from = ANIMA.GRID.FROM_CENTER

	if start_from == ANIMA.GRID.SEQUENCE_BOTTOM_RIGHT:
		start_point = grid_size
	elif start_from == ANIMA.GRID.FROM_POINT:
		start_point = animation_data.point
	elif start_from == ANIMA.GROUP.FROM_TOP:
		start_point = Vector2.ZERO
	elif start_from == ANIMA.GROUP.FROM_BOTTOM:
		start_point = Vector2(children.size(), 0)

	var is_group = start_point.x == 1
	var use_forumla = animation_data.distance_formula if animation_data.has("distance_formula") else ANIMA.DISTANCE.EUCLIDIAN
	var row := 0
	var column := 0

	for row_items in children:
		column = 0
		for item in row_items:
			var point = Vector2(row, column)
			var distance

			if use_forumla == ANIMA.DISTANCE.MANHATTAN:
				distance = _manhattan_distance(point, start_point)
			elif use_forumla == ANIMA.DISTANCE.EUCLIDIAN:
				distance = _euclidian_distance(point, start_point)
			elif use_forumla == ANIMA.DISTANCE.CHEBYSHEV:
				distance = _chebyshev_distance(point, start_point)
			elif use_forumla == ANIMA.DISTANCE.ROW:
				distance = abs(column - start_point.y)
			elif use_forumla == ANIMA.DISTANCE.COLUMN:
				distance = abs(row - start_point.x)
			elif use_forumla == ANIMA.DISTANCE.DIAGONAL:
				var sum: int = start_point.x + start_point.y

				distance = abs((row + column) - sum)

			if is_group:
				distance = floor(distance) - 1

			nodes.push_back({ node = item, delay_index = distance })

			column += 1

		row += 1

	return _create_grid_animation_with(nodes, animation_data)

func _manhattan_distance(point1: Vector2, point2: Vector2) -> float:
	var distance_x = point1.x - point2.x
	var distance_y = point1.y - point2.y
	var distance = abs(distance_x) + abs(distance_y)

	return distance

func _euclidian_distance(point1: Vector2, point2: Vector2) -> float:
	var distance_x = point1.x - point2.x
	var distance_y = point1.y - point2.y
	var distance = sqrt(distance_x * distance_x + distance_y * distance_y)

	return distance

func _chebyshev_distance(point1: Vector2, point2: Vector2) -> float:
	var y2 = point2.y
	var y1 = point1.y
	var x2 = point2.x
	var x1 = point1.x

	return abs(max(abs(y2 - y1), abs(x2 - x1)))

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
		if int(column) % 2 == 0:
			columns.push_back(column)

	return _generate_animation_for(rows, columns, animation_data)

func _generate_animation_for_odd_columns(animation_data: Dictionary) -> float:
	var columns := []
	var rows := []
	var grid_size = animation_data.grid_size

	for row in grid_size.x:
		rows.push_back(row)

	for column in grid_size.y:
		if int(column) % 2 != 0:
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
	_loop_count -= 1

	if _loop_count > 0 or _should_loop:
		if _loop_delay > 0:
			await get_tree().create_timer(_loop_delay).timeout

		_do_play()

func _on_all_tween_completed() -> void:
	emit_signal("animation_completed")
	emit_signal("loop_completed", _loop_count)

	if _is_single_shot:
		queue_free()

		return

	if _should_loop:
		_maybe_play()

func _on_backwords_tween_complete(tween: Tween) -> void:
	tween.queue_free()

	_on_all_tween_completed()

func get_animation_data() -> Array:
	return _anima_tween.get_animation_data()

func _play_backwards(time: float) -> void:
	_anima_tween.seek(time)

