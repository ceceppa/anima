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

	var parallel := AnimaParallel.new()
	parallel.children = [
		_make_child("position:x", 10.0, 0.5),
		_make_child("position:y", 20.0, 0.5),
	]

	var playback := AnimaPlayback.new(parallel, node)
	playback._advance(0.1)

	assert_gt(node.position.x, 0.0)
	assert_gt(node.position.y, 0.0)

func test_default_policy_finishes_only_once_every_child_finished():
	var node := Node2D.new()
	autofree(node)

	var parallel := AnimaParallel.new()
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

	var parallel := AnimaParallel.new()
	parallel.completion_policy = AnimaParallel.CompletionPolicy.FIRST_CHILD
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
	var parallel := AnimaParallel.new()
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

	var parallel := AnimaParallel.new()
	parallel.completion_policy = AnimaParallel.CompletionPolicy.NAMED_CHILD
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

	var parallel := AnimaParallel.new()
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
