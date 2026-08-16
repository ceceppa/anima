extends "res://addons/gut/test.gd"

## Rotating entrance/exit presets (phase-17, story-6).

func _control() -> Control:
	var node := Control.new()
	add_child_autofree(node)
	node.size = Vector2(80.0, 40.0)
	node.position = Vector2(50.0, 60.0)
	return node

func test_rotate_in_starts_transparent_and_rotated_ends_opaque_and_upright():
	var node := _control()
	var motion := Anima.animation("rotate_in")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_false(is_zero_approx(node.rotation))
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_rotate_out_starts_opaque_and_upright_ends_transparent_and_rotated():
	var node := _control()
	var motion := Anima.animation("rotate_out")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_false(is_zero_approx(node.rotation))

func test_corner_pivoted_entrances_end_upright_and_opaque_with_the_named_pivot():
	var cases := {
		"rotate_in_down_left": AnimaPivot.Kind.BOTTOM_LEFT,
		"rotate_in_down_right": AnimaPivot.Kind.BOTTOM_RIGHT,
		"rotate_in_up_left": AnimaPivot.Kind.BOTTOM_LEFT,
		"rotate_in_up_right": AnimaPivot.Kind.BOTTOM_RIGHT,
	}
	for preset_name in cases:
		var node := _control()
		var motion := Anima.animation(preset_name)
		assert_eq(motion.default_pivot, cases[preset_name], "%s pivot" % preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, 0.0)
		assert_almost_eq(node.modulate.a, 0.0, 0.01, "%s start opacity" % preset_name)
		instance.advance(node, motion.duration)
		assert_almost_eq(node.modulate.a, 1.0, 0.01, "%s end opacity" % preset_name)
		assert_almost_eq(node.rotation, 0.0, 0.01, "%s end rotation" % preset_name)

func test_corner_pivoted_exits_end_transparent_and_rotated_with_the_named_pivot():
	var cases := {
		"rotate_out_down_left": AnimaPivot.Kind.BOTTOM_LEFT,
		"rotate_out_down_right": AnimaPivot.Kind.BOTTOM_RIGHT,
		"rotate_out_up_left": AnimaPivot.Kind.BOTTOM_LEFT,
		"rotate_out_up_right": AnimaPivot.Kind.BOTTOM_RIGHT,
	}
	for preset_name in cases:
		var node := _control()
		var motion := Anima.animation(preset_name)
		assert_eq(motion.default_pivot, cases[preset_name], "%s pivot" % preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, 0.0)
		assert_almost_eq(node.modulate.a, 1.0, 0.01, "%s start opacity" % preset_name)
		instance.advance(node, motion.duration)
		assert_almost_eq(node.modulate.a, 0.0, 0.01, "%s end opacity" % preset_name)
		assert_false(is_zero_approx(node.rotation), "%s end rotation" % preset_name)

func test_all_ten_rotating_presets_are_registered():
	var names := ["rotate_in", "rotate_in_down_left", "rotate_in_down_right", "rotate_in_up_left", "rotate_in_up_right",
		"rotate_out", "rotate_out_down_left", "rotate_out_down_right", "rotate_out_up_left", "rotate_out_up_right"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("rotate_in_up_right"), load("res://addons/anima/presets/entrance/rotate_in_up_right.tres"))
