func generate_animation(node: Node) -> Dictionary:
	return {
		0: {
			opacity = 0,
			x = -20,
		}, 
		100: {
			opacity = 1,
			x = 0
		},
		relative = ["x"]
	}
