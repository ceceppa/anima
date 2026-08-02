extends "res://addons/gut/test.gd"

func test_a_group_built_through_the_public_api_exposes_its_configured_choices():
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	collection.filter = AnimaTargetCollection.Filter.EVEN_ONLY

	var group := Motion.group(collection, Motion.to(NodePath("modulate:a"), 1.0))
	group.playback_mode = AnimaGroupMotion.PlaybackMode.STAGGERED
	group.distribution.stagger_interval = 0.1
	group.order.kind = AnimaGroupOrder.Kind.REVERSE
	group.completion_policy = AnimaGroupMotion.CompletionPolicy.ALL_ITEMS

	assert_eq(group.target_collection, collection)
	assert_eq(group.target_collection.filter, AnimaTargetCollection.Filter.EVEN_ONLY)
	assert_eq(group.playback_mode, AnimaGroupMotion.PlaybackMode.STAGGERED)
	assert_almost_eq(group.distribution.stagger_interval, 0.1, 0.0001)
	assert_eq(group.order.kind, AnimaGroupOrder.Kind.REVERSE)
	assert_eq(group.completion_policy, AnimaGroupMotion.CompletionPolicy.ALL_ITEMS)
	assert_eq(group.validate(), [])

func test_a_group_built_through_the_public_api_plays_through_anima_play():
	var root := Node.new()
	add_child_autofree(root)
	for i in 3:
		root.add_child(Node2D.new())

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN

	var group := Motion.group(collection, Motion.to(NodePath("position:x"), 10.0))
	group.item_motion.duration = 0.1
	group.distribution.stagger_interval = 0.02

	var playback := Anima.play(group, root)

	for i in range(20):
		playback._advance(0.02)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for child in root.get_children():
		assert_almost_eq(child.position.x, 10.0, 0.01)
