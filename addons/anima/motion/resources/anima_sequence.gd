class_name AnimaSequence
extends AnimaMotion

@export var children: Array[AnimaMotion] = []

func estimate_duration() -> float:
	var total := 0.0
	for child in children:
		if child.enabled:
			total += child.estimate_duration()
	return total

func create_runtime() -> Variant:
	return AnimaSequenceInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	for child in children:
		errors.append_array(child.validate())
	return errors
