## Base [Resource] every composite and leaf motion extends. Defines the shared
## contract — [method estimate_duration], [method create_runtime],
## [method validate] — every subtype must implement explicitly.
class_name AnimaMotion
extends Resource

## Which sibling instant [member delay] is measured from, inside an [_AnimaSequence].
enum DelayBasis {
	AFTER_PREVIOUS_ENDS,
	AFTER_PREVIOUS_STARTS,
}

## The value left on the target once a playback reaches [constant
## AnimaPlayback.State.FINISHED] — whether by playing to the end naturally or
## via [method AnimaPlayback.complete]. Unrelated to [constant
## AnimaGroupMotion.CompletionPolicy] / [constant _AnimaParallel.CompletionPolicy],
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

## Optional label, e.g. for [constant _AnimaParallel.CompletionPolicy.NAMED_CHILD].
@export var display_name: String = ""
## Disabled motions are skipped by every composite that contains them.
@export var enabled: bool = true
## Seconds relative to [member delay_basis]. Only [_AnimaSequence] consumes
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

## Transient, non-exported pending delay set by [method wait] and consumed by
## the very next [method then]/[method with] call — added onto the resolved
## next motion's own [member delay] rather than replacing it, so an already
## `with_delay()`-tagged next step and a preceding [method wait] stack
## instead of one overriding the other (`tech-spec.md` §Key technical
## decisions, the `.wait()` bullet). Never read anywhere except [method then]/
## [method with], which reset it to `0.0` immediately after consuming it.
var _pending_chain_wait: float = 0.0

## Transient target captured by [AnimaOnMotionFactory] when this motion is
## built through [method Anima.on] — never exported, so it's never part of a
## saved resource. `null` for a hand-built motion, an [method Anima.item]-built
## motion (which has no single fixed target), or a [method then]/[method with]
## composite whose combined motions were captured against different targets.
## Read only by [method play] and propagated by [method then]/[method with] —
## see `tech-spec.md` §Target-bound authoring contract, "`.play()` and
## per-leaf convenience targets".
var convenience_target: Node = null

## Starts this motion immediately via [method Anima.play], using [member
## convenience_target] when set. Returns the resulting [AnimaPlayback].
## Reports an error and returns `null` only when called on a leaf
## [AnimaPropertyMotion] with no captured target — build it through [method
## Anima.on] first, or call [method Anima.play] directly. A composite
## ([_AnimaSequence]/[_AnimaParallel]) always proceeds, passing `null` when its
## own [member convenience_target] wasn't propagated: each leaf then resolves
## its own captured target independently at `advance()` time
## (`tech-spec.md` §Target-bound authoring contract).
func play() -> AnimaPlayback:
	if self is AnimaPropertyMotion and convenience_target == null:
		push_error("play() needs a target captured via Anima.on() — use Anima.play(motion, target) instead.")
		return null
	return Anima.play(self, convenience_target)

## Reports this motion's duration kind and (when known) its length in seconds.
## Every subtype must override this explicitly.
func estimate_duration() -> AnimaDuration:
	push_error("AnimaMotion.estimate_duration() must be overridden by a subtype")
	return AnimaDuration.fixed(0.0)

## Builds the runtime instance that [method AnimaMotionInstance.advance]s this
## motion frame by frame. Every subtype must override this explicitly.
## [param context] is the per-resolution context an [AnimaValue]-typed field
## resolves against, supplied by [AnimaPlayback] (or a group/grid item's own
## context — see `tech-spec.md` §Dynamic values); `null` when none applies.
func create_runtime(context: AnimaValueContext = null) -> Variant:
	push_error("AnimaMotion.create_runtime() must be overridden by a subtype")
	return null

## Returns a list of human-readable configuration errors, or an empty array
## when this motion (and its children, if any) are valid.
func validate() -> Array[String]:
	return []

## Builds an [_AnimaSequence] that plays this motion, then [param other],
## in order — the same resource [method Motion.sequence] would build.
## Chaining a second `.then()` appends another step to one flat sequence
## instead of nesting (`a.then(b).then(c)` is a 3-step sequence, not a
## sequence of sequences). See [method with] for combining steps that
## should start together instead. [param other] accepts an [AnimaMotion]
## or any object exposing a `motion: AnimaMotion` property (a convenience
## factory like [AnimaGridMotionFactory]) — resolved via [method
## _resolve_chainable] (`tech-spec.md` §Target-bound authoring contract,
## "Chaining a motion factory directly").
func then(other: Variant) -> _AnimaSequence:
	var resolved_other := _resolve_chainable(other, "then")

	var sequence := _AnimaSequence.new()
	if self is _AnimaSequence:
		sequence.children.append_array((self as _AnimaSequence).children)
	else:
		sequence.children.append(self)

	if resolved_other == null:
		# _resolve_chainable already reported the error — return self's own
		# steps unchanged rather than building a broken composite.
		sequence.convenience_target = convenience_target
		return sequence

	if _pending_chain_wait != 0.0:
		resolved_other.delay += _pending_chain_wait
		_pending_chain_wait = 0.0

	sequence.children.append(resolved_other)
	sequence.convenience_target = _shared_convenience_target(convenience_target, resolved_other.convenience_target)
	return sequence

