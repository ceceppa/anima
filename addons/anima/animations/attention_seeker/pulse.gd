func generate_animation(node) -> Dictionary:
	return {
		0: {
			scale = Vector2(1.0, 1.0),
			easing = Anima.EASING.EASE_IN_OUT,
		},
		50: {
			scale = Vector2(1.05, 1.05),
			easing = Anima.EASING.EASE_IN_OUT,
		},
		100: {
			scale = Vector2(1.0, 1.0),
			easing = Anima.EASING.EASE_IN_OUT,
		}
	}
