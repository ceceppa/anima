extends "res://addons/gut/test.gd"

## Fading-exit presets (phase-17, story-3).

func _control_in_parent(parent_size: Vector2, size: Vector2, position: Vector2) -> Control:
	var parent := Control.new()
	add_child_autofree(parent)
	parent.size = parent_size

	var node := Control.new()
	parent.add_child(node)
	node.size = size
	node.position = position
	return node

func test_fade_out_ends_fully_transparent_with_no_position_change():
	var node := _control_in_parent(Vector2(500.0, 400.0), Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("fade_out").create_runtime()
	instance.advance(node, Anima.animation("fade_out").duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.position.y, 60.0, 0.01)

func test_fade_out_left_ends_offset_left_by_own_size():
	var node := _control_in_parent(Vector2(500.0, 400.0), Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("fade_out_left")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0 - 80.0, 0.01)

func test_fade_out_left_big_ends_further_offset_than_fade_out_left():
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

	var plain_motion := Anima.animation("fade_out_left")
	var plain_instance = plain_motion.create_runtime()
	plain_instance.advance(plain, plain_motion.duration)

	var big_motion := Anima.animation("fade_out_left_big")
	var big_instance = big_motion.create_runtime()
	big_instance.advance(big, big_motion.duration)

	assert_almost_eq(plain.position.x, 50.0 - 80.0, 0.01)
	assert_almost_eq(big.position.x, 50.0 - 80.0 - 300.0, 0.01)
	assert_true(big.position.x < plain.position.x)

func test_fade_out_left_bigs_offset_changes_with_parent_size():
	var small_parent := Control.new()
	add_child_autofree(small_parent)
	small_parent.size = Vector2(200.0, 200.0)
	var in_small_parent := Control.new()
	small_parent.add_child(in_small_parent)
	in_small_parent.size = Vector2(80.0, 40.0)
	in_small_parent.position = Vector2(50.0, 60.0)

	var large_parent := Control.new()
	add_child_autofree(large_parent)
	large_parent.size = Vector2(600.0, 200.0)
	var in_large_parent := Control.new()
	large_parent.add_child(in_large_parent)
	in_large_parent.size = Vector2(80.0, 40.0)
	in_large_parent.position = Vector2(50.0, 60.0)

	var motion := Anima.animation("fade_out_left_big")
	var small_instance = motion.create_runtime()
	small_instance.advance(in_small_parent, motion.duration)
	var large_instance = motion.create_runtime()
	large_instance.advance(in_large_parent, motion.duration)

	# Same target size, same starting position — only the parent's size
	# differs. The resolved offset must differ too, proving it's computed
	# live from both the target's own size and its parent's, not a fixed
	# literal baked in when the preset was authored.
	assert_almost_eq(in_small_parent.position.x, 50.0 - 80.0 - 200.0, 0.01)
	assert_almost_eq(in_large_parent.position.x, 50.0 - 80.0 - 600.0, 0.01)
	assert_true(in_large_parent.position.x < in_small_parent.position.x)

func test_directional_exits_end_transparent_and_offset():
	var cases := {
		"fade_out_right": Vector2(50.0 + 80.0, 60.0),
		"fade_out_up": Vector2(50.0, 60.0 - 40.0),
		"fade_out_down": Vector2(50.0, 60.0 + 40.0),
		"fade_out_top_left": Vector2(50.0 - 80.0, 60.0 - 40.0),
		"fade_out_top_right": Vector2(50.0 + 80.0, 60.0 - 40.0),
		"fade_out_bottom_left": Vector2(50.0 - 80.0, 60.0 + 40.0),
		"fade_out_bottom_right": Vector2(50.0 + 80.0, 60.0 + 40.0),
	}
	for preset_name in cases:
		var node := _control_in_parent(Vector2(500.0, 400.0), Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		var motion := Anima.animation(preset_name)
		var instance = motion.create_runtime()
		instance.advance(node, motion.duration)
		assert_almost_eq(node.modulate.a, 0.0, 0.01, "%s opacity" % preset_name)
		var expected: Vector2 = cases[preset_name]
		assert_almost_eq(node.position.x, expected.x, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, expected.y, 0.01, "%s y" % preset_name)

func test_all_thirteen_fading_exit_presets_are_registered():
	var names := ["fade_out", "fade_out_left", "fade_out_left_big", "fade_out_right", "fade_out_right_big",
		"fade_out_up", "fade_out_up_big", "fade_out_down", "fade_out_down_big",
		"fade_out_top_left", "fade_out_top_right", "fade_out_bottom_left", "fade_out_bottom_right"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("fade_out_up_big"), load("res://addons/anima/presets/exit/fade_out_up_big.tres"))
