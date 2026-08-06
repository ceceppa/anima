extends ExamplePlayground

enum Family {
	POSITION, POSITION_X, POSITION_Y, MOVE_BY,
	SCALE, SCALE_BY, ROTATION, ROTATE_BY,
	OPACITY, COLOR, SIZE, PROPERTY, CHAINED,
	KEYFRAMES, SPRING, DYNAMIC_VALUES,
}

const FAMILY_ORDER := [
	Family.POSITION, Family.POSITION_X, Family.POSITION_Y, Family.MOVE_BY,
	Family.SCALE, Family.SCALE_BY, Family.ROTATION, Family.ROTATE_BY,
	Family.OPACITY, Family.COLOR, Family.SIZE, Family.PROPERTY, Family.CHAINED,
	Family.KEYFRAMES, Family.SPRING, Family.DYNAMIC_VALUES,
]
const FAMILY_LABELS := {
	Family.POSITION: "Position",
	Family.POSITION_X: "Position X",
	Family.POSITION_Y: "Position Y",
	Family.MOVE_BY: "Move By",
	Family.SCALE: "Scale",
	Family.SCALE_BY: "Scale By",
	Family.ROTATION: "Rotation",
	Family.ROTATE_BY: "Rotate By",
	Family.OPACITY: "Opacity",
	Family.COLOR: "Colour",
	Family.SIZE: "Size",
	Family.PROPERTY: "Property",
	Family.CHAINED: "Chained",
	Family.KEYFRAMES: "Keyframes",
	Family.SPRING: "Spring",
	Family.DYNAMIC_VALUES: "Dynamic Values",
}
const FAMILY_EXAMPLES := {
	Family.POSITION: "Anima.on(card).position(card.position + Vector2(60, -40), 0.4)",
	Family.POSITION_X: "Anima.on(card).position_x(card.position.x + 60, 0.4)",
	Family.POSITION_Y: "Anima.on(card).position_y(card.position.y - 40, 0.4)",
	Family.MOVE_BY: "Anima.on(card).move_by(Vector2(60, 0), 0.4)",
	Family.SCALE: "Anima.on(card).scale(Vector2(1.3, 1.3), 0.4)",
	Family.SCALE_BY: "Anima.on(card).scale_by(Vector2(-0.2, -0.2), 0.4)",
	Family.ROTATION: "Anima.on(card).rotation(0.35, 0.4)",
	Family.ROTATE_BY: "Anima.on(card).rotate_by(-0.35, 0.4)",
	Family.OPACITY: "Anima.on(card).opacity(0.2, 0.4)",
	Family.COLOR: "Anima.on(card).color(Color(1.0, 0.4, 0.6), 0.4)",
	Family.SIZE: "Anima.on(card).size(Vector2(280, 280), 0.4)",
	Family.PROPERTY: "Anima.on(card).property(NodePath(\"modulate:b\"), 0.5, 0.4)",
	Family.CHAINED: "Anima.on(card).move_by(Vector2(50, 0), 0.2).repeat(2).on_started(...).on_completed(...)",
	Family.KEYFRAMES: "Motion.keyframes({\"from\": {...}, 30: {...}, 70: {...}, \"to\": {...}}).with_duration(0.9)",
	Family.SPRING: "Anima.on(card).position_x(card.position.x + 80, 0.0).with_ease(spring)",
	Family.DYNAMIC_VALUES: "Motion.to(\"position:x\", AnimaValue.target(\"position:x\").add(AnimaValue.target(\"size:x\")))",
}
const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

## Peak alpha of the stage's background glow — deliberately well below
## Card.GLOW_PEAK_ALPHA so it never competes with the animating card.
const GLOW_ALPHA := 0.08

@onready var _selector: SelectorDock = %Selector
@onready var _example_line: Label = %ExampleLine
@onready var _card: Card = %Card
@onready var _card_center: Control = %CardCenter
@onready var _glow: TextureRect = %Glow
@onready var _controls: PlaybackControls = %PlaybackControls

var _selected_family: Family = Family.MOVE_BY
var _active_playback: AnimaPlayback = null
## The Speed dock's current selection — applied to every freshly built
## AnimaPlayback in restart(), not just whichever one happened to be active
## when the dock last fired. Without this, restart() (selecting a new
## family, or pressing Restart) silently drops back to 1x every time,
## since a new AnimaPlayback always starts at its own default speed_scale.
var _selected_speed: float = 1.0

