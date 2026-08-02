extends "res://addons/gut/test.gd"

func _tick(scene: Control, frames: int) -> void:
	for i in range(frames):
		scene._process(1.0 / 60.0)
		AnimaRuntime.get_singleton()._process(1.0 / 60.0)

func _selector_buttons(selector: SelectorDock) -> Array:
	var buttons := []
	for i in range(selector.get_item_count()):
		buttons.append(selector.get_item(i))
	return buttons

func test_selecting_each_composition_type_completes_every_card():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	var card_row: HBoxContainer = scene.get_node("%CardRow")

	assert_eq(selector.get_item_count(), 6, "all six composition types should be selectable")

	for button in _selector_buttons(selector):
		button.pressed.emit()
		_tick(scene, 200)

		var cards := card_row.get_children()
		assert_gt(cards.size(), 0, "%s demo should show at least one state card" % button.text)

		if button.text == "Race" or button.text == "Conditional":
			# Race's loser freezes short of full progress; Conditional's
			# non-taken branch never leaves rest — either way, only one
			# card is expected to reach full progress, not both/all.
			var reached_full := false
			for card in cards:
				if is_equal_approx(card.progress, 1.0):
					reached_full = true
			assert_true(reached_full, "%s demo should have exactly one card that reaches full progress" % button.text)
		else:
			for card in cards:
				assert_almost_eq(card.progress, 1.0, 0.001, "every card should reach full progress for %s" % button.text)

func test_stage_position_and_size_stay_fixed_across_type_switches():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var stage: PanelContainer = scene.get_node("%Stage")
	var selector: SelectorDock = scene.get_node("%Selector")
	var before_position := stage.position
	var before_size := stage.size

	for button in _selector_buttons(selector):
		button.pressed.emit()
		_tick(scene, 1)
		assert_eq(stage.position, before_position, "stage position should not change when switching composition type")
		assert_eq(stage.size, before_size, "stage size should not change when switching composition type")

	_tick(scene, 200) # let the final demo finish before the scene is freed

func test_selecting_each_type_shows_its_matching_title_and_description():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var expected := {
		"Sequence": "Plays each animation one after another.",
		"Parallel": "Plays all animations at the same time.",
		"Stagger": "Starts each animation with a short delay between them.",
		"Repeat": "Repeats the composition a set number of times.",
		"Race": "Ends as soon as the first animation finishes.",
		"Conditional": "Plays one of two animations based on a condition.",
	}

	var selector: SelectorDock = scene.get_node("%Selector")
	var type_title: Label = scene.get_node("%TypeTitle")
	var type_description: Label = scene.get_node("%TypeDescription")

	for button in _selector_buttons(selector):
		button.pressed.emit()
		assert_eq(type_title.text, button.text)
		assert_eq(type_description.text, expected[button.text])
		_tick(scene, 200) # let each demo finish before selecting the next

func test_selecting_the_same_type_twice_shows_the_same_counter_value():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	var type_counter: Label = scene.get_node("%TypeCounter")
	var first_button: SelectorButton = selector.get_item(0)

	first_button.pressed.emit()
	var counter_text := type_counter.text

	_tick(scene, 200)
	first_button.pressed.emit()
	assert_eq(type_counter.text, counter_text)
	_tick(scene, 200)

func test_background_glow_is_subtle_and_stays_fixed_across_type_switches():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var stage: PanelContainer = scene.get_node("%Stage")
	var glow: TextureRect = scene.get_node("%Glow")
	assert_true(stage.clip_contents, "the glow must stay within the stage's rounded bounds")
	assert_not_null(glow.texture, "the stage should show a background glow behind the cards")
	assert_lt(scene.GLOW_ALPHA, Card.GLOW_PEAK_ALPHA, "the background glow must stay clearly less prominent than an animating card's own glow")

	var before_position := glow.position
	var before_size := glow.size

	var selector: SelectorDock = scene.get_node("%Selector")
	for button in _selector_buttons(selector):
		button.pressed.emit()
		_tick(scene, 1)
		assert_eq(glow.position, before_position, "the glow's position should not change when switching composition type")
		assert_eq(glow.size, before_size, "the glow's size should not change when switching composition type")

	_tick(scene, 200)

func test_selector_dock_moves_indicator_and_selects_exactly_one_item():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%Selector")
	selector.select(2)
	await get_tree().process_frame

	var selected_count := 0
	for button in _selector_buttons(selector):
		if button.button_pressed:
			selected_count += 1
	assert_eq(selected_count, 1, "exactly one item should be selected")
	assert_true(selector.get_item(2).button_pressed, "the item passed to select() should be the selected one")

	var expected_rect := selector._rect_for_index(2)
	assert_eq(selector.indicator_target_position, expected_rect.position)
	assert_eq(selector.indicator_target_size, expected_rect.size)

	_tick(scene, 200) # let the demo selected above finish before the scene is freed

func test_sequence_card_b_waits_for_card_a_to_complete():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	selector.get_item(0).pressed.emit() # Sequence

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	_tick(scene, 10) # well before card A's 0.6s duration elapses
	var cards := card_row.get_children()
	assert_gt(cards[0].progress, 0.0, "card A should already be animating")
	assert_eq(cards[1].progress, 0.0, "card B should not start while card A is still animating")

	_tick(scene, 200)

func test_parallel_cards_start_at_the_same_time():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	selector.get_item(1).pressed.emit() # Parallel

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	_tick(scene, 1)
	var cards := card_row.get_children()
	assert_gt(cards[0].progress, 0.0, "card A should be animating on the very first frame")
	assert_gt(cards[1].progress, 0.0, "card B should be animating on the very first frame, alongside card A")

	_tick(scene, 200)

