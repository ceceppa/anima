var KEYFRAMES := {
	0: {
		"translate:x": "-:size:x",
		opacity = 0,
		"skew:x": 0.3,
	},
	60: {
		"skew:x": -0.2,
		opacity = 1,
	},
	80: {
		"skew:x": 0.5,
	},
	100: {
		"translate:x": 0.0,
		"skew:x": 0.0
	},
	easing = ANIMA.EASING.EASE_OUT,
	initial_values = {
		opacity = 0,
	}
}