func _ready() -> void:
	super._ready()
	_style_glow()

	# CardCenter is a plain Control, not a CenterContainer: a CenterContainer
	# re-asserts its own centering on every layout pass, fighting the
	# convenience motion's direct writes to Card.position — a Card that
	# looked centred on the first play would jump back to the container's
	# top-left corner from underneath a later one. Centring here once (and
	# again only when either box's actual size changes) leaves `position`
	# fully owned by whichever motion is currently animating it in between.
	_card_center.resized.connect(_recenter_card)
	_card.resized.connect(_recenter_card)
	_recenter_card()

	for family in FAMILY_ORDER:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = FAMILY_LABELS[family]
		button.pressed.connect(select_family.bind(family))
		_selector.add_item(button)

	_controls.restart_pressed.connect(restart)
	_controls.reverse_pressed.connect(reverse)
	_controls.complete_pressed.connect(func() -> void:
		if _active_playback != null:
			_active_playback.complete()
	)
	_controls.revert_pressed.connect(func() -> void:
		if _active_playback != null:
			_active_playback.revert()
	)
	_controls.speed_selected.connect(func(speed: float) -> void:
		_selected_speed = speed
		if _active_playback != null:
			_active_playback.speed_scale = speed
	)
	_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void:
		Anima.reduced_motion = enabled
	)
	_selector.select(FAMILY_ORDER.find(_selected_family))
	restart()

func _exit_tree() -> void:
	if _active_playback != null and _active_playback.state == AnimaPlayback.State.PLAYING:
		_active_playback.cancel()

## Chooses the shown Anima.on() family and immediately replays it.
func select_family(family: Family) -> void:
	_selected_family = family
	_selector.select(FAMILY_ORDER.find(family))
	restart()

## Restarts the selected family's motion from the card's resting appearance.
func restart() -> void:
	if _active_playback != null and _active_playback.state == AnimaPlayback.State.PLAYING:
		_active_playback.cancel()
	_reset_card()
	_example_line.text = FAMILY_EXAMPLES[_selected_family]
	var motion := _build_motion()
	# 0.0 means complete immediately when reduced motion is active — the
	# web's "remove the motion" sense of reduced motion, not just a slower
	# play-through (tech-spec.md §Speed, direction, and reduced motion).
	motion.reduced_motion_speed = 0.0
	_active_playback = Anima.play(motion, _card)
	_active_playback.speed_scale = _selected_speed

## Reverses the currently selected motion through its actually-recorded run —
## the same public AnimaPlayback.reverse() a canonical motion uses
## (tech-spec.md §Key technical decisions), no convenience-specific path. If
## nothing has been captured yet (pressed before even one frame played),
## starts the same motion already reversed instead of leaving the original
## forward run untouched — see AnimaPlayback.reverse()'s return value.
func reverse() -> void:
	if _active_playback == null:
		restart()
		return
	if not _active_playback.reverse():
		var motion := _active_playback.motion
		var target := _active_playback.target
		# The original playback is still validly PLAYING forward — cancel it
		# before discarding the reference, or it stays registered with
		# AnimaRuntime and keeps getting ticked after nothing here can reach it.
		if _active_playback.state == AnimaPlayback.State.PLAYING:
			_active_playback.cancel()
		_active_playback = Anima.play_backwards(motion, target)

func _reset_card() -> void:
	_card.size = _card.custom_minimum_size
	_recenter_card()
	_card.scale = Vector2.ONE
	_card.rotation = 0.0
	_card.modulate = Color.WHITE

func _recenter_card() -> void:
	_card.position = (_card_center.size - _card.size) / 2.0

func _build_motion() -> AnimaMotion:
	match _selected_family:
		Family.POSITION:
			return Anima.on(_card).position(_card.position + Vector2(60.0, -40.0), 0.4)
		Family.POSITION_X:
			return Anima.on(_card).position_x(_card.position.x + 60.0, 0.4)
		Family.POSITION_Y:
			return Anima.on(_card).position_y(_card.position.y - 40.0, 0.4)
		Family.MOVE_BY:
			return Anima.on(_card).move_by(Vector2(60.0, 0.0), 0.4)
		Family.SCALE:
			return Anima.on(_card).scale(Vector2(1.3, 1.3), 0.4)
		Family.SCALE_BY:
			return Anima.on(_card).scale_by(Vector2(-0.2, -0.2), 0.4)
		Family.ROTATION:
			return Anima.on(_card).rotation(0.35, 0.4)
		Family.ROTATE_BY:
			return Anima.on(_card).rotate_by(-0.35, 0.4)
		Family.OPACITY:
			return Anima.on(_card).opacity(0.2, 0.4)
		Family.COLOR:
			return Anima.on(_card).color(Color(1.0, 0.4, 0.6), 0.4)
		Family.SIZE:
			return Anima.on(_card).size(Vector2(280.0, 280.0), 0.4)
		Family.PROPERTY:
			return Anima.on(_card).property(NodePath("modulate:b"), 0.5, 0.4)
		Family.CHAINED:
			return _build_chained_motion()
		Family.KEYFRAMES:
			return _build_keyframe_motion()
		Family.SPRING:
			return _build_spring_motion()
		_:
			return _build_dynamic_value_motion() # Family.DYNAMIC_VALUES

