extends "res://addons/gut/test.gd"

const ComposerSession = preload("res://addons/anima/editor/anima_composer_session.gd")
const MotionComposer = preload("res://addons/anima/editor/anima_motion_composer.gd")

func test_workspace_keeps_one_motion_graph_while_selection_changes():
	var root := _AnimaSequence.new()
	var nested := _AnimaParallel.new()
	root.children = [nested]
	var session := ComposerSession.new()

	session.open_motion(root)

	assert_eq(session.root_motion, root)
	assert_eq(session.selected_motion, root)
	assert_true(session.select_motion(nested))
	assert_eq(session.selected_motion, nested)
	assert_eq(session.root_motion, root)

func test_workspace_exposes_selected_scene_node_and_missing_context_message():
	var composer := MotionComposer.new()
	var root := _AnimaSequence.new()
	var scene_node := Node.new()
	add_child_autoqfree(composer)
	add_child_autoqfree(scene_node)

	composer.open_motion(root)
	assert_string_contains(composer.scene_node_context_message(), "Select a scene node")

	composer.select_scene_node(scene_node)
	assert_true(composer.has_scene_node_context())
	assert_eq(composer.selected_motion(), root)

## Regression: selecting a plain node used to do nothing — the only entry
## point was expanding an AnimaMotion resource field in the Inspector. The
## Inspector plugin now finds a node's exported motion field via
## AnimaMotionFieldScanner and opens it the same way as opening it directly.
func test_opening_a_nodes_scanned_motion_field_opens_that_same_motion():
	var script := GDScript.new()
	script.source_code = "extends Node\n@export var motion: AnimaMotion\n"
	script.reload()
	var node := Node.new()
	node.set_script(script)
	var motion := AnimaPropertyMotion.new()
	node.motion = motion
	add_child_autofree(node)

	var fields := AnimaMotionFieldScanner.motion_fields(node)
	assert_eq(fields, ["motion"])

	var composer := MotionComposer.new()
	add_child_autoqfree(composer)
	composer.open_motion(node.get(fields[0]))

	assert_eq(composer.selected_motion(), motion, "opening the scanned field should open that same motion in the panel")

func test_top_level_empty_state_names_both_ways_in():
	var composer := MotionComposer.new()
	add_child_autoqfree(composer)

	assert_string_contains(composer.workspace_status_message(), "Select a node")

## Regression: selecting a Property Motion used to fall through to the Group
## Setup dead-end message ("select a Group Motion…") since only Group Motions
## had a working editing view. Selecting one now opens its own editing view.
func test_selecting_a_property_motion_shows_its_editing_view_directly():
	var root := _AnimaSequence.new()
	var property_motion := AnimaPropertyMotion.new()
	root.children = [property_motion]
	var composer := MotionComposer.new()
	add_child_autoqfree(composer)

	composer.open_motion(root)
	composer.select_motion(property_motion)

	assert_true(composer._property_motion_composer.visible, "selecting a Property Motion should show its own editing view")
	assert_false(composer._group_composer.visible, "the Group Setup dead-end message should not show for a Property Motion")

func test_switching_between_group_and_property_motion_updates_the_shown_view_immediately():
	var root := _AnimaSequence.new()
	var group := AnimaGroupMotion.new()
	var property_motion := AnimaPropertyMotion.new()
	root.children = [group, property_motion]
	var composer := MotionComposer.new()
	add_child_autoqfree(composer)

	composer.open_motion(root)

	composer.select_motion(group)
	assert_true(composer._group_composer.visible, "selecting a Group Motion should show Group Setup")
	assert_false(composer._property_motion_composer.visible)

	composer.select_motion(property_motion)
	assert_true(composer._property_motion_composer.visible, "switching to a Property Motion should show its editing view immediately")
	assert_false(composer._group_composer.visible, "no intermediate Group Setup state should remain visible")

	composer.select_motion(group)
	assert_true(composer._group_composer.visible, "switching back to a Group Motion should show Group Setup again")
	assert_false(composer._property_motion_composer.visible)

## An unconfigured group has nothing for Group Inspection to show yet — the
## Inspect Group button stays hidden until the group has both a target
## collection and an item motion assigned.
func test_inspect_button_hidden_until_the_group_is_configured():
	var root := _AnimaSequence.new()
	var group := AnimaGroupMotion.new()
	root.children = [group]
	var composer := MotionComposer.new()
	add_child_autoqfree(composer)

	composer.open_motion(root)
	composer.select_motion(group)
	assert_false(composer._inspect_button.visible, "Inspect Group should not show until the group is configured")

	group.target_collection = AnimaTargetCollection.new()
	group.item_motion = Motion.to(NodePath("position:x"), 10.0)
	composer.select_motion(group)
	assert_true(composer._inspect_button.visible, "Inspect Group should show once the group has a target collection and item motion")
