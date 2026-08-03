extends "res://addons/gut/test.gd"

func _make_node_with_motion_field(motion: AnimaMotion) -> Node:
	var script := GDScript.new()
	script.source_code = "extends Node\n@export var motion: AnimaMotion\n"
	script.reload()
	var node := Node.new()
	node.set_script(script)
	node.motion = motion
	return node

func _make_node_with_typed_motion_field(motion: AnimaGroupMotion) -> Node:
	var script := GDScript.new()
	script.source_code = "extends Node\n@export var group_motion: AnimaGroupMotion\n"
	script.reload()
	var node := Node.new()
	node.set_script(script)
	node.group_motion = motion
	return node

func test_finds_an_exported_anima_motion_field():
	var node := _make_node_with_motion_field(AnimaPropertyMotion.new())
	add_child_autofree(node)

	assert_eq(AnimaMotionFieldScanner.motion_fields(node), ["motion"])

func test_finds_an_exported_field_typed_as_a_motion_subtype():
	var node := _make_node_with_typed_motion_field(AnimaGroupMotion.new())
	add_child_autofree(node)

	assert_eq(AnimaMotionFieldScanner.motion_fields(node), ["group_motion"])

func test_finds_an_exported_field_left_unassigned():
	var node := _make_node_with_motion_field(null)
	add_child_autofree(node)

	assert_eq(AnimaMotionFieldScanner.motion_fields(node), ["motion"], "an unassigned field should still be listed so the entry point can prompt for one")

func test_finds_nothing_on_a_node_with_no_motion_fields():
	var node := Node.new()
	add_child_autofree(node)

	assert_eq(AnimaMotionFieldScanner.motion_fields(node), [])
