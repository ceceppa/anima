extends ExamplePlayground

@onready var _row: HBoxContainer = %LayoutRow
@onready var _status: Label = %Status
@onready var _action_dock: SelectorDock = %ActionDock
@onready var _playback_controls: PlaybackControls = %PlaybackControls

const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")
var _active_playbacks: Array[AnimaPlayback] = []
var _selected_speed := 1.0

func _ready() -> void:
	super._ready()
	var trigger: SelectorButton = SELECTOR_BUTTON.instantiate()
	trigger.text = "Change layout"
	trigger.pressed.connect(_trigger_layout_change)
	_action_dock.add_item(trigger)
	_action_dock.select(0)
	_playback_controls.restart_pressed.connect(_reset)
	_playback_controls.reverse_pressed.connect(_reverse)
	_playback_controls.complete_pressed.connect(_complete)
	_playback_controls.revert_pressed.connect(_reset)
	_playback_controls.speed_selected.connect(_set_speed)
	_playback_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void: Anima.reduced_motion = enabled)
	_reset()

func _trigger_layout_change() -> void:
	var transition := Anima.layout_transition(_row)
	for child in _row.get_children():
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_EXPAND_FILL if child.name == "Middle" else Control.SIZE_FILL

	_action_dock.select(0)
	_status.text = "During: Godot chose the final row; Anima is settling the previous arrangement into it."

func _reset() -> void:
	for playback in _active_playbacks:
		playback.revert()
	_active_playbacks.clear()
	for child in _row.get_children():
		if child is Control:
			child.size_flags_horizontal = Control.SIZE_FILL
	_status.text = "Before: three controls share the standard container row."

func _reverse() -> void:
	for playback in _active_playbacks:
		playback.reverse()

func _complete() -> void:
	for playback in _active_playbacks:
		playback.complete()

func _set_speed(speed: float) -> void:
	_selected_speed = speed
	for playback in _active_playbacks:
		playback.speed_scale = speed
