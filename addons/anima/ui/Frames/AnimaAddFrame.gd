tool
extends AnimaRectangle

func _ready():
	var anima: AnimaNode = Anima.begin_single_shot(self)

	anima.set_default_duration(0.3)

	var dotted = $AddButton/Dotted

	dotted.rect_position = (self.rect_position - dotted.rect_position) / 2

	anima.then(
		Anima.Node($AddButton).anima_fade_in().anima_initial_value(0)
	)
	anima.with(
		Anima.Node($AddButton/Dotted/Plus/Vertical) \
			.anima_animation_frames({
				from = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2.ZERO),
					rotate = -45,
				},
				to = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(5, 40)),
					rotate = 0,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node($AddButton/Dotted/Plus/Horizontal) \
			.anima_animation_frames({
				from = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2.ZERO),
					rotate = -45,
				},
				to = {
					PROPERTIES.RECTANGLE_SIZE.name: Rect2(Vector2.ZERO, Vector2(40, 5)),
					rotate = 0,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)

	anima.play_with_delay(1.0)

func _on_AddButton_mouse_entered():
	$AddButton.set_size(Vector2(1.2, 1.2))
