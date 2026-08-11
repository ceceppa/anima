extends "res://addons/gut/test.gd"

func test_estimate_duration_reports_fixed_kind_and_formula_value():
	var repeat := _AnimaRepeat.new()
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

	var repeat := _AnimaRepeat.new()
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

	var repeat := _AnimaRepeat.new()
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

	var repeat := _AnimaRepeat.new()
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

func test_negative_count_reports_infinite_duration():
	var repeat := _AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.2
	repeat.child = child
	repeat.count = -1

	var result := repeat.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.INFINITE)

func test_negative_count_never_finishes_on_its_own():
	var node := Node2D.new()
	autofree(node)

	var repeat := _AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.1
	repeat.child = child
	repeat.count = -1

	var playback := AnimaPlayback.new(repeat, node)
	for i in range(200):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.PLAYING, "an indefinite repeat should keep playing indefinitely")
	playback.cancel()

func test_reversing_a_finished_repeat_returns_to_start_and_repeats_the_same_number_of_times():
	var node := Node2D.new()
	autofree(node)
	node.position.x = 0.0

	var repeat := _AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.from_value = 0.0 # explicit, so every repetition behaves the same regardless of accumulated position
	child.to_value = 10.0
	child.duration = 0.1
	repeat.child = child
	repeat.count = 2

	var playback := AnimaPlayback.new(repeat, node)
	for i in range(20):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	for i in range(9):
		playback._advance(0.02)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED, "should still be repeating the reversed motion")

	for i in range(20):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 0.0, 0.01, "reversing a repeat should return to where it actually started")

## Regression: reversing a repeated *relative* child (move_by-style) used to
## replay the same captured absolute segment every repetition — snapping
## back to the same starting point and re-animating the identical stretch
## instead of continuing further back, the way the forward relative repeat
## keeps continuing forward.
func test_reversing_a_relative_repeat_continues_backward_through_each_repetition():
	var node := Node2D.new()
	autofree(node)
	node.position.x = 0.0

	var repeat := _AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.is_relative = true # move_by-style — from_value captured live each repetition
	child.duration = 0.1
	repeat.child = child
	repeat.count = 2

	var playback := AnimaPlayback.new(repeat, node)
	for i in range(20):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 20.0, 0.01, "sanity: two +10 relative repetitions should land at 20")

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	for i in range(5): # finishes the first reversed repetition (0.1s)
		playback._advance(0.02)
	var after_first_reversed_leg := node.position.x
	assert_almost_eq(after_first_reversed_leg, 10.0, 0.5, "sanity: the first reversed repetition should land back at 10")

	playback._advance(0.02) # one frame into the second reversed repetition
	assert_lt(node.position.x, after_first_reversed_leg + 0.01, "the second reversed repetition should keep heading toward 0, not snap back up to 20 and replay the same segment")

	for i in range(19):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 0.0, 0.01, "reversing a relative repeat should continue backward through both repetitions, landing at the true start, not repeat the same segment twice")

func test_reversing_an_indefinite_repeat_does_not_error():
	var node := Node2D.new()
	autofree(node)

	var repeat := _AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.1
	repeat.child = child
	repeat.count = -1

	var playback := AnimaPlayback.new(repeat, node)
	for i in range(10):
		playback._advance(0.02)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	playback.cancel()

func test_reversing_an_alternating_repeat_reverses_the_currently_active_direction():
	var node := Node2D.new()
	autofree(node)
	node.position.x = 0.0

	var repeat := _AnimaRepeat.new()
	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.from_value = 0.0
	child.to_value = 10.0
	child.duration = 0.2
	repeat.child = child
	repeat.count = 3
	repeat.alternate = true

	var playback := AnimaPlayback.new(repeat, node)
	# First repetition (forward, 0 -> 10) finishes; second (alternated, 10 -> 0) is under way.
	for i in range(13):
		playback._advance(0.02)
	var mid_second_repetition_x: float = node.position.x
	assert_lt(mid_second_repetition_x, 10.0, "second, alternated repetition should be moving back towards 0")

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	assert_almost_eq(node.position.x, mid_second_repetition_x, 0.01, "reversing should not jump the value")

	for i in range(10):
		playback._advance(0.02)
	assert_almost_eq(node.position.x, 10.0, 0.01, "reversing the alternated (backward) leg should head back to 10")
