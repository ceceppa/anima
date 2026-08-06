## Checks whether an [AnimaGroupMotion] can compile into a native [Animation],
## and compiles an eligible one.
##
## Editor/tooling code, not something runtime playback depends on — see
## `project-rules.md` §Editor Boundaries. Compiling reuses the same
## [AnimaTargetResolver] and [AnimaGroupScheduler] runtime playback itself
## uses, so a compiled Animation's visible item starts always match what
## [method Anima.play] would have produced.
class_name AnimaGroupCompiler
extends RefCounted

## Why a group can't compile into a native [Animation] right now. [constant NONE]
## means it's eligible.
enum Blocker {
	## The group is eligible for compilation.
	NONE,
	## The target collection is supplied by code at play time
	## ([constant AnimaTargetCollection.Kind.RUNTIME_CALLABLE]), so there's
	## nothing to resolve ahead of time.
	RUNTIME_ONLY_TARGETS,
	## The target collection depends on Godot scene-group membership
	## ([constant AnimaTargetCollection.Kind.SCENE_GROUP]), which can change
	## at any time and has no guaranteed stable order.
	LIVE_MEMBERSHIP,
	## One of the collection's explicit references didn't resolve to a node.
	UNRESOLVED_REFERENCE,
	## The group's order is [constant AnimaGroupOrder.Kind.RANDOM]. A seed
	## makes it repeatable at runtime, but a compiled Animation is one fixed
	## timeline, so a shuffled order is treated as non-deterministic.
	NON_DETERMINISTIC_ORDER,
	## The item motion isn't a single [AnimaPropertyMotion]. Compiling a
	## composite item motion (Sequence, Parallel, Stagger, and similar) into
	## native tracks isn't supported yet.
	ITEM_MOTION_NOT_A_PROPERTY_MOTION,
	## The item motion depends on author-supplied code — a [constant
	## AnimaEase.Kind.CALLABLE] ease — which can't be baked into fixed
	## keyframes.
	CALLBACK_DEPENDENT,
	## The item motion doesn't have a fixed, known-ahead-of-time duration —
	## for example, a [constant AnimaEase.Kind.SPRING] ease, which settles on
	## its own schedule instead of a fixed duration.
	ITEM_MOTION_NOT_FIXED_DURATION,
	## The item motion's [member AnimaPropertyMotion.from_value] or [member
	## AnimaPropertyMotion.to_value] is an [AnimaValue], resolved per-item at
	## runtime — the same "runtime-only source blocks static compilation"
	## rule [constant RUNTIME_ONLY_TARGETS]/[constant LIVE_MEMBERSHIP] already
	## enforce, applied to this new source of runtime-only-ness.
	DYNAMIC_VALUE,
}

## How many samples each item's eased curve is baked into. Every [AnimaEase]
## kind evaluates the same way here, so this works regardless of which curve
## shape the item motion uses.
const SAMPLES_PER_ITEM := 20

## The result of checking a group's eligibility — see [method check_eligibility].
class Eligibility:
	## Why the group isn't eligible, or [constant Blocker.NONE] if it is.
	var blocker: Blocker = Blocker.NONE
	## A plain-language explanation of [member blocker]. Empty when eligible.
	var message: String = ""

	## Whether [method AnimaGroupCompiler.compile] can be called for this result.
	func is_eligible() -> bool:
		return blocker == Blocker.NONE

