## One canonical stop within an [AnimaKeyframeTrack] — one property's value at
## one normalised offset, with optional per-segment easing.
##
## Never constructed by hand in ordinary authoring; [AnimaKeyframeMotion]
## builds these while parsing an authored keyframe declaration.
class_name AnimaKeyframeStop
extends Resource

## Normalised position within the motion's duration, from 0.0 ("from") to 1.0 ("to").
@export var offset: float = 0.0
## This stop's value for its track's property — a fixed literal, or an
## [AnimaValue] resolved against the animated target the same way one is
## anywhere else a value is accepted (`tech-spec.md` §Dynamic values).
@export var value: Variant = null
## Easing for the segment arriving at this stop, from the previous stop's
## offset to this one. `null` falls back to [member AnimaKeyframeMotion.default_ease].
@export var ease: AnimaEase = null
## An [enum AnimaPropertyMotion.Pivot] declared inline with this stop, or
## `null` when not declared here. Authoring convenience only — pivot
## resolves once for the whole motion, not per stop (`tech-spec.md`
## §Keyframe motions, "Pivot"). Never constructed by hand; see [member ease].
@export var pivot: Variant = null
