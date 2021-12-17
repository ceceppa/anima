func generate_animation(node: Node) -> Dictionary:
	return {
		0: {
			opacity = 0,
			scale = Vector2(0.3, 0.3),
			y = 1000,
			easing = [0.55, 0.055, 0.675, 0.19],
			pivot = Anima.PIVOT.CENTER
		},
		60: {
			opacity = 1,
			scale = Vector2(0.475, 0.475),
			y = -60,
			easing = [0.175, 0.885, 0.32, 1]
		},
		100: {
			scale = Vector2(1, 1),
			y = 0
		},
		relative = ["y"]
	}
