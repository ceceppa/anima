extends "res://addons/gut/test.gd"

## Fading-entrance presets (phase-17, story-2).

func _control(size: Vector2, position: Vector2) -> Control:
	var parent := Control.new()
	add_child_autofree(parent)
	parent.size = Vector2(500.0, 400.0)

	var node := Control.new()
	parent.add_child(node)
	node.size = size
	node.position = position
	return node

func _play_to_end(name: String, node: Control) -> void:
	var motion := Anima.animation(name)
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)

func test_fade_in_ends_fully_opaque_with_no_position_change():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	_play_to_end("fade_in", node)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.position.x, 50.0, 0.01)
	assert_almost_eq(node.position.y, 60.0, 0.01)

func test_fade_in_starts_transparent_and_offset_left_by_own_size():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var motion := Anima.animation("fade_in_left")
	var instance = motion.create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)
	assert_almost_eq(node.position.x, 50.0 - 80.0, 0.01)

func test_fade_in_left_ends_at_rest_and_opaque():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	_play_to_end("fade_in_left", node)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)
	assert_almost_eq(node.position.x, 50.0, 0.01)

func test_fade_in_left_big_starts_further_offset_than_fade_in_left():
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

	var plain_instance = Anima.animation("fade_in_left").create_runtime()
	plain_instance.advance(plain, 0.0)
	var big_instance = Anima.animation("fade_in_left_big").create_runtime()
	big_instance.advance(big, 0.0)

	assert_almost_eq(plain.position.x, 50.0 - 80.0, 0.01)
	assert_almost_eq(big.position.x, 50.0 - 80.0 - 300.0, 0.01)
	assert_true(big.position.x < plain.position.x)

func test_fade_in_right_starts_offset_right_by_own_size():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("fade_in_right").create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.position.x, 50.0 + 80.0, 0.01)

func test_fade_in_up_starts_offset_below_by_own_size():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("fade_in_up").create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.position.y, 60.0 + 40.0, 0.01)

func test_fade_in_down_starts_offset_above_by_own_size():
	var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var instance = Anima.animation("fade_in_down").create_runtime()
	instance.advance(node, 0.0)
	assert_almost_eq(node.position.y, 60.0 - 40.0, 0.01)

func test_directional_entrances_end_at_rest_and_opaque():
	var names := ["fade_in_right", "fade_in_up", "fade_in_down",
		"fade_in_right_big", "fade_in_up_big", "fade_in_down_big",
		"fade_in_top_left", "fade_in_top_right", "fade_in_bottom_left", "fade_in_bottom_right"]
	for preset_name in names:
		var node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
		_play_to_end(preset_name, node)
		assert_almost_eq(node.modulate.a, 1.0, 0.01, "%s opacity" % preset_name)
		assert_almost_eq(node.position.x, 50.0, 0.01, "%s x" % preset_name)
		assert_almost_eq(node.position.y, 60.0, 0.01, "%s y" % preset_name)

func test_diagonal_entrances_start_offset_on_both_axes():
	var top_left := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var top_left_instance = Anima.animation("fade_in_top_left").create_runtime()
	top_left_instance.advance(top_left, 0.0)
	assert_almost_eq(top_left.position.x, 50.0 - 80.0, 0.01)
	assert_almost_eq(top_left.position.y, 60.0 - 40.0, 0.01)

	var bottom_right := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var bottom_right_instance = Anima.animation("fade_in_bottom_right").create_runtime()
	bottom_right_instance.advance(bottom_right, 0.0)
	assert_almost_eq(bottom_right.position.x, 50.0 + 80.0, 0.01)
	assert_almost_eq(bottom_right.position.y, 60.0 + 40.0, 0.01)

func test_fade_in_small_matches_fade_in_left():
	var left_node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var small_node := _control(Vector2(80.0, 40.0), Vector2(50.0, 60.0))
	var left_instance = Anima.animation("fade_in_left").create_runtime()
	var small_instance = Anima.animation("fade_in_small").create_runtime()
	left_instance.advance(left_node, 0.0)
	small_instance.advance(small_node, 0.0)
	assert_almost_eq(left_node.position.x, small_node.position.x, 0.01)

func test_all_fourteen_fading_entrance_presets_are_registered():
	var names := ["fade_in", "fade_in_left", "fade_in_left_big", "fade_in_right", "fade_in_right_big",
		"fade_in_up", "fade_in_up_big", "fade_in_down", "fade_in_down_big",
		"fade_in_top_left", "fade_in_top_right", "fade_in_bottom_left", "fade_in_bottom_right", "fade_in_small"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)

func test_by_name_and_by_asset_return_the_identical_resource():
	assert_same(Anima.animation("fade_in_down_big"), load("res://addons/anima/presets/fading_entrances/fade_in_down_big.tres"))
