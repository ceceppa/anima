extends ExamplePlayground

const POLICIES := {
	"Replace": AnimaMotion.InterruptionPolicy.REPLACE,
	"Retarget": AnimaMotion.InterruptionPolicy.RETARGET,
	"Queue": AnimaMotion.InterruptionPolicy.QUEUE,
	"Reverse": AnimaMotion.InterruptionPolicy.REVERSE,
}

@onready var _target: Control = %Target
@onready var _status: Label = %Status
@onready var _action_dock: SelectorDock = %ActionDock
@onready var _playback_controls: PlaybackControls = %PlaybackControls
var _active: AnimaPlayback
var _selected_speed := 1.0

const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

func _ready() -> void:
	super._ready()
	for label in POLICIES:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = label
		button.pressed.connect(_run_policy.bind(label))
		_action_dock.add_item(button)

	_action_dock.select(0)
	_playback_controls.reverse_pressed.connect(_reverse)
	_playback_controls.complete_pressed.connect(_complete)
	_playback_controls.revert_pressed.connect(_reset)
	_playback_controls.speed_selected.connect(_set_speed)
	_playback_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void: Anima.reduced_motion = enabled)
	_reset()

func _run_policy(label: String) -> void:
	_reset()
	_action_dock.select(POLICIES.keys().find(label))
	var first := Motion.to(NodePath("position:x"), 440.0)
	first.duration = 1.0
	_active = Anima.play(first, _target)
	_active.speed_scale = _selected_speed
	await get_tree().create_timer(0.25).timeout
	var incoming := Motion.to(NodePath("position:x"), 120.0)
	incoming.duration = 0.5
	incoming.interruption_policy = POLICIES[label]
	if label == "Retarget":
		first.ease.kind = AnimaEase.Kind.SPRING
		incoming.ease.kind = AnimaEase.Kind.SPRING
	Anima.play(incoming, _target)
	_status.text = "%s: the new request interrupted the active motion." % label

func _reset() -> void:
	if _active != null:
		_active.revert()
	_target.position.x = 120.0
	_status.text = "Ready: choose an interruption while the target is moving."

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

func _on_playback_controls_restart_pressed() -> void:
	%ActionDock.trigger_item(%ActionDock.selected_index)
