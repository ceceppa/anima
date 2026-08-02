extends "res://addons/gut/test.gd"

func test_position_maps_to_the_position_property_with_no_target_needed():
	var motion := AnimaItemMotionFactory.new().position(Vector2(1.0, 2.0))

	assert_eq(motion.target_property, NodePath("position"))
	assert_eq(motion.to_value, Vector2(1.0, 2.0))

func test_move_by_and_scale_by_and_rotate_by_are_relative():
	var factory := AnimaItemMotionFactory.new()

	assert_true(factory.move_by(Vector2(1.0, 0.0)).is_relative)
	assert_true(factory.scale_by(Vector2(0.1, 0.1)).is_relative)
	assert_true(factory.rotate_by(0.2).is_relative)

func test_opacity_maps_to_modulate_alpha():
	var motion := AnimaItemMotionFactory.new().opacity(0.5)

	assert_eq(motion.target_property, NodePath("modulate:a"))

func test_color_maps_to_modulate():
	var motion := AnimaItemMotionFactory.new().color(Color.RED)

	assert_eq(motion.target_property, NodePath("modulate"))

func test_size_maps_to_the_size_property():
	var motion := AnimaItemMotionFactory.new().size(Vector2(10.0, 10.0))

	assert_eq(motion.target_property, NodePath("size"))

func test_property_delegates_with_no_class_restriction():
	var motion := AnimaItemMotionFactory.new().property(NodePath("visible"), true)

	assert_eq(motion.target_property, NodePath("visible"))
	assert_eq(motion.to_value, true)

func test_property_with_empty_path_fails_validation():
	var motion := AnimaItemMotionFactory.new().property(NodePath(), 1.0)

	assert_null(motion)
	assert_push_error("NodePath")
