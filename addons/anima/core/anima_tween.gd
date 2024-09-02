@tool

class_name AnimaTween
extends Node

signal animation_completed

const VISIBILITY_STRATEGY_META_KEY = "__anima_visibility_strategy"

var PROPERTIES_TO_ATTENUATE = ["rotate", "rotation", "rotation:y", "rotate:y", "y", "position:y", "x"]

var _animation_data := []
var _callbacks := {}
var _tween_started := 0
var _root_node: Node
var _use_meta_values := true
var _apply_initial_values_on: int = 0 #ANIMA.APPLY_INITIAL_VALUES.ON_ANIMATION_CREATION
var _should_apply_initial_values := true
var _initial_values := []
var is_playing_backwards := false
var _tween: Tween
var _children_to_remove := []

enum PLAY_MODE {
	NORMAL,
	BACKWARDS,
	LOOP_IN_CIRCLE
}

func _init(new_name: String = "AnimaTween"):
	name = new_name

func _enter_tree():
	_create_tween()

func _create_tween():
	var tree = get_tree()

	if not tree:
		return

	_tween = tree.create_tween()

	_tween.set_parallel(true)
	_tween.pause()

	_tween.loop_finished.connect(_on_tween_completed)
	_tween.finished.connect(_on_tween_completed)

func _exit_tree():
	for child in get_children():
		child.free()

func _ready():
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
	# There is no need to recreating anything checked each "loop"
	set_loops(0)

func set_loops(loops: int) -> void:
	if _tween:
		_tween.set_loops(loops)

func set_repeat(repeat) -> void:
	if !repeat:
		set_loops(1)

func play(play_speed: float):
	_tween.set_speed_scale(play_speed)
	_tween.play()

func do_apply_initial_values() -> void:
	if _should_apply_initial_values:
		for data in _initial_values:
			_apply_initial_values(data)

func set_apply_initial_values(when) -> void:
	_apply_initial_values_on = when

func add_animation_data(animation_data: Dictionary) -> void:
	var index: String

	_animation_data.push_back(animation_data)
	index = str(_animation_data.size())

	var duration = animation_data.duration if animation_data.has('duration') else ANIMA.DEFAULT_DURATION

	if animation_data.has('visibility_strategy'):
		_apply_visibility_strategy(animation_data)

	if animation_data.has("initial_value"):
		animation_data.initial_values = {}
		animation_data.initial_values[animation_data.property] = animation_data.initial_value

	if animation_data.has("initial_values"):
		if not animation_data.has("to"):
			printerr("When specifying 'initial_values' the 'to' keyframe cannot be undefined!")
		else:
			_add_initial_values(animation_data)

	var easing_points

	if animation_data.has("easing") and not animation_data.easing == null:
		if animation_data.easing is Callable or animation_data.easing is Array:
			easing_points = animation_data.easing
		elif animation_data.easing is Curve:
			easing_points = animation_data.easing
		else:
			easing_points = AnimaEasing.get_easing_points(animation_data.easing)

	animation_data._easing_points = easing_points

	var property_data: Dictionary = {}
	var node: Node = animation_data.node

	if animation_data.property is Object:
		property_data = {
			property = animation_data.property,
			key = animation_data.key
		}
	else:
		property_data = AnimaNodesProperties.map_property_to_godot_property(node, animation_data.property)

	var meta_value: Dictionary = animation_data.node.get_meta(ANIMA._INITIAL_STATE_META_KEY) if animation_data.node.has_meta(ANIMA._INITIAL_STATE_META_KEY) else {}

	if not meta_value.has(animation_data.property):
		property_data._initial_value = AnimaNodesProperties.get_property_value(animation_data.node, animation_data, animation_data.property)
		meta_value[animation_data.property] = property_data

		animation_data.node.set_meta(ANIMA._INITIAL_STATE_META_KEY, meta_value)

	if not property_data.has("property") and not property_data.has("callback"):
