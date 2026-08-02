extends "res://addons/gut/test.gd"

func _valid_grid() -> AnimaGridMotion:
	var grid := AnimaGridMotion.new()
	grid.target_collection = AnimaTargetCollection.new()
	grid.item_motion = AnimaPropertyMotion.new()
	grid.item_motion.target_property = NodePath("modulate:a")
	grid.item_motion.to_value = 1.0
	grid.grid_dimensions = Vector2i(5, 5)
	grid.start_point = Vector2i(2, 2)
	return grid

func test_defaults_to_a_top_starting_row_formula_at_the_origin_cell():
	var grid := AnimaGridMotion.new()

	assert_eq(grid.grid_dimensions, Vector2i(1, 1))
	assert_eq(grid.start_point, Vector2i.ZERO)
	assert_eq(grid.distance_formula, AnimaGridMotion.DistanceFormula.ROW)
	assert_eq(grid.spiral_direction, AnimaGridMotion.SpiralDirection.CLOCKWISE)

func test_validate_passes_for_a_fully_configured_grid():
	assert_eq(_valid_grid().validate(), [])

func test_validate_rejects_non_positive_dimensions():
	var grid := _valid_grid()
	grid.grid_dimensions = Vector2i(0, 5)

	assert_eq(grid.validate(), ["grid_dimensions must have a positive width and height"])

func test_validate_rejects_a_start_point_outside_the_grid():
	var grid := _valid_grid()
	grid.start_point = Vector2i(5, 0)

	assert_eq(grid.validate(), ["start_point must be inside grid_dimensions"])

func test_validate_accepts_a_start_point_on_the_last_valid_tile():
	var grid := _valid_grid()
	grid.start_point = Vector2i(4, 4)

	assert_eq(grid.validate(), [])

func test_validate_still_inherits_the_group_motion_checks():
	var grid := AnimaGridMotion.new()
	grid.grid_dimensions = Vector2i(3, 3)

	var errors := grid.validate()

	assert_true(errors.has("target_collection is required"))
	assert_true(errors.has("item_motion is required"))

func test_a_partially_filled_final_row_does_not_change_the_declared_dimensions():
	var grid := _valid_grid()
	grid.grid_dimensions = Vector2i(5, 5)

	assert_eq(grid.validate(), [], "23 resolved targets in a 5x5 grid (ragged final row) should still validate")
	assert_eq(grid.grid_dimensions, Vector2i(5, 5))
