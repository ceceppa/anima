## Typed easing/curve resource shared by every leaf motion. `evaluate(t)` is
## the contract every non-stateful [member kind] implements; [constant Kind.SPRING]
## is the one exception (see anima_property_motion.gd).
class_name AnimaEase
extends Resource

## Curve shapes `evaluate(t: float) -> float` can produce. [constant Kind.SPRING]
## is stateful and does not implement `evaluate(t)`.
enum Kind {
	LINEAR,
	POLYNOMIAL,
	SINE,
	EXPONENTIAL,
	CIRCULAR,
	BACK,
	BOUNCE,
	ELASTIC,
	CUBIC_BEZIER,
	CURVE,
	CALLABLE,
	DECAY,
	CUSTOM_SAMPLED,
	SPRING,
}

## Which parameter set a [constant Kind.SPRING] reads. [constant SIMPLE]
## (response/bounce) is the default, user-friendly surface; [constant ADVANCED]
## exposes the underlying physics directly.
enum SpringModel {
	SIMPLE,
	ADVANCED,
}

## When a [constant Kind.SPRING]-eased motion reports itself finished.
enum SpringCompletionMode {
	STRICTLY_SETTLED,
	VISUALLY_SETTLED,
	FIXED_PREVIEW_DURATION,
	MANUAL,
}

## Internal tuning constant for [constant Kind.DECAY]'s asymptotic curve shape.
const DECAY_SCALE := 2000.0

## Which curve shape [method evaluate] produces.
@export var kind: Kind = Kind.LINEAR
## Exponent used only when [member kind] is [constant Kind.POLYNOMIAL].
@export var exponent: float = 2.0
## Overshoot amount used only when [member kind] is [constant Kind.BACK].
@export var back_overshoot: float = 1.70158
## Oscillation amplitude used only when [member kind] is [constant Kind.ELASTIC].
@export var elastic_amplitude: float = 1.0
## Oscillation period used only when [member kind] is [constant Kind.ELASTIC].
@export var elastic_period: float = 0.3
## First control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
@export var bezier_p1: Vector2 = Vector2(0.42, 0.0)
## Second control point used only when [member kind] is [constant Kind.CUBIC_BEZIER].
@export var bezier_p2: Vector2 = Vector2(0.58, 1.0)
## Sampled curve used only when [member kind] is [constant Kind.CURVE].
@export var curve: Curve
## Custom evaluator `(t: float) -> float`, used only when [member kind] is
## [constant Kind.CALLABLE].
@export var evaluator: Callable
## Decay rate used only when [member kind] is [constant Kind.DECAY].
@export var decay_rate: float = 0.998
## Evenly-spaced sample values used only when [member kind] is
## [constant Kind.CUSTOM_SAMPLED].
@export var custom_samples: PackedFloat32Array = PackedFloat32Array()

## Which parameter set [constant Kind.SPRING] reads — [constant SpringModel.SIMPLE]
## (response/bounce) by default.
@export var spring_model: SpringModel = SpringModel.SIMPLE
## Roughly how long the spring takes to feel settled. [constant SpringModel.SIMPLE] only.
@export var spring_response: float = 0.5
## Overshoot amount, `-1..1`. `0.0` is critically damped (no overshoot);
## positive values overshoot and oscillate. [constant SpringModel.SIMPLE] only.
@export var spring_bounce: float = 0.0
## Mass of the simulated body. Used by both spring models.
@export var spring_mass: float = 1.0
## Spring stiffness (higher = snappier). [constant SpringModel.ADVANCED] only.
@export var spring_stiffness: float = 100.0
## Spring damping (higher = settles faster, less oscillation). [constant SpringModel.ADVANCED] only.
@export var spring_damping: float = 10.0
## Velocity the spring starts with.
@export var spring_initial_velocity: float = 0.0
## When the spring-eased motion reports itself finished.
@export var spring_completion_mode: SpringCompletionMode = SpringCompletionMode.STRICTLY_SETTLED
## Below this velocity, the spring is considered settled (`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).
@export var spring_settle_velocity: float = 0.01
## Below this distance from the target, the spring is considered settled
## (`STRICTLY_SETTLED`/`VISUALLY_SETTLED`).
@export var spring_settle_distance: float = 0.001
## Fixed time to report finished after, used only when [member spring_completion_mode]
## is [constant SpringCompletionMode.FIXED_PREVIEW_DURATION].
@export var spring_preview_duration: float = 1.0

