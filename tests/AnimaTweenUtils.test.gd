extends "res://addons/gut/test.gd"

func test_it_works_if_calculated_value_is_null():
	var node := Button.new()

	var test_data := {
		_easing_points = null,
		_is_first_frame = true,
		_wait_time = 0,
		duration = 0.15,
		node = node,
		property = "modulate",
		to = Color(0.019608,0.266667,0.368627,1)
	}
	
	var output = AnimaTweenUtils.calculate_from_and_to(test_data)

	assert_typeof(output, TYPE_DICTIONARY)

	node.free()
