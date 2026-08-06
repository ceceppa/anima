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
	assert_eq(selector.get_item_count(), 16, "one item per showcased family, including Keyframes, Spring, and Dynamic Values")

func test_selecting_each_family_produces_a_visible_card_run_matching_the_shown_example():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var example_line: Label = scene.get_node("%ExampleLine")
	var card: Card = scene.get_node("%Card")

	for index in selector.get_item_count():
		var button_text: String = selector.get_item(index).text
		selector.get_item(index).pressed.emit()

		var playback: AnimaPlayback = scene.get("_active_playback")
		assert_not_null(playback, "selecting a family should start a public AnimaPlayback")

		if button_text == "Keyframes":
			assert_true(playback.motion is AnimaKeyframeMotion, "the Keyframes family should build an AnimaKeyframeMotion")
			assert_string_contains(example_line.text, "Motion.keyframes(", "the shown example line should match the Keyframes family")
		elif button_text == "Dynamic Values":
			assert_true(playback.motion is AnimaSequence, "the Dynamic Values family chains a standalone dynamic-value motion into a keyframe one")
			assert_string_contains(example_line.text, "AnimaValue.target(", "the shown example line should match the Dynamic Values family")
		else:
			assert_true(playback.motion is AnimaPropertyMotion or playback.motion is AnimaRepeat, "every other showcased family builds a single AnimaPropertyMotion, or an AnimaRepeat wrapping one")
			assert_string_contains(example_line.text, "Anima.on(card)", "the shown example line should match the family actually playing")

		# 90 frames (1.5s) comfortably covers every family's own duration —
		# most finish well under 0.5s, but Keyframes (0.9s) and Spring
		# (settles by simulation, not a fixed timer) both need more room.
		for i in range(90):
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

	var chained_index := -1
	for i in selector.get_item_count():
		if selector.get_item(i).text == "Chained":
			chained_index = i
			break
	assert_ne(chained_index, -1, "sanity: a Chained family item should exist")
	selector.get_item(chained_index).pressed.emit()

	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_true(playback.motion is AnimaRepeat, "the chained family should repeat its move_by motion")
	assert_string_contains(example_line.text, "started", "on_started should already have fired and be reflected in the example line")

	var base_x := card.position.x
	# move_by has no explicit .from(), so each of the 2 repetitions moves
	# another 50px from wherever the card actually is when it starts —
	# base -> base+50 -> base+100, not two identical 0-to-50 legs.
	for i in range(40): # two 0.2s legs plus a 0.15s delay_between — enough to finish both
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_string_contains(example_line.text, "completed", "on_completed should have fired once the whole repeat run finished")
	assert_almost_eq(card.position.x, base_x + 100.0, 0.5, "two accumulating move_by repetitions of +50px each should land 100px on from the base position")

	controls.reverse_pressed.emit()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	for i in range(40):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	# Reverse derives its delta from the last captured leg (base+50 ->
	# base+100, mirrored), then repeats that same relative delta backward,
	# capturing a fresh live start each repetition — the same way the
	# forward relative repeat keeps continuing forward — so it lands all the
	# way back at base+0, not base+50.
	assert_almost_eq(card.position.x, base_x, 0.5, "reversing the chained repeat should continue backward through both repetitions, landing back at the base position")

## Regression: two identical, non-eased move_by legs back-to-back used to
## concatenate into one seamless glide across the full combined distance —
## the repeat genuinely ran twice, but read as a single motion.
func test_chained_family_pauses_visibly_between_its_two_repetitions():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Card = scene.get_node("%Card")

	var chained_index := -1
	for i in selector.get_item_count():
		if selector.get_item(i).text == "Chained":
			chained_index = i
			break
	assert_ne(chained_index, -1, "sanity: a Chained family item should exist")
	selector.get_item(chained_index).pressed.emit()

	var playback: AnimaPlayback = scene.get("_active_playback")
	var previous_x := card.position.x
	var saw_a_pause := false
	for i in range(60): # 1s, comfortably covers the whole run
		playback._advance(1.0 / 60.0)
		if playback.state == AnimaPlayback.State.PLAYING and is_equal_approx(card.position.x, previous_x):
			saw_a_pause = true
		previous_x = card.position.x
		if playback.state == AnimaPlayback.State.FINISHED:
			break

	assert_true(saw_a_pause, "the run should include at least one frame where the card visibly holds still between its two repetitions, not one uninterrupted glide across the whole distance")

## Regression: the Spring family used to use a bounce value so low
## (damping_ratio 0.85) that its overshoot was well under a pixel at this
## travel distance — indistinguishable from a plain eased motion, which
## defeated the whole point of a spring demo.
func test_spring_family_visibly_overshoots_its_target_before_settling():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Card = scene.get_node("%Card")

	var spring_index := -1
	for i in selector.get_item_count():
		if selector.get_item(i).text == "Spring":
			spring_index = i
			break
	assert_ne(spring_index, -1, "sanity: a Spring family item should exist")

	selector.get_item(spring_index).pressed.emit()

	var playback: AnimaPlayback = scene.get("_active_playback")
	# Read the target the motion itself was actually built with, rather than
	# recomputing it from the card's resting position separately — the two
	# can disagree by a pixel or more depending on exactly when the
	# container's layout has settled, which isn't this test's concern.
	var target_x: float = (playback.motion as AnimaPropertyMotion).to_value
	var max_x := card.position.x
	for i in range(300):
		playback._advance(1.0 / 60.0)
		max_x = maxf(max_x, card.position.x)
		if playback.state == AnimaPlayback.State.FINISHED:
			break

	assert_gt(max_x, target_x, "the spring should visibly pass its target before settling, not glide straight to it")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the spring should have settled well within 5 seconds")
	assert_almost_eq(card.position.x, target_x, 0.5, "the spring should still come to rest at its target")

