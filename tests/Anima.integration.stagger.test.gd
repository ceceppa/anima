extends "res://addons/gut/test.gd"

func _make_targets(count: int) -> Array[Node]:
	var targets: Array[Node] = []
	for i in range(count):
		var node: Node2D = add_child_autofree(Node2D.new())
		targets.append(node)
	return targets

func _make_template(duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = duration
	return motion

func test_stagger_plays_with_no_top_level_target_and_completes():
	var targets := _make_targets(3)
	var stagger := _AnimaStagger.new()
	stagger.targets = targets
	stagger.template = _make_template(0.2)
	stagger.interval = 0.05

	var playback := Anima.play(stagger)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for target in targets:
		assert_almost_eq(target.position.x, 10.0, 0.01)

func test_stagger_reports_fixed_duration_end_to_end():
	var targets := _make_targets(3)
	var stagger := _AnimaStagger.new()
	stagger.targets = targets
	stagger.template = _make_template(0.5)
	stagger.interval = 0.1

	var result := stagger.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(result.seconds, 0.7, 0.0001)
