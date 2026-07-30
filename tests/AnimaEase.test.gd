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
	var kinds = [AnimaEase.Kind.LINEAR, AnimaEase.Kind.POLYNOMIAL, AnimaEase.Kind.SINE, AnimaEase.Kind.EXPONENTIAL, AnimaEase.Kind.CIRCULAR]

	for kind in kinds:
		var ease := AnimaEase.new()
		ease.kind = kind

		assert_almost_eq(ease.evaluate(0.0), 0.0, 0.0001)
		assert_almost_eq(ease.evaluate(1.0), 1.0, 0.0001)

func test_non_linear_kinds_differ_from_linear_at_midpoint():
	var linear := AnimaEase.new()
	linear.kind = AnimaEase.Kind.LINEAR
	var linear_midpoint = linear.evaluate(0.5)

	var non_linear_kinds = [AnimaEase.Kind.POLYNOMIAL, AnimaEase.Kind.SINE, AnimaEase.Kind.EXPONENTIAL, AnimaEase.Kind.CIRCULAR]

	for kind in non_linear_kinds:
		var ease := AnimaEase.new()
		ease.kind = kind

		assert_ne(ease.evaluate(0.5), linear_midpoint)
