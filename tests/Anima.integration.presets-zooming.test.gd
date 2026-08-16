extends "res://addons/gut/test.gd"

## Zooming entrance/exit presets (phase-17, story-8).

func _control(size: Vector2, position: Vector2) -> Control:
	var parent := Control.new()
	add_child_autofree(parent)
	parent.size = Vector2(500.0, 400.0)

	var node := Control.new()
	parent.add_child(node)
	node.size = size
	node.position = position
	return node

func test_zoom_in_starts_transparent_small_ends_opaque_normal_scale():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("zoom_in")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.scale.x, 0.3, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.scale.x, 1.0, 0.01)

func test_zoom_in_left_starts_offset_left_ends_at_rest():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("zoom_in_left")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.position.x, 50.0 - 80.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.scale.x, 1.0, 0.01)

func test_zoom_in_left_big_starts_further_offset_than_zoom_in_left():
	var parent := Control.new()
	add_child_autofree(parent)
	parent.size = Vector2(300.0, 200.0)

	var plain := Control.new()
	parent.add_child(plain)
	plain.size = Vector2(80.0, 40.0)
	plain.position = Vector2(50.0, 60.0)

	var big := Control.new()
	parent.add_child(big)
	big.size = Vector2(80.0, 40.0)
	big.position = Vector2(50.0, 60.0)

	var plain_instance = Anima.animation("zoom_in_left").create_runtime()
	plain_instance.advance(plain, 0.0)
	var big_instance = Anima.animation("zoom_in_left_big").create_runtime()
	big_instance.advance(big, 0.0)

	assert_true(big.position.x < plain.position.x)

func test_remaining_zoom_in_entrances_end_opaque_and_normal_scale():
	var names := ["zoom_in_right", "zoom_in_right_big", "zoom_in_up", "zoom_in_up_big", "zoom_in_down", "zoom_in_down_big"]
	for preset_name in names:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		var motion := Anima.animation(preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, 0.0)
		assert_almost_eq(node.modulate.a, 0.0, 0.01, "%s start opacity" % preset_name)
		instance.advance(node, motion.duration)
		assert_almost_eq(node.modulate.a, 1.0, 0.01, "%s end opacity" % preset_name)
		assert_almost_eq(node.scale.x, 1.0, 0.01, "%s end scale" % preset_name)

func test_zoom_out_starts_opaque_ends_transparent_and_smaller():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("zoom_out")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

func test_zoom_out_down_ends_transparent_smaller_and_offset_above():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("zoom_out_down")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.scale.x, 0.1, 0.01)
	assert_almost_eq(node.position.y, 60.0 - 40.0, 0.01)

func test_zoom_out_down_big_ends_far_offset():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("zoom_out_down_big")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.y, 60.0 + 1000.0, 0.01)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

func test_zoom_out_left_and_right_end_transparent_and_offset():
	var left := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var left_motion := Anima.animation("zoom_out_left")
	var left_instance = left_motion.create_runtime()
	left_instance.advance(left, left_motion.duration)
	assert_almost_eq(left.modulate.a, 0.0, 0.01)
	assert_almost_eq(left.position.x, 50.0 - 80.0, 0.01)

	var right := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var right_motion := Anima.animation("zoom_out_right")
	var right_instance = right_motion.create_runtime()
	right_instance.advance(right, right_motion.duration)
	assert_almost_eq(right.modulate.a, 0.0, 0.01)
	assert_almost_eq(right.position.x, 50.0 + 80.0, 0.01)

func test_zoom_out_up_stays_opaque_and_normal_scale_per_v1_source():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("zoom_out_up")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.scale.x, 1.0, 0.01)
	assert_almost_eq(node.position.y, 60.0 + 40.0, 0.01)

func test_all_fifteen_zooming_presets_are_registered():
	var names := ["zoom_in", "zoom_in_left", "zoom_in_left_big", "zoom_in_right", "zoom_in_right_big",
		"zoom_in_up", "zoom_in_up_big", "zoom_in_down", "zoom_in_down_big",
		"zoom_out", "zoom_out_down", "zoom_out_down_big", "zoom_out_left", "zoom_out_right", "zoom_out_up"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("zoom_in_up_big"), load("res://addons/anima/presets/zooming_entrances/zoom_in_up_big.tres"))
