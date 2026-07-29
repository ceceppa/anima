extends "res://addons/gut/test.gd"

func test_repeat_plays_through_anima_and_completes():
	var node: Node2D = add_child_autofree(Node2D.new())

	var child := AnimaPropertyMotion.new()
	child.target_property = NodePath("position:x")
	child.to_value = 10.0
	child.duration = 0.2

	var repeat := AnimaRepeat.new()
	repeat.child = child
	repeat.count = 2

	var playback := Anima.play(repeat, node)

	simulate(AnimaRuntime.get_singleton(), 30, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
