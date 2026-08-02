extends "res://addons/gut/test.gd"

func _make_grid(root: Node, dimensions: Vector2i, start: Vector2i) -> AnimaGridMotion:
	for i in dimensions.x * dimensions.y:
		root.add_child(Node2D.new())

	var grid := AnimaGridMotion.new()
	grid.target_collection = AnimaTargetCollection.new()
	grid.target_collection.kind = AnimaTargetCollection.Kind.CHILDREN
	grid.grid_dimensions = dimensions
	grid.start_point = start
	grid.item_motion = AnimaPropertyMotion.new()
	grid.item_motion.target_property = NodePath("modulate:a")
	grid.item_motion.from_value = 1.0
	grid.item_motion.to_value = 0.0
	grid.item_motion.duration = 0.1
	grid.playback_mode = AnimaGroupMotion.PlaybackMode.STAGGERED
	grid.distribution.stagger_interval = 0.02
	return grid

func test_a_valid_grid_motion_plays_its_item_motion_across_every_resolved_tile():
	var root := Node.new()
	add_child_autofree(root)
	var grid := _make_grid(root, Vector2i(3, 3), Vector2i(1, 1))

	var playback := Anima.play(grid, root)
	for i in range(30):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for child in root.get_children():
		assert_almost_eq(child.modulate.a, 0.0, 0.01)

func test_the_centre_tile_starts_before_its_neighbours_under_the_default_row_formula():
	var root := Node.new()
	add_child_autofree(root)
	var grid := _make_grid(root, Vector2i(3, 3), Vector2i(1, 1))
	# Default distance_formula is ROW: the start row (row 1 — index 3,4,5)
	# is the first wave.
	var playback := Anima.play(grid, root)
	playback._advance(0.01)

	var start_row_child := root.get_child(4) as Node2D
	var corner_child := root.get_child(0) as Node2D
	assert_lt(start_row_child.modulate.a, 1.0, "the start row should already be animating")
	assert_almost_eq(corner_child.modulate.a, 1.0, 0.0001, "a later wave should not have started yet")
	playback.cancel()

func test_reversing_a_completed_grid_run_replays_the_recorded_execution_in_reverse_order():
	var root := Node.new()
	add_child_autofree(root)
	var grid := _make_grid(root, Vector2i(3, 3), Vector2i(0, 0))
	grid.distance_formula = AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD # a strict traversal with no rank ties, so a full-list reverse is well-defined
	grid.playback_mode = AnimaGroupMotion.PlaybackMode.SEQUENTIAL
	grid.reverse_order_policy = AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION

	var playback := Anima.play(grid, root)
	for i in range(60):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	var forward_order: Array[Node] = []
	for entry in playback._instance.execution_record.entries:
		forward_order.append(entry.target)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	var reversed_order: Array[Node] = []
	for entry in playback._instance.execution_record.entries:
		reversed_order.append(entry.target)
	reversed_order.reverse()
	assert_eq(forward_order, reversed_order)

	for i in range(60):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_a_static_deterministic_grid_motion_is_eligible_and_compiles_to_a_native_animation():
	var root := Node.new()
	add_child_autofree(root)
	var grid := _make_grid(root, Vector2i(3, 3), Vector2i(1, 1))

	var eligibility := AnimaGroupCompiler.check_eligibility(grid, root)
	assert_true(eligibility.is_eligible())
	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.NONE)

	var animation := AnimaGroupCompiler.compile(grid, root)
	assert_eq(animation.get_track_count(), 9)

func test_an_explicitly_random_ordered_grid_motion_is_ineligible_with_a_plain_language_reason():
	var root := Node.new()
	add_child_autofree(root)
	var grid := _make_grid(root, Vector2i(2, 2), Vector2i(0, 0))
	grid.order.kind = AnimaGroupOrder.Kind.RANDOM

	var eligibility := AnimaGroupCompiler.check_eligibility(grid, root)

	assert_false(eligibility.is_eligible())
	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.NON_DETERMINISTIC_ORDER)
	assert_true(eligibility.message.length() > 0)

func test_validation_playback_and_compilation_agree_on_the_same_derived_tile_schedule():
	var root := Node.new()
	add_child_autofree(root)
	var grid := _make_grid(root, Vector2i(3, 3), Vector2i(2, 0))
	grid.distance_formula = AnimaGridMotion.DistanceFormula.MANHATTAN

	assert_eq(grid.validate(), [])

	var resolution := AnimaTargetResolver.resolve(
		grid.target_collection, root, [], grid.invalid_target_policy, grid.empty_group_policy,
	)
	var schedule := AnimaGroupScheduler.derive(grid, resolution.targets)

	var playback := Anima.play(grid, root)
	for i in range(60):
		playback._advance(1.0 / 60.0)
	var played_record: AnimaExecutionRecord = playback._instance.execution_record

	for i in schedule.entries.size():
		assert_eq(schedule.entries[i].target, played_record.entries[i].target, "the same schedule should drive both a fresh derivation and the actual played run")
		assert_almost_eq(schedule.entries[i].start_offset, played_record.entries[i].start_offset, 0.0001)

	var animation := AnimaGroupCompiler.compile(grid, root)
	assert_eq(animation.get_track_count(), schedule.entries.size(), "compilation should bake one track per the same resolved schedule")
