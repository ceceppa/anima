extends "res://addons/gut/test.gd"

func test_then_plays_two_convenience_motions_in_sequence():
	var node: Node2D = add_child_autofree(Node2D.new())

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(node).opacity(0.0, 0.1))

	assert_true(chain is _AnimaSequence)
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

	assert_true(chain is _AnimaParallel)
	assert_eq(chain.children.size(), 2)

	var playback := Anima.play(chain, node)
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_play_starts_a_with_chain_combining_different_target_nodes():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())
	var c: Control = add_child_autofree(Control.new())
	c.modulate = Color.WHITE

	var playback: AnimaPlayback = Anima.on(a).move_by(Vector2(50.0, 0.0), 0.1) \
		.with(Anima.on(b).move_by(Vector2(0.0, 30.0), 0.1)) \
		.with(Anima.on(c).color(Color.TRANSPARENT, 0.1)) \
		.play()

	assert_not_null(playback)
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(a.position.x, 50.0, 0.01, "a should have moved on its own captured target")
	assert_almost_eq(b.position.y, 30.0, 0.01, "b should have moved on its own captured target")
	assert_almost_eq(c.modulate.a, 0.0, 0.01, "c should have faded on its own captured target")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_play_starts_a_then_chain_combining_different_target_nodes():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())

	var playback: AnimaPlayback = Anima.on(a).move_by(Vector2(40.0, 0.0), 0.1) \
		.then(Anima.on(b).move_by(Vector2(0.0, 40.0), 0.1)) \
		.play()

	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(a.position.x, 40.0, 0.01)
	assert_almost_eq(b.position.y, 0.0, 0.01, "b's step should not have started yet")

	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(b.position.y, 40.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_reversing_a_multi_target_with_chain_still_targets_each_leafs_own_node():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())
	a.position = Vector2(5.0, 0.0)
	b.position = Vector2(0.0, 5.0)

	var playback: AnimaPlayback = Anima.on(a).move_by(Vector2(50.0, 0.0), 0.1) \
		.with(Anima.on(b).move_by(Vector2(0.0, 50.0), 0.1)) \
		.play()

	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(a.position.x, 55.0, 0.01)
	assert_almost_eq(b.position.y, 55.0, 0.01)

	playback.reverse()
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(a.position.x, 5.0, 0.01, "reverse should still move a, not the wrong node")
	assert_almost_eq(b.position.y, 5.0, 0.01, "reverse should still move b, not the wrong node")

func test_multiple_with_calls_after_one_then_join_a_single_parallel_group():
	var node: Node2D = add_child_autofree(Node2D.new())

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(node).opacity(0.0, 0.1)) \
		.with(Anima.on(node).scale(Vector2(2.0, 2.0), 0.1)) \
		.with(Anima.on(node).rotation(1.0, 0.1))

	assert_true(chain is _AnimaSequence)
	assert_eq(chain.children.size(), 2, "position step, then one parallel group of everything chained since then()")
	assert_true(chain.children[1] is _AnimaParallel)
	assert_eq(chain.children[1].children.size(), 3, "opacity, scale, and rotation should all be in the same group, not nested pairs")

func test_three_motions_joined_by_with_all_play_and_finish_together():
	var node: Node2D = add_child_autofree(Node2D.new())

	var chain := Anima.on(node).position(Vector2(50.0, 0.0), 0.1) \
		.with(Anima.on(node).opacity(0.0, 0.1)) \
		.with(Anima.on(node).rotation(1.0, 0.1))

	var playback := Anima.play(chain, node)
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.rotation, 1.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

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

func test_fade_out_then_fade_in_play_end_to_end_via_chained_play():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.modulate.a = 1.0

	var playback: AnimaPlayback = Anima.on(node).fade_out(0.1).play()
	for i in range(6):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

	var fade_in_playback: AnimaPlayback = Anima.on(node).fade_in(0.1).play()
	for i in range(6):
		fade_in_playback._advance(1.0 / 60.0)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)

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

func test_with_delay_on_a_composed_chain_delays_the_whole_chains_start():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())
	b.modulate.a = 1.0

	var playback: AnimaPlayback = Anima.on(a).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(b).opacity(0.0, 0.1)) \
		.with_delay(1.0) \
		.play()

	playback._advance(0.5)
	assert_almost_eq(a.position.x, 0.0, 0.01, "nothing should animate before the whole-chain delay elapses")
	assert_almost_eq(b.modulate.a, 1.0, 0.01)

	for i in range(78):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(a.position.x, 50.0, 0.01, "position step should have finished first, once the delay has elapsed")
	assert_almost_eq(b.modulate.a, 0.0, 0.01, "opacity step should have played after it, in original order")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_per_leaf_with_delay_before_combining_is_unaffected_by_the_base_promotion():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.modulate.a = 1.0

	var motion := Anima.on(node).opacity(0.0, 0.1).with_delay(0.2)
	var playback := Anima.play(motion, node)

	playback._advance(0.1)
	assert_almost_eq(node.modulate.a, 1.0, 0.01, "the single leaf's own delay should still apply as before")

	for i in range(20):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

