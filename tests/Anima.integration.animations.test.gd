extends "res://addons/gut/test.gd"

func test_multiple_fade_in():
	var node1 = Control.new()
	var node2 = Control.new()
	var node3 = Control.new()

	var anima = Anima.begin(self, 'sequence_callback') \
		.set_visibility_strategy(ANIMA.VISIBILITY.TRANSPARENT_ONLY)

	anima.then( Anima.Node(node1).anima_animation("flash", 1 ) )
	
	assert_eq(anima.get_duration(), 1.0)

	anima.then( Anima.Node(node2).anima_animation("flash", 1) )

	assert_eq(anima.get_duration(), 2.0)

	anima.then( Anima.Node(node3).anima_animation("flash", 1) )

	assert_eq(anima.get_duration(), 3.0)

	var data = anima.get_animation_data()

	print(data)

	assert_eq(data.size(), 12)

	assert_eq_deep(data, [
		{_easing_points = null, _is_first_frame = true, _wait_time = 0.0, duration = 0.25, from = 1, node = node1, property = "opacity", to = 0, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 0.25, duration = 0.25, from = 0, node = node1, property = "opacity", to = 1, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 0.5, duration = 0.25, from = 1, node = node1, property = "opacity", to = 0, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 0.75, duration = 0.25, from = 0, node = node1, property = "opacity", to = 1, easing = null},
		{_easing_points = null, _is_first_frame = true, _wait_time = 1.0, duration = 0.25, from = 1, node = node2, property = "opacity", to = 0, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 1.25, duration = 0.25, from = 0, node = node2, property = "opacity", to = 1, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 1.5, duration = 0.25, from = 1, node = node2, property = "opacity", to = 0, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 1.75, duration = 0.25, from = 0, node = node2, property = "opacity", to = 1, easing = null},
		{_easing_points = null, _is_first_frame = true, _wait_time = 2.0, duration = 0.25, from = 1, node = node3, property = "opacity", to = 0, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 2.25, duration = 0.25, from = 0, node = node3, property = "opacity", to = 1, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 2.5, duration = 0.25, from = 1, node = node3, property = "opacity", to = 0, easing = null},
		{_easing_points = null, _is_first_frame = false, _wait_time = 2.75, duration = 0.25, from = 0, node = node3, property = "opacity", to = 1, easing = null}
	] )
	
	anima.free()
	node1.free()
	node2.free()
	node3.free()
