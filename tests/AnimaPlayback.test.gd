extends "res://addons/gut/test.gd"

func _make_playback(to_value: float, duration: float) -> AnimaPlayback:
	var node := Node2D.new()
	autofree(node)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = to_value
	motion.duration = duration

	return AnimaPlayback.new(motion, node)

func test_advances_property_to_end_value_across_simulated_frames():
	var playback := _make_playback(100.0, 1.0)

	for i in range(10):
		playback._advance(0.1)

	assert_almost_eq(playback.target.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_pause_freezes_value_and_resume_continues_to_end_value():
	var playback := _make_playback(100.0, 1.0)

	playback._advance(0.5)
	var value_before_pause: float = playback.target.position.x

	playback.pause()
	playback._advance(0.5)
	assert_eq(playback.target.position.x, value_before_pause, "paused playback should not change the property")
	assert_eq(playback.state, AnimaPlayback.State.PAUSED)

	playback.resume()
	for i in range(5):
		playback._advance(0.1)

	assert_almost_eq(playback.target.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_cancel_stops_changes_and_reports_not_successful():
	var playback := _make_playback(100.0, 1.0)

	playback._advance(0.5)
	var value_before_cancel: float = playback.target.position.x

	watch_signals(playback)
	playback.cancel()

	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_signal_emitted_with_parameters(playback, "finished", [false])

	playback._advance(0.5)
	assert_eq(playback.target.position.x, value_before_cancel, "cancelled playback should not change the property further")

func _make_spring_playback(to_value: float) -> AnimaPlayback:
	var node := Node2D.new()
	autofree(node)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.from_value = 0.0
	motion.to_value = to_value
	motion.ease = AnimaEase.new()
	motion.ease.kind = AnimaEase.Kind.SPRING

	return AnimaPlayback.new(motion, node)

func test_retarget_continues_from_current_value_and_velocity_without_resetting():
	var playback := _make_spring_playback(100.0)

	for i in range(30):
		playback._advance(1.0 / 60.0)
	var value_before_retarget: float = playback.target.position.x
	assert_gt(value_before_retarget, 0.0, "the spring should already be moving before it's retargeted")

	playback.retarget(50.0)
	# Retargeting must not jump the value back toward the original start (0.0).
	assert_almost_eq(playback.target.position.x, value_before_retarget, 0.5)

	for i in range(600):
		playback._advance(1.0 / 60.0)
		if playback.state == AnimaPlayback.State.FINISHED:
			break
	assert_almost_eq(playback.target.position.x, 50.0, 1.0)

func test_retarget_still_reports_finished_against_the_new_target():
	var playback := _make_spring_playback(100.0)
	playback.motion.ease.spring_completion_mode = AnimaEase.SpringCompletionMode.STRICTLY_SETTLED

	for i in range(20):
		playback._advance(1.0 / 60.0)
	playback.retarget(30.0)

	var finished := false
	for i in range(600):
		playback._advance(1.0 / 60.0)
		if playback.state == AnimaPlayback.State.FINISHED:
			finished = true
			break

	assert_true(finished, "playback should still report finished after a retarget")
	assert_almost_eq(playback.target.position.x, 30.0, 1.0)

func test_retarget_on_non_spring_motion_is_an_error():
	var playback := _make_playback(100.0, 1.0) # linear ease, not spring
	playback.retarget(50.0)
	assert_push_error("only defined for a single SPRING-eased")

func test_on_started_callback_fires_once_when_playback_begins():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.2
	var call_count := [0]
	motion.on_started(func(): call_count[0] += 1)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)

	assert_eq(call_count[0], 1, "on_started should fire exactly once, at the moment playback begins")
	for i in range(10):
		playback._advance(0.05)
	assert_eq(call_count[0], 1, "on_started should not fire again while the same run continues")

func test_on_completed_callback_fires_once_only_on_successful_finish():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.2
	var call_count := [0]
	motion.on_completed(func(): call_count[0] += 1)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)

	playback._advance(0.1)
	assert_eq(call_count[0], 0, "on_completed should not fire before the motion actually finishes")

	playback._advance(0.2)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_eq(call_count[0], 1)

	playback._advance(0.1)
	assert_eq(call_count[0], 1, "on_completed should not fire again after the run already finished")

