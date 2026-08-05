## Base [Resource] every composite and leaf motion extends. Defines the shared
## contract — [method estimate_duration], [method create_runtime],
## [method validate] — every subtype must implement explicitly.
class_name AnimaMotion
extends Resource

## Which sibling instant [member delay] is measured from, inside an [AnimaSequence].
enum DelayBasis {
	AFTER_PREVIOUS_ENDS,
	AFTER_PREVIOUS_STARTS,
}

## The value left on the target once a playback reaches [constant
## AnimaPlayback.State.FINISHED] — whether by playing to the end naturally or
## via [method AnimaPlayback.complete]. Unrelated to [constant
## AnimaGroupMotion.CompletionPolicy] / [constant AnimaParallel.CompletionPolicy],
## which decide *when* a composite counts as done, never what value is left
## behind — see tech-spec.md's Key technical decisions.
enum CompletionValuePolicy {
	## Leave the motion's authored end value in place. Today's implicit behaviour.
	KEEP_FINAL,
	## Re-apply the value captured before playback started, immediately after
	## [signal AnimaPlayback.finished] reports success.
	RESTORE_INITIAL,
}

## The value left on the target when [method AnimaPlayback.cancel] is called.
enum CancellationValuePolicy {
	## Leave whatever value was showing at the moment of cancellation. Today's
	## actual behaviour — cancelling simply stops advancing.
	KEEP_CURRENT,
	## Re-apply the value captured before playback started.
	RESTORE_INITIAL,
	## Apply the motion's authored end value(s), the same value [method
	## AnimaPlayback.complete] would produce — but [signal AnimaPlayback.finished]
	## still reports `false` and [member on_completed_callback] still never
	## fires; this changes only the value cancellation leaves behind, not the
	## fact that it was a cancellation.
	COMPLETE,
}

## Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
@export var display_name: String = ""
## Disabled motions are skipped by every composite that contains them.
@export var enabled: bool = true
## Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
## this and [member delay_basis] this phase. May be negative (an overlap).
@export var delay: float = 0.0
## Which sibling instant [member delay] is measured from.
@export var delay_basis: DelayBasis = DelayBasis.AFTER_PREVIOUS_ENDS
## Playback speed multiplier applied regardless of direction — pairs with
## [member forward_speed]/[member reverse_speed], which apply only for their
## matching direction. Set via [method with_speed].
@export var speed: float = 1.0
## Multiplier applied only while this motion plays forward (root-level
## playback only — see tech-spec.md §Speed, direction, and reduced motion).
## Composes with [member speed] and [AnimaPlayback.speed_scale].
@export var forward_speed: float = 1.0
## Multiplier applied only while this motion plays in reverse — via [method
## AnimaPlayback.reverse] or [method Anima.play_backwards] — instead of
## [member forward_speed]. Lets a motion's structural reverse (e.g. a closing
## animation) play at a different pace than its forward run without
## duplicating the motion or hand-adjusting durations.
@export var reverse_speed: float = 1.0
## Optional categorisation metadata — no logic reads or filters on this.
@export var tags: Array[String] = []
## Optional free-form metadata — no logic reads this.
@export var metadata: Dictionary = {}
## Optional callback [AnimaPlayback] invokes exactly once, at the moment this
## motion begins playing — including a fresh reversed run (see [method on_started]).
@export var on_started_callback: Callable = Callable()
## Optional callback [AnimaPlayback] invokes exactly once, immediately before
## it reports a successful finish — never on cancellation (see [method on_completed]).
@export var on_completed_callback: Callable = Callable()
## The value left behind once this motion's playback finishes — natural finish
## or [method AnimaPlayback.complete]. See [enum CompletionValuePolicy].
@export var completion_value_policy: CompletionValuePolicy = CompletionValuePolicy.KEEP_FINAL
## The value left behind when this motion's playback is cancelled. See
## [enum CancellationValuePolicy].
@export var cancellation_value_policy: CancellationValuePolicy = CancellationValuePolicy.KEEP_CURRENT
## Overrides how this motion plays when reduced motion is active for the
## playing target (see [method Anima.is_reduced_motion_active]). `< 0.0`
## (the default) means no override. `> 0.0` replaces the normal `speed_scale
## × direction_speed` product outright. `0.0` means complete immediately
## instead — the same outcome [method AnimaPlayback.complete] produces —
## since a literal `0.0` multiplier would freeze the motion forever rather
## than reduce it.
@export var reduced_motion_speed: float = -1.0

