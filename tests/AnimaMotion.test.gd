extends "res://addons/gut/test.gd"

func test_default_values():
	var motion := AnimaMotion.new()

	assert_eq(motion.display_name, "")
	assert_eq(motion.enabled, true)
	assert_eq(motion.delay, 0.0)
	assert_eq(motion.delay_basis, AnimaMotion.DelayBasis.AFTER_PREVIOUS_ENDS)
	assert_eq(motion.speed, 1.0)
	assert_eq(motion.tags, [])
	assert_eq(motion.metadata, {})
	assert_false(motion.on_started_callback.is_valid())
	assert_false(motion.on_completed_callback.is_valid())

func _leaf(display_name: String) -> AnimaMotion:
	var motion := AnimaMotion.new()
	motion.display_name = display_name
	return motion

func test_then_builds_a_two_step_sequence():
	var a := _leaf("a")
	var b := _leaf("b")

	var result := a.then(b)

	assert_true(result is _AnimaSequence)
	assert_eq(result.children, [a, b])

func test_repeated_then_calls_flatten_into_one_sequence_instead_of_nesting():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")

	var result := a.then(b).then(c)

	assert_eq(result.children, [a, b, c])

func test_with_builds_a_two_child_parallel():
	var a := _leaf("a")
	var b := _leaf("b")

	var result := a.with(b)

	assert_true(result is _AnimaParallel)
	assert_eq(result.children, [a, b])

func test_repeated_with_calls_join_one_parallel_group_instead_of_nesting():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")

	var result := a.with(b).with(c)

	assert_true(result is _AnimaParallel)
	assert_eq(result.children, [a, b, c])

func test_with_after_then_groups_only_the_most_recent_step():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")

	var result := a.then(b).with(c)

	assert_true(result is _AnimaSequence)
	assert_eq(result.children.size(), 2)
	assert_eq(result.children[0], a)
	assert_true(result.children[1] is _AnimaParallel)
	assert_eq(result.children[1].children, [b, c])

func test_then_after_with_starts_a_new_step_leaving_the_earlier_group_intact():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")
	var d := _leaf("d")

	var result := a.with(b).then(c).with(d)

	assert_true(result is _AnimaSequence)
	assert_eq(result.children.size(), 2)
	assert_true(result.children[0] is _AnimaParallel)
	assert_eq(result.children[0].children, [a, b])
	assert_true(result.children[1] is _AnimaParallel)
	assert_eq(result.children[1].children, [c, d])

func test_then_accepts_a_factory_exposing_a_motion_property():
	var container := Node.new()
	add_child_autofree(container)
	var a := _leaf("a")
	var factory := AnimaGridMotionFactory.new(container).with_item_motion(Anima.item().opacity(0.0, 0.1))

	var result := a.then(factory)

	assert_eq(result.children, [a, factory.motion])

func test_with_accepts_a_factory_exposing_a_motion_property():
	var container := Node.new()
	add_child_autofree(container)
	var a := _leaf("a")
	var factory := AnimaGridMotionFactory.new(container).with_item_motion(Anima.item().opacity(0.0, 0.1))

	var result := a.with(factory)

	assert_true(result is _AnimaParallel)
	assert_eq(result.children, [a, factory.motion])

func test_then_with_an_unsupported_type_reports_an_error_and_returns_self_unchanged():
	var a := _leaf("a")

	var result := a.then("not a motion")

	assert_eq(result.children, [a])
	assert_push_error("AnimaMotion.then()")

func test_with_with_an_unsupported_type_reports_an_error_and_returns_self_unchanged():
	var a := _leaf("a")

	var result := a.with("not a motion")

	assert_same(result, a)
	assert_push_error("AnimaMotion.with()")

func test_then_propagates_convenience_target_when_both_sides_agree():
	var node: Node2D = add_child_autofree(Node2D.new())
	var a := _leaf("a")
	a.convenience_target = node
	var b := _leaf("b")
	b.convenience_target = node

	var result := a.then(b)

	assert_same(result.convenience_target, node)

func test_then_leaves_convenience_target_unset_when_sides_disagree():
	var node_a: Node2D = add_child_autofree(Node2D.new())
	var node_b: Node2D = add_child_autofree(Node2D.new())
	var a := _leaf("a")
	a.convenience_target = node_a
	var b := _leaf("b")
	b.convenience_target = node_b

	var result := a.then(b)

	assert_null(result.convenience_target)

func test_with_propagates_convenience_target_when_both_sides_agree():
	var node: Node2D = add_child_autofree(Node2D.new())
	var a := _leaf("a")
	a.convenience_target = node
	var b := _leaf("b")
	b.convenience_target = node

	var result := a.with(b)

	assert_same(result.convenience_target, node)

