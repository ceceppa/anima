class_name AnimaStagger
extends AnimaMotion

enum Order {
	FORWARD,
	REVERSE,
	FROM_CENTER,
	FROM_EDGES,
	CUSTOM,
	RANDOM,
}

@export var template: AnimaMotion = null
## Untyped (not Array[Node]): a typed Node array on a Resource script fails
## Godot 4.6's external-class-member static resolution when set from another script.
@export var targets: Array = []
@export var interval: float = 0.05
@export var order: Order = Order.FORWARD
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

func estimate_duration() -> AnimaDuration:
	if template == null or targets.is_empty():
		return AnimaDuration.fixed(0.0)

	var template_duration := template.estimate_duration()
	if template_duration.kind != AnimaDuration.Kind.FIXED:
		return AnimaDuration.new(template_duration.kind, 0.0)

	var total: float = float(targets.size() - 1) * interval + template_duration.seconds
	return AnimaDuration.fixed(total)

func create_runtime() -> Variant:
	return AnimaStaggerInstance.new(self)

func validate() -> Array[String]:
	var errors: Array[String] = []
	if template == null:
		errors.append("template is required")
	elif order == Order.CUSTOM and custom_order.size() != targets.size():
		errors.append("custom_order must have one index per target")
	if template != null:
		errors.append_array(template.validate())
	return errors
