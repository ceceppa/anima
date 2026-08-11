## Returned by [method Anima.grid] — builds and plays an [AnimaGridMotion]
## against [member container] with one line, mirroring [method Anima.on]'s
## ergonomics for the one motion kind it doesn't cover. Only ever builds an
## [AnimaGridMotion], so — unlike [AnimaOnMotionFactory], which needs a
## factory because one target maps to many possible property-motion kinds —
## this factory exists purely to keep [member container] in scope across the
## chain (`tech-spec.md` §Grid convenience shorthand).
class_name AnimaGridMotionFactory
extends RefCounted

## Duration a distance-formula preset's own default item motion uses, when it
## supplies one (`tech-spec.md` §Grid convenience shorthand).
const DEFAULT_DURATION := 0.3
## Ease a distance-formula preset's own default item motion uses. Scoped to
## this default only — [member AnimaKeyframeMotion.default_ease]'s own
## general `LINEAR` default is untouched.
const DEFAULT_EASE := AnimaEase.Kind.EASE_IN_OUT
## The item motion a distance-formula preset applies when none has been set
## yet: fades each item in from invisible while its own scale dips 0.25 below
## rest, pulses 0.15 above rest at the midpoint, then settles back to its own
## resting scale (`tech-spec.md` §Grid convenience shorthand). A `static var`,
## not a `const` — its [AnimaValue] entries are built via a static method
## call, not a constant expression GDScript's `const` accepts; the shared
## [AnimaValue] instances stay safe to reuse since arithmetic methods like
## [method AnimaValue.subtract] never mutate their receiver.
static var DEFAULT_ITEM_MOTION := {
	"from": {"opacity": 0.0, "scale": AnimaValue.target(NodePath("scale")).subtract(Vector2(0.25, 0.25))},
	50: {"scale": AnimaValue.target(NodePath("scale")).add(Vector2(0.15, 0.15))},
	"to": {"opacity": 1.0, "scale": AnimaValue.target(NodePath("scale"))},
}

## The node whose children this grid motion targets.
var container: Node
## The grid motion this factory builds. Every field keeps [AnimaGridMotion]'s
## own constructor default — except [member AnimaGroupMotion.target_collection],
## set to [constant AnimaTargetCollection.Kind.CHILDREN] against [member
## container], and [member AnimaGridMotion.distance_formula], set to
## [constant AnimaGridMotion.DistanceFormula.EUCLIDEAN] — a factory-level
## default distinct from [AnimaGridMotion]'s own general-purpose `ROW`
## default, since this shorthand's own common case is radiating outward from
## a point (`tech-spec.md` §Grid convenience shorthand).
var motion: AnimaGridMotion
## Whether [method with_start_point] has been called explicitly — set once
## `true`, [method with_dimensions] never overwrites [member
## AnimaGridMotion.start_point] again, regardless of which call came first.
var _start_point_explicit: bool = false

## [param p_grid_size] accepts a [Vector2i] (used directly), a [Vector2]
## (floored to whole cells), a [Node] (dimensions inferred from that node
## instead of [param p_container]), or `null` (dimensions inferred from
## [param p_container] itself) — resolved through [method _resolve_grid_size]
## and applied via [method with_dimensions], so it carries the same
## auto-derived centred [member AnimaGridMotion.start_point] behaviour
## (`tech-spec.md` §Grid convenience shorthand).
func _init(p_container: Node, p_grid_size: Variant = null) -> void:
	container = p_container
	motion = AnimaGridMotion.new()
	motion.target_collection = AnimaTargetCollection.new()
	motion.target_collection.kind = AnimaTargetCollection.Kind.CHILDREN
	motion.distance_formula = AnimaGridMotion.DistanceFormula.EUCLIDEAN
	motion.convenience_target = container
	with_dimensions(_resolve_grid_size(p_grid_size))

