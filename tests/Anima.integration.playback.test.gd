extends "res://addons/gut/test.gd"

func test_playing_a_motion_with_no_setup_reaches_end_value():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 100.0
	motion.duration = 1.0

	var playback := Anima.play(motion, node)

	simulate(AnimaRuntime.get_singleton(), 60, 1.0 / 60.0)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_second_motion_on_same_node_plays_independently():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion_a := AnimaPropertyMotion.new()
	motion_a.target_property = NodePath("position:x")
	motion_a.to_value = 100.0
	motion_a.duration = 1.0

	var motion_b := AnimaPropertyMotion.new()
	motion_b.target_property = NodePath("position:y")
	motion_b.to_value = 50.0
	motion_b.duration = 2.0

	var playback_a := Anima.play(motion_a, node)
	var playback_b := Anima.play(motion_b, node)

	simulate(AnimaRuntime.get_singleton(), 120, 1.0 / 60.0)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_eq(playback_a.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.y, 50.0, 0.01)
	assert_eq(playback_b.state, AnimaPlayback.State.FINISHED)

func test_playing_a_sequence_runs_children_in_order_and_completes():
	var node: Node2D = add_child_autofree(Node2D.new())

	var first := AnimaPropertyMotion.new()
	first.target_property = NodePath("position:x")
	first.to_value = 10.0
	first.duration = 0.5

	var second := AnimaPropertyMotion.new()
	second.target_property = NodePath("position:y")
	second.to_value = 20.0
	second.duration = 0.5

	var sequence := AnimaSequence.new()
	sequence.children = [first, second]

	var playback := Anima.play(sequence, node)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(node.position.y, 0.0)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_playing_a_parallel_runs_children_concurrently_and_completes():
	var node: Node2D = add_child_autofree(Node2D.new())

	var first := AnimaPropertyMotion.new()
	first.target_property = NodePath("position:x")
	first.to_value = 10.0
	first.duration = 0.5

	var second := AnimaPropertyMotion.new()
	second.target_property = NodePath("position:y")
	second.to_value = 20.0
	second.duration = 0.5

	var parallel := AnimaParallel.new()
	parallel.children = [first, second]

	var playback := Anima.play(parallel, node)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_gt(node.position.x, 0.0)
	assert_gt(node.position.y, 0.0)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
