---
title: "Built-in Easings"
description: "Every named easing curve the addon ships"
---

Anima ships every standard named easing curve — the same names CSS and most
game engines use — so you can reach for one by name instead of tuning curve
parameters by hand.

```gdscript
Anima.on($Card).opacity(1.0).with_ease(AnimaEase.Kind.EASE_OUT_BACK)
```

`with_ease()` accepts a bare `AnimaEase.Kind` value directly — no need to
construct an `AnimaEase` resource for the common case of picking a named
curve.

## Named curves

- `EASE`, `EASE_IN`, `EASE_OUT`, `EASE_IN_OUT`
- Sine: `EASE_IN_SINE`, `EASE_OUT_SINE`, `EASE_IN_OUT_SINE`
- Quad: `EASE_IN_QUAD`, `EASE_OUT_QUAD`, `EASE_IN_OUT_QUAD`
- Cubic: `EASE_IN_CUBIC`, `EASE_OUT_CUBIC`, `EASE_IN_OUT_CUBIC`
- Quart: `EASE_IN_QUART`, `EASE_OUT_QUART`, `EASE_IN_OUT_QUART`
- Quint: `EASE_IN_QUINT`, `EASE_OUT_QUINT`, `EASE_IN_OUT_QUINT`
- Expo: `EASE_IN_EXPO`, `EASE_OUT_EXPO`, `EASE_IN_OUT_EXPO`
- Circ: `EASE_IN_CIRC`, `EASE_OUT_CIRC`, `EASE_IN_OUT_CIRC`
- Back (overshoots past the target, then settles): `EASE_IN_BACK`,
  `EASE_OUT_BACK`, `EASE_IN_OUT_BACK`
- Elastic (springs past the target before settling): `EASE_IN_ELASTIC`,
  `EASE_OUT_ELASTIC`, `EASE_IN_OUT_ELASTIC`
- Bounce (bounces at the end like a dropped ball): `EASE_IN_BOUNCE`,
  `EASE_OUT_BOUNCE`, `EASE_IN_OUT_BOUNCE`

`_IN` starts slow and accelerates, `_OUT` starts fast and decelerates,
`_IN_OUT` does both.

## Configurable curve families

For finer control than a named curve gives you — a custom overshoot amount,
a spring's stiffness/damping, a hand-drawn `Curve` resource, or a callable —
`AnimaEase` also has parameterised `Kind` values (`BACK`, `BOUNCE`,
`ELASTIC`, `SPRING`, `CUBIC_BEZIER`, `CURVE`, `CALLABLE`, and more). These
need an `AnimaEase` resource, not a bare `Kind`. See the generated
[AnimaEase](../../anima/anima-ease) reference page for every field.
