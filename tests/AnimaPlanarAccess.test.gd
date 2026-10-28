extends "res://addons/gut/test.gd"

## Catalog presets are written for 2D. With [member AnimaKeyframeMotion.planar]
## set, AnimaPlanarAccess maps them onto a Node3D's local XY plane.

func after_each():
	for playback in AnimaRuntime.get_singleton().active_playbacks.duplicate():
		playback.cancel()
	AnimaPlanarAccess.pixels_per_metre = 100.0

## A 1 m cube under a plain Node3D — the shape every 3D showcase shape uses.
func _make_cube() -> Node3D:
	var body := Node3D.new()
	var mesh := MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	body.add_child(mesh)
	add_child_autofree(body)
	return body

func _step(seconds: float) -> void:
	var frames := int(ceil(seconds * 60.0))
	for i in frames:
		AnimaRuntime.get_singleton()._process(1.0 / 60.0)

func test_non_planar_access_is_a_plain_get_and_set():
	var body := _make_cube()
	AnimaPlanarAccess.write(body, ^"position:y", 2.0, false)
	assert_eq(body.position.y, 2.0)
	assert_eq(AnimaPlanarAccess.read(body, ^"position:y", false), 2.0)

func test_planar_access_on_a_2d_node_is_a_plain_get_and_set():
	var control := Control.new()
	add_child_autofree(control)
	AnimaPlanarAccess.write(control, ^"position:y", 20.0, true)
	assert_eq(control.position.y, 20.0)
	assert_eq(AnimaPlanarAccess.read(control, ^"rotation", true), 0.0)

func test_planar_position_flips_y_and_converts_pixels_to_metres():
	var body := _make_cube()
	AnimaPlanarAccess.write(body, ^"position:y", -30.0, true)
	assert_almost_eq(body.position.y, 0.3, 0.0001, "2D up (negative y) is 3D up (positive y)")
	AnimaPlanarAccess.write(body, ^"position:x", 50.0, true)
	assert_almost_eq(body.position.x, 0.5, 0.0001)
	AnimaPlanarAccess.write(body, ^"position", Vector2(100, 100), true)
	assert_true(body.position.is_equal_approx(Vector3(1, -1, 0)))
	assert_true(AnimaPlanarAccess.read(body, ^"position", true).is_equal_approx(Vector2(100, 100)))

func test_pixels_per_metre_is_configurable():
	var body := _make_cube()
	AnimaPlanarAccess.pixels_per_metre = 10.0
	AnimaPlanarAccess.write(body, ^"position:x", 10.0, true)
	assert_almost_eq(body.position.x, 1.0, 0.0001)

func test_planar_scale_keeps_depth_following_x():
	var body := _make_cube()
	AnimaPlanarAccess.write(body, ^"scale", Vector2(1.25, 0.75), true)
	assert_true(body.scale.is_equal_approx(Vector3(1.25, 0.75, 1.25)))
	assert_eq(AnimaPlanarAccess.read(body, ^"scale", true), Vector2(1.25, 0.75))

func test_planar_rotation_turns_around_z_with_the_sign_flipped():
	var body := _make_cube()
	AnimaPlanarAccess.write(body, ^"rotation", 0.5, true)
	assert_almost_eq(body.rotation.z, -0.5, 0.0001)
	assert_almost_eq(AnimaPlanarAccess.read(body, ^"rotation", true), 0.5, 0.0001)

func test_planar_opacity_drives_geometry_transparency():
	var body := _make_cube()
	var mesh := body.get_child(0) as MeshInstance3D
	AnimaPlanarAccess.write(body, ^"modulate:a", 0.25, true)
	assert_almost_eq(mesh.transparency, 0.75, 0.0001)
	assert_almost_eq(AnimaPlanarAccess.read(body, ^"modulate:a", true), 0.25, 0.0001)

func test_planar_opacity_uses_a_label3d_own_modulate():
	var label := Label3D.new()
	add_child_autofree(label)
	AnimaPlanarAccess.write(label, ^"modulate:a", 0.5, true)
	assert_almost_eq(label.modulate.a, 0.5, 0.0001)
	assert_eq(label.transparency, 0.0)

