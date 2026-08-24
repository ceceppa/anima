## Runtime-only record for one supported Control-container layout change.
## Capture the controls before asking Godot to relayout, then call [method play]
## after the container has selected its final rectangles.  The final rectangles
## remain the only destination values; this record only makes the change visible
## between the two layouts.
class_name AnimaLayoutTransition
extends Node

## Default duration in seconds for a captured layout transition.
const DEFAULT_DURATION := 0.3

## Rectangles captured before Godot's next layout pass, keyed by Control id.
var _before_rects: Dictionary = {}
## Duration supplied for this transition record.
var _duration: float = DEFAULT_DURATION
## Playbacks started by the observed layout change.
var _playbacks: Array[AnimaPlayback] = []
## Controls currently observed for the one captured transition.
var _connected_controls: Array[Control] = []
## True while at least one observed control has an active layout playback.
var _is_animating: bool = false
## Controls with an active layout playback. Godot can notify each control in a
## container layout pass separately, so one control's playback must not hide a
## later control's final rectangle.
var _animating_control_ids: Dictionary = {}
## Number of layout motion playbacks that must finish before observation resumes.
var _remaining_playbacks: int = 0

var _x
## Captures direct and nested Controls whose immediate parent is a standard
## Control.  Nodes outside that boundary are intentionally ignored.
func _init(container: Node, duration: float = DEFAULT_DURATION) -> void:
	_duration = maxf(duration, 0.0)

	for control in _supported_controls(container):
		_before_rects[control.get_instance_id()] = {
			"control": control,
			"position": control.position,
			"size": control.size,
		}

		_connect_control(control)

## Returns the playbacks started when Godot changed the captured layout.
func play() -> Array[AnimaPlayback]:
	return _playbacks

func _animate_changes(control: Control = null) -> void:
	if control != null:
		_animate_control_change(control)
		return

	for snapshot in _before_rects.values():
		_animate_control_change(snapshot["control"] as Control)

func _animate_control_change(control: Control) -> void:
	if not is_instance_valid(control) or not (control.get_parent() is Container):
		return

	var control_id := control.get_instance_id()
	if _animating_control_ids.has(control_id):
		return

	var snapshot: Dictionary = _before_rects.get(control_id, {})
	if snapshot.is_empty():
		return

	var final_position := control.position
	var final_size := control.size
	var initial_position: Vector2 = snapshot["position"]
	var initial_size: Vector2 = snapshot["size"]
	if initial_position.is_equal_approx(final_position) and initial_size.is_equal_approx(final_size):
		return

	# Godot has already chosen this control's final rectangle. Temporarily
	# restore its prior visual rectangle, then animate only to that final value.
	_animating_control_ids[control_id] = true
	_is_animating = true
	control.position = initial_position
	control.size = initial_size
	var position_motion := Motion.to(NodePath("position"), final_position)
	position_motion.duration = _duration
	var size_motion := Motion.to(NodePath("size"), final_size)
	size_motion.duration = _duration

	var playback := Anima.play(Motion.parallel([position_motion, size_motion]), control)
	playback.finished.connect(_on_playback_finished.bind(control_id), CONNECT_ONE_SHOT)
	_playbacks.append(playback)
	_remaining_playbacks += 1

func _on_playback_finished(_success: bool, control_id: int) -> void:
	_remaining_playbacks -= 1
	_animating_control_ids.erase(control_id)
	_is_animating = not _animating_control_ids.is_empty()

func _connect_control(control: Control) -> void:
	if not is_instance_valid(control):
		return
	var change_callback := _animate_changes.bind(control)
	if not control.item_rect_changed.is_connected(change_callback):
		control.item_rect_changed.connect(change_callback)
	if not _connected_controls.has(control):
		_connected_controls.append(control)

func _disconnect_controls() -> void:
	for control in _connected_controls:
		var change_callback := _animate_changes.bind(control)
		if is_instance_valid(control) and control.item_rect_changed.is_connected(change_callback):
			control.item_rect_changed.disconnect(change_callback)

func _reconnect_controls() -> void:
	for control in _connected_controls:
		_connect_control(control)


func _supported_controls(container: Container) -> Array[Control]:
	var controls: Array[Control] = []

	for child in container.get_children():
		if child is Control:
			controls.append(child)
		if child is Container:
			controls.append_array(_supported_controls(child))

	return controls
