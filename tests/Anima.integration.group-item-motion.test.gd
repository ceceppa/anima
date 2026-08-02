extends "res://addons/gut/test.gd"

func _make_children_collection() -> AnimaTargetCollection:
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	return collection

func test_each_resolved_target_independently_receives_the_item_motion():
	var root := Node.new()
	add_child_autofree(root)
	var a := Node2D.new()
	var b := Node2D.new()
	root.add_child(a)
	root.add_child(b)
	a.position.x = 0.0
	b.position.x = 100.0

	var group := AnimaGroupMotion.new()
	group.target_collection = _make_children_collection()
	group.item_motion = Anima.item().move_by(Vector2(10.0, 0.0), 0.1)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var playback := Anima.play(group, root)
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(a.position.x, 10.0, 0.01, "each item's own move_by should start from its own actual position")
	assert_almost_eq(b.position.x, 110.0, 0.01, "each item's own move_by should start from its own actual position")

func test_replaying_the_same_group_animates_the_current_resolved_targets():
	var root := Node.new()
	add_child_autofree(root)
	var first := Node2D.new()
	root.add_child(first)

	var group := AnimaGroupMotion.new()
	group.target_collection = _make_children_collection()
	group.item_motion = Anima.item().opacity(0.0, 0.05)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var first_playback := Anima.play(group, root)
	for i in range(10):
		first_playback._advance(1.0 / 60.0)
	assert_almost_eq(first.modulate.a, 0.0, 0.01)

	var second := Node2D.new()
	root.add_child(second)
	second.modulate.a = 1.0

	var second_playback := Anima.play(group, root)
	for i in range(10):
		second_playback._advance(1.0 / 60.0)

	assert_almost_eq(second.modulate.a, 0.0, 0.01, "replaying the same group resource should reach the newly-added child too")

func test_the_same_item_motion_resource_is_reusable_across_different_target_collections():
	var first_root := Node.new()
	add_child_autofree(first_root)
	var first_child := Node2D.new()
	first_root.add_child(first_child)

	var second_root := Node.new()
	add_child_autofree(second_root)
	var second_child := Node2D.new()
	second_root.add_child(second_child)

	var shared_item_motion := Anima.item().opacity(0.2, 0.05)

	var first_group := AnimaGroupMotion.new()
	first_group.target_collection = _make_children_collection()
	first_group.item_motion = shared_item_motion
	first_group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var second_group := AnimaGroupMotion.new()
	second_group.target_collection = _make_children_collection()
	second_group.item_motion = shared_item_motion
	second_group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var first_playback := Anima.play(first_group, first_root)
	var second_playback := Anima.play(second_group, second_root)
	for i in range(10):
		first_playback._advance(1.0 / 60.0)
		second_playback._advance(1.0 / 60.0)

	assert_almost_eq(first_child.modulate.a, 0.2, 0.01)
	assert_almost_eq(second_child.modulate.a, 0.2, 0.01)

func test_reversing_a_group_using_an_item_motion_factory_replays_the_recorded_sequence_in_reverse_order():
	var root := Node.new()
	add_child_autofree(root)
	var a := Node2D.new()
	var b := Node2D.new()
	root.add_child(a)
	root.add_child(b)

	var group := AnimaGroupMotion.new()
	group.target_collection = _make_children_collection()
	group.item_motion = Anima.item().position(Vector2(100.0, 0.0), 0.05)
	group.playback_mode = AnimaGroupMotion.PlaybackMode.SEQUENTIAL
	group.reverse_order_policy = AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION

	var playback := Anima.play(group, root)
	for i in range(20):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	var forward_order: Array[Node] = []
	for entry in playback._instance.execution_record.entries:
		forward_order.append(entry.target)

	playback.reverse()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING, "reversing should resume playback through the recorded run")

	var reversed_order: Array[Node] = []
	for entry in playback._instance.execution_record.entries:
		reversed_order.append(entry.target)
	reversed_order.reverse()
	assert_eq(forward_order, reversed_order, "a group built with Anima.item() should reverse its recorded order exactly like a hand-built item motion")

	for i in range(20):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
