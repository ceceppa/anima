extends "res://addons/gut/test.gd"

func _make_child(property: String, to_value: float, duration: float, display_name: String = "") -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property)
	motion.to_value = to_value
	motion.duration = duration
	motion.display_name = display_name
	return motion

func test_children_start_immediately_and_run_concurrently():
	var node := Node2D.new()
	autofree(node)

	var parallel := _AnimaParallel.new()
	parallel.children = [
		_make_child("position:x", 10.0, 0.5),
		_make_child("position:y", 20.0, 0.5),
	]

	var playback := AnimaPlayback.new(parallel, node)
	playback._advance(0.1)

	assert_gt(node.position.x, 0.0)
	assert_gt(node.position.y, 0.0)

func test_a_childs_own_delay_offsets_it_from_the_groups_own_start():
	var node := Node2D.new()
	autofree(node)

	var immediate := _make_child("position:x", 10.0, 0.2)
	var delayed := _make_child("position:y", 10.0, 0.2)
	delayed.delay = 0.2

	var parallel := _AnimaParallel.new()
	parallel.children = [immediate, delayed]

	var playback := AnimaPlayback.new(parallel, node)
	playback._advance(0.1)
	assert_gt(node.position.x, 0.0, "the undelayed child should already be moving")
	assert_eq(node.position.y, 0.0, "the delayed child should not have started yet")

	playback._advance(0.15) # elapsed now 0.25s, past delayed's 0.2s delay
	assert_gt(node.position.y, 0.0, "the delayed child should have started once its own delay elapsed")

func test_two_children_with_different_delays_each_offset_from_the_groups_own_start():
	var node := Node2D.new()
	autofree(node)

	var a := _make_child("position:x", 10.0, 0.1)
	a.delay = 0.1
	var b := _make_child("position:y", 10.0, 0.1)
	b.delay = 0.2

	var parallel := _AnimaParallel.new()
	parallel.children = [a, b]

	var playback := AnimaPlayback.new(parallel, node)
	playback._advance(0.15) # past a's delay (0.1), before b's (0.2)
	assert_gt(node.position.x, 0.0, "a should have started once its own 0.1s delay elapsed")
	assert_eq(node.position.y, 0.0, "b should not have started yet — its delay is 0.2s from the group's own start")

	playback._advance(0.1) # elapsed now 0.25s, past b's delay too
	assert_gt(node.position.y, 0.0, "b should have started once its own 0.2s delay elapsed")

func test_completing_a_parallel_starts_and_finishes_a_still_delayed_child():
	var node := Node2D.new()
	autofree(node)

	var immediate := _make_child("position:x", 10.0, 0.2)
	var delayed := _make_child("position:y", 20.0, 0.2)
	delayed.delay = 5.0

	var parallel := _AnimaParallel.new()
	parallel.children = [immediate, delayed]

	var playback := AnimaPlayback.new(parallel, node)
	playback._advance(0.05)
	assert_eq(node.position.y, 0.0, "the delayed child should not have started yet")

	playback.complete()

	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01, "complete() should still start and finish the delayed child")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_each_childs_own_on_started_fires_immediately_and_on_completed_fires_once():
	var node := Node2D.new()
	autofree(node)

	var a := _make_child("position:x", 10.0, 0.2)
	var a_started := [0]
	var a_completed := [0]
	a.on_started_callback = func(): a_started[0] += 1
	a.on_completed_callback = func(): a_completed[0] += 1

	var b := _make_child("position:y", 10.0, 0.4)
	var b_started := [0]
	var b_completed := [0]
	b.on_started_callback = func(): b_started[0] += 1
	b.on_completed_callback = func(): b_completed[0] += 1

	var parallel := _AnimaParallel.new()
	parallel.children = [a, b]

	var playback := AnimaPlayback.new(parallel, node)
	assert_eq(a_started[0], 1, "both children start together at construction")
	assert_eq(b_started[0], 1)

	for i in range(3):
		playback._advance(0.1)
	assert_eq(a_completed[0], 1, "a should have finished (0.2s < 0.3s elapsed)")
	assert_eq(b_completed[0], 0, "b should not have finished yet (0.3s < 0.4s)")

	for i in range(2):
		playback._advance(0.1)
	assert_eq(a_completed[0], 1, "a's completed callback should not fire twice")
	assert_eq(b_completed[0], 1)

func test_default_policy_finishes_only_once_every_child_finished():
	var node := Node2D.new()
	autofree(node)

	var parallel := _AnimaParallel.new()
	parallel.children = [
		_make_child("position:x", 10.0, 0.3),
		_make_child("position:y", 20.0, 0.6),
	]

	var playback := AnimaPlayback.new(parallel, node)

	for i in range(4):
		playback._advance(0.1)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	for i in range(2):
		playback._advance(0.1)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_first_child_policy_finishes_as_soon_as_first_child_finishes():
	var node := Node2D.new()
	autofree(node)

	var parallel := _AnimaParallel.new()
	parallel.completion_policy = _AnimaParallel.CompletionPolicy.FIRST_CHILD
	parallel.children = [
		_make_child("position:x", 10.0, 0.3),
		_make_child("position:y", 20.0, 1.0),
	]

	var playback := AnimaPlayback.new(parallel, node)

	for i in range(3):
		playback._advance(0.1)

	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_lt(node.position.y, 20.0)

func test_estimate_duration_reports_longest_fixed_child_by_default():
	var parallel := _AnimaParallel.new()
	parallel.children = [
		_make_child("position:x", 10.0, 0.3),
		_make_child("position:y", 20.0, 0.6),
	]

	var result := parallel.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(result.seconds, 0.6, 0.0001)

func test_named_child_policy_finishes_as_soon_as_named_child_finishes():
	var node := Node2D.new()
	autofree(node)

	var parallel := _AnimaParallel.new()
	parallel.completion_policy = _AnimaParallel.CompletionPolicy.NAMED_CHILD
	parallel.completion_child_name = "decider"
	parallel.children = [
		_make_child("position:x", 10.0, 1.0, "slow"),
		_make_child("position:y", 20.0, 0.3, "decider"),
	]

	var playback := AnimaPlayback.new(parallel, node)

	for i in range(3):
		playback._advance(0.1)

	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_reversing_a_finished_parallel_returns_every_child_to_its_start_value():
	var node := Node2D.new()
	autofree(node)

	var parallel := _AnimaParallel.new()
	parallel.children = [
		_make_child("position:x", 10.0, 0.2),
		_make_child("position:y", 20.0, 0.2),
	]

	var playback := AnimaPlayback.new(parallel, node)
	for i in range(3):
		playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	for i in range(3):
		playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 0.0, 0.01, "reversing a parallel should return every child to its starting value")
	assert_almost_eq(node.position.y, 0.0, 0.01, "reversing a parallel should return every child to its starting value")
	assert_lt(node.position.x, 10.0)
