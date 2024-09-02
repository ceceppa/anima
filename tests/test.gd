@tool
extends Control

@export var debug_animation: bool = false:
	set(value):
		debug_animation = value

		if not value or not %Label2:
			return

		_animate()

func _animate():
	await (
		Anima.Node(%Label2)
		.clear()
		.anima_animation("bounce", 0.5)
		.play()
	).animation_completed

func _on_button_pressed():
	_animate()
