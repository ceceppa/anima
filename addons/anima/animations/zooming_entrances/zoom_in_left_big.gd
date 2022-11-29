var KEYFRAMES := {
	0: {
		opacity = 0,
		scale = Vector3(0.1, 0.1, 0.1),
		"translate:x": "- :size:x - ..:size:x",
		easing = [0.55, 0.055, 0.675, 0.19]
	},
	60: {
		opacity = 1,
		scale = Vector3(0.475, 0.475, 0.475),
		"translate:x": 10,
		easing = [0.175, 0.885, 0.32, 0.1]
	},
	100: {
		opacity = 1,
		scale = Vector3.ONE,
		"translate:x": 1,
	},
	initial_values = {
		opacity = 0,
	}
}