#		printerr("property/callback missing or not recognised for the animation: ", animation_data.property)
		return

	var object: Node = _get_animated_object_item(property_data)
	var use_method: String = "animate_linear"

	if easing_points is Array:
		use_method = 'animate_with_easing'
	elif easing_points is String:
		use_method = 'animate_with_anima_easing'
	elif easing_points is Callable:
		use_method = 'animate_with_easing_funcref'
	elif easing_points is Curve:
		use_method = 'animate_with_curve'
	elif easing_points is Dictionary:
		use_method = 'animate_with_parameterized_easing'

		if easing_points.fn.find("__") == 0:
			animation_data._easing_points = Callable(AnimaEasing, "spring")
		else:
			animation_data._easing_points = easing_points.fn

		animation_data._easing_params = easing_points

	object.set_animation_data(animation_data, property_data)

	if animation_data.has("__debug"):
		printt("use_method", use_method)

	_interpolate_method(
		object,
		use_method,
		duration,
		Tween.TRANS_LINEAR,
		Tween.TRANS_LINEAR,
		animation_data._wait_time
	)
	
	
	if animation_data.has("on_started"):
		_add_event_frame(animation_data, "on_started", animation_data._wait_time)

	if animation_data.has("on_completed"):
		_add_event_frame(animation_data, "on_completed", animation_data._wait_time + animation_data.duration)

	if not node.is_connected("tree_exiting",Callable(self,"_on_node_tree_exiting")):
		node.connect("tree_exiting",Callable(self,"_on_node_tree_exiting").bind(object))

func _interpolate_method(source: Node, method: String, duration: float, tween_in: int, tween_out: int, wait_time: float) -> void:
	var callable := Callable(source, method)

	if not _tween:
		return

	_tween.tween_method(
		callable,
		0.0,
		1.0,
		duration,
	).set_delay(wait_time)
	
	add_child(source)

func _add_event_frame(animation_data: Dictionary, callback_key: String, delay: float) -> void:
	if animation_data.has("__debug"):
		printt("add_event_frame", animation_data)

	var object := AnimaEvent.new(animation_data, callback_key, is_playing_backwards)

	_tween.tween_callback(object.execute_callback).set_delay(delay)

	add_child(object)

func _add_initial_values(animation_data: Dictionary) -> void:
	if _animation_data.has("__debug"):
		prints("_add_initial_values", animation_data.node, animation_data.initial_values)

	_initial_values.push_back({ node = animation_data.node, initial_values = animation_data.initial_values })

func _apply_initial_values(animation_data: Dictionary) -> void:
	var node: Node = animation_data.node

	if _animation_data.has("__debug"):
		prints("_apply_initial_values", node, animation_data.initial_values)

	for property in animation_data.initial_values:
		var value = animation_data.initial_values[property]
		var property_data = AnimaNodesProperties.map_property_to_godot_property(node, property)
		var is_rect2 = property_data.has("is_rect2") and property_data.is_rect2
		var is_object = typeof(property_data.property) == TYPE_OBJECT

		if value == null:
			continue

		if value is String:
			value = AnimaTweenUtils.calculate_dynamic_value(value, animation_data)

		if is_rect2:
			push_warning("not yet implemented")
			pass
		elif is_object:
			push_warning("not yet implemented")
			pass
		elif property_data.property == "shader_param":
			property_data.callback.callv([property_data.param, value])
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

func get_animation_data() -> Array:
	return _animation_data

func get_animations_count() -> int:
	return _animation_data.size()

func has_data() -> bool:
	return _animation_data.size() > 0

func stop() -> void:
	_tween.stop()

func clear_animations() -> void:
	_tween.stop()
	_tween.kill()

	for child in get_children():
		child.queue_free()

	_callbacks = {}
	_animation_data.clear()
	_initial_values.clear()

	if is_inside_tree():
		_enter_tree()

func set_visibility_strategy(strategy: int) -> void:
	for animation_data in _animation_data:
		_apply_visibility_strategy(animation_data, strategy)

func _apply_visibility_strategy(animation_data: Dictionary, strategy: int = ANIMA.VISIBILITY.IGNORE):
	if not animation_data.has('_is_first_frame') or not animation_data._is_first_frame:
		return

	var should_hide_nodes := false
	var should_make_nodes_transparent := false

	if animation_data.has("visibility_strategy"):
		strategy = animation_data.visibility_strategy

	if strategy == ANIMA.VISIBILITY.HIDDEN_ONLY:
		should_hide_nodes = true
	elif strategy == ANIMA.VISIBILITY.HIDDEN_AND_TRANSPARENT:
		should_hide_nodes = true
		should_make_nodes_transparent = true
	elif strategy == ANIMA.VISIBILITY.TRANSPARENT_ONLY:
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

