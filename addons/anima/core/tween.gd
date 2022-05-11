tool

class_name AnimaTween
extends Tween

signal animation_completed

const VISIBILITY_STRATEGY_META_KEY = "__visibility_strategy"

var PROPERTIES_TO_ATTENUATE = ["rotate", "rotation", "rotation:y", "rotate:y", "y", "position:y", "x"]

var _animation_data := []
var _callbacks := {}
var _loop_strategy = Anima.LOOP_STRATEGY.USE_EXISTING_RELATIVE_DATA
var _tween_completed := 0
var _tween_started := 0
var _root_node: Node

enum PLAY_MODE {
	NORMAL,
	BACKWARDS,
	LOOP_IN_CIRCLE
}

func _ready():
	connect("tween_started", self, '_on_tween_started')
	connect("tween_completed", self, '_on_tween_completed')

	#
	# By default Godot runs interpolate_property animation runs only once
	# this means that if you try to play again it won't work.
	# Possible solutions are:
	# - resetting the tween data and recreating all over again before starting the animation
	# - recreating the anima animation again before playing
	# - cheat
	#
	# Of the 3 I did prefer "cheating" making belive Godot that this tween is in a
	# repeat loop.
	# So, once all the animations are completed (_tween_completed == _animation_data.size())
	# we pause the tween, and next time we call play again we resume it and it works...
	# There is no need to recreating anything on each "loop"
	set_repeat(true)

func play(play_speed: float):
	set_speed_scale(play_speed)

	_tween_completed = 0

	resume_all()

func add_animation_data(animation_data: Dictionary, play_mode: int = PLAY_MODE.NORMAL) -> void:
	var index: String
	var is_backwards_animation = play_mode != PLAY_MODE.NORMAL

	_animation_data.push_back(animation_data)
	index = str(_animation_data.size())

	var duration = animation_data.duration if animation_data.has('duration') else Anima.DEFAULT_DURATION

	if animation_data.has('visibility_strategy'):
		_apply_visibility_strategy(animation_data)

	if animation_data.has("initial_value"):
		animation_data.initial_values = {}
		animation_data.initial_values[animation_data.property] = animation_data.initial_value

	var ignore_initial_values = animation_data.has("_ignore_initial_values") and animation_data._ignore_initial_values

	if animation_data.has("initial_values") and not is_backwards_animation and not ignore_initial_values:
		if not animation_data.has("to"):
			printerr("When using '_initial_value' the 'to' cannot be empty!")
		else:
			_apply_initial_values(animation_data)

	var easing_points

	if animation_data.has("easing") and not animation_data.easing == null:
		if animation_data.easing is FuncRef or animation_data.easing is Array:
			easing_points = animation_data.easing
		elif animation_data.easing is Curve:
			easing_points = animation_data.easing
		else:
			easing_points = AnimaEasing.get_easing_points(animation_data.easing)

	animation_data._easing_points = easing_points
	var property_data: Dictionary = {}
	if animation_data.property is Object:
		property_data = {
			property = animation_data.property,
			key = animation_data.key
		}
	else:
		property_data = AnimaNodesProperties.map_property_to_godot_property(animation_data.node, animation_data.property)

	if not property_data.has("property") and not property_data.has("callback"):
#		printerr("property/callback missing or not recognised for the animation: ", animation_data.property)
		return

	var object: Node = _get_animated_object_item(property_data)
	var use_method: String = "animate_linear"

	if easing_points is Array:
		use_method = 'animate_with_easing'
	elif easing_points is String:
		use_method = 'animate_with_anima_easing'
	elif easing_points is FuncRef:
		use_method = 'animate_with_easing_funcref'
	elif easing_points is Curve:
		use_method = 'animate_with_curve'

	var from := 0.0 if play_mode == PLAY_MODE.NORMAL else 1.0
	var to := 1.0 - from

	object.set_animation_data(animation_data, property_data, is_backwards_animation)

	if animation_data.has("__debug"):
		printt("use_method", use_method)

	interpolate_method(
		object,
		use_method,
		0.0,
		1.0,
		duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		animation_data._wait_time
	)
	
	add_child(object)

