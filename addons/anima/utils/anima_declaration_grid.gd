extends AnimaDeclarationBase
class_name AnimaDeclarationGrid

func _grid(grid: Node) -> AnimaDeclarationGrid:
	self._data.grid = grid

	return self

func anima_grid_size(size: Vector2) -> AnimaDeclarationGrid:
	self._data.grid_size = size

	return self

func anima_sequence_type(type: int) -> AnimaDeclarationGrid:
	self._data.animation_type = type

	return self

func anima_point(point: Vector2) -> AnimaDeclarationGrid:
	self._data.point = point

	return self

func anima_items_delay(delay: float) -> AnimaDeclarationGrid:
	self._data.items_delay = delay

	return self


func anima_from(from) -> AnimaDeclarationGrid:
	.anima_from(from)

	return self

func anima_to(to) -> AnimaDeclarationGrid:
	.anima_to(to)

	return self

func anima_duration(duration: float) -> AnimaDeclarationGrid:
	.anima_duration(duration)

	return self

func anima_delay(delay: float) -> AnimaDeclarationGrid:
	.anima_delay(delay)

	return self

func anima_animation(animation, ignore_relative := false) -> AnimaDeclarationGrid:
	.anima_animation(animation, ignore_relative)

	return self

func anima_property(property_name) -> AnimaDeclarationGrid:
	.anima_property(property_name)

	return self

func anima_relative(relative: bool) -> AnimaDeclarationGrid:
	.anima_relative(relative)

	return self

func anima_easing(easing) -> AnimaDeclarationGrid:
	.anima_easing(easing)

	return self

func anima_pivot(pivot: int) -> AnimaDeclarationGrid:
	.anima_pivot(pivot)

	return self

func anima_visibility_strategy(strategy: int) -> AnimaDeclarationGrid:
	.anima_visibility_strategy(strategy)

	return self

func anima_initial_value(initial_value) -> AnimaDeclarationGrid:
	.anima_initial_value(initial_value)

	return self

func anima_initial_values(initial_values: Dictionary) -> AnimaDeclarationGrid:
	.anima_initial_values(initial_values)

	return self

func anima_on_started(on_started: FuncRef, on_started_value, on_backwards_completed_value) -> AnimaDeclarationGrid:
	.anima_on_started(on_started, on_started_value, on_backwards_completed_value)

	return self

func anima_on_completed(on_completed: FuncRef) -> AnimaDeclarationGrid:
	.anima_on_completed(on_completed)

	return self
