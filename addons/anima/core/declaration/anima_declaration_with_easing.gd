class_name AnimaDeclarationWithEasing
extends AnimaDeclarationBase

# We can't use _init otherwise Godot complains with this nonsense
# Too few arguments for "_init()". Expected at least 1
func _init_me(data: Dictionary) -> AnimaDeclarationWithEasing:
	self._init_me(data)

	return self

func anima_easing(easing) -> AnimaDeclarationWithEasing:
	self._data.easing = easing

	return self

func anima_pivot(pivot: int) -> AnimaDeclarationWithEasing:
	self._data.pivot = pivot

	return self
