## Scripted 3D promo scene for social-media capture (about 20 seconds). Every
## node lives in showcase_3d.tscn, so look, framing and timing-relevant
## positions can be tweaked in the editor; this script only plays the
## storyboard, with Anima's own catalog presets:
##
## 1. The cube plays rubber_band, then tada.
## 2. The sphere and cylinder bounce in, then all three shapes play jello,
##    wobble and bounce.
## 3. The camera moves to the grid shot and three [method Anima.grid] calls
##    pop, ripple and spiral across the 5×5 floor of tiles.
## 4. The logo and repository link close the video.
##
## Nodes that appear later (sphere, cylinder, tiles, preset label, outro) are
## hidden in the scene; toggle their visibility in the editor to tweak them.
## The camera moves between the Marker3D nodes under [code]Shots[/code].
##
## Record it with Godot's Movie Maker, which renders at a fixed frame rate:
##
## [codeblock]
## godot --path . --write-movie /tmp/anima_3d.avi --fixed-fps 60 \
##       res://examples/showcase/3d/showcase_3d.tscn
## [/codeblock]
##
## Keep the Godot window visible while recording: macOS stops redrawing a
## hidden window and Movie Maker then repeats the last frame. The scene quits
## by itself at the end when Movie Maker is recording.
class_name Showcase3D
extends Node3D

## Emitted once the whole storyboard, outro hold included, has played.
signal show_finished

@export_multiline var hook_text := "Stop hand-writing Tweens."
@export_multiline var presets_text := "Every Anima preset, now in 3D"
@export_multiline var grid_text := "One call. 25 cubes."
## Seconds each camera move between shots takes.
@export var camera_move_duration := 1.0
## Seconds the outro stays on screen before the show ends.
@export var outro_hold := 2.4

## Code panel colours.
const CODE_TEXT := "cbd5e1"
const CODE_CLASS := "22d3ee"
const CODE_METHOD := "fbbf24"
const CODE_STRING := "86efac"
const CODE_NUMBER := "c084fc"

@onready var _camera: Camera3D = %Camera
@onready var _trio_shot: Marker3D = %TrioShot
@onready var _grid_shot: Marker3D = %GridShot
@onready var _cube: Node3D = %Cube
@onready var _sphere: Node3D = %Sphere
@onready var _cylinder: Node3D = %Cylinder
@onready var _tiles: Node3D = %Tiles
@onready var _preset_label: Label3D = %PresetLabel
@onready var _trio_label_spot: Marker3D = %TrioLabelSpot
@onready var _headline: Label = %Headline
@onready var _code_panel: PanelContainer = %CodePanel
@onready var _code: RichTextLabel = %Code
@onready var _outro: Control = %Outro

var _playbacks: Array[AnimaPlayback] = []
var _code_highlighter := RegEx.create_from_string("(\"[^\"]*\")|([A-Z][a-zA-Z0-9]+)|\\.([a-z_]+)|(\\d+(?:\\.\\d+)?)")

func _ready() -> void:
	_code.text = ""
	await get_tree().process_frame
	_run_show()

func _exit_tree() -> void:
	for playback in _playbacks:
		if playback != null and playback.state == AnimaPlayback.State.PLAYING:
			playback.cancel()

