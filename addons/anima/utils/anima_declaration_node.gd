extends AnimaDeclarationBase
class_name AnimaDeclarationNode

func node(node) -> AnimaDeclarationNode:
	self._data.node = node

	return self

func anima_from(from) -> AnimaDeclarationNode:
	.anima_from(from)

	return self

func anima_to(to) -> AnimaDeclarationNode:
	.anima_to(to)

	return self

func anima_duration(duration: float) -> AnimaDeclarationNode:
	.anima_duration(duration)

	return self

func anima_delay(delay: float) -> AnimaDeclarationNode:
	.anima_delay(delay)

	return self

func anima_animation(animation_name: String) -> AnimaDeclarationNode:
	.anima_animation(animation_name)

	return self

func anima_property(property_name) -> AnimaDeclarationNode:
	.anima_animation(property_name)

	return self

func anima_relative(relative: bool) -> AnimaDeclarationNode:
	.anima_relative(relative)

	return self

func anima_easing(easing) -> AnimaDeclarationNode:
	.anima_easing(easing)

	return self

func anima_pivot(pivot: int) -> AnimaDeclarationNode:
	.anima_pivot(pivot)

	return self

func anima_visibility_strategy(strategy: int) -> AnimaDeclarationNode:
	.anima_visibility_strategy(strategy)

	return self

func anima_initial_value(initial_value) -> AnimaDeclarationNode:
	.anima_initial_value(initial_value)

	return self

func anima_initial_values(initial_values: Dictionary) -> AnimaDeclarationNode:
	.anima_initial_values(initial_values)

	return self

func anima_on_started(on_started: FuncRef, on_started_value, on_backwards_completed_value) -> AnimaDeclarationNode:
	.anima_on_started(on_started, on_started_value, on_backwards_completed_value)

	return self

func anima_on_completed(on_completed: FuncRef) -> AnimaDeclarationNode:
	.anima_on_completed(on_completed)

	return self
