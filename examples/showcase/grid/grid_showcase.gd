## Scripted, self-contained scene for social-media capture — plays the full
## RPG-inventory storyboard automatically from `_ready()`, with no restart,
## reverse, or speed controls (`project-rules.md` §Example Scenes). Drives its
## own timeline and every [AnimaPlayback] it creates manually via [method
## AnimaPlayback.step], the same direct-drive entry point GUT tests use, so
## the whole ~15s sequence is deterministically advanceable by a test loop.
class_name GridShowcase
extends Control

const GRID_SIZE := Vector2i(5, 5)
const MATRIX_SIZE := Vector2i(4, 4)
const SLOT_SIZE := 120.0
const SLOT_GAP := 16.0
const MINI_SLOT_SIZE := 18.0
const MINI_SLOT_GAP := 2.0
const MINI_GRID_MARGIN := 14.0

const SCENE1_START := 0.0
const SCENE2_START := 2.0
const SCENE3_START := 5.0
const SCENE4_START := 12.0
const DIM_AT := 13.5
const TOTAL_DURATION := 15.0

const FRAME_GOLD := Color(0.788235, 0.635294, 0.152941, 1.0)
const SLOT_BG := Color(0.101961, 0.070588, 0.043137, 0.8)

## Formulas cycled through Scene 3 and assigned across the Scene 4 matrix —
## the storyboard's own "radial expansion", "diagonal corner sweep", and
## "random noise stagger" (`v2_stuff/prd-social-media.md` Scene 3).
enum Formula { RADIAL, DIAGONAL, RANDOM }
const FORMULA_CAPTIONS := {
	Formula.RADIAL: "Anima.grid($Grid).from_center().play()",
	Formula.DIAGONAL: "Anima.grid($Grid).diagonal_sweep().play()",
	Formula.RANDOM: "Anima.grid($Grid).random_stagger().play()",
}
const SCENE3_FORMULA_ORDER := [Formula.RADIAL, Formula.DIAGONAL, Formula.RANDOM]
const SCENE3_FORMULA_DURATION := (SCENE4_START - SCENE3_START) / 3.0 # ~2.33s each

## How long the ripple-in/formula-replay animation for one 5x5 grid takes.
const GRID_ANIM_DURATION := 0.55
## Delay between one Scene-4 mini-grid starting and the next, spiralling
## outward from the matrix centre — an adjustable value, per the phase brief's
## own Exit Criteria ("delay between waves exposed as an adjustable value").
@export var finale_wave_delay: float = 0.1

@onready var _scene2: Control = %Scene2
@onready var _vanilla_code: Label = %VanillaCode
@onready var _anima_code: Label = %AnimaCode
@onready var _scene3: Control = %Scene3
@onready var _caption_bar: Label = %CaptionBar
@onready var _scene4: Control = %Scene4
@onready var _matrix: Control = %Matrix
@onready var _dim: ColorRect = %Dim
@onready var _logo_cta: Control = %LogoCta
@onready var _logo: TextureRect = %Logo

var _elapsed: float = 0.0
var _current_beat: int = -1
var _dim_triggered: bool = false
var _active_playbacks: Array[AnimaPlayback] = []

## Icon art each Scene-4 mini-grid's slots animate in — populated from
## `assets/icons/` if present, else an obvious placeholder swatch. Scene 1's
## own inventory grid is a separate concern entirely, owned by `%Layer1`
## (`layer_1.gd`/`inventory_grid.gd`) — this scene only tells it when to play.
var _mini_grids: Array[Control] = []
var _mini_icon_nodes: Array[Array] = [] # Array[Array[TextureRect]], one inner array per mini-grid

## Scene 3's own formula-cycling sub-state.
var _scene3_formula_index: int = -1

func _ready() -> void:
	_build_finale_matrix()
	_play_scene1()

func _process(delta: float) -> void:
	#_advance_show(delta)
	pass

