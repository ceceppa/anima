extends "res://addons/gut/test.gd"

func test_race_plays_through_anima_and_completes_on_fastest_child():
	var node: Node2D = add_child_autofree(Node2D.new())

	var fast := AnimaPropertyMotion.new()
	fast.target_property = NodePath("position:x")
	fast.to_value = 10.0
	fast.duration = 0.2

	var slow := AnimaPropertyMotion.new()
	slow.target_property = NodePath("position:y")
	slow.to_value = 20.0
	slow.duration = 1.0

	var race := _AnimaRace.new()
	race.children = [fast, slow]

	var playback := Anima.play(race, node)

	simulate(AnimaRuntime.get_singleton(), 15, 1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_lt(node.position.y, 20.0)
