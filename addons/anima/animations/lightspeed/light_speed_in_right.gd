var KEYFRAMES := {
	0: {
		"translate:x": ":size:x",
		"opacity": 0,
		"skew:x": deg_to_rad(-30),
	},
	60: {
		"skew:x": deg_to_rad(20),
		"opacity": 1,
	},
	80: {
		"skew:x": deg_to_rad(-5),
	},
	100: {
		"translate:x": 0,
		"skew:x": 0
	},
	"easing": ANIMA.EASING.EASE_OUT,
	"initial_values": {
		opacity = 0,
	}
}

