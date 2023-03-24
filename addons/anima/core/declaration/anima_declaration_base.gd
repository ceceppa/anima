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

func anima_on_started(target: Object, method: String, on_started_value = null, on_backwards_completed_value = null):
	if typeof(on_started_value) != TYPE_ARRAY:
		on_started_value = [on_started_value]

	if typeof(on_backwards_completed_value) != TYPE_ARRAY:
		on_backwards_completed_value = [on_backwards_completed_value]

	_data.on_started = { 
		target = target,
		method = method,
		value = on_started_value,
		backwards_value = on_backwards_completed_value
	}

func anima_on_completed(target: Object, method: String, on_completed_value = null, on_backwards_completed_value = null):
	_data.on_completed = { 
		target = target,
		method = method,
		value = on_completed_value,
		backwards_value = on_backwards_completed_value
	}

func debug(what = "---"):
	_data.__debug = what

	return self
