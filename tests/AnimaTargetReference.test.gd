extends "res://addons/gut/test.gd"

const TargetReference = preload("res://addons/anima/motion/resources/anima_target_reference.gd")

func _motion() -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 80.0
	motion.duration = 0.1
	return motion

func test_live_target_resolves_for_immediate_playback():
	var target: Node2D = add_child_autofree(Node2D.new())
	var reference = TargetReference.new()
	reference.set_live_target(target)

	var playback := Anima.play_referenced(_motion(), reference)
	simulate(AnimaRuntime.get_singleton(), 6, 1.0 / 60.0)

	assert_not_null(playback)
	assert_almost_eq(target.position.x, 80.0, 0.01)

func test_scene_relative_reference_resolves_in_a_new_scene_instance():
	var first_root := Node.new()
	var first_target := Node2D.new()
	first_target.name = "Target"
	first_root.add_child(first_target)
	var reference = TargetReference.new()
	assert_eq(reference.set_scene_relative(first_root, first_target), "")
	first_root.free()

	var second_root: Node = add_child_autofree(Node.new())
	var second_target := Node2D.new()
	second_target.name = "Target"
	second_root.add_child(second_target)
	var playback := Anima.play_referenced(_motion(), reference, second_root)
	simulate(AnimaRuntime.get_singleton(), 6, 1.0 / 60.0)

	assert_not_null(playback)
	assert_almost_eq(second_target.position.x, 80.0, 0.01)

func test_live_target_explains_how_to_make_a_saved_resource_safe():
	var reference = TargetReference.new()
	var target := Node.new()
	reference.set_live_target(target)

	assert_string_contains(reference.serialization_error(), "scene-relative")
	target.free()
