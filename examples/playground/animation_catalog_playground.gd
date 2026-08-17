extends ExamplePlayground

## Peak alpha of the stage's background glow — matches every other playground.
const GLOW_ALPHA := 0.08

## Same atlas Card uses, so the Sprite2D slot's artwork matches Card's own
## treatment instead of a flat placeholder (story-1c; project-rules.md
## §Example Scenes "Card atlas").
const CARD_ATLAS := preload("res://examples/playground/images/cards.jpg")
const CARD_ATLAS_COLUMNS := 4
const CARD_ATLAS_CELL_SIZE := Vector2(384, 341)
const SPRITE_ATLAS_INDEX := 0

## Target-mode dock selection — which of the two stage halves currently
## play the selected preset. BOTH plays it on both simultaneously; CONTROL/
## SPRITE2D play it on only the one visible half. Every preset plays
## correctly on either target (AnimationCatalogSprite gives Sprite2D a
## synthetic `size` so `Control.size`-dependent offsets still resolve;
## writing an undefined property like `Sprite2D`'s skew to a `Control` is a
## silent no-op, confirmed empirically — see tech-spec.md §Animation
## catalog and story-1c) — so this is a display choice, not a compatibility
## routing decision (design-brief.md §Component guide "Target-mode dock").
enum TargetMode { BOTH, CONTROL, SPRITE2D }
const TARGET_MODE_ORDER := [TargetMode.BOTH, TargetMode.CONTROL, TargetMode.SPRITE2D]
const TARGET_MODE_LABELS := {
	TargetMode.BOTH: "Both",
	TargetMode.CONTROL: "Control",
	TargetMode.SPRITE2D: "Sprite2D",
}

@onready var _sidebar: SelectorDock = %Sidebar
@onready var _grid: SelectorDock = %Grid
@onready var _target_mode_dock: SelectorDock = %TargetModeDock
@onready var _glow: TextureRect = %Glow
@onready var _control_slot: Control = %ControlSlot
@onready var _control_label: Label = %ControlLabel
@onready var _sprite_slot: Control = %SpriteSlot
@onready var _sprite: AnimationCatalogSprite = %Sprite
@onready var _controls: PlaybackControls = %PlaybackControls

const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

var _categories: Array[String] = []
var _current_category: String = ""
var _current_names: Array[String] = []
var _current_name: String = ""
var _target_mode: TargetMode = TargetMode.BOTH

## Non-null exactly when the Control label is currently playing the
## selected preset — i.e. whenever target mode is BOTH or CONTROL.
var _label_playback: AnimaPlayback = null
## Non-null exactly when the Sprite2D slot is currently playing the
## selected preset — i.e. whenever target mode is BOTH or SPRITE2D.
var _sprite_playback: AnimaPlayback = null
var _selected_speed: float = 1.0

func _ready() -> void:
	super._ready()
	_style_glow()
	_make_sprite_texture()

	_control_slot.resized.connect(_recenter_control_label)
	_control_label.resized.connect(_recenter_control_label)
	_sprite_slot.resized.connect(_recenter_sprite)

	_categories = AnimationCatalogIndex.categories()
	for category in _categories:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = category.capitalize()
		button.pressed.connect(select_category.bind(category))
		_sidebar.add_item(button)

	for mode in TARGET_MODE_ORDER:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = TARGET_MODE_LABELS[mode]
		button.pressed.connect(select_target_mode.bind(mode))
		_target_mode_dock.add_item(button)
	_target_mode_dock.select(TARGET_MODE_ORDER.find(TargetMode.BOTH))
	_apply_target_mode_visibility()

	_controls.restart_pressed.connect(restart)
	_controls.reverse_pressed.connect(reverse)
	_controls.complete_pressed.connect(func() -> void:
		_for_each_playback(func(p: AnimaPlayback) -> void: p.complete())
	)
	_controls.revert_pressed.connect(func() -> void:
		_for_each_playback(func(p: AnimaPlayback) -> void: p.revert())
	)
	_controls.speed_selected.connect(func(speed: float) -> void:
		_selected_speed = speed
		_for_each_playback(func(p: AnimaPlayback) -> void: p.speed_scale = speed)
	)
	_controls.reduced_motion_toggled.connect(func(enabled: bool) -> void:
		Anima.reduced_motion = enabled
	)

	if not _categories.is_empty():
		select_category(_categories[0])

func _exit_tree() -> void:
	_for_each_playback(func(p: AnimaPlayback) -> void:
		if p.state == AnimaPlayback.State.PLAYING:
			p.cancel()
	)

func _for_each_playback(action: Callable) -> void:
	if _label_playback != null:
		action.call(_label_playback)
	if _sprite_playback != null:
		action.call(_sprite_playback)

## Restrained depth behind the stage visual — same technique every other
## playground uses (design-brief.md §Component guide "Background depth treatment").
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

