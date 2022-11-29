tool
extends Button

var MAPPED_STYLEBOXES := {
	DRAW_NORMAL: "normal",
	DRAW_DISABLED: "disabled",
	DRAW_HOVER: "hover",
	DRAW_PRESSED: "pressed",
	DRAW_HOVER_PRESSED: "focus"
}

var _initial_draw_mode: int = -1
var _should_draw := false
#var state: int = BUTTON_STATE.NORMAL

func _ready():
	_should_draw = true

func _draw():
	var draw_mode = get_draw_mode()

	if _should_draw:
		_animate_state_changed(_initial_draw_mode, draw_mode)

	_initial_draw_mode = draw_mode

func _animate_state_changed(from_state: int, to_state: int) -> void:
	_should_draw = true

	update()
	
	_should_draw = false
	var a = get_stylebox("normal")
	var b = get_stylebox("hover")
	var c = get_stylebox("pressed")
	var d = get_stylebox("focus")
	var e = get_stylebox("disabled")
	
	prints(a,b,c,d,e)

	pass