func _apply_initial_values(animation_data: Dictionary) -> void:
	var node: Node = animation_data.node

	for property in animation_data.initial_values:
		var value = animation_data.initial_values[property]
		var property_data = AnimaNodesProperties.map_property_to_godot_property(node, property)
		var is_rect2 = property_data.has("is_rect2") and property_data.is_rect2
		var is_object = typeof(property_data.property) == TYPE_OBJECT

		if is_rect2:
			push_warning("not yet implemented")
			pass
		elif is_object:
			push_warning("not yet implemented")
			pass
		elif property_data.has('subkey'):
			node[property_data.property][property_data.key][property_data.subkey] = value
		elif property_data.has('key'):
			node[property_data.property][property_data.key] = value
		else:
			node[property_data.property] = value

func _get_animated_object_item(property_data: Dictionary) -> Node:
	var is_rect2 = property_data.has("is_rect2") and property_data.is_rect2
	var animate_callback := property_data.has("callback")
	var is_object = property_data.has("property") and typeof(property_data.property) == TYPE_OBJECT

	if is_rect2:
		return AnimateRect2.new()
	elif is_object:
		if property_data.has("subkey"):
			return AnimateObjectWithSubKey.new()

		return AnimateObjectWithKey.new()
	elif property_data.has('subkey'):
		return AnimatedPropertyWithSubKeyItem.new()
	elif property_data.has('key'):
		return AnimatedPropertyWithKeyItem.new()
	elif animate_callback:
		if property_data.has("param"):
			return AnimatedCallbackWithParam.new()

		return AnimatedCallback.new()

	return AnimatedPropertyItem.new()

# Needed for animations created via the Visual Editor
func set_root_node(node: Node) -> void:
	_root_node = node

#
# Given an CSS-Keyframe like Dictionary of frames generates the animation frames
#
#	0: {
#		opacity = 0,
#		scale = Vector2(0.3, 0.3),
#		y = 100,
#		easing = [0.55, 0.055, 0.675, 0.19],
#	},
#	60: {
#		opacity = 1,
#		scale = Vector2(0.475, 0.475),
#		y = 100,
#		easing = [0.55, 0.055, 0.675, 0.19]
#	},
#	100: {
#		scale = Vector2(1, 1),
#		y = 0
#	}
#
func add_frames(animation_data: Dictionary, full_keyframes_data: Dictionary) -> float:
	var last_duration := 0.0
	var relative_properties: Array = ["x", "y", "z", "position", "position:x", "position:z", "position:y"]
	var pivot = full_keyframes_data.pivot if full_keyframes_data.has("pivot") else null
	var easing = full_keyframes_data.easing if full_keyframes_data.has("easing") else null

	if animation_data.has("_ignore_relative") and animation_data._ignore_relative:
		relative_properties = []

	if full_keyframes_data.has("relative"):
		relative_properties = full_keyframes_data.relative

	animation_data._relative_to = Anima.RELATIVE_TO.INITIAL_VALUE

	if full_keyframes_data.has("relativeTo"):
		animation_data._relative_to = full_keyframes_data.relativeTo

	# Flattens the keyframe_data
	var keyframes_data = AnimaTweenUtils.flatten_keyframes_data(full_keyframes_data)

	var previous_key_value := {}
	var wait_time: float = animation_data._wait_time if animation_data.has('_wait_time') else 0.0

	if pivot:
		animation_data.pivot = pivot

	if keyframes_data.has("initial_values"):
		animation_data.initial_values = keyframes_data.initial_values

	if easing:
		animation_data.easing = easing

	keyframes_data.erase("initial_values")

	var frame_keys: Array = keyframes_data.keys()
	frame_keys.sort_custom(self, "_sort_frame_index")

	var percentage = frame_keys[0]
	var base_data = animation_data.duplicate()
	var node: Node = animation_data.node
	var real_duration := 0.0
	var first_frame_data = keyframes_data[percentage]

	for property_to_animate in first_frame_data:
		var current_value = AnimaNodesProperties.get_property_value(node, { property = property_to_animate })
		var value = first_frame_data[property_to_animate]

		if value != null and value is String:
			value = AnimaTweenUtils.maybe_calculate_value(value, base_data)

		var data := { percentage = percentage, value = value }

		base_data.property = property_to_animate
		previous_key_value[property_to_animate] = data
		node.set_meta("__initial_" + property_to_animate, current_value)

	frame_keys.pop_front()

	#
	# Sometimes we want to be able to define the duration of each single step.
	# For example for "typewrite" we want to specify the duration of the animation of the single
	# character, instead of the full sentences, otherwise different string length will
	# have different speed.
	# In those cases we can define a special key called "_duration" where we can specify a formula
	# using the "dynamic value" capability.
	#
	if full_keyframes_data.has("_duration"):
		var duration_formula = full_keyframes_data._duration.replace("{duration}", animation_data.duration)
		real_duration = AnimaTweenUtils.maybe_calculate_value(duration_formula, animation_data)
		
		animation_data.duration = real_duration

	var is_first_frame := true
	for frame_key in frame_keys:
		if (not frame_key is int and not frame_key is float) or frame_key > 100:
			continue

		var keyframe_data: Dictionary = keyframes_data[frame_key]

		animation_data._is_first_frame = is_first_frame
		animation_data._is_last_frame = frame_key == 100

		_calculate_frame_data(
			wait_time,
			animation_data,
			relative_properties,
			frame_key,
			keyframes_data[frame_key],
			previous_key_value
		)

		animation_data.erase("initial_values")

	return real_duration

