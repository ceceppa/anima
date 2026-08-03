extends "res://addons/gut/test.gd"

const MotionComposer = preload("res://addons/anima/editor/anima_motion_composer.gd")
const GroupInspector = preload("res://addons/anima/editor/anima_group_inspector.gd")

func _load_showcase() -> Node:
	var scene: Node = preload("res://examples/editor/motion_composer_showcase.tscn").instantiate()
	add_child_autofree(scene)
	return scene

func test_the_showcase_has_one_node_per_motion_composer_state():
	var scene := _load_showcase()

	assert_not_null(scene.get_node("GroupMotionExample"))
	assert_not_null(scene.get_node("PropertyMotionExample"))
	assert_not_null(scene.get_node("ResolvedGroupExample"))
	assert_not_null(scene.get_node("EmptyExample"))

## The empty node carries no motion at all — the entry point's own per-field
## "Assign an Anima motion to open it here." message (story-3 relies on
## already-shipped Phase 8 behaviour) covers this state; this test only
## confirms the node is set up to trigger it.
func test_empty_example_has_no_motion_assigned():
	var scene := _load_showcase()
	var node := scene.get_node("EmptyExample")

	assert_eq(AnimaMotionFieldScanner.motion_fields(node), ["motion"])
	assert_null(node.get("motion"))

func test_group_motion_example_opens_group_setup_with_its_configuration():
	var scene := _load_showcase()
	var motion: AnimaMotion = scene.get_node("GroupMotionExample").get("motion")
	var composer := MotionComposer.new()
	add_child_autofree(composer)

	composer.open_motion(motion)

	assert_true(composer._group_composer.visible, "a Group Motion should open Group Setup")
	assert_false(composer._property_motion_composer.visible)
	assert_eq(composer.selected_motion(), motion)

func test_property_motion_example_opens_its_editing_view():
	var scene := _load_showcase()
	var motion: AnimaMotion = scene.get_node("PropertyMotionExample").get("motion")
	var composer := MotionComposer.new()
	add_child_autofree(composer)

	composer.open_motion(motion)

	assert_true(composer._property_motion_composer.visible, "a Property Motion should open its own editing view")
	assert_false(composer._group_composer.visible)

## The resolved-group example carries real child nodes so Group Inspection
## has something non-empty to show once the developer opens Group Setup and
## presses Inspect Group, rather than demonstrating the empty resolved-target
## state story-2 already covers.
func test_resolved_group_example_resolves_its_own_children_for_inspection():
	var scene := _load_showcase()
	var node := scene.get_node("ResolvedGroupExample")
	var motion: AnimaGroupMotion = node.get("motion")
	var inspector := GroupInspector.new()
	add_child_autofree(inspector)

	inspector.inspect(motion, node)

	assert_eq(inspector.targets.size(), 3, "the resolved-group example should have real children to resolve")
	assert_true(inspector.compile_eligible)