func test_on_completed_callback_does_not_fire_on_cancel():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.2
	var call_count := [0]
	motion.on_completed(func(): call_count[0] += 1)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.05)
	playback.cancel()

	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_eq(call_count[0], 0, "on_completed should not fire when playback is cancelled")

func test_on_started_and_on_completed_fire_independently_in_order():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.1
	var events: Array[String] = []
	motion.on_started(func(): events.append("started"))
	motion.on_completed(func(): events.append("completed"))

	var node := Node2D.new()
	autofree(node)
	node.position.x = 0.0
	var playback := AnimaPlayback.new(motion, node)
	assert_eq(node.position.x, 0.0, "on_started fires before any visible change")

	for i in range(10):
		playback._advance(0.02)

	assert_eq(events, ["started", "completed"])
	assert_almost_eq(node.position.x, 10.0, 0.01, "on_completed fires after the last visible change")

func test_reversing_fires_on_started_again():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.1
	var call_count := [0]
	motion.on_started(func(): call_count[0] += 1)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	for i in range(10):
		playback._advance(0.02)
	assert_eq(call_count[0], 1)

	playback.reverse()
	assert_eq(call_count[0], 2, "reversing starts a new run from the target's perspective")

func test_retarget_twice_in_quick_succession_ends_at_the_most_recent_target():
	var playback := _make_spring_playback(100.0)

	for i in range(10):
		playback._advance(1.0 / 60.0)
	playback.retarget(200.0)
	for i in range(2):
		playback._advance(1.0 / 60.0)
	playback.retarget(60.0)

	for i in range(600):
		playback._advance(1.0 / 60.0)
		if playback.state == AnimaPlayback.State.FINISHED:
			break
	assert_almost_eq(playback.target.position.x, 60.0, 1.0)

func test_play_backwards_plays_in_reverse_from_the_first_frame():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.from_value = 0.0
	motion.to_value = 10.0
	motion.duration = 0.2

	var node := Node2D.new()
	autofree(node)
	node.position.x = 0.0

	var playback := Anima.play_backwards(motion, node)
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	# Reversed from the start: from_value/to_value are swapped (10 -> 0), so
	# the target should not have jumped toward the original forward direction.
	assert_almost_eq(node.position.x, 10.0, 0.01, "the very first frame should already reflect the reversed start value")

	for i in range(10):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 0.0, 0.01, "playing backwards should end at the original forward start value")
	playback.cancel()

func test_play_backwards_on_a_group_matches_forward_then_reverse():
	var forward_root := Node.new()
	add_child_autofree(forward_root)
	var backward_root := Node.new()
	add_child_autofree(backward_root)

	for root in [forward_root, backward_root]:
		for i in 3:
			root.add_child(Node2D.new())

	var forward_group := AnimaGroupMotion.new()
	forward_group.target_collection = AnimaTargetCollection.new()
	forward_group.item_motion = AnimaPropertyMotion.new()
	forward_group.item_motion.target_property = NodePath("position:x")
	forward_group.item_motion.to_value = 10.0
	forward_group.item_motion.duration = 0.1
	forward_group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var backward_group := AnimaGroupMotion.new()
	backward_group.target_collection = AnimaTargetCollection.new()
	backward_group.item_motion = AnimaPropertyMotion.new()
	backward_group.item_motion.target_property = NodePath("position:x")
	backward_group.item_motion.to_value = 10.0
	backward_group.item_motion.duration = 0.1
	backward_group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var forward_playback := Anima.play(forward_group, forward_root)
	for i in range(10):
		forward_playback._advance(0.02)
	assert_eq(forward_playback.state, AnimaPlayback.State.FINISHED)
	forward_playback.reverse()
	for i in range(10):
		forward_playback._advance(0.02)
	assert_eq(forward_playback.state, AnimaPlayback.State.FINISHED)

	var backward_playback := Anima.play_backwards(backward_group, backward_root)
	for i in range(10):
		backward_playback._advance(0.02)
	assert_eq(backward_playback.state, AnimaPlayback.State.FINISHED)

	for i in forward_root.get_child_count():
		assert_almost_eq(
			backward_root.get_child(i).position.x,
			forward_root.get_child(i).position.x,
			0.01,
			"play_backwards should reach the same end state as playing forward then reversing"
		)

