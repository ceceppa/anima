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