## Folds [param other] into the same [_AnimaParallel] group as whatever was
## most recently chained — the group open since the last [method then], or
## the whole chain when no [method then] preceded it. Multiple consecutive
## `.with()` calls join one growing group rather than nesting
## (`a.then(b).with(c).with(d)` is `b`, `c`, and `d` all starting together,
## after `a`). Accepts the same [param other] types as [method then].
func with(other: Variant) -> AnimaMotion:
	var resolved_other := _resolve_chainable(other, "with")
	if resolved_other == null:
		return self

	if _pending_chain_wait != 0.0:
		resolved_other.delay += _pending_chain_wait
		_pending_chain_wait = 0.0

	if not (self is _AnimaSequence):
		return _grouped_with(self, resolved_other)

	var sequence := self as _AnimaSequence
	if sequence.children.is_empty():
		return resolved_other

	var result := _AnimaSequence.new()
	result.children.append_array(sequence.children)
	var last_index := result.children.size() - 1
	result.children[last_index] = _grouped_with(result.children[last_index], resolved_other)
	result.convenience_target = _shared_convenience_target(sequence.convenience_target, resolved_other.convenience_target)
	return result

## Resolves [param value] — passed to [method then]/[method with] as `other`
## — into an [AnimaMotion]: [param value] itself when it already is one, or
## the [AnimaMotion] held by its `motion` property when [param value] is a
## convenience factory ([AnimaGridMotionFactory] and any future factory built
## the same way). Reports an error naming [param caller] and [param value]'s
## type, and returns `null`, for anything else — the caller falls back to a
## no-op rather than building a broken composite (`tech-spec.md`
## §Target-bound authoring contract, "Chaining a motion factory directly").
func _resolve_chainable(value: Variant, caller: String) -> AnimaMotion:
	if value is AnimaMotion:
		return value
	# `"motion" in value` means substring search for a String, not property
	# lookup — restrict the property check to actual Objects first.
	if value is Object and "motion" in value and value.motion is AnimaMotion:
		return value.motion
	push_error("AnimaMotion.%s() needs an AnimaMotion or a factory exposing .motion — got %s." % [caller, type_string(typeof(value))])
	return null

## Shared helper for [method with]: groups [param existing] and [param other]
## into one [_AnimaParallel], flattening when [param existing] is already one.
func _grouped_with(existing: AnimaMotion, other: AnimaMotion) -> _AnimaParallel:
	var parallel := _AnimaParallel.new()
	if existing is _AnimaParallel:
		parallel.children.append_array((existing as _AnimaParallel).children)
	else:
		parallel.children.append(existing)
	parallel.children.append(other)
	parallel.convenience_target = _shared_convenience_target(existing.convenience_target, other.convenience_target)
	return parallel

## Returns [param a] when it equals [param b] and both are non-null, else
## `null` — the propagation rule [method then]/[method with] use for
## [member convenience_target] (`tech-spec.md` §Target-bound authoring
## contract, "`.play()` and per-leaf convenience targets").
func _shared_convenience_target(a: Node, b: Node) -> Node:
	if a != null and a == b:
		return a
	return null

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

## Wraps this motion in a new [_AnimaRepeat] that plays it [param count] times
## — the same resource [method Motion.repeat] would build, now reachable as a
## chain call on any motion, including one built through [method Anima.on].
## [param count] defaults to `-1`, which repeats indefinitely instead of a
## fixed number of times. [param alternate] `true` ping-pongs every other
## iteration between forward and backward (v1's `loop_in_circle`) instead of
## repeating identically.
func repeat(count: int = -1, alternate: bool = false) -> _AnimaRepeat:
	var result := _AnimaRepeat.new()
	result.child = self
	result.count = count
	result.alternate = alternate
	return result

## Sets [member speed] directly. Named `with_speed` rather than `speed()` for
## the same reason as `with_duration`/`with_ease`/`with_delay` on leaf motion
## types — a bare method name would collide with the field of the same name.
## Returns self so calls can keep chaining.
func with_speed(value: float) -> AnimaMotion:
	speed = value
	return self

## Sets [member delay] directly on this motion — including a composite built
## by [method then]/[method with], which previously had no way to delay its
## own overall start except repeating a per-leaf [method
## AnimaPropertyMotion.with_delay]/[method AnimaKeyframeMotion.with_delay] on
## every child. [AnimaPlayback] already reads the root motion's [member
## delay] before its first frame advances, so this base implementation is the
## only piece that was missing (`tech-spec.md` §Key technical decisions, the
## `AnimaMotion.with_delay()` bullet). [AnimaPropertyMotion]/
## [AnimaKeyframeMotion] override this with a narrower return type so
## duration/ease chaining still works after it; every other subtype
## (including a `.then()`/`.with()` composite) uses this base implementation
## directly. Returns self so calls can keep chaining.
func with_delay(value: float) -> AnimaMotion:
	delay = value
	return self

## Delays the start of whatever gets combined next via [method then]/[method
## with], instead of this motion's own start — the inline-pause counterpart
## to [method with_delay], which delays this motion itself. [param seconds]
## is added onto the next combined motion's own [member delay] (not a
## replacement), so a preceding [method wait] and an explicit [method
## with_delay] already set on that next step stack additively
## (`tech-spec.md` §Key technical decisions, the `.wait()` bullet). Consumed
## exactly once, by the very next [method then]/[method with] call — ending a
## chain, or calling [method play], with a [method wait] left unconsumed is a
## harmless no-op. Returns self so calls can keep chaining.
func wait(seconds: float) -> AnimaMotion:
	_pending_chain_wait = seconds
	return self