func test_root_level_delay_is_honoured_when_played_standalone():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.1
	motion.delay = 0.2

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)

	for i in range(9):
		playback._advance(0.02)
	assert_eq(node.position.x, 0.0, "the target should not move until the root-level delay has elapsed")

	for i in range(10):
		playback._advance(0.02)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_zero_delay_behaves_the_same_as_no_delay():
	var with_zero_delay := AnimaPropertyMotion.new()
	with_zero_delay.target_property = NodePath("position:x")
	with_zero_delay.to_value = 10.0
	with_zero_delay.duration = 0.1
	with_zero_delay.delay = 0.0

	var without_delay := AnimaPropertyMotion.new()
	without_delay.target_property = NodePath("position:x")
	without_delay.to_value = 10.0
	without_delay.duration = 0.1

	var node_a := Node2D.new()
	autofree(node_a)
	var node_b := Node2D.new()
	autofree(node_b)

	var playback_a := AnimaPlayback.new(with_zero_delay, node_a)
	var playback_b := AnimaPlayback.new(without_delay, node_b)

	for i in range(6):
		playback_a._advance(0.02)
		playback_b._advance(0.02)

	assert_almost_eq(node_a.position.x, node_b.position.x, 0.0001)
	assert_eq(playback_a.state, playback_b.state)

func test_with_speed_changes_how_fast_a_motion_plays():
	var normal := AnimaPropertyMotion.new()
	normal.target_property = NodePath("position:x")
	normal.to_value = 10.0
	normal.duration = 1.0

	var fast := AnimaPropertyMotion.new()
	fast.target_property = NodePath("position:x")
	fast.to_value = 10.0
	fast.duration = 1.0
	fast.with_speed(4.0)

	var normal_node := Node2D.new()
	autofree(normal_node)
	var fast_node := Node2D.new()
	autofree(fast_node)

	var normal_playback := AnimaPlayback.new(normal, normal_node)
	var fast_playback := AnimaPlayback.new(fast, fast_node)

	normal_playback._advance(0.05)
	fast_playback._advance(0.05)

	assert_gt(fast_node.position.x, normal_node.position.x)
	normal_playback.cancel()
	fast_playback.cancel()

