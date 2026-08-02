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

## Optional label, e.g. for [constant AnimaParallel.CompletionPolicy.NAMED_CHILD].
@export var display_name: String = ""
## Disabled motions are skipped by every composite that contains them.
@export var enabled: bool = true
## Seconds relative to [member delay_basis]. Only [AnimaSequence] consumes
## this and [member delay_basis] this phase. May be negative (an overlap).
@export var delay: float = 0.0
## Which sibling instant [member delay] is measured from.
@export var delay_basis: DelayBasis = DelayBasis.AFTER_PREVIOUS_ENDS
## Playback speed multiplier.
@export var speed: float = 1.0
## Optional categorisation metadata — no logic reads or filters on this.
@export var tags: Array[String] = []
## Optional free-form metadata — no logic reads this.
@export var metadata: Dictionary = {}

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