func _sort_frame_index(a, b) -> bool:
	return int(a) < int(b)

func _calculate_frame_data(wait_time: float, animation_data: Dictionary, relative_properties: Array, current_frame_key: float, frame_data: Dictionary, previous_key_value: Dictionary) -> void:
	var duration: float = animation_data.duration if animation_data.has('duration') else 0.0
	var easing = null
	var pivot = null

	if animation_data.has("easing"):
		easing = animation_data.easing

	if frame_data.has("easing"):
		easing = frame_data.easing

	var node: Node = animation_data.node
	var is_mesh = node is MeshInstance
	var keys := []

	for key in frame_data.keys():
		if key == "easing" or key == "pivot":
			continue

		if key == "skew":
			var skew: Vector2 = frame_data[key]

			frame_data["skew:x"] = skew.x / 32
			frame_data["skew:y"] = skew.y / 32

			if previous_key_value.skew and not previous_key_value.has("skew:x"):
				var p: Dictionary = previous_key_value.skew

				previous_key_value["skew:x"] = { percentage = p.percentage, value = p.value.x }
				previous_key_value["skew:y"] = { percentage = p.percentage, value = p.value.y }

			keys.push_back("skew:x")
			key = "skew:y"

		keys.push_back(key)

	for property_to_animate in keys:
		var data = animation_data.duplicate()
		var start_percentage = previous_key_value[property_to_animate].percentage
		var percentage = (current_frame_key - start_percentage) / 100.0
		var frame_duration = max(Anima.MINIMUM_DURATION, duration * percentage)
		var percentage_delay := 0.0
		var relative = relative_properties.find(property_to_animate) >= 0
		var initial_key = "__initial_" + property_to_animate
		var initial_value = node.get_meta(initial_key)

		if start_percentage > 0:
			percentage_delay += (start_percentage/ 100.0) * duration

		var from_value = previous_key_value[property_to_animate].value
		var to_value = frame_data[property_to_animate]

		#
		# To have generic animations that works with 2D and 3D Nodes
		# we always define scale as Vector3. But for 2D Nodes we can
		# only use Vector2, so in this case we have to "convert" the property
		# internally
		var node_property = AnimaNodesProperties.map_property_to_godot_property(node, property_to_animate)

		var should_convert_to_vector2: bool = not node_property.has("key") and node_property.has("property") and node_property.property in node and node[node_property.property] is Vector2
		if should_convert_to_vector2:
			if from_value is Vector3:
				from_value = Vector2(from_value.x, from_value.y)

			if to_value is Vector3:
				to_value = Vector2(to_value.x, to_value.y)

		var property_name = property_to_animate

		data.to = AnimaTweenUtils.maybe_calculate_value(to_value, data)

		if relative:
			if previous_key_value[property_to_animate].has("to"):
				from_value = previous_key_value[property_to_animate].to

			data.to += initial_value

		data.property = property_name
		data.duration = frame_duration
		data._wait_time = wait_time + percentage_delay
		data.easing = easing
		data.from = from_value

		if property_name == "opacity":
			data.easing = null

		if animation_data.has("__debug"):
			prints("\n=== FRAME", data.property, ":", data.from, " --> ", data.to, "wait time:", data._wait_time, "duration:", data.duration, "easing:", data.easing, " is relative:", str(relative))

		if typeof(from_value) != typeof(data.to) or from_value != data.to:
			add_animation_data(data)

		previous_key_value[property_to_animate] = { percentage = current_frame_key, value = frame_data[property_to_animate], to = data.to }

