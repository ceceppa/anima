extends Object
class_name AnimaDeclarationBase

var _data := {}

func get_data() -> Dictionary:
	return _data

func _init_me(data: Dictionary):
	for key in data:
		var value = data[key]

		if value != null:
			_data[key] = data[key]

func anima_from(from):
	if from == null:
		return

	_data.from = from

func anima_to(to):
	if to == null:
		return self

	_data.to = to

func anima_delay(delay: float):
	_data.delay = delay

func anima_visibility_strategy(strategy: int):
	_data.visibility_strategy = strategy

func anima_initial_value(initial_value):
	var values := {}
	values[_data.property] = initial_value

	_data.initial_values = values

func anima_on_started(target: Callable, on_started_value = null, on_backwards_completed_value = null):
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

func anima_on_completed(target: Callable, on_completed_value = null, on_backwards_completed_value = null):
	_data.on_completed = { 
		target = target,
		value = on_completed_value,
		backwards_value = on_backwards_completed_value
	}

func debug(what = "---"):
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

func play():
	Anima.begin_single_shot(__get_source()).then(_data).play()

func play_with_delay(delay: float):
	Anima.begin_single_shot(__get_source()).then(_data).play_with_delay(delay)

func play_with_speed(speed: float):
	Anima.begin_single_shot(__get_source()).then(_data).play_with_speed(speed)

func play_backwards():
	Anima.begin_single_shot(__get_source()).then(_data).play_backwards()

func play_backwards_with_delay(delay: float):
	Anima.begin_single_shot(__get_source()).then(_data).play_backwards_with_delay(delay)

func play_backwards_with_speed(speed: float):
	Anima.begin_single_shot(__get_source()).then(_data).play_backwards_with_speed(speed)
