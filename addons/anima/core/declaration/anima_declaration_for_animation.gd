class_name AnimaDeclarationForAnimation
extends AnimaDeclarationBase

# We can't use _init otherwise Godot complains with this nonsense
# Too few arguments for "_init()". Expected at least 1
func _init_me(data: Dictionary) -> AnimaDeclarationForAnimation:
	._init_me(data)

	return self

func anima_delay(value: float) -> AnimaDeclarationForAnimation:
	.anima_delay(value)

	return self

func anima_visibility_strategy(value: int) -> AnimaDeclarationForAnimation:
	.anima_visibility_strategy(value)

	return self

func anima_on_started(target: Object, method: String, on_started_value = null, on_backwards_completed_value = null) -> AnimaDeclarationForAnimation:
	.anima_on_started(target, method, on_started_value, on_backwards_completed_value)

	return self

func anima_on_completed(target: Object, method: String, on_completed_value = null, on_backwards_started_value = null) -> AnimaDeclarationForAnimation:
	.anima_on_completed(target, method, on_completed_value, on_backwards_started_value)

	return self
