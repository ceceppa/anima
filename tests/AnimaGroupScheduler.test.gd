extends "res://addons/gut/test.gd"

func _make_nodes(count: int) -> Array[Node]:
	var nodes: Array[Node] = []
	for i in count:
		nodes.append(autofree(Node.new()))
	return nodes

func _group(playback_mode: AnimaGroupMotion.PlaybackMode = AnimaGroupMotion.PlaybackMode.STAGGERED) -> AnimaGroupMotion:
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	group.playback_mode = playback_mode
	return group

func test_forward_order_keeps_the_resolved_sequence():
	var targets := _make_nodes(3)
	var group := _group()

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries.size(), 3)
	assert_eq(schedule.entries[0].target, targets[0])
	assert_eq(schedule.entries[1].target, targets[1])
	assert_eq(schedule.entries[2].target, targets[2])
	assert_eq(schedule.entries[0].rank, 0)
	assert_eq(schedule.entries[1].rank, 1)
	assert_eq(schedule.entries[2].rank, 2)

func test_reverse_order_starts_from_the_last_target_and_reverses_the_stagger_distribution():
	var targets := _make_nodes(3)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.REVERSE
	group.distribution.mode = AnimaGroupDistribution.Mode.FIXED_INTERVAL
	group.distribution.stagger_interval = 0.1

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries[0].target, targets[2])
	assert_eq(schedule.entries[1].target, targets[1])
	assert_eq(schedule.entries[2].target, targets[0])
	assert_almost_eq(schedule.entries[0].start_offset, 0.0, 0.0001)
	assert_almost_eq(schedule.entries[1].start_offset, 0.1, 0.0001)
	assert_almost_eq(schedule.entries[2].start_offset, 0.2, 0.0001)

func test_centred_order_starts_both_middle_targets_together_for_an_even_collection():
	var targets := _make_nodes(4)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.CENTRED
	group.distribution.mode = AnimaGroupDistribution.Mode.FIXED_INTERVAL
	group.distribution.stagger_interval = 0.1

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries[0].target, targets[1])
	assert_eq(schedule.entries[1].target, targets[2])
	assert_eq(schedule.entries[0].rank, 0)
	assert_eq(schedule.entries[1].rank, 0)
	assert_almost_eq(schedule.entries[0].start_offset, schedule.entries[1].start_offset, 0.0001)

	assert_eq(schedule.entries[2].target, targets[0])
	assert_eq(schedule.entries[3].target, targets[3])
	assert_eq(schedule.entries[2].rank, 1)
	assert_eq(schedule.entries[3].rank, 1)
	assert_gt(schedule.entries[2].start_offset, schedule.entries[0].start_offset)

func test_distance_order_from_an_index_origin_groups_equidistant_targets_into_one_wave():
	var targets := _make_nodes(5)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.DISTANCE
	group.order.origin = AnimaGroupOrder.Origin.INDEX
	group.order.origin_index = 2
	group.distribution.mode = AnimaGroupDistribution.Mode.FIXED_INTERVAL
	group.distribution.stagger_interval = 0.1

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries[0].target, targets[2])
	assert_eq(schedule.entries[1].target, targets[1])
	assert_eq(schedule.entries[2].target, targets[3])
	assert_eq(schedule.entries[3].target, targets[0])
	assert_eq(schedule.entries[4].target, targets[4])
	assert_almost_eq(schedule.entries[1].start_offset, schedule.entries[2].start_offset, 0.0001)
	assert_almost_eq(schedule.entries[3].start_offset, schedule.entries[4].start_offset, 0.0001)

func test_edge_order_starts_both_ends_together_and_meets_in_the_middle_last():
	var targets := _make_nodes(5)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.EDGE
	group.distribution.mode = AnimaGroupDistribution.Mode.FIXED_INTERVAL
	group.distribution.stagger_interval = 0.1

	var schedule := AnimaGroupScheduler.derive(group, targets)

	var first_wave := [schedule.entries[0].target, schedule.entries[1].target]
	assert_has(first_wave, targets[0])
	assert_has(first_wave, targets[4])
	assert_almost_eq(schedule.entries[0].start_offset, 0.0, 0.0001)
	assert_almost_eq(schedule.entries[1].start_offset, 0.0, 0.0001)

	assert_eq(schedule.entries[4].target, targets[2])
	assert_gt(schedule.entries[4].start_offset, schedule.entries[0].start_offset)

