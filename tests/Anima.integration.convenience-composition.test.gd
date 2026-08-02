extends "res://addons/gut/test.gd"

func test_then_plays_two_convenience_motions_in_sequence():
	var node: Node2D = add_child_autofree(Node2D.new())

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(node).opacity(0.0, 0.1))

	assert_true(chain is AnimaSequence)
	assert_eq(chain.children.size(), 2)

	var playback := Anima.play(chain, node)
	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.position.x, 50.0, 0.01, "position step should have finished first")
	assert_almost_eq(node.modulate.a, 1.0, 0.01, "opacity step should not have started yet")

	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01, "opacity step should now be finished")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_with_plays_two_convenience_motions_together():
	var node: Node2D = add_child_autofree(Node2D.new())

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.with(Anima.on(node).opacity(0.0, 0.1))

	assert_true(chain is AnimaParallel)
	assert_eq(chain.children.size(), 2)

	var playback := Anima.play(chain, node)
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_multiple_with_calls_after_one_then_join_a_single_parallel_group():
	var node: Node2D = add_child_autofree(Node2D.new())

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(node).opacity(0.0, 0.1)) \
		.with(Anima.on(node).scale(Vector2(2.0, 2.0), 0.1)) \
		.with(Anima.on(node).rotation(1.0, 0.1))

	assert_true(chain is AnimaSequence)
	assert_eq(chain.children.size(), 2, "position step, then one parallel group of everything chained since then()")
	assert_true(chain.children[1] is AnimaParallel)
	assert_eq(chain.children[1].children.size(), 3, "opacity, scale, and rotation should all be in the same group, not nested pairs")

func test_chaining_a_second_property_method_directly_is_not_supported():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := Anima.on(node).position(Vector2(50.0, 0.0))

	assert_false(motion.has_method("opacity"), "a returned AnimaPropertyMotion has no factory methods to chain — combine explicitly via then()/with() instead")

func test_delay_duration_ease_visibly_affect_convenience_playback_like_canonical():
	var convenience_node: Node2D = add_child_autofree(Node2D.new())
	var canonical_node: Node2D = add_child_autofree(Node2D.new())

	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.SINE

	var convenience_motion := Anima.on(convenience_node).position(Vector2(100.0, 0.0)) \
		.with_duration(0.2).with_ease(ease).with_delay(0.05)
	var canonical_motion := Motion.to(NodePath("position"), Vector2(100.0, 0.0)) \
		.with_duration(0.2).with_ease(ease)
	canonical_motion.delay = 0.05

	var convenience_playback := Anima.play(convenience_motion, convenience_node)
	var canonical_playback := Anima.play(canonical_motion, canonical_node)
	for i in range(20):
		convenience_playback._advance(1.0 / 60.0)
		canonical_playback._advance(1.0 / 60.0)

	assert_almost_eq(convenience_node.position.x, canonical_node.position.x, 0.01)

func test_repeat_wraps_a_convenience_motion_like_any_other_motion():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position.x = 0.0

	var repeated := Motion.repeat(Anima.on(node).move_by(Vector2(10.0, 0.0), 0.05), 3)
	var playback := Anima.play(repeated, node)
	for i in range(20):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 30.0, 0.5, "three repeats of a +10 move_by should land at 30")

func test_reversing_a_then_composition_returns_every_started_step_to_its_actual_start():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position = Vector2(5.0, 0.0)
	node.modulate.a = 0.8

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(node).opacity(0.0, 0.1))
	var playback := Anima.play(chain, node)

	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.position.x, 50.0, 0.01)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.position.x, 5.0, 0.01, "reverse should return position to the value observed when the run began")

func test_reversing_a_with_composition_returns_every_captured_child_to_its_actual_start():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position = Vector2(5.0, 0.0)
	node.modulate.a = 0.8

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.with(Anima.on(node).opacity(0.0, 0.1))
	var playback := Anima.play(chain, node)

	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

	playback.reverse()
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.position.x, 5.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.8, 0.01)

func test_pause_resume_and_cancel_already_work_for_a_convenience_motion_like_any_other():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := Anima.on(node).position(Vector2(100.0, 0.0), 0.5)
	var playback := Anima.play(motion, node)
	playback._advance(0.1)

	playback.pause()
	var frozen_x := node.position.x
	playback._advance(0.1)
	assert_eq(node.position.x, frozen_x, "paused convenience playback should not keep changing the property")

	playback.resume()
	playback._advance(0.05)
	assert_gt(node.position.x, frozen_x)

	watch_signals(playback)
	playback.cancel()
	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_signal_emitted_with_parameters(playback, "finished", [false])
