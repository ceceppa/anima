extends ExamplePlayground

enum PlaybackMode { SEQUENTIAL, PARALLEL, STAGGERED }
enum Ordering { FIRST, LAST, CENTER, ODD, EVEN, RANDOM, INDEX }

const PLAYBACK_LABELS := ["Sequential", "Parallel", "Staggered"]
const ORDER_LABELS := ["First", "Last", "Center", "Odd", "Even", "Random", "Index"]
const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

const ORDER_DESCRIPTIONS := {
	Ordering.FIRST: "Starts at the first card in the collection.",
	Ordering.LAST: "Starts at the last card and travels back.",
	Ordering.CENTER: "Starts in the middle and spreads outward.",
	Ordering.ODD: "Animates only the second, fourth, and later odd-position cards.",
	Ordering.EVEN: "Animates only the first, third, and later even-position cards.",
	Ordering.RANDOM: "Uses the same seeded random card order every time.",
	Ordering.INDEX: "Starts from the selected middle index and spreads outward.",
}

@onready var _playback_selector: SelectorDock = %PlaybackSelector
@onready var _order_selector: SelectorDock = %OrderSelector
@onready var _order_description: Label = %OrderDescription
@onready var _card_row: HBoxContainer = %CardRow
@onready var _controls: PlaybackControls = %PlaybackControls

var selected_playback: PlaybackMode = PlaybackMode.STAGGERED
var selected_order: Ordering = Ordering.FIRST
var active_playback: AnimaPlayback = null
var _group: AnimaGroupMotion = null
## The speed multiplier last picked via the speed selector — applied to
## whatever playback is currently running, and reapplied to each new one
## `restart()` creates, so switching playback mode/ordering doesn't silently
## drop back to 1x (`_mano_output/phase-16/stories/story-5b-group-playground-speed-persists-across-restart.md`).
var _selected_speed: float = 1.0

func _ready() -> void:
	super._ready()

	for index in PLAYBACK_LABELS.size():
		var playback_button: SelectorButton = SELECTOR_BUTTON.instantiate()
		playback_button.text = PLAYBACK_LABELS[index]
		playback_button.pressed.connect(select_playback.bind(index))
		_playback_selector.add_item(playback_button)
	for index in ORDER_LABELS.size():
		var order_button: SelectorButton = SELECTOR_BUTTON.instantiate()
		order_button.text = ORDER_LABELS[index]
		order_button.pressed.connect(select_order.bind(index))
		_order_selector.add_item(order_button)
	_controls.restart_pressed.connect(restart)
	_controls.reverse_pressed.connect(reverse)
	_controls.complete_pressed.connect(func() -> void:
		if active_playback != null:
			active_playback.complete()
	)
	_controls.revert_pressed.connect(func() -> void:
		if active_playback != null:
			active_playback.revert()
	)
	_controls.speed_selected.connect(func(speed: float) -> void:
		_selected_speed = speed
		if active_playback != null:
			active_playback.speed_scale = speed
	)
	_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void:
		Anima.reduced_motion = enabled
	)
	_playback_selector.select(selected_playback)
	_order_selector.select(selected_order)
	_order_description.text = ORDER_DESCRIPTIONS[selected_order]
	restart()

func _exit_tree() -> void:
	if active_playback != null and active_playback.state == AnimaPlayback.State.PLAYING:
		active_playback.cancel()

## Chooses the group's relation between item starts and immediately restarts it.
func select_playback(mode: PlaybackMode) -> void:
	selected_playback = mode
	_playback_selector.select(mode)
	restart()

## Chooses where the group starts and immediately restarts the visible cards.
func select_order(ordering: Ordering) -> void:
	selected_order = ordering
	_order_selector.select(ordering)
	_order_description.text = ORDER_DESCRIPTIONS[ordering]
	restart()

## Restarts the currently selected group combination from its first visible card.
func restart(play := true) -> void:
	if active_playback != null and active_playback.state == AnimaPlayback.State.PLAYING:
		active_playback.cancel()
	for card in _cards():
		card.set_progress(0.0)
	_group = _build_group()
	# 0.0 means complete immediately when reduced motion is active — the
	# web's "remove the motion" sense of reduced motion, not just a slower
	# play-through (tech-spec.md §Speed, direction, and reduced motion).
	_group.reduced_motion_speed = 0.0

	active_playback = Anima.play(_group, self)
	active_playback.speed_scale = _selected_speed

## Replays this run's resolved card collection in reverse order and returns the
## decorative cards to their resting appearance. If nothing has been captured
## yet, starts the same group motion already reversed instead of leaving the
## original forward run untouched.
func reverse() -> void:
	if active_playback == null:
		restart()
		return

	if not active_playback.reverse():
		var motion := active_playback.motion
		var target := active_playback.target
		# The original playback is still validly PLAYING forward — it just
		# failed to reverse in place. Cancel it before discarding the
		# reference, or it stays registered with AnimaRuntime and keeps
		# getting ticked (eventually against a freed target) after nothing
		# in this scene can reach it anymore.
		if active_playback.state == AnimaPlayback.State.PLAYING:
			active_playback.cancel()
		
		active_playback = Anima.play_backwards(motion, target)

func _cards() -> Array[Card]:
	var cards: Array[Card] = []
	for child in _card_row.get_children():
		cards.append(child as Card)
	return cards

func _build_group() -> AnimaGroupMotion:
	var item := Motion.to(NodePath("progress"), 1.0).with_duration(0.42)
	item.from_value = 0.0
	var group := Anima.group(_card_row).with_item_motion(item).motion
	match selected_playback:
		PlaybackMode.SEQUENTIAL:
			group.playback_mode = AnimaGroupMotion.PlaybackMode.SEQUENTIAL
		PlaybackMode.PARALLEL:
			group.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
		_:
			group.playback_mode = AnimaGroupMotion.PlaybackMode.STAGGERED
	group.distribution.stagger_interval = 0.12
	group.reverse_order_policy = AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION
	_configure_order(group)

	return group

func _configure_order(group: AnimaGroupMotion) -> void:
	match selected_order:
		Ordering.LAST:
			group.order.kind = AnimaGroupOrder.Kind.REVERSE
		Ordering.CENTER:
			group.order.kind = AnimaGroupOrder.Kind.CENTRED
		Ordering.ODD:
			group.target_collection.filter = AnimaTargetCollection.Filter.ODD_ONLY
		Ordering.EVEN:
			group.target_collection.filter = AnimaTargetCollection.Filter.EVEN_ONLY
		Ordering.RANDOM:
			group.order.kind = AnimaGroupOrder.Kind.RANDOM
			group.order.seed = 2026
		Ordering.INDEX:
			group.order.kind = AnimaGroupOrder.Kind.DISTANCE
			group.order.origin = AnimaGroupOrder.Origin.INDEX
			group.order.origin_index = 2
