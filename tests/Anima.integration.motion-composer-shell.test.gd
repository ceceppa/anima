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
