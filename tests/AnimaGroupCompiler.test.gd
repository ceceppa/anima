extends "res://addons/gut/test.gd"

func _make_group(root: Node, count: int) -> AnimaGroupMotion:
	for i in count:
		root.add_child(Node2D.new())

	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.target_collection.kind = AnimaTargetCollection.Kind.CHILDREN
	group.item_motion = AnimaPropertyMotion.new()
	group.item_motion.target_property = NodePath("position:x")
	group.item_motion.from_value = 0.0
	group.item_motion.to_value = 10.0
	group.item_motion.duration = 0.2
	return group

func test_eligible_group_reports_no_blocker():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 3)

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_true(eligibility.is_eligible())
	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.NONE)

func test_eligible_group_compiles_one_track_per_resolved_target():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 3)

	var animation := AnimaGroupCompiler.compile(group, root)

	assert_eq(animation.get_track_count(), 3)

func test_parallel_group_bakes_every_track_starting_at_zero():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 3)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var animation := AnimaGroupCompiler.compile(group, root)

	for track_index in animation.get_track_count():
		assert_almost_eq(animation.track_get_key_time(track_index, 0), 0.0, 0.0001)

func test_staggered_group_bakes_each_targets_wave_offset_into_its_first_key():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 3)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.STAGGERED
	group.distribution.stagger_interval = 0.1

	var animation := AnimaGroupCompiler.compile(group, root)

	assert_almost_eq(animation.track_get_key_time(0, 0), 0.0, 0.0001)
	assert_almost_eq(animation.track_get_key_time(1, 0), 0.1, 0.0001)
	assert_almost_eq(animation.track_get_key_time(2, 0), 0.2, 0.0001)

func test_sequential_group_bakes_starts_back_to_back_from_the_actual_item_duration():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 3)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.SEQUENTIAL
	group.sequential_gap = 0.1

	var animation := AnimaGroupCompiler.compile(group, root)

	assert_almost_eq(animation.track_get_key_time(0, 0), 0.0, 0.0001)
	assert_almost_eq(animation.track_get_key_time(1, 0), 0.3, 0.0001)
	assert_almost_eq(animation.track_get_key_time(2, 0), 0.6, 0.0001)

func test_compiled_track_keyframes_span_from_the_starting_value_to_the_target_value():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)

	var animation := AnimaGroupCompiler.compile(group, root)
	var key_count := animation.track_get_key_count(0)

	assert_almost_eq(animation.track_get_key_value(0, 0), 0.0, 0.0001)
	assert_almost_eq(animation.track_get_key_value(0, key_count - 1), 10.0, 0.0001)

func test_runtime_callable_collection_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.target_collection.kind = AnimaTargetCollection.Kind.RUNTIME_CALLABLE

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.RUNTIME_ONLY_TARGETS)
	assert_false(eligibility.message.is_empty())

func test_scene_group_collection_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.target_collection.kind = AnimaTargetCollection.Kind.SCENE_GROUP
	group.target_collection.reference_data = ["some_group"]

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.LIVE_MEMBERSHIP)
	assert_false(eligibility.message.is_empty())

func test_random_order_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.order.kind = AnimaGroupOrder.Kind.RANDOM

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.NON_DETERMINISTIC_ORDER)
	assert_false(eligibility.message.is_empty())

func test_unresolved_explicit_reference_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 0)
	group.target_collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	group.target_collection.reference_data = [NodePath("DoesNotExist")]

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.UNRESOLVED_REFERENCE)
	assert_false(eligibility.message.is_empty())

func test_composite_item_motion_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.item_motion = Motion.sequence([Motion.to(NodePath("position:x"), 10.0)])

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.ITEM_MOTION_NOT_A_PROPERTY_MOTION)
	assert_false(eligibility.message.is_empty())

func test_callable_eased_item_motion_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.item_motion.ease = AnimaEase.new()
	group.item_motion.ease.kind = AnimaEase.Kind.CALLABLE
	group.item_motion.ease.evaluator = func(t: float) -> float: return t

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.CALLBACK_DEPENDENT)
	assert_false(eligibility.message.is_empty())

func test_spring_eased_item_motion_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.item_motion.ease = AnimaEase.new()
	group.item_motion.ease.kind = AnimaEase.Kind.SPRING

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.ITEM_MOTION_NOT_FIXED_DURATION)
	assert_false(eligibility.message.is_empty())

func test_every_blocker_reports_a_distinct_message():
	var root := Node.new()
	add_child_autofree(root)

	var messages := {}
	var scenarios: Array[AnimaGroupMotion] = []

	var runtime_group := _make_group(root, 1)
	runtime_group.target_collection.kind = AnimaTargetCollection.Kind.RUNTIME_CALLABLE
	scenarios.append(runtime_group)

	var scene_group := _make_group(root, 1)
	scene_group.target_collection.kind = AnimaTargetCollection.Kind.SCENE_GROUP
	scene_group.target_collection.reference_data = ["some_group"]
	scenarios.append(scene_group)

	var random_group := _make_group(root, 1)
	random_group.order.kind = AnimaGroupOrder.Kind.RANDOM
	scenarios.append(random_group)

	var unresolved_group := _make_group(root, 0)
	unresolved_group.target_collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	unresolved_group.target_collection.reference_data = [NodePath("DoesNotExist")]
	scenarios.append(unresolved_group)

	var composite_group := _make_group(root, 1)
	composite_group.item_motion = Motion.sequence([Motion.to(NodePath("position:x"), 10.0)])
	scenarios.append(composite_group)

	for scenario in scenarios:
		var eligibility := AnimaGroupCompiler.check_eligibility(scenario, root)
		assert_false(eligibility.is_eligible())
		messages[eligibility.message] = true

	assert_eq(messages.size(), scenarios.size())

func test_revalidating_after_a_change_updates_eligibility():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.order.kind = AnimaGroupOrder.Kind.RANDOM

	var blocked := AnimaGroupCompiler.check_eligibility(group, root)
	assert_false(blocked.is_eligible())

	group.order.kind = AnimaGroupOrder.Kind.FORWARD
	var eligible := AnimaGroupCompiler.check_eligibility(group, root)
	assert_true(eligible.is_eligible())

func test_item_motion_with_a_dynamic_to_value_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.item_motion.to_value = AnimaValue.target(NodePath("scale:x"))

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.DYNAMIC_VALUE)
	assert_false(eligibility.message.is_empty())

func test_item_motion_with_a_dynamic_from_value_blocks_with_its_own_reason():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root, 1)
	group.item_motion.from_value = AnimaValue.target(NodePath("scale:x"))

	var eligibility := AnimaGroupCompiler.check_eligibility(group, root)

	assert_eq(eligibility.blocker, AnimaGroupCompiler.Blocker.DYNAMIC_VALUE)
