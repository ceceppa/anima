class_name AnimaTween
extends Tween

var _animation_data := []

var _loops_count := 0
var _loop_times := 0
var _loop_delay := 0.0

# Needed to use interpolate_property
var _fake_property: Dictionary = {}

var _visibility_strategy: int = Anima.Visibility.IGNORE
var _callbacks := {}

func _ready():
	connect("tween_started", self, '_on_tween_started')
	connect("tween_step", self, '_on_tween_step_with_easing')
	connect("tween_step", self, '_on_tween_step_with_easing_callback')
	connect("tween_step", self, '_on_tween_step_without_easing')
	connect("tween_completed", self, '_on_tween_completed')

func play():
	var index := 0
	for animation_data in _animation_data:
		var easing_points

		if animation_data.has('easing'):
			easing_points = AnimaEasing.get_easing_points(animation_data.easing)

		if animation_data.has('easing_points'):
			easing_points = animation_data.easing_points

		animation_data._easing_points = easing_points
		animation_data._animation_callback = funcref(self, '_calculate_from_and_to')

		if easing_points is Array:
			animation_data._use_step_callback = '_on_tween_step_with_easing'
		elif easing_points is String:
			animation_data._use_step_callback = '_on_tween_step_with_easing_callback'
		else:
			animation_data._use_step_callback = '_on_tween_step_without_easing'

		index += 1

	var started := start()

	if not started:
		printerr('something went wrong while trying to start the tween')

func add_animation_data(animation_data: Dictionary) -> void:
	_animation_data.push_back(animation_data)

	var index = str(_animation_data.size())
	var duration = animation_data.duration if animation_data.has('duration') else 0.7
	var property_key = 'p' + index

	_fake_property[property_key] = 0.0

	if animation_data.has('pivot'):
		AnimaNodesProperties.set_pivot(animation_data.node, animation_data.pivot)

	if animation_data.has('on_completed') and animation_data.has('_is_last_frame'):
		_callbacks[property_key] = animation_data.on_completed

	if animation_data.has('hide_strategy'):
		_apply_visibility_strategy(animation_data)

	interpolate_property(
		self,
		'_fake_property:' + property_key,
		0.0,
		1.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		animation_data._wait_time
	)

#
# Given an array of frames generates the animation data using relative end value
#
# frames = [{
#	percentage = the percentage of the animation
#	to = the relative end value
#	easing_points = the easing points for the bezier curver (optional)
# }]
#
func add_relative_frames(data: Dictionary, property: String, frames: Array) -> float:
	return _add_frames(data, property, frames, true)

#
# Given an array of frames generates the animation data using absolute end value
#
# frames = [{
#	percentage = the percentage of the animation
#	to = the relative end value
#	easing_points = the easing points for the bezier curver (optional)
# }]
#
func add_frames(data: Dictionary, property: String, frames: Array) -> float:
	return _add_frames(data, property, frames)

func _add_frames(data: Dictionary, property: String, frames: Array, relative: bool = false) -> float:
	var duration: float = data.duration if data.has('duration') else 0.0
	var _wait_time: float = data._wait_time if data.has('_wait_time') else 0.0
	var last_duration := 0.0

	var keys_to_ignore = ['duration', '_wait_time']
	for frame in frames:
		var percentage = frame.percentage if frame.has('percentage') else 100.0
		percentage /= 100.0

		var frame_duration = max(0.000001, duration * percentage)
		var diff = frame_duration - last_duration
		var is_first_frame = true
		var is_last_frame = percentage == 1

		var animation_data = {
			property = property,
			relative = relative,
			duration = diff,
			_wait_time = _wait_time
		}

		# We need to restore the animation jest before the node is animated
		# but we also need to consider that a node can have multiple
		# properties animated, so we need to restore it only before the first
		# animation starts
		for animation in _animation_data:
			if animation.node == data.node:
				is_first_frame = false

				if animation.has('_is_last_frame'):
					is_last_frame = false

		if is_first_frame:
			animation_data._is_first_frame = true

		if is_last_frame:
			animation_data._is_last_frame = true

		for key in frame:
			if key != 'percentage':
				animation_data[key] = frame[key]

		for key in data:
			if key == 'callback' and percentage < 1:
				animation_data.erase(key)
			elif keys_to_ignore.find(key) < 0:
				animation_data[key] = data[key]

		add_animation_data(animation_data)

		last_duration = frame_duration
		_wait_time += diff

	return _wait_time

