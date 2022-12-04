extends "res://addons/gut/test.gd"

func test_sprint_with_no_parameters():
	var easing_data = AnimaEasing.get_easing_points("spring")

	assert_eq_deep(easing_data, {
		fn = "__spring",
		mass = 1.0,
		damping = 10.0,
		stiffness = 100.0,
		velocity = 0.0
	})

func test_sprint_with_one_param():
	var easing_data = AnimaEasing.get_easing_points("spring(42)")

	assert_eq_deep(easing_data, {
		fn = "__spring",
		mass = 42.0,
		damping = 10.0,
		stiffness = 100.0,
		velocity = 0.0
	})

func test_sprint_with_two_param():
	var easing_data = AnimaEasing.get_easing_points("spring(, 142)")

	assert_eq_deep(easing_data, {
		fn = "__spring",
		mass = 1.0,
		damping = 10.0,
		stiffness = 142.0,
		velocity = 0.0
	})
