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

func test_grid_then_on_plays_the_grid_then_fades_a_different_node():
	var root := Node.new()
	add_child_autofree(root)
	for i in 4:
		var cell := Node2D.new()
		root.add_child(cell)
	var other: Node2D = add_child_autofree(Node2D.new())
	other.modulate.a = 1.0

	var factory := Anima.grid(root, Vector2i(2, 2)).with_item_motion(Anima.item().opacity(0.0, 0.05))
	# PARALLEL removes stagger timing from the picture — this test is about
	# .then() waiting for the grid step, not about the grid's own schedule.
	factory.motion.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
	var playback: AnimaPlayback = factory.then(Anima.on(other).fade_out(0.05)).play()

	assert_not_null(playback)
	for i in range(2):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(other.modulate.a, 1.0, 0.01, "the fade should not have started until the grid step finished")

	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(other.modulate.a, 0.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_grid_with_on_plays_the_grid_and_a_different_node_together():
	var root := Node.new()
	add_child_autofree(root)
	for i in 4:
		var cell := Node2D.new()
		root.add_child(cell)
	var other: Node2D = add_child_autofree(Node2D.new())

	var playback: AnimaPlayback = Anima.grid(root, Vector2i(2, 2)) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.with(Anima.on(other).move_by(Vector2(20.0, 0.0), 0.05)) \
		.play()

	assert_not_null(playback)
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(other.position.x, 20.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_grid_with_another_grid_factory_directly_plays_both():
	var root_a := Node.new()
	add_child_autofree(root_a)
	var root_b := Node.new()
	add_child_autofree(root_b)
	for i in 4:
		root_a.add_child(Node2D.new())
		root_b.add_child(Node2D.new())

	var playback: AnimaPlayback = Anima.grid(root_a, Vector2i(2, 2)) \
		.with_item_motion(Anima.item().opacity(0.0, 0.05)) \
		.with(
			Anima.grid(root_b, Vector2i(2, 2)) \
				.with_item_motion(Anima.item().opacity(0.0, 0.05))
		) \
		.play()

	assert_not_null(playback)
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for cell in root_a.get_children():
		assert_almost_eq((cell as Node2D).modulate.a, 0.0, 0.01, "root_a's cells should have faded")
	for cell in root_b.get_children():
		assert_almost_eq((cell as Node2D).modulate.a, 0.0, 0.01, "root_b's cells should have faded")

func test_a_then_step_containing_a_delayed_with_group_stages_each_child_from_that_steps_own_start():
	var root_a := Node.new()
	add_child_autofree(root_a)
	var root_b := Node.new()
	add_child_autofree(root_b)
	for i in 2:
		root_a.add_child(Node2D.new())
		root_b.add_child(Node2D.new())
	var overlay: Node2D = add_child_autofree(Node2D.new())
	overlay.modulate.a = 1.0

	# Mirrors a real authored chain: step 1 (diamond) then step 2, where step
	# 2 is a .with() group of a grid motion delayed 0.2s and an Anima.on()
	# motion delayed 0.3s (0.1s after the grid one starts).
	var step1 := Anima.grid(root_a, Vector2i(2, 1)).with_item_motion(Anima.item().opacity(0.0, 0.05))
	var step2_grid := Anima.grid(root_b, Vector2i(2, 1)).with_item_motion(Anima.item().opacity(0.0, 0.05))
	step2_grid.motion.delay = 0.2
	var overlay_motion := Anima.on(overlay).fade_out(0.05).with_delay(0.3)

	var playback: AnimaPlayback = step1.then(step2_grid.with(overlay_motion)).play()

	# Step 1 alone (~0.05s at most, PARALLEL default stagger with 2 items —
	# comfortably done well before 0.2s).
	for i in range(12):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(overlay.modulate.a, 1.0, 0.01, "overlay should not have started — step 2 has barely begun")

	for i in range(12): # elapsed within step 2 now ~0.2-0.4s, past the grid's 0.2s delay
		playback._advance(1.0 / 60.0)
	for cell in root_b.get_children():
		assert_almost_eq((cell as Node2D).modulate.a, 0.0, 0.01, "root_b's grid should have started once its own 0.2s delay elapsed")

	for i in range(12): # elapsed within step 2 now past the overlay's 0.3s delay
		playback._advance(1.0 / 60.0)
	assert_almost_eq(overlay.modulate.a, 0.0, 0.01, "overlay should have started once its own 0.3s delay elapsed")

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
