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

const KIND_LABELS := {
	AnimaDuration.Kind.FIXED: "FIXED",
	AnimaDuration.Kind.ESTIMATED: "ESTIMATED",
	AnimaDuration.Kind.DYNAMIC: "DYNAMIC",
	AnimaDuration.Kind.INFINITE: "INFINITE",
}

@onready var _selector: HBoxContainer = %Selector
@onready var _duration_badge: Label = %DurationBadge
@onready var _card_row: HBoxContainer = %CardRow
@onready var _playback_controls: PlaybackControls = %PlaybackControls

var _selector_buttons: Dictionary = {}
var _selected_type: CompositionType = CompositionType.SEQUENCE

var _cards: Array[StateCard] = []
var _card_segments: Array = []       # per card: Array[Vector2], each a [start, end) pulse window
var _card_freeze_at: Array[float] = [] # per card: elapsed time is clamped to this before scaling
var _demo_elapsed: float = 0.0
var _tracking: bool = false
var _playback: AnimaPlayback = null
var _current_targets: Array[Node] = []

func _ready() -> void:
	_apply_hidpi_scale()

	for type in CompositionType.values():
		if type == CompositionType.CONDITIONAL:
			continue # temporarily removed from the selector — confusing, revisit later
		var button: SelectorButton = preload("res://examples/shared/components/selector_button.tscn").instantiate()
		button.text = TYPE_LABELS[type]
		button.pressed.connect(_select_type.bind(type))
		_selector.add_child(button)
		_selector_buttons[type] = button

	_playback_controls.restart_pressed.connect(func() -> void: _select_type(_selected_type))
	_select_type(CompositionType.SEQUENCE)

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
	_update_selector_visuals()

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

	var duration := composition.estimate_duration()
	if duration.kind == AnimaDuration.Kind.FIXED:
		_duration_badge.text = "%s · %.1fs" % [KIND_LABELS[duration.kind], duration.seconds]
	else:
		_duration_badge.text = KIND_LABELS[duration.kind]

	_demo_elapsed = 0.0
	_tracking = true
	_playback = Anima.play(composition, target)

func _update_selector_visuals() -> void:
	for type in _selector_buttons:
		var button: SelectorButton = _selector_buttons[type]
		button.set_selected(type == _selected_type)

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

	# Only the branch the condition actually selects gets a runtime instance —
	# one card representing whichever branch runs, not one per branch.
	var duration := (when_true if picked_true else when_false).estimate_duration().seconds
	var cards: Array[Dictionary] = [
		{"label": "True" if picked_true else "False", "start": 0.0, "end": duration},
	]
	return {"composition": conditional, "target": placeholder, "targets": [placeholder], "cards": cards}

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

		if _demo_elapsed < freeze_at:
			all_completed = false

	if all_completed:
		_tracking = false