## Advances the whole scripted show by [param delta] seconds — the scene's
## own timeline (which beat is showing) plus every currently active
## [AnimaPlayback], stepped manually rather than through [AnimaRuntime]'s
## automatic per-frame loop, so a test can drive the entire ~15s sequence
## deterministically without waiting on real frames.
func _advance_show(delta: float) -> void:
	_elapsed += delta
	_update_beat()
	if _current_beat == 2:
		_advance_scene3(delta)
	if not _dim_triggered and _elapsed >= DIM_AT:
		_dim_triggered = true
		_trigger_finale_dim()

	for playback in _active_playbacks.duplicate():
		if playback.state == AnimaPlayback.State.PLAYING:
			playback.step(delta)
		if playback.state != AnimaPlayback.State.PLAYING:
			_active_playbacks.erase(playback)

func _beat_for_elapsed(elapsed: float) -> int:
	if elapsed >= SCENE4_START:
		return 3
	if elapsed >= SCENE3_START:
		return 2
	if elapsed >= SCENE2_START:
		return 1
	return 0

func _update_beat() -> void:
	var beat := _beat_for_elapsed(_elapsed)
	if beat == _current_beat:
		return
	_current_beat = beat
	match beat:
		0:
			_play_scene1()
		1:
			_play_scene2()
		2:
			_play_scene3()
		3:
			_play_scene4()

## A flat-colour placeholder texture — used whenever an expected asset is
## missing, so the scene shows an obvious gap instead of nothing at all.
func _solid_texture(color: Color) -> ImageTexture:
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)

## Builds one bordered inventory slot (`design-brief.md` §Showcase: Grid —
## Inventory frame) holding one item-art `TextureRect`, starting hidden and
## scaled down so it can "ripple" into place.
func _build_slot(size: Vector2, icon_paths: Array, index: int) -> Panel:
	var panel := Panel.new()
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = SLOT_BG
	style.border_color = FRAME_GOLD
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.size = size * 0.7
	icon.position = size * 0.15
	icon.pivot_offset = icon.size / 2.0
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_SCALE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = _icon_texture(icon_paths, index)
	icon.modulate.a = 0.0
	icon.scale = Vector2(0.6, 0.6)
	panel.add_child(icon)
	return panel

