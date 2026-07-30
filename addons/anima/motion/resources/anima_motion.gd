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
