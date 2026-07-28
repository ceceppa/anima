extends "res://addons/gut/test.gd"

func _make_child(property: String, to_value: float, duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property)
	motion.to_value = to_value
	motion.duration = duration
	return motion

func test_children_run_strictly_one_after_another():
	var node := Node2D.new()
	autofree(node)
	node.modulate = Color(1, 1, 1, 1)

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.5),
		_make_child("position:y", 20.0, 0.5),
		_make_child("modulate:a", 0.0, 0.5),
	]

	var playback := AnimaPlayback.new(sequence, node)

	for i in range(2):
		playback._advance(0.1)
	assert_gt(node.position.x, 0.0)
	assert_eq(node.position.y, 0.0)
	assert_eq(node.modulate.a, 1.0)

	for i in range(3):
		playback._advance(0.1)
	assert_almost_eq(node.position.x, 10.0, 0.01)

	for i in range(2):
		playback._advance(0.1)
	assert_gt(node.position.y, 0.0)
	assert_lt(node.position.y, 20.0)
	assert_eq(node.modulate.a, 1.0)

func test_completes_only_once_last_child_finishes():
	var node := Node2D.new()
	autofree(node)
	node.modulate = Color(1, 1, 1, 1)

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.3),
		_make_child("position:y", 20.0, 0.3),
		_make_child("modulate:a", 0.0, 0.3),
	]

	var playback := AnimaPlayback.new(sequence, node)

	for i in range(6):
		playback._advance(0.1)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	for i in range(3):
		playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

func test_pause_freezes_active_child_and_resume_continues_it():
	var node := Node2D.new()
	autofree(node)

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.5),
		_make_child("position:y", 20.0, 0.5),
	]

	var playback := AnimaPlayback.new(sequence, node)

	for i in range(2):
		playback._advance(0.1)
	var value_before_pause: float = node.position.x

	playback.pause()
	playback._advance(0.5)
	assert_eq(node.position.x, value_before_pause, "paused sequence should not change the active child's property")

	playback.resume()
	for i in range(3):
		playback._advance(0.1)
	assert_almost_eq(node.position.x, 10.0, 0.01)

	for i in range(5):
		playback._advance(0.1)
	assert_almost_eq(node.position.y, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