func add_frames(animation_data: Dictionary, full_keyframes_data: Dictionary) -> float:
	if not is_instance_valid(get_parent()):
		return 0.0

	var frames = AnimaKeyframesEngine.parse_frames(animation_data, full_keyframes_data)
	var duration = animation_data.duration
	var is_first_frame := true
	var initial_wait_time = animation_data._wait_time if animation_data.has("_wait_time") else 0.0

	for frame in frames:
		var frame_duration = frame._wait_time + frame.duration

		duration = max(duration, frame_duration - initial_wait_time)

		frame._is_first_frame = is_first_frame

		add_animation_data(frame)

		is_first_frame = false

	return duration

func get_duration() -> float:
	var duration := 0.0

	for data in _animation_data:
		var data_duration = data._wait_time + data.duration

		duration = max(duration, data_duration)

	return duration
	
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

func _on_tween_completed(_ignore = null) -> void:
	_tween.stop()

	animation_completed.emit()

func _on_node_tree_exiting(anima_item: Node) -> void:
	anima_item.free()

class AnimatedItem extends Node:
	var _node: Node
	var _callback: Callable
	var _callback_param
	var _property
	var _key
	var _subKey
	var _animation_data: Dictionary
	var _root_node: Node
	var _property_data: Dictionary
	var _easing_curve: Curve
	var _visibility_applied := false
	var _animate_callback: Callable

	func set_animation_data(data: Dictionary, property_data: Dictionary) -> void:
		_animation_data = data

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

		_animate_callback = _animate_normal

		if _animation_data.has("_decimals"):
			_animate_callback = _animate_with_fixed_decimals

		if _animation_data.has("__debug"):
			print("Using:")
			printt("", property_data)
			printt("", "AnimatedPropertyItem:", self is AnimatedPropertyItem)
			printt("", "AnimatedPropertyWithKeyItem:", self is AnimatedPropertyWithKeyItem)
			printt("", "AnimatedPropertyWithSubKeyItem:", self is AnimatedPropertyWithSubKeyItem)
			printt("", "AnimateObjectWithKey:", self is AnimateObjectWithKey)
			printt("", "AnimateObjectWithSubKey:", self is AnimateObjectWithSubKey)
			printt("", "AnimateRect2:", self is AnimateRect2)

	func set_visibility_strategy() -> void:
		_visibility_applied = true

		var visibility_strategy = _node.get_meta(VISIBILITY_STRATEGY_META_KEY) if _node.has_meta(VISIBILITY_STRATEGY_META_KEY) else null

		if _node.has_meta("_visibility_strategy_reverted") or visibility_strategy == null:
			return

		_node.set_meta("_visibility_strategy_reverted", true)

		if _animation_data.has("visibility_strategy"):
			visibility_strategy = _animation_data.visibility_strategy

		var should_restore_visibility := false
		var should_restore_modulate := false

		if visibility_strategy == ANIMA.VISIBILITY.HIDDEN_ONLY:
			should_restore_visibility = true
		elif visibility_strategy == ANIMA.VISIBILITY.HIDDEN_AND_TRANSPARENT:
			should_restore_modulate = true
			should_restore_visibility = true
		elif visibility_strategy == ANIMA.VISIBILITY.TRANSPARENT_ONLY:
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

	func animate(elapsed: float) -> void:
		_animate_callback.call(elapsed)
	
	func _animate_normal(elapsed: float) -> void:
		if not _visibility_applied:
			set_visibility_strategy()

		if _property_data.size() == 0:
			_property_data = AnimaTweenUtils.calculate_from_and_to(_animation_data)

			if _animation_data.has("__debug"):
				printt("_property_data", _property_data)
				print("")

		var from = _property_data.from
		var diff = _property_data.diff

		var value = from + (diff * elapsed)

		apply_value(value)

	func _animate_with_fixed_decimals(elapsed: float) -> void:
		if not _visibility_applied:
			set_visibility_strategy()

		if _property_data.size() == 0:
			_property_data = AnimaTweenUtils.calculate_from_and_to(_animation_data)

			if _animation_data.has("__debug"):
				printt("_property_data", _property_data)
				print("")

		var from = _property_data.from
		var diff = _property_data.diff

		var value = snapped(from + (diff * elapsed), _animation_data._decimals)

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
		var easing_callback = Callable(AnimaEasing, easing_points_function)
		var easing_elapsed = easing_callback.call(elapsed)

		animate(easing_elapsed)

	func animate_with_easing_funcref(elapsed: float) -> void:
		var easing_callback = _animation_data._easing_points
		var easing_elapsed = easing_callback.call(elapsed)

		animate(easing_elapsed)

	func animate_with_parameterized_easing(elapsed: float) -> void:
		var easing_callback = _animation_data._easing_points
		var easing_params = _animation_data._easing_params
		var easing_elapsed = easing_callback.call(elapsed, easing_params)

		animate(easing_elapsed)

	func animate_with_curve(elapsed: float) -> void:
		var easing_elapsed = _easing_curve.sample(elapsed)

		animate(easing_elapsed)

	func animate_linear(elapsed: float) -> void:
		animate(elapsed)

	func _cubic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> float:
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var q2 = p2.lerp(p3, t)

		var r0 = q0.lerp(q1, t)
		var r1 = q1.lerp(q2, t)

		var s = r0.lerp(r1, t)

		return s.y

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
		_callback.callv([_callback_param, value])