func get_animation_data() -> Array:
	return _animation_data

func get_animations_count() -> int:
	return _animation_data.size()

func has_data() -> bool:
	return _animation_data.size() > 0

func clear_animations() -> void:
	remove_all()
	reset_all()

	for child in get_children():
		child.queue_free()

	_callbacks = {}
	_animation_data.clear()

func set_visibility_strategy(strategy: int) -> void:
	for animation_data in _animation_data:
		_apply_visibility_strategy(animation_data, strategy)

func set_loop_strategy(strategy: int) -> void:
	_loop_strategy = strategy

func reverse_animation(animation_data: Array, animation_length: float, default_duration: float):
	clear_animations()

	var data: Array = _flip_animations(animation_data.duplicate(true), animation_length, default_duration)

	for new_data in data:
		add_animation_data(new_data, PLAY_MODE.BACKWARDS)

#
# In order to flip "nested relative" animations we need to calculate what all the
# property as it would be if the animation is played normally. Only then we can calculate
# the correct relative positions, by also looking at the previous frames.
# Otherwise we would end up with broken animations when animating the same property more than
# once 
func _flip_animations(data: Array, animation_length: float, default_duration: float) -> Array:
	var new_data := []
	var previous_frames := {}
	var length: float = animation_length

	data.invert()
	for animation in data:
		if animation.has("_ignore_for_backwards"):
			continue

		var animation_data = animation.duplicate(true)

		var duration: float = float(animation_data.duration) if animation_data.has('duration') else default_duration
		var wait_time: float = animation_data._wait_time
		var node = animation_data.node
		var new_wait_time: float = length - duration - wait_time
		var property = animation_data.property
		var is_relative = animation_data.has("relative") and animation_data.relative

		if animation_data.has("initial_value"):
			animation_data.erase("initial_value")
			
		if animation_data.has("initial_values"):
			animation_data.erase("initial_values")

		if not is_relative:
			var temp = animation_data.to

			if animation_data.has("from"):
				animation_data.to = animation_data.from

			animation_data.from = temp

		animation_data._wait_time = max(Anima.MINIMUM_DURATION, new_wait_time)

		var old_on_completed = animation_data.on_completed if animation_data.has("on_completed") else null
		var erase_on_completed := true

		if animation_data.has("on_started"):
			animation_data.on_completed = animation_data.on_started
			animation_data.erase("on_started")

			erase_on_completed = false

		if old_on_completed:
			animation_data.on_started = old_on_completed

			if erase_on_completed:
				animation_data.erase('on_completed')

		animation_data.erase("initial_values")
		animation_data.erase("initial_value")

		new_data.push_back(animation_data)

	return new_data

