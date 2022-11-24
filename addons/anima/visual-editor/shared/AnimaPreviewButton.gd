tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

var _anima: AnimaNode

func _ready():
	_disabled_icon_color = Color("#ff8a8c")

func _on_Preview_toggled(button_pressed):
	._on_Button_toggled(button_pressed)

	var icon_name = "Wait.svg" if button_pressed else "Play.svg"

	icon = load("res://addons/anima/visual-editor/icons/" + icon_name)

	if button_pressed:
		_anima = Anima.begin(self, "zoom_icon") \
			.with(
				Anima.Node(self).anima_animation("pulse", 0.7)
			) \
			.loop_with_delay(0.5)
	else:
		_anima.stop()

	disabled = button_pressed

	update()
