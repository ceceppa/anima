extends "res://addons/gut/test.gd"

## Sliding entrance / slide exit presets (phase-17, story-7).

func _control(size: Vector2, position: Vector2) -> Control:
	var node := Control.new()
	add_child_autofree(node)
	node.size = size
	node.position = position
	return node

func test_slide_in_left_starts_offset_and_ends_at_rest_with_no_opacity_change():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("slide_in_left")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.position.x, 50.0 - 80.0, 0.01)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)

func test_sliding_entrances_start_offset_by_own_size_in_the_named_direction():
	var cases := {
		"slide_in_left": Vector2(50.0 - 80.0, 60.0),
		"slide_in_right": Vector2(50.0 + 80.0, 60.0),
		"slide_in_up": Vector2(50.0, 60.0 + 40.0),
		"slide_in_down": Vector2(50.0, 60.0 - 40.0),
	}
	for preset_name in cases:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		var motion := Anima.animation(preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, 0.0)
		var expected: Vector2 = cases[preset_name]
		assert_almost_eq(node.position.x, expected.x, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, expected.y, 0.01, "%s y" % preset_name)
		instance.advance(node, motion.duration)
		assert_almost_eq(node.position.x, 50.0, 0.01, "%s ends x" % preset_name)
		assert_almost_eq(node.position.y, 60.0, 0.01, "%s ends y" % preset_name)

func test_sliding_exits_start_at_rest_and_end_offset_by_own_size():
	var cases := {
		"slide_out_left": Vector2(50.0 - 80.0, 60.0),
		"slide_out_right": Vector2(50.0 + 80.0, 60.0),
		"slide_out_up": Vector2(50.0, 60.0 - 40.0),
		"slide_out_down": Vector2(50.0, 60.0 + 40.0),
	}
	for preset_name in cases:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		var motion := Anima.animation(preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, 0.0)
		assert_almost_eq(node.position.x, 50.0, 0.01, "%s starts x" % preset_name)
		assert_almost_eq(node.position.y, 60.0, 0.01, "%s starts y" % preset_name)
		instance.advance(node, motion.duration)
		var expected: Vector2 = cases[preset_name]
		assert_almost_eq(node.position.x, expected.x, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, expected.y, 0.01, "%s y" % preset_name)

func test_offset_changes_with_the_targets_own_size():
	var small := _control(Vector2(50.0, 40.0), Vector2(0.0, 0.0))
	var large := _control(Vector2(300.0, 40.0), Vector2(0.0, 0.0))
	var small_instance = Anima.animation("slide_in_left").create_runtime()
	var large_instance = Anima.animation("slide_in_left").create_runtime()
	small_instance.advance(small, 0.0)
	large_instance.advance(large, 0.0)
	assert_almost_eq(small.position.x, -50.0, 0.01)
	assert_almost_eq(large.position.x, -300.0, 0.01)

func test_all_eight_sliding_presets_are_registered():
	var names := ["slide_in_left", "slide_in_right", "slide_in_up", "slide_in_down",
		"slide_out_left", "slide_out_right", "slide_out_up", "slide_out_down"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("slide_out_down"), load("res://addons/anima/presets/exit/slide_out_down.tres"))
