var KEYFRAMES := {
	0: {
		rotation = 0,
	},
	[20, 60]: {
		rotation = deg_to_rad(80),
		easing = ANIMA.EASING.EASE_IN_OUT,
	},
	[40, 80]: {
		rotation = deg_to_rad(60),
		opacity = 1,
		easing = ANIMA.EASING.EASE_IN_OUT,
	},
	81: {
		"translate:y": 0,
	},
	100: {
		"translate:y": 700,
		"opacity": 0
	},
	"easing": ANIMA.EASING.EASE_IN_OUT,
	"pivot": ANIMA.PIVOT.TOP_LEFT
}
