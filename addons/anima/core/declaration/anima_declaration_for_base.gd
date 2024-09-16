extends Object
class_name AnimaDeclarationForBase

var _parent_class

func _add(key, value):
	_parent_class._add(key, value)

func get_data() -> Dictionary:
	return _parent_class.get_data()

func _init(parent_class):
	_parent_class = parent_class

func _init_me(data: Dictionary):
	for key in data:
		var value = data[key]

		if value != null:
			_parent_class._add(key, data[key])

func anima_from(from) -> Variant:
	if from == null:
		return self

	_parent_class._add("from", from)

	return self

func anima_to(to) -> Variant:
	if to == null:
		return self

	_parent_class._add("to", to)

	return self

func anima_delay(delay: float) -> Variant:
	_parent_class._add("delay", delay)

	return self

func anima_visibility_strategy(strategy: int) -> Variant:
	_parent_class._add("visibility_strategy", strategy)

	return self

func anima_initial_value(initial_value) -> Variant:
	#var values := {}
	#values[_parent_class.get("property")] = initial_value

	_parent_class._add("initial_value", initial_value)

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

	_parent_class._add("on_started", { 
		target = target,
		value = on_started_value,
		backwards_value = on_backwards_completed_value
	})
	
	return self

func anima_on_completed(target: Callable, on_completed_value = null, on_backwards_completed_value = null) -> Variant:
	_parent_class._add("on_completed", {
		target = target,
		value = on_completed_value,
		backwards_value = on_backwards_completed_value
	})
	
	return self

func anima_with(new_class = null, delay = null) -> AnimaDeclarationNode:
	return _parent_class._with(new_class, delay)

func anima_then(new_class = null, delay = null) -> AnimaDeclarationNode:
	return _parent_class._then(new_class, delay)

func play() -> AnimaNode:
	return _parent_class.play()

func play_with_delay(delay: float) -> AnimaNode:
	return _parent_class.play_with_delay(delay)

func play_with_speed(speed: float) -> AnimaNode:
	return _parent_class.play_with_speed(speed)

func play_backwards() -> AnimaNode:
	return _parent_class.play_backwards()

func play_backwards_with_delay(delay: float) -> AnimaNode:
	return _parent_class.play_backwards_with_delay(delay)

func play_backwards_with_speed(speed: float) -> AnimaNode:
	return _parent_class.play_backwards_with_speed(speed)

func loop(times: int = -1) -> AnimaNode:
	return _parent_class.loop(times)

func loop_in_circle(times: int = -1) -> AnimaNode:
	return _parent_class.loop_in_circle(times)

func loop_in_circle_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_in_circle_with_delay(delay, times)

func loop_in_circle_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_in_circle_with_speed(speed, times)

func loop_in_circle_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_in_circle_with_delay_and_speed(delay, speed, times)

func loop_backwards(times: int = -1) -> AnimaNode:
	return _parent_class.loop_backwards(times)

func loop_backwards_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_backwards_with_speed(speed, times)

func loop_backwards_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_backwards_with_delay(delay, times)

func loop_backwards_with_delay_and_speed(delay: float, speed: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_backwards_with_delay_and_speed(delay, speed, times)

func loop_with_delay(delay: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_with_delay(delay, times)

func loop_with_speed(speed: float, times: int = -1) -> AnimaNode:
	return _parent_class.loop_with_speed(speed, times)

func loop_times_with_delay(times: float, delay: float) -> AnimaNode:
	return _parent_class.loop_times_with_delay(times, delay)

func loop_times_with_delay_and_speed(times: int, delay: float, speed: float) -> AnimaNode:
	return _parent_class.loop_times_with_delay_and_speed(times, delay, speed)
