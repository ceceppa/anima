class_name PlaybackControls
extends HBoxContainer

signal restart_pressed
signal reverse_pressed

@onready var _restart_button: Button = %RestartButton
@onready var _reverse_button: Button = %ReverseButton

func _ready() -> void:
	_restart_button.pressed.connect(func() -> void: restart_pressed.emit())
	_reverse_button.pressed.connect(func() -> void: reverse_pressed.emit())
