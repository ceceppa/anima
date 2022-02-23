tool
extends Control

signal frame_deleted

func _ready():
	var frame_name = find_node("FrameName")

	frame_name.set_initial_value("Frame01")
	frame_name.set_placeholder("Frame01")

	_animate_me()

func _animate_me(backwards := false) -> AnimaNode:
	var anima: AnimaNode = Anima.begin_single_shot(self)
	
	anima.set_default_duration(0.3)

	anima.then(
		Anima.Node(self) \
			.anima_animation_frames({
				from = {
					"size:x": 0,
					"min_size:x": 0,
				},
				to = {
					"size:x": 360,
					"min_size:x": 360,
				},
				easing = Anima.EASING.EASE_OUT_BACK
			})
	)
	anima.with(
		Anima.Node($Rectangle).anima_fade_in().anima_initial_value(0)
	)
	anima.with(
		Anima.Group($Rectangle/AddContainer/HBoxContainer, 0.05).anima_animation_frames({
			from = {
				scale = Vector2(0.1, 0.1),
				opacity = 0,
			},
			to = {
				scale = Vector2.ONE,
				opacity = 1,
				easing = Anima.EASING.EASE_OUT_BACK
			},
			initial_values = {
				opacity = 0,
			}
		}).anima_delay(0.1)
	)
	anima.with(
		Anima.Group($Rectangle/MarginContainer/VBoxContainer, 0.05) \
			.anima_animation_frames({
				from = {
					y = 40,
					opacity = 0,
				},
				to = {
					y = 0,
					opacity = 1,
					easing = Anima.EASING.EASE_OUT_BACK
				},
				initial_values = {
					opacity = 0
				}
			})
	)

	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	return anima

func _on_Delete_pressed():
	var anima := _animate_me(true)

	yield(anima, "animation_completed")

	queue_free()
	emit_signal("frame_deleted")
