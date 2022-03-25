class_name AnimaDeclarationForProperty
extends AnimaDeclarationBase

# We can't use _init otherwise Godot complains with this nonsense
# Too few arguments for "_init()". Expected at least 1
func _init_me(data: Dictionary) -> AnimaDeclarationForProperty:
	._init_me(data)

	return self

func anima_as_relative() -> AnimaDeclarationForProperty:
	self._data.relative = true
	
	return self

func anima_easing(easing) -> AnimaDeclarationForProperty:
	self._data.easing = easing

	return self

func anima_pivot(pivot: int) -> AnimaDeclarationForProperty:
	self._data.pivot = pivot

	return self

func anima_from(value) -> AnimaDeclarationForProperty:
	.anima_from(value)

	return self

func anima_to(value) -> AnimaDeclarationForProperty:
	.anima_to(value)

	return self

func anima_delay(value: float) -> AnimaDeclarationForProperty:
	.anima_delay(value)

	return self

func anima_visibility_strategy(value: int) -> AnimaDeclarationForProperty:
	.anima_visibility_strategy(value)

	return self

func anima_initial_value(value) -> AnimaDeclarationForProperty:
	.anima_initial_value(value)

	return self

func anima_on_started(on_started: FuncRef, on_started_value, on_backwards_completed_value = null) -> AnimaDeclarationForProperty:
	.anima_on_started(on_started, on_started_value, on_backwards_completed_value)

	return self

func anima_on_completed(on_completed: FuncRef, on_completed_value, on_backwards_started_value = null) -> AnimaDeclarationForProperty:
	.anima_on_completed(on_completed, on_completed_value, on_backwards_started_value)

	return self
