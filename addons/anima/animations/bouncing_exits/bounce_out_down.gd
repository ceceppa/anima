var KEYFRAMES := {
	20: {
		y = 10,
		"scale:y": 0.985,
	},
	[40, 45]: {
		opacity = 1,
		y = -20,
		"scale:y": 0.9
	},
	100: {
		opacity = 0,
		y = "..:size:y + ..:position:y",
		"scale:y": 3
	}
}
