var KEYFRAMES := {
	[0, 20, 40, 60, 80, 100]: {
		easing = [0.215, 0.61, 0.355, 1],
	},
	0: {
		opacity = 0,
		scale = Vector3(0.3, 0.3, 0.3)
	},
	20: {
		scale = Vector3(1.1, 1.1, 1.1)
	},
	40: {
		scale = Vector3(0.9, 0.9, 0.9),
	},
	60: {
		opacity = 1,
		scale = Vector3(1.03, 1.03, 1.03)
	},
	80: {
		scale = Vector3(0.97, 0.97, 0.97)
	},
	100: {
		opacity = 1,
		scale = Vector3.ONE
	},
	initial_values = {
		opacity = 0
	}
}
