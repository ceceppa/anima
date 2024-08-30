class_name AnimaDeclarationGrid
extends AnimaDeclarationNode

func _init_me(grid: Node, grid_size: Vector2, items_delay: float, animation_type: int, point: Vector2) -> AnimaDeclarationGrid:
	self._data.grid = grid
	self._data.items_delay = items_delay
	self._data.grid_size = grid_size
	self._data.animation_type = animation_type
	self._data.point = point
	self._data.distance_formula = ANIMA.DISTANCE.EUCLIDIAN

	if Engine.is_editor_hint():
		for node in grid.get_children():
			super._clear_metakeys(node)

	return self

func anima_distance_formula(distance_formula: int) -> AnimaDeclarationGrid:
	self._data.distance_formula = distance_formula

	return self
