extends "res://addons/gut/test.gd"

func _make_targets(count: int) -> Array[Node]:
	var targets: Array[Node] = []
	for i in count:
		var node := Node2D.new()
		autofree(node)
		targets.append(node)
	return targets

func _make_property_motion(duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = duration
	return motion

func _make_group(targets: Array[Node], playback_mode: AnimaGroupMotion.PlaybackMode = AnimaGroupMotion.PlaybackMode.STAGGERED) -> AnimaGroupMotion:
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	collection.reference_data = targets

	var group := AnimaGroupMotion.new()
	group.target_collection = collection
	group.item_motion = _make_property_motion(0.3)
	group.playback_mode = playback_mode
	return group

func test_staggered_group_starts_targets_according_to_their_schedule():
	var targets := _make_targets(3)
	var group := _make_group(targets)
	group.distribution.stagger_interval = 0.1

	var playback := AnimaPlayback.new(group, null)

	playback._advance(0.05)
	assert_gt(targets[0].position.x, 0.0)
	assert_eq(targets[1].position.x, 0.0)
	assert_eq(targets[2].position.x, 0.0)

	playback._advance(0.05)
	assert_gt(targets[1].position.x, 0.0)
	assert_eq(targets[2].position.x, 0.0)

	playback._advance(0.1)
	assert_gt(targets[2].position.x, 0.0)

func test_staggered_group_runs_every_target_to_completion():
	var targets := _make_targets(3)
	var group := _make_group(targets)
	group.item_motion = _make_property_motion(0.2)
	group.distribution.stagger_interval = 0.05

	var playback := AnimaPlayback.new(group, null)
	for i in range(20):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for target in targets:
		assert_almost_eq(target.position.x, 10.0, 0.01)

func test_parallel_group_starts_every_target_together():
	var targets := _make_targets(3)
	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.order.kind = AnimaGroupOrder.Kind.REVERSE

	var playback := AnimaPlayback.new(group, null)
	playback._advance(0.05)

	for target in targets:
		assert_gt(target.position.x, 0.0)

func test_parallel_group_all_items_completion_waits_for_the_slowest_item():
	var targets := _make_targets(2)
	var call_count := [0]
	var conditional := AnimaConditional.new()
	conditional.condition = func():
		var is_fast: bool = call_count[0] == 0
		call_count[0] += 1
		return is_fast
	conditional.when_true = _make_property_motion(0.1)
	conditional.when_false = _make_property_motion(1.0)

	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.item_motion = conditional
	group.completion_policy = AnimaGroupMotion.CompletionPolicy.ALL_ITEMS

	var playback := AnimaPlayback.new(group, null)
	for i in range(8):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

func test_parallel_group_first_item_completion_finishes_as_soon_as_the_fastest_item_finishes():
	var targets := _make_targets(2)
	var call_count := [0]
	var conditional := AnimaConditional.new()
	conditional.condition = func():
		var is_fast: bool = call_count[0] == 0
		call_count[0] += 1
		return is_fast
	conditional.when_true = _make_property_motion(0.1)
	conditional.when_false = _make_property_motion(1.0)

	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.item_motion = conditional
	group.completion_policy = AnimaGroupMotion.CompletionPolicy.FIRST_ITEM

	var playback := AnimaPlayback.new(group, null)
	for i in range(8):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_sequential_group_starts_the_next_item_only_after_the_previous_one_finishes():
	var targets := _make_targets(2)
	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.SEQUENTIAL)
	group.item_motion = _make_property_motion(0.2)

	var playback := AnimaPlayback.new(group, null)
	playback._advance(0.1)

	assert_gt(targets[0].position.x, 0.0)
	assert_eq(targets[1].position.x, 0.0)

	playback._advance(0.15)
	assert_almost_eq(targets[0].position.x, 10.0, 0.01)
	assert_eq(targets[1].position.x, 0.0)

	playback._advance(0.3)
	assert_almost_eq(targets[1].position.x, 10.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_sequential_group_waits_the_configured_gap_between_items():
	var targets := _make_targets(2)
	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.SEQUENTIAL)
	group.item_motion = _make_property_motion(0.05)
	group.sequential_gap = 0.2

	var playback := AnimaPlayback.new(group, null)
	playback._advance(0.08)
	assert_almost_eq(targets[0].position.x, 10.0, 0.01)
	assert_eq(targets[1].position.x, 0.0)

	playback._advance(0.1)
	assert_eq(targets[1].position.x, 0.0, "the gap has not elapsed yet")

	playback._advance(0.2)
	assert_gt(targets[1].position.x, 0.0)

