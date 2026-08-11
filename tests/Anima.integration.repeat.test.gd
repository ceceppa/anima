extends "res://addons/gut/test.gd"

func test_repeat_plays_through_anima_and_completes():
	var node: Node2D = add_child_autofree(Node2D.new())

	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.2

	var repeat := _AnimaRepeat.new()
	repeat.child = child
	repeat.count = 2

	var playback := Anima.play(repeat, node)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_chained_repeat_on_a_convenience_motion_matches_the_direct_repeat_builder():
	var chained_node: Node2D = add_child_autofree(Node2D.new())
	var direct_node: Node2D = add_child_autofree(Node2D.new())

	var chained_motion := Anima.on(chained_node).move_by(Vector2(10.0, 0.0), 0.1).repeat(2)
	var direct_child := AnimaPropertyMotion.new()
	direct_child.target_property = NodePath("position")
	direct_child.to_value = Vector2(10.0, 0.0)
	direct_child.duration = 0.1
	direct_child.is_relative = true
	var direct_motion := Motion.repeat(direct_child, 2)

	var chained_playback := Anima.play(chained_motion, chained_node)
	var direct_playback := Anima.play(direct_motion, direct_node)

	for i in range(20):
		chained_playback._advance(0.02)
		direct_playback._advance(0.02)

	assert_eq(chained_playback.state, AnimaPlayback.State.FINISHED)
	assert_eq(direct_playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(chained_node.position.x, direct_node.position.x, 0.01)
