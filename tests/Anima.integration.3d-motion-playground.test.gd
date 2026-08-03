extends "res://addons/gut/test.gd"

func test_the_playground_shows_the_shared_header_card_example_line_selector_and_controls():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	assert_not_null(scene.get_node("%Selector"))
	assert_not_null(scene.get_node("%Card"))
	assert_not_null(scene.get_node("%ExampleLine"))
	assert_not_null(scene.get_node("%PlaybackControls"))
	assert_not_null(scene.find_child("Header", true, false))

	var selector: SelectorDock = scene.get_node("%Selector")
	assert_eq(selector.get_item_count(), 7, "one item per Node3D-valid Anima.on() family")

func test_selecting_each_family_produces_a_visible_run_matching_the_shown_example():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var example_line: Label = scene.get_node("%ExampleLine")
	var card: Card3D = scene.get_node("%Card")

	for index in selector.get_item_count():
		selector.get_item(index).pressed.emit()

		var playback: AnimaPlayback = scene.get("_active_playback")
		assert_not_null(playback, "selecting a family should start a public AnimaPlayback")
		assert_true(playback.motion is AnimaPropertyMotion, "every showcased family builds a single AnimaPropertyMotion")
		assert_string_contains(example_line.text, "Anima.on(card)", "the shown example line should match the family actually playing")

		for i in range(30):
			playback._advance(1.0 / 60.0)
		assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	assert_not_null(card)

func test_restart_and_reverse_replay_the_selected_motions_actual_recorded_run():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Card3D = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	selector.get_item(4).pressed.emit() # Move By
	var base_x := card.position.x

	var playback: AnimaPlayback = scene.get("_active_playback")
	for i in range(30):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	var moved_x := card.position.x
	assert_ne(moved_x, base_x, "the move_by family should visibly move the card")

	controls.reverse_pressed.emit()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	for i in range(30):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(card.position.x, base_x, 0.01, "reverse should return the card through its actually recorded run")

	controls.restart_pressed.emit()
	var restarted: AnimaPlayback = scene.get("_active_playback")
	for i in range(30):
		restarted._advance(1.0 / 60.0)
	assert_almost_eq(card.position.x, moved_x, 0.01, "restart should play the selected family forward again")