## Real icon file paths under `assets/icons/`, if the user has supplied any
## yet — empty when the folder doesn't exist, so every slot falls back to
## the placeholder swatch instead of erroring.
func _discover_icon_paths() -> Array:
	var paths: Array = []
	var dir := DirAccess.open("res://examples/showcase/grid/assets/icons")
	if dir == null:
		return paths
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".svg")):
			paths.append("res://examples/showcase/grid/assets/icons/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths

func _icon_texture(icon_paths: Array, index: int) -> Texture2D:
	if icon_paths.is_empty():
		return _solid_texture(FRAME_GOLD)
	var path: String = icon_paths[index % icon_paths.size()]
	if ResourceLoader.exists(path):
		return load(path)
	return _solid_texture(FRAME_GOLD)

## Builds the Scene-4 finale: a 4x4 matrix of miniature 5x5 inventory grids
## (`design-brief.md` §Showcase: Grid — Finale matrix).
func _build_finale_matrix() -> void:
	var mini_grid_size := MINI_SLOT_SIZE * 5.0 + MINI_SLOT_GAP * 4.0 + MINI_GRID_MARGIN * 2.0
	var total_size := Vector2(mini_grid_size, mini_grid_size) * Vector2(MATRIX_SIZE)
	var origin := (size - total_size) / 2.0

	for row in MATRIX_SIZE.y:
		for col in MATRIX_SIZE.x:
			var mini := Control.new()
			mini.size = Vector2(mini_grid_size, mini_grid_size)
			mini.position = origin + Vector2(col, row) * mini_grid_size
			mini.mouse_filter = Control.MOUSE_FILTER_IGNORE

			var border := Panel.new()
			border.size = mini.size
			border.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var border_style := StyleBoxFlat.new()
			border_style.bg_color = Color(0.078, 0.051, 0.035, 1.0)
			border_style.border_color = FRAME_GOLD
			border_style.set_border_width_all(1)
			mini.add_child(border)

			var icon_paths := _discover_icon_paths()
			var mini_icons: Array = []
			for mini_row in GRID_SIZE.y:
				for mini_col in GRID_SIZE.x:
					var mini_index := mini_row * GRID_SIZE.x + mini_col
					var slot := _build_slot(Vector2(MINI_SLOT_SIZE, MINI_SLOT_SIZE), icon_paths, mini_index)
					slot.position = Vector2(MINI_GRID_MARGIN, MINI_GRID_MARGIN) + Vector2(mini_col, mini_row) * (MINI_SLOT_SIZE + MINI_SLOT_GAP)
					mini.add_child(slot)
					mini_icons.append(slot.get_node("Icon"))

			_matrix.add_child(mini)
			_mini_grids.append(mini)
			_mini_icon_nodes.append(mini_icons)

## Scene 1 (0:00-0:02) — items ripple into the empty inventory grid while the
## opening banner reads (`v2_stuff/prd-social-media.md` Scene 1). `%Layer1`
## (`layer_1.gd`) owns the actual grid/banner content and its own reveal —
## this only shows it and tells it to play.
func _play_scene1() -> void:
	%Layer1.visible = true
	_scene2.visible = false
	_scene3.visible = false
	_scene4.visible = false
	%Layer1.play()

## Scene 2 (0:02-0:05) — hard cut to the full-screen code comparison
## (`v2_stuff/prd-social-media.md` Scene 2). Code text is illustrative
## placeholder copy — story-2's own scope explicitly excludes final wording.
func _play_scene2() -> void:
	%Layer1.visible = false
	_scene2.visible = true
	_scene3.visible = false
	_scene4.visible = false
	_vanilla_code.text = "for x in range(cols):\n  for y in range(rows):\n    var i := x + y * cols\n    var t := i * 0.05\n    get_child(i).modulate.a = 0.0\n    var tw := create_tween()\n    tw.tween_property(\n      get_child(i), \"modulate:a\", 1.0, 0.3\n    ).set_delay(t)\n    # ...16 more lines of rank math"
	_anima_code.text = "Anima.grid($Grid).play()"

## Scene 3 (0:05-0:12) — cuts back to the inventory grid and replays it with
## three different formulas back-to-back, the live triggering code line shown
## in the caption bar (`v2_stuff/prd-social-media.md` Scene 3). Reuses the
## same `%Layer1` grid Scene 1 shows.
##
## `%InventoryGrid.play()` doesn't take a formula argument yet — every replay
## here uses its one built-in formula, only the caption text actually cycles
## per formula. Wiring a real per-formula replay through is follow-up work,
## not this fix.
func _play_scene3() -> void:
	%Layer1.visible = true
	_scene2.visible = false
	_scene3.visible = true
	_scene4.visible = false
	_scene3_formula_index = -1
	_advance_scene3(0.0)

func _advance_scene3(_delta: float) -> void:
	var elapsed_in_scene := _elapsed - SCENE3_START
	var index: int = clampi(int(elapsed_in_scene / SCENE3_FORMULA_DURATION), 0, SCENE3_FORMULA_ORDER.size() - 1)
	if index == _scene3_formula_index:
		return
	_scene3_formula_index = index
	var formula: Formula = SCENE3_FORMULA_ORDER[index]
	_caption_bar.text = FORMULA_CAPTIONS[formula]
	%Layer1.play()

## Scene 4 (0:12-0:15) — the finale matrix: the centre-most mini-grid starts
## first, the rest follow one at a time spiralling outward, each a fixed
## delay after the previous (`AnimaMotion.delay`, `tech-spec.md` §Key
## technical decisions) — the adjustable [member finale_wave_delay].
## Formulas cycle across the matrix so it isn't 16 identical animations.
func _play_scene4() -> void:
	%Layer1.visible = false
	_scene2.visible = false
	_scene3.visible = false
	_scene4.visible = true
	_dim.visible = false
	_logo_cta.visible = false

	var ranks := _spiral_outward_ranks(MATRIX_SIZE)
	for i in _mini_grids.size():
		_reset_icons(_mini_icon_nodes[i])
		var formula: Formula = SCENE3_FORMULA_ORDER[i % SCENE3_FORMULA_ORDER.size()]
		var motion := _build_formula_motion(formula, _mini_icon_nodes[i])
		motion.delay = ranks[i] * finale_wave_delay
		_active_playbacks.append(AnimaPlayback.new(motion, self))

## Ranks each cell of a [param dimensions] grid by distance from its centre
## (Manhattan distance, angle as a tiebreak), producing a unique 0..N-1 rank
## per cell with no ties — a deterministic "centre first, then outward, one
## at a time" ordering, matching the storyboard's own description of the
## finale (`v2_stuff/prd-social-media.md` Scene 4; user clarification: "the
## central item... gets played first then in outward spiral").
func _spiral_outward_ranks(dimensions: Vector2i) -> Array:
	var center := Vector2((dimensions.x - 1) / 2.0, (dimensions.y - 1) / 2.0)
	var cells: Array = []
	for row in dimensions.y:
		for col in dimensions.x:
			var offset := Vector2(col, row) - center
			var distance := absf(offset.x) + absf(offset.y)
			var angle := offset.angle()
			cells.append({"index": row * dimensions.x + col, "distance": distance, "angle": angle})

	cells.sort_custom(func(a, b) -> bool:
		if not is_equal_approx(a["distance"], b["distance"]):
			return a["distance"] < b["distance"]
		return a["angle"] < b["angle"]
	)

	var ranks: Array = []
	ranks.resize(cells.size())
	for rank in cells.size():
		ranks[cells[rank]["index"]] = rank
	return ranks

## Fades the closing logo and CTA text in over the dimmed finale matrix at
## 13.5s (`v2_stuff/prd-social-media.md` Scene 4 "End Transition").
func _trigger_finale_dim() -> void:
	_dim.visible = true
	_logo_cta.visible = true
	_logo_cta.modulate.a = 0.0
	var fade := Anima.on(_logo_cta).opacity(1.0, 0.5).from(0.0)
	_active_playbacks.append(AnimaPlayback.new(fade, _logo_cta))

func _reset_icons(icons: Array) -> void:
	for icon in icons:
		icon.modulate.a = 0.0
		icon.scale = Vector2(0.6, 0.6)

## Plays [param formula] on [param icons] — one shared grid-driven ripple
## used by Scene 1, Scene 3, and each Scene-4 mini-grid (`tech-spec.md`
## §Grid motion contract).
func _play_formula(formula: Formula, icons: Array) -> void:
	var motion := _build_formula_motion(formula, icons)
	_active_playbacks.append(AnimaPlayback.new(motion, self))

func _build_formula_motion(formula: Formula, icons: Array) -> AnimaGridMotion:
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.EXPLICIT
	collection.reference_data = icons

	var grid := AnimaGridMotion.new()
	grid.target_collection = collection
	grid.grid_dimensions = GRID_SIZE
	grid.distribution.stagger_interval = GRID_ANIM_DURATION / float(GRID_SIZE.x + GRID_SIZE.y)
	grid.item_motion = Anima.item().opacity(1.0, GRID_ANIM_DURATION * 0.6).from(0.0) \
		.with(Anima.item().scale(Vector2.ONE, GRID_ANIM_DURATION * 0.6).from(Vector2(0.6, 0.6)))

	match formula:
		Formula.RADIAL:
			grid.distance_formula = AnimaGridMotion.DistanceFormula.EUCLIDEAN
			grid.start_point = Vector2i(2, 2)
		Formula.DIAGONAL:
			grid.distance_formula = AnimaGridMotion.DistanceFormula.DIAGONAL
			grid.start_point = Vector2i(0, 0)
		Formula.RANDOM:
			grid.order.kind = AnimaGroupOrder.Kind.RANDOM
			grid.order.seed = 2026

	return grid
