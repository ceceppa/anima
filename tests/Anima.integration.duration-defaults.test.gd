extends "res://addons/gut/test.gd"

var _original_default_duration: float

func before_each() -> void:
	_original_default_duration = Anima.default_duration

func after_each() -> void:
	Anima.default_duration = _original_default_duration

func test_omitted_duration_uses_the_attached_behaviours_default():
	var node: Node2D = add_child_autofree(Node2D.new())
	var behaviour := AnimaBehaviour.new()
	behaviour.default_duration = 0.5
	Anima.attach_behaviour(node, behaviour)

	var playback := Anima.play(Anima.on(node).position(Vector2(100.0, 0.0)), node)
	for i in range(10):
		playback._advance(0.02) # 0.2s in — should still be running under the 0.5s behaviour default
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	for i in range(20):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 100.0, 0.01)

func test_omitted_duration_with_no_behaviour_falls_back_to_the_global_default():
	var node: Node2D = add_child_autofree(Node2D.new())
	Anima.default_duration = 0.4

	var playback := Anima.play(Anima.on(node).position(Vector2(100.0, 0.0)), node)
	for i in range(15):
		playback._advance(0.02) # 0.3s in — should still be running under the 0.4s global default
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	for i in range(10):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 100.0, 0.01)

func test_explicit_with_duration_wins_over_both_defaults():
	var node: Node2D = add_child_autofree(Node2D.new())
	var behaviour := AnimaBehaviour.new()
	behaviour.default_duration = 5.0
	Anima.attach_behaviour(node, behaviour)
	Anima.default_duration = 5.0

	var motion := Anima.on(node).position(Vector2(100.0, 0.0))
	motion.with_duration(0.1)
	var playback := Anima.play(motion, node)
	for i in range(6):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the explicit 0.1s duration should win over both 5.0s defaults")
	assert_almost_eq(node.position.x, 100.0, 0.01)

func test_changing_the_default_after_authoring_but_before_playing_still_applies():
	var node: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(node).position(Vector2(100.0, 0.0)) # authored while the default is whatever it currently is

	Anima.default_duration = 0.2 # changed before this motion ever plays

	var playback := Anima.play(motion, node)
	for i in range(9):
		playback._advance(0.02)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	for i in range(2):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the default in effect when the motion actually starts should apply, not the one at authoring time")
