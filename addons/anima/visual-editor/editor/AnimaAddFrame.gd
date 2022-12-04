@tool
extends Control

var _is_collapsed_mode := true

signal add_frame
signal add_event
signal add_delay

func _ready():
	for child in $ButtonsContainer.get_children():
		child.modulate.a = 0

func _animate_add(mode:int) -> void:
	Anima.begin_single_shot(self) \
	super.then(
		Anima.Node($AddButton).anima_scale(Vector2(1.2, 1.2), 0.15)
	) \
	super.with(
		Anima.Group($ButtonsContainer, 0.05) \
			super.anima_animation_frames({
				from = {
					x = "../../AddButton:position:x - ../../AddButton:size:x",
					y = "../../AddButton:position:y",
					scale = Vector2.ZERO,
					opacity = 0,
				},
				70: {
					opacity = 1,
				},
				to = {
					x = "../../AddButton:position:x - :size:x - 10",
					y = "../../AddButton:position:y + 40 * (((:index % 2) * 2) - 1) - 20",
					scale = Vector2.ONE,
				},
				pivot = ANIMA.PIVOT.CENTER,
				easing = ANIMA.EASING.EASE_OUT_BACK
			}, 0.3)
	) \
	super.play_as_backwards_when(mode == AnimaTween.PLAY_MODE.BACKWARDS)

func _on_Animation_pressed():
	_on_Timer_timeout()
	
	emit_signal("add_frame")

func _on_Delay_pressed():
	_on_Timer_timeout()

	emit_signal("add_delay")

func _on_Event_pressed():
	emit_signal("add_event")

func _on_AddButton_mouse_entered():
	$Timer.stop()

	if $ButtonsContainer/Animation.modulate.a < 1:
		_animate_add(AnimaTween.PLAY_MODE.NORMAL)

func _on_Timer_timeout():
	_animate_add(AnimaTween.PLAY_MODE.BACKWARDS)

func _on_mouse_entered():
	$Timer.stop()

func _on_mouse_exited():
	$Timer.start()

func update_position(parent_size: Vector2):
	position = parent_size - $AddButton.size - Vector2(200, 92)
