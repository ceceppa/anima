class_name AnimaPropertyMotion
extends AnimaMotion

@export var target_property: NodePath = NodePath()
@export var from_value: Variant = null
@export var to_value: Variant = null
@export var duration: float = 0.0
@export var ease: AnimaEase = AnimaEase.new()

func estimate_duration() -> AnimaDuration:
	return AnimaDuration.fixed(duration)

func create_runtime() -> Variant:
	return AnimaPropertyMotionInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	if target_property.is_empty():
		errors.append("target_property is required")
	return errors

## Chainable setters for the Motion builder API. Named with_duration/with_ease
## rather than duration/ease — those names are already the field names above,
## and GDScript cannot declare a method with the same name as a property.
func with_duration(value: float) -> AnimaPropertyMotion:
	duration = value
	return self

func with_ease(value: AnimaEase) -> AnimaPropertyMotion:
	ease = value
	return self
