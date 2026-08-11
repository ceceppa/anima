extends "res://addons/gut/test.gd"

func test_a_node_target_resolves_to_children_of_that_node():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGroupMotionFactory.new(container)

	assert_eq(factory.motion.target_collection.kind, AnimaTargetCollection.Kind.CHILDREN)
	assert_same(factory.container, container)

func test_an_array_target_resolves_to_explicit_with_those_nodes():
	var a := Node.new()
	var b := Node.new()
	add_child_autofree(a)
	add_child_autofree(b)

	var factory := AnimaGroupMotionFactory.new([a, b])

	assert_eq(factory.motion.target_collection.kind, AnimaTargetCollection.Kind.EXPLICIT)
	assert_eq(factory.motion.target_collection.reference_data, [a, b])
	assert_null(factory.container)

func test_an_array_entry_that_is_not_a_node_is_skipped_and_reported():
	var a := Node.new()
	add_child_autofree(a)

	var factory := AnimaGroupMotionFactory.new([a, "not a node"])

	assert_eq(factory.motion.target_collection.reference_data, [a])
	assert_push_error("must be a Node")

func test_chain_methods_work_identically_on_an_array_built_factory():
	var a := Node.new()
	add_child_autofree(a)
	var item_motion := Anima.item().opacity(0.0, 0.1)
	var other := AnimaMotion.new()

	var factory := AnimaGroupMotionFactory.new([a]) \
		.with_item_motion(item_motion) \
		.with_delay(1.5) \
		.on_started(Callable(self, "_noop")) \
		.on_completed(Callable(self, "_noop"))

	assert_eq(factory.motion.item_motion, item_motion)
	assert_almost_eq(factory.motion.delay, 1.5, 0.0001)
	assert_eq(factory.motion.on_started_callback, Callable(self, "_noop"))
	assert_true(factory.then(other) is _AnimaSequence)
	assert_true(factory.with(other) is _AnimaParallel)

func test_init_captures_container_as_the_group_motions_convenience_target():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGroupMotionFactory.new(container)

	assert_same(factory.motion.convenience_target, container)

func test_chain_methods_set_the_matching_group_motion_fields():
	var container := Node.new()
	add_child_autofree(container)
	var item_motion := Anima.item().opacity(0.0, 0.1)

	var factory := AnimaGroupMotionFactory.new(container) \
		.with_item_motion(item_motion) \
		.with_delay(1.5)

	assert_eq(factory.motion.item_motion, item_motion)
	assert_almost_eq(factory.motion.delay, 1.5, 0.0001)

func test_keyframes_builds_and_assigns_a_keyframe_item_motion_and_returns_the_factory():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGroupMotionFactory.new(container)
	var result := factory.keyframes({"to": {"opacity": 1.0}}, 0.3)

	assert_same(result, factory)
	assert_true(factory.motion.item_motion is AnimaKeyframeMotion)
	assert_almost_eq((factory.motion.item_motion as AnimaKeyframeMotion).duration, 0.3, 0.0001)

func test_with_duration_with_ease_with_pivot_configure_the_item_motion():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGroupMotionFactory.new(container) \
		.with_item_motion(Anima.item().opacity(0.0, 0.1)) \
		.with_duration(0.4) \
		.with_ease(AnimaEase.Kind.EASE_IN_OUT) \
		.with_pivot(AnimaPivot.Kind.CENTER)

	var item_motion := factory.motion.item_motion as AnimaPropertyMotion
	assert_almost_eq(item_motion.duration, 0.4, 0.0001)
	assert_eq(item_motion.ease.kind, AnimaEase.Kind.EASE_IN_OUT)
	assert_eq(item_motion.pivot, AnimaPivot.Kind.CENTER)

func test_with_duration_without_an_item_motion_reports_an_error_and_returns_the_factory():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGroupMotionFactory.new(container)
	var result := factory.with_duration(0.5)

	assert_same(result, factory)
	assert_null(factory.motion.item_motion)
	assert_push_error("requires an item motion")

func test_on_started_and_on_completed_set_the_group_motions_callbacks():
	var container := Node.new()
	add_child_autofree(container)
	var started_flag := Callable(self, "_noop")
	var completed_flag := Callable(self, "_noop")

	var factory := AnimaGroupMotionFactory.new(container) \
		.on_started(started_flag) \
		.on_completed(completed_flag)

	assert_eq(factory.motion.on_started_callback, started_flag)
	assert_eq(factory.motion.on_completed_callback, completed_flag)

func _noop() -> void:
	pass

func test_then_delegates_to_the_group_motions_own_then_and_returns_the_composite():
	var container := Node.new()
	add_child_autofree(container)
	var other := AnimaMotion.new()

	var factory := AnimaGroupMotionFactory.new(container).with_item_motion(Anima.item().opacity(0.0, 0.1))
	var result := factory.then(other)

	assert_true(result is _AnimaSequence)
	assert_eq(result.children, [factory.motion, other])

func test_with_delegates_to_the_group_motions_own_with_and_returns_the_composite():
	var container := Node.new()
	add_child_autofree(container)
	var other := AnimaMotion.new()

	var factory := AnimaGroupMotionFactory.new(container).with_item_motion(Anima.item().opacity(0.0, 0.1))
	var result := factory.with(other)

	assert_true(result is _AnimaParallel)
	assert_eq(result.children, [factory.motion, other])

func test_play_without_an_item_motion_reports_an_error_and_returns_null():
	var container := Node.new()
	add_child_autofree(container)

	var factory := AnimaGroupMotionFactory.new(container)

	assert_null(factory.play())
	assert_push_error("requires with_item_motion")
