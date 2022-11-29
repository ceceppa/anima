extends "res://addons/gut/test.gd"

func test_returns_empty_array_when_only_from():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				opacity = 1
			}
		})

	assert_eq_deep(output, [])

	node.free()

func test_parse_only_to_animation():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			to = {
				opacity = 1
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = null, to = 1, duration = 3.0, _wait_time = 0.0 }
	])

	node.free()

func test_parse_simple_from_to_animation():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				opacity = 0,
			},
			to = {
				opacity = 1
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 3.0, _wait_time = 0.0 }
	])

	node.free()

func test_parse_all_the_properties():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				opacity = 0,
				scale = Vector2.ZERO
			},
			to = {
				opacity = 1,
				scale = Vector2.ONE
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 3.0, _wait_time = 0.0 },
		{ node = node, property = "scale", from = Vector2.ZERO, to = Vector2.ONE, duration = 3.0, _wait_time = 0.0 }
	])

	node.free()

func test_parse_all_the_percentage():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				opacity = 0,
			},
			25: {
				opacity = 1,
			},
			50: {
				opacity = 0,
			},
			75: {
				opacity = 1,
			},
			to = {
				opacity = 0,
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 0.75, _wait_time = 0.0 },
		{ node = node, property = "opacity", from = 1, to = 0, duration = 0.75, _wait_time = 0.75 },
		{ node = node, property = "opacity", from = 0, to = 1, duration = 0.75, _wait_time = 1.5 },
		{ node = node, property = "opacity", from = 1, to = 0, duration = 0.75, _wait_time = 2.25 },
	])

	node.free()

func test_handles_missing_properties_in_frames():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				opacity = 0,
				scale = Vector2.ZERO
			},
			50: {
				opacity = 1,
				x = 100,
			},
			75: {
				x = -20,
			},
			to = {
				scale = Vector2.ONE
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 1.5, _wait_time = 0.0 },
		{ node = node, property = "scale", from = Vector2.ZERO, to = Vector2.ONE, duration = 3.0, _wait_time = 0.0 },

		{ node = node, property = "x", from = 100, to = -20, duration = 0.75, _wait_time = 1.5 },
	])

	node.free()

func test_ignores_single_keys_only_present_in_from():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				opacity = 0,
				scale = Vector2.ZERO
			},
			50: {
				x = 100,
			},
			75: {
				x = -20,
			},
			to = {
				opacity = 1
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 3.0, _wait_time = 0.0 },
		{ node = node, property = "x", from = 100, to = -20, duration = 0.75, _wait_time = 1.5 },
	])
	
	node.free()

func test_handles_translations():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				"translate:y": 20,
				"translate:x": 20,
				translate = Vector2(10, 10),
			},
			to = {
				translate = Vector2(-10, -10),
				"translate:x": 0,
				"translate:y": -20,
			}
		})

	assert_eq_deep(output, [
		{ node = node, _wait_time = 0.0, duration = 3.0, from = 20, to = -20, property = "position:y", relative = true },
		{ node = node, _wait_time = 0.0, duration = 3.0, from = 20, to = 0, property = "position:x", relative = true },
		{ node = node, _wait_time = 0.0, duration = 3.0, from = Vector2(10, 10), to = Vector2(-10, -10), property = "position", relative = true }
	])
	node.free()

func test_ignore_equal_initial_and_final_values():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				"translate:y": 20,
				"translate:x": 20,
			},
			50: {
				"translate:x": 20,
			},
			to = {
				"translate:y": 20,
				"translate:x": 0,
			}
		})

	assert_eq_deep(output, [
		{ node = node, _wait_time = 1.5, duration = 1.5, from = 20, to = 0, property = "position:x", relative = true },
	])

	node.free()

func test_adds_the_animation_wait_time():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3, _wait_time = 42 },
		{
			to = {
				opacity = 1
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = null, to = 1, duration = 3.0, _wait_time = 42.0 }
	])

	node.free()

func test_should_set_easing_for_relevant_frames():
	var node := Container.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3, _wait_time = 42 },
		{
			from = {
				opacity = 0,
				easing = ANIMA.EASING.EASE_OUT_BACK
			},
			50: {
				x = -100,
			},
			to = {
				x = 0,
				opacity = 1,
				easing = ANIMA.EASING.EASE_IN_BACK
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 3.0, _wait_time = 42.0, easing = ANIMA.EASING.EASE_OUT_BACK },
		{ node = node, property = "x", from = -100, to = 0, duration = 1.5, _wait_time = 43.5, easing = ANIMA.EASING.EASE_IN_BACK }
	])

	node.free()

func test_should_set_pivot_for_relevant_frames():
	var node := Control.new()
	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3, _wait_time = 42 },
		{
			from = {
				opacity = 0,
				pivot = ANIMA.PIVOT.BOTTOM_CENTER
			},
			50: {
				x = -100,
			},
			to = {
				x = 0,
				opacity = 1,
				pivot = ANIMA.PIVOT.BOTTOM_RIGHT
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "opacity", from = 0, to = 1, duration = 3.0, _wait_time = 42.0, pivot = ANIMA.PIVOT.BOTTOM_CENTER },
		{ node = node, property = "x", from = -100, to = 0, duration = 1.5, _wait_time = 43.5, pivot = ANIMA.PIVOT.BOTTOM_RIGHT }
	])

	node.free()

func test_converts_vector3_to_vector2_if_needed():
	var node := Control.new()

	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				scale = Vector3.ZERO,
			},
			to = {
				scale = Vector3.ONE,
			}
		})

	assert_eq_deep(output, [
		{ node = node, property = "scale", from = Vector2.ZERO, to = Vector2.ONE, duration = 3.0, _wait_time = 0.0 },
	])
	
	node.free()

func test_applies_the_global_pivot_and_easing():
	var node := Control.new()

	var output = AnimaKeyframesEngine.parse_frames(
		{ node = node, duration = 3 },
		{
			from = {
				scale = Vector3.ZERO,
			},
			to = {
				scale = Vector3.ONE,
			},
			pivot = ANIMA.PIVOT.CENTER,
			easing = ANIMA.EASING.EASE_IN
		})

	assert_eq_deep(output, [
		{ node = node, property = "scale", from = Vector2.ZERO, to = Vector2.ONE, duration = 3.0, _wait_time = 0.0, pivot = ANIMA.PIVOT.CENTER, easing = ANIMA.EASING.EASE_IN },
	])
	
	node.free()
