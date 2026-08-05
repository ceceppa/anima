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
	var card: Node3D = scene.get_node("%Card")

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
	var card: Node3D = scene.get_node("%Card")
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

func test_complete_pressed_snaps_the_card_to_its_end_value():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Node3D = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	selector.get_item(4).pressed.emit() # Move By
	var playback: AnimaPlayback = scene.get("_active_playback")
	playback._advance(0.05) # partway through, nowhere near finished
	var partial_x := card.position.x

	controls.complete_pressed.emit()

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_ne(card.position.x, partial_x, "complete() should snap to the end value, not leave the card at its partial position")

func test_revert_pressed_snaps_the_card_back_to_its_starting_value():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Node3D = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	selector.get_item(4).pressed.emit() # Move By
	var base_x := card.position.x
	var playback: AnimaPlayback = scene.get("_active_playback")
	playback._advance(0.2)
	assert_ne(card.position.x, base_x, "sanity: the card should have moved")

	controls.revert_pressed.emit()

	assert_eq(playback.state, AnimaPlayback.State.CANCELLED)
	assert_almost_eq(card.position.x, base_x, 0.01, "revert() should snap back to the pre-animation value")

## Regression: toggling reduced motion never set reduced_motion_speed on any
## demo motion, so there was nothing for the global switch to override —
## the toggle visibly did nothing regardless of its state.
## Reduced motion means "skip to the end" (the web's prefers-reduced-motion
## sense), not a slower play-through — tech-spec.md §Speed, direction, and
## reduced motion's reduced_motion_speed == 0.0 sentinel.
func test_reduced_motion_toggle_completes_the_motion_immediately():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%Selector")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	selector.get_item(4).pressed.emit() # Move By
	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_eq(playback.motion.reduced_motion_speed, 0.0, "the played motion should set the complete-immediately sentinel")

	controls.reduced_motion_toggled.emit(true)
	playback._advance(0.001) # any nonzero frame should be enough to complete

	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "reduced motion on should complete the motion immediately")
	controls.reduced_motion_toggled.emit(false)

## Regression: pressing reverse before the auto-started motion had captured
## even one frame used to silently no-op (AnimaPlayback.reverse() had
## nothing to reverse to), leaving the original forward run untouched.
func test_pressing_reverse_before_anything_has_played_still_reverses():
	var scene: Control = preload("res://examples/playground/3d_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.restart_pressed.emit()
	var original_playback: AnimaPlayback = scene.get("_active_playback")
	controls.reverse_pressed.emit() # same frame as restart — nothing captured yet
	assert_push_error("nothing captured to reverse")

	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_ne(playback, original_playback, "reverse() failing natively should fall back to a fresh play_backwards() run, not leave the original forward playback untouched")
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	for i in range(30):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the fallback reversed run should still play through and finish")
