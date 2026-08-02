## Describes the order and starting point a group uses to reveal its targets.
##
## A resolved target collection is just a flat list of nodes. `AnimaGroupOrder`
## decides which one visibly starts first, which starts last, and which ones
## start together as part of the same "wave" — without the author calculating
## any of that by hand. [AnimaGroupScheduler] reads this resource to turn a
## plain node list into that visible sequence.
class_name AnimaGroupOrder
extends Resource

## The broad ordering strategy for a resolved target collection.
enum Kind {
	## Keeps the resolved collection's own order — the first resolved target
	## starts first, and so on down the list. This is the default.
	FORWARD,
	## Reverses the resolved collection's order — the last resolved target
	## starts first, and so on back up the list.
	REVERSE,
	## Starts from the middle of the resolved collection and spreads outward
	## in both directions. When the collection has an even number of targets,
	## the two middle targets start together as the first wave.
	CENTRED,
	## Starts from both ends of the resolved collection at once and spreads
	## inward, meeting in the middle last.
	EDGE,
	## Starts targets in a shuffled order. [member seed] makes the shuffle
	## repeatable — replaying with the same seed always produces the same
	## visible sequence.
	RANDOM,
	## Starts targets by their distance from an origin cell in a virtual grid,
	## [member grid_columns] wide. Targets the same distance from the origin
	## cell start together as one wave. See [member origin].
	GRID,
	## Starts targets by their distance from a single origin position in the
	## resolved list. Targets the same distance from the origin start
	## together as one wave. See [member origin].
	DISTANCE,
	## Reserved for an author-supplied explicit start order. Not yet
	## configurable from this resource — falls back to [constant FORWARD]
	## until a matching field is added.
	EXPLICIT,
	## Reserved for an author-supplied custom ordering function. Not yet
	## configurable from this resource — falls back to [constant FORWARD]
	## until a matching field is added.
	CUSTOM,
}

## The point from which an order starts when that strategy uses an origin.
## Only [constant Kind.GRID] and [constant Kind.DISTANCE] read this — every
## other [member kind] has its own fixed starting point.
enum Origin {
	## Starts from the first resolved target.
	FIRST,
	## Starts from the last resolved target.
	LAST,
	## Starts from the middle of the resolved collection (or, for
	## [constant AnimaGroupOrder.Kind.GRID], the middle of the grid).
	CENTER,
	## Starts from the resolved target at [member origin_index].
	INDEX,
	## Starts from [member origin_point], read as a virtual position — a grid
	## column/row for [constant AnimaGroupOrder.Kind.GRID], or a fractional
	## list position for [constant AnimaGroupOrder.Kind.DISTANCE].
	POINT,
}

## The ordering strategy used for the group.
@export var kind: Kind = Kind.FORWARD
## The start point for origin-based ordering. First preserves list traversal.
@export var origin: Origin = Origin.FIRST
## The resolved-list position used when [member origin] is [constant Origin.INDEX].
@export var origin_index: int = 0
## The virtual position used when [member origin] is [constant Origin.POINT].
## See [constant Origin.POINT] for how [constant Kind.GRID] and
## [constant Kind.DISTANCE] each interpret this differently.
@export var origin_point: Vector2 = Vector2.ZERO
## Optional seed that makes a [constant Kind.RANDOM] order repeatable.
@export var seed: int = 0
## Column count used only by [constant Kind.GRID].
@export var grid_columns: int = 1
