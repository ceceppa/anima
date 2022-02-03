extends Object
class_name AnimaDeclarationBase

var _data := {}

func get_data() -> Dictionary:
	return _data

func anima_from(from):
	if from == null:
		return

	_data.from = from

func anima_to(to):
	if to == null:
		return self

	_data.to = to

func anima_duration(duration: float):
	_data.duration = max(Anima.MINIMUM_DURATION, duration)

func anima_delay(delay: float):
	_data.delay = delay

func anima_animation(animation):
	if _data.has("property"):
		printerr("The property parameter have already been specified, so the animation one will be ignored.")

		return 

	_data.animation = animation

func anima_property(property_name):
	if _data.has("animation"):
		printerr("The animation parameter have already been specified, so the property one will be ignored.")

		return

	_data.property = property_name

func anima_relative(relative: bool):
	_data.relative = relative

func anima_easing(easing):
	_data.easing = easing

func anima_pivot(pivot: int):
	_data.pivot = pivot

func anima_visibility_strategy(strategy: int):
	_data.visibility_strategy = strategy

func anima_initial_value(initial_value):
	var values := {}
	values[_data.property] = initial_value

	_data.initial_values = values

func anima_initial_values(initial_values: Dictionary):
	_data.initial_values = initial_values

func anima_on_started(on_started: FuncRef, on_started_value, on_backwards_completed_value):
	if typeof(on_started_value) != TYPE_ARRAY:
		on_started_value = [on_started_value]

	if typeof(on_backwards_completed_value) != TYPE_ARRAY:
		on_backwards_completed_value = [on_backwards_completed_value]

	_data.on_started = [on_started, on_started_value, on_backwards_completed_value]

func anima_on_completed(on_completed: FuncRef):
	_data.on_completed = on_completed

func debug():
	_data.__debug = true

	return self
