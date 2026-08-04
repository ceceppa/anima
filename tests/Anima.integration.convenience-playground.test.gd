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
	assert_eq(selector.get_item_count(), 13, "one item per showcased Anima.on() family")

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
		assert_true(playback.motion is AnimaPropertyMotion or playback.motion is AnimaRepeat, "every showcased family builds a single AnimaPropertyMotion, or an AnimaRepeat wrapping one")
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

## Regression: pressing reverse before the just-restarted run had captured
## even one frame used to silently no-op (AnimaPlayback.reverse() had
## nothing to reverse to), leaving the original forward run playing
## untouched — the card would end up having moved forward and stayed there,
## not returned to rest. restart() then reverse_pressed() in the same frame,
## with no tick in between, deterministically forces the zero-capture case.
func test_pressing_reverse_before_anything_has_played_still_reverses():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var card: Card = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	controls.restart_pressed.emit()
	var base_x := card.position.x
	var original_playback: AnimaPlayback = scene.get("_active_playback")
	controls.reverse_pressed.emit() # same frame as restart — nothing captured yet
	assert_push_error("nothing captured to reverse")

	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_ne(playback, original_playback, "reverse() failing natively should fall back to a fresh play_backwards() run, not leave the original forward playback untouched")

	for i in range(30):
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(card.position.x, base_x, 0.5, "reversing before anything played should end back at rest, not have moved forward and stayed there")

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

## Exercises the phase goal end-to-end: lifecycle callbacks, repeat, and
## playback-direction control together on one motion, with reverse producing
## a correct, predictable end state — the concrete form of "A developer can
## write Anima.on(node) to animate a property with lifecycle callbacks,
## repeat, and playback-direction control" (phase-10 phase-brief.md "Phase Goal").
func test_chained_family_demonstrates_callbacks_repeat_and_reverse_together():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var example_line: Label = scene.get_node("%ExampleLine")
	var card: Card = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	var chained_index := selector.get_item_count() - 1
	selector.get_item(chained_index).pressed.emit()

	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_true(playback.motion is AnimaRepeat, "the chained family should repeat its move_by motion")
	assert_string_contains(example_line.text, "started", "on_started should already have fired and be reflected in the example line")

	var base_x := card.position.x
	# move_by has no explicit .from(), so each of the 2 repetitions moves
	# another 50px from wherever the card actually is when it starts —
	# base -> base+50 -> base+100, not two identical 0-to-50 legs.
	for i in range(30): # two 0.2s iterations — enough to finish both
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_string_contains(example_line.text, "completed", "on_completed should have fired once the whole repeat run finished")
	assert_almost_eq(card.position.x, base_x + 100.0, 0.5, "two accumulating move_by repetitions of +50px each should land 100px on from the base position")

	controls.reverse_pressed.emit()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	for i in range(30):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	# Reverse replays the last captured leg (base+50 -> base+100, mirrored)
	# for both repeat iterations, so it lands back at base+50, not base+0 —
	# the same "actually observed run, not full history" rule reverse()
	# already applies to every other motion kind.
	assert_almost_eq(card.position.x, base_x + 50.0, 0.5, "reversing the chained repeat should return through its actually-recorded last leg")
