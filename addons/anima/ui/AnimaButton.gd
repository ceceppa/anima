@tool
extends Button
class_name AnimaButton

@export var theme_icon := "Save" :
	get:
		return theme_icon
	set(new_icon):
		theme_icon = new_icon
		icon = ANIMA.get_theme_icon(new_icon)

func _ready():
	icon = ANIMA.get_theme_icon(theme_icon)
