extends "res://addons/gut/test.gd"

const PropertyMotionComposer = preload("res://addons/anima/editor/anima_property_motion_composer.gd")
const MotionComposer = preload("res://addons/anima/editor/anima_motion_composer.gd")

func test_opening_a_convenience_created_motion_shows_its_semantic_name_and_canonical_property():
	var target: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(target).opacity(0.5, 0.3)

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, target)

	assert_eq(composer._semantic_label.text, "Opacity")
	assert_string_contains(composer._property_label.text, "modulate:a")
	assert_string_contains(composer._target_label.text, String(target.name))

func test_a_motion_authored_directly_without_a_convenience_origin_falls_back_to_a_generic_label():
	var motion := Motion.to(NodePath("position:x"), 10.0)

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, null)

	assert_eq(composer._semantic_label.text, "Property Motion")

func test_editing_the_motion_in_the_composer_changes_the_same_resource_playback_reads():
	var target: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(target).position(Vector2(50.0, 0.0), 0.1)

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, target)

	composer._to_field.text = var_to_str(Vector2(90.0, 0.0))
	composer._commit_to()

	assert_eq(motion.to_value, Vector2(90.0, 0.0), "the composer should edit the same authored resource, not a copy")

	var playback := Anima.play(motion, target)
	for i in range(10):
		playback._advance(1.0 / 60.0)
	assert_almost_eq(target.position.x, 90.0, 0.01, "playback should reflect the edited value")

func test_editing_duration_and_ease_changes_the_same_resource():
	var target: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(target).opacity(0.0, 0.2)

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, target)

	composer._on_duration_changed(0.5)
	assert_almost_eq(motion.duration, 0.5, 0.0001)

	composer._on_ease_selected(AnimaEase.Kind.SINE)
	assert_eq(motion.ease.kind, AnimaEase.Kind.SINE)

func test_editing_without_an_undo_redo_manager_still_edits_the_same_instance_no_copy():
	var target: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(target).opacity(0.5, 0.2)
	var original_id := motion.get_instance_id()

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, target)
	composer._on_duration_changed(0.8)

	assert_eq(motion.get_instance_id(), original_id, "editing should never replace the authored resource with a new one")
	assert_almost_eq(motion.duration, 0.8, 0.0001)

func test_a_generic_property_motion_offers_a_searchable_property_choice_with_current_value():
	var target: Node2D = add_child_autofree(Node2D.new())
	target.position.x = 42.0
	var motion := Anima.on(target).property(NodePath("position:x"), 100.0, 0.2)

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, target)

	composer._on_property_search_changed("position")

	var found := false
	for i in composer._property_results.item_count:
		if String(composer._property_results.get_item_metadata(i)) == "position":
			found = true
	assert_true(found, "searching for 'position' should surface the node's position property")
	assert_string_contains(composer._validation_label.text, "Current value")

func test_validation_reports_a_property_not_found_on_the_target():
	var target: Node2D = add_child_autofree(Node2D.new())
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("not_a_real_property")
	motion.to_value = 1.0

	var composer := PropertyMotionComposer.new()
	add_child_autoqfree(composer)
	composer.show_motion(motion, target)

	assert_string_contains(composer._validation_label.text, "was not found")

func test_the_motion_composer_shell_shows_the_property_panel_for_a_selected_property_motion():
	var composer := MotionComposer.new()
	add_child_autoqfree(composer)
	var target: Node2D = add_child_autofree(Node2D.new())
	var motion := Anima.on(target).opacity(0.5, 0.2)

	composer.open_motion(motion)
	composer.select_scene_node(target)

	assert_true(composer._property_motion_composer.visible)
	assert_false(composer._group_composer.visible)
