extends "res://addons/gut/test.gd"

func test_estimate_duration_reports_fixed_kind_and_formula_value():
	var repeat := AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.3
	repeat.child = child
	repeat.count = 3
	repeat.delay_between = 0.1

	var result := repeat.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(result.seconds, 1.1, 0.0001)

func test_repeats_the_child_the_configured_number_of_times():
	var node := Node2D.new()
	autofree(node)

	var repeat := AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.2
	repeat.child = child
	repeat.count = 3

	var playback := AnimaPlayback.new(repeat, node)

	for i in range(29):
		playback._advance(0.02)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_delay_between_waits_before_starting_the_next_repetition():
	var node := Node2D.new()
	autofree(node)

	var repeat := AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.from_value = 0.0
	child.to_value = 10.0
	child.duration = 0.2
	repeat.child = child
	repeat.count = 2
	repeat.delay_between = 0.3

	var playback := AnimaPlayback.new(repeat, node)

	for i in range(10):
		playback._advance(0.02)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	for i in range(14):
		playback._advance(0.02)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED, "should still be waiting out the 0.3s delay between repetitions")

	for i in range(11):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_alternate_reverses_direction_on_the_second_repetition():
	var node := Node2D.new()
	autofree(node)

	var repeat := AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.from_value = 0.0
	child.to_value = 10.0
	child.duration = 0.2
	repeat.child = child
	repeat.count = 3
	repeat.alternate = true

	var playback := AnimaPlayback.new(repeat, node)

	for i in range(10):
		playback._advance(0.02)
	assert_almost_eq(node.position.x, 10.0, 0.01, "first repetition should animate forward, from 0 to 10")

	for i in range(5):
		playback._advance(0.02)
	assert_lt(node.position.x, 10.0, "second repetition should animate backward, from 10 towards 0")

	for i in range(5):
		playback._advance(0.02)
	assert_almost_eq(node.position.x, 0.0, 0.01, "second repetition should finish back at 0")

	for i in range(10):
		playback._advance(0.02)
	assert_almost_eq(node.position.x, 10.0, 0.01, "third repetition should animate forward again, from 0 to 10")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
