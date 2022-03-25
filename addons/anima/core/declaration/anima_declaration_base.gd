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

func anima_on_started(on_started: FuncRef, on_started_value, on_backwards_completed_value = null):
	if typeof(on_started_value) != TYPE_ARRAY:
		on_started_value = [on_started_value]

	if typeof(on_backwards_completed_value) != TYPE_ARRAY:
		on_backwards_completed_value = [on_backwards_completed_value]

	_data.on_started = [on_started, on_started_value, on_backwards_completed_value]

func anima_on_completed(on_completed: FuncRef, on_completed_value, on_backwards_started_value = null):
	_data.on_completed = [on_completed, on_completed_value, on_backwards_started_value]

func debug():
	_data.__debug = true

	return self