func test_invalid_target_skip_policy_lets_the_remaining_items_continue():
	var targets := _make_targets(2)
	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.invalid_target_policy = AnimaGroupMotion.InvalidTargetPolicy.SKIP

	var playback := AnimaPlayback.new(group, null)
	playback._advance(0.05)
	targets[0].free()

	playback._advance(0.05)
	assert_gt(targets[1].position.x, 0.0)
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

func test_invalid_target_cancel_group_policy_stops_the_whole_group():
	var targets := _make_targets(2)
	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.invalid_target_policy = AnimaGroupMotion.InvalidTargetPolicy.CANCEL_GROUP

	var playback := AnimaPlayback.new(group, null)
	playback._advance(0.05)
	targets[0].free()

	playback._advance(0.05)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_empty_group_with_complete_policy_finishes_immediately_as_a_no_op():
	var group := _make_group([])
	group.empty_group_policy = AnimaGroupMotion.EmptyGroupPolicy.COMPLETE

	var playback := AnimaPlayback.new(group, null)
	playback._advance(0.016)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_each_item_resolves_a_dynamic_value_against_its_own_target():
	var targets := _make_targets(3)
	targets[0].scale = Vector2(1.0, 0.0)
	targets[1].scale = Vector2(2.0, 0.0)
	targets[2].scale = Vector2(3.0, 0.0)

	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.item_motion.to_value = AnimaValue.target(NodePath("scale:x"))

	var playback := AnimaPlayback.new(group, null)
	playback._advance(group.item_motion.duration)

	assert_almost_eq(targets[0].position.x, 1.0, 0.01)
	assert_almost_eq(targets[1].position.x, 2.0, 0.01)
	assert_almost_eq(targets[2].position.x, 3.0, 0.01)

func test_each_item_resolves_its_own_group_index_and_count():
	var targets := _make_targets(3)
	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.item_motion.to_value = AnimaValue.group_index().multiply(100.0).add(AnimaValue.group_count())

	var playback := AnimaPlayback.new(group, null)
	playback._advance(group.item_motion.duration)

	assert_almost_eq(targets[0].position.x, 3.0, 0.01)
	assert_almost_eq(targets[1].position.x, 103.0, 0.01)
	assert_almost_eq(targets[2].position.x, 203.0, 0.01)

func test_root_resolves_the_groups_own_container_not_an_individual_item():
	var container: Node2D = Node2D.new()
	autofree(container)
	container.scale = Vector2(99.0, 0.0)
	var targets := _make_targets(2)
	targets[0].scale = Vector2(1.0, 0.0)
	targets[1].scale = Vector2(2.0, 0.0)

	var group := _make_group(targets, AnimaGroupMotion.PlaybackMode.PARALLEL)
	group.item_motion.to_value = AnimaValue.root(NodePath("scale:x"))

	var playback := AnimaPlayback.new(group, container)
	playback._advance(group.item_motion.duration)

	assert_almost_eq(targets[0].position.x, 99.0, 0.01)
	assert_almost_eq(targets[1].position.x, 99.0, 0.01)

func test_grid_item_resolves_its_own_row_and_column():
	var targets := _make_targets(4)

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	collection.reference_data = targets

	var grid := AnimaGridMotion.new()
	grid.target_collection = collection
	grid.grid_dimensions = Vector2i(2, 2)
	grid.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	grid.item_motion = _make_property_motion(0.1)
	grid.item_motion.to_value = AnimaValue.grid_row().multiply(10.0).add(AnimaValue.grid_column())

	var playback := AnimaPlayback.new(grid, null)
	playback._advance(0.1)

	assert_almost_eq(targets[0].position.x, 0.0, 0.01)
	assert_almost_eq(targets[1].position.x, 1.0, 0.01)
	assert_almost_eq(targets[2].position.x, 10.0, 0.01)
	assert_almost_eq(targets[3].position.x, 11.0, 0.01)
