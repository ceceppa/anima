## Animates a single property on a node from one value to another. The only
## leaf motion type — every composite eventually plays one of these.
class_name AnimaPropertyMotion
extends AnimaMotion

## The property to animate, e.g. `NodePath("position:x")`.
@export var target_property: NodePath = NodePath()
## Starting value. `null` reads the target's current value when playback starts.
@export var from_value: Variant = null
## Value to animate to.
@export var to_value: Variant = null
## How long the motion takes, in seconds. Unused when [member ease] is
## [constant AnimaEase.Kind.SPRING] — a spring settles on its own instead.
@export var duration: float = 0.0
## The curve (or spring) driving the animation.
@export var ease: AnimaEase = AnimaEase.new()

## `FIXED` for every ease except [constant AnimaEase.Kind.SPRING], which
## reports `ESTIMATED` (a settle-time estimate derived from its parameters).
func estimate_duration() -> AnimaDuration:
	if ease.kind == AnimaEase.Kind.SPRING:
		return AnimaDuration.estimated(ease.spring_estimated_seconds())
	return AnimaDuration.fixed(duration)

## Builds the runtime instance that animates [member target_property].
func create_runtime() -> Variant:
	return AnimaPropertyMotionInstance.new(self)

## Requires [member target_property].
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

## See [method with_duration].
func with_ease(value: AnimaEase) -> AnimaPropertyMotion:
	ease = value
	return self
