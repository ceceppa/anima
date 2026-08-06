extends "res://addons/gut/test.gd"

func _play(motion: AnimaMotion, target: Node, frames: int = 10, dt: float = 1.0 / 60.0) -> AnimaPlayback:
	var playback := Anima.play(motion, target)
	for i in range(frames):
		playback._advance(dt)
	return playback

func test_a_motion_resolves_a_value_read_from_the_targets_own_property():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.scale = Vector2(3.0, 3.0)

	var motion := Motion.to(NodePath("position:x"), AnimaValue.target(NodePath("scale:x"))).with_duration(0.1)
	_play(motion, node)

	assert_almost_eq(node.position.x, 3.0, 0.01)

func test_a_motion_resolves_a_value_read_from_a_different_named_node():
	var parent: Node2D = add_child_autofree(Node2D.new())
	var target: Node2D = Node2D.new()
	target.name = "Target"
	parent.add_child(target)
	var source: Node2D = Node2D.new()
	source.name = "Source"
	parent.add_child(source)
	source.position = Vector2(75.0, 0.0)

	var motion := Motion.to(NodePath("position:x"), AnimaValue.node(NodePath("../Source"), NodePath("position:x"))).with_duration(0.1)
	_play(motion, target)

	assert_almost_eq(target.position.x, 75.0, 0.01)

func test_two_targets_using_the_same_dynamic_value_definition_each_resolve_their_own_value():
	var node_a: Node2D = add_child_autofree(Node2D.new())
	node_a.scale = Vector2(2.0, 2.0)
	var node_b: Node2D = add_child_autofree(Node2D.new())
	node_b.scale = Vector2(9.0, 9.0)

	var shared_value := AnimaValue.target(NodePath("scale:x"))
	_play(Motion.to(NodePath("position:x"), shared_value).with_duration(0.1), node_a)
	_play(Motion.to(NodePath("position:x"), shared_value).with_duration(0.1), node_b)

	assert_almost_eq(node_a.position.x, 2.0, 0.01)
	assert_almost_eq(node_b.position.x, 9.0, 0.01)

func test_a_motion_resolves_two_dynamic_values_combined_arithmetically():
	var parent: Node2D = add_child_autofree(Node2D.new())
	var target: Node2D = Node2D.new()
	target.name = "Target"
	parent.add_child(target)
	var source: Node2D = Node2D.new()
	source.name = "Source"
	parent.add_child(source)
	source.scale = Vector2(6.0, 0.0)

	var combined := AnimaValue.constant(2.0).add(AnimaValue.node(NodePath("../Source"), NodePath("scale:x")))
	var motion := Motion.to(NodePath("position:x"), combined).with_duration(0.1)
	_play(motion, target)

	assert_almost_eq(target.position.x, 8.0, 0.01)

func test_a_keyframe_motion_played_through_anima_play_resolves_a_dynamic_stop():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.scale = Vector2(6.0, 0.0)

	var motion := Motion.keyframes({
		"from": {"position:x": 0.0},
		"to": {"position:x": AnimaValue.target(NodePath("scale:x"))},
	}).with_duration(0.1)
	_play(motion, node)

	assert_almost_eq(node.position.x, 6.0, 0.01)

func test_a_grid_motion_played_through_anima_play_resolves_per_item_dynamic_values():
	var container: Node2D = add_child_autofree(Node2D.new())
	var icons: Array[Node] = []
	for i in 4:
		var icon := Node2D.new()
		container.add_child(icon)
		icons.append(icon)

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN

	var grid := AnimaGridMotion.new()
	grid.target_collection = collection
	grid.grid_dimensions = Vector2i(2, 2)
	grid.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	grid.item_motion = AnimaPropertyMotion.new()
	grid.item_motion.target_property = NodePath("position:x")
	grid.item_motion.to_value = AnimaValue.grid_row().multiply(10.0).add(AnimaValue.grid_column())
	grid.item_motion.duration = 0.1

	_play(grid, container)

	assert_almost_eq(icons[0].position.x, 0.0, 0.01)
	assert_almost_eq(icons[1].position.x, 1.0, 0.01)
	assert_almost_eq(icons[2].position.x, 10.0, 0.01)
	assert_almost_eq(icons[3].position.x, 11.0, 0.01)

func test_a_motion_resolves_a_value_read_from_playback_context_data():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := Motion.to(NodePath("position:x"), AnimaValue.context("target_x")).with_duration(0.1)
	var playback := Anima.play(motion, node)
	playback.context_data["target_x"] = 42.0
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.position.x, 42.0, 0.01)
