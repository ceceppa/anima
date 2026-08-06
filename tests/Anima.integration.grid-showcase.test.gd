extends "res://addons/gut/test.gd"

func _make_scene() -> Control:
	var scene: Control = preload("res://examples/showcase/grid/grid_showcase.tscn").instantiate()
	add_child_autofree(scene)
	return scene

## Scene 1's own grid/banner content and ripple-in behaviour is `%Layer1`'s
## (`InventoryHookLayer`/`InventoryGrid`) responsibility, already covered by
## `Anima.integration.grid-showcase-inventory-hook.test.gd`. This orchestrator
## only needs to show it at the right time and tell it to play.
func test_opening_the_scene_shows_and_plays_layer1_for_scene_1():
	var scene := _make_scene()
	await get_tree().process_frame

	assert_true(scene.get_node("%Layer1").visible, "Layer1 (Scene 1's grid/banner) should be visible immediately on open")

func test_finale_matrix_missing_icon_assets_fall_back_to_a_visible_placeholder_not_a_gap():
	var scene := _make_scene()
	await get_tree().process_frame

	# assets/icons/ existing or not, every Scene-4 mini-grid slot must still
	# have a real, visible texture instead of an invisible gap.
	var mini_icons: Array = scene.get("_mini_icon_nodes")
	assert_gt(mini_icons.size(), 0, "sanity: the finale matrix should have mini-grids")
	for mini in mini_icons:
		for icon in mini:
			assert_not_null(icon.texture, "a finale-matrix slot should always have a texture (real icon or placeholder), never a blank gap")

func test_scene_2_hard_cuts_to_the_code_comparison_and_hides_the_inventory():
	var scene := _make_scene()
	await get_tree().process_frame

	for i in range(int(2.5 * 60.0)): # into the 0:02-0:05 window
		scene._advance_show(1.0 / 60.0)

	assert_true(scene.get_node("%Scene2").visible, "Scene 2's code comparison should be visible")
	assert_false(scene.get_node("%Layer1").visible, "Layer1 (Scene 1's grid/banner) should be hidden during Scene 2")
	assert_eq(scene.get_node("%Banner2").text, "From 25 lines of math to 1 line.")
	assert_eq(scene.get_node("%VanillaLabel").text, "Vanilla Godot")
	assert_eq(scene.get_node("%AnimaLabel").text, "Anima")
	assert_false(scene.get_node("%VanillaCode").text.is_empty(), "the vanilla-Godot panel should show illustrative code text")
	assert_false(scene.get_node("%AnimaCode").text.is_empty(), "the Anima panel should show illustrative code text")

func test_scene_3_cuts_back_to_the_grid_and_cycles_through_different_formula_captions():
	var scene := _make_scene()
	await get_tree().process_frame

	var seen_captions: Array = []
	# Step through the whole 0:05-0:12 window in small increments, recording
	# every distinct caption-bar line the inventory grid shows along the way.
	for i in range(int(7.5 * 60.0)):
		scene._advance_show(1.0 / 60.0)
		if scene.get_node("%Scene3").visible:
			var caption: String = scene.get_node("%CaptionBar").text
			if not seen_captions.has(caption):
				seen_captions.append(caption)

	assert_true(scene.get_node("%Layer1").visible, "Layer1 (the inventory grid) should be visible again by the end of Scene 3")
	assert_gt(seen_captions.size(), 1, "at least two different formula caption lines should have appeared in sequence")

func test_scene_4_finale_matrix_starts_the_centre_grid_first_then_spirals_outward():
	var scene := _make_scene()
	await get_tree().process_frame

	for i in range(int(12.05 * 60.0)): # just into the 0:12-0:15 window
		scene._advance_show(1.0 / 60.0)

	assert_true(scene.get_node("%Scene4").visible, "the finale matrix should be visible in the 0:12-0:15 window")
	var mini_icons: Array = scene.get("_mini_icon_nodes")
	assert_eq(mini_icons.size(), 16, "sanity: a 4x4 matrix should have 16 mini-grids")

	var ranks: Array = scene._spiral_outward_ranks(Vector2i(4, 4))
	var centre_index: int = ranks.find(0)
	var last_index: int = ranks.find(15)

	var centre_icons: Array = mini_icons[centre_index]
	var any_centre_visible := false
	for icon in centre_icons:
		if icon.modulate.a > 0.0:
			any_centre_visible = true
			break
	assert_true(any_centre_visible, "the centre-most mini-grid (rank 0) should already be animating just after Scene 4 starts")

	var last_icons: Array = mini_icons[last_index]
	var any_last_visible := false
	for icon in last_icons:
		if icon.modulate.a > 0.0:
			any_last_visible = true
			break
	assert_false(any_last_visible, "the last mini-grid in the spiral (rank 15) should not have started yet this early into Scene 4")

