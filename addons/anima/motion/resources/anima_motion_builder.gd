## Fluent, chainable factory layer over the [AnimaMotion] resource hierarchy —
## builds the same resources direct construction does, nothing new at runtime.
## Unprefixed by design; see `project-rules.md` §Naming.
class_name Motion
extends RefCounted

## Builds an [AnimaSequence] playing [param children] one after another.
static func sequence(children: Array[AnimaMotion]) -> AnimaSequence:
	var motion := AnimaSequence.new()
	motion.children = children
	return motion

## Builds an [AnimaParallel] playing [param children] together.
static func parallel(children: Array[AnimaMotion]) -> AnimaParallel:
	var motion := AnimaParallel.new()
	motion.children = children
	return motion

## Builds an [AnimaStagger] playing [param template] against each of [param targets],
## [param interval] seconds apart.
static func stagger(targets: Array[Node], template: AnimaMotion, interval: float) -> AnimaStagger:
	var motion := AnimaStagger.new()
	motion.targets = targets
	motion.template = template
	motion.interval = interval
	return motion

## Builds an [AnimaRepeat] playing [param child] [param count] times.
static func repeat(child: AnimaMotion, count: int) -> AnimaRepeat:
	var motion := AnimaRepeat.new()
	motion.child = child
	motion.count = count
	return motion

## Builds an [AnimaRace] that completes as soon as the fastest of [param children] finishes.
static func race(children: Array[AnimaMotion]) -> AnimaRace:
	var motion := AnimaRace.new()
	motion.children = children
	return motion

## Builds an [AnimaConditional] that plays [param when_true] or [param when_false]
## depending on [param condition].
static func conditional(condition: Callable, when_true: AnimaMotion, when_false: AnimaMotion) -> AnimaConditional:
	var motion := AnimaConditional.new()
	motion.condition = condition
	motion.when_true = when_true
	motion.when_false = when_false
	return motion

## Builds an [AnimaPropertyMotion] animating [param target_property] to [param to_value].
static func to(target_property: NodePath, to_value: Variant) -> AnimaPropertyMotion:
	var motion := AnimaPropertyMotion.new()
	motion.target_property = target_property
	motion.to_value = to_value
	return motion

## Builds an [AnimaGroupMotion] playing [param item_motion] against every
## target [param target_collection] resolves. The rest of a group's
## configuration — [member AnimaGroupMotion.playback_mode], [member
## AnimaGroupMotion.distribution], [member AnimaGroupMotion.order], and its
## policies — all have working defaults, so set only the ones you need to
## change directly on the returned resource.
##
## ```gdscript
## var collection := AnimaTargetCollection.new()
## collection.kind = AnimaTargetCollection.Kind.CHILDREN
##
## var group := Motion.group(collection, Motion.to(NodePath("modulate:a"), 1.0))
## group.order.kind = AnimaGroupOrder.Kind.CENTRED
##
## Anima.play(group, $CardRow)
## ```
static func group(target_collection: AnimaTargetCollection, item_motion: AnimaMotion) -> AnimaGroupMotion:
	var motion := AnimaGroupMotion.new()
	motion.target_collection = target_collection
	motion.item_motion = item_motion
	return motion
