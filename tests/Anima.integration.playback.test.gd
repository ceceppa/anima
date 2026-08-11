extends "res://addons/gut/test.gd"

func test_playing_a_motion_with_no_setup_reaches_end_value():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var playback := Anima.play(motion, node)

	simulate(AnimaRuntime.get_singleton(), 60, 1.0 / 60.0)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

## Regression: a playback is removed from AnimaRuntime.active_playbacks when
## it finishes or is cancelled (see AnimaRuntime._track), so it stops being
## advanced every frame. reverse() setting state back to PLAYING used to be a
## no-op through the real runtime loop for exactly that reason — every other
## reverse test in this addon calls playback._advance() directly, which
## bypasses AnimaRuntime._process() entirely and never exercised this path.
## AnimaRuntime.ensure_tracked() (called from reverse()) re-adds it.
func test_reverse_after_a_natural_finish_is_still_advanced_by_the_runtime():
	var node: Node2D = add_child_autofree(Node2D.new())
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 1.0 / 6.0

	var playback := Anima.play(motion, node)
	simulate(AnimaRuntime.get_singleton(), 10, 1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	simulate(AnimaRuntime.get_singleton(), 10, 1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the runtime should have kept advancing the reversed run on its own")
	assert_almost_eq(node.position.x, 0.0, 0.01)

## Same regression, for cancel() instead of a natural finish — cancel also
## removes the playback from AnimaRuntime.active_playbacks via the same
## `finished` signal.
func test_reverse_after_cancel_is_still_advanced_by_the_runtime():
	var node: Node2D = add_child_autofree(Node2D.new())
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 1.0

	var playback := Anima.play(motion, node)
	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)
	playback.cancel()
	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	var value_at_cancel: float = node.position.x
	assert_gt(value_at_cancel, 0.0)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	simulate(AnimaRuntime.get_singleton(), 60, 1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the runtime should have kept advancing the reversed run after a cancel, too")
	assert_almost_eq(node.position.x, 0.0, 0.01)

func test_freeing_the_target_mid_playback_cancels_it_without_error():
	var root: Node = add_child_autofree(Node.new())
	var target := Node2D.new()
	root.add_child(target)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var playback := Anima.play(motion, target)
	playback._advance(1.0 / 6.0)
	assert_true(AnimaRuntime.get_singleton().active_playbacks.has(playback), "sanity: the playback should still be tracked before the target is freed")

	root.remove_child(target)
	target.free()
	playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_false(AnimaRuntime.get_singleton().active_playbacks.has(playback), "a freed target's playback should stop being advanced every frame")

func test_hiding_target_does_not_cancel_playback():
	var node: Node2D = add_child_autofree(Node2D.new())
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var playback := Anima.play(motion, node)
	simulate(AnimaRuntime.get_singleton(), 5, 1.0 / 60.0)
	node.hide()
	simulate(AnimaRuntime.get_singleton(), 5, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.PLAYING, "hiding the target should not stop its playback")
	playback.cancel()

func test_reparenting_target_does_not_cancel_playback():
	var old_parent: Node = add_child_autofree(Node.new())
	var new_parent: Node = add_child_autofree(Node.new())
	var target := Node2D.new()
	old_parent.add_child(target)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var playback := Anima.play(motion, target)
	simulate(AnimaRuntime.get_singleton(), 5, 1.0 / 60.0)

	old_parent.remove_child(target)
	new_parent.add_child(target)
	simulate(AnimaRuntime.get_singleton(), 55, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "reparenting the target should not stop its playback")
	assert_almost_eq(target.position.x, 100.0, 0.01)
	playback.cancel()

## Drives real engine frames (await get_tree().process_frame) rather than
## simulate(), which calls _process() directly and bypasses the engine's own
## pause gate entirely — the thing this test needs to actually exercise.
func test_pausing_the_scene_tree_stops_advancing_and_resumes_on_unpause():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var playback := Anima.play(motion, node)
	await get_tree().process_frame
	await get_tree().process_frame
	var value_before_pause: float = node.position.x
	assert_gt(value_before_pause, 0.0, "sanity: the motion should already be moving before pausing")

	get_tree().paused = true
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().paused = false

	assert_eq(node.position.x, value_before_pause, "a paused scene tree should not advance playback")
	assert_eq(playback.state, AnimaPlayback.State.PLAYING, "pausing should not cancel playback, only stop advancing it")
	playback.cancel()

func test_second_motion_on_same_node_plays_independently():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion_a := AnimaPropertyMotion.new()
	motion_a.target_property = NodePath("position:x")
	motion_a.to_value = 100.0
	motion_a.duration = 1.0

	var motion_b := AnimaPropertyMotion.new()
	motion_b.target_property = NodePath("position:y")
	motion_b.to_value = 50.0
	motion_b.duration = 2.0

	var playback_a := Anima.play(motion_a, node)
	var playback_b := Anima.play(motion_b, node)

	simulate(AnimaRuntime.get_singleton(), 120, 1.0 / 60.0)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_eq(playback_a.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.y, 50.0, 0.01)
	assert_eq(playback_b.state, AnimaPlayback.State.FINISHED)

func test_playing_a_sequence_runs_children_in_order_and_completes():
	var node: Node2D = add_child_autofree(Node2D.new())

	var first := AnimaPropertyMotion.new()
	first.target_property = NodePath("position:x")
	first.to_value = 10.0
	first.duration = 0.5

	var second := AnimaPropertyMotion.new()
	second.target_property = NodePath("position:y")
	second.to_value = 20.0
	second.duration = 0.5

	var sequence := _AnimaSequence.new()
	sequence.children = [first, second]

	var playback := Anima.play(sequence, node)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(node.position.y, 0.0)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_playing_a_parallel_runs_children_concurrently_and_completes():
	var node: Node2D = add_child_autofree(Node2D.new())

	var first := AnimaPropertyMotion.new()
	first.target_property = NodePath("position:x")
	first.to_value = 10.0
	first.duration = 0.5

	var second := AnimaPropertyMotion.new()
	second.target_property = NodePath("position:y")
	second.to_value = 20.0
	second.duration = 0.5

	var parallel := _AnimaParallel.new()
	parallel.children = [first, second]

	var playback := Anima.play(parallel, node)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_gt(node.position.x, 0.0)
	assert_gt(node.position.y, 0.0)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
