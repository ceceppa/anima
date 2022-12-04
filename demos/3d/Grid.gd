extends Node3D

func _ready():
	var grid_size := Vector2(10, 6)
	_checkboard(grid_size)

	var group1 = Anima.begin($Grid)
	group1.then({ 
		grid = $Grid,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.COLUMNS_ODD,
		property = "x",
		to = 5, 
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE,
		items_delay = 0
	})
	group1.with({ 
		grid = $Grid,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.COLUMNS_EVEN,
		property = "x",
		to = -5, 
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE,
		items_delay = 0
	})

	group1.wait(0.3)

	group1.then({
		grid = $Grid,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.COLUMNS_ODD,
		property = "x",
		to = 5,
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE,
		items_delay = 0,
		_debug = true
	})
	group1.with({
		grid = $Grid,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.COLUMNS_EVEN,
		property = "x",
		to = -5,
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE,
		items_delay = 0,
	})

	group1.wait(0.3)

	var cube = Anima.begin($Cubes)
	cube.then({
		grid = $Cubes,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.COLUMNS_ODD,
		property = "x",
		to = 5,
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE,
		items_delay = 0
	})
	cube.with({
		grid = $Cubes,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.COLUMNS_EVEN,
		property = "x",
		to = -5,
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE,
		items_delay = 0
	})
	cube.with({
		grid = $Cubes,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.EVEN_ITEMS,
		property = "scale",
		to = Vector3(1, 0.2, 1),
		duration = 0.6,
		easing = ANIMA.EASING.EASE_OUT_BOUNCE,
		items_delay = 0
	})
	cube.with({
		grid = $Cubes,
		grid_size = grid_size,
		animation_type = ANIMA.GRID.ODD_ITEMS,
		property = "rotation:y",
		to = 90,
		relative = true,
		duration = 0.3,
		items_delay = 0
	})

	cube.wait(0.3)

	cube.then({ 
		grid = $Cubes,
		grid_size = grid_size,
		items_delay = 0,
		animation_type = ANIMA.GRID.COLUMNS_ODD,
		property = "x",
		to = 5,
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE
	})
	cube.with({
		grid = $Cubes,
		grid_size = grid_size,
		items_delay = 0,
		animation_type = ANIMA.GRID.COLUMNS_EVEN,
		property = "x",
		to = -5,
		relative = true,
		duration = 0.3,
		easing = ANIMA.EASING.EASE_OUT_SINE
	})
	cube.with({
		grid = $Cubes,
		grid_size = grid_size,
		items_delay = 0,
		animation_type = ANIMA.GRID.EVEN_ITEMS,
		property = "scale",
		to = Vector3(1, 1, 1),
		duration = 0.6,
		easing = ANIMA.EASING.EASE_OUT_BOUNCE
	})
	cube.with({
		grid = $Cubes,
		grid_size = grid_size,
		items_delay = 0,
		animation_type = ANIMA.GRID.ODD_ITEMS,
		property = "rotation:y",
		to = 90,
		relative = true,
		duration = 0.3
	})

	cube.wait(0.3)

	cube.loop()
	group1.loop()

func _checkboard(grid_size: Vector2) -> void:
	var dark = $Main/Dark
	var light = $Main/Light3D
	var cube_light = $Main/Cube2
	var cube_dark = $Main/Cube
	
	var position1 := Vector3(25, 0, -18)

	var odd = true

	for i in grid_size.x:
		odd = i % 2 != 0

		for j in grid_size.y:
			var clone
			var cube

			if odd:
				clone = dark.duplicate()
				cube = cube_dark.duplicate()
			else:
				clone = light.duplicate()
				cube = cube_light.duplicate()

			clone.show()
			cube.show()

			$Grid.add_child(clone)
			$Cubes.add_child(cube)

			clone.global_transform.origin = position1 + Vector3(-5 * i, 0, 5 * j)
			cube.global_transform.origin = position1 + Vector3(-5 * i, 1, 5 * j)

			odd = !odd

	dark.hide()
	light.hide()
	cube_dark.hide()
	cube_light.hide()
