extends ExamplePlayground

const STRATEGIES := {
	"Leave Alone": AnimaMotion.VisibilityStrategy.IGNORE,
	"Unhide": AnimaMotion.VisibilityStrategy.HIDDEN_ONLY,
	"Make Opaque": AnimaMotion.VisibilityStrategy.TRANSPARENT_ONLY,
	"Both": AnimaMotion.VisibilityStrategy.HIDDEN_AND_TRANSPARENT,
}
const TIMINGS := {
	"On Play": AnimaMotion.InitialValueTiming.ON_PLAY,
	"On Creation": AnimaMotion.InitialValueTiming.ON_ANIMATION_CREATION,
}
const START_X := -200.0
const END_X := 120.0

const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

@onready var _target: ColorRect = %Target
@onready var _status: Label = %Status
@onready var _visibility_dock: SelectorDock = %VisibilityDock
@onready var _timing_dock: SelectorDock = %TimingDock
@onready var _hide_toggle: ToggleSwitch = %HideToggle
@onready var _action_dock: SelectorDock = %ActionDock
@onready var _playback_controls: PlaybackControls = %PlaybackControls

var _selected_strategy_label := "Leave Alone"
var _selected_timing_label := "On Play"
var _active: AnimaPlayback
var _selected_speed := 1.0

func _ready() -> void:
	super._ready()

	for label in STRATEGIES:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = label
		button.pressed.connect(_select_strategy.bind(label))
		_visibility_dock.add_item(button)
	_visibility_dock.select(0)

	for label in TIMINGS:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = label
		button.pressed.connect(_select_timing.bind(label))
		_timing_dock.add_item(button)
	_timing_dock.select(0)

	var start_button: SelectorButton = SELECTOR_BUTTON.instantiate()
	start_button.text = "Start"
	start_button.pressed.connect(_start)
	_action_dock.add_item(start_button)

	_hide_toggle.toggled.connect(func(_enabled: bool) -> void: _update_status("Ready"))
	_playback_controls.restart_pressed.connect(_reset)
	_playback_controls.reverse_pressed.connect(_reverse)
	_playback_controls.complete_pressed.connect(_complete)
	_playback_controls.revert_pressed.connect(_reset)
	_playback_controls.speed_selected.connect(_set_speed)
	_playback_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void: Anima.reduced_motion = enabled)

	_reset()

func _select_strategy(label: String) -> void:
	_selected_strategy_label = label
	_visibility_dock.select(STRATEGIES.keys().find(label))
	_update_status("Ready")

func _select_timing(label: String) -> void:
	_selected_timing_label = label
	_timing_dock.select(TIMINGS.keys().find(label))
	_update_status("Ready")

## Plays an entrance on [member _target], which starts hidden and fully
## transparent: [member AnimaMotion.visibility_strategy] and [member
## AnimaMotion.initial_value_timing] use the two currently selected choices;
## the animated property itself (`position:x`) never overlaps with what a
## visibility-strategy fixup touches (`visible`/`modulate.a`), so each
## choice's effect is visible on its own (tech-spec.md §Visibility strategy
## and initial-value timing).
func _start() -> void:
	_reset()
	var entrance := Motion.to(NodePath("position:x"), END_X)
	entrance.duration = 0.6
	entrance.visibility_strategy = STRATEGIES[_selected_strategy_label]
	entrance.initial_value_timing = TIMINGS[_selected_timing_label]
	entrance.completion_value_policy = AnimaMotion.CompletionValuePolicy.HIDE if _hide_toggle.enabled else AnimaMotion.CompletionValuePolicy.KEEP_FINAL
	_active = Anima.play(entrance, _target)
	_active.speed_scale = _selected_speed
	_active.finished.connect(_on_finished, CONNECT_ONE_SHOT)
	_update_status("Playing")

func _on_finished(success: bool) -> void:
	if success:
		_update_status("Finished")

func _reset() -> void:
	if _active != null:
		_active.cancel()
		_active = null
	_target.visible = false
	_target.modulate.a = 0.0
	_target.position.x = START_X
	_update_status("Ready")

func _reverse() -> void:
	if _active != null:
		_active.reverse()

func _complete() -> void:
	if _active != null:
		_active.complete()

func _set_speed(speed: float) -> void:
	_selected_speed = speed
	if _active != null:
		_active.speed_scale = speed

func _update_status(stage: String) -> void:
	var state := "visible" if _target.visible else "hidden"
	var hide_note := " · hides on finish" if _hide_toggle.enabled else ""
	_status.text = "%s — target %s · %s · %s%s" % [stage, state, _selected_strategy_label, _selected_timing_label, hide_note]
