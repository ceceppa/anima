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

func _init(p_target: Node = null) -> void:
	target = p_target
	root = p_target
