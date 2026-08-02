## Names the source a group will later resolve into animation targets.
##
## A target is a Godot node that visibly changes. This resource stores the
## author’s choice; resolving the actual nodes belongs to group playback.
class_name AnimaTargetCollection
extends Resource

## The supported ways an author can supply nodes to a group.
enum Kind {
	## Uses the direct children of the node passed to the group.
	CHILDREN,
	## Uses the nodes or node paths listed in [member reference_data].
	EXPLICIT,
	## Uses every node that belongs to the named Godot scene group.
	SCENE_GROUP,
	## Uses every child below the node passed to the group, at any depth.
	DESCENDANTS,
	## Uses the nodes supplied by code when playback starts.
	RUNTIME_CALLABLE,
}

## Limits a collection to alternating zero-based positions before it is ordered.
##
## `ODD_ONLY` keeps positions `1`, `3`, and so on. `EVEN_ONLY` keeps positions
## `0`, `2`, and so on. Choose [constant Filter.NONE] to keep every target.
enum Filter {
	## Keeps every resolved target.
	NONE,
	## Keeps positions 1, 3, 5, and so on in the resolved collection.
	ODD_ONLY,
	## Keeps positions 0, 2, 4, and so on in the resolved collection.
	EVEN_ONLY,
}

## The source used to find the group’s target nodes.
@export var kind: Kind = Kind.CHILDREN
## References used by the selected source.
##
## For [constant Kind.EXPLICIT], add nodes or paths relative to the supplied
## root node. For [constant Kind.SCENE_GROUP], add the names of Godot scene
## groups. Runtime-supplied collections receive their nodes from code instead.
@export var reference_data: Array = []
## Chooses whether every target or only alternating zero-based positions play.
##
## Filtering happens before a group chooses its animation order, so these
## positions always refer to the visible collection order.
@export var filter: Filter = Filter.NONE
## Whether targets are chosen when the group begins playing.
##
## Keep this enabled when a scene can add or remove nodes before the animation
## starts. Disable it only when later playback code supplies a fixed snapshot.
@export var resolve_on_play: bool = true
