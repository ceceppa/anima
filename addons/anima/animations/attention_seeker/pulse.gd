func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var frames = [
		{ percentage = 0, from = Vector2(1, 1) },
		{ percentage = 50, to = Vector2(1.05, 1.05), easing = Anima.EASING.EASE_IN_OUT_SINE },
		{ percentage = 100, to = Vector2(1, 1) },
	]

	AnimaNodesProperties.set_2D_pivot(data.node, Anima.PIVOT.CENTER)

	anima_tween.add_frames(data, "scale", frames)
