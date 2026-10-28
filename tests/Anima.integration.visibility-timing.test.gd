extends "res://addons/gut/test.gd"

func _make_scene() -> Control:
	var scene: Control = preload("res://examples/playground/visibility_timing_playground.tscn").instantiate()
	add_child_autofree(scene)
	return scene

func test_visibility_dock_lists_four_strategies_with_leave_alone_selected_by_default():
	var scene := _make_scene()
	await get_tree().process_frame

	var dock: SelectorDock = scene.get_node("%VisibilityDock")
	assert_eq(dock.get_item_count(), 4)
	assert_eq(dock.get_item(0).text, "Leave Alone")
	assert_eq(dock.get_item(1).text, "Unhide")
	assert_eq(dock.get_item(2).text, "Make Opaque")
	assert_eq(dock.get_item(3).text, "Both")
	assert_eq(dock.selected_index, 0)

func test_timing_dock_lists_two_choices_with_on_play_selected_by_default():
	var scene := _make_scene()
	await get_tree().process_frame

	var dock: SelectorDock = scene.get_node("%TimingDock")
	assert_eq(dock.get_item_count(), 2)
	assert_eq(dock.get_item(0).text, "On Play")
	assert_eq(dock.get_item(1).text, "On Creation")
	assert_eq(dock.selected_index, 0)

func test_target_starts_hidden_and_transparent():
	var scene := _make_scene()
	await get_tree().process_frame

	var target: ColorRect = scene.get_node("%Target")
	assert_false(target.visible)
	assert_almost_eq(target.modulate.a, 0.0, 0.0001)

func test_choosing_unhide_and_starting_makes_the_target_visible():
	var scene := _make_scene()
	await get_tree().process_frame

	var visibility_dock: SelectorDock = scene.get_node("%VisibilityDock")
	visibility_dock.get_item(1).pressed.emit() # Unhide
	var action_dock: SelectorDock = scene.get_node("%ActionDock")
	action_dock.get_item(0).pressed.emit() # Start
	await get_tree().process_frame

	var target: ColorRect = scene.get_node("%Target")
	assert_true(target.visible, "Unhide should make the entrance-motion target visible once playback starts")

func test_choosing_leave_alone_and_starting_keeps_the_target_hidden():
	var scene := _make_scene()
	await get_tree().process_frame

	var action_dock: SelectorDock = scene.get_node("%ActionDock")
	action_dock.get_item(0).pressed.emit() # Start, with Leave Alone still selected (default)
	await get_tree().process_frame

	var target: ColorRect = scene.get_node("%Target")
	assert_false(target.visible, "Leave Alone should leave a hidden target hidden even while it plays")

func test_hide_after_finish_toggle_hides_the_target_once_the_entrance_completes():
	var scene := _make_scene()
	await get_tree().process_frame

	scene.get_node("%VisibilityDock").get_item(1).pressed.emit() # Unhide, so it becomes visible first
	scene.get_node("%HideToggle").enabled = true

	var target: ColorRect = scene.get_node("%Target")
	var status: Label = scene.get_node("%Status")
	scene.get_node("%ActionDock").get_item(0).pressed.emit() # Start
	await get_tree().process_frame
	assert_true(target.visible, "sanity: Unhide should have made it visible while playing")

	scene._active.complete()
	assert_false(target.visible, "Hide After Finish should hide the target once the entrance finishes")
	assert_true(status.text.contains("Finished"))
