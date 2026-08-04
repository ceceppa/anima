extends ExamplePlayground

## Anima.on() families valid for a Node3D target (tech-spec.md §Convenience
## method interface) — no rotation, opacity, colour, or size: those require
## Control/Node2D/CanvasItem.
enum Family { POSITION, POSITION_X, POSITION_Y, POSITION_Z, MOVE_BY, SCALE, SCALE_BY }

const FAMILY_ORDER := [
	Family.POSITION, Family.POSITION_X, Family.POSITION_Y, Family.POSITION_Z,
	Family.MOVE_BY, Family.SCALE, Family.SCALE_BY,
]
const FAMILY_LABELS := {
	Family.POSITION: "Position",
	Family.POSITION_X: "Position X",
	Family.POSITION_Y: "Position Y",
	Family.POSITION_Z: "Position Z",
	Family.MOVE_BY: "Move By",
	Family.SCALE: "Scale",
	Family.SCALE_BY: "Scale By",
}
const FAMILY_EXAMPLES := {
	Family.POSITION: "Anima.on(card).position(card.position + Vector3(0.8, 0.4, 0), 0.4)",
	Family.POSITION_X: "Anima.on(card).position_x(card.position.x + 0.8, 0.4)",
	Family.POSITION_Y: "Anima.on(card).position_y(card.position.y + 0.6, 0.4)",
	Family.POSITION_Z: "Anima.on(card).position_z(card.position.z - 0.8, 0.4)",
	Family.MOVE_BY: "Anima.on(card).move_by(Vector3(0.6, 0, 0), 0.4)",
	Family.SCALE: "Anima.on(card).scale(Vector3(1.4, 1.4, 1.4), 0.4)",
	Family.SCALE_BY: "Anima.on(card).scale_by(Vector3(-0.3, -0.3, -0.3), 0.4)",
}
const SELECTOR_BUTTON := preload("res://examples/playground/shared/components/selector_button.tscn")

## Peak alpha of the stage's background glow — deliberately well below a
## competing visual, the same restrained treatment every 2D stage uses.
const GLOW_ALPHA := 0.08

@onready var _selector: SelectorDock = %Selector
@onready var _example_line: Label = %ExampleLine
@onready var _card: Node3D = %Card
@onready var _glow: TextureRect = %Glow
@onready var _controls: PlaybackControls = %PlaybackControls

var _selected_family: Family = Family.MOVE_BY
var _active_playback: AnimaPlayback = null

func _ready() -> void:
	super._ready()
	_style_glow()
	_reset_card()

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
## the same public AnimaPlayback.reverse() the 2D playground's controls use.
## If nothing has been captured yet, starts the same motion already reversed
## instead of leaving the original forward run untouched.
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
	_card.position = Vector3.ZERO
	_card.scale = Vector3.ONE

func _build_motion() -> AnimaPropertyMotion:
	match _selected_family:
		Family.POSITION:
			return Anima.on(_card).position(_card.position + Vector3(0.8, 0.4, 0.0), 0.4)
		Family.POSITION_X:
			return Anima.on(_card).position_x(_card.position.x + 0.8, 0.4)
		Family.POSITION_Y:
			return Anima.on(_card).position_y(_card.position.y + 0.6, 0.4)
		Family.POSITION_Z:
			return Anima.on(_card).position_z(_card.position.z - 0.8, 0.4)
		Family.MOVE_BY:
			return Anima.on(_card).move_by(Vector3(0.6, 0.0, 0.0), 0.4)
		Family.SCALE:
			return Anima.on(_card).scale(Vector3(1.4, 1.4, 1.4), 0.4)
		_:
			return Anima.on(_card).scale_by(Vector3(-0.3, -0.3, -0.3), 0.4)

## Restrained depth behind the stage — the same treatment every 2D playground uses.
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
