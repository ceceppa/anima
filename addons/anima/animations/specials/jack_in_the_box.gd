var KEYFRAMES := {
	0: {
		opacity = 0,
		scale = Vector3(0.1, 0.1, 0.1),
		rotation = deg_to_rad(30),
	},
	50: {
		rotation = deg_to_rad(-10),
	},
	70: {
		rotation = deg_to_rad(3),
	},
	100: {
		opacity = 1,
		scale = Vector3.ONE,
		rotation = 0
	},
	"pivot": ANIMA.PIVOT.BOTTOM_CENTER
}