func test_planar_skew_shears_the_basis():
	var body := _make_cube()
	AnimaPlanarAccess.write(body, ^"transform:x:y", 0.2, true)
	assert_almost_eq(body.basis.x.y, -0.2, 0.0001)
	assert_almost_eq(AnimaPlanarAccess.read(body, ^"transform:x:y", true), 0.2, 0.0001)

func test_planar_size_reads_visual_bounds_in_pixels_and_ignores_writes():
	var body := _make_cube()
	assert_true(AnimaPlanarAccess.read(body, ^"size", true).is_equal_approx(Vector2(100, 100)))
	AnimaPlanarAccess.write(body, ^"size:x", 500.0, true)
	assert_almost_eq(AnimaPlanarAccess.read(body, ^"size:x", true), 100.0, 0.001)

func test_every_catalog_preset_is_planar():
	for preset_name in AnimaAnimationRegistry._PATHS.keys():
		var preset := Anima.animation(preset_name) as AnimaKeyframeMotion
		assert_not_null(preset, preset_name)
		if preset != null:
			assert_true(preset.planar, "%s should be marked planar" % preset_name)

func test_tada_on_a_node3d_keeps_its_depth_and_rocks_around_z():
	var body := _make_cube()
	Anima.play(Anima.animation("tada"), body)
	var min_depth := INF
	var max_tilt := 0.0
	for i in 60:
		_step(1.0 / 60.0)
		min_depth = minf(min_depth, body.scale.z)
		max_tilt = maxf(max_tilt, absf(body.rotation.z))
	assert_gt(min_depth, 0.8, "a Vector2 scale must not flatten the cube's depth to zero")
	assert_gt(max_tilt, 0.01)
	assert_true(body.scale.is_equal_approx(Vector3.ONE))
	assert_almost_eq(body.rotation.z, 0.0, 0.0001)

func test_bounce_on_a_node3d_hops_up():
	var body := _make_cube()
	Anima.play(Anima.animation("bounce"), body)
	var highest := 0.0
	for i in 70:
		_step(1.0 / 60.0)
		highest = maxf(highest, body.position.y)
	assert_almost_eq(highest, 0.3, 0.02, "bounce's 30 px hop is 0.3 m up")
	assert_almost_eq(body.position.y, 0.0, 0.0001)

func test_zoom_in_on_a_node3d_fades_in_through_transparency():
	var body := _make_cube()
	var mesh := body.get_child(0) as MeshInstance3D
	Anima.play(Anima.animation("zoom_in"), body)
	_step(1.0 / 60.0)
	assert_gt(mesh.transparency, 0.5, "starts mostly transparent")
	_step(1.0)
	assert_almost_eq(mesh.transparency, 0.0, 0.0001)
	assert_true(body.scale.is_equal_approx(Vector3.ONE))

func test_fade_in_up_on_a_node3d_rises_from_below_by_its_own_height():
	var body := _make_cube()
	Anima.play(Anima.animation("fade_in_up"), body)
	_step(1.0 / 60.0)
	assert_lt(body.position.y, -0.5, "starts below its resting place")
	_step(1.0)
	assert_almost_eq(body.position.y, 0.0, 0.0001)

func test_a_non_planar_keyframe_motion_on_a_node3d_is_unchanged():
	var body := _make_cube()
	Anima.play(Anima.on(body).keyframes({"to": {"position:y": 2.0}}, 0.2), body)
	_step(0.3)
	assert_almost_eq(body.position.y, 2.0, 0.0001)

func test_reversed_preset_stays_planar():
	var body := _make_cube()
	var playback := Anima.play(Anima.animation("tada").duplicate(true), body)
	_step(0.3)
	assert_true(playback.reverse())
	_step(1.0)
	assert_gt(body.scale.z, 0.5, "a reversed preset must still map its Vector2 scale")

func test_fully_transparent_geometry_stops_casting_shadows_until_visible_again():
	var body := _make_cube()
	var mesh := body.get_child(0) as MeshInstance3D
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	AnimaPlanarAccess.write(body, ^"modulate:a", 0.0, true)
	assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	AnimaPlanarAccess.write(body, ^"modulate:a", 0.0, true)
	AnimaPlanarAccess.write(body, ^"modulate:a", 0.4, true)
	assert_eq(mesh.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED, "the geometry's own setting comes back")
