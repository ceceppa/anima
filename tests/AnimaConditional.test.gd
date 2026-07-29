extends "res://addons/gut/test.gd"

func _make_leaf(property: String, to_value: float, duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property)
	motion.to_value = to_value
	motion.duration = duration
	return motion

func test_compile_time_true_condition_plays_when_true_branch():
	var conditional := AnimaConditional.new()
	conditional.resolution_timing = AnimaConditional.ResolutionTiming.COMPILE_TIME
	conditional.condition = func(): return true
	conditional.when_true = _make_leaf("position:x", 10.0, 0.3)
	conditional.when_false = _make_leaf("position:y", 20.0, 0.3)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(conditional, node)

	for i in range(3):
		playback._advance(0.1)

	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(node.position.y, 0.0)

func test_compile_time_false_condition_plays_when_false_branch():
	var conditional := AnimaConditional.new()
	conditional.resolution_timing = AnimaConditional.ResolutionTiming.COMPILE_TIME
	conditional.condition = func(): return false
	conditional.when_true = _make_leaf("position:x", 10.0, 0.3)
	conditional.when_false = _make_leaf("position:y", 20.0, 0.3)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(conditional, node)

	for i in range(3):
		playback._advance(0.1)

	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(node.position.x, 0.0)

func test_runtime_resolution_reports_dynamic_before_playing():
	var conditional := AnimaConditional.new()
	conditional.condition = func(): return true
	conditional.when_true = _make_leaf("position:x", 10.0, 0.3)
	conditional.when_false = _make_leaf("position:y", 20.0, 0.5)

	var result := conditional.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.DYNAMIC)

func test_runtime_resolution_plays_the_selected_branch_and_completes_with_it():
	var conditional := AnimaConditional.new()
	conditional.condition = func(): return false
	conditional.when_true = _make_leaf("position:x", 10.0, 1.0)
	conditional.when_false = _make_leaf("position:y", 20.0, 0.3)

	var node := Node2D.new()
	autofree(node)
	var playback := AnimaPlayback.new(conditional, node)

	for i in range(2):
		playback._advance(0.1)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(node.position.x, 0.0)