## Regression: AnimaKeyframeMotionInstance never overrode force_complete()/
## restore_initial() (the AnimaMotionInstance base no-ops), so Complete and
## Revert silently did nothing to a running Keyframes motion — the card just
## froze wherever it happened to be, instead of snapping to its end/start.
func test_complete_and_revert_snap_a_running_keyframes_motion_to_its_authored_values():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var selector: SelectorDock = scene.get_node("%Selector")
	var card: Card = scene.get_node("%Card")
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")

	var keyframes_index := -1
	for i in selector.get_item_count():
		if selector.get_item(i).text == "Keyframes":
			keyframes_index = i
			break
	assert_ne(keyframes_index, -1, "sanity: a Keyframes family item should exist")

	selector.get_item(keyframes_index).pressed.emit()
	var base_x := card.position.x
	var playback: AnimaPlayback = scene.get("_active_playback")
	for i in range(16): # partway through the 0.9s run, past the 30% offset stop
		playback._advance(1.0 / 60.0)
	assert_ne(card.position.x, base_x, "sanity: the card should be visibly mid-motion before Complete is pressed")

	controls.complete_pressed.emit()
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "Complete should finish the playback, not merely stop it")
	assert_almost_eq(card.position.x, base_x, 0.01, "Complete should snap to the authored end value, not leave the card wherever it was")
	assert_almost_eq(card.modulate.a, 1.0, 0.01, "Complete should snap every track to its end value, not just position")

	# Fresh run for Revert — Complete already consumed the first playback.
	selector.get_item(keyframes_index).pressed.emit()
	base_x = card.position.x
	playback = scene.get("_active_playback")
	for i in range(16):
		playback._advance(1.0 / 60.0)
	assert_ne(card.position.x, base_x, "sanity: the card should be visibly mid-motion before Revert is pressed")

	controls.revert_pressed.emit()
	assert_eq(playback.state, AnimaPlayback.State.CANCELLED, "Revert should cancel the playback after restoring, matching AnimaPlayback.revert()'s documented behaviour")
	assert_almost_eq(card.position.x, base_x, 0.01, "Revert should snap back to the pre-animation starting value")
	assert_almost_eq(card.modulate.a, 1.0, 0.01, "Revert should restore every track's starting value, not just position")

## Regression: picking a speed only ever set it on whichever AnimaPlayback
## happened to be active at that moment — restart() always built a fresh one
## at the default speed, so the very next restart (or family switch) silently
## dropped the selection back to 1x.
func test_selected_speed_persists_across_restart_and_family_switches():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	var speed_dock: SelectorDock = controls.get_node("%SpeedDock")
	var selector: SelectorDock = scene.get_node("%Selector")

	speed_dock.get_item(2).pressed.emit() # 2x, per PlaybackControls.SPEED_OPTIONS
	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_eq(playback.speed_scale, 2.0, "selecting a speed should apply it to the currently active playback")

	controls.restart_pressed.emit()
	var restarted: AnimaPlayback = scene.get("_active_playback")
	assert_eq(restarted.speed_scale, 2.0, "restarting should keep the previously selected speed, not reset to the default")

	selector.get_item(1).pressed.emit() # switch family
	var switched: AnimaPlayback = scene.get("_active_playback")
	assert_eq(switched.speed_scale, 2.0, "switching families should also keep the previously selected speed")

func _select_family(scene: Control, label: String) -> void:
	var selector: SelectorDock = scene.get_node("%Selector")
	for i in selector.get_item_count():
		if selector.get_item(i).text == label:
			selector.get_item(i).pressed.emit()
			return
	fail_test("no selector item labelled '%s' was found" % label)

## Story-14.6: the Dynamic Values family demonstrates a standalone dynamic
## value (the slide, which also combines two dynamic values via .add()) and
## a dynamic value inside a keyframe step (the pulse's opacity dip), in one
## selection.
func test_dynamic_values_family_demonstrates_a_standalone_value_and_a_dynamic_keyframe_step():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var card: Card = scene.get_node("%Card")
	_select_family(scene, "Dynamic Values")

	var playback: AnimaPlayback = scene.get("_active_playback")
	var start_x := card.position.x
	var start_width := card.size.x

	for i in range(24): # 0.4s — the standalone slide's own duration
		playback._advance(1.0 / 60.0)
	assert_almost_eq(card.position.x, start_x + start_width, 1.0, "the standalone dynamic value should slide the card by exactly its own width")

	for i in range(15): # to ~0.65s global — the keyframe pulse's own mid-point
		playback._advance(1.0 / 60.0)
	assert_lt(card.modulate.a, 1.0, "the keyframe's dynamic opacity step should visibly dip partway through the pulse")

	for i in range(20): # comfortably past the 0.9s total sequence duration
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(card.modulate.a, 1.0, 0.01, "opacity should settle back to fully visible once the pulse completes")

func test_dynamic_values_family_restarts_and_reverses_like_any_other_family():
	var scene: Control = preload("res://examples/playground/convenience_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	_select_family(scene, "Dynamic Values")

	var playback: AnimaPlayback = scene.get("_active_playback")
	for i in range(10):
		playback._advance(1.0 / 60.0)

	controls.reverse_pressed.emit()
	var reversed: AnimaPlayback = scene.get("_active_playback")
	assert_not_null(reversed, "reverse should keep a public AnimaPlayback active, the same as any other family")

	controls.restart_pressed.emit()
	var restarted: AnimaPlayback = scene.get("_active_playback")
	assert_not_null(restarted, "restart should keep a public AnimaPlayback active, the same as any other family")
	assert_eq(restarted.state, AnimaPlayback.State.PLAYING)
