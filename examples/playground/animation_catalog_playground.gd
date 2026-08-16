extends ExamplePlayground

## Peak alpha of the stage's background glow — matches every other playground.
const GLOW_ALPHA := 0.08

## light_speed_in_*/light_speed_out_* target Sprite2D, not Control — Control
## has no writable "transform" for their skew (tech-spec.md §Animation
## catalog). The Card stage swaps to a small placeholder Sprite2D only for
## these four; every other preset plays on the ordinary Card.
const SPRITE2D_PRESETS := [
	"light_speed_in_left", "light_speed_in_right",
	"light_speed_out_left", "light_speed_out_right",
]

@onready var _sidebar: SelectorDock = %Sidebar
@onready var _grid: SelectorDock = %Grid
@onready var _stage_title: Label = %StageTitle
@onready var _glow: TextureRect = %Glow
@onready var _card_center: Control = %CardCenter
@onready var _card: Card = %Card
@onready var _sprite: Sprite2D = %Sprite
@onready var _controls: PlaybackControls = %PlaybackControls

const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

var _categories: Array[String] = []
var _current_category: String = ""
var _current_names: Array[String] = []
var _current_name: String = ""

var _active_playback: AnimaPlayback = null
var _selected_speed: float = 1.0

func _ready() -> void:
	super._ready()
	_style_glow()
	_make_sprite_texture()

	_card_center.resized.connect(_recenter_stage_visual)
	_card.resized.connect(_recenter_stage_visual)

	_categories = AnimationCatalogIndex.categories()
	for category in _categories:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = category.capitalize()
		button.pressed.connect(select_category.bind(category))
		_sidebar.add_item(button)

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

	if not _categories.is_empty():
		select_category(_categories[0])

func _exit_tree() -> void:
	if _active_playback != null and _active_playback.state == AnimaPlayback.State.PLAYING:
		_active_playback.cancel()

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

## The Sprite2D stand-in for the 4 light_speed presets — a flat tinted
## placeholder the same rough footprint as Card, generated at runtime so no
## art asset is needed for this narrow compatibility case.
func _make_sprite_texture() -> void:
	var image := Image.create(220, 220, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.152941, 0.101961, 0.278431, 1.0)) # close to Card's own gradient start
	_sprite.texture = ImageTexture.create_from_image(image)

func _recenter_stage_visual() -> void:
	_card.position = (_card_center.size - _card.size) / 2.0
	_sprite.position = _card_center.size / 2.0

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

## Selects and immediately plays [param preset_name] in the stage.
func select_preset(preset_name: String) -> void:
	_current_name = preset_name
	_grid.select(_current_names.find(preset_name))
	_stage_title.text = preset_name
	restart()

## Restarts the currently selected preset from the stage visual's resting appearance.
func restart() -> void:
	if _active_playback != null and _active_playback.state == AnimaPlayback.State.PLAYING:
		_active_playback.cancel()
	if _current_name == "":
		return

	var use_sprite := preset_name_uses_sprite(_current_name)
	_card.visible = not use_sprite
	_sprite.visible = use_sprite
	var target: Node = _sprite if use_sprite else _card
	_reset_target(target)

	var cached := Anima.animation(_current_name)
	if cached == null:
		return
	# Never chain-mutate the shared cached preset (tech-spec.md §Animation
	# catalog) — duplicate before setting a per-play override.
	var playable := cached.duplicate(true) as AnimaMotion
	playable.reduced_motion_speed = 0.0

	_active_playback = Anima.play(playable, target)
	_active_playback.speed_scale = _selected_speed

## Whether [param preset_name] is one of the 4 light_speed presets, which
## need Sprite2D rather than Card — see [constant SPRITE2D_PRESETS].
func preset_name_uses_sprite(preset_name: String) -> bool:
	return SPRITE2D_PRESETS.has(preset_name)

func _reset_target(target: Node) -> void:
	target.rotation = 0.0
	target.scale = Vector2.ONE
	target.modulate = Color.WHITE
	if target is Control:
		var control := target as Control
		control.size = control.custom_minimum_size
		control.position = (_card_center.size - control.size) / 2.0
	elif target is Node2D:
		var node2d := target as Node2D
		node2d.position = _card_center.size / 2.0
		node2d.skew = 0.0

## Reverses the currently selected preset through its actually-recorded run,
## the same public AnimaPlayback.reverse() contract every other playground
## uses (tech-spec.md §Key technical decisions).
func reverse() -> void:
	if _active_playback == null:
		restart()
		return
	if not _active_playback.reverse():
		var motion := _active_playback.motion
		var target := _active_playback.target
		if _active_playback.state == AnimaPlayback.State.PLAYING:
			_active_playback.cancel()
		_active_playback = Anima.play_backwards(motion, target)