func test_a_chain_with_no_whole_chain_delay_starts_immediately():
	var a: Node2D = add_child_autofree(Node2D.new())

	var playback: AnimaPlayback = Anima.on(a).position(Vector2(50.0, 0.0), 0.1) \
		.then(Anima.on(a).opacity(0.0, 0.1)) \
		.play()

	playback._advance(1.0 / 60.0)
	assert_gt(a.position.x, 0.0, "the chain should already be animating on the very next frame")

func test_wait_delays_the_start_of_the_next_thenned_step():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())
	b.modulate.a = 1.0

	var playback: AnimaPlayback = Anima.on(a).position(Vector2(50.0, 0.0), 0.05) \
		.wait(1.0) \
		.then(Anima.on(b).opacity(0.0, 0.05)) \
		.play()

	for i in range(15):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(a.position.x, 50.0, 0.01, "the first step should already be finished")
	assert_almost_eq(b.modulate.a, 1.0, 0.01, "the second step should still be waiting out the 1s pause")

	for i in range(70):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(b.modulate.a, 0.0, 0.01, "the second step should have finished once the wait and its own duration elapsed")

func test_wait_adds_to_an_explicit_with_delay_on_the_next_step_instead_of_replacing_it():
	var a: Node2D = add_child_autofree(Node2D.new())
	var b: Node2D = add_child_autofree(Node2D.new())
	b.modulate.a = 1.0

	var playback: AnimaPlayback = Anima.on(a).position(Vector2(50.0, 0.0), 0.05) \
		.wait(1.0) \
		.then(Anima.on(b).opacity(0.0, 0.05).with_delay(0.5)) \
		.play()

	# 1.0 (wait) + 0.5 (explicit with_delay) = 1.5s total before the opacity step starts.
	for i in range(84):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(b.modulate.a, 1.0, 0.01, "opacity should not have started yet — the two delays should add, not one replace the other")

	for i in range(20):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(b.modulate.a, 0.0, 0.01)

func test_wait_between_two_grid_factory_calls_delays_the_second_grids_start():
	var a := Node.new()
	add_child_autofree(a)
	for i in 4:
		a.add_child(Node2D.new())
	var b := Node.new()
	add_child_autofree(b)
	var b_children: Array[Node2D] = []
	for i in 4:
		var cell := Node2D.new()
		cell.modulate.a = 1.0
		b.add_child(cell)
		b_children.append(cell)

	var factory_a := Anima.grid(a, Vector2i(2, 2)).with_item_motion(Anima.item().opacity(0.0, 0.05))
	factory_a.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	var factory_b := Anima.grid(b, Vector2i(2, 2)).with_item_motion(Anima.item().opacity(0.0, 0.05))
	factory_b.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var playback: AnimaPlayback = factory_a.wait(1.0).with(factory_b).play()

	for i in range(30):
		playback._advance(1.0 / 60.0)
	for cell in b_children:
		assert_almost_eq(cell.modulate.a, 1.0, 0.01, "the second grid should still be waiting out its 1s pause")

	for i in range(50):
		playback._advance(1.0 / 60.0)
	for cell in b_children:
		assert_almost_eq(cell.modulate.a, 0.0, 0.01)

func test_wait_between_two_group_factory_calls_delays_the_second_groups_start():
	var a := Node.new()
	add_child_autofree(a)
	var a_child := Node2D.new()
	a.add_child(a_child)
	var b := Node.new()
	add_child_autofree(b)
	var b_child := Node2D.new()
	b_child.modulate.a = 1.0
	b.add_child(b_child)

	var factory_a := Anima.group(a).with_item_motion(Anima.item().opacity(0.0, 0.05))
	var factory_b := Anima.group(b).with_item_motion(Anima.item().opacity(0.0, 0.05))

	var playback: AnimaPlayback = factory_a.wait(1.0).with(factory_b).play()

	for i in range(30):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(b_child.modulate.a, 1.0, 0.01, "the second group should still be waiting out its 1s pause")

	for i in range(50):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(b_child.modulate.a, 0.0, 0.01)

func test_ending_a_chain_with_an_unconsumed_wait_does_not_error_or_affect_playback():
	var a: Node2D = add_child_autofree(Node2D.new())

	var playback: AnimaPlayback = Anima.on(a).position(Vector2(50.0, 0.0), 0.05).wait(1.0).play()

	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(a.position.x, 50.0, 0.01, "an unconsumed wait() must not delay or otherwise affect the motion it was called on")