func test_complete_applies_end_value_and_fires_completion_once():
	var playback := _make_playback(100.0, 1.0)
	var call_count := [0]
	playback.motion.on_completed(func(): call_count[0] += 1)

	playback._advance(0.2)
	watch_signals(playback)
	playback.complete()

	assert_almost_eq(playback.target.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_eq(call_count[0], 1)
	assert_signal_emitted_with_parameters(playback, "finished", [true])

	playback._advance(0.5)
	assert_eq(call_count[0], 1, "complete() should not fire the completion callback again")

func test_complete_with_restore_initial_policy_snaps_back_after_finishing():
	var playback := _make_playback(100.0, 1.0)
	playback.motion.completion_value_policy = AnimaMotion.CompletionValuePolicy.RESTORE_INITIAL

	playback._advance(0.5)
	playback.complete()

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(playback.target.position.x, 0.0, 0.01, "RESTORE_INITIAL should return to the pre-animation value even though completion succeeded")

func test_complete_with_default_policy_keeps_final_value():
	var playback := _make_playback(100.0, 1.0)

	playback._advance(0.5)
	playback.complete()

	assert_almost_eq(playback.target.position.x, 100.0, 0.01, "KEEP_FINAL (default) should leave the authored end value in place")

func test_revert_restores_initial_value_and_cancels():
	var playback := _make_playback(100.0, 1.0)
	playback.target.position.x = 5.0 # the pre-animation value observed at capture

	watch_signals(playback)
	playback._advance(0.5)
	assert_ne(playback.target.position.x, 5.0, "sanity: the motion should have moved away from the pre-animation value")

	playback.revert()

	assert_almost_eq(playback.target.position.x, 5.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_signal_emitted_with_parameters(playback, "finished", [false])

	playback._advance(0.5)
	assert_almost_eq(playback.target.position.x, 5.0, 0.01, "reverted playback should not change the property further")

func test_cancel_with_restore_initial_policy_snaps_back():
	var playback := _make_playback(100.0, 1.0)
	playback.motion.cancellation_value_policy = AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL
	playback.target.position.x = 0.0

	playback._advance(0.5)
	playback.cancel()

	assert_almost_eq(playback.target.position.x, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)

func test_cancel_with_complete_policy_applies_end_value_but_reports_cancellation():
	var playback := _make_playback(100.0, 1.0)
	playback.motion.cancellation_value_policy = AnimaMotion.CancellationValuePolicy.COMPLETE
	var call_count := [0]
	playback.motion.on_completed(func(): call_count[0] += 1)

	watch_signals(playback)
	playback._advance(0.5)
	playback.cancel()

	assert_almost_eq(playback.target.position.x, 100.0, 0.01, "COMPLETE cancellation policy applies the authored end value")
	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_signal_emitted_with_parameters(playback, "finished", [false])
	assert_eq(call_count[0], 0, "cancellation must never fire on_completed_callback, even under the COMPLETE value policy")

func test_complete_and_revert_on_a_sequence():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.position = Vector2(0.0, 0.0)

	var first := AnimaPropertyMotion.new()
	first.target_property = NodePath("position:x")
	first.to_value = 10.0
	first.duration = 0.5

	var second := AnimaPropertyMotion.new()
	second.target_property = NodePath("position:y")
	second.to_value = 20.0
	second.duration = 0.5

	var sequence := AnimaSequence.new()
	sequence.children = [first, second]

	var complete_playback := AnimaPlayback.new(sequence, node)
	complete_playback._advance(0.1)
	complete_playback.complete()
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01, "complete() on a Sequence should force every child, not just the started one")
	assert_eq(complete_playback.state, AnimaPlayback.State.FINISHED)

	var revert_node: Node2D = add_child_autofree(Node2D.new())
	var revert_playback := AnimaPlayback.new(sequence, revert_node)
	revert_playback._advance(0.1)
	revert_playback.revert()
	assert_almost_eq(revert_node.position.x, 0.0, 0.01)
	assert_eq(revert_playback.state, AnimaPlayback.State.CANCELLED)

func test_complete_and_revert_on_a_parallel():
	var node: Node2D = add_child_autofree(Node2D.new())

	var first := AnimaPropertyMotion.new()
	first.target_property = NodePath("position:x")
	first.to_value = 10.0
	first.duration = 0.5

	var second := AnimaPropertyMotion.new()
	second.target_property = NodePath("position:y")
	second.to_value = 20.0
	second.duration = 0.5

	var parallel := AnimaParallel.new()
	parallel.children = [first, second]

	var playback := AnimaPlayback.new(parallel, node)
	playback._advance(0.1)
	playback.complete()

	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	var revert_node: Node2D = add_child_autofree(Node2D.new())
	var revert_playback := AnimaPlayback.new(parallel, revert_node)
	revert_playback._advance(0.1)
	revert_playback.revert()
	assert_almost_eq(revert_node.position.x, 0.0, 0.01)
	assert_almost_eq(revert_node.position.y, 0.0, 0.01)

func test_complete_and_revert_on_a_group():
	var root: Node = add_child_autofree(Node.new())
	for i in 3:
		root.add_child(Node2D.new())

	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = AnimaPropertyMotion.new()
	group.item_motion.target_property = NodePath("position:x")
	group.item_motion.to_value = 10.0
	group.item_motion.duration = 0.5
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var playback := Anima.play(group, root)
	playback._advance(0.1)
	playback.complete()

	for child in root.get_children():
		assert_almost_eq(child.position.x, 10.0, 0.01, "complete() on a Group should force every resolved item to its end value")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	var revert_root: Node = add_child_autofree(Node.new())
	for i in 3:
		revert_root.add_child(Node2D.new())
	var revert_playback := Anima.play(group, revert_root)
	revert_playback._advance(0.1)
	revert_playback.revert()

	for child in revert_root.get_children():
		assert_almost_eq(child.position.x, 0.0, 0.01, "revert() on a Group should return every started item to its initial value")
	assert_eq(revert_playback.state, AnimaPlayback.State.CANCELLED)

func test_forward_speed_applies_only_when_playing_forward():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0
	motion.forward_speed = 4.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.05)

	assert_gt(node.position.x, 15.0, "forward_speed should scale the forward run")
	playback.cancel()

