extends ExamplePlayground

enum Family { MOVE_BY, SCALE, ROTATION, OPACITY, COLOR }

const FAMILY_ORDER := [Family.MOVE_BY, Family.SCALE, Family.ROTATION, Family.OPACITY, Family.COLOR]
const FAMILY_LABELS := {
	Family.MOVE_BY: "Move By",
	Family.SCALE: "Scale",
	Family.ROTATION: "Rotation",
	Family.OPACITY: "Opacity",
	Family.COLOR: "Colour",
}
const FAMILY_EXAMPLES := {
	Family.MOVE_BY: "Anima.on(card).move_by(Vector2(60, 0), 0.4)",
	Family.SCALE: "Anima.on(card).scale(Vector2(1.3, 1.3), 0.4)",
	Family.ROTATION: "Anima.on(card).rotation(0.35, 0.4)",
	Family.OPACITY: "Anima.on(card).opacity(0.2, 0.4)",
	Family.COLOR: "Anima.on(card).color(Color(1.0, 0.4, 0.6), 0.4)",
}
const SELECTOR_BUTTON := preload("res://examples/shared/components/selector_button.tscn")

## Peak alpha of the stage's background glow — deliberately well below
## Card.GLOW_PEAK_ALPHA so it never competes with the animating card.
const GLOW_ALPHA := 0.08

@onready var _selector: SelectorDock = %Selector
@onready var _example_line: Label = %ExampleLine
@onready var _card: Card = %Card
@onready var _glow: TextureRect = %Glow
@onready var _controls: PlaybackControls = %PlaybackControls

var _selected_family: Family = Family.MOVE_BY
var _active_playback: AnimaPlayback = null
var _base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	_style_glow()
	_base_position = _card.position

	for family in FAMILY_ORDER:
		var button: SelectorButton = SELECTOR_BUTTON.instantiate()
		button.text = FAMILY_LABELS[family]
		button.pressed.connect(select_family.bind(family))
		_selector.add_item(button)

	_controls.restart_pressed.connect(restart)
	_controls.reverse_pressed.connect(reverse)
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
	_active_playback = Anima.play(_build_motion(), _card)

## Reverses the currently selected motion through its actually-recorded run —
## the same public AnimaPlayback.reverse() a canonical motion uses
## (tech-spec.md §Key technical decisions), no convenience-specific path.
func reverse() -> void:
	if _active_playback == null:
		restart()
		return
	_active_playback.reverse()

func _reset_card() -> void:
	_card.position = _base_position
	_card.scale = Vector2.ONE
	_card.rotation = 0.0
	_card.modulate = Color.WHITE

func _build_motion() -> AnimaPropertyMotion:
	match _selected_family:
		Family.MOVE_BY:
			return Anima.on(_card).move_by(Vector2(60.0, 0.0), 0.4)
		Family.SCALE:
			return Anima.on(_card).scale(Vector2(1.3, 1.3), 0.4)
		Family.ROTATION:
			return Anima.on(_card).rotation(0.35, 0.4)
		Family.OPACITY:
			return Anima.on(_card).opacity(0.2, 0.4)
		_:
			return Anima.on(_card).color(Color(1.0, 0.4, 0.6), 0.4)

## Restrained depth behind the card — design-brief.md §Component guide
## "Content stage", the same treatment `composition_playground.gd` uses.
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
