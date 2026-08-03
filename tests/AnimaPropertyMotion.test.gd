extends "res://addons/gut/test.gd"

func test_validate_fails_without_target_property():
	var motion := AnimaPropertyMotion.new()
	motion.to_value = 1.0
	motion.duration = 0.3

	assert_eq(motion.validate(), ["target_property is required"])

func test_validate_passes_with_target_property_end_value_and_duration():
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("modulate:a")
	motion.to_value = 1.0
	motion.duration = 0.3

	assert_eq(motion.validate(), [])

func test_default_ease_is_linear():
	var motion := AnimaPropertyMotion.new()

	assert_eq(motion.ease.kind, AnimaEase.Kind.LINEAR)

func test_with_delay_sets_the_inherited_delay_field_and_returns_self():
	var motion := AnimaPropertyMotion.new()

	var result := motion.with_delay(0.25)

	assert_eq(motion.delay, 0.25)
	assert_same(result, motion)

func test_from_sets_explicit_start_value_and_returns_self():
	var motion := AnimaPropertyMotion.new()

	var result := motion.from(10.0)

	assert_eq(motion.from_value, 10.0)
	assert_same(result, motion)

func test_from_current_clears_the_start_value():
	var motion := AnimaPropertyMotion.new()
	motion.from_value = 10.0

	motion.from_current()

	assert_null(motion.from_value)

func test_relative_sets_is_relative_and_returns_self():
	var motion := AnimaPropertyMotion.new()

	var result := motion.relative()

	assert_true(motion.is_relative)
	assert_same(result, motion)

func test_is_relative_adds_to_value_to_the_resolved_start_instead_of_replacing_it():
	var target := Node2D.new()
	add_child_autofree(target)
	target.position.x = 10.0

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.to_value = 40.0
	motion.duration = 0.5
	motion.is_relative = true

	var instance = motion.create_runtime()
	for i in range(30):
		instance.advance(target, 1.0 / 60.0)

	assert_almost_eq(target.position.x, 50.0, 0.01, "move_by-style motion should end at start (10) + delta (40)")

func test_estimate_duration_returns_duration():
	var motion := AnimaPropertyMotion.new()
	motion.duration = 0.75

	var result := motion.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.FIXED)
	assert_eq(result.seconds, 0.75)

func _make_spring_motion(to_value: float) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("position:x")
	motion.from_value = 0.0
	motion.to_value = to_value
	motion.ease = AnimaEase.new()
	motion.ease.kind = AnimaEase.Kind.SPRING
	return motion

func test_estimate_duration_reports_estimated_for_spring_ease():
	var motion := _make_spring_motion(100.0)

	var result := motion.estimate_duration()
	assert_eq(result.kind, AnimaDuration.Kind.ESTIMATED)
	assert_gt(result.seconds, 0.0)

func test_spring_moves_toward_target_and_eventually_settles():
	var target := Node2D.new()
	add_child_autofree(target)

	var motion := _make_spring_motion(100.0)
	var instance = motion.create_runtime()

	var finished := false
	for i in range(600):
		finished = instance.advance(target, 1.0 / 60.0)
		if finished:
			break

	assert_true(finished, "spring should eventually settle")
	assert_almost_eq(target.position.x, 100.0, 1.0)

func test_higher_bounce_overshoots_more_than_lower_bounce():
	var low_bounce_target := Node2D.new()
	add_child_autofree(low_bounce_target)
	var low_motion := _make_spring_motion(100.0)
	low_motion.ease.spring_bounce = 0.0
	var low_instance = low_motion.create_runtime()

	var high_bounce_target := Node2D.new()
	add_child_autofree(high_bounce_target)
	var high_motion := _make_spring_motion(100.0)
	high_motion.ease.spring_bounce = 0.8
	var high_instance = high_motion.create_runtime()

	var low_peak := 0.0
	var high_peak := 0.0
	for i in range(300):
		low_instance.advance(low_bounce_target, 1.0 / 60.0)
		high_instance.advance(high_bounce_target, 1.0 / 60.0)
		low_peak = maxf(low_peak, low_bounce_target.position.x)
		high_peak = maxf(high_peak, high_bounce_target.position.x)

	assert_gt(high_peak, 100.0, "a bouncy spring should overshoot its target")
	assert_gt(high_peak, low_peak, "higher bounce should overshoot more than a critically-damped (zero-bounce) spring")

