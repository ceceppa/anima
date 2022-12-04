class_name AnimaDeclarationForProperty
extends AnimaDeclarationBase

# We can't use _init otherwise Godot complains with this nonsense
# Too few arguments for "_init()". Expected at least 1
func _init_me(data: Dictionary) -> AnimaDeclarationForProperty:
	super._init_me(data)

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
	super.anima_from(value)

	return self

func anima_to(value) -> AnimaDeclarationForProperty:
	super.anima_to(value)

	return self

func anima_delay(value: float) -> AnimaDeclarationForProperty:
	super.anima_delay(value)

	return self

func anima_visibility_strategy(value: int) -> AnimaDeclarationForProperty:
	super.anima_visibility_strategy(value)

	return self

func anima_initial_value(value) -> AnimaDeclarationForProperty:
	super.anima_initial_value(value)

	return self

func anima_on_started(target: Object, method: String, on_started_value = null, on_backwards_completed_value = null) -> AnimaDeclarationForProperty:
	super.anima_on_started(target, method, on_started_value, on_backwards_completed_value)

	return self

func anima_on_completed(target: Object, method: String, on_completed_value = null, on_backwards_started_value = null) -> AnimaDeclarationForProperty:
	super.anima_on_completed(target, method, on_completed_value, on_backwards_started_value)

	return self
