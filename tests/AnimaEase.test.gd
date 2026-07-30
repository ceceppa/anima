extends "res://addons/gut/test.gd"

func test_can_construct_all_supported_kinds():
	var linear := AnimaEase.new()
	linear.kind = AnimaEase.Kind.LINEAR

	var polynomial := AnimaEase.new()
	polynomial.kind = AnimaEase.Kind.POLYNOMIAL

	var sine := AnimaEase.new()
	sine.kind = AnimaEase.Kind.SINE

	var exponential := AnimaEase.new()
	exponential.kind = AnimaEase.Kind.EXPONENTIAL

	var circular := AnimaEase.new()
	circular.kind = AnimaEase.Kind.CIRCULAR

	assert_eq(linear.kind, AnimaEase.Kind.LINEAR)
	assert_eq(polynomial.kind, AnimaEase.Kind.POLYNOMIAL)
	assert_eq(sine.kind, AnimaEase.Kind.SINE)
	assert_eq(exponential.kind, AnimaEase.Kind.EXPONENTIAL)
	assert_eq(circular.kind, AnimaEase.Kind.CIRCULAR)

func test_boundaries_are_exact_for_every_kind():
	var kinds = [
		AnimaEase.Kind.LINEAR, AnimaEase.Kind.POLYNOMIAL, AnimaEase.Kind.SINE,
		AnimaEase.Kind.EXPONENTIAL, AnimaEase.Kind.CIRCULAR, AnimaEase.Kind.BACK,
		AnimaEase.Kind.BOUNCE, AnimaEase.Kind.CUBIC_BEZIER,
	]

	for kind in kinds:
		var ease := AnimaEase.new()
		ease.kind = kind

		assert_almost_eq(ease.evaluate(0.0), 0.0, 0.0001, "kind %s should start at 0" % kind)
		assert_almost_eq(ease.evaluate(1.0), 1.0, 0.0001, "kind %s should end at 1" % kind)

func test_non_linear_kinds_differ_from_linear_at_midpoint():
	var linear := AnimaEase.new()
	linear.kind = AnimaEase.Kind.LINEAR
	var linear_midpoint = linear.evaluate(0.5)

	var non_linear_kinds = [AnimaEase.Kind.POLYNOMIAL, AnimaEase.Kind.SINE, AnimaEase.Kind.EXPONENTIAL, AnimaEase.Kind.CIRCULAR]

	for kind in non_linear_kinds:
		var ease := AnimaEase.new()
		ease.kind = kind

		assert_ne(ease.evaluate(0.5), linear_midpoint)

func test_back_overshoots_before_reaching_start_or_end():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.BACK
	ease.back_overshoot = 1.70158

	assert_lt(ease.evaluate(0.1), 0.0, "back easing should dip below 0 near the start")

func test_bounce_dips_back_down_before_settling():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.BOUNCE

	var before_last_bounce := ease.evaluate(0.95)
	var at_end := ease.evaluate(1.0)
	assert_lt(before_last_bounce, at_end, "bounce should still be rising into its final settle just before t=1")

	# Somewhere in the middle, bounce should dip back down after a local peak —
	# sample densely and confirm at least one such dip exists.
	var previous := 0.0
	var saw_dip := false
	for i in range(1, 100):
		var t := i / 100.0
		var value: float = ease.evaluate(t)
		if value < previous:
			saw_dip = true
		previous = value
	assert_true(saw_dip, "bounce should dip back down at least once before settling at 1.0")

func test_elastic_oscillates_around_final_value_before_settling():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.ELASTIC
	ease.elastic_amplitude = 1.0
	ease.elastic_period = 0.3

	assert_eq(ease.evaluate(0.0), 0.0)
	assert_eq(ease.evaluate(1.0), 1.0)

	var overshoot_seen := false
	for i in range(1, 100):
		var t := i / 100.0
		if ease.evaluate(t) > 1.0 or ease.evaluate(t) < 0.0:
			overshoot_seen = true
	assert_true(overshoot_seen, "elastic should oscillate past its 0..1 range before settling")

func test_cubic_bezier_follows_configured_control_points():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.CUBIC_BEZIER
	ease.bezier_p1 = Vector2(0.0, 1.0)
	ease.bezier_p2 = Vector2(1.0, 0.0)

	# A curve pulled toward y=1 early (control point 1) and y=0 late (control
	# point 2) should sit above the linear diagonal early and below it late.
	assert_gt(ease.evaluate(0.25), 0.25)
	assert_lt(ease.evaluate(0.75), 0.75)

func test_curve_kind_samples_the_assigned_curve_resource():
	var curve := Curve.new()
	curve.clear_points()
	curve.add_point(Vector2(0.0, 0.0))
	curve.add_point(Vector2(1.0, 1.0))

	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.CURVE
	ease.curve = curve

	assert_almost_eq(ease.evaluate(0.5), curve.sample(0.5), 0.0001)

func test_callable_kind_delegates_to_the_assigned_callable():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.CALLABLE
	ease.evaluator = func(t: float) -> float: return t * t

	assert_almost_eq(ease.evaluate(0.5), 0.25, 0.0001)

func test_decay_approaches_one_without_overshooting():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.DECAY
	ease.decay_rate = 0.998

	assert_eq(ease.evaluate(0.0), 0.0)
	assert_lt(ease.evaluate(1.0), 1.0001, "decay should not overshoot past 1.0")
	assert_gt(ease.evaluate(1.0), 0.9, "decay should have visibly approached 1.0 by t=1")
	assert_gt(ease.evaluate(1.0), ease.evaluate(0.5), "decay should keep approaching 1.0 as t increases")

func test_spring_defaults_to_simple_model_and_strictly_settled():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.SPRING

	assert_eq(ease.spring_model, AnimaEase.SpringModel.SIMPLE)
	assert_eq(ease.spring_completion_mode, AnimaEase.SpringCompletionMode.STRICTLY_SETTLED)

func test_spring_stiffness_and_damping_reflects_advanced_model_directly():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.SPRING
	ease.spring_model = AnimaEase.SpringModel.ADVANCED
	ease.spring_stiffness = 250.0
	ease.spring_damping = 15.0

	var result := ease.spring_stiffness_and_damping()
	assert_eq(result.x, 250.0)
	assert_eq(result.y, 15.0)

func test_custom_sampled_interpolates_between_configured_samples():
	var ease := AnimaEase.new()
	ease.kind = AnimaEase.Kind.CUSTOM_SAMPLED
	ease.custom_samples = PackedFloat32Array([0.0, 0.5, 1.0])

	assert_almost_eq(ease.evaluate(0.0), 0.0, 0.0001)
	assert_almost_eq(ease.evaluate(0.5), 0.5, 0.0001)
	assert_almost_eq(ease.evaluate(1.0), 1.0, 0.0001)
	assert_almost_eq(ease.evaluate(0.25), 0.25, 0.0001)
