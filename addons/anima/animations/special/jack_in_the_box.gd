func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var size = AnimaNodesProperties.get_size(data.node)

	var scale_frames = [
		{ percentage = 0 ,from = Vector2(0.1, 0.1) },
		{ percentage = 50, to = Vector2(1, 1) },
	]

	var rotate_frames = [
		{ percentage = 0, from = 30 },
		{ percentage = 50, to = -10 },
		{ percentage = 70, to = 3 },
		{ percentage = 100, to = 0 },
	]

	var opacity_frames = [
		{ from = 0, to = 1 },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER_BOTTOM)

	anima_tween.add_frames(data, "opacity", opacity_frames)
	anima_tween.add_frames(data, "rotation", rotate_frames)
	anima_tween.add_frames(data, "scale", scale_frames)
