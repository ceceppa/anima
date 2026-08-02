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
