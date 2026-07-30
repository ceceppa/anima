extends Control

enum CompositionType {
	SEQUENCE,
	PARALLEL,
	STAGGER,
	REPEAT,
	RACE,
	CONDITIONAL,
}

const TYPE_LABELS := {
	CompositionType.SEQUENCE: "Sequence",
	CompositionType.PARALLEL: "Parallel",
	CompositionType.STAGGER: "Stagger",
	CompositionType.REPEAT: "Repeat",
	CompositionType.RACE: "Race",
	CompositionType.CONDITIONAL: "Conditional",
}

const TYPE_DESCRIPTIONS := {
	CompositionType.SEQUENCE: "Plays each animation one after another.",
	CompositionType.PARALLEL: "Plays all animations at the same time.",
	CompositionType.STAGGER: "Starts each animation with a short delay between them.",
	CompositionType.REPEAT: "Repeats the composition a set number of times.",
	CompositionType.RACE: "Ends as soon as the first animation finishes.",
	CompositionType.CONDITIONAL: "Plays one of two animations based on a condition.",
}


## Fixed order for the stage counter ("01 / 06").
const DISPLAYED_TYPES := [
	CompositionType.SEQUENCE,
	CompositionType.PARALLEL,
	CompositionType.STAGGER,
	CompositionType.REPEAT,
	CompositionType.RACE,
	CompositionType.CONDITIONAL,
]

## Peak alpha of the stage's background glow — deliberately well below
## StateCard.GLOW_PEAK_ALPHA so it never competes with an animating card.
const GLOW_ALPHA := 0.08

## Conditional's single card layers these on top of StateCard's own
## progress-driven look (story-9b) — which branch ran is shown by direction
## of travel, extra scale, and (for the false branch) extra dimming, not by
## a label on the card.
const CONDITIONAL_OFFSET := 40.0
const CONDITIONAL_EXTRA_SCALE := 0.12
const CONDITIONAL_DIM_ALPHA := 0.2
const CONDITIONAL_CALLOUT_DURATION := 1.2
const CONDITIONAL_CALLOUT_FADE := 0.3

@onready var _stage: PanelContainer = %Stage
@onready var _glow: TextureRect = %Glow
@onready var _type_info: VBoxContainer = %TypeInfo
@onready var _type_title: Label = %TypeTitle
@onready var _type_description: Label = %TypeDescription
@onready var _type_counter: Label = %TypeCounter
@onready var _selector: SelectorDock = %Selector
@onready var _card_row: HBoxContainer = %CardRow
@onready var _conditional_callout: Label = %ConditionalCallout

var _type_info_tween: Tween

var _selector_type_order: Array = []
var _selected_type: CompositionType = CompositionType.SEQUENCE

var _conditional_callout_active: bool = false
var _conditional_callout_elapsed: float = 0.0

var _conditional_picked_true: bool = false
var _conditional_base_position: Vector2 = Vector2.ZERO
var _conditional_base_captured: bool = false

var _cards: Array[StateCard] = []
var _card_segments: Array = []       # per card: Array[Vector2], each a [start, end) pulse window
var _card_freeze_at: Array[float] = [] # per card: elapsed time is clamped to this before scaling
var _demo_elapsed: float = 0.0
var _tracking: bool = false
var _playback: AnimaPlayback = null
var _current_targets: Array[Node] = []

func _ready() -> void:
	_apply_hidpi_scale()
	_style_stage()
	_style_glow()

	for type in CompositionType.values():
		var button: SelectorButton = preload("res://examples/shared/components/selector_button.tscn").instantiate()
		button.text = TYPE_LABELS[type]
		button.pressed.connect(_select_type.bind(type))
		_selector.add_item(button)
		_selector_type_order.append(type)

	await get_tree().process_frame

	_select_type(CompositionType.SEQUENCE)

## Content stage container — design-brief.md §Component guide "Content stage
## (container)": stage-bg background, radius-lg, soft border/shadow, generous
## padding. Position/size never change; only the stage's contents do.
func _style_stage() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0549020, 0.0784314, 0.125490, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.117647, 0.160784, 0.231373, 0.4)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 24
	style.corner_radius_bottom_left = 24
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
	style.shadow_size = 32
	style.content_margin_left = 40
	style.content_margin_right = 40
	style.content_margin_top = 40
	style.content_margin_bottom = 40
	_stage.add_theme_stylebox_override("panel", style)
	_stage.clip_contents = true # keeps the background glow (below) within the stage's bounds

## Restrained depth behind the card row — design-brief.md §Component guide
## "Background depth treatment": a radial gradient, not the dot/grid
## alternative, kept subtle enough to stay less prominent than any card's own
## glow (story-5).
func _style_glow() -> void:
	var accent := Color(0.309804, 0.27451, 0.898039, 1.0)
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

