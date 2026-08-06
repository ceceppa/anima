## Returned by [method Anima.grid] — builds and plays an [AnimaGridMotion]
## against [member container] with one line, mirroring [method Anima.on]'s
## ergonomics for the one motion kind it doesn't cover. Only ever builds an
## [AnimaGridMotion], so — unlike [AnimaOnMotionFactory], which needs a
## factory because one target maps to many possible property-motion kinds —
## this factory exists purely to keep [member container] in scope across the
## chain (`tech-spec.md` §Grid convenience shorthand).
class_name AnimaGridMotionFactory
extends RefCounted

## The node whose children this grid motion targets.
var container: Node
## The grid motion this factory builds. Every field keeps [AnimaGridMotion]'s
## own constructor default except [member AnimaGroupMotion.target_collection],
## set to [constant AnimaTargetCollection.Kind.CHILDREN] against [member container].
var motion: AnimaGridMotion

func _init(p_container: Node) -> void:
	container = p_container
	motion = AnimaGridMotion.new()
	motion.target_collection = AnimaTargetCollection.new()
	motion.target_collection.kind = AnimaTargetCollection.Kind.CHILDREN

## Sets [member AnimaGroupMotion.item_motion]. Required before [method play] —
## a grid motion with no item motion has nothing to animate. Returns self so
## calls can keep chaining.
func with_item_motion(value: AnimaMotion) -> AnimaGridMotionFactory:
	motion.item_motion = value
	return self

## Sets [member AnimaGridMotion.grid_dimensions]. Returns self so calls can
## keep chaining.
func with_dimensions(value: Vector2i) -> AnimaGridMotionFactory:
	motion.grid_dimensions = value
	return self

## Sets [member AnimaGridMotion.distance_formula]. Returns self so calls can
## keep chaining.
func with_distance_formula(value: AnimaGridMotion.DistanceFormula) -> AnimaGridMotionFactory:
	motion.distance_formula = value
	return self

## Sets [member AnimaGridMotion.start_point]. Returns self so calls can keep
## chaining.
func with_start_point(value: Vector2i) -> AnimaGridMotionFactory:
	motion.start_point = value
	return self

## Sets [member AnimaGroupDistribution.stagger_interval]. Returns self so
## calls can keep chaining.
func with_stagger_interval(value: float) -> AnimaGridMotionFactory:
	motion.distribution.stagger_interval = value
	return self

## Builds an [AnimaKeyframeMotion] from [param initial] (the same shape
## [method Motion.keyframes] parses) and [param duration], then sets it as
## [member AnimaGroupMotion.item_motion] — the same name [method
## AnimaOnMotionFactory.keyframes] uses, but returns this factory (not the
## built motion), so [method play] stays reachable at the end of the chain
## the same way every other method here does (`tech-spec.md` §Grid
## convenience shorthand).
func keyframes(initial: Dictionary = {}, duration: float = 0.0) -> AnimaGridMotionFactory:
	var keyframe_motion := Motion.keyframes(initial)
	keyframe_motion.duration = duration
	motion.item_motion = keyframe_motion
	return self

## Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
## duration — [member AnimaPropertyMotion.duration] or [member
## AnimaKeyframeMotion.duration], whichever applies. Reports an error and
## leaves the factory otherwise unchanged when no item motion is set yet, or
## when it's a kind with no duration of its own (a composite like
## [AnimaSequence]). Returns self so calls can keep chaining — e.g. directly
## after [method keyframes] (`tech-spec.md` §Grid convenience shorthand).
func with_duration(value: float) -> AnimaGridMotionFactory:
	if motion.item_motion == null:
		push_error("AnimaGridMotionFactory.with_duration() requires an item motion — call with_item_motion() or keyframes() first.")
		return self
	if motion.item_motion is AnimaPropertyMotion:
		(motion.item_motion as AnimaPropertyMotion).duration = value
	elif motion.item_motion is AnimaKeyframeMotion:
		(motion.item_motion as AnimaKeyframeMotion).duration = value
	else:
		push_error("AnimaGridMotionFactory.with_duration() only applies to a property or keyframe item motion.")
	return self

## Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
## easing — [member AnimaPropertyMotion.ease] or [member
## AnimaKeyframeMotion.default_ease], whichever applies. [param value] is a
## full [AnimaEase] or a bare [enum AnimaEase.Kind], coerced via [method
## AnimaEase.from] (`tech-spec.md` §Easing curve library). Same missing- or
## incompatible-item-motion error behaviour as [method with_duration].
func with_ease(value: Variant) -> AnimaGridMotionFactory:
	if motion.item_motion == null:
		push_error("AnimaGridMotionFactory.with_ease() requires an item motion — call with_item_motion() or keyframes() first.")
		return self
	var ease := AnimaEase.from(value)
	if motion.item_motion is AnimaPropertyMotion:
		(motion.item_motion as AnimaPropertyMotion).ease = ease
	elif motion.item_motion is AnimaKeyframeMotion:
		(motion.item_motion as AnimaKeyframeMotion).default_ease = ease
	else:
		push_error("AnimaGridMotionFactory.with_ease() only applies to a property or keyframe item motion.")
	return self

## Sets the currently-configured [member AnimaGroupMotion.item_motion]'s
## pivot — [member AnimaPropertyMotion.pivot] or [member
## AnimaKeyframeMotion.default_pivot], whichever applies. Same missing- or
## incompatible-item-motion error behaviour as [method with_duration].
func with_pivot(value: AnimaPropertyMotion.Pivot) -> AnimaGridMotionFactory:
	if motion.item_motion == null:
		push_error("AnimaGridMotionFactory.with_pivot() requires an item motion — call with_item_motion() or keyframes() first.")
		return self
	if motion.item_motion is AnimaPropertyMotion:
		(motion.item_motion as AnimaPropertyMotion).pivot = value
	elif motion.item_motion is AnimaKeyframeMotion:
		(motion.item_motion as AnimaKeyframeMotion).default_pivot = value
	else:
		push_error("AnimaGridMotionFactory.with_pivot() only applies to a property or keyframe item motion.")
	return self

## Plays [member motion] against [member container] — [code]Anima.play(motion, container)[/code].
## Reports an error and returns `null` when [method with_item_motion] was
## never called, instead of playing an empty grid.
func play() -> AnimaPlayback:
	if motion.item_motion == null:
		push_error("AnimaGridMotionFactory.play() requires with_item_motion() to be called first.")
		return null
	return Anima.play(motion, container)