func test_distance_order_with_an_omitted_origin_starts_from_first():
	var targets := _make_nodes(4)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.DISTANCE

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(group.order.origin, AnimaGroupOrder.Origin.FIRST)
	for i in targets.size():
		assert_eq(schedule.entries[i].target, targets[i])
		assert_eq(schedule.entries[i].rank, i)

func test_grid_order_ranks_by_distance_from_an_index_origin_cell():
	var targets := _make_nodes(6)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.GRID
	group.order.origin = AnimaGroupOrder.Origin.INDEX
	group.order.origin_index = 0
	group.order.grid_columns = 3

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries[0].target, targets[0])
	assert_eq(schedule.entries[0].rank, 0)

	var second_wave := [schedule.entries[1].target, schedule.entries[2].target, schedule.entries[3].target]
	assert_has(second_wave, targets[1])
	assert_has(second_wave, targets[3])
	assert_has(second_wave, targets[4])

	var third_wave := [schedule.entries[4].target, schedule.entries[5].target]
	assert_has(third_wave, targets[2])
	assert_has(third_wave, targets[5])

func test_parity_filtered_collections_still_order_correctly():
	var source := _make_nodes(4)
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	collection.reference_data = source
	collection.filter = AnimaTargetCollection.Filter.ODD_ONLY

	var resolution := AnimaTargetResolver.resolve(collection, null)
	var group := _group()

	var schedule := AnimaGroupScheduler.derive(group, resolution.targets)

	assert_eq(resolution.targets, [source[1], source[3]])
	assert_eq(schedule.entries[0].target, source[1])
	assert_eq(schedule.entries[1].target, source[3])

func test_random_order_replays_identically_with_the_same_seed():
	var targets := _make_nodes(6)
	var first_group := _group()
	first_group.order.kind = AnimaGroupOrder.Kind.RANDOM
	first_group.order.seed = 42
	var second_group := _group()
	second_group.order.kind = AnimaGroupOrder.Kind.RANDOM
	second_group.order.seed = 42

	var first_schedule := AnimaGroupScheduler.derive(first_group, targets)
	var second_schedule := AnimaGroupScheduler.derive(second_group, targets)

	assert_eq(first_schedule.seed, 42)
	for i in targets.size():
		assert_eq(first_schedule.entries[i].target, second_schedule.entries[i].target)

	var seen_ranks := {}
	for entry in first_schedule.entries:
		seen_ranks[entry.rank] = true
	assert_eq(seen_ranks.size(), targets.size())

func test_parallel_mode_starts_every_target_together_regardless_of_order():
	var targets := _make_nodes(4)
	var group := _group(AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.order.kind = AnimaGroupOrder.Kind.REVERSE

	var schedule := AnimaGroupScheduler.derive(group, targets)

	for entry in schedule.entries:
		assert_almost_eq(entry.start_offset, 0.0, 0.0001)

func test_sequential_mode_produces_a_strict_visit_order_with_no_start_offsets():
	var targets := _make_nodes(4)
	var group := _group(AnimaGroupMotion.PlaybackMode.SEQUENTIAL)
	group.order.kind = AnimaGroupOrder.Kind.CENTRED

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries[0].target, targets[1])
	assert_eq(schedule.entries[1].target, targets[2])
	assert_eq(schedule.entries[2].target, targets[0])
	assert_eq(schedule.entries[3].target, targets[3])
	for entry in schedule.entries:
		assert_almost_eq(entry.start_offset, 0.0, 0.0001)

func test_staggered_total_duration_spreads_ranks_across_the_configured_duration():
	var targets := _make_nodes(3)
	var group := _group()
	group.distribution.mode = AnimaGroupDistribution.Mode.TOTAL_DURATION
	group.distribution.total_stagger_duration = 1.0

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_almost_eq(schedule.entries[0].start_offset, 0.0, 0.0001)
	assert_almost_eq(schedule.entries[1].start_offset, 0.5, 0.0001)
	assert_almost_eq(schedule.entries[2].start_offset, 1.0, 0.0001)

