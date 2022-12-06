@tool
extends ColorRect

enum STYLE {
	PRIMARY,
	SECONDARY,
	TERTIARY,
	FOURTH,
	BACKGROUND
}

var COLORS := {
	STYLE.PRIMARY: Color("#032534"),
	STYLE.SECONDARY: Color("#545408"),
	STYLE.TERTIARY: Color("#056154"),
	STYLE.FOURTH: Color("#CECCF1").darkened(0.4),
	STYLE.BACKGROUND: Color("#1a304f"),
}

@export var style := STYLE.PRIMARY :
	get:
		return style
	set(mod_value):
		style = mod_value

		color = COLORS[style]
@export var adjust_size := 0.0 :
	get:
		return adjust_size
	set(mod_value):
		adjust_size = mod_value

		_on_resized()

func _ready():
	if get_child_count() == 0:
		return

	get_child(0).connect("resized",Callable(self,"_on_resized"))
	connect("resized",Callable(self,"_on_resized"))

	_on_resized()

var _can = true

func _on_resized() -> void:
	if get_child_count() > 0:
		var child_size = get_child(0).size

		if child_size != size:
			custom_minimum_size = child_size

func set_bg_style(new_style: int) -> void:
	style = new_style

	color = COLORS[style]