## Demonstrates the lifecycle-callback and repeat chain modifiers together —
## `.repeat()` comes before `.on_started()`/`.on_completed()` so the
## callbacks land on the [AnimaRepeat] [AnimaPlayback] actually reads, not on
## the leaf motion it wraps. Fires once each per full repeat run, not once
## per iteration. Shown through the same read-only example line every other
## family uses, appended with each event as it actually fires.
func _build_chained_motion() -> AnimaMotion:
	var base_text := FAMILY_EXAMPLES[Family.CHAINED]
	var repeated := Anima.on(_card).move_by(Vector2(50.0, 0.0), 0.2).repeat(2)
	# Without a pause, two identical, non-eased legs concatenate into one
	# seamless glide across the full distance — the repeat is genuinely
	# running twice, but reads as a single motion. This makes the break
	# between repetitions visible.
	repeated.delay_between = 0.15
	return repeated \
		.on_started(func(): _example_line.text = base_text + "  →  started") \
		.on_completed(func(): _example_line.text = base_text + "  →  started  →  completed")

## Demonstrates a multi-property keyframe motion: opacity, position, and
## scale each follow their own track through the same four offsets, showing
## the mid-point stops (30%, 70%) as visible pass-through states, not just a
## straight start-to-end interpolation.
func _build_keyframe_motion() -> AnimaKeyframeMotion:
	var base := _card.position
	return Motion.keyframes({
		"from": {"opacity": 1.0, "position": base, "scale": Vector2.ONE},
		30: {"opacity": 0.4, "position": base + Vector2(40.0, -30.0), "scale": Vector2(0.85, 0.85)},
		70: {"opacity": 1.0, "position": base + Vector2(80.0, 0.0), "scale": Vector2(1.15, 1.15)},
		"to": {"opacity": 1.0, "position": base, "scale": Vector2.ONE},
	}).with_duration(0.9)

## Demonstrates a spring-eased motion — the physics-simulated ease driven by
## AnimaPropertyMotionInstance._advance_spring(), not a fixed-duration curve;
## `duration` stays 0.0 since springs settle by simulation, not a timer.
## `.position_x()`, not `.position()`: _advance_spring() casts its captured
## from/to values with `float(...)`, which only produces a real number for an
## already-scalar property — a Vector2 target silently simulates toward 0.0
## and never visibly moves. Springs are scalar-only today.
## `spring_bounce = 0.6` (damping_ratio 0.4) is deliberately well above the
## critically-damped default — a low bounce (e.g. 0.15, damping_ratio 0.85)
## overshoots by well under a pixel at this travel distance, which reads as
## no bounce at all; this value overshoots by roughly a quarter of the total
## travel, visibly distinguishing a spring from every other eased family here.
func _build_spring_motion() -> AnimaPropertyMotion:
	var spring := AnimaEase.new()
	spring.kind = AnimaEase.Kind.SPRING
	spring.spring_response = 0.3
	spring.spring_bounce = 0.6
	return Anima.on(_card).position_x(_card.position.x + 80.0, 0.0).with_ease(spring)

## Demonstrates a dynamic value standalone, combined arithmetically, and
## inside a keyframe, chained through the same `.then()` composition CHAINED
## already uses. `slide_by_own_width` reads two of the card's own live
## properties (its position and its size) and adds them — standalone and
## combined at once, resolved fresh each run regardless of the card's actual
## current width. `pulse` then dips opacity to half of whatever it resolves
## to at that keyframe step, demonstrating a dynamic value inside a keyframe
## (`tech-spec.md` §Dynamic values). `Anima.on()`'s convenience methods take a
## fixed `float`/`Vector2`, not an [AnimaValue], so this uses [Motion]'s
## canonical `.to()`/`.keyframes()` authoring instead, the same as KEYFRAMES.
func _build_dynamic_value_motion() -> AnimaMotion:
	var slide_by_own_width := Motion.to(
		NodePath("position:x"),
		AnimaValue.target(NodePath("position:x")).add(AnimaValue.target(NodePath("size:x"))),
	).with_duration(0.4)

	var pulse := Motion.keyframes({
		"from": {"scale": Vector2.ONE},
		50: {"scale": Vector2(1.15, 1.15), "opacity": AnimaValue.target(NodePath("modulate:a")).multiply(0.5)},
		"to": {"scale": Vector2.ONE, "opacity": 1.0},
	}).with_duration(0.5)

	return slide_by_own_width.then(pulse)

## Restrained depth behind the card — design-brief.md §Component guide
## "Content stage", the same treatment `composition_playground.gd` uses.
func _style_glow() -> void:
	var accent := Color(0.486275, 0.227451, 0.929412, 1.0) # design-brief.md accent #7C3AED
	var gradient := Gradient.new()
	gradient.set_color(0, Color(accent.r, accent.g, accent.b, GLOW_ALPHA))
	gradient.set_color(1, Color(accent.r, accent.g, accent.b, 0.0))

	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.width = 512
	texture.height = 512
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)

	_glow.texture = texture
	_glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_glow.stretch_mode = TextureRect.STRETCH_SCALE
