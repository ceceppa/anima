extends "res://addons/gut/test.gd"

const ComposerSession = preload("res://addons/anima/editor/anima_composer_session.gd")
const MotionComposer = preload("res://addons/anima/editor/anima_motion_composer.gd")

func test_workspace_keeps_one_motion_graph_while_selection_changes():
	var root := AnimaSequence.new()
	var nested := AnimaParallel.new()
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
	var root := AnimaSequence.new()
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
