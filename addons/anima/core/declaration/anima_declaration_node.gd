class_name AnimaDeclarationNode

var _data := {}

var _target_data = _data
var _anima_declaration
var _anima_node: AnimaNode
var _is_single_shot := true

enum PlayAction {
	PLAY,
	PLAY_WITH_DELAY,
	PLAY_WITH_SPEED,
	PLAY_BACKWARDS,
	PLAY_BACKWARDS_WITH_DELAY,
	PLAY_BACKWARDS_WITH_SPEED,
	LOOP,
	LOOP_IN_CIRCLE,
	LOOP_IN_CIRCLE_WITH_DELAY,
	LOOP_IN_CIRCLE_WITH_SPEED,
	LOOP_IN_CIRCLE_WITH_DELAY_AND_SPEED,
	LOOP_BACKWARDS,
	LOOP_BACKWARDS_WITH_SPEED,
	LOOP_BACKWARDS_WITH_DELAY,
	LOOP_BACKWARDS_WITH_DELAY_AND_SPEED,
	LOOP_WITH_DELAY,
	LOOP_WITH_SPEED,
	LOOP_TIMES_WITH_DELAY,
	LOOP_TIMES_WITH_DELAY_AND_SPEED
}

func _init(node: Node = null):
	if Engine.is_editor_hint():
		_clear_metakeys(node)

	_data.clear()
	_target_data = _data

	_target_data.node = node

func _set_data(data: Dictionary):
	_target_data = data

	return self

func _create_declaration_for_animation(data: Dictionary) -> AnimaDeclarationForAnimation:
	var c:= AnimaDeclarationForAnimation.new(self)

	for key in data:
		_target_data[key] = data[key]

	return c._init_me(_target_data)

func _create_declaration_with_easing(data: Dictionary) -> AnimaDeclarationForProperty:
	var c:= AnimaDeclarationForProperty.new(self)

	if data.has("duration") and data.duration == null and _target_data.has("duration"):
		data.duration = _target_data.duration

	for key in data:
		_target_data[key] = data[key]

	return c._init_me(_target_data)

func _create_relative_declaration_with_easing(data: Dictionary) -> AnimaDeclarationForRelativeProperty:
	var c:= AnimaDeclarationForRelativeProperty.new(self)

	for key in data:
		_target_data[key] = data[key]

	return c._init_me(_target_data)
	
func anima_animation(animation: String, duration = null) -> AnimaDeclarationForAnimation:
	_anima_declaration = _create_declaration_for_animation({ animation = animation, duration = duration })

	return _anima_declaration

func anima_animation_frames(frames: Dictionary, duration = null) -> AnimaDeclarationForAnimation:
	_anima_declaration = _create_declaration_for_animation({ animation = frames, duration = duration })

	return _anima_declaration

func anima_property(property: String, final_value = null, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = property, to = final_value, duration = duration })

	return _anima_declaration

func anima_fade_in(duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "opacity", from = 0.0, to = 1.0, duration = duration })

	return _anima_declaration

func anima_fade_out(duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "opacity", from = 1.0, to = 0.0, duration = duration })

	return _anima_declaration

func anima_position(position: Vector2, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "position", to = position, duration = duration })

	return _anima_declaration

func anima_position3D(position: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "position", to = position, duration = duration })

	return _anima_declaration

func anima_position_x(x: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "x", to = x, duration = duration })

	return _anima_declaration

func anima_position_y(y: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "y", to = y, duration = duration })

	return _anima_declaration

func anima_position_z(z: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "z", to = z, duration = duration })

	return _anima_declaration

