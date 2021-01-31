#
# Easing functions and code has been inspired from:
# https://easings.net/
#
class_name AnimaEasing

enum EASING {
	LINEAR,   
	EASE,
	EASE_IN_OUT,
	EASE_IN,
	EASE_OUT,
	EASE_IN_SINE,
	EASE_OUT_SINE,
	EASE_IN_OUT_SINE,
	EASE_IN_QUAD,
	EASE_OUT_QUAD,
	EASE_IN_OUT_QUAD,
	EASE_IN_CUBIC,
	EASE_OUT_CUBIC,
	EASE_IN_OUT_CUBIC,
	EASE_IN_QUART,
	EASE_OUT_QUART,
	EASE_IN_OUT_QUART,
	EASE_IN_QUINT,
	EASE_OUT_QUINT,
	EASE_IN_OUT_QUINT,
	EASE_IN_EXPO,
	EASE_OUT_EXPO,
	EASE_IN_OUT_EXPO,
	EASE_IN_CIRC,
	EASE_OUT_CIRC,
	EASE_IN_OUT_CIRC,
	EASE_IN_BACK,
	EASE_OUT_BACK,
	EASE_IN_OUT_BACK,
	EASE_IN_ELASTIC,
	EASE_OUT_ELASTIC,
	EASE_IN_OUT_ELASTIC,
	EASE_IN_BOUNCE,
	EASE_OUT_BOUNCE,
	EASE_IN_OUT_BOUNCE,
}

const _easing_mapping = {
	EASING.LINEAR: null,
	EASING.EASE: [0.25, 0.1, 0.25, 1],
	EASING.EASE_IN_OUT: [0.42, 0, 0.58, 1],
	EASING.EASE_IN: [0.42, 0, 1, 1],
	EASING.EASE_OUT: [0, 0, 0.58, 1],
	EASING.EASE_IN_SINE: [0, 0, 1, .5],
	EASING.EASE_OUT_SINE: [0.61, 1, 0.88, 1],
	EASING.EASE_IN_OUT_SINE: [0.37, 0, 0.63, 1],
	EASING.EASE_IN_QUAD: [0.11, 0, 0.5, 0],
	EASING.EASE_OUT_QUAD: [0.5, 1.0, 0.89, 1],
	EASING.EASE_IN_OUT_QUAD: [0.45, 0, 0.55, 1],
	EASING.EASE_IN_CUBIC: [0.32, 0, 0.67, 0],
	EASING.EASE_OUT_CUBIC: [0.33, 1, 0.68, 1],
	EASING.EASE_IN_OUT_CUBIC: [0.65, 0, 0.35, 1],
	EASING.EASE_IN_QUART: [0.5, 0, 0.75, 0],
	EASING.EASE_OUT_QUART: [0.25, 1, 0.5, 1],
	EASING.EASE_IN_OUT_QUART: [0.76, 0, 0.24, 1],
	EASING.EASE_IN_QUINT: [0.64, 0, 0.78, 0],
	EASING.EASE_OUT_QUINT: [0.22, 1, 0.36, 1],
	EASING.EASE_IN_OUT_QUINT: [0.83, 0, 0.17, 1],
	EASING.EASE_IN_EXPO: [0.7, 0, 0.84, 0],
	EASING.EASE_OUT_EXPO: [0.16, 1, 0.3, 1],
	EASING.EASE_IN_OUT_EXPO: [0.87, 0, 0.13, 1],
	EASING.EASE_IN_CIRC: [0.55, 0, 0.1, 0.45],
	EASING.EASE_OUT_CIRC: [0, 0.55, 0.45, 1],
	EASING.EASE_IN_OUT_CIRC: [0.85, 0, 0.15, 1],
	EASING.EASE_IN_BACK: [0.36, 0, 0.66, -0.56],
	EASING.EASE_OUT_BACK: [0.36, 1.56, 0.64, 1],
	EASING.EASE_IN_OUT_BACK: [0.68, -0.6, 0.32, 1.6],
	EASING.EASE_IN_ELASTIC: 'ease_in_elastic',
	EASING.EASE_OUT_ELASTIC: 'ease_out_elastic',
	EASING.EASE_IN_OUT_ELASTIC: 'ease_in_out_elastic',
	EASING.EASE_IN_BOUNCE: 'ease_in_bounce',
	EASING.EASE_OUT_BOUNCE: 'ease_out_bounce',
	EASING.EASE_IN_OUT_BOUNCE: 'ease_in_out_bounce'
}

const _ELASTIC_C4: float = (2.0 * PI) / 3.0
const _ELASTIC_C5: float = (2.0 * PI) / 4.5

static func get_easing_points(easing_name):
	if _easing_mapping.has(easing_name):
		return _easing_mapping[easing_name]

	printerr('Easing not found: ' + str(easing_name))

	return _easing_mapping[EASING.LINEAR]

static func ease_in_elastic(elapsed: float) -> float:
	if elapsed == 0:
		return 0.0
	elif elapsed == 1:
		return 1.0

	return -pow(2, 10 * elapsed - 10) * sin((elapsed * 10 - 10.75) * _ELASTIC_C4)

static func ease_out_elastic(elapsed: float) -> float:
	if elapsed == 0:
		return 0.0
	elif elapsed == 1:
		return 1.0

	return pow(2, -10 * elapsed) * sin((elapsed * 10 - 0.75) * _ELASTIC_C4) + 1

static func ease_in_out_elastic(elapsed: float) -> float:
	if elapsed == 0:
		return 0.0
	elif elapsed == 1:
		return 1.0
	elif elapsed < 0.5:
		return -(pow(2, 20 * elapsed - 10) * sin((20 * elapsed - 11.125) * _ELASTIC_C5)) / 2

	return (pow(2, -20 * elapsed + 10) * sin((20 * elapsed - 11.125) * _ELASTIC_C5)) / 2 + 1

const n1 = 7.5625;
const d1 = 2.75;

static func ease_in_bounce(elapsed: float) -> float:
	return 1 - ease_out_bounce(1.0 - elapsed)

static func ease_out_bounce(elapsed: float) -> float:
	if elapsed < 1 / d1:
		return n1 * elapsed * elapsed;
	elif elapsed < 2 / d1:
		elapsed -= 1.5 / d1

		return n1 * elapsed * elapsed + 0.75;
	elif elapsed < 2.5 / d1:
		elapsed -= 2.25 / d1

		return n1 * elapsed * elapsed + 0.9375;

	elapsed -= 2.625 / d1
	return n1 * elapsed * elapsed + 0.984375;

static func ease_in_out_bounce(elapsed: float) -> float:
	if elapsed < 0.5:
		return (1 - ease_out_bounce(1 - 2 * elapsed)) / 2

	return (1 + ease_out_bounce(2 * elapsed - 1)) / 2
