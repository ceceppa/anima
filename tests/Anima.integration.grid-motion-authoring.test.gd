extends "res://addons/gut/test.gd"

func test_a_grid_motion_applies_its_shared_item_motion_to_every_tiled_target():
	var root := Node.new()
	add_child_autofree(root)
	var cells: Array[Node2D] = []
	for i in 9:
		var cell := Node2D.new()
		root.add_child(cell)
		cells.append(cell)

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN

	var grid := AnimaGridMotion.new()
	grid.target_collection = collection
	grid.grid_dimensions = Vector2i(3, 3)
	grid.item_motion = Anima.item().opacity(0.0, 0.05)
	grid.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	assert_eq(grid.validate(), [])

	var playback := Anima.play(grid, root)
	for i in range(10):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for cell in cells:
		assert_almost_eq(cell.modulate.a, 0.0, 0.01)

func test_the_grid_shorthand_plays_equivalently_to_the_hand_built_approach():
	var hand_built_root := Node.new()
	add_child_autofree(hand_built_root)
	var shorthand_root := Node.new()
	add_child_autofree(shorthand_root)
	for i in 9:
		hand_built_root.add_child(Node2D.new())
		shorthand_root.add_child(Node2D.new())

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var hand_built := AnimaGridMotion.new()
	hand_built.target_collection = collection
	hand_built.grid_dimensions = Vector2i(3, 3)
	hand_built.item_motion = Anima.item().opacity(0.0, 0.05)
	hand_built.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var shorthand_factory := Anima.grid(shorthand_root) \
		.with_dimensions(Vector2i(3, 3)) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05))
	shorthand_factory.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var hand_built_playback := Anima.play(hand_built, hand_built_root)
	var shorthand_playback := shorthand_factory.play()

	for i in range(10):
		hand_built_playback._advance(1.0 / 60.0)
		shorthand_playback._advance(1.0 / 60.0)

	assert_eq(shorthand_playback.state, hand_built_playback.state)
	for i in 9:
		assert_almost_eq(
			(shorthand_root.get_child(i) as Node2D).modulate.a,
			(hand_built_root.get_child(i) as Node2D).modulate.a,
			0.01,
		)

func test_the_grid_factorys_keyframes_shorthand_plays_equivalently_to_a_hand_built_keyframe_item_motion():
	var hand_built_root := Node.new()
	add_child_autofree(hand_built_root)
	var shorthand_root := Node.new()
	add_child_autofree(shorthand_root)
	for i in 4:
		hand_built_root.add_child(Node2D.new())
		shorthand_root.add_child(Node2D.new())

	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var hand_built := AnimaGridMotion.new()
	hand_built.target_collection = collection
	hand_built.grid_dimensions = Vector2i(2, 2)
	hand_built.item_motion = Motion.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}).with_duration(0.1)
	hand_built.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var shorthand_factory := Anima.grid(shorthand_root) \
		.with_dimensions(Vector2i(2, 2)) \
		.keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}, 0.1)
	shorthand_factory.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL

	var hand_built_playback := Anima.play(hand_built, hand_built_root)
	var shorthand_playback := shorthand_factory.play()

	for i in range(10):
		hand_built_playback._advance(1.0 / 60.0)
		shorthand_playback._advance(1.0 / 60.0)

	assert_eq(shorthand_playback.state, hand_built_playback.state)
	for i in 4:
		assert_almost_eq(
			(shorthand_root.get_child(i) as Node2D).modulate.a,
			(hand_built_root.get_child(i) as Node2D).modulate.a,
			0.01,
		)