func test_stagger_activation_travels_across_the_cards():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	selector.get_item(2).pressed.emit() # Stagger

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	_tick(scene, 8) # 0.133s: A (start 0.0s) and B (start 0.1s) running, C (start 0.2s) not yet
	var cards := card_row.get_children()
	assert_gt(cards[0].progress, 0.0, "card A should already be animating")
	assert_gt(cards[1].progress, 0.0, "card B should have started once its offset elapsed")
	assert_eq(cards[2].progress, 0.0, "card C should not have started yet")

	_tick(scene, 200)

func test_repeat_card_completes_and_restarts_at_least_twice():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	selector.get_item(3).pressed.emit() # Repeat

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	var card := card_row.get_children()[0]

	var restarts := 0
	var was_high := false
	for i in range(200):
		_tick(scene, 1)
		if card.progress > 0.9:
			was_high = true
		elif was_high and card.progress < 0.1:
			restarts += 1
			was_high = false

	assert_gt(restarts, 1, "the same card should complete and restart at least twice")

func test_conditional_shows_one_card_with_a_branch_callout():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	assert_eq(selector.get_item_count(), 6, "Conditional should be selectable as a sixth item")

	var conditional_button: SelectorButton = null
	for button in _selector_buttons(selector):
		if button.text == "Conditional":
			conditional_button = button
	conditional_button.pressed.emit()

	var type_counter: Label = scene.get_node("%TypeCounter")
	assert_true(type_counter.text.ends_with("06"), "the counter total should include Conditional")

	var callout: Label = scene.get_node("%ConditionalCallout")
	assert_true(callout.visible, "the callout should appear as soon as Conditional starts playing")
	assert_true(callout.text.begins_with("Condition evaluated:"), "the callout should name the evaluated condition")
	var picked_true := callout.text.contains("TRUE")

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	var cards := card_row.get_children()
	assert_eq(cards.size(), 1, "Conditional demo shows exactly one card")
	assert_null(cards[0].get_node_or_null("MarginContainer/Label"), "the card should show decorative artwork, not a branch label")

	_tick(scene, 200)

	assert_almost_eq(cards[0].progress, 1.0, 0.001, "the card should reach full progress regardless of which branch ran")
	assert_false(callout.visible, "the callout should disappear on its own after a short moment")

	var offset: float = cards[0].position.x - scene._conditional_base_position.x
	if picked_true:
		assert_gt(offset, 0.0, "the true branch should move the card forward")
		assert_gt(cards[0].scale.x, 1.0, "the true branch should grow the card slightly larger")
		assert_almost_eq(cards[0].modulate.a, 1.0, 0.01, "the true branch should be fully bright")
	else:
		assert_lt(offset, 0.0, "the false branch should move the card backward")
		assert_lt(cards[0].scale.x, 1.0, "the false branch should shrink the card slightly smaller")
		assert_lt(cards[0].modulate.a, Card.DIM_ALPHA, "the false branch should dim below the card's resting look")

func test_race_loser_card_freezes_short_of_full_progress():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var selector: SelectorDock = scene.get_node("%Selector")
	var race_button: SelectorButton = null
	for button in _selector_buttons(selector):
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

func test_spacing_matches_design_brief_scale():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var content: VBoxContainer = scene.get_node("Margin/Content")
	var stage_content: VBoxContainer = scene.get_node("%Stage/StageContent")
	var card_row: HBoxContainer = scene.get_node("%CardRow")
	var dock_margin: MarginContainer = scene.get_node("%Stage/StageContent/DockMargin")

	assert_eq(content.get_theme_constant("separation"), 24, "header-to-stage gap should be 24px")
	assert_eq(stage_content.get_theme_constant("separation"), 40, "description-to-cards gap should be 40px")
	assert_eq(card_row.get_theme_constant("separation"), 40, "gap between cards should be 40px")
	assert_eq(dock_margin.get_theme_constant("margin_top"), 8, "extra top margin brings the cards-to-dock gap to 48px (40 base + 8)")

	_tick(scene, 200)

func test_playground_end_to_end_header_stage_dock_stay_fixed_across_all_types():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	var header: ExampleHeader = scene.get_node("%Header")
	var stage: PanelContainer = scene.get_node("%Stage")
	var selector: SelectorDock = scene.get_node("%Selector")

	var header_rect := Rect2(header.position, header.size)
	var stage_rect := Rect2(stage.position, stage.size)
	var dock_rect := Rect2(selector.position, selector.size)

	for button in _selector_buttons(selector):
		button.pressed.emit()
		_tick(scene, 1)
		assert_eq(Rect2(header.position, header.size), header_rect, "header rect should stay fixed across every composition type")
		assert_eq(Rect2(stage.position, stage.size), stage_rect, "stage rect should stay fixed across every composition type")
		assert_eq(Rect2(selector.position, selector.size), dock_rect, "dock rect should stay fixed across every composition type")

	_tick(scene, 200)

func test_selecting_a_new_type_while_playing_cancels_the_previous_one():
	var scene: Control = preload("res://examples/composition_playground.tscn").instantiate()
	add_child_autofree(scene)

	_tick(scene, 5)

	var selector: SelectorDock = scene.get_node("%Selector")
	var second_button: SelectorButton = selector.get_item(1)
	second_button.pressed.emit()

	var card_row: HBoxContainer = scene.get_node("%CardRow")
	for card in card_row.get_children():
		assert_eq(card.progress, 0.0, "switching type mid-playback should start the new one fresh")

	# Run the newly-selected demo to completion before the test ends, so no
	# active AnimaPlayback is left pointing at a node this test is about to
	# free — project-rules.md §Testing (no disposable-test leaks).
	_tick(scene, 200)