func test_reverse_speed_applies_only_when_playing_backward():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.from_value = 0.0
	motion.to_value = 100.0
	motion.duration = 1.0
	motion.reverse_speed = 4.0

	var node := Node2D.new()
	autofree(node)
	var playback := Anima.play_backwards(motion, node)
	playback._advance(0.05)

	# Reversed run starts at 100 and moves toward 0; reverse_speed=4x should
	# already have covered much more ground than the default 1x would.
	assert_lt(node.position.x, 85.0, "reverse_speed should scale the reversed run")
	playback.cancel()

func test_forward_speed_does_not_affect_the_reversed_run():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.from_value = 0.0
	motion.to_value = 100.0
	motion.duration = 1.0
	motion.forward_speed = 10.0
	# reverse_speed left at the default 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := Anima.play_backwards(motion, node)
	playback._advance(0.05)

	# At default 1x reverse speed, 0.05s of a 1.0s motion should move only
	# slightly from 100 — nowhere near what 10x forward_speed would produce.
	assert_almost_eq(node.position.x, 95.0, 1.0, "forward_speed must not leak into a reversed run")
	playback.cancel()

func test_changing_speed_scale_mid_flight_does_not_change_authored_duration():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.1)

	playback.speed_scale = 4.0
	for i in range(5):
		playback._advance(0.05)

	assert_eq(motion.duration, 1.0, "the authored duration must never be mutated by a runtime speed change")
	assert_gt(node.position.x, 50.0, "raising speed_scale mid-flight should visibly speed up progress")

func test_reverse_mid_flight_preserves_progress_without_snapping():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.5)
	var value_at_reverse: float = node.position.x
	assert_almost_eq(value_at_reverse, 50.0, 1.0, "sanity: halfway through a linear motion")

	playback.reverse()

	assert_almost_eq(node.position.x, value_at_reverse, 0.5, "reverse() must not snap to either end")

## The specific trajectory a reversed run takes is Phase 10's established
## reversal contract (tech-spec.md's Key technical decisions) — reversing
## replays the full captured range from its own start, it is not a
## continuous mirror of the exact mid-flight value. This test covers what
## Phase 11 actually adds: repeated reverse() calls keep correctly
## alternating which speed multiplier is selected.
func test_reversing_repeatedly_keeps_alternating_the_selected_direction():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback._advance(0.1)
	assert_false(playback._is_reversed, "starts forward")

	playback.reverse()
	assert_true(playback._is_reversed, "first reverse() should select reverse_speed")
	playback._advance(0.1) # let the freshly reversed instance capture a value

	playback.reverse()
	assert_false(playback._is_reversed, "second reverse() should select forward_speed again")
	playback._advance(0.1)

	playback.reverse()
	assert_true(playback._is_reversed, "a third reverse() should alternate back to reverse_speed")
	playback.cancel()

