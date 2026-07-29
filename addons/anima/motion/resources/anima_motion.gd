class_name AnimaMotion
extends Resource

enum DelayBasis {
	AFTER_PREVIOUS_ENDS,
	AFTER_PREVIOUS_STARTS,
}

@export var display_name: String = ""
@export var enabled: bool = true
@export var delay: float = 0.0
@export var delay_basis: DelayBasis = DelayBasis.AFTER_PREVIOUS_ENDS
@export var speed: float = 1.0
@export var tags: Array[String] = []
@export var metadata: Dictionary = {}

func estimate_duration() -> AnimaDuration:
	push_error("AnimaMotion.estimate_duration() must be overridden by a subtype")
	return AnimaDuration.fixed(0.0)

func create_runtime() -> Variant:
	push_error("AnimaMotion.create_runtime() must be overridden by a subtype")
	return null

func validate() -> Array[String]:
	return []
