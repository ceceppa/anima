## Plays one shared motion across a collection of nodes as one coordinated group.
##
## A collection chooses the nodes, and the item motion describes what each node
## does. Playback, distribution, and order describe when each visible item starts.
##
## ```gdscript
## var group := AnimaGroupMotion.new()
## group.target_collection = AnimaTargetCollection.new()
## group.item_motion = Motion.to(NodePath("position:x"), 120.0)
## ```
class_name AnimaGroupMotion
extends AnimaMotion

## Chooses whether group items wait, begin together, or use staggered starts.
enum PlaybackMode {
	SEQUENTIAL,
	PARALLEL,
	STAGGERED,
}

## Chooses how a group treats item completion.
enum CompletionPolicy {
	ALL_ITEMS,
	FIRST_ITEM,
}

## Chooses how a reverse run reuses the recorded forward order.
enum ReverseOrderPolicy {
	REUSE_EXECUTION,
	REVERSE_EXECUTION,
}

## Chooses what happens when an item target cannot be used.
enum InvalidTargetPolicy {
	SKIP,
	CANCEL_GROUP,
}

## Chooses what happens when a collection resolves to no targets.
enum EmptyGroupPolicy {
	COMPLETE,
	REPORT_ERROR,
}

## The nodes this group will resolve when it plays.
@export var target_collection: AnimaTargetCollection = null
## The shared motion each resolved target receives.
@export var item_motion: AnimaMotion = null
## The relationship between item starts.
@export var playback_mode: PlaybackMode = PlaybackMode.STAGGERED
## Stagger timing choices, used only for [constant PlaybackMode.STAGGERED].
@export var distribution: AnimaGroupDistribution = AnimaGroupDistribution.new()
## The resolved-target order and starting point.
@export var order: AnimaGroupOrder = AnimaGroupOrder.new()
## Extra wait after each completed item in [constant PlaybackMode.SEQUENTIAL].
@export var sequential_gap: float = 0.0
## The completion event an author wants to observe.
@export var completion_policy: CompletionPolicy = CompletionPolicy.ALL_ITEMS
## The order policy used when the author reverses a group.
@export var reverse_order_policy: ReverseOrderPolicy = ReverseOrderPolicy.REUSE_EXECUTION
## The response when a resolved target cannot play.
@export var invalid_target_policy: InvalidTargetPolicy = InvalidTargetPolicy.SKIP
## The response when no targets are found.
@export var empty_group_policy: EmptyGroupPolicy = EmptyGroupPolicy.COMPLETE

## Reports the shared item motion’s duration because group scheduling is runtime work.
func estimate_duration() -> AnimaDuration:
	return item_motion.estimate_duration() if item_motion != null else AnimaDuration.fixed(0.0)

## Builds the runtime instance that resolves, schedules, and plays this group.
## See [method AnimaMotion.create_runtime] for [param context].
func create_runtime(context: AnimaValueContext = null) -> Variant:
	return AnimaGroupPlayback.new(self, context)

## Returns messages describing missing or incompatible authored group settings.
func validate() -> Array[String]:
	var errors: Array[String] = []
	if target_collection == null:
		errors.append("target_collection is required")
	if item_motion == null:
		errors.append("item_motion is required")
	else:
		errors.append_array(item_motion.validate())
	if sequential_gap < 0.0:
		errors.append("sequential_gap must be zero or greater")
	if distribution == null:
		errors.append("distribution is required")
	else:
		errors.append_array(distribution.validate())
	return errors
