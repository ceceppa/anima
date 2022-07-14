var KEYFRAMES := {
	[0, 100]: {
		scale = Vector3.ONE,
		"rotate:y": 0,
	},
	[10, 20]: {
		scale = Vector3(0.9, 0.9, 0.9),
		"rotate:y": -3
	},
	[30, 50, 70, 90]: {
		scale = Vector3(1.1, 1.1, 1.1),
		"rotate:y": 3
	},
	[40, 60, 80]: {
		scale = Vector3(1.1, 1.1, 1.1),
		"rotate:y": -3
	},
	pivot = ANIMA.PIVOT.CENTER
}