## _select_type() frees the *previous* demo's placeholders when switching —
## this frees whichever demo was still active when the scene itself closes.
func _exit_tree() -> void:
	for target in _current_targets:
		target.free()
	_current_targets.clear()

## The editor scales its own UI for a HiDPI display automatically; a running
## game window does not. This reads the actual screen's OS-reported scale
## factor and applies it as the window's content scale, rather than
## hardcoding a fixed @2x — correct on any scale factor (1.5x, 2x, 3x...),
## not just Retina's usual 2x, and a no-op on a non-HiDPI screen.
func _apply_hidpi_scale() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var f_scale := DisplayServer.screen_get_scale(screen)
	if f_scale > 1.0:
		get_window().content_scale_factor = f_scale

func _select_type(type: CompositionType) -> void:
	if _playback != null and _playback.state == AnimaPlayback.State.PLAYING:
		_playback.cancel()

	_selected_type = type
	_selector.select(_selector_type_order.find(type))
	_update_stage_head(type)

	_conditional_base_captured = false
	_conditional_callout_active = false
	_conditional_callout.visible = false

	for card in _cards:
		_card_row.remove_child(card)
		card.free()
	_cards.clear()
	_card_segments.clear()
	_card_freeze_at.clear()

	# Placeholder targets are plain Nodes, never added to the tree — unlike
	# the StateCards above, nothing frees them automatically; dropping the
	# only reference to a Node (not a RefCounted) leaks it.
	for old_target in _current_targets:
		old_target.free()
	_current_targets.clear()

	var demo := _build_demo(type)
	var composition: AnimaMotion = demo.composition
	var target: Node = demo.target
	for new_target in demo.targets:
		_current_targets.append(new_target)

	for card_info in demo.cards:
		var card: StateCard = preload("res://examples/shared/components/state_card.tscn").instantiate()
		_card_row.add_child(card)
		card.set_label(card_info.label)
		card.set_progress(0.0)
		_cards.append(card)

		# Most demos are a single pulse per card ([start, end]); Repeat's one
		# card instead gets several pulse windows, so the same card visibly
		# repeats rather than looking like several different one-time cards.
		var segments: Array[Vector2] = []
		if card_info.has("segments"):
			for segment in card_info.segments:
				segments.append(segment)
		else:
			segments.append(Vector2(card_info.start, card_info.end))
		_card_segments.append(segments)

		# freeze_at defaults to the last segment's end (no early cutoff) —
		# Race's losing card is the only demo that overrides it, to visibly
		# stop short of finishing instead of completing alongside the winner.
		_card_freeze_at.append(card_info.get("freeze_at", segments[-1].y))

	_demo_elapsed = 0.0
	_tracking = true
	_playback = Anima.play(composition, target)

	if type == CompositionType.CONDITIONAL:
		_conditional_picked_true = demo.conditional_picked_true
		_show_conditional_callout(_conditional_picked_true)

## Names the branch the condition picked, visible only briefly at the start
## of Conditional's playback — story-9b. Faded and hidden from _process()
## (elapsed-time driven, like the cards) rather than a Tween, so it advances
## in step with the same manually-ticked clock the rest of this scene uses.
func _show_conditional_callout(picked_true: bool) -> void:
	_conditional_callout.text = "Condition evaluated: %s  (Playing: %s branch)" % [
		"TRUE" if picked_true else "FALSE",
		"True" if picked_true else "False",
	]
	_conditional_callout.modulate.a = 1.0
	_conditional_callout.visible = true
	_conditional_callout_elapsed = 0.0
	_conditional_callout_active = true

## Advances the callout's visible-then-fade lifetime by `delta`, called each
## frame from _process() alongside the card updates.
func _update_conditional_callout(delta: float) -> void:
	if not _conditional_callout_active:
		return

	_conditional_callout_elapsed += delta
	var fade_start := CONDITIONAL_CALLOUT_DURATION
	var fade_end := CONDITIONAL_CALLOUT_DURATION + CONDITIONAL_CALLOUT_FADE

	if _conditional_callout_elapsed >= fade_end:
		_conditional_callout.visible = false
		_conditional_callout_active = false
	elif _conditional_callout_elapsed >= fade_start:
		var fade_t := (_conditional_callout_elapsed - fade_start) / CONDITIONAL_CALLOUT_FADE
		_conditional_callout.modulate.a = 1.0 - fade_t