func test_advanced_model_higher_damping_overshoots_less_than_lower_damping():
	var low_damping_target := Node2D.new()
	add_child_autofree(low_damping_target)
	var low_motion := _make_spring_motion(100.0)
	low_motion.ease.spring_model = AnimaEase.SpringModel.ADVANCED
	low_motion.ease.spring_stiffness = 300.0
	low_motion.ease.spring_damping = 5.0
	var low_instance = low_motion.create_runtime()

	var high_damping_target := Node2D.new()
	add_child_autofree(high_damping_target)
	var high_motion := _make_spring_motion(100.0)
	high_motion.ease.spring_model = AnimaEase.SpringModel.ADVANCED
	high_motion.ease.spring_stiffness = 300.0
	high_motion.ease.spring_damping = 60.0
	var high_instance = high_motion.create_runtime()

	var low_peak := 0.0
	var high_peak := 0.0
	for i in range(300):
		low_instance.advance(low_damping_target, 1.0 / 60.0)
		high_instance.advance(high_damping_target, 1.0 / 60.0)
		low_peak = maxf(low_peak, low_damping_target.position.x)
		high_peak = maxf(high_peak, high_damping_target.position.x)

	assert_gt(low_peak, high_peak, "lower damping should overshoot more than higher damping")

func test_strictly_settled_only_finishes_within_configured_thresholds():
	var target := Node2D.new()
	add_child_autofree(target)
	var motion := _make_spring_motion(100.0)
	motion.ease.spring_completion_mode = AnimaEase.SpringCompletionMode.STRICTLY_SETTLED
	var instance = motion.create_runtime()

	var finished := false
	var frames := 0
	while not finished and frames < 1000:
		finished = instance.advance(target, 1.0 / 60.0)
		frames += 1

	assert_true(finished, "spring should eventually be reported settled")
	assert_almost_eq(target.position.x, 100.0, motion.ease.spring_settle_distance * 2.0)

func test_fixed_preview_duration_finishes_at_configured_time_regardless_of_physics():
	var target := Node2D.new()
	add_child_autofree(target)
	var motion := _make_spring_motion(100.0)
	motion.ease.spring_completion_mode = AnimaEase.SpringCompletionMode.FIXED_PREVIEW_DURATION
	motion.ease.spring_preview_duration = 0.2
	var instance = motion.create_runtime()

	var finished_frame := -1
	for i in range(60):
		var finished: bool = instance.advance(target, 1.0 / 60.0)
		if finished:
			finished_frame = i
			break

	assert_ne(finished_frame, -1, "should have finished within one second")
	var elapsed: float = (finished_frame + 1) / 60.0
	assert_almost_eq(elapsed, 0.2, 1.0 / 60.0)

func test_with_pivot_sets_the_pivot_field_and_returns_self():
	var motion := AnimaPropertyMotion.new()

	var result := motion.with_pivot(AnimaPropertyMotion.Pivot.CENTER)

	assert_eq(motion.pivot, AnimaPropertyMotion.Pivot.CENTER)
	assert_same(result, motion)

