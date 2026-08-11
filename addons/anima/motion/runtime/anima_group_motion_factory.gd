## Returned by [method Anima.group] — builds and plays an [AnimaGroupMotion]
## against a chosen target set with one line, mirroring [method Anima.grid]'s
## ergonomics for the general (non-grid) group case. Only ever builds an
## [AnimaGroupMotion], so — like [AnimaGridMotionFactory] — this factory
## exists purely to keep the resolved target collection in scope across the
## chain (`tech-spec.md` §Group convenience shorthand).
class_name AnimaGroupMotionFactory
extends RefCounted

## The container whose children this group targets, when [method Anima.group]
## was given a [Node]. `null` when given an explicit target array instead —
## [constant AnimaTargetCollection.Kind.EXPLICIT] resolves its own [member
## AnimaTargetCollection.reference_data] directly and needs no root
## (`tech-spec.md` §Group convenience shorthand).
var container: Node = null
## The group motion this factory builds. [member AnimaGroupMotion.item_motion]
## stays unset until [method with_item_motion]/[method keyframes] is called —
## required before [method play].
var motion: AnimaGroupMotion

## [param targets] is a [Node] (its children become the group's targets,
## [constant AnimaTargetCollection.Kind.CHILDREN], mirroring [method
## Anima.grid]) or an [Array] of [Node]s (used directly, [constant
## AnimaTargetCollection.Kind.EXPLICIT]) — resolved in [method
## _resolve_targets] (`tech-spec.md` §Group convenience shorthand).
func _init(targets: Variant) -> void:
	motion = AnimaGroupMotion.new()
	motion.target_collection = AnimaTargetCollection.new()
	_resolve_targets(targets)
	motion.convenience_target = container

## Resolves [param targets] into [member motion]'s [AnimaTargetCollection]
## and [member container]. A [Node] resolves to [constant
## AnimaTargetCollection.Kind.CHILDREN] against that node. An [Array]
## resolves to [constant AnimaTargetCollection.Kind.EXPLICIT] with [member
## container] left `null` — [constant AnimaTargetCollection.Kind.EXPLICIT]
## resolves its own [member AnimaTargetCollection.reference_data] directly
## and needs no root. Any entry in the array that isn't a [Node] is reported
## and skipped rather than failing the whole call.
func _resolve_targets(targets: Variant) -> void:
	if targets is Node:
		container = targets
		motion.target_collection.kind = AnimaTargetCollection.Kind.CHILDREN
		return
	if targets is Array:
		motion.target_collection.kind = AnimaTargetCollection.Kind.EXPLICIT
		var resolved: Array = []
		for entry in targets:
			if entry is Node:
				resolved.append(entry)
			else:
				push_error("AnimaGroupMotionFactory: array entry must be a Node — got %s. Skipping it." % type_string(typeof(entry)))
		motion.target_collection.reference_data = resolved
		return
	push_error("AnimaGroupMotionFactory: targets must be a Node or an Array of Node — got %s." % type_string(typeof(targets)))

## Sets [member AnimaGroupMotion.item_motion]. Required before [method play] —
## a group motion with no item motion has nothing to animate. Returns self so
## calls can keep chaining.
func with_item_motion(value: AnimaMotion) -> AnimaGroupMotionFactory:
	motion.item_motion = value
	return self

## Builds an [AnimaKeyframeMotion] from [param initial] (the same shape
## [method Motion.keyframes] parses) and [param duration], then sets it as
## [member AnimaGroupMotion.item_motion] — the same name [method
## AnimaGridMotionFactory.keyframes] uses, but returns this factory (not the
## built motion), so [method play] stays reachable at the end of the chain
## (`tech-spec.md` §Group convenience shorthand).
func keyframes(initial: Dictionary = {}, duration: float = 0.0) -> AnimaGroupMotionFactory:
	var keyframe_motion := Motion.keyframes(initial)
	keyframe_motion.duration = duration
	motion.item_motion = keyframe_motion
	return self

## Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
## duration — [member AnimaPropertyMotion.duration] or [member
## AnimaKeyframeMotion.duration], whichever applies. Reports an error and
## leaves the factory otherwise unchanged when no item motion is set yet, or
## when it's a kind with no duration of its own. Returns self so calls can
## keep chaining — e.g. directly after [method keyframes].
func with_duration(value: float) -> AnimaGroupMotionFactory:
	if motion.item_motion == null:
		push_error("AnimaGroupMotionFactory.with_duration() requires an item motion — call with_item_motion() or keyframes() first.")
		return self
	if motion.item_motion is AnimaPropertyMotion:
		(motion.item_motion as AnimaPropertyMotion).duration = value
	elif motion.item_motion is AnimaKeyframeMotion:
		(motion.item_motion as AnimaKeyframeMotion).duration = value
	else:
		push_error("AnimaGroupMotionFactory.with_duration() only applies to a property or keyframe item motion.")
	return self

## Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
## easing — [member AnimaPropertyMotion.ease] or [member
## AnimaKeyframeMotion.default_ease], whichever applies. [param value] is a
## full [AnimaEase] or a bare [enum AnimaEase.Kind], coerced via [method
## AnimaEase.from]. Same missing- or incompatible-item-motion error behaviour
## as [method with_duration].
func with_ease(value: Variant) -> AnimaGroupMotionFactory:
	if motion.item_motion == null:
		push_error("AnimaGroupMotionFactory.with_ease() requires an item motion — call with_item_motion() or keyframes() first.")
		return self
	var ease := AnimaEase.from(value)
	if motion.item_motion is AnimaPropertyMotion:
		(motion.item_motion as AnimaPropertyMotion).ease = ease
	elif motion.item_motion is AnimaKeyframeMotion:
		(motion.item_motion as AnimaKeyframeMotion).default_ease = ease
	else:
		push_error("AnimaGroupMotionFactory.with_ease() only applies to a property or keyframe item motion.")
	return self

## Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
## pivot — [member AnimaPropertyMotion.pivot] or [member
## AnimaKeyframeMotion.default_pivot], whichever applies. Same missing- or
## incompatible-item-motion error behaviour as [method with_duration].
func with_pivot(value: AnimaPivot.Kind) -> AnimaGroupMotionFactory:
	if motion.item_motion == null:
		push_error("AnimaGroupMotionFactory.with_pivot() requires an item motion — call with_item_motion() or keyframes() first.")
		return self
	if motion.item_motion is AnimaPropertyMotion:
		(motion.item_motion as AnimaPropertyMotion).pivot = value
	elif motion.item_motion is AnimaKeyframeMotion:
		(motion.item_motion as AnimaKeyframeMotion).default_pivot = value
	else:
		push_error("AnimaGroupMotionFactory.with_pivot() only applies to a property or keyframe item motion.")
	return self

## Sets [member AnimaMotion.delay] on the group motion as a whole — delays
## the group's overall start, independent of its own per-item
## stagger/distribution delay. Returns self so calls can keep chaining.
func with_delay(value: float) -> AnimaGroupMotionFactory:
	motion.delay = value
	return self

## Delegates to [member motion]'s own [method AnimaMotion.wait] — delays the
## start of whatever gets combined next via [method then]/[method with],
## reachable mid-chain the same way [method with_delay] already is. Returns
## this factory (not [member motion]) so [method play] stays reachable at
## the end of the chain.
func wait(seconds: float) -> AnimaGroupMotionFactory:
	motion.wait(seconds)
	return self

## Sets [member AnimaMotion.on_started_callback], invoked once when the group
## motion starts. Returns self so calls can keep chaining.
func on_started(callback: Callable) -> AnimaGroupMotionFactory:
	motion.on_started_callback = callback
	return self

## Sets [member AnimaMotion.on_completed_callback], invoked once immediately
## before a successful finish — never on cancellation. Returns self so calls
## can keep chaining.
func on_completed(callback: Callable) -> AnimaGroupMotionFactory:
	motion.on_completed_callback = callback
	return self

## Builds an [_AnimaSequence] playing [member motion], then [param other] — the
## same resource [method AnimaMotion.then] would build, since [member motion]
## already carries [member AnimaMotion.convenience_target] (set in [method
## _init]). Returns the composite motion itself, not this factory — combining
## the group with something else means nothing further configures this group
## specifically. [param other] accepts the same types [method AnimaMotion.then]
## does — an [AnimaMotion], or another convenience factory exposing `motion`.
func then(other: Variant) -> AnimaMotion:
	return motion.then(other)

## Same as [method then], but folds [param other] into the same
## [_AnimaParallel] group instead of a new sequential step — see [method
## AnimaMotion.with].
func with(other: Variant) -> AnimaMotion:
	return motion.with(other)

## Plays [member motion] against [member container] — [code]Anima.play(motion,
## container)[/code]. Reports an error and returns `null` when [method
## with_item_motion]/[method keyframes] was never called, instead of playing
## an empty group.
func play() -> AnimaPlayback:
	if motion.item_motion == null:
		push_error("AnimaGroupMotionFactory.play() requires with_item_motion() to be called first.")
		return null
	return Anima.play(motion, container)
