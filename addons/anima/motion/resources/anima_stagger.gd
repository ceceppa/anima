## Plays one instance of [member template] per entry in [member targets],
## started [member interval] seconds apart in the resolved [member order].
class_name AnimaStagger
extends AnimaMotion

## The order [member targets] start in.
enum Order {
	FORWARD,
	REVERSE,
	FROM_CENTER,
	FROM_EDGES,
	CUSTOM,
	RANDOM,
}

## The motion played against every entry in [member targets].
@export var template: AnimaMotion = null
## Untyped (not Array[Node]): a typed Node array on a Resource script fails
## Godot 4.6's external-class-member static resolution when set from another script.
@export var targets: Array = []
## Seconds between one target starting and the next.
@export var interval: float = 0.05
## The order [member targets] start in.
@export var order: Order = Order.FORWARD
## Explicit start-order target indices, used only when [member order] is
## [constant Order.CUSTOM].
@export var custom_order: Array[int] = []

## Returns target indices in the order each entry should start, per `order`.
func resolve_order() -> Array[int]:
	var n := targets.size()
	var indices: Array[int] = []
	for i in range(n):
		indices.append(i)

	match order:
		Order.FORWARD:
			return indices
		Order.REVERSE:
			indices.reverse()
			return indices
		Order.FROM_CENTER:
			var center := float(n - 1) / 2.0
			indices.sort_custom(func(a: int, b: int) -> bool:
				var da := absf(a - center)
				var db := absf(b - center)
				return da < db if not is_equal_approx(da, db) else a < b
			)
			return indices
		Order.FROM_EDGES:
			indices.sort_custom(func(a: int, b: int) -> bool:
				var da: int = mini(a, n - 1 - a)
				var db: int = mini(b, n - 1 - b)
				return da < db if da != db else a < b
			)
			return indices
		Order.CUSTOM:
			return custom_order.duplicate()
		Order.RANDOM:
			indices.shuffle()
			return indices
		_:
			return indices

## The template's own kind, combined with the staggered start offsets — not a
## sum of per-target durations, since targets start staggered rather than end-to-end.
func estimate_duration() -> AnimaDuration:
	if template == null or targets.is_empty():
		return AnimaDuration.fixed(0.0)

	var template_duration := template.estimate_duration()
	if template_duration.kind != AnimaDuration.Kind.FIXED:
		return AnimaDuration.new(template_duration.kind, 0.0)

	var total: float = float(targets.size() - 1) * interval + template_duration.seconds
	return AnimaDuration.fixed(total)

## Builds the runtime instance that plays [member template] across [member targets].
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaStaggerInstance.new(self, context)

## Requires [member template], and one [member custom_order] entry per target
## when [member order] is [constant Order.CUSTOM].
func validate() -> Array[String]:
	var errors: Array[String] = []
	if template == null:
		errors.append("template is required")
	elif order == Order.CUSTOM and custom_order.size() != targets.size():
		errors.append("custom_order must have one index per target")
	if template != null:
		errors.append_array(template.validate())
	return errors
