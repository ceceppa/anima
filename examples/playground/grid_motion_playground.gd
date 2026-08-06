extends ExamplePlayground

const GRID_SIZE := Vector2i(5, 5)
const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

enum OrderFrom { TOP, BOTTOM, CENTER, TOGETHER, ODD, EVEN, RANDOM, INDEX }

const ORDER_ORDER := [
	OrderFrom.TOP, OrderFrom.BOTTOM, OrderFrom.CENTER, OrderFrom.TOGETHER,
	OrderFrom.ODD, OrderFrom.EVEN, OrderFrom.RANDOM, OrderFrom.INDEX,
]
const ORDER_LABELS := {
	OrderFrom.TOP: "Top", OrderFrom.BOTTOM: "Bottom", OrderFrom.CENTER: "Center",
	OrderFrom.TOGETHER: "Together", OrderFrom.ODD: "Odd", OrderFrom.EVEN: "Even",
	OrderFrom.RANDOM: "Random", OrderFrom.INDEX: "Index",
}

const FORMULA_ORDER := [
	AnimaGridMotion.DistanceFormula.EUCLIDEAN, AnimaGridMotion.DistanceFormula.MANHATTAN,
	AnimaGridMotion.DistanceFormula.CHEBYSHEV, AnimaGridMotion.DistanceFormula.ROW,
	AnimaGridMotion.DistanceFormula.COLUMN, AnimaGridMotion.DistanceFormula.DIAGONAL,
	AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL, AnimaGridMotion.DistanceFormula.CLOCKWISE,
	AnimaGridMotion.DistanceFormula.ANTICLOCKWISE, AnimaGridMotion.DistanceFormula.SPIRAL_INWARD,
	AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD, AnimaGridMotion.DistanceFormula.SERPENTINE_ROW,
	AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN,
]
const FORMULA_LABELS := {
	AnimaGridMotion.DistanceFormula.EUCLIDEAN: "Euclidean",
	AnimaGridMotion.DistanceFormula.MANHATTAN: "Manhattan",
	AnimaGridMotion.DistanceFormula.CHEBYSHEV: "Chebyshev",
	AnimaGridMotion.DistanceFormula.ROW: "Row",
	AnimaGridMotion.DistanceFormula.COLUMN: "Column",
	AnimaGridMotion.DistanceFormula.DIAGONAL: "Diagonal",
	AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL: "Anti-diagonal",
	AnimaGridMotion.DistanceFormula.CLOCKWISE: "Clockwise",
	AnimaGridMotion.DistanceFormula.ANTICLOCKWISE: "Anticlockwise",
	AnimaGridMotion.DistanceFormula.SPIRAL_INWARD: "Spiral Inward",
	AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD: "Spiral Outward",
	AnimaGridMotion.DistanceFormula.SERPENTINE_ROW: "Serpentine Row",
	AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN: "Serpentine Column",
}
const FORMULA_DESCRIPTIONS := {
	AnimaGridMotion.DistanceFormula.EUCLIDEAN: "Straight-line distance from the start tile.",
	AnimaGridMotion.DistanceFormula.MANHATTAN: "Horizontal plus vertical distance from the start tile.",
	AnimaGridMotion.DistanceFormula.CHEBYSHEV: "The larger of horizontal or vertical distance.",
	AnimaGridMotion.DistanceFormula.ROW: "Distance along the row axis only.",
	AnimaGridMotion.DistanceFormula.COLUMN: "Distance along the column axis only.",
	AnimaGridMotion.DistanceFormula.DIAGONAL: "Distance along the main diagonal.",
	AnimaGridMotion.DistanceFormula.ANTI_DIAGONAL: "Distance along the anti-diagonal.",
	AnimaGridMotion.DistanceFormula.CLOCKWISE: "A wave sweeping clockwise from 12 o'clock around the start tile.",
	AnimaGridMotion.DistanceFormula.ANTICLOCKWISE: "A wave sweeping anticlockwise from 12 o'clock around the start tile.",
	AnimaGridMotion.DistanceFormula.SPIRAL_INWARD: "Peels the grid inward from its top-left corner, ring by ring. Ignores the tapped tile — it traces the grid's own shape.",
	AnimaGridMotion.DistanceFormula.SPIRAL_OUTWARD: "The same spiral in reverse: starts at the centre and expands outward. Ignores the tapped tile too.",
	AnimaGridMotion.DistanceFormula.SERPENTINE_ROW: "Alternating left-right traversal, row by row.",
	AnimaGridMotion.DistanceFormula.SERPENTINE_COLUMN: "Alternating top-bottom traversal, column by column.",
}

@onready var _grid: GridContainer = %Grid
@onready var _order_selector: SelectorDock = %OrderSelector
@onready var _formula_selector: SelectorDock = %FormulaRow
@onready var _formula_description: Label = %FormulaDescription
@onready var _start_marker: Label = %StartMarker
@onready var _controls: PlaybackControls = %PlaybackControls

var _selected_order: OrderFrom = OrderFrom.TOP
var _selected_formula: AnimaGridMotion.DistanceFormula = AnimaGridMotion.DistanceFormula.EUCLIDEAN
var _start_point: Vector2i = Vector2i(2, 2)
var _active_playback: AnimaPlayback = null
var _grid_motion: AnimaGridMotion = null

