extends "res://addons/gut/test.gd"

func _open_scene() -> Control:
	var scene: Control = preload("res://examples/playground/grid_motion_playground.tscn").instantiate()
	add_child_autofree(scene)
	await get_tree().process_frame
	return scene

func _press_event() -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	return event

func test_the_playground_shows_a_5x5_grid_order_formula_and_playback_controls():
	var scene := await _open_scene()

	var grid: GridContainer = scene.get_node("%Grid")
	assert_eq(grid.columns, 5)
	assert_eq(grid.get_child_count(), 25)

	var order_selector: SelectorDock = scene.get_node("%OrderSelector")
	assert_eq(order_selector.get_item_count(), 8)
	assert_eq(order_selector.selected_index, 0, "Top should be selected by default")

	var formula_selector: SelectorDock = scene.get_node("%FormulaRow")
	assert_eq(formula_selector.get_item_count(), 13, "one button per Grid formula, wrapping across rows")
	assert_not_null(scene.get_node("%FormulaDescription"))
	assert_not_null(scene.get_node("%PlaybackControls"))

func test_tapping_a_non_central_card_makes_it_the_start_point_and_replays():
	var scene := await _open_scene()
	var grid: GridContainer = scene.get_node("%Grid")

	# Column 1, row 3 (zero-based) — not the grid centre (2, 2).
	var tapped_index := 3 * 5 + 1
	var card: Card = grid.get_child(tapped_index)
	card.emit_signal("gui_input", _press_event())

	assert_eq(scene.get("_start_point"), Vector2i(1, 3))
	var grid_motion: AnimaGridMotion = scene.get("_grid_motion")
	assert_eq(grid_motion.start_point, Vector2i(1, 3))

	var marker: Label = scene.get_node("%StartMarker")
	assert_eq(marker.get_parent(), card, "the Start marker should follow the tapped card")
	assert_true(marker.visible)

func test_selecting_an_order_from_mode_changes_the_grid_motions_configuration():
	var scene := await _open_scene()
	var order_selector: SelectorDock = scene.get_node("%OrderSelector")

	order_selector.get_item(1).pressed.emit() # Bottom
	var grid_motion: AnimaGridMotion = scene.get("_grid_motion")
	assert_eq(grid_motion.order.kind, AnimaGroupOrder.Kind.REVERSE)

	order_selector.get_item(4).pressed.emit() # Odd
	grid_motion = scene.get("_grid_motion")
	assert_eq(grid_motion.target_collection.filter, AnimaTargetCollection.Filter.ODD_ONLY)
	assert_eq(grid_motion.order.kind, AnimaGroupOrder.Kind.GRID, "Odd should leave the grid formula active")

func test_selecting_a_formula_produces_the_matching_grid_run_and_updates_the_row():
	var scene := await _open_scene()
	var formula_selector: SelectorDock = scene.get_node("%FormulaRow")

	var row_index := 3 # Row formula, per FORMULA_ORDER
	var row_button: SelectorButton = formula_selector.get_item(row_index)
	row_button.pressed.emit()

	var grid_motion: AnimaGridMotion = scene.get("_grid_motion")
	assert_eq(grid_motion.distance_formula, AnimaGridMotion.DistanceFormula.ROW)
	assert_eq(formula_selector.selected_index, row_index, "the shared indicator should move to the chosen formula")
	assert_true(row_button.button_pressed, "the chosen formula's button should show selected")

	var euclidean_button: SelectorButton = formula_selector.get_item(0)
	assert_false(euclidean_button.button_pressed, "only the chosen formula's button should show selected")

	var description: Label = scene.get_node("%FormulaDescription")
	assert_string_contains(description.text.to_lower(), "row axis")

func test_restart_and_reverse_replay_the_same_selected_grid_configuration():
	var scene := await _open_scene()
	var grid: GridContainer = scene.get_node("%Grid")

	# Manhattan distance from a corner has a unique nearest (the corner
	# itself) and a unique farthest cell (the opposite corner) in a 5x5
	# grid, unlike Euclidean — avoids a tied max rank, whose reversal
	# tie-break order is a separate, pre-existing concern this test isn't
	# about (see tests/AnimaExecutionRecord.test.gd).
	var formula_selector: SelectorDock = scene.get_node("%FormulaRow")
	formula_selector.get_item(1).pressed.emit() # Manhattan — see FORMULA_ORDER in grid_motion_playground.gd

	var tapped_index := 0 * 5 + 0
	(grid.get_child(tapped_index) as Card).emit_signal("gui_input", _press_event())

	var playback: AnimaPlayback = scene.get("_active_playback")
	for i in range(90):
		playback._advance(1.0 / 60.0)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

	var group_instance := playback._instance as AnimaGroupPlayback
	var forward_first: Node = group_instance.execution_record.entries[0].target
	var forward_last: Node = group_instance.execution_record.entries[-1].target

	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.reverse_pressed.emit()
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)
	var reversed_record: AnimaExecutionRecord = group_instance.execution_record
	assert_eq(reversed_record.entries[0].target, forward_last)
	assert_eq(reversed_record.entries[-1].target, forward_first)

	controls.restart_pressed.emit()
	var restarted: AnimaPlayback = scene.get("_active_playback")
	for i in range(90):
		restarted._advance(1.0 / 60.0)
	assert_eq(restarted.state, AnimaPlayback.State.FINISHED)
	var restarted_instance := restarted._instance as AnimaGroupPlayback
	assert_eq(restarted_instance.execution_record.entries[0].target, forward_first, "restart should replay the same tapped start point forward again")

## Regression: pressing reverse before the auto-started grid had captured
## even one frame used to silently no-op (AnimaPlayback.reverse() had
## nothing to reverse to), leaving the original forward run untouched.
func test_pressing_reverse_before_anything_has_played_still_reverses():
	var scene := await _open_scene()

	var controls: PlaybackControls = scene.get_node("%PlaybackControls")
	controls.restart_pressed.emit()
	var original_playback: AnimaPlayback = scene.get("_active_playback")
	controls.reverse_pressed.emit() # same frame as restart — nothing captured yet
	assert_push_error("nothing captured to reverse")

	var playback: AnimaPlayback = scene.get("_active_playback")
	assert_ne(playback, original_playback, "reverse() failing natively should fall back to a fresh play_backwards() run, not leave the original forward playback untouched")
	assert_eq(playback.state, AnimaPlayback.State.PLAYING)

	for i in range(200):
		playback._advance(0.02)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED, "the fallback reversed run should still play through and finish")
