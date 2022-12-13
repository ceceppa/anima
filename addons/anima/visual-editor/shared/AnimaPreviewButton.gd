tool
extends "res://addons/anima/visual-editor/shared/AnimaMenuButton.gd"

var _anima: AnimaNode

func _ready():
	_disabled_icon_color = Color("#ff8a8c")

	set_items([
		{ icon = "res://addons/anima/visual-editor/icons/Play.svg", label = "Can play Animation" },
		{ icon = "res://addons/anima/visual-editor/icons/Skip.svg", label = "Skip Animation" }
#		{ icon = "res://addons/anima/visual-editor/icons/PlayOnEdit.svg", label = "Play on animation change" }
	])

func _on_Preview_toggled(button_pressed):
	._on_Button_toggled(button_pressed)

	toggle_mode = _selected_id == 0

	if _selected_id != 0:
		pressed = false
		return

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