class AnimateRect2 extends AnimatedItem:
	func animate(elapsed: float) -> void:
		if _property_data.size() == 0:
			_property_data = AnimaTweenUtils.calculate_from_and_to(_animation_data)

		apply_value(Rect2(
			_property_data.from.position + (_property_data.diff.position * elapsed),
			_property_data.from.size + (_property_data.diff.size * elapsed)
		))

	func apply_value(value: Rect2) -> void:
		_node.set(_property, value)

class AnimaEvent extends Node:
	var _data: Dictionary
	var _callback
	var _executed := false
	var _is_playing_backwards: bool

	func _init(animation_data: Dictionary,callback_key: String, is_playing_backwards: bool):
		_data = animation_data
		_callback = animation_data[callback_key]
		_is_playing_backwards = is_playing_backwards

	func execute_callback():
		var fn
		var args: Array = []

		if _callback is Array:
			fn = _callback[0]
			args = _callback[1]
		elif _callback is Dictionary:
			var value = _callback.value if not _is_playing_backwards else _callback.backwards_value

			fn = _callback.target

			if value is Array:
				args = value
			else:
				args = [value]

		else:
			fn = _callback

		if fn:
			fn.callv(args)

func reverse_animation(tween: AnimaTween, animation_length: float, overridden_default_duration: float):
	var data: Array = _flip_animations(tween.get_animation_data().duplicate(true), animation_length, overridden_default_duration)

	for new_data in data:
		add_animation_data(new_data)

#
# In order to flip nested relative animations we need to calculate the final value it would
# have if played forwards. Then we can calculate the correct relative positions, by also looking at the previous frames.
# Otherwise we would end up with broken animations when animating the same property more than
# once
func _flip_animations(data: Array, animation_length: float, overridden_default_duration: float) -> Array:
	var new_data := []
	var previous_frames := {}
	var length: float = animation_length

	data.reverse()
	for animation in data:
		if animation.has("_ignore_for_backwards"):
			continue

		var animation_data = animation.duplicate(true)

		var duration: float = float(animation_data.duration) if animation_data.has('duration') else overridden_default_duration
		var wait_time: float = animation_data._wait_time
		var node = animation_data.node
		var new_wait_time: float = length - duration - wait_time
		var property = animation_data.property
		var is_relative = animation_data.has("relative") and animation_data.relative

		if animation_data.has("initial_value"):
			animation_data.erase("initial_value")

		if animation_data.has("initial_values"):
			animation_data.erase("initial_values")

		var temp = animation_data.to
		var meta_key: String = "__initial_" + node.name + "_" + str(animation_data.property) 

		if animation_data.has("from"):
			animation_data.to = animation_data.from
		elif node.has_meta(meta_key):
			animation_data.to = node.get_meta(meta_key)

		animation_data.from = temp

		animation_data._wait_time = max(ANIMA.MINIMUM_DURATION, new_wait_time)

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
		
		if animation_data.has("easing") and animation_data.easing:
			animation_data.easing = AnimaEasing.get_mirrored_easing(animation_data.easing)

		new_data.push_back(animation_data)

	return new_data
