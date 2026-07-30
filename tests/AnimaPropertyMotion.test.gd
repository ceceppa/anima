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
