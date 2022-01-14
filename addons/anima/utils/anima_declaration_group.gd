extends AnimaDeclarationBase
class_name AnimaDeclarationGroup

func _group(group) -> AnimaDeclarationGroup:
	self._data.group = group

	return self

func anima_animation_type(type: int) -> AnimaDeclarationGroup:
	self._data.animation_type = type

	return self

func anima_point(point: Vector2) -> AnimaDeclarationGroup:
	self._data.point = point

	return self

func anima_items_delay(delay: float) -> AnimaDeclarationGroup:
	self._data.items_delay = delay

	return self


func anima_from(from) -> AnimaDeclarationGroup:
	.anima_from(from)

	return self

func anima_to(to) -> AnimaDeclarationGroup:
	.anima_to(to)

	return self

func anima_duration(duration: float) -> AnimaDeclarationGroup:
	.anima_duration(duration)

	return self

func anima_delay(delay: float) -> AnimaDeclarationGroup:
	.anima_delay(delay)

	return self

func anima_animation(animation_name: String) -> AnimaDeclarationGroup:
	.anima_animation(animation_name)

	return self

func anima_property(property_name) -> AnimaDeclarationGroup:
	.anima_property(property_name)

	return self

func anima_relative(relative: bool) -> AnimaDeclarationGroup:
	.anima_relative(relative)

	return self

func anima_easing(easing) -> AnimaDeclarationGroup:
	.anima_easing(easing)

	return self

func anima_pivot(pivot: int) -> AnimaDeclarationGroup:
	.anima_pivot(pivot)

	return self

func anima_visibility_strategy(strategy: int) -> AnimaDeclarationGroup:
	.anima_visibility_strategy(strategy)

	return self

func anima_initial_value(initial_value) -> AnimaDeclarationGroup:
	.anima_initial_value(initial_value)

	return self

func anima_initial_values(initial_values: Dictionary) -> AnimaDeclarationGroup:
	.anima_initial_values(initial_values)

	return self

func anima_on_started(on_started: FuncRef, on_started_value, on_backwards_completed_value) -> AnimaDeclarationGroup:
	.anima_on_started(on_started, on_started_value, on_backwards_completed_value)

	return self

func anima_on_completed(on_completed: FuncRef) -> AnimaDeclarationGroup:
	.anima_on_completed(on_completed)

	return self
