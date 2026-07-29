extends "res://addons/gut/test.gd"

func _make_child(property: String, to_value: float, duration: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath(property)
	motion.to_value = to_value
	motion.duration = duration
	return motion

func test_completes_as_soon_as_fastest_child_finishes():
	var node := Node2D.new()
	autofree(node)

	var race := AnimaRace.new()
	race.children = [
		_make_child("position:x", 10.0, 0.2),
		_make_child("position:y", 20.0, 1.0),
	]

	var playback := AnimaPlayback.new(race, node)

	for i in range(9):
		playback._advance(0.02)
	assert_ne(playback.state, AnimaPlayback.State.FINISHED)

	playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_lt(node.position.y, 20.0)

func test_losing_child_stops_changing_after_race_completes():
	var node := Node2D.new()
	autofree(node)

	var race := AnimaRace.new()
	race.children = [
		_make_child("position:x", 10.0, 0.2),
		_make_child("position:y", 20.0, 1.0),
	]

	var playback := AnimaPlayback.new(race, node)

	for i in range(10):
		playback._advance(0.02)
	var y_at_completion: float = node.position.y

	for i in range(10):
		playback._advance(0.02)
	assert_eq(node.position.y, y_at_completion, "losing child should not keep animating after the race completes")

func test_estimate_duration_reports_fixed_kind_and_fastest_value():
	var race := AnimaRace.new()
	race.children = [
		_make_child("position:x", 10.0, 1.0),
		_make_child("position:y", 20.0, 0.4),
		_make_child("modulate:a", 0.0, 2.0),
	]

	var result := race.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(result.seconds, 0.4, 0.0001)