func _ready() -> void:
	super._ready()

	for row in GRID_SIZE.y:
		for col in GRID_SIZE.x:
			var index := row * GRID_SIZE.x + col
			var card: Card = preload("res://examples/playground/shared/components/card.tscn").instantiate()
			card.custom_minimum_size = Vector2(96, 96)
			card.atlas_index = index % 12
			card.mouse_filter = Control.MOUSE_FILTER_STOP
			card.gui_input.connect(_on_card_gui_input.bind(Vector2i(col, row)))
			_grid.add_child(card)

	for order in ORDER_ORDER:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = ORDER_LABELS[order]
		button.pressed.connect(select_order.bind(order))
		_order_selector.add_item(button)

	for formula in FORMULA_ORDER:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = FORMULA_LABELS[formula]
		button.pressed.connect(select_formula.bind(formula))
		_formula_selector.add_item(button)

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
		if _active_playback != null:
			_active_playback.speed_scale = speed
	)
	_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void:
		Anima.reduced_motion = enabled
	)

	_order_selector.select(ORDER_ORDER.find(_selected_order))
	_reflect_selected_formula()
	_update_start_marker()
	restart()

func _exit_tree() -> void:
	if _active_playback != null and _active_playback.state == AnimaPlayback.State.PLAYING:
		_active_playback.cancel()

## Tapping a Card makes it the persistent start point and immediately
## replays — ux-flow.md §Grid Motion Example Scene. Not restricted to the
## grid's centre.
func _on_card_gui_input(event: InputEvent, cell: Vector2i) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_point = cell
		_update_start_marker()
		restart()

## Chooses the Order From mode and immediately replays — Top, Together, Odd,
## and Even leave the grid's own distance_formula active; Bottom, Center,
## Random, and Index fall back to the standard flat-list ordering any group
## has (tech-spec.md §Grid motion contract), the same way
## `group_motion_playground.gd`'s ordering selector already does.
func select_order(order: OrderFrom) -> void:
	_selected_order = order
	_order_selector.select(ORDER_ORDER.find(order))
	restart()

## Chooses the propagation formula and replays — the chosen Order From mode
## and start point are untouched.
func select_formula(formula: AnimaGridMotion.DistanceFormula) -> void:
	_selected_formula = formula
	_reflect_selected_formula()
	restart()

func _reflect_selected_formula() -> void:
	_formula_selector.select(FORMULA_ORDER.find(_selected_formula))
	_formula_description.text = FORMULA_DESCRIPTIONS[_selected_formula]

func restart() -> void:
	if _active_playback != null and _active_playback.state == AnimaPlayback.State.PLAYING:
		_active_playback.cancel()
	for card in _cards():
		card.set_progress(0.0)

	_grid_motion = _build_grid_motion()
	# 0.0 means complete immediately when reduced motion is active — the
	# web's "remove the motion" sense of reduced motion, not just a slower
	# play-through (tech-spec.md §Speed, direction, and reduced motion).
	_grid_motion.reduced_motion_speed = 0.0
	_active_playback = Anima.play(_grid_motion, self)

## Replays the resolved tile sequence backward through its actually-recorded
## run — the same public AnimaPlayback.reverse() any group already has. If
## nothing has been captured yet, starts the same grid motion already
## reversed instead of leaving the original forward run untouched.
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

func _cards() -> Array[Card]:
	var cards: Array[Card] = []
	for child in _grid.get_children():
		cards.append(child as Card)
	return cards

## Built through the [method Anima.grid] shorthand rather than hand-assembling
## an [AnimaTargetCollection] and [AnimaGridMotion] directly. This scene's
## explicit, tap-selected card collection and odd/even filter sit outside
## what the shorthand's own chain methods cover, so they're configured on the
## exposed [member AnimaGridMotionFactory.motion] afterward — the same
## escape hatch `tech-spec.md` §Grid convenience shorthand documents for
## anyone who needs more than the convenience surface itself.
func _build_grid_motion() -> AnimaGridMotion:
	var factory := Anima.grid(self) \
		.with_dimensions(GRID_SIZE) \
		.with_start_point(_start_point) \
		.with_distance_formula(_selected_formula) \
		.with_item_motion(Anima.item().property(NodePath("progress"), 1.0, 0.28).from(0.0)) \
		.with_stagger_interval(0.1)

	factory.motion.target_collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	factory.motion.target_collection.reference_data = _cards()
	factory.motion.reverse_order_policy = AnimaGroupMotion.ReverseOrderPolicy.REVERSE_EXECUTION
	_configure_order(factory.motion)
	return factory.motion

func _configure_order(grid: AnimaGridMotion) -> void:
	match _selected_order:
		OrderFrom.BOTTOM:
			grid.order.kind = AnimaGroupOrder.Kind.REVERSE
		OrderFrom.CENTER:
			grid.order.kind = AnimaGroupOrder.Kind.CENTRED
		OrderFrom.TOGETHER:
			grid.playback_mode = AnimaGroupMotion.PlaybackMode.PARALLEL
		OrderFrom.ODD:
			grid.target_collection.filter = AnimaTargetCollection.Filter.ODD_ONLY
		OrderFrom.EVEN:
			grid.target_collection.filter = AnimaTargetCollection.Filter.EVEN_ONLY
		OrderFrom.RANDOM:
			grid.order.kind = AnimaGroupOrder.Kind.RANDOM
			grid.order.seed = 2026
		OrderFrom.INDEX:
			grid.order.kind = AnimaGroupOrder.Kind.DISTANCE
			grid.order.origin = AnimaGroupOrder.Origin.INDEX
			grid.order.origin_index = 12
		_:
			pass # TOP — leaves order.kind at AnimaGridMotion's own GRID default.

func _update_start_marker() -> void:
	var index := _start_point.y * GRID_SIZE.x + _start_point.x
	var cards := _cards()
	if index < 0 or index >= cards.size():
		return
	_start_marker.get_parent().remove_child(_start_marker)
	cards[index].add_child(_start_marker)
	_start_marker.owner = self # reparenting drops %unique_name lookup unless the owner is restored
	_start_marker.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_start_marker.visible = true