func test_with_leaves_convenience_target_unset_when_sides_disagree():
	var node_a: Node2D = add_child_autofree(Node2D.new())
	var node_b: Node2D = add_child_autofree(Node2D.new())
	var a := _leaf("a")
	a.convenience_target = node_a
	var b := _leaf("b")
	b.convenience_target = node_b

	var result := a.with(b)

	assert_null(result.convenience_target)

func test_play_wraps_anima_play_with_the_convenience_target():
	var node: Node2D = add_child_autofree(Node2D.new())
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position")
	motion.to_value = Vector2(10.0, 0.0)
	motion.convenience_target = node

	var playback: AnimaPlayback = motion.play()

	assert_not_null(playback)
	assert_same(playback.target, node)
	playback.cancel() # avoid leaking a still-PLAYING playback into later tests

func test_play_on_a_leaf_property_motion_with_no_captured_target_fails():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position")
	motion.to_value = Vector2.ZERO

	var playback := motion.play()

	assert_null(playback)
	assert_push_error("target")

func test_on_started_sets_callback_and_returns_self():
	var motion := AnimaMotion.new()
	var callback := func(): pass

	var result := motion.on_started(callback)

	assert_eq(result, motion)
	assert_eq(motion.on_started_callback, callback)

func test_on_completed_sets_callback_and_returns_self():
	var motion := AnimaMotion.new()
	var callback := func(): pass

	var result := motion.on_completed(callback)

	assert_eq(result, motion)
	assert_eq(motion.on_completed_callback, callback)

func test_repeat_wraps_the_motion_in_an_animarepeat():
	var motion := _leaf("a")

	var result := motion.repeat(3, true)

	assert_true(result is _AnimaRepeat)
	assert_eq(result.child, motion)
	assert_eq(result.count, 3)
	assert_eq(result.alternate, true)

func test_repeat_defaults_to_indefinite_non_alternating():
	var motion := _leaf("a")

	var result := motion.repeat()

	assert_eq(result.count, -1)
	assert_eq(result.alternate, false)

func test_with_speed_sets_speed_and_returns_self():
	var motion := AnimaMotion.new()

	var result := motion.with_speed(2.0)

	assert_eq(result, motion)
	assert_eq(motion.speed, 2.0)

func test_with_delay_sets_delay_and_returns_self_on_a_plain_motion():
	var motion := AnimaMotion.new()

	var result := motion.with_delay(1.5)

	assert_eq(result, motion)
	assert_almost_eq(motion.delay, 1.5, 0.0001)

func test_with_delay_on_a_composed_chain_sets_the_composites_own_delay():
	var a := AnimaPropertyMotion.new()
	var b := AnimaPropertyMotion.new()
	var chain: AnimaMotion = a.then(b)

	var result := chain.with_delay(2.0)

	assert_eq(result, chain)
	assert_true(chain is _AnimaSequence)
	assert_almost_eq(chain.delay, 2.0, 0.0001)
	assert_almost_eq(a.delay, 0.0, 0.0001, "with_delay() on the composite must not touch its children's own delay")

func test_wait_adds_to_the_next_thenned_motions_own_delay():
	var a := AnimaPropertyMotion.new()
	var b := AnimaPropertyMotion.new()

	var chain := a.wait(1.0).then(b)

	assert_almost_eq(b.delay, 1.0, 0.0001)
	assert_almost_eq(a.delay, 0.0, 0.0001, "wait() must not touch the motion it was called on")
	assert_eq(chain.children[1], b)

func test_wait_adds_to_an_already_delayed_next_thenned_motion_instead_of_replacing_it():
	var a := AnimaPropertyMotion.new()
	var b := AnimaPropertyMotion.new().with_delay(0.5)

	a.wait(1.0).then(b)

	assert_almost_eq(b.delay, 1.5, 0.0001)

func test_wait_adds_to_the_next_withed_motions_own_delay():
	var a := AnimaPropertyMotion.new()
	var b := AnimaPropertyMotion.new()

	a.wait(1.0).with(b)

	assert_almost_eq(b.delay, 1.0, 0.0001)

func test_wait_is_consumed_only_once_by_the_next_then_or_with():
	var a := AnimaPropertyMotion.new()
	var b := AnimaPropertyMotion.new()
	var c := AnimaPropertyMotion.new()

	var chain := a.wait(1.0).then(b).then(c)

	assert_almost_eq(b.delay, 1.0, 0.0001)
	assert_almost_eq(c.delay, 0.0, 0.0001, "a wait() call is consumed by the very next then()/with(), not every later one")
	assert_eq(chain.children, [a, b, c])

func test_ending_a_chain_with_an_unconsumed_wait_is_a_harmless_no_op():
	var a := AnimaPropertyMotion.new()

	var result := a.wait(1.0)

	assert_eq(result, a)
