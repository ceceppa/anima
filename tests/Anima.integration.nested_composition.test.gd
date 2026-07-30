extends "res://addons/gut/test.gd"

func _make_sequence(ease_kind: AnimaEase.Kind) -> AnimaSequence:
	var a := AnimaPropertyMotion.new()
	a.target_property = NodePath("position:x")
	a.to_value = 10.0
	a.duration = 0.5
	a.ease = AnimaEase.new()
	a.ease.kind = ease_kind

	var b := AnimaPropertyMotion.new()
	b.target_property = NodePath("position:y")
	b.to_value = 20.0
	b.duration = 0.5
	b.ease = AnimaEase.new()
	b.ease.kind = ease_kind

	var parallel := AnimaParallel.new()
	parallel.children = [a, b]

	var c := AnimaPropertyMotion.new()
	c.target_property = NodePath("modulate:a")
	c.to_value = 0.0
	c.duration = 0.5
	c.ease = AnimaEase.new()
	c.ease.kind = ease_kind

	var sequence := AnimaSequence.new()
	sequence.children = [parallel, c]
	return sequence

func test_parallel_pair_runs_concurrently_then_third_motion_follows():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.modulate = Color(1, 1, 1, 1)

	var sequence := _make_sequence(AnimaEase.Kind.LINEAR)
	var playback := Anima.play(sequence, node)

	# Partway through the parallel pair: both moving concurrently, third untouched.
	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_gt(node.position.x, 0.0)
	assert_lt(node.position.x, 10.0)
	assert_gt(node.position.y, 0.0)
	assert_lt(node.position.y, 20.0)
	assert_eq(node.modulate.a, 1.0)

	# The parallel pair finishes: third still hasn't started.
	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(node.modulate.a, 1.0)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	# Now the third motion runs and the whole sequence completes.
	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_lt(node.modulate.a, 1.0)
	assert_gt(node.modulate.a, 0.0)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_linear_vs_non_linear_easing_produce_different_value_over_time():
	var node_linear: Node2D = add_child_autofree(Node2D.new())
	var node_eased: Node2D = add_child_autofree(Node2D.new())

	var playback_linear := Anima.play(_make_sequence(AnimaEase.Kind.LINEAR), node_linear)
	var playback_eased := Anima.play(_make_sequence(AnimaEase.Kind.SINE), node_eased)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)

	assert_ne(node_linear.position.x, node_eased.position.x)
	assert_ne(node_linear.position.y, node_eased.position.y)

	# Neither playback ran to completion (the comparison only needs a midpoint) —
	# cancel both so they don't linger as active playbacks targeting freed nodes.
	playback_linear.cancel()
	playback_eased.cancel()