func test_pivot_resolves_each_anchor_position_on_a_control():
	var expected := {
		AnimaPropertyMotion.Pivot.TOP_LEFT: Vector2(0.0, 0.0),
		AnimaPropertyMotion.Pivot.TOP_CENTER: Vector2(50.0, 0.0),
		AnimaPropertyMotion.Pivot.TOP_RIGHT: Vector2(100.0, 0.0),
		AnimaPropertyMotion.Pivot.CENTER_LEFT: Vector2(0.0, 40.0),
		AnimaPropertyMotion.Pivot.CENTER: Vector2(50.0, 40.0),
		AnimaPropertyMotion.Pivot.CENTER_RIGHT: Vector2(100.0, 40.0),
		AnimaPropertyMotion.Pivot.BOTTOM_LEFT: Vector2(0.0, 80.0),
		AnimaPropertyMotion.Pivot.BOTTOM_CENTER: Vector2(50.0, 80.0),
		AnimaPropertyMotion.Pivot.BOTTOM_RIGHT: Vector2(100.0, 80.0),
	}

	for pivot in expected:
		var control := Control.new()
		add_child_autofree(control)
		control.size = Vector2(100.0, 80.0)

		var motion := AnimaPropertyMotion.new()
		motion.target_property = NodePath("scale")
		motion.to_value = Vector2(1.2, 1.2)
		motion.duration = 0.3
		motion.pivot = pivot

		var instance = motion.create_runtime()
		instance.advance(control, 1.0 / 60.0)

		assert_eq(control.pivot_offset, expected[pivot], "pivot %s should resolve to %s" % [pivot, expected[pivot]])

func test_pivot_leaves_a_non_scale_rotation_motion_unaffected():
	var control := Control.new()
	add_child_autofree(control)
	control.size = Vector2(100.0, 80.0)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("modulate:a")
	motion.to_value = 0.5
	motion.duration = 0.3
	motion.pivot = AnimaPropertyMotion.Pivot.BOTTOM_RIGHT

	var instance = motion.create_runtime()
	instance.advance(control, 1.0 / 60.0)

	assert_eq(control.pivot_offset, Vector2.ZERO, "pivot should be ignored for a property other than scale/rotation")

func test_pivot_on_an_unsupported_target_does_not_error():
	var target := Node2D.new()
	add_child_autofree(target)

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("rotation")
	motion.to_value = 0.5
	motion.duration = 0.1
	motion.pivot = AnimaPropertyMotion.Pivot.CENTER

	var instance = motion.create_runtime()
	var finished := false
	for i in range(10):
		finished = instance.advance(target, 1.0 / 60.0)

	assert_true(finished, "an unsupported pivot target should still finish normally")

func test_pivot_on_a_sprite2d_like_node_does_not_visibly_shift_the_artwork():
	var image := Image.create(20, 10, false, Image.FORMAT_RGBA8)
	var sprite := Sprite2D.new()
	add_child_autofree(sprite)
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.global_position = Vector2(200.0, 150.0)

	var transform_before := sprite.global_transform
	var original_offset := sprite.offset
	var original_global_position := sprite.global_position

	var motion := AnimaPropertyMotion.new()
	motion.target_property = NodePath("scale")
	motion.to_value = Vector2(1.5, 1.5)
	motion.duration = 0.3
	motion.pivot = AnimaPropertyMotion.Pivot.BOTTOM_RIGHT

	var instance = motion.create_runtime()
	instance.advance(sprite, 1.0 / 60.0)

	assert_ne(sprite.offset, original_offset, "pivot should have shifted the sprite's offset")

	var effective_before: Vector2 = original_global_position + transform_before.basis_xform(original_offset)
	var effective_after: Vector2 = sprite.global_position + transform_before.basis_xform(sprite.offset)
	assert_almost_eq(effective_before.x, effective_after.x, 0.01, "artwork should not visibly shift when pivot is applied")
	assert_almost_eq(effective_before.y, effective_after.y, 0.01, "artwork should not visibly shift when pivot is applied")

func test_manual_mode_never_finishes_on_its_own():
	var target := Node2D.new()
	add_child_autofree(target)
	var motion := _make_spring_motion(100.0)
	motion.ease.spring_completion_mode = AnimaEase.SpringCompletionMode.MANUAL
	var instance = motion.create_runtime()

	var finished := false
	for i in range(600):
		finished = instance.advance(target, 1.0 / 60.0)
	assert_false(finished, "manual mode should never auto-complete on its own")
