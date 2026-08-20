extends "res://addons/gut/test.gd"

func _make_scene() -> Control:
	var scene: Control = preload("res://examples/demo_selector.tscn").instantiate()
	add_child_autofree(scene)
	return scene

func _titles(grid: HFlowContainer) -> Array:
	var titles := []
	for card in grid.get_children():
		titles.append(card.title)
	return titles

func test_selector_shows_two_categories():
	var scene := _make_scene()
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%CategorySelector")
	assert_eq(selector.get_item_count(), 2)
	assert_eq(selector.get_item(0).text, "2D")
	assert_eq(selector.get_item(1).text, "3D")

func test_2d_is_selected_by_default_and_lists_every_2d_demo():
	var scene := _make_scene()
	await get_tree().process_frame

	var grid: HFlowContainer = scene.get_node("%DemoGrid")
	assert_eq(_titles(grid), ["Composition", "Group Motion", "Convenience Motion", "Grid Motion", "Animation Catalog"])

func test_selecting_3d_shows_only_the_3d_demo():
	var scene := _make_scene()
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%CategorySelector")
	selector.get_item(1).pressed.emit()
	await get_tree().process_frame

	var grid: HFlowContainer = scene.get_node("%DemoGrid")
	assert_eq(_titles(grid), ["3D Motion"])

func test_switching_back_to_2d_restores_every_2d_demo():
	var scene := _make_scene()
	await get_tree().process_frame

	var selector: SelectorDock = scene.get_node("%CategorySelector")
	selector.get_item(1).pressed.emit()
	await get_tree().process_frame
	selector.get_item(0).pressed.emit()
	await get_tree().process_frame

	var grid: HFlowContainer = scene.get_node("%DemoGrid")
	assert_eq(grid.get_child_count(), 5)

func test_every_demo_card_is_wired_to_open_its_own_scene():
	var scene := _make_scene()
	await get_tree().process_frame

	var grid: HFlowContainer = scene.get_node("%DemoGrid")
	for card in grid.get_children():
		assert_gt(card.pressed.get_connections().size(), 0, "%s card should open its demo when pressed" % card.title)