func test_explicit_and_custom_kinds_fall_back_to_forward_order():
	var targets := _make_nodes(3)
	var explicit_group := _group()
	explicit_group.order.kind = AnimaGroupOrder.Kind.EXPLICIT
	var custom_group := _group()
	custom_group.order.kind = AnimaGroupOrder.Kind.CUSTOM

	var explicit_schedule := AnimaGroupScheduler.derive(explicit_group, targets)
	var custom_schedule := AnimaGroupScheduler.derive(custom_group, targets)

	for i in targets.size():
		assert_eq(explicit_schedule.entries[i].target, targets[i])
		assert_eq(custom_schedule.entries[i].target, targets[i])

func test_deriving_an_empty_target_list_returns_an_empty_schedule():
	var group := _group()
	var schedule := AnimaGroupScheduler.derive(group, [])
	assert_eq(schedule.entries.size(), 0)

## --- AnimaGridMotion: distance_formula propagation (story 6) ---

func _grid(formula: AnimaGridMotion.DistanceFormula, dimensions: Vector2i = Vector2i(3, 3), start: Vector2i = Vector2i(1, 1)) -> AnimaGridMotion:
	var grid := AnimaGridMotion.new()
	grid.target_collection = AnimaTargetCollection.new()
	grid.item_motion = Motion.to(NodePath("position:x"), 10.0)
	grid.grid_dimensions = dimensions
	grid.start_point = start
	grid.distance_formula = formula
	return grid

func _wave(schedule: AnimaGroupScheduler.Schedule, targets: Array[Node], rank: int) -> Array:
	var wave := []
	for entry in schedule.entries:
		if entry.rank == rank:
			wave.append(entry.target)
	return wave

func test_a_grid_motion_defaults_to_the_grid_order_kind_that_triggers_formula_ranking():
	assert_eq(AnimaGridMotion.new().order.kind, AnimaGroupOrder.Kind.GRID)

func test_euclidean_formula_ranks_by_straight_line_distance_from_the_start_point():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.EUCLIDEAN)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	assert_eq(schedule.entries[0].target, targets[4], "the start cell (1,1) itself should start first")
	var second_wave := _wave(schedule, targets, 1)
	assert_eq(second_wave.size(), 8, "every immediate neighbour — orthogonal (distance 1.0) and diagonal (distance ~1.41) — floors to the same wave 1")

func test_manhattan_formula_groups_the_orthogonal_cross_ahead_of_the_corners():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.MANHATTAN)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	assert_eq(schedule.entries[0].target, targets[4])
	var cross := _wave(schedule, targets, 1)
	assert_eq(cross.size(), 4)
	assert_has(cross, targets[1])
	assert_has(cross, targets[3])
	assert_has(cross, targets[5])
	assert_has(cross, targets[7])
	var corners := _wave(schedule, targets, 2)
	assert_eq(corners.size(), 4)
	assert_has(corners, targets[0])
	assert_has(corners, targets[2])
	assert_has(corners, targets[6])
	assert_has(corners, targets[8])

func test_chebyshev_formula_treats_every_neighbour_including_corners_as_one_wave():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.CHEBYSHEV)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	assert_eq(schedule.entries[0].target, targets[4])
	var ring := _wave(schedule, targets, 1)
	assert_eq(ring.size(), 8, "every surrounding cell, including corners, is distance 1 under Chebyshev")

func test_row_formula_waves_by_row_distance_from_the_start_row():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.ROW)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var first_wave := _wave(schedule, targets, 0)
	assert_eq(first_wave.size(), 3)
	assert_has(first_wave, targets[3])
	assert_has(first_wave, targets[4])
	assert_has(first_wave, targets[5])

	var second_wave := _wave(schedule, targets, 1)
	assert_eq(second_wave.size(), 6, "both the row above and the row below the start row tie at distance 1")

func test_column_formula_waves_by_column_distance_from_the_start_column():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.COLUMN)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var first_wave := _wave(schedule, targets, 0)
	assert_eq(first_wave.size(), 3)
	assert_has(first_wave, targets[1])
	assert_has(first_wave, targets[4])
	assert_has(first_wave, targets[7])

func test_diagonal_formula_waves_along_the_main_diagonal_from_the_start_point():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.DIAGONAL)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var first_wave := _wave(schedule, targets, 0)
	assert_eq(first_wave.size(), 3)
	assert_has(first_wave, targets[0])
	assert_has(first_wave, targets[4])
	assert_has(first_wave, targets[8])

