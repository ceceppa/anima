## Runs each enabled child in [member children] one after another; completes
## when the last one finishes.
class_name _AnimaSequence
extends AnimaMotion

## The motions to run in order.
@export var children: Array[AnimaMotion] = []

## Returns each enabled child's scheduled start time (seconds since the
## sequence's own start), honouring delay/delay_basis. Parallel array to
## this sequence's enabled children, in the same order.
func compute_schedule() -> Array[float]:
	var starts: Array[float] = []
	var previous_start := 0.0
	var previous_end := 0.0
	var first := true
	for child in children:
		if not child.enabled:
			continue

		var reference := 0.0
		if not first:
			reference = previous_start if child.delay_basis == AnimaMotion.DelayBasis.AFTER_PREVIOUS_STARTS else previous_end

		var scheduled_start: float = maxf(0.0, reference + child.delay)
		starts.append(scheduled_start)

		previous_start = scheduled_start
		previous_end = scheduled_start + child.estimate_duration().seconds
		first = false

	return starts

## Sum of every enabled child's scheduled end time, once every child reports
## a fixed duration (worst-kind-wins otherwise). Honours [method compute_schedule]'s
## delay/overlap timing, not a plain sum of durations.
func estimate_duration() -> AnimaDuration:
	var enabled_children: Array[AnimaMotion] = []
	for child in children:
		if child.enabled:
			enabled_children.append(child)

	if enabled_children.is_empty():
		return AnimaDuration.fixed(0.0)

	var child_durations: Array[AnimaDuration] = []
	for child in enabled_children:
		child_durations.append(child.estimate_duration())

	var kind := AnimaDuration.worst_kind(child_durations)
	if kind != AnimaDuration.Kind.FIXED:
		return AnimaDuration.new(kind, 0.0)

	var starts := compute_schedule()
	var latest_end := 0.0
	for i in range(enabled_children.size()):
		latest_end = maxf(latest_end, starts[i] + child_durations[i].seconds)
	return AnimaDuration.fixed(latest_end)

## Builds the runtime instance that plays each child per [method compute_schedule].
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaSequenceInstance.new(self, context)

## Validates every child recursively.
func validate() -> Array[String]:
	var errors: Array[String] = []
	for child in children:
		errors.append_array(child.validate())
	return errors
