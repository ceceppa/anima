tool
extends MarginContainer


func _get_anima_node():
	var anima = Anima.begin(self)

	Anima.register_animation(self, 'card_in')
	Anima.register_animation(self, 'show_details')

	anima.then({ node = $CardPanel, animation = 'card_in', duration = 0.3 })
	anima.then({ node = $CardPanel/Info, animation = 'show_details', duration = 0.3, delay = 0.1 })
	anima.with({ node = $CardPanel/Info/Title, animation = 'typewrite', duration = 0.3 })
	anima.with({ node = $CardPanel/Info/Subtitle, animation = 'typewrite', duration = 0.3, delay = 0.15 })

	anima.set_visibility_strategy(Anima.VISIBILITY.TRANSPARENT_ONLY)

func generate_animation(anima_tween: AnimaTween, data: Dictionary) -> void:
	var frames := {}

	if data.animation == 'card_in':
		frames = _card_in_animation()
	else:
		frames = _show_details_animation()

	for key in frames:
		anima_tween.add_frames(data, key, frames[key])

func _card_in_animation() -> Dictionary:
	var scale_frames := [ { from = Vector2(0.7, 0.7), to = Vector2(1, 1), easing = Anima.EASING.EASE_OUT_BACK, pivot = Anima.PIVOT.CENTER }]
	var opacity_frames := [ { from = 0, to = 1 }]

	return {
		scale = scale_frames,
		opacity = opacity_frames
	}

func _show_details_animation() -> Dictionary:
	var y_frames := [ { from = 30, to = -30, relative = true, easing = Anima.EASING.EASE_OUT_BACK }]
	var opacity_frames := [ { from = 0, to = 1 }]

	return {
		y = y_frames,
		opacity = opacity_frames
	}

func _on_CardPanel_mouse_entered():
	pass # Replace with function body.