## Checks whether [param group] can compile into a native [Animation] against
## [param root], without compiling it. Nothing here is cached, so calling
## this again after changing [param group]'s configuration always reflects
## its current eligibility.
static func check_eligibility(group: AnimaGroupMotion, root: Node) -> Eligibility:
	var result := Eligibility.new()

	if group.target_collection.kind == AnimaTargetCollection.Kind.RUNTIME_CALLABLE:
		result.blocker = Blocker.RUNTIME_ONLY_TARGETS
		result.message = "This group's targets are supplied by code at play time, so there's nothing to resolve ahead of time."
		return result

	if group.target_collection.kind == AnimaTargetCollection.Kind.SCENE_GROUP:
		result.blocker = Blocker.LIVE_MEMBERSHIP
		result.message = "This group's targets come from a scene group, whose membership can change at any time."
		return result

	if group.order.kind == AnimaGroupOrder.Kind.RANDOM:
		result.blocker = Blocker.NON_DETERMINISTIC_ORDER
		result.message = "This group's order is Random. A seed makes it repeatable at runtime, but a compiled Animation is one fixed timeline, so a shuffled order can't be baked into it."
		return result

	if not (group.item_motion is AnimaPropertyMotion):
		result.blocker = Blocker.ITEM_MOTION_NOT_A_PROPERTY_MOTION
		result.message = "This group's item motion isn't a single property motion — compiling a composite item motion isn't supported yet."
		return result

	var item := group.item_motion as AnimaPropertyMotion
	if item.from_value is AnimaValue or item.to_value is AnimaValue:
		result.blocker = Blocker.DYNAMIC_VALUE
		result.message = "This group's item motion uses a dynamic value, resolved per item at runtime — there's nothing fixed to bake into a native curve."
		return result

	if item.ease.kind == AnimaEase.Kind.CALLABLE:
		result.blocker = Blocker.CALLBACK_DEPENDENT
		result.message = "This group's item motion uses a Callable ease, which can't be baked into fixed keyframes."
		return result

	if item.estimate_duration().kind != AnimaDuration.Kind.FIXED:
		result.blocker = Blocker.ITEM_MOTION_NOT_FIXED_DURATION
		result.message = "This group's item motion doesn't have a fixed, known-ahead-of-time duration — for example, a spring settles on its own schedule instead."
		return result

	var resolution := AnimaTargetResolver.resolve(
		group.target_collection,
		root,
		[],
		group.invalid_target_policy,
		group.empty_group_policy,
	)
	if not resolution.messages.is_empty():
		result.blocker = Blocker.UNRESOLVED_REFERENCE
		result.message = resolution.messages[0]
		return result

	return result

## Compiles [param group] into a native [Animation] against [param root],
## whose visible item starts and durations match its authored playback,
## ordering, and distribution. Only call this once [method check_eligibility]
## reports [constant Blocker.NONE] for the same [param group] and [param
## root] — behaviour is undefined otherwise.
static func compile(group: AnimaGroupMotion, root: Node) -> Animation:
	var resolution := AnimaTargetResolver.resolve(
		group.target_collection,
		root,
		[],
		group.invalid_target_policy,
		group.empty_group_policy,
	)
	var schedule := AnimaGroupScheduler.derive(group, resolution.targets)
	var item := group.item_motion as AnimaPropertyMotion

	var animation := Animation.new()
	var longest_end := 0.0

	for index in schedule.entries.size():
		var entry := schedule.entries[index]
		var start_offset := _resolve_start_offset(group, entry, index)
		_add_item_track(animation, root, entry.target, item, start_offset)
		longest_end = maxf(longest_end, start_offset + item.duration)

	animation.length = longest_end
	return animation

## [method AnimaGroupScheduler.derive] leaves every SEQUENTIAL entry's offset
## at `0.0`, since real sequential timing is driven by each item's actual
## completion at runtime (see [AnimaGroupPlayback]). A compiled group has no
## runtime to wait on, so — now that eligibility already guarantees a single
## fixed-duration item motion shared by every target — sequential starts are
## computed directly here instead.
static func _resolve_start_offset(group: AnimaGroupMotion, entry: AnimaGroupScheduler.ScheduleEntry, index: int) -> float:
	if group.playback_mode != AnimaGroupMotion.PlaybackMode.SEQUENTIAL:
		return entry.start_offset
	var item := group.item_motion as AnimaPropertyMotion
	return float(index) * (item.duration + group.sequential_gap)

static func _add_item_track(animation: Animation, root: Node, target: Node, item: AnimaPropertyMotion, start_offset: float) -> void:
	var track_index := animation.add_track(Animation.TYPE_VALUE)
	var relative_path := root.get_path_to(target)
	var property_path := NodePath("%s:%s" % [relative_path, item.target_property.get_concatenated_subnames()])
	animation.track_set_path(track_index, property_path)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_CONTINUOUS)

	var from_value: Variant = item.from_value
	if from_value == null:
		from_value = target.get_indexed(item.target_property)

	for sample in range(SAMPLES_PER_ITEM + 1):
		var t := float(sample) / float(SAMPLES_PER_ITEM)
		var eased_t := item.ease.evaluate(t)
		var time := start_offset + t * item.duration
		animation.track_insert_key(track_index, time, lerp(from_value, item.to_value, eased_t))