## Derives (stiffness, damping) from whichever [member spring_model] is active,
## for the runtime instance that simulates a SPRING-eased motion frame by frame.
func spring_stiffness_and_damping() -> Vector2:
	if spring_model == SpringModel.ADVANCED:
		return Vector2(spring_stiffness, spring_damping)

	var angular_frequency: float = TAU / maxf(spring_response, 0.001)
	var damping_ratio: float = 1.0 - spring_bounce
	var stiffness: float = angular_frequency * angular_frequency * spring_mass
	var damping: float = 2.0 * damping_ratio * angular_frequency * spring_mass
	return Vector2(stiffness, damping)

## A rough settle-time estimate for a SPRING ease, derived from its parameters —
## used by AnimaPropertyMotion.estimate_duration() to report AnimaDuration.ESTIMATED.
func spring_estimated_seconds() -> float:
	if spring_completion_mode == SpringCompletionMode.FIXED_PREVIEW_DURATION:
		return spring_preview_duration

	var stiffness_damping := spring_stiffness_and_damping()
	var stiffness: float = stiffness_damping.x
	var damping: float = stiffness_damping.y
	var mass: float = maxf(spring_mass, 0.001)
	var angular_frequency: float = sqrt(stiffness / mass)
	var damping_ratio: float = damping / (2.0 * sqrt(stiffness * mass))

	if angular_frequency <= 0.0 or damping_ratio <= 0.0:
		return 1.0
	# ln(100) ≈ 4.6 time constants to decay a settling envelope to ~1%.
	return 4.6 / (damping_ratio * angular_frequency)

## Returns the eased value for normalized time [param t] (`0.0`-`1.0`).
## Not implemented for [constant Kind.SPRING] — that kind is stateful and is
## advanced frame-by-frame instead (see anima_property_motion.gd).
func evaluate(t: float) -> float:
	t = clampf(t, 0.0, 1.0)

	match kind:
		Kind.LINEAR:
			return t
		Kind.POLYNOMIAL:
			return pow(t, exponent)
		Kind.SINE:
			return 1.0 - cos(t * PI / 2.0)
		Kind.EXPONENTIAL:
			return 0.0 if t == 0.0 else pow(2.0, 10.0 * (t - 1.0))
		Kind.CIRCULAR:
			return 1.0 - sqrt(1.0 - t * t)
		Kind.BACK:
			return t * t * ((back_overshoot + 1.0) * t - back_overshoot)
		Kind.BOUNCE:
			return _evaluate_bounce(t)
		Kind.ELASTIC:
			return _evaluate_elastic(t)
		Kind.CUBIC_BEZIER:
			var inv := 1.0 - t
			return 3.0 * inv * inv * t * bezier_p1.y + 3.0 * inv * t * t * bezier_p2.y + t * t * t
		Kind.CURVE:
			return curve.sample(t) if curve != null else t
		Kind.CALLABLE:
			return evaluator.call(t) if evaluator.is_valid() else t
		Kind.DECAY:
			var k: float = -log(decay_rate) * DECAY_SCALE
			return 1.0 - exp(-k * t)
		Kind.CUSTOM_SAMPLED:
			return _evaluate_custom_sampled(t)
		_:
			return t

func _evaluate_bounce(t: float) -> float:
	if t < 1.0 / 2.75:
		return 7.5625 * t * t
	elif t < 2.0 / 2.75:
		var t2 := t - 1.5 / 2.75
		return 7.5625 * t2 * t2 + 0.75
	elif t < 2.5 / 2.75:
		var t2 := t - 2.25 / 2.75
		return 7.5625 * t2 * t2 + 0.9375
	else:
		var t2 := t - 2.625 / 2.75
		return 7.5625 * t2 * t2 + 0.984375

func _evaluate_elastic(t: float) -> float:
	if t == 0.0:
		return 0.0
	if t == 1.0:
		return 1.0

	var amplitude := elastic_amplitude
	var s: float
	if amplitude < 1.0:
		amplitude = 1.0
		s = elastic_period / 4.0
	else:
		s = elastic_period / (2.0 * PI) * asin(1.0 / amplitude)

	return amplitude * pow(2.0, -10.0 * t) * sin((t - s) * (2.0 * PI) / elastic_period) + 1.0

func _evaluate_custom_sampled(t: float) -> float:
	if custom_samples.is_empty():
		return t
	if custom_samples.size() == 1:
		return custom_samples[0]

	var scaled: float = t * (custom_samples.size() - 1)
	var index: int = clampi(int(floor(scaled)), 0, custom_samples.size() - 2)
	var local_t: float = scaled - index
	return lerpf(custom_samples[index], custom_samples[index + 1], local_t)
