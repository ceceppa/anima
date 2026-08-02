## Returned by [method Anima.play] — one call's live playback state and controls.
class_name AnimaPlayback
extends RefCounted

## Which lifecycle stage this playback is in.
enum State {
	PLAYING,
	PAUSED,
	CANCELLED,
	FINISHED,
}

## Emitted exactly once, on [constant State.FINISHED] or [constant State.CANCELLED].
## [param success] is `true` only for a natural finish, `false` for a cancel.
signal finished(success: bool)

## The motion being played.
var motion: AnimaMotion
## The node it's playing against.
var target: Node
## Which lifecycle stage this playback is in.
var state: State = State.PLAYING
## A multiplier applied to every frame this playback advances by. `1.0` is
## normal speed; `2.0` runs twice as fast; `0.5` runs at half speed. When
## [member motion] is an [AnimaGroupMotion], every active item shares this
## same scaled delta, so changing it affects the whole group as one playback.
var speed_scale: float = 1.0

var _instance: Variant = null

func _init(p_motion: AnimaMotion, p_target: Node = null) -> void:
	motion = p_motion
	target = p_target
	_instance = motion.create_runtime()

## Freezes the animated value in place until [method resume].
func pause() -> void:
	if state == State.PLAYING:
		state = State.PAUSED

## Continues playback from wherever [method pause] froze it.
func resume() -> void:
	if state == State.PAUSED:
		state = State.PLAYING

## Stops playback and resolves [signal finished] as not-successful.
func cancel() -> void:
	if state == State.PLAYING or state == State.PAUSED:
		state = State.CANCELLED
		finished.emit(false)

## Redirects a still-moving SPRING-eased AnimaPropertyMotion to a new
## destination, preserving its current value/velocity instead of restarting
## it from scratch. An error (not silently ignored) for any other motion
## shape — composites and non-SPRING eases have no defined retarget behaviour.
func retarget(new_to_value: Variant) -> void:
	var property_motion := motion as AnimaPropertyMotion
	if property_motion == null or property_motion.ease.kind != AnimaEase.Kind.SPRING:
		push_error("AnimaPlayback.retarget() is only defined for a single SPRING-eased AnimaPropertyMotion")
		return

	property_motion.to_value = new_to_value
	_instance.retarget_spring(new_to_value)

## Reverses a still-playing or already-finished [AnimaGroupMotion] group,
## reusing its recorded target sequence instead of resolving and scheduling
## it again — a [constant AnimaGroupOrder.Kind.RANDOM] order does not
## reshuffle. Restarts this same playback from the top, respecting [member
## AnimaGroupMotion.reverse_order_policy]. An error (not silently ignored)
## for any other motion shape — only a played group has a recorded sequence
## to reverse.
func reverse() -> void:
	var group_instance := _instance as AnimaGroupPlayback
	var group_motion := motion as AnimaGroupMotion
	if group_instance == null or group_motion == null or group_instance.execution_record == null:
		push_error("AnimaPlayback.reverse() is only defined for a played AnimaGroupMotion")
		return

	var record := group_instance.execution_record
	if group_motion.reverse_order_policy == AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION:
		record = record.reversed()
	group_instance.restart_from_record(record)
	state = State.PLAYING

func _advance(delta: float) -> void:
	if state != State.PLAYING:
		return

	var is_finished: bool = _instance.advance(target, delta * speed_scale)
	if is_finished:
		state = State.FINISHED
		finished.emit(true)
