## Transient, per-resolution context an [AnimaValue] resolves against — never
## serialized, built fresh for each resolution. A plain (non-group) motion's
## context has [member target] and [member root] pointing at the same node; a
## group/grid item's context has [member root] pointing at the group's own
## container instead (`tech-spec.md` §Dynamic values).
class_name AnimaValueContext
extends RefCounted

## The node this specific value resolution is happening for — [constant
## AnimaValue.Kind.TARGET] reads from this node.
var target: Node
## The node [constant AnimaValue.Kind.ROOT] reads from, and [constant
## AnimaValue.Kind.NODE] paths resolve relative to. Equal to [member target]
## for a plain motion; the group's own container for a group/grid item.
var root: Node
## Arbitrary data supplied to the playback before it starts, read by
## [constant AnimaValue.Kind.CONTEXT]. Shares the same [Dictionary] object as
## [member AnimaPlayback.context_data] — mutate that dictionary in place
## rather than reassigning it, or a context already built keeps pointing at
## the old one.
var context_data: Dictionary = {}
## This item's position in start order among its group, or `-1` outside a
## group/grid item.
var group_index: int = -1
## The group's total item count, or `-1` outside a group/grid item.
var group_count: int = -1
## [member group_index] normalised to `0.0`-`1.0` across the group, or `-1.0`
## outside a group/grid item.
var group_normalised_index: float = -1.0
## This item's row within an [AnimaGridMotion], or `-1` outside one.
var grid_row: int = -1
## This item's column within an [AnimaGridMotion], or `-1` outside one.
var grid_column: int = -1
## Whether 2D property paths read from a [Node3D] are mapped onto its local
## XY plane — set for a planar [AnimaKeyframeMotion] (see [AnimaPlanarAccess]).
var planar: bool = false

func _init(p_target: Node = null) -> void:
	target = p_target
	root = p_target

## Returns a copy of this context with [member planar] set to `true`, so a
## planar motion never changes a context other motions may share.
func as_planar() -> AnimaValueContext:
	var copy := AnimaValueContext.new(target)
	copy.root = root
	copy.context_data = context_data
	copy.group_index = group_index
	copy.group_count = group_count
	copy.group_normalised_index = group_normalised_index
	copy.grid_row = grid_row
	copy.grid_column = grid_column
	copy.planar = true
	return copy
