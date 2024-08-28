extends Object
class_name AnimaDeclarationBase

var _data := {}
var _is_single_shot := true
var _anima_node: AnimaNode

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

func clear():
	_anima_node.clear()

func get_data() -> Dictionary:
	return _data

func _init_me(data: Dictionary):
	for key in data:
		var value = data[key]

		if value != null:
			_data[key] = data[key]

func anima_from(from) -> Variant:
	if from == null:
		return self

	_data.from = from

	return self

func anima_to(to) -> Variant:
	if to == null:
		return self

	_data.to = to

	return self

func anima_delay(delay: float) -> Variant:
	_data.delay = delay

	return self

func anima_visibility_strategy(strategy: int) -> Variant:
	_data.visibility_strategy = strategy

	return self

func anima_initial_value(initial_value) -> Variant:
	var values := {}
	values[_data.property] = initial_value

	_data.initial_values = values

	return self

func anima_on_started(target: Callable, on_started_value = null, on_backwards_completed_value = null) -> Variant:
	if typeof(on_started_value) != TYPE_ARRAY:
		if on_started_value == null:
			on_started_value = []
		else:
			on_started_value = [on_started_value]

	if typeof(on_backwards_completed_value) != TYPE_ARRAY:
		if on_backwards_completed_value == null:
			on_backwards_completed_value = []
		else:
			on_backwards_completed_value = [on_backwards_completed_value]

	_data.on_started = { 
		target = target,
		value = on_started_value,
		backwards_value = on_backwards_completed_value
	}
	
	return self

func anima_on_completed(target: Callable, on_completed_value = null, on_backwards_completed_value = null) -> Variant:
	_data.on_completed = { 
		target = target,
		value = on_completed_value,
		backwards_value = on_backwards_completed_value
	}
	
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

func _do_play(action: PlayAction, param = null) -> AnimaNode:
	if _anima_node == null:
		_anima_node = Anima.begin(__get_source()).then(_data)

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