func get_animations_count() -> int:
	return _animation_data.size()

func clear_animations() -> void:
	_fake_property = {}
	_animation_data.clear()

func set_visibility_strategy(strategy: int) -> void:
	for animation_data in _animation_data:
		_apply_visibility_strategy(animation_data, strategy)

	_visibility_strategy = strategy

func _apply_visibility_strategy(animation_data: Dictionary, strategy: int = Anima.Visibility.IGNORE):
	if not animation_data.has('_is_first_frame'):
		return

	var should_hide_nodes := false
	var should_make_nodes_transparent := false

	if animation_data.has('hide_strategy'):
		strategy = animation_data.hide_strategy

	if strategy == Anima.Visibility.HIDDEN_ONLY:
		should_hide_nodes = true
	elif strategy == Anima.Visibility.HIDDEN_AND_TRANSPARENT:
		should_hide_nodes = true
		should_make_nodes_transparent = true
	elif strategy == Anima.Visibility.TRANSPARENT_ONLY:
		should_make_nodes_transparent = true

	var node = animation_data.node

	if should_hide_nodes:
		node.show()

	if should_make_nodes_transparent:
		var modulate = node.modulate
		var transparent = modulate

		transparent.a = 0
		node.set_meta('_old_modulate', modulate)

		node.modulate = transparent

func _on_tween_step_with_easing(object: Object, key: NodePath, _time: float, elapsed: float):
	var index := _get_animation_data_index(key)

	if _animation_data[index]._use_step_callback != '_on_tween_step_with_easing':
		return

	var easing_points = _animation_data[index]._easing_points
	var p1 = easing_points[0]
	var p2 = easing_points[1]
	var p3 = easing_points[2]
	var p4 = easing_points[3]

	var easing_elapsed = _cubic_bezier(Vector2.ZERO, Vector2(p1, p2), Vector2(p3, p4), Vector2(1, 1), elapsed)

	_animation_data[index]._animation_callback.call_func(index, easing_elapsed)

func _on_tween_step_with_easing_callback(object: Object, key: NodePath, _time: float, elapsed: float):
	var index := _get_animation_data_index(key)

	if _animation_data[index]._use_step_callback != '_on_tween_step_with_easing_callback':
		return

	var easing_points_function = _animation_data[index]._easing_points
	var easing_callback = funcref(AnimaEasing, easing_points_function)
	var easing_elapsed = easing_callback.call_func(elapsed)

	_animation_data[index]._animation_callback.call_func(index, easing_elapsed)

func _on_tween_step_without_easing(object: Object, key: NodePath, _time: float, elapsed: float):
	var index := _get_animation_data_index(key)

	if _animation_data[index]._use_step_callback != '_on_tween_step_without_easing':
		return

	_animation_data[index]._animation_callback.call_func(index, elapsed)

func _get_animation_data_index(key: NodePath) -> int:
	var s = str(key)

	return int(s.replace('_fake_property:p', '')) - 1

func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> float:
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var q2 = p2.linear_interpolate(p3, t)

	var r0 = q0.linear_interpolate(q1, t)
	var r1 = q1.linear_interpolate(q2, t)

	var s = r0.linear_interpolate(r1, t)

	return s.y