## Plays the whole storyboard once. Called from [method _ready].
func _run_show() -> void:
	var cube := _cube
	var sphere := _sphere
	var cylinder := _cylinder
	var shapes: Array[Node3D] = [sphere, cube, cylinder]
	var tiles := _tiles

	# Act 1: one preset at a time on the cube.
	_headline_in(hook_text)
	_track(Anima.play(Anima.animation("fade_in"), _code_panel))

	await _show_code("Anima.play(Anima.animation(\"rubber_band\"), cube)")
	_set_preset_label("rubber_band")
	await _track(Anima.play(Anima.animation("rubber_band"), cube)).finished
	await _wait(0.2)

	await _show_code("Anima.play(Anima.animation(\"tada\"), cube)")
	_set_preset_label("tada")
	var tada := _track(Anima.play(Anima.animation("tada"), cube))
	await _wait(0.5)
	_headline_out()
	await tada.finished
	await _wait(0.2)

	# Act 2: the same presets on a group of shapes.
	_move_camera(_trio_shot)
	_preset_label.position = _trio_label_spot.position
	_headline_in(presets_text)
	_reveal([sphere, cylinder])

	await _show_code("Anima.group([sphere, cylinder]) \\\n    .with_item_motion(Anima.animation(\"bouncing_in\")).play()")
	_set_preset_label("bouncing_in")
	await _track(Anima.group([sphere, cylinder]).with_item_motion(Anima.animation("bouncing_in")).play()).finished
	await _wait(0.3)

	for preset in ["jello", "wobble", "bounce"]:
		await _show_code("Anima.group(shapes) \\\n    .with_item_motion(Anima.animation(\"%s\")).play()" % preset)
		_set_preset_label(preset)
		await _track(Anima.group(shapes).with_item_motion(Anima.animation(preset)).play()).finished
		await _wait(0.25)

	# Act 3: one grid call per wave across the 5×5 floor.
	_headline_out()
	# A Label3D's outline ignores modulate, so hide the label once it's out.
	_track(Anima.play(Anima.animation("zoom_out"), _preset_label)).finished.connect(func(_success: bool) -> void: _preset_label.hide())
	_track(Anima.group(shapes).with_item_motion(Anima.animation("zoom_out")).play())
	await _move_camera(_grid_shot).finished
	_headline_in(grid_text)
	_reveal(tiles.get_children())

	await _show_code("Anima.grid(tiles, Vector2i(5, 5)) \\\n    .with_item_motion(Anima.animation(\"bouncing_in\")).play()")
	await _track(Anima.grid(tiles, Vector2i(5, 5)).with_item_motion(Anima.animation("bouncing_in")).play()).finished
	await _wait(0.2)

	await _show_code("Anima.grid(tiles, Vector2i(5, 5)) \\\n    .with_item_motion(Anima.animation(\"bounce\")).play()")
	await _track(Anima.grid(tiles, Vector2i(5, 5)).with_item_motion(Anima.animation("bounce")).play()).finished
	await _wait(0.2)

	await _show_code("Anima.grid(tiles, Vector2i(5, 5)).spiral_out() \\\n    .with_item_motion(Anima.animation(\"rubber_band\")).play()")
	await _track(Anima.grid(tiles, Vector2i(5, 5)).spiral_out().with_item_motion(Anima.animation("rubber_band")).play()).finished
	await _wait(0.3)

	# Outro: logo and link.
	_headline_out()
	await _play_outro()
	await _wait(outro_hold)
	show_finished.emit()

	if OS.has_feature("movie"):
		get_tree().quit()

func _headline_in(text: String) -> void:
	_headline.text = text
	_track(Anima.play(Anima.animation("zoom_in"), _headline))

func _headline_out() -> void:
	_track(Anima.play(Anima.animation("fade_out"), _headline))

func _set_preset_label(text: String) -> void:
	_preset_label.text = text
	_preset_label.show()
	_track(Anima.play(Anima.animation("bouncing_in"), _preset_label))

## Shows hidden nodes fully transparent, so the preset that follows fades
## them in from its own first frame instead of popping them in first.
func _reveal(nodes: Array) -> void:
	for node in nodes:
		AnimaPlanarAccess.write(node, ^"modulate:a", 0.0, true)
		node.show()

## Types [param snippet] into the code panel and waits until it's fully shown.
func _show_code(snippet: String) -> void:
	_code.text = _highlight(snippet)
	# Counting the characters makes the label parse the new text now.
	# Otherwise the count can still be the old one and the snippet stays hidden.
	var characters := _code.get_total_character_count()
	_code.visible_characters = 0
	var duration := clampf(snippet.length() * 0.006, 0.25, 0.6)
	await _track(Anima.on(_code).property(^"visible_characters", characters, duration).from(0).play()).finished
	_code.visible_characters = -1

func _move_camera(shot: Marker3D) -> AnimaPlayback:
	return _track(Anima.on(_camera).property(^"transform", shot.transform, camera_move_duration) \
		.with_ease(AnimaEase.Kind.EASE_IN_OUT_CUBIC).play())

func _play_outro() -> void:
	_outro.show()
	_track(Anima.play(Anima.animation("fade_out"), _code_panel))
	_track(Anima.play(Anima.animation("fade_in"), %Dim))
	_track(Anima.play(Anima.animation("bouncing_in"), %Logo))
	await _wait(0.35)
	_track(Anima.play(Anima.animation("zoom_in"), %Tagline))
	await _wait(0.25)
	await _track(Anima.play(Anima.animation("zoom_in"), %Url)).finished

func _track(playback: AnimaPlayback) -> AnimaPlayback:
	_playbacks.append(playback)
	return playback

func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

## Turns a code snippet into BBCode: strings, class names, method names and
## numbers each get their own colour.
func _highlight(snippet: String) -> String:
	var result := "[color=#%s]" % CODE_TEXT
	var cursor := 0
	for found in _code_highlighter.search_all(snippet):
		result += _escape(snippet.substr(cursor, found.get_start() - cursor))
		if found.get_string(1) != "":
			result += "[color=#%s]%s[/color]" % [CODE_STRING, found.get_string(1)]
		elif found.get_string(2) != "":
			result += "[color=#%s]%s[/color]" % [CODE_CLASS, found.get_string(2)]
		elif found.get_string(3) != "":
			result += ".[color=#%s]%s[/color]" % [CODE_METHOD, found.get_string(3)]
		else:
			result += "[color=#%s]%s[/color]" % [CODE_NUMBER, found.get_string(4)]
		cursor = found.get_end()
	result += _escape(snippet.substr(cursor))
	return result + "[/color]"

func _escape(text: String) -> String:
	return text.replace("[", "[lb]")
