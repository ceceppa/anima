extends "res://addons/gut/test.gd"

func test_default_kind_is_fixed():
	var duration := AnimaDuration.new()

	assert_eq(duration.kind, AnimaDuration.Kind.FIXED)
	assert_eq(duration.seconds, 0.0)

func test_fixed_factory_sets_kind_and_seconds():
	var duration := AnimaDuration.fixed(2.4)

	assert_eq(duration.kind, AnimaDuration.Kind.FIXED)
	assert_eq(duration.seconds, 2.4)

func test_dynamic_factory_sets_kind_dynamic():
	var duration := AnimaDuration.dynamic()

	assert_eq(duration.kind, AnimaDuration.Kind.DYNAMIC)

func test_worst_kind_picks_the_least_certain_kind():
	var durations: Array[AnimaDuration] = [
		AnimaDuration.fixed(1.0),
		AnimaDuration.dynamic(),
		AnimaDuration.fixed(2.0),
	]

	assert_eq(AnimaDuration.worst_kind(durations), AnimaDuration.Kind.DYNAMIC)

func test_worst_kind_of_all_fixed_is_fixed():
	var durations: Array[AnimaDuration] = [
		AnimaDuration.fixed(1.0),
		AnimaDuration.fixed(2.0),
	]

	assert_eq(AnimaDuration.worst_kind(durations), AnimaDuration.Kind.FIXED)