func test_group_nested_in_sequence_composes_speed_across_both_levels():
	var root: Node = add_child_autofree(Node.new())
	for i in 3:
		root.add_child(Node2D.new())

	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = AnimaPropertyMotion.new()
	group.item_motion.target_property = NodePath("position:x")
	group.item_motion.to_value = 10.0
	group.item_motion.duration = 1.0
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	group.speed = 2.0

	var sequence := AnimaSequence.new()
	sequence.children = [group]

	var baseline_root: Node = add_child_autofree(Node.new())
	for i in 3:
		baseline_root.add_child(Node2D.new())
	var baseline_group := AnimaGroupMotion.new()
	baseline_group.target_collection = AnimaTargetCollection.new()
	baseline_group.item_motion = AnimaPropertyMotion.new()
	baseline_group.item_motion.target_property = NodePath("position:x")
	baseline_group.item_motion.to_value = 10.0
	baseline_group.item_motion.duration = 1.0
	baseline_group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	# no group.speed multiplier — this is the 1x-group-speed baseline

	var scaled_playback := AnimaPlayback.new(sequence, root)
	scaled_playback.speed_scale = 3.0
	var baseline_playback := AnimaPlayback.new(baseline_group, baseline_root)

	scaled_playback._advance(0.05)
	baseline_playback._advance(0.05)

	# The scaled playback runs at group.speed (2x) * playback.speed_scale (3x)
	# = 6x the baseline's 1x-group / 1x-playback rate.
	for i in root.get_child_count():
		assert_almost_eq(
			root.get_child(i).position.x,
			baseline_root.get_child(i).position.x * 6.0,
			0.5,
			"nested group speed and playback speed_scale should compose multiplicatively"
		)
	scaled_playback.cancel()
	baseline_playback.cancel()

func _settle_frame_count(speed: float) -> int:
	var playback := _make_spring_playback(100.0)
	playback.motion.speed = speed
	playback.motion.ease.spring_completion_mode = AnimaEase.SpringCompletionMode.STRICTLY_SETTLED

	var frames := 0
	while playback.state != AnimaPlayback.State.FINISHED and frames < 6000:
		playback._advance(1.0 / 60.0)
		frames += 1
	return frames

func test_doubling_spring_speed_halves_settle_time():
	var frames_at_1x := _settle_frame_count(1.0)
	var frames_at_2x := _settle_frame_count(2.0)

	assert_almost_eq(float(frames_at_2x), float(frames_at_1x) / 2.0, float(frames_at_1x) * 0.15, "2x speed should settle in roughly half the frames")

func test_halving_spring_speed_doubles_settle_time():
	var frames_at_1x := _settle_frame_count(1.0)
	var frames_at_half := _settle_frame_count(0.5)

	assert_almost_eq(float(frames_at_half), float(frames_at_1x) * 2.0, float(frames_at_1x) * 0.3, "0.5x speed should settle in roughly double the frames")

func test_step_advances_a_manually_constructed_playback_with_no_runtime():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	assert_null(playback._runtime, "a directly constructed playback is not tracked by AnimaRuntime")

	for i in range(10):
		playback.step(0.1)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_step_respects_effective_speed():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(motion, node)
	playback.speed_scale = 2.0
	playback.step(0.25)

	assert_almost_eq(node.position.x, 50.0, 0.01, "step() should scale by speed_scale the same way the automatic path does")
	playback.cancel()

func test_with_speed_also_applies_when_playing_backwards():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.from_value = 0.0
	motion.to_value = 10.0
	motion.duration = 1.0
	motion.with_speed(4.0)

	var node := Node2D.new()
	autofree(node)
	var playback := Anima.play_backwards(motion, node)
	playback._advance(0.05)

	assert_lt(node.position.x, 10.0)
	assert_gt(node.position.x, 6.0, "4x speed should already be well on its way back after one short frame")
	playback.cancel()