func anima_relative_position(position: Vector2, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "position", to = position, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position3D(position: Vector3, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "position", to = position, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position_x(x: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "x", to = x, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position_y(y: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "y", to = y, duration = duration, relative = true })

	return _anima_declaration

func anima_relative_position_z(z: float, duration = null) -> AnimaDeclarationForRelativeProperty:
	_anima_declaration = _create_relative_declaration_with_easing({ property = "z", to = z, duration = duration, relative = true })

	return _anima_declaration

func anima_scale(scale: Vector2, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale", to = scale, duration = duration })

	return _anima_declaration

func anima_scale3D(scale: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale", to = scale, duration = duration })

	return _anima_declaration

func anima_scale_x(x: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale:x", to = x, duration = duration })

	return _anima_declaration

func anima_scale_y(y: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale:y", to = y, duration = duration })

	return _anima_declaration

func anima_scale_z(z: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "scale:z", to = z, duration = duration })

	return _anima_declaration

func anima_size(size: Vector2, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size", to = size, duration = duration })

	return _anima_declaration

func anima_size3D(size: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size", to = size, duration = duration })

	return _anima_declaration

func anima_size_x(size: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size:x", to = size, duration = duration })

	return _anima_declaration

func anima_size_y(size: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size:y", to = size, duration = duration })

	return _anima_declaration

func anima_size_z(size: float, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "size:z", to = size, duration = duration })

	return _anima_declaration

func anima_rotate(rotate: float, pivot: int = ANIMA.PIVOT.CENTER, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotate", to = rotate, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_rotate3D(rotate: Vector3, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation", to = rotate, duration = duration })

	return _anima_declaration

func anima_rotate_x(x: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation:x", to = x, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_rotate_y(y: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation:y", to = y, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_rotate_z(z: float, pivot: int, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "rotation:z", to = z, duration = duration, pivot = pivot })

	return _anima_declaration

func anima_shader_param(param_name: String, to_value, duration = null) -> AnimaDeclarationForProperty:
	_anima_declaration = _create_declaration_with_easing({ property = "shader_param:" + param_name, to = to_value, duration = duration })

	return _anima_declaration

func clear():
	if _anima_node and is_instance_valid(_anima_node):
		_anima_node.clear()

	_clear_metakeys(_target_data.node)

	return self

func _then():
	_nested_animation("_then")

func _with():
	_nested_animation("_with")

func _nested_animation(key):
	if not _target_data.has(key):
		_target_data[key] = {}

	if _target_data.has("node"):
		_target_data[key].node = _target_data.node
	elif _target_data.has("grid"):
		_target_data[key].grid = _target_data.grid
	elif _target_data.has("group"):
		_target_data[key].group = _target_data.group

	var has_duration = _target_data.has("duration")
	var duration = _target_data.duration if has_duration else null

	if has_duration:
		_target_data[key].duration = duration

	_target_data = _target_data[key]

	return self

func as_reusable() -> Variant:
	_is_single_shot = false
	
	return self

func debug(what = "---") -> Variant:
	_data.__debug = what

	return self

func __get_source():
	if _data.has("node"):
		return _data.node
	elif _data.has("grid"):
		return _data.grid
	elif _data.has("group"):
		return _data.group
	
	return null

func _init_anima_node(data, mode):
	if _anima_node == null:
		_anima_node = Anima.begin(__get_source())

	if not data.has("duration") or data.duration == null:
		data.duration = ANIMA.DEFAULT_DURATION

	if mode == "with":
		_anima_node.with(data)

	if data.has("_with"):
		_init_anima_node(data._with, "with")

	if data.has("_then"):
		_init_anima_node(data._then, "then")

func _do_play(action: PlayAction, param = null) -> AnimaNode:
	_init_anima_node(_data, "with")

	var single_shot = _is_single_shot if action < PlayAction.LOOP else false
	_anima_node.set_single_shot(single_shot)

	match action:
		PlayAction.PLAY:
			_anima_node.play()
		PlayAction.PLAY_WITH_DELAY:
			_anima_node.play_with_delay(param)
		PlayAction.PLAY_WITH_SPEED:
			_anima_node.play_with_speed(param)
		PlayAction.PLAY_BACKWARDS:
			_anima_node.play_backwards()
		PlayAction.PLAY_BACKWARDS_WITH_DELAY:
			_anima_node.play_backwards_with_delay(param)
		PlayAction.PLAY_BACKWARDS_WITH_SPEED:
			_anima_node.play_backwards_with_speed(param)
		PlayAction.LOOP:
			_anima_node.loop(param)
		PlayAction.LOOP_IN_CIRCLE:
			_anima_node.loop_in_circle(param)
		PlayAction.LOOP_IN_CIRCLE_WITH_DELAY:
			_anima_node.loop_in_circle_with_delay(param)
		PlayAction.LOOP_IN_CIRCLE_WITH_SPEED:
			_anima_node.loop_in_circle_with_speed(param.speed, param.times)
		PlayAction.LOOP_IN_CIRCLE_WITH_DELAY_AND_SPEED:
			_anima_node.loop_in_circle_with_delay_and_speed(param.delay, param.speed, param.times)
		PlayAction.LOOP_BACKWARDS:
			_anima_node.loop_backwards(param)
		PlayAction.LOOP_BACKWARDS_WITH_SPEED:
			_anima_node.loop_backwards_with_speed(param.speed, param.times)
		PlayAction.LOOP_BACKWARDS_WITH_DELAY:
			_anima_node.loop_with_delay(param.delay, param.times)
		PlayAction.LOOP_BACKWARDS_WITH_DELAY_AND_SPEED:
			_anima_node.loop_times_with_delay_and_speed(param.times, param.delay, param.speed)
		PlayAction.LOOP_WITH_DELAY:
			_anima_node.loop_with_delay(param.delay, param.times)
		PlayAction.LOOP_WITH_SPEED:
			_anima_node.loop_with_speed(param.speed, param.times)
		PlayAction.LOOP_TIMES_WITH_DELAY:
			_anima_node.loop_times_with_delay(param.times, param.delay)
		PlayAction.LOOP_TIMES_WITH_DELAY_AND_SPEED:
			_anima_node.loop_times_with_delay_and_speed(param.times, param.delay, param.speed)

	return _anima_node

func play() -> AnimaNode:
	return _do_play(PlayAction.PLAY)

func play_with_delay(delay: float) -> AnimaNode:
	return _do_play(PlayAction.PLAY_WITH_DELAY, delay)

func play_with_speed(speed: float) -> AnimaNode:
	return _do_play(PlayAction.PLAY_BACKWARDS_WITH_SPEED, speed)

func play_backwards() -> AnimaNode:
	return _do_play(PlayAction.PLAY_BACKWARDS)

func play_backwards_with_delay(delay: float) -> AnimaNode:
	return _do_play(PlayAction.PLAY_BACKWARDS_WITH_DELAY, delay)

func play_backwards_with_speed(speed: float) -> AnimaNode:
	return _do_play(PlayAction.PLAY_BACKWARDS_WITH_SPEED, speed)

func loop(times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP, times)

func loop_in_circle(times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_IN_CIRCLE, times)

func loop_in_circle_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_IN_CIRCLE_WITH_DELAY, times)

func loop_in_circle_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_IN_CIRCLE_WITH_SPEED, { times = times, speed = speed })

func loop_in_circle_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_IN_CIRCLE_WITH_DELAY_AND_SPEED, { times = times, delay = delay, speed = speed })

func loop_backwards(times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_BACKWARDS, times)

func loop_backwards_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_BACKWARDS_WITH_SPEED, { times = times, speed = speed })

func loop_backwards_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_BACKWARDS_WITH_DELAY, { times = times, delay = delay })

func loop_backwards_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_BACKWARDS_WITH_DELAY_AND_SPEED, { times = times, delay = delay, speed = speed })

func loop_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_WITH_DELAY,  { times = times, delay = delay })

func loop_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _do_play(PlayAction.LOOP_WITH_SPEED, { times = times, speed = speed })

func loop_times_with_delay(times: float, delay: float) -> AnimaNode:
	return _do_play(PlayAction.LOOP_TIMES_WITH_DELAY, { times = times, delay = delay })

func loop_times_with_delay_and_speed(times: int, delay: float, speed: float) -> AnimaNode:
	return _do_play(PlayAction.LOOP_TIMES_WITH_DELAY_AND_SPEED, { times = times, delay = delay, speed = speed })

func _add(key, value) -> void:
	_target_data[key] = value

func _get(key) -> Variant:
	return _target_data[key]

func _clear_metakeys(node: Node):
	for meta in node.get_meta_list():
		if meta.begins_with("__anima"):
			node.remove_meta(meta)
