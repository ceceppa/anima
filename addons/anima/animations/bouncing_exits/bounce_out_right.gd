func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var x_frames = [
		{ percentage = 0, to = 0 },
		{ percentage = 20, to = -20 },
		{ percentage = 100, to = 2000 },
	]

	var scale_frames = [
		{ percentage = 0, from = 1 },
		{ percentage = 20, to = 0.9 },
		{ percentage = 100, to = 2 },
	]

	var opacity_frames = [
		{ percentage = 0, from = 1 },
		{ percentage = 20, to = 1 },
		{ percentage = 100, to = 0 },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_relative_frames(data, "x", x_frames)
	anima_tween.add_frames(data, "scale:y", scale_frames)
	anima_tween.add_frames(data, "opacity", opacity_frames)
