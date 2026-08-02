extends "res://addons/gut/test.gd"

func test_position_maps_to_the_position_property():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).position(Vector2(1.0, 2.0))

	assert_eq(motion.target_property, NodePath("position"))
	assert_eq(motion.to_value, Vector2(1.0, 2.0))
	assert_false(motion.is_relative)

func test_move_by_maps_to_position_and_is_relative():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).move_by(Vector2(1.0, 2.0))

	assert_eq(motion.target_property, NodePath("position"))
	assert_true(motion.is_relative)

func test_scale_by_maps_to_scale_and_is_relative():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).scale_by(Vector2(0.5, 0.5))

	assert_eq(motion.target_property, NodePath("scale"))
	assert_true(motion.is_relative)

func test_rotate_by_maps_to_rotation_and_is_relative():
	var control: Control = add_child_autofree(Control.new())

	var motion := AnimaOnMotionFactory.new(control).rotate_by(0.5)

	assert_eq(motion.target_property, NodePath("rotation"))
	assert_true(motion.is_relative)

func test_position_axis_methods_map_to_the_indexed_property():
	var node3d: Node3D = add_child_autofree(Node3D.new())
	var factory := AnimaOnMotionFactory.new(node3d)

	assert_eq(factory.position_x(1.0).target_property, NodePath("position:x"))
	assert_eq(factory.position_y(1.0).target_property, NodePath("position:y"))
	assert_eq(factory.position_z(1.0).target_property, NodePath("position:z"))

func test_default_duration_is_zero():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).position(Vector2.ZERO)

	assert_eq(motion.duration, 0.0)

func test_explicit_duration_overrides_the_default():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).position(Vector2.ZERO, 0.4)

	assert_eq(motion.duration, 0.4)

func test_property_with_empty_path_fails_validation():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).property(NodePath(), 1.0)

	assert_null(motion)
	assert_push_error("NodePath")

func test_property_delegates_to_the_named_path_with_no_class_restriction():
	var node3d: Node3D = add_child_autofree(Node3D.new())

	var motion := AnimaOnMotionFactory.new(node3d).property(NodePath("visible"), false)

	assert_eq(motion.target_property, NodePath("visible"))
	assert_eq(motion.to_value, false)
