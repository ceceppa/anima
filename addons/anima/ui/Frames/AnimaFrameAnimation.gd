tool
extends Control

signal frame_deleted

export (bool) var is_initial_frame := false setget set_is_initial_frame

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
		Anima.Group(find_node("ContentContainer"), 0.05) \
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
	anima.with(
		Anima.Group(find_node("CTAContainer"), 0.05).anima_animation_frames({
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

	rect_clip_content = true

	if backwards:
		anima.play_backwards_with_speed(1.5)
	else:
		anima.play()

	yield(anima, "animation_completed")

	rect_clip_content = false

	return anima

func set_is_initial_frame(is_initial: bool) -> void:
	is_initial_frame = is_initial

	var frame_name = find_node("FrameName")
	var remove = find_node("RemoveWrapper")

	frame_name.set_initial_value("Initial Values")
	frame_name.can_edit_value = not is_initial
	frame_name.can_clear_custom_value = not is_initial

	if is_initial:
		frame_name.label = "Initial Values"

	remove.visible = not is_initial
	find_node("PlayContainer").visible = not is_initial
	find_node("DurationContainer").visible = not is_initial

func _on_Delete_pressed():
	yield(_animate_me(true), "completed")

	queue_free()
	emit_signal("frame_deleted")
