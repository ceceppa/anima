## Anima's public entry point — a [code]class_name[/code]-declared static
## facade, never a [code]project.godot[/code] autoload. Zero mandatory setup:
## [method play] works on the very first call.
class_name Anima
extends RefCounted

## Node metadata key an [AnimaBehaviour] is stored under — no hidden child
## node or node subclass (tech-spec.md §Data model `AnimaBehaviour` row).
const BEHAVIOUR_META_KEY := "_anima_behaviour"
## Private group every node with an attached [AnimaBehaviour] is added to,
## for discovery.
const BEHAVIOUR_GROUP := "_anima_enabled"

## Plays [param motion] against [param target] and returns the resulting
## [AnimaPlayback]. [param target] is optional when [param motion] supplies
## its own targets (e.g. [AnimaStagger], which ignores [param target]
## entirely). An [AnimaGroupMotion] is different: it still reads [param
## target] as the root node its [member AnimaGroupMotion.target_collection]
## resolves against — required for a [constant AnimaTargetCollection.Kind.CHILDREN]
## or [constant AnimaTargetCollection.Kind.DESCENDANTS] collection, unused otherwise.
##
## ```gdscript
## var collection := AnimaTargetCollection.new()
## collection.kind = AnimaTargetCollection.Kind.CHILDREN
## var group := Motion.group(collection, Motion.to(NodePath("modulate:a"), 1.0))
##
## Anima.play(group, $CardRow) # $CardRow's children are the group's targets
## ```
static func play(motion: AnimaMotion, target: Node = null) -> AnimaPlayback:
	return AnimaRuntime.get_singleton().play(motion, target)

## Returns a lightweight proxy for animating [param node] directly —
## `Anima.of(node).to(...)` — without building an [AnimaMotion] resource by hand.
static func of(node: Node) -> AnimaNodeProxy:
	return AnimaNodeProxy.new(node)

## Attaches [param behaviour] to [param node] via node metadata — [param node]'s
## class and script are unchanged. Retrieve it later with [method get_behaviour].
static func attach_behaviour(node: Node, behaviour: AnimaBehaviour) -> void:
	node.set_meta(BEHAVIOUR_META_KEY, behaviour)
	if not node.is_in_group(BEHAVIOUR_GROUP):
		node.add_to_group(BEHAVIOUR_GROUP)

## Returns the [AnimaBehaviour] attached to [param node], or `null` if none.
static func get_behaviour(node: Node) -> AnimaBehaviour:
	if not node.has_meta(BEHAVIOUR_META_KEY):
		return null
	return node.get_meta(BEHAVIOUR_META_KEY) as AnimaBehaviour