func test_anti_diagonal_formula_waves_along_the_anti_diagonal_from_the_start_point():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var first_wave := _wave(schedule, targets, 0)
	assert_eq(first_wave.size(), 3)
	assert_has(first_wave, targets[2])
	assert_has(first_wave, targets[4])
	assert_has(first_wave, targets[6])

func test_clockwise_formula_sweeps_from_12_oclock_with_the_start_point_always_first():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.CLOCKWISE)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	assert_eq(order, [
		targets[4], # start point, always first
		targets[1], # 12 o'clock
		targets[2], # 1:30
		targets[5], # 3 o'clock
		targets[8], # 4:30
		targets[7], # 6 o'clock
		targets[6], # 7:30
		targets[3], # 9 o'clock
		targets[0], # 10:30
	])

func test_anticlockwise_formula_sweeps_the_opposite_way_from_12_oclock():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.ANTICLOCKWISE)

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	assert_eq(order, [
		targets[4], # start point, always first
		targets[1], # 12 o'clock
		targets[0], # 10:30
		targets[3], # 9 o'clock
		targets[6], # 7:30
		targets[7], # 6 o'clock
		targets[8], # 4:30
		targets[5], # 3 o'clock
		targets[2], # 1:30
	])

func test_a_different_valid_start_point_changes_the_propagation_and_is_not_restricted_to_the_centre():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.MANHATTAN, Vector2i(3, 3), Vector2i(0, 0))

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	assert_eq(schedule.entries[0].target, targets[0], "start point in the corner should itself start first")
	var second_wave := _wave(schedule, targets, 1)
	assert_eq(second_wave.size(), 2)
	assert_has(second_wave, targets[1])
	assert_has(second_wave, targets[3])

## Spiral is the classic "peel the matrix inward from its own edges" order —
## a property of the grid's own rectangle, not of the chosen start point (see
## AnimaGroupScheduler._ranks_spiral). For a 3x3 grid, row-major index order,
## the clockwise inward path is: top row left-to-right, right column
## top-to-bottom, bottom row right-to-left, left column bottom-to-top, then
## whatever's left in the centre.
func test_spiral_inward_peels_the_grid_clockwise_from_the_top_left_corner():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.SPIRAL_INWARD)
	grid.spiral_direction = AnimaGridMotion.SpiralDirection.CLOCKWISE

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	assert_eq(order, [
		targets[0], targets[1], targets[2], # top row, left to right
		targets[5], targets[8],             # right column, top to bottom
		targets[7], targets[6],             # bottom row, right to left
		targets[3],                         # left column, bottom to top
		targets[4],                         # centre, last
	])
	for i in range(order.size() - 1):
		assert_ne(schedule.entries[i].rank, schedule.entries[i + 1].rank, "a spiral is a strict traversal, never a simultaneous wave")

func test_spiral_outward_reverses_the_inward_traversal():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD)
	grid.spiral_direction = AnimaGridMotion.SpiralDirection.CLOCKWISE

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	assert_eq(order, [
		targets[4],
		targets[3],
		targets[6], targets[7],
		targets[8], targets[5],
		targets[2], targets[1], targets[0],
	])

func test_spiral_counterclockwise_mirrors_the_clockwise_traversal():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.SPIRAL_INWARD)
	grid.spiral_direction = AnimaGridMotion.SpiralDirection.COUNTERCLOCKWISE

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	assert_eq(order, [
		targets[0], targets[3], targets[6], # left column, top to bottom
		targets[7], targets[8],             # bottom row, left to right
		targets[5], targets[2],             # right column, bottom to top
		targets[1],                         # top row, right to left
		targets[4],                         # centre, last
	])

func test_spiral_ignores_the_chosen_start_point_since_it_traces_the_grids_own_rectangle():
	var with_default_start := AnimaGroupScheduler.derive(
		_grid(AnimaGridMotion.DistanceFormula.SPIRAL_INWARD, Vector2i(3, 3), Vector2i(1, 1)), _make_nodes(9)
	)
	var with_corner_start := AnimaGroupScheduler.derive(
		_grid(AnimaGridMotion.DistanceFormula.SPIRAL_INWARD, Vector2i(3, 3), Vector2i(0, 0)), _make_nodes(9)
	)

	for i in with_default_start.entries.size():
		assert_eq(with_default_start.entries[i].rank, with_corner_start.entries[i].rank)

