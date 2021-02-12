extends Spatial

func _ready():
	var grid_size := Vector2(10, 6)
	_checkboard(grid_size)

	var group1 = Anima.grid($Grid, grid_size)
	group1.set_items_delay(0)
	group1.then({ animation_type = Anima.GRID.COLUMNS_ODD, property = "x", to = 5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	group1.with({ animation_type = Anima.GRID.COLUMNS_EVEN, property = "x", to = -5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })

	group1.wait(0.3)

	group1.then({ animation_type = Anima.GRID.COLUMNS_ODD, property = "x", to = 5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	group1.with({ animation_type = Anima.GRID.COLUMNS_EVEN, property = "x", to = -5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	group1.wait(0.3)

	group1.end()

	var cube = Anima.grid($Cubes, grid_size)
	cube.set_animation_type(Anima.GRID.TOGETHER)
	cube.then({ animation_type = Anima.GRID.COLUMNS_ODD, property = "x", to = 5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	cube.with({ animation_type = Anima.GRID.COLUMNS_EVEN, property = "x", to = -5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	cube.with({ animation_type = Anima.GRID.EVEN, property = "scale", to = Vector3(1, 0.2, 1), duration = 0.6, easing = Anima.EASING.EASE_OUT_BOUNCE })
	cube.with({ animation_type = Anima.GRID.ODD, property = "rotation:y", to = 90, relative = true, duration = 0.3 })

	cube.wait(0.3)

	cube.then({ animation_type = Anima.GRID.COLUMNS_ODD, property = "x", to = 5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	cube.with({ animation_type = Anima.GRID.COLUMNS_EVEN, property = "x", to = -5, relative = true, duration = 0.3, easing = Anima.EASING.EASE_OUT_SINE })
	cube.with({ animation_type = Anima.GRID.EVEN, property = "scale", to = Vector3(1, 1, 1), duration = 0.6, easing = Anima.EASING.EASE_OUT_BOUNCE })
	cube.with({ animation_type = Anima.GRID.ODD, property = "rotation:y", to = 90, relative = true, duration = 0.3 })

	cube.wait(0.3)

	cube.end()

	cube.loop()
	group1.loop()

func _checkboard(grid_size: Vector2) -> void:
	var dark = $Main/Dark
	var light = $Main/Light
	var cube_light = $Main/Cube2
	var cube_dark = $Main/Cube
	
	var position1 := Vector3(25, 0, -18)

	var odd = true

	for i in grid_size.x:
		var first
		var second

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
