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
## Seconds still to wait, at the root level, before [member motion]'s own
## [member AnimaMotion.delay] lets playback actually reach the target — see
## [method _advance]. Reset on every new run ([method _init], [method reverse]).
var _delay_remaining: float = 0.0
## Set by [method AnimaRuntime._track] when this playback was created through
## [method Anima.play]/[method Anima.play_backwards] — lets [method reverse]
## re-register with [method AnimaRuntime.ensure_tracked] after a natural
## finish or a cancel already removed it from the runtime's per-frame loop.
## `null` for a playback built directly (e.g. most of this addon's own
## tests), which the caller is responsible for advancing itself.
var _runtime: AnimaRuntime = null

## [param p_start_reversed] is [method Anima.play_backwards]'s entry point:
## captures [param p_motion]'s start/end with one zero-length frame, then
## immediately reverses in place — see [method _reverse_in_place] — so
## playback begins already running backward, with no visible forward frame.
func _init(p_motion: AnimaMotion, p_target: Node = null, p_start_reversed: bool = false) -> void:
	motion = p_motion
	target = p_target
	_instance = motion.create_runtime()
	if p_start_reversed:
		_instance.advance(target, 0.0)
		if not _reverse_in_place():
			push_error("AnimaPlayback: play_backwards() has nothing to reverse — no capturable start value or target.")
		else:
			# Snap to the reversed motion's own start value now, so the target
			# reflects the reversed run immediately — without this, it would
			# sit at the forward capture's start value for one frame, then
			# visibly jump to the reversed start on the first real _advance().
			_instance.advance(target, 0.0)
	_reset_delay()
	_fire_started()

## Invokes [member AnimaMotion.on_started_callback] on the current [member motion],
## if one was set, exactly once per run — called on initial play and again on
## every [method reverse] restart, since each is its own new run from the
## target's perspective.
func _fire_started() -> void:
	if motion.on_started_callback.is_valid():
		motion.on_started_callback.call()

## Restarts the root-level start delay from [member motion]'s current
## [member AnimaMotion.delay] — called whenever a new run begins.
func _reset_delay() -> void:
	_delay_remaining = maxf(motion.delay, 0.0)

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

## Reverses this playback, returning every target to what was actually
## observed when the run began. For an [AnimaGroupMotion] (including
## [AnimaGridMotion]), reuses its recorded target sequence instead of
## resolving and scheduling it again — a [constant AnimaGroupOrder.Kind.RANDOM]
## order does not reshuffle — replays each started item's own reversed motion
## (see [method AnimaGroupPlayback.build_reversed_item_motions]) instead of
## its original forward one, and restarts this same playback from the top,
## respecting [member AnimaGroupMotion.reverse_order_policy] for item order.
## For a leaf [AnimaPropertyMotion] or an [AnimaSequence]/[AnimaParallel]
## composition of them (e.g. a target-bound motion authored through [method
## Anima.on]), replaces [member motion] with a freshly built reversed motion
## and restarts playback against it — see [method AnimaMotionInstance.build_reversed].
## Returns `false` (and pushes an error, not silently ignored) when nothing
## has been captured yet to reverse to, for every motion kind — the caller
## can react (e.g. [method Anima.play_backwards] instead) rather than this
## call being a silent no-op that leaves the original forward run untouched.
func reverse() -> bool:
	if not _reverse_in_place():
		push_error("AnimaPlayback.reverse() has nothing captured to reverse yet — play this motion at least one frame first.")
		return false

	state = State.PLAYING
	_reset_delay()
	_fire_started()
	if _runtime != null:
		_runtime.ensure_tracked(self)
	return true

## Shared reversal step behind both [method reverse] and [method _init]'s
## [code]p_start_reversed[/code] path. For an [AnimaGroupMotion] (including
## [AnimaGridMotion]), reuses its recorded target sequence instead of
## resolving and scheduling it again, replays each started item's own
## reversed motion (see [method AnimaGroupPlayback.build_reversed_item_motions])
## instead of its original forward one, and restarts from the top, respecting
## [member AnimaGroupMotion.reverse_order_policy] for item order. For a leaf
## [AnimaPropertyMotion] or an [AnimaSequence]/[AnimaParallel]/[AnimaRepeat]
## composition of them, replaces [member motion] with a freshly built
## reversed motion and restarts playback against it — see [method
## AnimaMotionInstance.build_reversed]. Returns `false` (leaving state
## untouched) when there is nothing captured yet to reverse to.
func _reverse_in_place() -> bool:
	var group_instance := _instance as AnimaGroupPlayback
	var group_motion := motion as AnimaGroupMotion
	if group_instance != null and group_motion != null and group_instance.execution_record != null:
		var reversed_item_motions := group_instance.build_reversed_item_motions()
		if reversed_item_motions.is_empty():
			return false

		var record := group_instance.execution_record
		if group_motion.reverse_order_policy == AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION:
			record = record.reversed()
		group_instance.restart_from_record(record, reversed_item_motions)
		return true

	var reversed_motion: AnimaMotion = _instance.build_reversed()
	if reversed_motion == null:
		return false

	motion = reversed_motion
	_instance = motion.create_runtime()
	return true

func _advance(delta: float) -> void:
	if state != State.PLAYING:
		return

	var scaled_delta := delta * speed_scale
	if _delay_remaining > 0.0:
		_delay_remaining -= scaled_delta
		if _delay_remaining > 0.0:
			return
		scaled_delta = -_delay_remaining
		_delay_remaining = 0.0

	var is_finished: bool = _instance.advance(target, scaled_delta)
	if is_finished:
		state = State.FINISHED
		if motion.on_completed_callback.is_valid():
			motion.on_completed_callback.call()
		finished.emit(true)
