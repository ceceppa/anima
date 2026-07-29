class_name AnimaPlayback
extends RefCounted

enum State {
	PLAYING,
	PAUSED,
	CANCELLED,
	FINISHED,
}

signal finished(success: bool)

var motion: AnimaMotion
var target: Node
var state: State = State.PLAYING

var _instance: Variant = null

func _init(p_motion: AnimaMotion, p_target: Node = null) -> void:
	motion = p_motion
	target = p_target
	_instance = motion.create_runtime()

func pause() -> void:
	if state == State.PLAYING:
		state = State.PAUSED

func resume() -> void:
	if state == State.PAUSED:
		state = State.PLAYING

func cancel() -> void:
	if state == State.PLAYING or state == State.PAUSED:
		state = State.CANCELLED
		finished.emit(false)

func _advance(delta: float) -> void:
	if state != State.PLAYING:
		return

	var is_finished: bool = _instance.advance(target, delta)
	if is_finished:
		state = State.FINISHED
		finished.emit(true)
