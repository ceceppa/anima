## Animates a single property on a node from one value to another. The only
## leaf motion type — every composite eventually plays one of these.
class_name AnimaPropertyMotion
extends AnimaMotion

## Restored Anima v1 anchor positions a scale or rotation motion can
## transform around, instead of the target's default origin. Only takes
## effect when [member target_property] is `scale`/`scale:x`/`scale:y` or
## `rotation` — see [member pivot] (`tech-spec.md` §Motion pivot control).
enum Pivot {
	## No pivot override — the target's default transform origin is used.
	NONE,
	TOP_LEFT,
	TOP_CENTER,
	TOP_RIGHT,
	CENTER_LEFT,
	CENTER,
	CENTER_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_CENTER,
	BOTTOM_RIGHT,
}

## The property to animate, e.g. `NodePath("position:x")`.
@export var target_property: NodePath = NodePath()
## Starting value. `null` reads the target's current value when playback starts.
@export var from_value: Variant = null
## Value to animate to. Interpreted as an absolute destination, unless
## [member relative] is `true` — see [member relative].
@export var to_value: Variant = null
## How long the motion takes, in seconds. Unused when [member ease] is
## [constant AnimaEase.Kind.SPRING] — a spring settles on its own instead.
@export var duration: float = 0.0
## The curve (or spring) driving the animation.
@export var ease: AnimaEase = AnimaEase.new()
## When `true`, [member to_value] is added to the resolved start value
## instead of replacing it — e.g. move 40 pixels right from wherever the
## target actually is, instead of moving to x = 40. Used by `move_by()`,
## `scale_by()`, `rotate_by()`, and the generic [method relative] modifier
## (`tech-spec.md` §Target-bound authoring contract). Named is_relative
## rather than relative — that name is the [method relative] chain method
## below, and GDScript cannot declare a method with the same name as a
## property (see [method with_duration]).
@export var is_relative: bool = false
## Anchor position a scale or rotation motion transforms around, restored
## from Anima v1. Ignored on any other property, or a target that supports
## neither `Control`'s native pivot nor an `offset`+`texture` pair
## (`tech-spec.md` §Motion pivot control).
@export var pivot: Pivot = Pivot.NONE

## `FIXED` for every ease except [constant AnimaEase.Kind.SPRING], which
## reports `ESTIMATED` (a settle-time estimate derived from its parameters).
func estimate_duration() -> AnimaDuration:
	if ease.kind == AnimaEase.Kind.SPRING:
		return AnimaDuration.estimated(ease.spring_estimated_seconds())
	return AnimaDuration.fixed(duration)

## Builds the runtime instance that animates [member target_property]. See
## [method AnimaMotion.create_runtime] for [param context].
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaPropertyMotionInstance.new(self, context)

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

## See [method with_duration]. Named with_delay rather than delay — that name
## is [member AnimaMotion.delay] above, inherited from the base resource.
func with_delay(value: float) -> AnimaPropertyMotion:
	delay = value
	return self

## Sets an explicit starting value instead of reading the target's current
## value when playback starts. See [member from_value].
func from(value: Variant) -> AnimaPropertyMotion:
	from_value = value
	return self

## Clears an explicit start value, restoring the default of reading the
## target's current value when playback starts. Mainly useful for
## readability when a chain wants to say so explicitly.
func from_current() -> AnimaPropertyMotion:
	from_value = null
	return self

## Marks [member to_value] as a delta added to the resolved start value
## instead of an absolute destination. See [member is_relative].
func relative() -> AnimaPropertyMotion:
	is_relative = true
	return self

## See [method with_duration]. Sets [member pivot] directly — that name is
## the field above, and GDScript cannot declare a method with the same name.
func with_pivot(value: Pivot) -> AnimaPropertyMotion:
	pivot = value
	return self
