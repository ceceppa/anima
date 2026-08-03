extends "res://addons/gut/test.gd"

func test_the_playground_shows_the_shared_header_card_example_line_selector_and_controls():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	assert_not_null(scene.get_node("%Selector"))
	assert_not_null(scene.get_node("%Card"))
	assert_not_null(scene.get_node("%ExampleLine"))
	assert_not_null(scene.get_node("%PlaybackControls"))
	assert_not_null(scene.find_child("Header", true, false))

	var selector: SelectorDock = scene.get_node("%Selector")
	assert_eq(selector.get_item_count(), 12, "one item per showcased Anima.on() family")

func test_selecting_each_family_produces_a_visible_card_run_matching_the_shown_example():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var example_line: Label = scene.get_node("%ExampleLine")
	var card: Card = scene.get_node("%Card")

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

## Regression: CardCenter used to be a CenterContainer, which re-asserts its
## own centring on every layout pass — fighting a convenience motion's
## direct writes to Card.position. The card looked right the first time
## (whatever position was captured once at _ready()) but jumped to the
## container's top-left corner on a later reset once the container's real
## layout diverged from that stale snapshot. Resetting now always recentres
## against the container's *current* size instead of a one-time capture.
func test_resetting_the_card_uses_the_current_centred_position_not_a_stale_snapshot():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var card_center: Control = scene.get_node("%CardCenter")
	var card: Card = scene.get_node("%Card")

	# Simulate the container's real layout resolving strictly after the
	# scene's own _ready() already ran — e.g. a deferred sort pass, or the
	# window resizing between two plays. Card clamps its own size up to its
	# custom_minimum_size, so the expected centre is computed from Card's
	# actual resulting size rather than hardcoded against it.
	card_center.size = Vector2(400.0, 300.0)
	card.size = Vector2(100.0, 100.0)
	var expected_position := (card_center.size - card.size) / 2.0

	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.restart_pressed.emit()

	assert_eq(card.position, expected_position, "resetting should recentre against the container's actual current size, not a value captured once at _ready()")

func test_restart_and_reverse_replay_the_selected_motions_actual_recorded_run():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Card = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	selector.get_item(0).pressed.emit() # Move By
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
