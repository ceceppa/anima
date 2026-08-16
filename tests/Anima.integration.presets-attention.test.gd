extends "res://addons/gut/test.gd"

## Catalog foundation + attention presets (phase-17, story-1).

func test_unregistered_name_reports_null():
	assert_null(Anima.animation("not_a_real_preset"))
	assert_push_error("no ported preset")

func test_by_name_and_by_asset_return_the_identical_resource():
	var by_name := Anima.animation("tada")
	var by_asset := load("res://addons/anima/presets/attention/tada.tres")
	assert_same(by_name, by_asset)

func test_repeated_calls_return_the_cached_instance():
	assert_same(Anima.animation("pulse"), Anima.animation("pulse"))

func test_bounce_settles_at_rest_and_normal_scale():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("bounce")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.y, 0.0, 0.01)
	assert_almost_eq(node.scale.y, 1.0, 0.01)

func test_flash_ends_fully_visible():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("flash")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.modulate.a, 1.0, 0.01)

func test_flash_is_transparent_partway_through():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("flash")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration * 0.25)
	assert_almost_eq(node.modulate.a, 0.0, 0.01)

func test_headshake_ends_back_at_rest_and_upright():
	var node := Node2D.new()
	add_child_autofree(node)
	node.position = Vector2(100.0, 0.0)
	var motion := Anima.animation("headshake")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.x, 100.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_heartbeat_pulses_larger_twice_and_ends_normal():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("heartbeat")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration * 0.14)
	assert_almost_eq(node.scale.x, 1.3, 0.01)
	instance.advance(node, motion.duration * (0.42 - 0.14))
	assert_almost_eq(node.scale.x, 1.3, 0.01)
	instance.advance(node, motion.duration * (1.0 - 0.42))
	assert_almost_eq(node.scale.x, 1.0, 0.01)

func test_jello_settles_back_to_no_skew():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("jello")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.transform.x.y, 0.0, 0.001)
	assert_almost_eq(node.transform.y.x, 0.0, 0.001)

func test_pulse_grows_larger_then_returns_to_normal():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("pulse")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration * 0.5)
	assert_almost_eq(node.scale.x, 1.1, 0.01)
	instance.advance(node, motion.duration * 0.5)
	assert_almost_eq(node.scale.x, 1.0, 0.01)

func test_rubber_band_ends_at_normal_shape():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("rubber_band")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.scale.x, 1.0, 0.01)
	assert_almost_eq(node.scale.y, 1.0, 0.01)

func test_shake_x_returns_to_resting_position():
	var node := Node2D.new()
	add_child_autofree(node)
	node.position = Vector2(50.0, 0.0)
	var motion := Anima.animation("shake_x")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.x, 50.0, 0.01)

func test_shake_y_returns_to_resting_position():
	var node := Node2D.new()
	add_child_autofree(node)
	node.position = Vector2(0.0, 20.0)
	var motion := Anima.animation("shake_y")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.y, 20.0, 0.01)

func test_swing_ends_upright():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("swing")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_tada_ends_at_normal_scale_and_rotation():
	var node := Node2D.new()
	add_child_autofree(node)
	var motion := Anima.animation("tada")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.scale.x, 1.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_wobble_offset_depends_on_the_targets_own_size():
	var narrow := Control.new()
	add_child_autofree(narrow)
	narrow.size = Vector2(100.0, 40.0)
	narrow.position = Vector2(0.0, 0.0)

	var wide := Control.new()
	add_child_autofree(wide)
	wide.size = Vector2(400.0, 40.0)
	wide.position = Vector2(0.0, 0.0)

	var motion := Anima.animation("wobble")
	var narrow_instance = motion.create_runtime()
	narrow_instance.advance(narrow, motion.duration * 0.15)
	var wide_instance = motion.create_runtime()
	wide_instance.advance(wide, motion.duration * 0.15)

	# wobble's first stop (offset 0.15) offsets by -0.25 * the target's own
	# width — a wider target must resolve a proportionally larger offset,
	# proving the value is computed live from the target rather than baked.
	assert_almost_eq(narrow.position.x, -25.0, 0.01)
	assert_almost_eq(wide.position.x, -100.0, 0.01)

func test_wobble_ends_back_at_rest_and_upright():
	var node := Control.new()
	add_child_autofree(node)
	node.size = Vector2(100.0, 40.0)
	node.position = Vector2(30.0, 0.0)
	var motion := Anima.animation("wobble")
	var instance = motion.create_runtime()
	instance.advance(node, motion.duration)
	assert_almost_eq(node.position.x, 30.0, 0.01)
	assert_almost_eq(node.rotation, 0.0, 0.01)

func test_all_twelve_attention_presets_are_registered():
	var names := ["bounce", "flash", "headshake", "heartbeat", "jello", "pulse",
		"rubber_band", "shake_x", "shake_y", "swing", "tada", "wobble"]
	for preset_name in names:
		assert_not_null(Anima.animation(preset_name), "missing preset: %s" % preset_name)
