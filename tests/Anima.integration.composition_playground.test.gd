extends "res://addons/gut/test.gd"

func _tick(scene: Control, frames: int) -> void:
	for i in range(frames):
		scene._process(1.0 / 60.0)
		AnimaRuntime.get_singleton()._process(1.0 / 60.0)

func test_selecting_each_composition_type_completes_every_card():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: HBoxContainer = scene.get_node("%Selector")
	var card_row: HBoxContainer = scene.get_node("%CardRow")

	assert_eq(selector.get_child_count(), 5, "Conditional is temporarily removed from the selector; the other five composition types remain")

	for button in selector.get_children():
		button.pressed.emit()
		_tick(scene, 200)

		var cards := card_row.get_children()
		assert_gt(cards.size(), 0, "%s demo should show at least one state card" % button.text)

		if button.text == "Race":
			# The losing card is meant to freeze short of full progress once
			# the race resolves — only the winner reaches 1.0.
			var reached_full := false
			for card in cards:
				if is_equal_approx(card.progress, 1.0):
					reached_full = true
			assert_true(reached_full, "Race demo should have a winner that reaches full progress")
		else:
			for card in cards:
				assert_almost_eq(card.progress, 1.0, 0.001, "every card should reach full progress for %s" % button.text)

func test_restart_resets_and_replays_the_currently_selected_type():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	_tick(scene, 200)

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	for card in card_row.get_children():
		assert_almost_eq(card.progress, 1.0, 0.001)

	var playback_controls: PlaybackControls = scene.get_node("%PlaybackControls")
	playback_controls.get_node("%RestartButton").pressed.emit()

	for card in card_row.get_children():
		assert_eq(card.progress, 0.0, "restart should reset every card back to zero progress")

	_tick(scene, 200)
	for card in card_row.get_children():
		assert_almost_eq(card.progress, 1.0, 0.001, "restarted demo should run back to full progress")

func test_race_loser_card_freezes_short_of_full_progress():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: HBoxContainer = scene.get_node("%Selector")
	var race_button: SelectorButton = null
	for button in selector.get_children():
		if button.text == "Race":
			race_button = button
	race_button.pressed.emit()

	_tick(scene, 200)

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	var cards := card_row.get_children()
	assert_eq(cards.size(), 2, "Race demo shows one card per competing motion")

	# Which card wins is randomised, so check by outcome, not by index.
	var progresses: Array[float] = [cards[0].progress, cards[1].progress]
	progresses.sort()

	assert_lt(progresses[0], 1.0, "the losing card should freeze before reaching full progress")
	assert_gt(progresses[0], 0.0, "the losing card should still show some progress before freezing")
	assert_almost_eq(progresses[1], 1.0, 0.001, "the winning card should reach full progress")

func test_duration_badge_shows_reported_kind_for_the_selected_type():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var badge: Label = scene.get_node("%DurationBadge")
	assert_true(badge.text.begins_with("FIXED"), "Sequence demo is Fixed-duration; badge should show its kind and seconds")

	# Cancel before the scene is torn down — an uncancelled, unfinished
	# AnimaPlayback would otherwise linger in the AnimaRuntime singleton
	# pointing at a freed node and error on every later test in this run.
	scene._playback.cancel()

func test_selecting_a_new_type_while_playing_cancels_the_previous_one():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	_tick(scene, 5)

	var selector: HBoxContainer = scene.get_node("%Selector")
	var second_button: Button = selector.get_child(1)
	second_button.pressed.emit()

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	for card in card_row.get_children():
		assert_eq(card.progress, 0.0, "switching type mid-playback should start the new one fresh")

	# Run the newly-selected demo to completion before the test ends, so no
	# active AnimaPlayback is left pointing at a node this test is about to
	# free — project-rules.md §Testing (no disposable-test leaks).
	_tick(scene, 200)