## Resolves [param value] into a concrete [Vector2i] grid size. An
## unrecognised type reports an error and falls back to the same inference
## [method _infer_grid_size] performs for `null`.
func _resolve_grid_size(value: Variant) -> Vector2i:
	if value is Vector2i:
		return value
	if value is Vector2:
		return Vector2i(floori(value.x), floori(value.y))
	if value is Node:
		return _infer_grid_size(value)
	if value == null:
		return _infer_grid_size(container)
	push_error("AnimaGridMotionFactory: grid_size must be a Vector2i, Vector2, Node, or null — got %s. Falling back to inference." % type_string(typeof(value)))
	return _infer_grid_size(container)

## Infers a grid size from [param node]: [param node]'s own `rows`/`columns`
## if both exist, [param node]'s `columns` alone (true for any [GridContainer]
## or lookalike) with rows computed from [member container]'s own child
## count, or — with neither — a single column tall enough to fit every one of
## [member container]'s children. Child count always comes from [member
## container], never from [param node], even when they differ
## (`tech-spec.md` §Grid convenience shorthand).
func _infer_grid_size(node: Node) -> Vector2i:
	if "rows" in node and "columns" in node:
		return Vector2i(node.columns, node.rows)
	if "columns" in node and node.columns > 0:
		var columns: int = node.columns
		return Vector2i(columns, ceili(container.get_child_count() / float(columns)))
	return Vector2i(1, container.get_child_count())

## Sets [member AnimaGroupMotion.item_motion]. Required before [method play] —
## a grid motion with no item motion has nothing to animate. Returns self so
## calls can keep chaining.
func with_item_motion(value: AnimaMotion) -> AnimaGridMotionFactory:
	motion.item_motion = value
	return self

## Sets [member AnimaGridMotion.grid_dimensions]. Also auto-derives a centred
## [member AnimaGridMotion.start_point] — `Vector2i(floori(value.x / 2.0),
## floori(value.y / 2.0))` — unless [method with_start_point] has already been
## called explicitly on this factory (`tech-spec.md` §Grid convenience
## shorthand). Floored, not rounded, so an odd dimension centres on the
## middle index rather than one rounded up past it. Returns self so calls can
## keep chaining.
func with_dimensions(value: Vector2i) -> AnimaGridMotionFactory:
	motion.grid_dimensions = value
	if not _start_point_explicit:
		motion.start_point = Vector2i(floori(value.x / 2.0), floori(value.y / 2.0))
	return self

## Sets [member AnimaGridMotion.distance_formula]. Returns self so calls can
## keep chaining.
func with_distance_formula(value: AnimaGridMotion.DistanceFormula) -> AnimaGridMotionFactory:
	motion.distance_formula = value
	return self

## Applies [member DEFAULT_ITEM_MOTION]/[member DEFAULT_DURATION]/
## [member DEFAULT_EASE] if [member AnimaGridMotion.item_motion] is still
## unset — called by every distance-formula preset, never by [method
## with_distance_formula] itself, so only the named one-liner presets get a
## free default motion (`tech-spec.md` §Grid convenience shorthand).
func _ensure_default_item_motion() -> void:
	if motion.item_motion == null:
		keyframes(DEFAULT_ITEM_MOTION, DEFAULT_DURATION).with_ease(DEFAULT_EASE)

## Named presets for every [enum AnimaGridMotion.DistanceFormula] value — pure
## sugar for [method with_distance_formula], one name per formula with no
## aliases (`tech-spec.md` §Grid convenience shorthand). Preset for
## [constant AnimaGridMotion.DistanceFormula.EUCLIDEAN].
func radial() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.EUCLIDEAN)

## Preset for [constant AnimaGridMotion.DistanceFormula.MANHATTAN].
func diamond() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.MANHATTAN)

## Preset for [constant AnimaGridMotion.DistanceFormula.CHEBYSHEV].
func box() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.CHEBYSHEV)

## Preset for [constant AnimaGridMotion.DistanceFormula.ROW].
func by_row() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.ROW)

