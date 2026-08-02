extends "res://addons/gut/test.gd"

func test_default_values():
	var motion := AnimaMotion.new()

	assert_eq(motion.display_name, "")
	assert_eq(motion.enabled, true)
	assert_eq(motion.delay, 0.0)
	assert_eq(motion.delay_basis, AnimaMotion.DelayBasis.AFTER_PREVIOUS_ENDS)
	assert_eq(motion.speed, 1.0)
	assert_eq(motion.tags, [])
	assert_eq(motion.metadata, {})

func _leaf(display_name: String) -> AnimaMotion:
	var motion := AnimaMotion.new()
	motion.display_name = display_name
	return motion

func test_then_builds_a_two_step_sequence():
	var a := _leaf("a")
	var b := _leaf("b")

	var result := a.then(b)

	assert_true(result is AnimaSequence)
	assert_eq(result.children, [a, b])

func test_repeated_then_calls_flatten_into_one_sequence_instead_of_nesting():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")

	var result := a.then(b).then(c)

	assert_eq(result.children, [a, b, c])

func test_with_builds_a_two_child_parallel():
	var a := _leaf("a")
	var b := _leaf("b")

	var result := a.with(b)

	assert_true(result is AnimaParallel)
	assert_eq(result.children, [a, b])

func test_repeated_with_calls_join_one_parallel_group_instead_of_nesting():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")

	var result := a.with(b).with(c)

	assert_true(result is AnimaParallel)
	assert_eq(result.children, [a, b, c])

func test_with_after_then_groups_only_the_most_recent_step():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")

	var result := a.then(b).with(c)

	assert_true(result is AnimaSequence)
	assert_eq(result.children.size(), 2)
	assert_eq(result.children[0], a)
	assert_true(result.children[1] is AnimaParallel)
	assert_eq(result.children[1].children, [b, c])

func test_then_after_with_starts_a_new_step_leaving_the_earlier_group_intact():
	var a := _leaf("a")
	var b := _leaf("b")
	var c := _leaf("c")
	var d := _leaf("d")

	var result := a.with(b).then(c).with(d)

	assert_true(result is AnimaSequence)
	assert_eq(result.children.size(), 2)
	assert_true(result.children[0] is AnimaParallel)
	assert_eq(result.children[0].children, [a, b])
	assert_true(result.children[1] is AnimaParallel)
	assert_eq(result.children[1].children, [c, d])
