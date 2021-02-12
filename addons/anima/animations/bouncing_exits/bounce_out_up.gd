func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var y_frames = [
		{ percentage = 0, to = 0 },
		{ percentage = 20, to = -10 },
		{ percentage = 40, to = 30 },
		{ percentage = 45, to = 0 },
		{ percentage = 100, to = -2000 },
	]

	var scale_frames = [
		{ percentage = 0, from = 1 },
		{ percentage = 20, to =0.985 },
		{ percentage = 40, to = 0.9 },
		{ percentage = 45, to = 0.9 },
		{ percentage = 100, to = 3 },
	]

	var opacity_frames = [
		{ percentage = 0, from = 1 },
		{ percentage = 20, to = 1 },
		{ percentage = 40, to = 1 },
		{ percentage = 45, to = 1 },
		{ percentage = 100, to = 0 },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_relative_frames(data, "y", y_frames)
	anima_tween.add_frames(data, "scale:y", scale_frames)
	anima_tween.add_frames(data, "opacity", opacity_frames)
