extends "res://addons/gut/test.gd"

## Back entrance/exit presets (phase-17, story-5).

func _control(size: Vector2, position: Vector2) -> Control:
	var parent := Control.new()
	add_child_autofree(parent)
	parent.size = Vector2(500.0, 400.0)

	var node := Control.new()
	parent.add_child(node)
	node.size = size
	node.position = position
	return node

func test_back_in_down_starts_transparent_small_and_far_above():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("back_in_down").create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.scale.x, 0.7, 0.01)
	assert_almost_eq(node.position.y, 60.0 - 1200.0, 0.01)

func test_back_entrances_end_at_rest_full_opacity_and_normal_scale():
	var names := ["back_in_down", "back_in_left", "back_in_right", "back_in_up"]
	for preset_name in names:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		var motion := Anima.animation(preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, motion.duration)
		assert_almost_eq(node.modulate.a, 1.0, 0.01, "%s opacity" % preset_name)
		assert_almost_eq(node.scale.x, 1.0, 0.01, "%s scale" % preset_name)
		assert_almost_eq(node.position.x, 50.0, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, 60.0, 0.01, "%s y" % preset_name)

func test_back_out_starts_at_full_scale_and_opacity():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("back_out_left").create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.scale.x, 1.0, 0.01)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)

func test_back_exits_end_offset_at_reduced_scale_and_opacity():
	var cases := {
		"back_out_down": Vector2(50.0, 60.0 + 700.0),
		"back_out_up": Vector2(50.0, 60.0 - 700.0),
		"back_out_left": Vector2(50.0 - 2000.0, 60.0),
		"back_out_right": Vector2(50.0 + 2000.0, 60.0),
	}
	for preset_name in cases:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		var motion := Anima.animation(preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, motion.duration)
		var expected: Vector2 = cases[preset_name]
		assert_almost_eq(node.position.x, expected.x, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, expected.y, 0.01, "%s y" % preset_name)
		assert_almost_eq(node.scale.x, 0.7, 0.01, "%s scale" % preset_name)
		assert_almost_eq(node.modulate.a, 0.7, 0.01, "%s opacity" % preset_name)

func test_all_eight_back_presets_are_registered():
	var names := ["back_in_down", "back_in_left", "back_in_right", "back_in_up",
		"back_out_down", "back_out_left", "back_out_right", "back_out_up"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("back_out_up"), load("res://addons/anima/presets/exit/back_out_up.tres"))
