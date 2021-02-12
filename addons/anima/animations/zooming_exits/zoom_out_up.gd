func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var size = AnimaNodesProperties.get_size(data.node)

	var zoom_frames = [
		{ percentage = 0, from = Vector2(0.3, 0.3), easing_points = [0.55, 0.055, 0.675, 0.19] },
		{ percentage = 100, to = Vector2(0.475, 0.475), easing_points = [0.175, 0.885, 0.32, 1] },
	]

	var opacity_frames = [
		{ from = 1, to = 0 },
	]

	var position_frames = [
		{ percentage = 0, from = 60, easing_points = [0.55, 0.055, 0.675, 0.19] },
		{ percentage = 100, to = -2000, easing_points = [0.175, 0.885, 0.32, 1] },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_frames(data, "opacity", opacity_frames)
	anima_tween.add_frames(data, "scale", zoom_frames)
	anima_tween.add_relative_frames(data, "y", position_frames)
