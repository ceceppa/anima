@tool
extends "res://addons/anima/visual-editor/shared/AnimaMenuButton.gd"

var _anima: AnimaNode

func _ready():
	_disabled_icon_color = Color("#ff8a8c")

	set_items([
		{ icon = "res://addons/anima/visual-editor/icons/Play.svg", label = "Play once" },
		{ icon = "res://addons/anima/visual-editor/icons/PlayOnEdit.svg", label = "Play checked animation change" }
	])
	
	set_show_panel_on(12)
	
	custom_minimum_size = Vector2(32, 32)

func _on_Preview_toggled(button_pressed):
	super._on_Button_toggled(button_pressed)

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

	queue_redraw()

