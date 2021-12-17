func generate_animation(node: Node) -> Dictionary:
	var size = AnimaNodesProperties.get_size(node)

	return {
		0: {
			x = 0,
			rotate = 0,
			opacity = 1,
		},
		100: {
			x = size.x * 3,
			rotate = 120,
			opacity = 0
		},
		pivot = Anima.PIVOT.CENTER,
		relative = ['x']
	}
