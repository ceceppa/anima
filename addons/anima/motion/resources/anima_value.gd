## A motion property value resolved against live playback state instead of a
## fixed literal — e.g. a target's own current size, or another node's
## property — restoring Anima v1's dynamic-expression capability
## (`"-.:size:x"`) in typed form. Accepted anywhere a fixed value is accepted
## today: [member AnimaPropertyMotion.from_value]/[member
## AnimaPropertyMotion.to_value] and [member AnimaKeyframeStop.value].
##
## One polymorphic [Resource] with a [member kind] discriminator — the same
## shape [AnimaEase] already uses for its own many kinds — rather than a
## subtype per source (`tech-spec.md` §Dynamic values).
class_name AnimaValue
extends Resource

## Which source [method resolve] reads from.
enum Kind {
	## A wrapped literal — see [method constant].
	CONSTANT,
	## The animated target's own property — see [method target].
	TARGET,
	## Another node's property, found by path — see [method node].
	NODE,
	## The group/grid's own container, or the animated target for a plain
	## motion — see [method root].
	ROOT,
	## Arbitrary data supplied to the playback before it starts — see
	## [method context].
	CONTEXT,
	## This item's position in start order among its group — see [method group_index].
	GROUP_INDEX,
	## The group's total item count — see [method group_count].
	GROUP_COUNT,
	## [constant GROUP_INDEX] normalised to `0.0`-`1.0` — see [method group_normalised_index].
	GROUP_NORMALISED_INDEX,
	## This item's row within an [AnimaGridMotion] — see [method grid_row].
	GRID_ROW,
	## This item's column within an [AnimaGridMotion] — see [method grid_column].
	GRID_COLUMN,
	## Sum of two operands — see [method add].
	ADD,
	## First operand minus the second — see [method subtract].
	SUBTRACT,
	## Product of two operands — see [method multiply].
	MULTIPLY,
	## First operand divided by the second — see [method divide].
	DIVIDE,
	## Negation of one operand — see [method negative].
	NEGATIVE,
	## Absolute value of one operand — see [method absolute].
	ABSOLUTE,
	## Smaller of two operands — see [method minimum].
	MINIMUM,
	## Larger of two operands — see [method maximum].
	MAXIMUM,
	## One operand clamped between two bounds — see [method clamp].
	CLAMP,
	## One operand linearly remapped from one range to another — see [method map].
	MAP,
	## One vector component of one operand — see [method x], [method y],
	## [method z], [method component].
	COMPONENT,
	## Result of an author-supplied custom calculation — see [method custom].
	CUSTOM,
	## Character count of one operand's resolved [String] — see [method length].
	LENGTH,
}

## Which source [method resolve] reads from.
@export var kind: Kind = Kind.CONSTANT
## The wrapped literal, used only when [member kind] is [constant Kind.CONSTANT].
@export var constant_value: Variant = null
## The property to read, used by [constant Kind.TARGET], [constant Kind.NODE],
## and [constant Kind.ROOT].
@export var property_path: NodePath = NodePath()
## The other node's path, relative to the resolving context's own root — used
## only when [member kind] is [constant Kind.NODE].
@export var node_path: NodePath = NodePath()
## The key to read from the playback's context data — used only when [member
## kind] is [constant Kind.CONTEXT].
@export var context_key: String = ""
## Each entry is a literal [Variant] or a nested [AnimaValue], resolved in
## order before the operation itself runs. Used by every arithmetic
## [member kind]: index 0 is always the value the chain method was called
## on; the rest depend on the operation (e.g. [constant Kind.CLAMP] is
## `[value, min, max]`, [constant Kind.MAP] is
## `[value, in_min, in_max, out_min, out_max]`).
@export var operands: Array = []
## Which vector component to extract, used only when [member kind] is
## [constant Kind.COMPONENT] (`0` = x, `1` = y, `2` = z).
@export var component_index: int = 0
## The author-supplied calculation, used only when [member kind] is
## [constant Kind.CUSTOM]. Called with the same [AnimaValueContext]
## [method resolve] itself receives.
@export var custom_callable: Callable = Callable()

## Wraps [param value] so it can serve as an operand in an arithmetic
## combination, or as a value that happens to be typed [AnimaValue].
static func constant(value: Variant) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.CONSTANT
	result.constant_value = value
	return result

## Reads [param property] from the node this value is resolving for — Anima
## v1's `.`/self reference.
static func target(property: NodePath) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.TARGET
	result.property_path = property
	return result

