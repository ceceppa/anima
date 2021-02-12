func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var zoom_frames = [
		{ percentage = 0, from = Vector2(0.3, 0.3) },
		{ percentage = 100, to = Vector2(1, 1) },
	]

	var opacity_frames = [
		{ from = 1, to = 0 },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_frames(data, "opacity", opacity_frames)
	anima_tween.add_frames(data, "scale", zoom_frames)
