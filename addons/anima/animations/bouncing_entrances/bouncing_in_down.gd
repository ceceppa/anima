var KEYFRAMES := {
	[0, 60, 75, 90, 100]: {
		easing = [0.215, 0.61, 0.355, 1],
	},
	0: {
		opacity = 0,
		y = "- :size:y - :position:y",
		"scale:y": 3,
	},
	60: {
		opacity = 1,
		y = 25,
		"scale:y": 0.9
	},
	75: {
		y = -10,
		"scale:y": 0.95
	},
	90: {
		y = 5,
		"scale:y": 0.985,
	},
	100: {
		y = 0,
		"scale:y": 1.0
	},
	initial_values = {
		opacity = 0
	}
}