func _apply_visibility_strategy(animation_data: Dictionary, strategy: int = Anima.VISIBILITY.IGNORE):
	if not animation_data.has('_is_first_frame'):
		return

	var should_hide_nodes := false
	var should_make_nodes_transparent := false

	if animation_data.has("visibility_strategy"):
		strategy = animation_data.visibility_strategy

	if strategy == Anima.VISIBILITY.HIDDEN_ONLY:
		should_hide_nodes = true
	elif strategy == Anima.VISIBILITY.HIDDEN_AND_TRANSPARENT:
		should_hide_nodes = true
		should_make_nodes_transparent = true
	elif strategy == Anima.VISIBILITY.TRANSPARENT_ONLY:
		should_make_nodes_transparent = true

	var node: Node = animation_data.node

	if should_hide_nodes:
		node.show()

	if should_make_nodes_transparent and 'modulate' in node:
		var modulate = node.modulate
		var transparent = modulate

		transparent.a = 0
		node.set_meta('_old_modulate', modulate)

		node.modulate = transparent

	node.set_meta(VISIBILITY_STRATEGY_META_KEY, strategy)


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

func _on_tween_completed(node, _ignore) -> void:
	node.on_completed()

	_tween_completed += 1

	if _tween_completed >= _animation_data.size():
		stop_all()

		emit_signal("animation_completed")

func _on_tween_started(node, _ignore) -> void:
	node.on_started()

class AnimatedItem extends Node:
	var _node: Node
	var _callback: FuncRef
	var _callback_param
	var _property
	var _key
	var _subKey
	var _animation_data: Dictionary
	var _loop_strategy: int = Anima.LOOP_STRATEGY.USE_EXISTING_RELATIVE_DATA
	var _is_backwards_animation: bool = false
	var _root_node: Node
	var _property_data: Dictionary
	var _easing_curve: Curve

	func on_started() -> void:
		var visibility_strategy = _node.get_meta(VISIBILITY_STRATEGY_META_KEY) if _node.has_meta(VISIBILITY_STRATEGY_META_KEY) else null

		if _node.has_meta("_visibility_strategy_reverted") or visibility_strategy == null:
			return

		_node.set_meta("_visibility_strategy_reverted", true)

		if _animation_data.has("visibility_strategy"):
			visibility_strategy = _animation_data.visibility_strategy

		var should_restore_visibility := false
		var should_restore_modulate := false

		if visibility_strategy == Anima.VISIBILITY.HIDDEN_ONLY:
			should_restore_visibility = true
		elif visibility_strategy == Anima.VISIBILITY.HIDDEN_AND_TRANSPARENT:
			should_restore_modulate = true
			should_restore_visibility = true
		elif visibility_strategy == Anima.VISIBILITY.TRANSPARENT_ONLY:
			should_restore_modulate = true

		if should_restore_modulate:
			var old_modulate

			if _node.has_meta('_old_modulate'):
				old_modulate = _node.get_meta('_old_modulate')
				old_modulate.a = 1.0

			if old_modulate:
				_node.modulate = old_modulate

		if should_restore_visibility:
			_node.show()

		var should_trigger_on_started: bool = _animation_data.has('_is_first_frame') and \
												_animation_data._is_first_frame and \
												_animation_data.has('on_started')

		if should_trigger_on_started:
			_execute_callback(_animation_data.on_started)

	func on_completed() -> void:
		if _loop_strategy == Anima.LOOP_STRATEGY.RECALCULATE_RELATIVE_DATA:
			_property_data.clear()

		var should_trigger_on_completed = _animation_data.has('on_completed') and _animation_data.has('_is_last_frame')

		if should_trigger_on_completed:
			_execute_callback(_animation_data.on_completed)

	func set_animation_data(data: Dictionary, property_data: Dictionary, is_backwards_animation: bool) -> void:
		_animation_data = data
		_is_backwards_animation = is_backwards_animation

		if property_data.has("callback"):
			_callback = property_data.callback

		if property_data.has("param"):
			_callback_param = property_data.param

		if property_data.has("property"):
			_property = property_data.property

		if data.has("easing") and data.easing is Curve:
			_easing_curve = data.easing

		_key = property_data.key if property_data.has("key") else null
		_subKey = property_data.subkey if property_data.has("subkey") else null

		_node = data.node
		_node.remove_meta("_visibility_strategy_reverted")

		if _animation_data.has("__debug"):
			print("Using:")
			printt("", property_data)
			printt("", "AnimatedPropertyItem:", self is AnimatedPropertyItem)
			printt("", "AnimatedPropertyWithKeyItem:", self is AnimatedPropertyWithKeyItem)
			printt("", "AnimatedPropertyWithSubKeyItem:", self is AnimatedPropertyWithSubKeyItem)
			printt("", "AnimateObjectWithKey:", self is AnimateObjectWithKey)
			printt("", "AnimateObjectWithSubKey:", self is AnimateObjectWithSubKey)
			printt("", "AnimateRect2:", self is AnimateRect2)

	func animate(elapsed: float) -> void:
		if _property_data.size() == 0:
			_property_data = AnimaTweenUtils.calculate_from_and_to(_animation_data, _is_backwards_animation)

			if _animation_data.has("__debug"):
				printt("_property_data", _property_data)
				print("")

		var from = _property_data.from
		var diff = _property_data.diff

		var value = from + (diff * elapsed)

		apply_value(value)

	func apply_value(value) -> void:
		printerr("Please use LinearAnimatedItem or EasingAnimatedItem class intead!!!")

	func animate_with_easing(elapsed: float):
		var easing_points = _animation_data._easing_points
		var p1 = easing_points[0]
		var p2 = easing_points[1]
		var p3 = easing_points[2]
		var p4 = easing_points[3]

		var easing_elapsed = _cubic_bezier(Vector2.ZERO, Vector2(p1, p2), Vector2(p3, p4), Vector2(1, 1), elapsed)

		animate(easing_elapsed)

	func animate_with_anima_easing(elapsed: float) -> void:
		var easing_points_function = _animation_data._easing_points
		var easing_callback = funcref(AnimaEasing, easing_points_function)
		var easing_elapsed = easing_callback.call_func(elapsed)

		animate(easing_elapsed)

	func animate_with_easing_funcref(elapsed: float) -> void:
		var easing_callback = _animation_data._easing_points
		var easing_elapsed = easing_callback.call_func(elapsed)

		animate(easing_elapsed)

	func animate_with_curve(elapsed: float) -> void:
		var easing_elapsed = _easing_curve.interpolate(elapsed)

		animate(easing_elapsed)

	func animate_linear(elapsed: float) -> void:
		animate(elapsed)

	func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> float:
		var q0 = p0.linear_interpolate(p1, t)
		var q1 = p1.linear_interpolate(p2, t)
		var q2 = p2.linear_interpolate(p3, t)

		var r0 = q0.linear_interpolate(q1, t)
		var r1 = q1.linear_interpolate(q2, t)

		var s = r0.linear_interpolate(r1, t)

		return s.y

	func _execute_callback(callback) -> void:
		var fn: FuncRef
		var args: Array = []

		if callback is Array:
			fn = callback[0]
			args = callback[1]

			if _is_backwards_animation:
				args = callback[2]
		else:
			fn = callback
			
		fn.call_funcv(args)

