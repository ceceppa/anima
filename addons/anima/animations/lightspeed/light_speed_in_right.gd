var KEYFRAMES := {
	0: {
		"translate:x": ":size:x",
		opacity = 0,
		"skew:x": -30,
	},
	60: {
		"skew:x": 20,
		opacity = 1,
	},
	80: {
		"skew:x": -5,
	},
	100: {
		"translate:x": 0,
		"skew:x": 0
	},
	easing = ANIMA.EASING.EASE_OUT,
	initial_values = {
		opacity = 0,
	}
}

