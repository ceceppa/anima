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