class AnimatedPropertyItem extends AnimatedItem:
	func apply_value(value) -> void:
		_node.set(_property, value)

class AnimatedPropertyWithKeyItem extends AnimatedItem:
	func apply_value(value) -> void:
		_node[_property][_key] = value

class AnimatedPropertyWithSubKeyItem extends AnimatedItem:
	func apply_value(value) -> void:
		_node[_property][_key][_subKey] = value

class AnimateObjectWithKey extends AnimatedItem:
	func apply_value(value) -> void:
		_property[_key] = value

class AnimateObjectWithSubKey extends AnimatedItem:
	func apply_value(value) -> void:
		_property[_key][_subKey] = value

class AnimatedCallback extends AnimatedItem:
	func apply_value(value) -> void:
		_callback

class AnimatedCallbackWithParam extends AnimatedItem:
	func apply_value(value) -> void:
		_callback.call_funcv([_callback_param, value])

class AnimateRect2 extends AnimatedItem:
	func animate(elapsed: float) -> void:
		if _property_data.size() == 0:
			_property_data = AnimaTweenUtils.calculate_from_and_to(_animation_data, _is_backwards_animation)

		apply_value(Rect2(
			_property_data.from.position + (_property_data.diff.position * elapsed),
			_property_data.from.size + (_property_data.diff.size * elapsed)
		))

	func apply_value(value: Rect2) -> void:
		_node.set(_property, value)