## Layers direction/scale/dimming on top of StateCard's own progress-driven
## look for Conditional's single card — true moves it forward and grows it;
## false moves it backward and shrinks + dims it. This is deliberately kept
## out of StateCard's own contract (project-rules.md §Example Scenes: no
## state, no per-composition-type branching inside state_card.gd) since no
## other composition type needs a direction.
func _apply_conditional_transform(card: StateCard, t: float) -> void:
	if not _conditional_base_captured:
		_conditional_base_position = card.position
		_conditional_base_captured = true

	var direction := 1.0 if _conditional_picked_true else -1.0
	card.position = _conditional_base_position + Vector2(direction * CONDITIONAL_OFFSET * t, 0.0)
	card.scale += Vector2.ONE * (direction * CONDITIONAL_EXTRA_SCALE * t)

	if not _conditional_picked_true:
		card.modulate.a = lerpf(StateCard.DIM_ALPHA, CONDITIONAL_DIM_ALPHA, t)

## Updates the stage's per-type title/description/counter as the composition
## type changes. The text updates immediately (so it's correct the instant a
## type is selected); a brief fade-in on the title/description container is
## what keeps the switch from reading as an instant snap — design-brief.md
## §Component guide "Stage type title + description".
func _update_stage_head(type: CompositionType) -> void:
	var index := DISPLAYED_TYPES.find(type)
	_type_counter.text = "" if index == -1 else "%02d / %02d" % [index + 1, DISPLAYED_TYPES.size()]
	_type_title.text = TYPE_LABELS[type]
	_type_description.text = TYPE_DESCRIPTIONS.get(type, "")

	if _type_info_tween != null and _type_info_tween.is_valid():
		_type_info_tween.kill()
	_type_info.modulate.a = 0.0
	_type_info_tween = create_tween()
	_type_info_tween.tween_property(_type_info, "modulate:a", 1.0, 0.12)

## Builds the requested composition type via the Motion builder against this
## scene's own demo nodes/cards. Only this scene owns these demo definitions —
## project-rules.md §Example Scenes / story-8's Boundaries.
func _build_demo(type: CompositionType) -> Dictionary:
	match type:
		CompositionType.SEQUENCE:
			return _build_sequence_demo()
		CompositionType.PARALLEL:
			return _build_parallel_demo()
		CompositionType.STAGGER:
			return _build_stagger_demo()
		CompositionType.REPEAT:
			return _build_repeat_demo()
		CompositionType.RACE:
			return _build_race_demo()
		CompositionType.CONDITIONAL:
			return _build_conditional_demo()
		_:
			return {}

## Anima.play() still needs a real Node target to prove the composition
## genuinely runs and completes for real — this one is never added to the
## tree, so it's never rendered. The StateCards themselves are what the
## user actually watches (StateCard.set_progress()), driven by the same
## precomputed [start, end] windows below, not by this placeholder's values.
func _make_placeholder() -> Node2D:
	return Node2D.new()

func _build_sequence_demo() -> Dictionary:
	var placeholder := _make_placeholder()
	var children: Array[AnimaMotion] = [
		Motion.to(NodePath("position:x"), 100.0).with_duration(0.6),
		Motion.to(NodePath("position:x"), 200.0).with_duration(0.6),
		Motion.to(NodePath("position:x"), 300.0).with_duration(0.6),
	]
	var sequence := Motion.sequence(children)
	var starts := sequence.compute_schedule()

	var cards: Array[Dictionary] = []
	var labels := ["A", "B", "C"]
	for i in range(children.size()):
		cards.append({"label": labels[i], "start": starts[i], "end": starts[i] + children[i].estimate_duration().seconds})

	return {"composition": sequence, "target": placeholder, "targets": [placeholder], "cards": cards}

func _build_parallel_demo() -> Dictionary:
	var placeholder := _make_placeholder()
	var leaf_a := Motion.to(NodePath("position:x"), 200.0).with_duration(0.8)
	var leaf_b := Motion.to(NodePath("modulate:a"), 0.3).with_duration(0.8)
	var parallel := Motion.parallel([leaf_a, leaf_b])

	var cards: Array[Dictionary] = [
		{"label": "A", "start": 0.0, "end": 0.8},
		{"label": "B", "start": 0.0, "end": 0.8},
	]
	return {"composition": parallel, "target": placeholder, "targets": [placeholder], "cards": cards}

func _build_stagger_demo() -> Dictionary:
	var targets: Array[Node] = [_make_placeholder(), _make_placeholder(), _make_placeholder()]
	var interval := 0.1
	var template := Motion.to(NodePath("position:x"), 60.0).with_duration(0.4)
	var stagger := Motion.stagger(targets, template, interval)

	var labels := ["A", "B", "C"]
	var cards: Array[Dictionary] = []
	for i in range(targets.size()):
		var start: float = float(i) * interval
		cards.append({"label": labels[i], "start": start, "end": start + 0.4})

	return {"composition": stagger, "target": null, "targets": targets, "cards": cards}

