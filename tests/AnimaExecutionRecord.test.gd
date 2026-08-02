extends "res://addons/gut/test.gd"

func _make_targets(count: int) -> Array[Node]:
	var targets: Array[Node] = []
	for i in count:
		var node := Node.new()
		autofree(node)
		targets.append(node)
	return targets

func test_from_schedule_copies_every_entry_in_start_order():
	var targets := _make_targets(3)
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	group.order.kind = AnimaGroupOrder.Kind.REVERSE
	group.order.seed = 7

	var schedule := AnimaGroupScheduler.derive(group, targets)
	var record := AnimaExecutionRecord.from_schedule(schedule)

	assert_eq(record.seed, 7)
	assert_eq(record.entries.size(), 3)
	assert_eq(record.entries[0].target, targets[2])
	assert_eq(record.entries[1].target, targets[1])
	assert_eq(record.entries[2].target, targets[0])

func test_reversed_mirrors_ranks_so_the_last_target_starts_first():
	var targets := _make_targets(3)
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	group.distribution.stagger_interval = 0.1

	var schedule := AnimaGroupScheduler.derive(group, targets)
	var record := AnimaExecutionRecord.from_schedule(schedule)
	var reversed_record := record.reversed()

	assert_eq(reversed_record.entries[0].target, targets[2])
	assert_eq(reversed_record.entries[1].target, targets[1])
	assert_eq(reversed_record.entries[2].target, targets[0])
	assert_almost_eq(reversed_record.entries[0].start_offset, 0.0, 0.0001)
	assert_almost_eq(reversed_record.entries[2].start_offset, 0.2, 0.0001)

func test_reversed_keeps_a_tied_wave_starting_together():
	var targets := _make_targets(4)
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	group.order.kind = AnimaGroupOrder.Kind.CENTRED
	group.distribution.stagger_interval = 0.1

	var schedule := AnimaGroupScheduler.derive(group, targets)
	var record := AnimaExecutionRecord.from_schedule(schedule)
	var reversed_record := record.reversed()

	assert_eq(reversed_record.entries[0].rank, reversed_record.entries[1].rank)
	assert_almost_eq(reversed_record.entries[0].start_offset, reversed_record.entries[1].start_offset, 0.0001)

func test_reversed_does_not_reshuffle_a_random_order():
	var targets := _make_targets(6)
	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	group.order.kind = AnimaGroupOrder.Kind.RANDOM
	group.order.seed = 99

	var schedule := AnimaGroupScheduler.derive(group, targets)
	var record := AnimaExecutionRecord.from_schedule(schedule)
	var reversed_record := record.reversed()

	var forward_targets: Array[Node] = []
	for entry in record.entries:
		forward_targets.append(entry.target)
	var reversed_targets: Array[Node] = []
	for entry in reversed_record.entries:
		reversed_targets.append(entry.target)

	reversed_targets.reverse()
	assert_eq(forward_targets, reversed_targets)
	assert_eq(reversed_record.seed, 99)