func _calculate_from_and_to(index: int, value: float) -> void:
	var animation_data = _animation_data[index]
	var node = animation_data.node
	var from
	var to
	var relative = animation_data.relative if animation_data.has('relative') else false
	var node_from = AnimaNodesProperties.get_property_initial_value(node, animation_data.property)

	if animation_data.has('from'):
		from = _maybe_convert_from_deg_to_rad(node, animation_data, animation_data.from)
		from = _maybe_calculate_relative_value(relative, from, node_from)
	else:
		from = node_from

	if animation_data.has('to'):
		to = _maybe_convert_from_deg_to_rad(node, animation_data, animation_data.to)
		to = _maybe_calculate_relative_value(relative, to, from)
	else:
		to = from

	animation_data._property_data = AnimaNodesProperties.map_property_to_godot_property(node, animation_data.property)

	animation_data._property_data.diff = to - from
	animation_data._property_data.from = from

	if animation_data._property_data.has('subkey'):
		animation_data._animation_callback = funcref(self, '_on_animation_with_subkey')
	elif animation_data._property_data.has('key'):
		animation_data._animation_callback = funcref(self, '_on_animation_with_key')
	else:
		animation_data._animation_callback = funcref(self, '_on_animation_without_key')

	_animation_data[index]._animation_callback.call_func(index, value)

func _maybe_calculate_relative_value(relative, value, current_node_value):
	if not relative:
		return value

	return value + current_node_value

func _maybe_convert_from_deg_to_rad(node: Node, animation_data: Dictionary, value):
	if not node is Spatial or animation_data.property.find('rotation') < 0:
		return value

	if value is Vector3:
		return Vector3(deg2rad(value.x), deg2rad(value.y), deg2rad(value.z))

	return deg2rad(value)

func _on_animation_with_key(index: int, elapsed: float) -> void:
	var animation_data = _animation_data[index]
	var property_data = _animation_data[index]._property_data
	var node = animation_data.node
	var value = property_data.from + (property_data.diff * elapsed)

	node[property_data.property_name][property_data.key] = value

func _on_animation_with_subkey(index: int, elapsed: float) -> void:
	var animation_data = _animation_data[index]
	var property_data = _animation_data[index]._property_data
	var node = animation_data.node
	var value = property_data.from + (property_data.diff * elapsed)

	node[property_data.property_name][property_data.key][property_data.subkey] = value

func _on_animation_without_key(index: int, elapsed: float) -> void:
	var animation_data = _animation_data[index]
	var property_data = _animation_data[index]._property_data
	var node = animation_data.node
	var value = property_data.from + (property_data.diff * elapsed)

	if property_data.has('callback'):
		property_data.callback.call_func(property_data.param, value)

		return

	node[property_data.property_name] = value

#
# We don't want the user to specify the from/to value as color
# we animate opacity.
# So this function converts the "from = #" -> Color(.., .., .., #)
# same for the to value
#
func _maybe_adjust_modulate_value(animation_data: Dictionary, value):
	var property = animation_data.property
	var node = animation_data.node

	if not property == 'opacity':
		return value

	if value is int or value is float:
		var color = node.modulate

		color.a = value

		return color

	return value

func _on_tween_completed(_ignore, property_name: String) -> void:
	var property_key = property_name.replace(':_fake_property:', '')

	if _callbacks.has(property_key):
		var callback = _callbacks[property_key]

		callback[0].call_funcv(callback[1])

func _on_tween_started(_ignore, key) -> void:
	var index := _get_animation_data_index(key)
	var hide_strategy = _visibility_strategy
	var animation_data = _animation_data[index]

	if animation_data.has('hide_strategy'):
		hide_strategy = animation_data.hide_strategy

	var node = animation_data.node
	var should_restore_visibility := false
	var should_restore_modulate := false

	if hide_strategy == Anima.Visibility.HIDDEN_ONLY:
		should_restore_visibility = true
	elif hide_strategy == Anima.Visibility.HIDDEN_AND_TRANSPARENT:
		should_restore_modulate = true
		should_restore_visibility = true
	elif hide_strategy == Anima.Visibility.TRANSPARENT_ONLY:
		should_restore_modulate = true

	if should_restore_modulate:
		var old_modulate = node.get_meta('_old_modulate')

		if old_modulate:
			node.modulate = old_modulate

	if should_restore_visibility:
		node.show()
