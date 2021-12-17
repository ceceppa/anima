func generate_animation(node: Node) -> Dictionary:
	var shake := {
		0: {
			y = 0
		},
		100: {
			y = 0
		},
		relative = ['x']
	}

	for p in range(10, 90, 20):
		shake[p] = { y = -10 }

	for p in range(20, 80, 20):
		shake[p] = { y = 10 }

	print(shake)
	return shake