func test_serpentine_row_zigzags_alternating_direction_each_row():
	var targets := _make_nodes(6)
	var grid := _grid(AnimaGridMotion.DistanceFormula.SERPENTINE_ROW, Vector2i(3, 2), Vector2i(0, 0))

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	assert_eq(order, [targets[0], targets[1], targets[2], targets[5], targets[4], targets[3]])

func test_serpentine_column_zigzags_alternating_direction_each_column():
	var targets := _make_nodes(6)
	var grid := _grid(AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN, Vector2i(3, 2), Vector2i(0, 0))

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	var order: Array[Node] = []
	for entry in schedule.entries:
		order.append(entry.target)

	# columns: 0={0,3}, 1={1,4}, 2={2,5}; column 0 top-to-bottom, column 1 bottom-to-top, column 2 top-to-bottom
	assert_eq(order, [targets[0], targets[3], targets[4], targets[1], targets[2], targets[5]])

func test_top_bottom_center_orders_still_work_when_order_kind_is_explicitly_overridden():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.EUCLIDEAN)
	grid.order.kind = AnimaGroupOrder.Kind.REVERSE

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	assert_eq(schedule.entries[0].target, targets[8], "explicitly overriding order.kind should fall back to the standard flat-list ordering, ignoring distance_formula")

func test_together_playback_mode_still_starts_every_grid_target_at_once():
	var targets := _make_nodes(9)
	var grid := _grid(AnimaGridMotion.DistanceFormula.EUCLIDEAN)
	grid.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var schedule := AnimaGroupScheduler.derive(grid, targets)

	for entry in schedule.entries:
		assert_almost_eq(entry.start_offset, 0.0, 0.0001)

func test_odd_even_filters_still_apply_before_grid_formula_ranking():
	var source := _make_nodes(9)
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	collection.reference_data = source
	collection.filter = AnimaTargetCollection.Filter.EVEN_ONLY

	var resolution := AnimaTargetResolver.resolve(collection, null)
	var grid := _grid(AnimaGridMotion.DistanceFormula.EUCLIDEAN, Vector2i(2, 3), Vector2i(0, 0))

	var schedule := AnimaGroupScheduler.derive(grid, resolution.targets)

	assert_eq(resolution.targets, [source[0], source[2], source[4], source[6], source[8]])
	assert_eq(schedule.entries[0].target, source[0])

func test_a_plain_group_motion_authored_with_the_grid_order_kind_keeps_the_original_virtual_grid_behaviour():
	var targets := _make_nodes(6)
	var group := _group()
	group.order.kind = AnimaGroupOrder.Kind.GRID
	group.order.origin = AnimaGroupOrder.Origin.INDEX
	group.order.origin_index = 0
	group.order.grid_columns = 3

	var schedule := AnimaGroupScheduler.derive(group, targets)

	assert_eq(schedule.entries[0].target, targets[0])
	assert_eq(schedule.entries[0].rank, 0)

## Regression: CLOCKWISE/ANTICLOCKWISE encode a bearing, and the spiral
## formulas encode a distance and a bearing, into one raw rank key — several
## orders of magnitude larger than an actual wave count. Undensified, a
## staggered group's `rank * stagger_interval` turned that raw magnitude
## directly into a start_offset of thousands of seconds, which is why these
## four formulas looked like they never animated at all.
func test_angular_and_spiral_formula_ranks_stay_dense_enough_for_a_sane_stagger_offset():
	var targets := _make_nodes(25)
	for formula in [
		AnimaGridMotion.DistanceFormula.CLOCKWISE,
		AnimaGridMotion.DistanceFormula.ANTICLOCKWISE,
		AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD,
		AnimaGridMotion.DistanceFormula.SPIRAL_INWARD,
	]:
		var grid := AnimaGridMotion.new()
		grid.target_collection = AnimaTargetCollection.new()
		grid.item_motion = Motion.to(NodePath("position:x"), 10.0)
		grid.grid_dimensions = Vector2i(5, 5)
		grid.start_point = Vector2i(2, 2)
		grid.distance_formula = formula
		grid.distribution.stagger_interval = 0.1

		var schedule := AnimaGroupScheduler.derive(grid, targets)

		var max_offset := 0.0
		for entry in schedule.entries:
			max_offset = maxf(max_offset, entry.start_offset)
		assert_lt(max_offset, 5.0, "formula %s should schedule its last wave within a few seconds, not thousands" % formula)
