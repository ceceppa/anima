tool
extends WindowDialog

var _anima: AnimaNode

func _ready() -> void:
	_anima = Anima.begin(self)
	_anima.then(
		Anima.Node(self) \
			.anima_animation_frames({
				0: {
					size = Vector2(1024, 0),
					opacity = 0,
					y = 0,
				},
				100: {
					size = Vector2(1024, 600),
					opacity = 1,
					y = - 300,
					easing = Anima.EASING.EASE_IN_OUT_BACK
				},
				initial_values = {
					opacity = 0,
				},
			}, 0.3)
	)

	rect_clip_content = false

	if not is_connected("popup_hide", self, "_on_hide"):
		connect("popup_hide", self, "_on_hide")

func popup_centered(size := Vector2.ZERO) -> void:
	rect_scale = Vector2.ONE
	rect_size = Vector2(1024, 0)
	rect_min_size = Vector2(1024, 0)

	.popup_centered(rect_size)
	_anima.play()

	_on_popup_visible()

func _on_popup_visible() -> void:
	pass

func _on_hide() -> void:
	show()

	_anima.play_backwards_with_speed(1.5)

	yield(_anima, 'animation_completed')

	hide()