## Reads [param property] from the node at [param path], resolved relative to
## the resolving context's own root — Anima v1's arbitrary node-path
## reference. A group/grid item's root is the group's own container, never
## another item (`tech-spec.md` §Dynamic values).
static func node(path: NodePath, property: NodePath) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.NODE
	result.node_path = path
	result.property_path = property
	return result

## Reads [param property] directly from the resolving context's own root —
## the group's own container for a group/grid item, or the animated target
## itself for a plain motion.
static func root(property: NodePath) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.ROOT
	result.property_path = property
	return result

## Reads [param key] from the data supplied to the playback before it started
## (see [member AnimaPlayback.context_data]). Returns `null` if nothing was
## stored under that key.
static func context(key: String) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.CONTEXT
	result.context_key = key
	return result

## Reads this item's position in start order among its group — `-1` outside
## a group/grid item (see [member AnimaValueContext.group_index]).
static func group_index() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.GROUP_INDEX
	return result

## Reads the group's total item count — `-1` outside a group/grid item.
static func group_count() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.GROUP_COUNT
	return result

## Reads this item's [method group_index] normalised to `0.0`-`1.0` across
## the group — `-1.0` outside a group/grid item.
static func group_normalised_index() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.GROUP_NORMALISED_INDEX
	return result

## Reads this item's row within an [AnimaGridMotion] — `-1` outside one.
static func grid_row() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.GRID_ROW
	return result

## Reads this item's column within an [AnimaGridMotion] — `-1` outside one.
static func grid_column() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.GRID_COLUMN
	return result

## Combines this value with [param other] (a literal or another [AnimaValue])
## by addition. Returns a new [AnimaValue] — this one is never mutated, so it
## stays safe to reuse as the base of a different combination elsewhere.
func add(other: Variant) -> AnimaValue:
	return _binary(Kind.ADD, other)

## See [method add]. Subtracts [param other] from this value.
func subtract(other: Variant) -> AnimaValue:
	return _binary(Kind.SUBTRACT, other)

## See [method add]. Multiplies this value by [param other].
func multiply(other: Variant) -> AnimaValue:
	return _binary(Kind.MULTIPLY, other)

## See [method add]. Divides this value by [param other].
func divide(other: Variant) -> AnimaValue:
	return _binary(Kind.DIVIDE, other)

## See [method add]. Resolves to whichever of this value and [param other] is smaller.
func minimum(other: Variant) -> AnimaValue:
	return _binary(Kind.MINIMUM, other)

## See [method add]. Resolves to whichever of this value and [param other] is larger.
func maximum(other: Variant) -> AnimaValue:
	return _binary(Kind.MAXIMUM, other)

func _binary(op_kind: Kind, other: Variant) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = op_kind
	result.operands = [self, other]
	return result

## Negates this value. See [method add] for the "returns a new AnimaValue" contract.
func negative() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.NEGATIVE
	result.operands = [self]
	return result

## Resolves to the absolute value of this value.
func absolute() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.ABSOLUTE
	result.operands = [self]
	return result

## Resolves to the character count of this value's resolved [String] — e.g.
## a target's own `text` length, for a content-length-scaled duration
## (`tech-spec.md` §Animation catalog, "`typewrite`'s content-length-scaled
## duration").
func length() -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.LENGTH
	result.operands = [self]
	return result

## Clamps this value between [param min_value] and [param max_value] (each a
## literal or another [AnimaValue]) — the resolved result never falls outside
## those bounds, even when this value's own resolution would otherwise exceed
## them.
func clamp(min_value: Variant, max_value: Variant) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.CLAMP
	result.operands = [self, min_value, max_value]
	return result

## Linearly remaps this value from the range [param in_min]-[param in_max] to
## [param out_min]-[param out_max] (each a literal or another [AnimaValue]).
func map(in_min: Variant, in_max: Variant, out_min: Variant, out_max: Variant) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.MAP
	result.operands = [self, in_min, in_max, out_min, out_max]
	return result

## Extracts this value's x component. Fails validation at resolve time if
## this value doesn't resolve to a vector.
func x() -> AnimaValue:
	return _component(0)

## See [method x]. Extracts the y component.
func y() -> AnimaValue:
	return _component(1)

## See [method x]. Extracts the z component.
func z() -> AnimaValue:
	return _component(2)

