func generate_animation(node: Node) -> Dictionary:
	return {
		0: {
			x = 0,
		},
		6.5: {
			x = -6,
			rotate = -9
		},
		18.5: {
			x = 5,
			rotate = 7
		},
		31.5: {
			x = -3,
			rotate = -5
		},
		43.5: {
			x = 2,
			rotate = 3
		},
		50: {
			x = 0,
			rotate = 0
		},
		relative = ['x']
	}
