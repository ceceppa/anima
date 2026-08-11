@tool

extends Panel

func play() -> void:
	await (
		Anima.on(%Vanilla)
			.move_by(Vector2(0, -%Vanilla.get_rect().size.y), 0.3)
			.with_ease(AnimaEase.Kind.EASE_OUT_QUAD)
			.with(
				Anima.on(%Anima)
					.move_by(Vector2(0, %AnimaPanel.get_rect().size.y), 0.3)
					.with_ease(AnimaEase.Kind.EASE_OUT_QUAD)
			).with(
				Anima.on(self).color(Color.TRANSPARENT, 0.3)
			).play()
	).finished
