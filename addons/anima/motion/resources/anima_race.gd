## Runs every enabled child in [member children] concurrently and completes
## as soon as the fastest one finishes.
class_name _AnimaRace
extends AnimaMotion

## The motions racing against each other.
@export var children: Array[AnimaMotion] = []
## Whether the runtime stops advancing the other children once one finishes.
## Setting this to `false` has no defined effect this phase.
@export var cancel_remaining: bool = true

## The fastest enabled child's duration (worst-kind-wins across children first).
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

	var fastest: float = child_durations[0].seconds
	for child_duration in child_durations:
		fastest = minf(fastest, child_duration.seconds)
	return AnimaDuration.fixed(fastest)

## Builds the runtime instance that races every enabled child.
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaRaceInstance.new(self, context)

## Validates every child recursively.
func validate() -> Array[String]:
	var errors: Array[String] = []
	for child in children:
		errors.append_array(child.validate())
	return errors
