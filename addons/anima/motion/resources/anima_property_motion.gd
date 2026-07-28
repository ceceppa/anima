class_name AnimaPropertyMotion
extends AnimaMotion

@export var target_property: NodePath = NodePath()
@export var from_value: Variant = null
@export var to_value: Variant = null
@export var duration: float = 0.0
@export var ease: AnimaEase = AnimaEase.new()

func estimate_duration() -> float:
	return duration

func create_runtime() -> Variant:
	push_error("AnimaPropertyMotion.create_runtime() is not implemented until the runtime lands (story-3)")
	return null

func validate() -> Array[String]:
	var errors: Array[String] = []
	if target_property.is_empty():
		errors.append("target_property is required")
	return errors
