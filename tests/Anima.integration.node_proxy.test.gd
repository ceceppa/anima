extends "res://addons/gut/test.gd"

func test_to_animates_the_node_the_same_way_anima_play_would():
	var node: Node2D = add_child_autofree(Node2D.new())

	var playback := Anima.of(node).to(NodePath("position:x"), 100.0, 0.5)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_transition_to_animates_multiple_properties_together():
	var node: Node2D = add_child_autofree(Node2D.new())

	var playback := Anima.of(node).transition_to({
		NodePath("position:x"): 100.0,
		NodePath("modulate:a"): 0.5,
	}, 0.5)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.5, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_enter_fades_the_node_in():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.modulate.a = 0.0

	var playback := Anima.of(node).enter()
	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_exit_fades_the_node_out():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.modulate.a = 1.0

	var playback := Anima.of(node).exit()
	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
