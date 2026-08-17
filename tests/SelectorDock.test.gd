extends "res://addons/gut/test.gd"

func _make_dock(count: int) -> SelectorDock:
	var dock: SelectorDock = preload("res://examples/playground/shared/components/selector_dock.tscn").instantiate()
	add_child_autofree(dock)
	for i in range(count):
		var button: SelectorButton = preload("res://examples/playground/shared/components/selector_button.tscn").instantiate()
		button.text = "Item %d" % i
		dock.add_item(button)
	return dock

func test_select_marks_exactly_one_item_selected():
	var dock := _make_dock(3)
	await dock.select(1)

	var selected_count := 0
	for i in range(dock.get_item_count()):
		if dock.get_item(i).button_pressed:
			selected_count += 1

	assert_eq(selected_count, 1, "exactly one item should be selected")
	assert_true(dock.get_item(1).button_pressed)
	assert_eq(dock.selected_index, 1)

func test_select_moves_the_indicator_target_to_the_selected_item():
	var dock := _make_dock(3)

	await dock.select(0)
	var rect0 := dock._rect_for_index(0)
	assert_eq(dock.indicator_target_position, rect0.position)
	assert_eq(dock.indicator_target_size, rect0.size)

	await dock.select(2)
	var rect2 := dock._rect_for_index(2)
	assert_eq(dock.indicator_target_position, rect2.position)
	assert_eq(dock.indicator_target_size, rect2.size)
	assert_ne(rect0.position, rect2.position, "the third item's rect should differ from the first's")

func test_select_with_out_of_range_index_is_ignored():
	var dock := _make_dock(2)
	await dock.select(0)
	await dock.select(5)
	assert_eq(dock.selected_index, 0, "an out-of-range index should be ignored, leaving the previous selection")

func test_clear_items_removes_every_item_and_resets_selection():
	var dock := _make_dock(3)
	await dock.select(1)

	dock.clear_items()

	assert_eq(dock.get_item_count(), 0)
	assert_eq(dock.selected_index, -1)

func test_select_after_clear_items_positions_the_indicator_on_the_new_item_set():
	var dock := _make_dock(3)
	await dock.select(2)

	dock.clear_items()
	var button: SelectorButton = preload("res://examples/playground/shared/components/selector_button.tscn").instantiate()
	button.text = "New Item"
	dock.add_item(button)
	await dock.select(0)

	var rect := dock._rect_for_index(0)
	assert_eq(dock.indicator_target_position, rect.position, "indicator must land on the new, single item's actual rect, not a stale 3-item-row position")
	assert_eq(dock.indicator_target_size, rect.size)

func test_selector_button_set_selected_does_not_render_its_own_fill():
	var dock := _make_dock(1)
	await dock.select(0)
	var button: SelectorButton = dock.get_item(0)
	assert_true(button.get_theme_stylebox("normal") is StyleBoxEmpty, "SelectorDock owns the shared indicator fill, not each SelectorButton")

func test_first_selection_snaps_the_indicator_with_no_animation():
	var dock := _make_dock(3)
	await dock.select(1)

	var rect1 := dock._rect_for_index(1)
	assert_eq(dock._indicator_position, rect1.position, "the very first selection should snap immediately, not animate in")
	assert_eq(dock._indicator_size, rect1.size)

func test_select_animates_the_indicator_from_its_previous_rect_to_the_new_one():
	var dock := _make_dock(3)
	await dock.select(0)
	var start_position := dock._indicator_position

	dock.select(2)
	await wait_process_frames(2)

	var rect2 := dock._rect_for_index(2)
	assert_ne(dock._indicator_position, start_position, "the indicator should have started moving away from its previous position")
	assert_ne(dock._indicator_position, rect2.position, "the indicator should not have arrived yet after only a couple of frames")

	await wait_process_frames(60)
	assert_almost_eq(dock._indicator_position.x, rect2.position.x, 1.0)
	assert_almost_eq(dock._indicator_position.y, rect2.position.y, 1.0)
	assert_almost_eq(dock._indicator_size.x, rect2.size.x, 1.0)
	assert_almost_eq(dock._indicator_size.y, rect2.size.y, 1.0)

func test_reselecting_mid_animation_retargets_without_jumping_to_the_first_item():
	var dock := _make_dock(3)
	await dock.select(0)
	var rect0 := dock._rect_for_index(0)

	dock.select(2)
	await wait_process_frames(2)
	dock.select(1)
	await wait_process_frames(1)

	assert_ne(dock._indicator_position, rect0.position, "retargeting mid-flight should not jump back to the very first item's position")

	await wait_process_frames(60)
	var rect1 := dock._rect_for_index(1)
	assert_almost_eq(dock._indicator_position.x, rect1.position.x, 1.0)
	assert_almost_eq(dock._indicator_position.y, rect1.position.y, 1.0)
