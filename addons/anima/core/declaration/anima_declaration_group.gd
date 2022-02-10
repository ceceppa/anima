class_name AnimaDeclarationGroup
extends AnimaDeclarationNode

func _init_me(group: Node, items_delay: float, animation_type: int, point: int) -> AnimaDeclarationGroup:

	self._data.group = group
	self._data.items_delay = items_delay
	self._data.animation_type = animation_type
	self._data.point = Vector2(point, 0)

	return self
