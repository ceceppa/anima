func generate_animation(node: Node) -> Dictionary:
	return {
		0: {
			y = 0
		},
		[10, 30, 50, 70, 90]: {
			y = -10,
		},
		[20, 40, 60, 80]: {
			y = 10
		},
		100: {
			y = 0
		},
	}
