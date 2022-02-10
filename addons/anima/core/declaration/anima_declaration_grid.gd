class_name AnimaDeclarationGrid
extends AnimaDeclarationNode

func _init_me(grid: Node, grid_size: Vector2, items_delay: float, animation_type: int, point: int) -> AnimaDeclarationGrid:
	self._data.grid = grid
	self._data.items_delay = items_delay
	self._data.grid_size = grid_size
	self._data.animation_type = animation_type
	self._data.point = Vector2(point, 0)

	return self
