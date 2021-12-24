func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var opacity_frames = [
		{ from = 0, to = 1 },
	]

	var size = AnimaNodesProperties.get_size(data.node)

	var position_frames = [
		{ from = size.y },
	]

	anima_tween.add_relative_frames(data, "y", position_frames)
	anima_tween.add_frames(data, "opacity", opacity_frames)
