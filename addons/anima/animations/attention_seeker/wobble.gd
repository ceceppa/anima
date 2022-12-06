var KEYFRAMES := {
	[0, 100]: {
		"translate:x": 0,
		"rotate:y": 0
	},
	15: {
		"translate:x": ":size:x * -0.25",
		"rotate:y": -deg_to_rad(5)
	},
	30: {
		"translate:x": ":size:x * 0.2",
		"rotate:y": deg_to_rad(3)
	},
	45: {
		"translate:x": ":size:x * -0.15",
		"rotate:y": -deg_to_rad(3)
	},
	60: {
		"translate:x": ":size:x * 0.1",
		"rotate:y": deg_to_rad(2)
	},
	75: {
		"translate:x": ":size:x * -0.05",
		"rotate:y": -deg_to_rad(1)
	},
	"pivot": ANIMA.PIVOT.CENTER,
}
