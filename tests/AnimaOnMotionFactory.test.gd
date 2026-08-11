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

func test_property_by_delegates_to_the_named_path_and_is_relative():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).property_by(NodePath("modulate:a"), -0.5)

	assert_eq(motion.target_property, NodePath("modulate:a"))
	assert_eq(motion.to_value, -0.5)
	assert_eq(motion.is_relative, true)

func test_property_by_with_empty_path_fails_validation():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).property_by(NodePath(), 1.0)

	assert_null(motion)
	assert_push_error("NodePath")

func test_property_delegates_to_the_named_path_with_no_class_restriction():
	var node3d: Node3D = add_child_autofree(Node3D.new())

	var motion := AnimaOnMotionFactory.new(node3d).property(NodePath("visible"), false)

	assert_eq(motion.target_property, NodePath("visible"))
	assert_eq(motion.to_value, false)

func test_with_delay_chains_off_a_semantic_method():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).move_by(Vector2(1.0, 2.0), 0.1).with_delay(0.05)

	assert_eq(motion.delay, 0.05)

func test_fade_out_animates_opacity_to_zero():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).fade_out(0.2)

	assert_eq(motion.target_property, NodePath("modulate:a"))
	assert_eq(motion.to_value, 0.0)
	assert_eq(motion.duration, 0.2)

func test_fade_in_animates_opacity_to_one():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).fade_in(0.2)

	assert_eq(motion.target_property, NodePath("modulate:a"))
	assert_eq(motion.to_value, 1.0)
	assert_eq(motion.duration, 0.2)

func test_fade_out_on_a_non_canvas_item_target_fails_validation():
	var node3d: Node3D = add_child_autofree(Node3D.new())

	var motion := AnimaOnMotionFactory.new(node3d).fade_out(0.2)

	assert_null(motion)
	assert_push_error("CanvasItem")

func test_keyframes_captures_the_target_for_play():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}})

	assert_same(motion.convenience_target, node)

func test_keyframes_built_motion_plays_via_the_chains_own_play():
	var node: Node2D = add_child_autofree(Node2D.new())
	node.modulate.a = 0.0

	var playback: AnimaPlayback = Anima.on(node).keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}, 0.1).play()
	for i in range(6):
		playback._advance(1.0 / 60.0)

	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)

func test_semantic_methods_capture_the_target_for_play():
	var node: Node2D = add_child_autofree(Node2D.new())

	var motion := AnimaOnMotionFactory.new(node).move_by(Vector2(1.0, 2.0))

	assert_same(motion.convenience_target, node)