## Reports this motion's duration kind and (when known) its length in seconds.
## Every subtype must override this explicitly.
func estimate_duration() -> AnimaDuration:
	push_error("AnimaMotion.estimate_duration() must be overridden by a subtype")
	return AnimaDuration.fixed(0.0)

## Builds the runtime instance that [method AnimaMotionInstance.advance]s this
## motion frame by frame. Every subtype must override this explicitly.
func create_runtime() -> Variant:
	push_error("AnimaMotion.create_runtime() must be overridden by a subtype")
	return null

## Returns a list of human-readable configuration errors, or an empty array
## when this motion (and its children, if any) are valid.
func validate() -> Array[String]:
	return []

## Builds an [AnimaSequence] that plays this motion, then [param other],
## in order — the same resource [method Motion.sequence] would build.
## Chaining a second `.then()` appends another step to one flat sequence
## instead of nesting (`a.then(b).then(c)` is a 3-step sequence, not a
## sequence of sequences). See [method with] for combining steps that
## should start together instead.
func then(other: AnimaMotion) -> AnimaSequence:
	var sequence := AnimaSequence.new()
	if self is AnimaSequence:
		sequence.children.append_array((self as AnimaSequence).children)
	else:
		sequence.children.append(self)
	sequence.children.append(other)
	return sequence

## Folds [param other] into the same [AnimaParallel] group as whatever was
## most recently chained — the group open since the last [method then], or
## the whole chain when no [method then] preceded it. Multiple consecutive
## `.with()` calls join one growing group rather than nesting
## (`a.then(b).with(c).with(d)` is `b`, `c`, and `d` all starting together,
## after `a`).
func with(other: AnimaMotion) -> AnimaMotion:
	if not (self is AnimaSequence):
		return _grouped_with(self, other)

	var sequence := self as AnimaSequence
	if sequence.children.is_empty():
		return other

	var result := AnimaSequence.new()
	result.children.append_array(sequence.children)
	var last_index := result.children.size() - 1
	result.children[last_index] = _grouped_with(result.children[last_index], other)
	return result

## Shared helper for [method with]: groups [param existing] and [param other]
## into one [AnimaParallel], flattening when [param existing] is already one.
func _grouped_with(existing: AnimaMotion, other: AnimaMotion) -> AnimaParallel:
	var parallel := AnimaParallel.new()
	if existing is AnimaParallel:
		parallel.children.append_array((existing as AnimaParallel).children)
	else:
		parallel.children.append(existing)
	parallel.children.append(other)
	return parallel

## Sets [member on_started_callback], invoked exactly once by [AnimaPlayback]
## when this motion begins playing. Returns self so calls can keep chaining.
func on_started(callback: Callable) -> AnimaMotion:
	on_started_callback = callback
	return self

## Sets [member on_completed_callback], invoked exactly once by [AnimaPlayback]
## immediately before it reports a successful finish — never on cancellation.
## Returns self so calls can keep chaining.
func on_completed(callback: Callable) -> AnimaMotion:
	on_completed_callback = callback
	return self

## Wraps this motion in a new [AnimaRepeat] that plays it [param count] times
## — the same resource [method Motion.repeat] would build, now reachable as a
## chain call on any motion, including one built through [method Anima.on].
## [param count] defaults to `-1`, which repeats indefinitely instead of a
## fixed number of times. [param alternate] `true` ping-pongs every other
## iteration between forward and backward (v1's `loop_in_circle`) instead of
## repeating identically.
func repeat(count: int = -1, alternate: bool = false) -> AnimaRepeat:
	var result := AnimaRepeat.new()
	result.child = self
	result.count = count
	result.alternate = alternate
	return result

## Sets [member speed] directly. Named `with_speed` rather than `speed()` for
## the same reason as `with_duration`/`with_ease`/`with_delay` on
## [AnimaPropertyMotion] — a bare method name would collide with the field of
## the same name. Returns self so calls can keep chaining.
func with_speed(value: float) -> AnimaMotion:
	speed = value
	return self