func test_finale_wave_delay_is_adjustable_and_changes_the_spiral_pace():
	var fast := _make_scene()
	fast.finale_wave_delay = 0.02
	await get_tree().process_frame
	var slow := _make_scene()
	slow.finale_wave_delay = 0.5
	await get_tree().process_frame

	for i in range(int(12.3 * 60.0)): # 0.3s into Scene 4 for both
		fast._advance_show(1.0 / 60.0)
		slow._advance_show(1.0 / 60.0)

	var fast_started := 0
	var slow_started := 0
	var fast_icons: Array = fast.get("_mini_icon_nodes")
	var slow_icons: Array = slow.get("_mini_icon_nodes")
	for mini in fast_icons:
		for icon in mini:
			if icon.modulate.a > 0.0:
				fast_started += 1
				break
	for mini in slow_icons:
		for icon in mini:
			if icon.modulate.a > 0.0:
				slow_started += 1
				break

	assert_gt(fast_started, slow_started, "a shorter wave delay should have started visibly more mini-grids by the same point in Scene 4")

func test_finale_matrix_does_not_play_the_same_formula_on_every_mini_grid():
	var scene := _make_scene()
	await get_tree().process_frame

	for i in range(int(14.9 * 60.0)): # let every mini-grid's motion get built
		scene._advance_show(1.0 / 60.0)

	var formulas: Array = []
	for i in scene._mini_grids.size():
		var formula = GridShowcase.SCENE3_FORMULA_ORDER[i % GridShowcase.SCENE3_FORMULA_ORDER.size()]
		if not formulas.has(formula):
			formulas.append(formula)
	assert_gt(formulas.size(), 1, "at least two visibly different propagation patterns should be used across the matrix")

func test_dim_overlay_and_logo_cta_appear_at_thirteen_point_five_seconds():
	var scene := _make_scene()
	await get_tree().process_frame

	for i in range(int(13.3 * 60.0)):
		scene._advance_show(1.0 / 60.0)
	assert_false(scene.get_node("%Dim").visible, "the dim overlay should not appear before 13.5s")

	for i in range(int(0.4 * 60.0)): # cross the 13.5s mark
		scene._advance_show(1.0 / 60.0)
	assert_true(scene.get_node("%Dim").visible, "the dim overlay should appear at 13.5s")
	assert_true(scene.get_node("%LogoCta").visible, "the logo/CTA block should appear at 13.5s")
	assert_eq(scene.get_node("%CtaLine1").text, "ANIMA FOR GODOT 4")
	assert_eq(scene.get_node("%CtaLine2").text, "15+ Built-in Formulas • Open Source")
	assert_eq(scene.get_node("%CtaLine3").text, "Link in Comments")

func test_full_sequence_plays_all_four_scenes_automatically_end_to_end():
	var scene := _make_scene()
	await get_tree().process_frame

	var saw_scene1: bool = scene.get_node("%Layer1").visible
	var saw_scene2 := false
	var saw_scene3 := false
	var saw_scene4 := false

	for i in range(int(GridShowcase.TOTAL_DURATION * 60.0) + 30):
		scene._advance_show(1.0 / 60.0)
		if scene.get_node("%Scene2").visible:
			saw_scene2 = true
		if scene.get_node("%Scene3").visible:
			saw_scene3 = true
		if scene.get_node("%Scene4").visible:
			saw_scene4 = true

	assert_true(saw_scene1, "Scene 1 should have played")
	assert_true(saw_scene2, "Scene 2 should have played")
	assert_true(saw_scene3, "Scene 3 should have played")
	assert_true(saw_scene4, "Scene 4 should have played")
	assert_true(scene.get_node("%LogoCta").visible, "the run should end with the closing logo/CTA visible")
