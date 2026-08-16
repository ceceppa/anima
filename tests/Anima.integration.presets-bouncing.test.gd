extends "res://addons/gut/test.gd"

## Bouncing entrance/exit presets (phase-17, story-4).

func _control(size: Vector2, position: Vector2) -> Control:
	var parent := Control.new()
	add_child_autofree(parent)
	parent.size = Vector2(500.0, 400.0)

	var node := Control.new()
	parent.add_child(node)
	node.size = size
	node.position = position
	return node

func _play_to_end(name: String, node: Control) -> AnimaMotion:
	var motion := Anima.animation(name)
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	return motion

func test_bouncing_in_starts_transparent_and_smaller_and_settles_normal():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("bouncing_in")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.scale.x, 0.3, 0.01)
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.scale.x, 1.0, 0.01)

func test_directional_bouncing_entrances_settle_at_rest_and_opaque():
	var names := ["bouncing_in_down", "bouncing_in_left", "bouncing_in_right", "bouncing_in_up"]
	for preset_name in names:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		_play_to_end(preset_name, node)
		assert_almost_eq(node.modulate.a, 1.0, 0.01, "%s opacity" % preset_name)
		assert_almost_eq(node.position.x, 50.0, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, 60.0, 0.01, "%s y" % preset_name)
		assert_almost_eq(node.scale.x, 1.0, 0.02, "%s scale" % preset_name)

func test_bouncing_in_down_starts_transparent_and_offset_above():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("bouncing_in_down").create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.y, 60.0 - 40.0, 0.01)

func test_bounce_out_starts_at_rest_and_ends_transparent_and_smaller():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := _play_to_end("bounce_out", node)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.scale.x, 0.3, 0.01)

func test_bounce_out_down_and_up_end_transparent_and_far_offset():
	var down := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	_play_to_end("bounce_out_down", down)
	assert_almost_eq(down.modulate.a, 0.0, 0.01)
	assert_almost_eq(down.position.y, 60.0 + 2000.0, 0.01)

	var up := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	_play_to_end("bounce_out_up", up)
	assert_almost_eq(up.modulate.a, 0.0, 0.01)
	assert_almost_eq(up.position.y, 60.0 - 2000.0, 0.01)

func test_bounce_out_left_and_right_stay_opaque_while_flying_off():
	var left := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	_play_to_end("bounce_out_left", left)
	assert_almost_eq(left.modulate.a, 1.0, 0.01)
	assert_almost_eq(left.position.x, 50.0 - 2000.0, 0.01)

	var right := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	_play_to_end("bounce_out_right", right)
	assert_almost_eq(right.modulate.a, 1.0, 0.01)
	assert_almost_eq(right.position.x, 50.0 + 2000.0, 0.01)

func test_all_ten_bouncing_presets_are_registered():
	var names := ["bouncing_in", "bouncing_in_down", "bouncing_in_left", "bouncing_in_right", "bouncing_in_up",
		"bounce_out", "bounce_out_down", "bounce_out_left", "bounce_out_right", "bounce_out_up"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("bouncing_in_left"), load("res://addons/anima/presets/entrance/bouncing_in_left.tres"))
