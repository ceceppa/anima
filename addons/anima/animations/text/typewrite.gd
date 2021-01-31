func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> float:
	var node = data.node
	var duration_per_char = data.duration

	if not node.has_method('set_visible_characters'):
		printerr('This animation works only with nodes that have the "visible_characters" property. Example: Label, RichText ')

		return duration_per_char

	var l = node.text.length()
	var real_duration = duration_per_char * l

	anima_tween.add_frames(data, 'visible_characters', [{ from = 0, to = l, duration = real_duration }])

	return real_duration

#func generate_animation(animation: Animation, node: CanvasItem, duration_per_char: float, delay: float) -> float:
#	if not node.has_method('set_visible_characters'):
#		printerr('This animation works only with nodes that have the "visible_characters" property. Example: Label, RichText ')
#
#		return duration_per_char
#
#	var real_duration = duration_per_char * node.text.length()
#
#	var track_index = animation.add_track(Animation.TYPE_VALUE)
#	var node_path = str(node.get_path())
#
#	animation.track_set_path(track_index, node_path + ":visible_characters")
#
#	animation.track_insert_key(track_index, delay + 0, 0)
#	animation.track_insert_key(track_index, delay + real_duration, node.text.length())
#
#	return real_duration