## Gives the Sprite2D slot the same Card artwork atlas, same cell, as the
## shared Card component (story-1c) — not a flat generated placeholder.
## Shown at its native atlas-cell size: `scale = Vector2.ONE` has to mean
## "rest" for a preset's own scale keyframes to land where they're
## authored to, the same convention the Control label already uses — a
## compensating base scale here would fight that.
func _make_sprite_texture() -> void:
	var column := SPRITE_ATLAS_INDEX % CARD_ATLAS_COLUMNS
	var row := floori(float(SPRITE_ATLAS_INDEX) / float(CARD_ATLAS_COLUMNS))
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = CARD_ATLAS
	atlas_texture.region = Rect2(Vector2(column, row) * CARD_ATLAS_CELL_SIZE, CARD_ATLAS_CELL_SIZE)
	_sprite.texture = atlas_texture

func _recenter_control_label() -> void:
	_control_label.position = (_control_slot.size - _control_label.size) / 2.0

func _recenter_sprite() -> void:
	_sprite.position = _sprite_slot.size / 2.0

## Chooses which stage half(s) are visible and playing — see [enum
## TargetMode]. Always restarts so the newly-shown half(s) actually animate
## immediately rather than sitting at rest until the next preset pick.
func select_target_mode(mode: TargetMode) -> void:
	_target_mode = mode
	_target_mode_dock.select(TARGET_MODE_ORDER.find(mode))
	_apply_target_mode_visibility()
	restart()

func _apply_target_mode_visibility() -> void:
	_control_slot.visible = _target_mode != TargetMode.SPRITE2D
	_sprite_slot.visible = _target_mode != TargetMode.CONTROL

## Chooses a category, repopulates the grid with its preset names, and plays
## the first one (ux-flow.md §Animation Catalog Playground).
func select_category(category: String) -> void:
	_current_category = category
	_sidebar.select(_categories.find(category))
	_grid.clear_items()

	_current_names = AnimationCatalogIndex.names(category)
	for preset_name in _current_names:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = preset_name
		button.pressed.connect(select_preset.bind(preset_name))
		_grid.add_item(button)

	if not _current_names.is_empty():
		select_preset(_current_names[0])

## Selects and immediately plays [param preset_name] in the stage. The
## grid's own selected button already names the current preset — no
## separate stage title (design-brief.md §Screen composition — phase-18).
func select_preset(preset_name: String) -> void:
	_current_name = preset_name
	_grid.select(_current_names.find(preset_name))
	restart()

## Restarts the currently selected preset on whichever target(s) the
## current target mode says should be playing (story-1c) — BOTH plays it on
## both the Control label and the Sprite2D slot; CONTROL/SPRITE2D play it on
## only that one target, matching whichever half is actually visible.
func restart() -> void:
	_for_each_playback(func(p: AnimaPlayback) -> void:
		if p.state == AnimaPlayback.State.PLAYING:
			p.cancel()
	)
	_label_playback = null
	_sprite_playback = null
	if _current_name == "":
		return

	if _target_mode != TargetMode.SPRITE2D:
		_reset_target(_control_label)
		_label_playback = _play_copy(_control_label)
	if _target_mode != TargetMode.CONTROL:
		_reset_target(_sprite)
		_sprite_playback = _play_copy(_sprite)

## Plays a fresh, independent copy of the current preset on [param target].
## Never chain-mutate the shared cached preset (tech-spec.md §Animation
## catalog) — duplicate before setting a per-play override, and duplicate
## again for each of the (up to two) simultaneous targets.
func _play_copy(target: Node) -> AnimaPlayback:
	var cached := Anima.animation(_current_name)
	if cached == null:
		return null
	var playable := cached.duplicate(true) as AnimaMotion
	playable.reduced_motion_speed = 0.0
	var playback := Anima.play(playable, target)
	playback.speed_scale = _selected_speed
	return playback

func _reset_target(target: Node) -> void:
	target.rotation = 0.0
	target.scale = Vector2.ONE
	target.modulate = Color.WHITE
	if target == _control_label:
		_recenter_control_label()
	elif target == _sprite:
		_recenter_sprite()
		_sprite.skew = 0.0

## Reverses the currently selected preset(s) through their actually-recorded
## run, the same public AnimaPlayback.reverse() contract every other
## playground uses (tech-spec.md §Key technical decisions).
func reverse() -> void:
	if _label_playback == null and _sprite_playback == null:
		restart()
		return
	if _label_playback != null:
		_label_playback = _reversed(_label_playback)
	if _sprite_playback != null:
		_sprite_playback = _reversed(_sprite_playback)

func _reversed(playback: AnimaPlayback) -> AnimaPlayback:
	if playback.reverse():
		return playback
	var motion := playback.motion
	var target := playback.target
	if playback.state == AnimaPlayback.State.PLAYING:
		playback.cancel()
	return Anima.play_backwards(motion, target)
