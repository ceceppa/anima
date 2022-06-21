tool
extends WindowDialog

func _ready():
	if not is_connected("popup_hide", self, "_on_hide"):
		connect("popup_hide", self, "_on_hide")

	rect_clip_content = false

func _play(backwards := false) -> AnimaNode:
	var anima = Anima.begin_single_shot(self)
	anima.then(
		Anima.Node(self) \
			.anima_animation_frames({
				0: {
					size = Vector2(1024, 0),
					opacity = 0,
					y = 600,
				},
				100: {
					size = Vector2(1024, 600),
					opacity = 1,
					y = 0,
					easing = ANIMA.EASING.EASE_IN_OUT_BACK
				},
				initial_values = {
					opacity = 0,
				},
			}, 0.3)
	)
	
	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	return anima

func popup_centered(size := Vector2.ZERO) -> void:
	rect_scale = Vector2.ONE
	rect_size = Vector2(1024, 600)
	rect_min_size = Vector2(1024, 0)

	.popup_centered(rect_size)

	_play()

	_on_popup_visible()

func _on_popup_visible() -> void:
	pass

func _on_hide() -> void:
	show()

	yield(_play(true), 'animation_completed')

	hide()
