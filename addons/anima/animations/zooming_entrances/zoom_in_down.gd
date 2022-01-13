var KEYFRAMES := {
	0: {
		opacity = 0,
		scale = Vector3(0.3, 0.3, 0.3),
		y = "-:size:y",
		easing = [0.55, 0.055, 0.675, 0.19],
	},
	60: {
		opacity = 1,
		scale = Vector3(0.475, 0.475, 0.475),
		y = 60,
		easing = [0.175, 0.885, 0.32, 1]
	},
	100: {
		scale = Vector3.ONE,
		y = 0
	},
	initial_values = {
		opacity = 0,
	}
}
