extends Object
class_name AnimaDeclarationBase

var _data := {}
var _is_single_shot := true

enum PlayAction {
	PLAY,
	PLAY_WITH_DELAY,
	PLAY_WITH_SPEED,
	PLAY_BACKWARDS,
	PLAY_BACKWARDS_WITH_DELAY,
	PLAY_BACKWARDS_WITH_SPEED,
}

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
	var anima := Anima.begin(__get_source()).then(_data)
	anima.set_single_shot(_is_single_shot)

	match action:
		PlayAction.PLAY:
			anima.play()
		PlayAction.PLAY_WITH_DELAY:
			anima.play_with_delay(param)
		PlayAction.PLAY_WITH_SPEED:
			anima.play_with_speed(param)
		PlayAction.PLAY_BACKWARDS:
			anima.play_backwards()
		PlayAction.PLAY_BACKWARDS_WITH_DELAY:
			anima.play_backwards_with_delay(param)
		PlayAction.PLAY_BACKWARDS_WITH_SPEED:
			anima.play_backwards_with_speed(param)

	return anima

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
