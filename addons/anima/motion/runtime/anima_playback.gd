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
## A multiplier applied to every frame this playback advances by, on top of
## [member AnimaMotion.forward_speed]/[member AnimaMotion.reverse_speed] (see
## [method _advance]). `1.0` is normal speed; `2.0` runs twice as fast; `0.5`
## runs at half speed. When [member motion] is an [AnimaGroupMotion], every
## active item shares this same scaled delta, so changing it affects the
## whole group as one playback.
var speed_scale: float = 1.0

## Whether [member target] was actually supplied, captured once at construction
## — a Godot node comparing itself as equal to `null` once freed means
## [code]target != null[/code] can no longer answer this reliably later
## (see [method _advance]'s target-freed check), so this is captured while
## [member target] is still known-good.
var _has_target: bool = false
## Whether this playback is currently running backward — selects [member
## AnimaMotion.reverse_speed] over [member AnimaMotion.forward_speed] in
## [method _advance]. Set once at construction ([param p_start_reversed]) and
## flipped on every successful [method reverse], so repeated direction
## changes keep selecting the correct multiplier.
var _is_reversed: bool = false
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
## Arbitrary data an [AnimaValue] built with [method AnimaValue.context] can
## read during this playback (see [member AnimaValueContext.context_data]).
## Mutate this dictionary in place before playback resolves any value that
## reads it — reassigning the whole dictionary after construction leaves an
## already-built context pointing at the old one.
var context_data: Dictionary = {}

## [param p_start_reversed] is [method Anima.play_backwards]'s entry point:
## captures [param p_motion]'s start/end with one zero-length frame, then
## immediately reverses in place — see [method _reverse_in_place] — so
## playback begins already running backward, with no visible forward frame.
func _init(p_motion: AnimaMotion, p_target: Node = null, p_start_reversed: bool = false) -> void:
	motion = p_motion
	target = p_target
	_has_target = p_target != null
	_is_reversed = p_start_reversed
	_instance = motion.create_runtime(_build_value_context())
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

## Builds the root-level [AnimaValueContext] passed to [method AnimaMotion.create_runtime]
## — [member target] as both target and root, sharing this playback's own
## [member context_data] (see [member AnimaValueContext.context_data]). A
## group/grid item resolves against its own, separately-built context instead
## (`tech-spec.md` §Dynamic values).
func _build_value_context() -> AnimaValueContext:
	var context := AnimaValueContext.new(target)
	context.context_data = context_data
	return context

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

## Stops playback and resolves [signal finished] as not-successful. The value
## left on [member target] follows [member AnimaMotion.cancellation_value_policy]:
## [constant AnimaMotion.CancellationValuePolicy.KEEP_CURRENT] (default) leaves
## whatever was showing at the moment of cancellation — today's actual
## behaviour, unchanged. [constant AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL]
## re-applies the pre-animation snapshot. [constant AnimaMotion.CancellationValuePolicy.COMPLETE]
## applies the motion's authored end value(s) — the same value [method complete]
## would produce — but this is still reported as a cancellation: [signal finished]
## still emits `false` and [member AnimaMotion.on_completed_callback] never fires.
func cancel() -> void:
	if state != State.PLAYING and state != State.PAUSED:
		return

	match motion.cancellation_value_policy:
		AnimaMotion.CancellationValuePolicy.RESTORE_INITIAL:
			_instance.restore_initial(target)
		AnimaMotion.CancellationValuePolicy.COMPLETE:
			_instance.force_complete(target)
		_: # KEEP_CURRENT
			pass

	state = State.CANCELLED
	finished.emit(false)

## Forces this playback to its valid final state immediately: applies every
## active motion's authored end value(s), fires [member
## AnimaMotion.on_completed_callback] and [signal finished] as a successful
## finish exactly once — the same as a natural finish — then applies [member
## AnimaMotion.completion_value_policy]. [constant AnimaMotion.CompletionValuePolicy.KEEP_FINAL]
## (default) leaves that end value in place. [constant
## AnimaMotion.CompletionValuePolicy.RESTORE_INITIAL] re-applies the
## pre-animation snapshot immediately after [signal finished] reports success.
## A no-op past [constant State.FINISHED]/[constant State.CANCELLED].
func complete() -> void:
	if state != State.PLAYING and state != State.PAUSED:
		return

	_instance.force_complete(target)
	state = State.FINISHED
	if motion.on_completed_callback.is_valid():
		motion.on_completed_callback.call()
	finished.emit(true)

	if motion.completion_value_policy == AnimaMotion.CompletionValuePolicy.RESTORE_INITIAL:
		_instance.restore_initial(target)

## Unconditionally restores [member target] to the value captured before
## playback started, and stops playback: [constant State.CANCELLED], [signal
## finished] emits `false`. Unlike [method cancel], the value left behind is
## never affected by [member AnimaMotion.cancellation_value_policy] — revert()
## always restores. This is why revert and [method reverse] are not
## equivalent: reverse() keeps playback running, now backward, from wherever
## it was; revert() stops it and snaps to the start. A no-op past [constant
## State.FINISHED]/[constant State.CANCELLED].
func revert() -> void:
	if state != State.PLAYING and state != State.PAUSED:
		return

	_instance.restore_initial(target)
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

	_is_reversed = not _is_reversed
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
	_instance = motion.create_runtime(_build_value_context())
	return true

## Manually advances this playback by exactly [param delta] seconds, scaled
## by the same effective speed (speed_scale × direction) [method _advance]
## already applies for the automatic per-frame path — for tests, tools, or
## frame-stepped debugging that want to drive playback themselves instead of
## relying on [AnimaRuntime]'s own per-frame loop. No separate clock-mode
## selection; this is a direct-drive entry point only.
func step(delta: float) -> void:
	_advance(delta)

func _advance(delta: float) -> void:
	if state != State.PLAYING:
		return

	if _has_target and not is_instance_valid(target):
		cancel()
		return

	if motion.reduced_motion_speed == 0.0 and Anima.is_reduced_motion_active(target):
		# 0.0 as a literal multiplier would freeze the motion forever — the
		# opposite of a reduced-motion outcome — so it's a sentinel for
		# "complete immediately" instead, reusing complete()'s own
		# value-policy and callback/signal contract as-is.
		complete()
		return

	var effective_speed: float = speed_scale * (motion.reverse_speed if _is_reversed else motion.forward_speed)
	if motion.reduced_motion_speed > 0.0 and Anima.is_reduced_motion_active(target):
		effective_speed = motion.reduced_motion_speed
	var scaled_delta := delta * effective_speed
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
