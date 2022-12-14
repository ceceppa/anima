tool
extends "res://addons/anima/visual-editor/shared/AnimaButton.gd"

signal play_preview
signal skip_changed

var _anima: AnimaNode
var skip := false setget set_skip
var _stop_funcref: FuncRef

func _on_Preview_pressed():
	if Input.is_physical_key_pressed(KEY_CONTROL):
		set_skip(not skip)

	if skip:
		return

	if _stop_funcref:
		_stop_funcref.call_func()

		return

	emit_signal("play_preview")

func set_skip(s: bool) -> void:
	if s != skip:
		emit_signal("skip_changed")

	skip = s
	
	var svg_name := "Play.svg" if not skip else "Skip.svg"

	icon = load("res://addons/anima/visual-editor/icons/" + svg_name)

func set_is_playing(playing: bool, stop_funcref = null) -> void:
	var icon_name = "Stop.svg" if playing else "Play.svg"

	icon = load("res://addons/anima/visual-editor/icons/" + icon_name)

	_stop_funcref = stop_funcref
