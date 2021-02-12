func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var y_frames = [
		{ percentage = 0, to = 3000, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 60, to = -3025, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 75, to = 35, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 90, to = -15, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 100, to = 5, easing_points = [0.215, 0.61, 0.355, 1] },
	]

	var scale_frames = [
		{ percentage = 0, from = 3, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 60, to = 0.9, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 75, to = 0.95, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 90, to = 0.985, easing_points = [0.215, 0.61, 0.355, 1] },
		{ percentage = 100, to = 1, easing_points = [0.215, 0.61, 0.355, 1] },
	]

	var opacity_frames = [
		{ percentage = 0, from = 0 },
		{ percentage = 60, to = 1 }
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_relative_frames(data, "y", y_frames)
	anima_tween.add_frames(data, "scale:y", scale_frames)
	anima_tween.add_frames(data, "opacity", opacity_frames)
