var KEYFRAMES := {
	[0, 60, 75, 90, 100]: {
		easing = [0.215, 0.61, 0.355, 1],
	},
	0: {
		"opacity": 0,
		"translate:x": "- :size:x - :position:x",
		"scale:x": 3,
	},
	60: {
		"opacity": 1,
		"translate:x": 25,
		"scale:x": 0.9
	},
	75: {
		"translate:x": -10,
		"scale:x": 0.95
	},
	90: {
		"translate:x": 5,
		"scale:x": 0.985,
	},
	100: {
		"translate:x": 0,
		"scale:x": 1.0
	},
	"initial_values": {
		opacity = 0,
	}
}
