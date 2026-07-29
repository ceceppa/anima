class_name AnimaRace
extends AnimaMotion

@export var children: Array[AnimaMotion] = []
@export var cancel_remaining: bool = true

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

func create_runtime() -> Variant:
	return AnimaRaceInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	for child in children:
		errors.append_array(child.validate())
	return errors
