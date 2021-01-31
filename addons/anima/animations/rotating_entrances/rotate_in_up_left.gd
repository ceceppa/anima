func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var opacity_frames = [
		{ percentage = 0, from = 0 },
		{ percentage = 100, to = 1 },
	]

	var rotate_frames = [
		{ percentage = 0, from = 45, pivot = Anima.PIVOT.LEFT_BOTTOM },
		{ percentage = 100, to = 0 },
	]

	anima_tween.add_frames(data, "opacity", opacity_frames)
	anima_tween.add_frames(data, "rotation", rotate_frames)
