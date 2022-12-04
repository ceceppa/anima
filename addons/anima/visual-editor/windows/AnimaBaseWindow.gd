@tool
extends Window

var _final_size := Vector2(1024, 600)

func _ready():
	if not is_connected("popup_hide",Callable(self,"_on_hide")):
		connect("popup_hide",Callable(self,"_on_hide"))

	clip_contents = false

func _play(backwards := false) -> AnimaNode:
	var anima = Anima.begin_single_shot(self)
	anima.then(
		Anima.Node(self) \
			super.anima_animation_frames({
				0: {
					size = Vector2(_final_size.x, 0),
					opacity = 0,
					pivot = ANIMA.PIVOT.CENTER,
				},
				10: {
					y = 100,
					easing = ANIMA.EASING.EASE_IN_OUT_BACK
				},
				100: {
					size = _final_size,
					opacity = 1,
					y = 0,
					easing = ANIMA.EASING.EASE_IN_OUT_BACK
				},
				initial_values = {
					opacity = 0,
				},
				relative = ["y"]
			}, 0.3)
	)
	
	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	return anima

func popup_centered(size := Vector2.ZERO) -> void:
	scale = Vector2.ONE
	size = _final_size
	minimum_size = Vector2(_final_size.x, 0)

	super.popup_centered(size)

	_play()

	_on_popup_visible()

func _on_popup_visible() -> void:
	pass

func _on_hide() -> void:
	show()

	await _play(true).animation_completed

	hide()
