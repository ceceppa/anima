class_name AnimaEase
extends Resource

enum Kind {
	LINEAR,
	POLYNOMIAL,
	SINE,
	EXPONENTIAL,
	CIRCULAR,
}

@export var kind: Kind = Kind.LINEAR
@export var exponent: float = 2.0

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
		_:
			return t
