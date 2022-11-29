extends "res://addons/gut/test.gd"

func test_flatten_keyframes_data():
	var keyframes_data = AnimaKeyframesEngine.flatten_keyframes_data({
		["from", 10]: {
			opacity = 0,
		},
		[50, 23]: {
			opacity = 1
		},
		[12, "to"]: {
			opacity = 0
		}
	})
	
	assert_eq_deep(keyframes_data, [
		{ percentage = 0, data = { opacity = 0 } },
		{ percentage = 10, data = { opacity = 0 } },
		{ percentage = 12, data = { opacity = 0 } },
		{ percentage = 23, data = { opacity = 1 } },
		{ percentage = 50, data = { opacity = 1 } },
		{ percentage = 100, data = { opacity = 0 } },
	])


func test_first_fame_contains_all_the_unique_animation_keys():
	var keyframes_data = AnimaKeyframesEngine.flatten_keyframes_data({
		["from", 10]: {
			opacity = 0,
		},
		[50]: {
			scale = 1,
			x = 2,
		},
		["to"]: {
			something = 0,
			x = -2
		}
	})
	
	assert_eq_deep(keyframes_data, [
		{ percentage = 0, data = {opacity = 0, scale = null, something = null } },
		{ percentage = 10, data = { opacity = 0 } },
		{ percentage = 50, data = { scale = 1, x = 2 } },
		{ percentage = 100, data = { something = 0, x = -2 } },
	])

func test_strips_all_the_non_percentage_keys():
	var keyframes_data = AnimaKeyframesEngine.flatten_keyframes_data({
		[50, "what"]: {
			scale = 1,
		},
		ciao = {
			scale = 0
		}
	})
	
	assert_eq_deep(keyframes_data, [
		{ percentage = 0, data = { scale = null } },
		{ percentage = 50, data = { scale = 1 } },
	])
