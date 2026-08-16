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
