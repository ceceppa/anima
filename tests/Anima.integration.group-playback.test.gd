extends "res://addons/gut/test.gd"

func _make_group_with_children(root: Node, count: int, item_duration: float = 0.2) -> AnimaGroupMotion:
	for i in count:
		var child := Node2D.new()
		root.add_child(child)

	var group := AnimaGroupMotion.new()
	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = AnimaPropertyMotion.new()
	group.item_motion.target_property = NodePath("position:x")
	group.item_motion.to_value = 10.0
	group.item_motion.duration = item_duration
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	return group

func test_pausing_and_resuming_a_group_freezes_and_continues_every_item():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group_with_children(root, 3)

	var playback := Anima.play(group, root)
	playback._advance(0.05)
	var frozen_positions: Array[float] = []
	for child in root.get_children():
		frozen_positions.append(child.position.x)

	playback.pause()
	playback._advance(0.05)
	for i in root.get_child_count():
		assert_almost_eq(root.get_child(i).position.x, frozen_positions[i], 0.0001)

	playback.resume()
	playback._advance(0.05)
	for i in root.get_child_count():
		assert_gt(root.get_child(i).position.x, frozen_positions[i])

	playback.cancel()

func test_cancelling_a_group_stops_every_item_where_it_is_and_reports_not_successful():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group_with_children(root, 2)

	var playback := Anima.play(group, root)
	playback._advance(0.05)
	var cancelled_positions: Array[float] = []
	for child in root.get_children():
		cancelled_positions.append(child.position.x)

	watch_signals(playback)
	playback.cancel()

	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_signal_emitted_with_parameters(playback, "finished", [false])

	playback._advance(0.05)
	for i in root.get_child_count():
		assert_almost_eq(root.get_child(i).position.x, cancelled_positions[i], 0.0001)

func test_speed_scale_advances_a_group_faster():
	var normal_root := Node.new()
	add_child_autofree(normal_root)
	var normal_group := _make_group_with_children(normal_root, 1, 1.0)

	var fast_root := Node.new()
	add_child_autofree(fast_root)
	var fast_group := _make_group_with_children(fast_root, 1, 1.0)

	var normal_playback := Anima.play(normal_group, normal_root)
	var fast_playback := Anima.play(fast_group, fast_root)
	fast_playback.speed_scale = 4.0

	normal_playback._advance(0.05)
	fast_playback._advance(0.05)

	assert_gt(fast_root.get_child(0).position.x, normal_root.get_child(0).position.x)

	normal_playback.cancel()
	fast_playback.cancel()

func test_a_target_leaving_the_scene_is_skipped_per_the_invalid_target_policy():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group_with_children(root, 2)
	group.invalid_target_policy = AnimaGroupMotion.InvalidTargetPolicy.SKIP

	var playback := Anima.play(group, root)
	playback._advance(0.05)
	var departing_child := root.get_child(0)
	var remaining_child := root.get_child(1)
	root.remove_child(departing_child)
	departing_child.free()

	for i in range(20):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(remaining_child.position.x, 10.0, 0.01)

func test_reversing_a_finished_group_replays_the_recorded_target_sequence():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group_with_children(root, 3, 0.05)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.SEQUENTIAL
	group.reverse_order_policy = AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION

	var playback := Anima.play(group, root)
	for i in range(20):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	var forward_order: Array[Node] = []
	for entry in playback._instance.execution_record.entries:
		forward_order.append(entry.target)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	var reversed_order: Array[Node] = []
	for entry in playback._instance.execution_record.entries:
		reversed_order.append(entry.target)
	reversed_order.reverse()
	assert_eq(forward_order, reversed_order)

	for i in range(20):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_reversing_a_non_group_playback_reports_an_error():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 10.0
	motion.duration = 0.1
	var node := Node2D.new()
	add_child_autofree(node)

	var playback := Anima.play(motion, node)
	playback.reverse()
	assert_push_error("only defined for a played AnimaGroupMotion")
	playback.cancel()
