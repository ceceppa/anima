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

func test_each_childs_own_on_started_and_on_completed_fire_as_it_runs():
	var node := Node2D.new()
	autofree(node)

	var first := _make_child("position:x", 10.0, 0.2)
	var first_started := [0]
	var first_completed := [0]
	first.on_started_callback = func(): first_started[0] += 1
	first.on_completed_callback = func(): first_completed[0] += 1

	var second := _make_child("position:y", 10.0, 0.2)
	var second_started := [0]
	second.on_started_callback = func(): second_started[0] += 1

	var sequence := AnimaSequence.new()
	sequence.children = [first, second]

	var playback := AnimaPlayback.new(sequence, node)
	playback._advance(0.0) # first advance is what actually starts the first child
	assert_eq(first_started[0], 1, "the first child should have started on the first advance")
	assert_eq(second_started[0], 0, "the second child should not have started yet")
	assert_eq(first_completed[0], 0)

	for i in range(3):
		playback._advance(0.1)

	assert_eq(first_completed[0], 1, "the first child should have completed exactly once")
	assert_eq(second_started[0], 1, "the second child should have started once the first finished")

func test_negative_delay_overlaps_with_previous_child():
	var node := Node2D.new()
	autofree(node)

	var overlap_child := _make_child("position:y", 20.0, 0.5)
	overlap_child.delay = -0.2

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.5),
		overlap_child,
	]

	var playback := AnimaPlayback.new(sequence, node)

	for i in range(2):
		playback._advance(0.1)
	assert_eq(node.position.y, 0.0, "overlap child should not have started yet at 0.2s")

	playback._advance(0.1)
	assert_gt(node.position.y, 0.0, "overlap child should have started at 0.3s, before the first child's 0.5s end")
	assert_lt(node.position.x, 10.0, "first child should still be running while the overlap child plays")

func test_positive_delay_waits_after_previous_child_ends():
	var node := Node2D.new()
	autofree(node)

	var delayed_child := _make_child("position:y", 20.0, 0.3)
	delayed_child.delay = 0.2

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.3),
		delayed_child,
	]

	var playback := AnimaPlayback.new(sequence, node)

	for i in range(4):
		playback._advance(0.1)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_eq(node.position.y, 0.0, "delayed child should still be waiting out its 0.2s gap after the first child ended")

	playback._advance(0.1)
	assert_gt(node.position.y, 0.0, "delayed child should start once its 0.2s gap after the first child's end has elapsed")

func test_after_previous_starts_offsets_from_predecessor_start_not_end():
	var node := Node2D.new()
	autofree(node)

	var offset_child := _make_child("position:y", 20.0, 0.3)
	offset_child.delay = 0.2
	offset_child.delay_basis = AnimaMotion.DelayBasis.AFTER_PREVIOUS_STARTS

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 1.0),
		offset_child,
	]

	var playback := AnimaPlayback.new(sequence, node)

	playback._advance(0.1)
	assert_eq(node.position.y, 0.0, "offset child should not have started before 0.2s")

	playback._advance(0.1)
	assert_gt(node.position.y, 0.0, "offset child should start 0.2s after the first child's start, independent of its 1.0s duration")
	assert_lt(node.position.x, 10.0, "first child (1.0s) is still far from finishing")

func test_first_child_uses_only_its_own_delay_from_sequence_start():
	var node := Node2D.new()
	autofree(node)

	var first_child := _make_child("position:x", 10.0, 0.5)
	first_child.delay = 0.2

	var sequence := AnimaSequence.new()
	sequence.children = [first_child]

	var playback := AnimaPlayback.new(sequence, node)

	playback._advance(0.1)
	assert_eq(node.position.x, 0.0, "first child should wait out its own delay before starting")

	playback._advance(0.15)
	assert_gt(node.position.x, 0.0, "first child should have started once its own delay elapsed, with no predecessor involved")

func test_estimate_duration_sums_fixed_children():
	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.3),
		_make_child("position:y", 20.0, 0.5),
	]

	var result := sequence.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_almost_eq(result.seconds, 0.8, 0.0001)

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

func test_reversing_a_finished_sequence_returns_every_child_to_its_start_value():
	var node := Node2D.new()
	autofree(node)

	var sequence := AnimaSequence.new()
	sequence.children = [
		_make_child("position:x", 10.0, 0.2),
		_make_child("position:y", 20.0, 0.2),
	]

	var playback := AnimaPlayback.new(sequence, node)
	for i in range(4):
		playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 10.0, 0.01)
	assert_almost_eq(node.position.y, 20.0, 0.01)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	for i in range(4):
		playback._advance(0.1)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(node.position.x, 0.0, 0.01, "reversing a sequence should return every child to its starting value")
	assert_almost_eq(node.position.y, 0.0, 0.01, "reversing a sequence should return every child to its starting value")

func test_completing_a_sequence_fires_each_not_yet_started_childs_on_started_and_on_completed():
	var node := Node2D.new()
	autofree(node)

	var first := _make_child("position:x", 10.0, 0.5)
	var second := _make_child("position:y", 20.0, 0.5)
	var second_started := [0]
	var second_completed := [0]
	second.on_started_callback = func(): second_started[0] += 1
	second.on_completed_callback = func(): second_completed[0] += 1

	var sequence := AnimaSequence.new()
	sequence.children = [first, second]

	var playback := AnimaPlayback.new(sequence, node)
	assert_eq(second_started[0], 0, "the second child should not have started yet")

	playback.complete()

	assert_eq(second_started[0], 1, "complete() should still start the not-yet-started child before ending it")
	assert_eq(second_completed[0], 1)
	assert_almost_eq(node.position.y, 20.0, 0.01)
