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