func _build_repeat_demo() -> Dictionary:
	var placeholder := _make_placeholder()
	var duration := 0.6
	var delay_between := 0.3
	var count := 3
	var child := Motion.to(NodePath("position:x"), 80.0).with_duration(duration)
	child.from_value = 0.0

	var repeat := Motion.repeat(child, count)
	repeat.alternate = true
	repeat.delay_between = delay_between

	# One card, pulsing once per repetition — not one card per repetition.
	# Three separate cards each doing a single pulse read as three unrelated
	# one-time events (indistinguishable from Sequence); the same card
	# visibly repeating is what actually reads as "repeat".
	var step := duration + delay_between
	var segments: Array[Vector2] = []
	for i in range(count):
		var start: float = float(i) * step
		segments.append(Vector2(start, start + duration))

	var cards: Array[Dictionary] = [
		{"label": "A", "segments": segments},
	]
	return {"composition": repeat, "target": placeholder, "targets": [placeholder], "cards": cards}

func _build_race_demo() -> Dictionary:
	var placeholder := _make_placeholder()

	# Randomised so the same card doesn't always win — Race is about whichever
	# finishes first, not about card A specifically.
	var a_is_fast := randi() % 2 == 0
	var duration_a := 0.3 if a_is_fast else 1.2
	var duration_b := 1.2 if a_is_fast else 0.3

	var leaf_a := Motion.to(NodePath("position:x"), 100.0).with_duration(duration_a)
	var leaf_b := Motion.to(NodePath("modulate:a"), 0.2).with_duration(duration_b)
	var race := Motion.race([leaf_a, leaf_b])

	# The race resolves the moment the fastest child finishes — the losing
	# card's progress is scaled to its own (longer) duration, but frozen at
	# that resolution point rather than snapping to complete alongside the
	# winner, so it visibly stops short instead of looking like Parallel.
	var race_duration := race.estimate_duration().seconds
	var cards: Array[Dictionary] = [
		{"label": "A", "start": 0.0, "end": duration_a, "freeze_at": race_duration},
		{"label": "B", "start": 0.0, "end": duration_b, "freeze_at": race_duration},
	]
	return {"composition": race, "target": placeholder, "targets": [placeholder], "cards": cards}

func _build_conditional_demo() -> Dictionary:
	var placeholder := _make_placeholder()
	var picked_true := randi() % 2 == 0

	var when_true := Motion.to(NodePath("position:x"), 100.0).with_duration(0.5)
	var when_false := Motion.to(NodePath("modulate:a"), 0.2).with_duration(0.5)
	var conditional := Motion.conditional(func() -> bool: return picked_true, when_true, when_false)

	# One card, no label — which branch ran is shown by the callout
	# (_show_conditional_callout) and by how the card itself moves
	# (_apply_conditional_transform), not by reading a letter on the card.
	var duration := (when_true if picked_true else when_false).estimate_duration().seconds
	var cards: Array[Dictionary] = [
		{"label": "", "start": 0.0, "end": duration},
	]
	return {
		"composition": conditional,
		"target": placeholder,
		"targets": [placeholder],
		"cards": cards,
		"conditional_picked_true": picked_true,
	}

## Drives each StateCard purely from elapsed time against that card's own
## precomputed pulse segments — no new addon API, just each composition's
## public duration/schedule surface (stories 0, 1, 2). Within a segment,
## progress rises 0→1 continuously (no discrete state, nothing snaps).
## Between segments (Repeat's gaps) it drops back to 0, so the same card
## visibly repeats instead of just holding at "done". Elapsed time is
## clamped to the card's freeze point first, so a Race loser stops
## advancing the moment the race resolves instead of reaching full
## progress alongside the winner.
func _process(delta: float) -> void:
	_update_conditional_callout(delta)

	if not _tracking:
		return

	_demo_elapsed += delta
	var all_completed := true

	for i in range(_cards.size()):
		var segments: Array = _card_segments[i]
		var freeze_at: float = _card_freeze_at[i]
		var clamped_elapsed: float = minf(_demo_elapsed, freeze_at)

		var t := 1.0
		for j in range(segments.size()):
			var segment: Vector2 = segments[j]
			if clamped_elapsed < segment.x:
				t = 0.0
				break
			elif clamped_elapsed < segment.y:
				t = (clamped_elapsed - segment.x) / (segment.y - segment.x)
				break
			elif j < segments.size() - 1:
				t = 0.0 # past this pulse, waiting for the next one
			else:
				t = 1.0 # past the last pulse — stay complete
		_cards[i].set_progress(t)

		if _selected_type == CompositionType.CONDITIONAL:
			_apply_conditional_transform(_cards[i], t)

		if _demo_elapsed < freeze_at:
			all_completed = false

	if all_completed:
		_tracking = false
