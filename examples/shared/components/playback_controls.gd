class_name PlaybackControls
extends HBoxContainer

signal restart_pressed

@onready var _restart_button: Button = %RestartButton

func _ready() -> void:
	_restart_button.pressed.connect(func() -> void: restart_pressed.emit())
