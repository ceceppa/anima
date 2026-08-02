extends "res://addons/gut/test.gd"

func _make_group(root: Node) -> AnimaGroupMotion:
	for _index in 3:
		var target := Node2D.new()
		target.modulate.a = 0.0
		root.add_child(target)
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var group := Motion.group(collection, Motion.to(NodePath("modulate:a"), 1.0))
	group.item_motion.duration = 0.1
	group.distribution.stagger_interval = 0.1
	return group

func test_reduced_motion_starts_every_group_target_without_staggering_and_finishes_once():
	var normal_root := Node.new()
	add_child_autofree(normal_root)
	var reduced_root := Node.new()
	add_child_autofree(reduced_root)
	var normal_group := _make_group(normal_root)
	var reduced_group := _make_group(reduced_root)
	var behaviour := AnimaBehaviour.new()
	behaviour.reduced_motion = AnimaBehaviour.ReducedMotion.ENABLED
	Anima.attach_behaviour(reduced_root, behaviour)

	var normal_playback := Anima.play(normal_group, normal_root)
	var reduced_playback := Anima.play(reduced_group, reduced_root)
	watch_signals(normal_playback)
	watch_signals(reduced_playback)
	normal_playback._advance(0.05)
	reduced_playback._advance(0.05)

	assert_eq(normal_root.get_child(1).modulate.a, 0.0)
	for target in reduced_root.get_children():
		assert_gt(target.modulate.a, 0.0)

	for _step in 20:
		normal_playback._advance(0.05)
		reduced_playback._advance(0.05)

	for target in normal_root.get_children():
		assert_almost_eq(target.modulate.a, 1.0, 0.01)
	for target in reduced_root.get_children():
		assert_almost_eq(target.modulate.a, 1.0, 0.01)
	assert_signal_emit_count(normal_playback, "finished", 1)
	assert_signal_emit_count(reduced_playback, "finished", 1)

func test_cancelling_reduced_motion_group_notifies_once():
	var root := Node.new()
	add_child_autofree(root)
	var group := _make_group(root)
	var behaviour := AnimaBehaviour.new()
	behaviour.reduced_motion = AnimaBehaviour.ReducedMotion.ENABLED
	Anima.attach_behaviour(root, behaviour)
	var playback := Anima.play(group, root)
	watch_signals(playback)
	playback._advance(0.05)
	playback.cancel()
	playback.cancel()

	assert_signal_emit_count(playback, "finished", 1)
	assert_signal_emitted_with_parameters(playback, "finished", [false])