## Preset for [constant AnimaGridMotion.DistanceFormula.COLUMN].
func by_column() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.COLUMN)

## Preset for [constant AnimaGridMotion.DistanceFormula.DIAGONAL].
func diagonal() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.DIAGONAL)

## Preset for [constant AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL].
func anti_diagonal() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL)

## Preset for [constant AnimaGridMotion.DistanceFormula.CLOCKWISE].
func clockwise() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.CLOCKWISE)

## Preset for [constant AnimaGridMotion.DistanceFormula.ANTICLOCKWISE].
func counter_clockwise() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.ANTICLOCKWISE)

## Preset for [constant AnimaGridMotion.DistanceFormula.SPIRAL_INWARD].
func spiral_in() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.SPIRAL_INWARD)

## Preset for [constant AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD].
func spiral_out() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD)

## Preset for [constant AnimaGridMotion.DistanceFormula.SERPENTINE_ROW].
func serpentine_row() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.SERPENTINE_ROW)

## Preset for [constant AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN].
func serpentine_column() -> AnimaGridMotionFactory:
	_ensure_default_item_motion()
	return with_distance_formula(AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN)

## Sets [member AnimaGridMotion.start_point] and marks it explicit, so no
## later [method with_dimensions] call auto-derives over it — whether this is
## called before or after [method with_dimensions] in the chain. Returns self
## so calls can keep chaining.
func with_start_point(value: Vector2i) -> AnimaGridMotionFactory:
	motion.start_point = value
	_start_point_explicit = true
	return self

## Sets [member AnimaGroupDistribution.stagger_interval]. Returns self so
## calls can keep chaining.
func with_stagger_interval(value: float) -> AnimaGridMotionFactory:
	motion.distribution.stagger_interval = value
	return self

## Sets [member AnimaMotion.delay] on the grid motion as a whole — delays the
## grid's overall start, independent of its own per-item stagger/distribution
## delay. Returns self so calls can keep chaining.
func with_delay(value: float) -> AnimaGridMotionFactory:
	motion.delay = value
	return self

## Sets [member AnimaMotion.on_started_callback], invoked once when the grid
## motion starts. Returns self so calls can keep chaining.
func on_started(callback: Callable) -> AnimaGridMotionFactory:
	motion.on_started_callback = callback
	return self

## Sets [member AnimaMotion.on_completed_callback], invoked once immediately
## before a successful finish — never on cancellation. Returns self so calls
## can keep chaining.
func on_completed(callback: Callable) -> AnimaGridMotionFactory:
	motion.on_completed_callback = callback
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
func with_pivot(value: AnimaPivot.Kind) -> AnimaGridMotionFactory:
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

## Builds an [AnimaSequence] playing [member motion], then [param other] — the
## same resource [method AnimaMotion.then] would build, since [member motion]
## already carries [member AnimaMotion.convenience_target] (set in [method _init]).
## Returns the composite motion itself, not this factory: combining the grid
## with something else means nothing further configures this grid specifically
## (`tech-spec.md` §Grid convenience shorthand, "`.then()`/`.with()` (phase-15)").
## [param other] accepts the same types [method AnimaMotion.then] does —
## an [AnimaMotion], or another convenience factory exposing `motion`.
func then(other: Variant) -> AnimaMotion:
	return motion.then(other)

## Same as [method then], but folds [param other] into the same [AnimaParallel]
## group instead of a new sequential step — see [method AnimaMotion.with].
func with(other: Variant) -> AnimaMotion:
	return motion.with(other)

## Plays [member motion] against [member container] — [code]Anima.play(motion, container)[/code].
## Reports an error and returns `null` when [method with_item_motion] was
## never called, instead of playing an empty grid.
func play() -> AnimaPlayback:
	if motion.item_motion == null:
		push_error("AnimaGridMotionFactory.play() requires with_item_motion() to be called first.")
		return null
	return Anima.play(motion, container)
