class_name AnimaMotion
extends Resource

@export var display_name: String = ""
@export var enabled: bool = true
@export var delay: float = 0.0
@export var speed: float = 1.0
@export var tags: Array[String] = []
@export var metadata: Dictionary = {}

func estimate_duration() -> float:
	push_error("AnimaMotion.estimate_duration() must be overridden by a subtype")
	return 0.0

func create_runtime() -> Variant:
	push_error("AnimaMotion.create_runtime() must be overridden by a subtype")
	return null

func validate() -> Array[String]:
	return []
