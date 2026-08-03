extends "res://addons/gut/test.gd"

const GroupInspector = preload("res://addons/anima/editor/anima_group_inspector.gd")

func test_inspection_uses_the_same_resolved_targets_and_offsets_as_playback_and_compilation():
	var root := Node.new()
	add_child_autofree(root)
	for i in 3:
		root.add_child(Node2D.new())
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var group := Motion.group(collection, Motion.to(NodePath("position:x"), 10.0))
	group.item_motion.duration = 0.1
	group.distribution.stagger_interval = 0.05
	var inspector := GroupInspector.new()

	inspector.inspect(group, root)
	var animation := inspector.compile()

	assert_eq(inspector.targets, root.get_children())
	assert_eq(inspector.start_offsets, [0.0, 0.05, 0.1])
	assert_true(inspector.compile_eligible)
	assert_ne(animation, null)
	assert_eq(animation.get_track_count(), inspector.targets.size())
	inspector.free()

## Regression: an empty resolved-target list used to read "No resolved
## targets." with no indication of what to do about it.
func test_empty_resolved_target_list_names_the_next_step():
	var root := Node.new()
	add_child_autofree(root)
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN
	var group := Motion.group(collection, Motion.to(NodePath("position:x"), 10.0))
	var inspector := GroupInspector.new()
	add_child_autofree(inspector)

	inspector.inspect(group, root)

	assert_eq(inspector.targets, [])
	assert_string_contains(inspector.resolved_targets_message(), "Group Setup")
	assert_string_contains(inspector.resolved_targets_message(), "target collection")
