class_name PlaybackControls
extends HBoxContainer

signal restart_pressed
signal reverse_pressed
signal complete_pressed
signal revert_pressed
## [param speed] is one of [constant SPEED_OPTIONS].
signal speed_selected(speed: float)
signal reduced_motion_toggled(enabled: bool)

## Matches SPEED_LABELS index for index — 1× is the default selection.
const SPEED_OPTIONS := [0.5, 1.0, 2.0]
const SPEED_LABELS := ["0.5×", "1×", "2×"]
const DEFAULT_SPEED_INDEX := 1

const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

## Fill, border, size, and icon artwork are authored directly on
## RestartButton/ReverseButton/CompleteButton/RevertButton in
## playback_controls.tscn (design-brief.md §Component guide "Playback
## controls") — this script only wires signals.
@onready var _restart_button: Button = %RestartButton
@onready var _reverse_button: Button = %ReverseButton
@onready var _complete_button: Button = %CompleteButton
@onready var _revert_button: Button = %RevertButton
@onready var _speed_dock: SelectorDock = %SpeedDock
@onready var _reduced_motion_toggle: ToggleSwitch = %ReducedMotionToggle

func _ready() -> void:
	_restart_button.pressed.connect(func() -> void: restart_pressed.emit())
	_reverse_button.pressed.connect(func() -> void: reverse_pressed.emit())
	_complete_button.pressed.connect(func() -> void: complete_pressed.emit())
	_revert_button.pressed.connect(func() -> void: revert_pressed.emit())

	for i in SPEED_LABELS.size():
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = SPEED_LABELS[i]
		button.pressed.connect(_on_speed_button_pressed.bind(i))
		_speed_dock.add_item(button)
	_speed_dock.select(DEFAULT_SPEED_INDEX)

	_reduced_motion_toggle.toggled.connect(func(enabled: bool) -> void: reduced_motion_toggled.emit(enabled))

func _on_speed_button_pressed(index: int) -> void:
	_speed_dock.select(index)
	speed_selected.emit(SPEED_OPTIONS[index])
