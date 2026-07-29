extends "res://addons/gut/test.gd"

func _make_leaf(property: String, to_value: float, duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property)
	motion.to_value = to_value
	motion.duration = duration
	return motion

func test_conditional_plays_through_anima_and_completes_with_selected_branch():
	var node: Node2D = add_child_autofree(Node2D.new())

	var conditional := AnimaConditional.new()
	conditional.condition = func(): return true
	conditional.when_true = _make_leaf("position:x", 10.0, 0.3)
	conditional.when_false = _make_leaf("position:y", 20.0, 1.0)

	var playback := Anima.play(conditional, node)

	simulate(AnimaRuntime.get_singleton(), 20, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(node.position.y, 0.0)

func test_sequence_containing_runtime_conditional_reports_dynamic_duration():
	var conditional := AnimaConditional.new()
	conditional.condition = func(): return true
	conditional.when_true = _make_leaf("position:x", 10.0, 0.3)
	conditional.when_false = _make_leaf("position:y", 20.0, 0.5)

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_leaf("modulate:a", 0.0, 0.2),
		conditional,
	]

	var result := sequence.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.DYNAMIC)