## See [method x]. Extracts the component at [param index] (`0` = x, `1` = y, `2` = z).
func component(index: int) -> AnimaValue:
	return _component(index)

func _component(index: int) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.COMPONENT
	result.operands = [self]
	result.component_index = index
	return result

## Resolves through [param callable] instead of a structural operation above —
## the escape hatch for a calculation those can't express (Anima v1's
## formulas ran through Godot's full [Expression] parser, so arbitrary math
## was implicitly available; this covers the same ground explicitly).
## [param callable] receives the same [AnimaValueContext] [method resolve]
## itself receives. Runtime-only: potentially non-serialisable,
## non-compilable, and unavailable in editor preview, the same limitation
## [constant AnimaEase.Kind.CALLABLE] already has.
static func custom(callable: Callable) -> AnimaValue:
	var result := AnimaValue.new()
	result.kind = Kind.CUSTOM
	result.custom_callable = callable
	return result

## Resolves [param operand] against [param context] — through [method resolve]
## if it is itself an [AnimaValue], or returned unchanged as a literal.
func _resolve_operand(operand: Variant, context: AnimaValueContext) -> Variant:
	if operand is AnimaValue:
		return (operand as AnimaValue).resolve(context)
	return operand

## Resolves this value against [param context]. A [constant Kind.NODE]
## reference that can't be found reports an error and returns `null` instead
## of silently animating to an unresolved value.
func resolve(context: AnimaValueContext) -> Variant:
	match kind:
		Kind.CONSTANT:
			return constant_value
		Kind.TARGET:
			return context.target.get_indexed(property_path)
		Kind.NODE:
			var node_ref: Node = context.root.get_node_or_null(node_path)
			if node_ref == null:
				push_error("AnimaValue.node(): no node found at path '%s' relative to '%s'" % [node_path, context.root.get_path()])
				return null
			return node_ref.get_indexed(property_path)
		Kind.ROOT:
			return context.root.get_indexed(property_path)
		Kind.CONTEXT:
			return context.context_data.get(context_key)
		Kind.GROUP_INDEX:
			return context.group_index
		Kind.GROUP_COUNT:
			return context.group_count
		Kind.GROUP_NORMALISED_INDEX:
			return context.group_normalised_index
		Kind.GRID_ROW:
			return context.grid_row
		Kind.GRID_COLUMN:
			return context.grid_column
		Kind.ADD:
			return _resolve_operand(operands[0], context) + _resolve_operand(operands[1], context)
		Kind.SUBTRACT:
			return _resolve_operand(operands[0], context) - _resolve_operand(operands[1], context)
		Kind.MULTIPLY:
			return _resolve_operand(operands[0], context) * _resolve_operand(operands[1], context)
		Kind.DIVIDE:
			return _resolve_operand(operands[0], context) / _resolve_operand(operands[1], context)
		Kind.NEGATIVE:
			return -_resolve_operand(operands[0], context)
		Kind.ABSOLUTE:
			return abs(_resolve_operand(operands[0], context))
		Kind.MINIMUM:
			return min(_resolve_operand(operands[0], context), _resolve_operand(operands[1], context))
		Kind.MAXIMUM:
			return max(_resolve_operand(operands[0], context), _resolve_operand(operands[1], context))
		Kind.CLAMP:
			return clampf(_resolve_operand(operands[0], context), _resolve_operand(operands[1], context), _resolve_operand(operands[2], context))
		Kind.MAP:
			var raw: float = _resolve_operand(operands[0], context)
			var in_min: float = _resolve_operand(operands[1], context)
			var in_max: float = _resolve_operand(operands[2], context)
			var out_min: float = _resolve_operand(operands[3], context)
			var out_max: float = _resolve_operand(operands[4], context)
			return out_min + (raw - in_min) / (in_max - in_min) * (out_max - out_min)
		Kind.COMPONENT:
			var raw = _resolve_operand(operands[0], context)
			match component_index:
				0:
					return raw.x
				1:
					return raw.y
				2:
					return raw.z
				_:
					push_error("AnimaValue.component(): index %d is not a valid vector component" % component_index)
					return null
		Kind.LENGTH:
			var length_operand: Variant = _resolve_operand(operands[0], context)
			if length_operand == null:
				return 0
			return String(length_operand).length()
		Kind.CUSTOM:
			return custom_callable.call(context)
		_:
			push_error("AnimaValue.resolve(): unhandled Kind %s" % kind)
			return null
