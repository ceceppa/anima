## Fills its own bounds with as many whole clones of the authored [member
## _tile] template as actually fit, each centred, spaced at least
## [member min_gap] apart — and gives each tile position a matching icon
## loaded from `assets/icons/`, sized to at most [member max_icon_ratio] of
## the tile (`project-rules.md` §Example Scenes' auto-fit tile grid). Icons
## are children of [member _icons], siblings of the tiles rather than nested
## under them, specifically so an [AnimaGridMotion] played on [member _icons]
## (see [method play]) can animate the icon layer independently of the
## (non-animated) tile frames underneath.
class_name InventoryGrid
extends Control

const ICONS_DIR := "res://examples/showcase/grid/assets/icons"

## Minimum space kept between neighbouring tiles. Adjustable from the
## Inspector — rebuilds live so the change is visible immediately, the same
## reactive-export pattern `ExampleHeader.title` already uses.
@export var min_gap: float = 12.0:
	set(value):
		min_gap = value
		if is_node_ready():
			_build_tile_grid()

## The largest an icon is ever allowed to be, as a fraction of its own
## tile's size (`0.8` = at most 80%) — the icon keeps its own aspect ratio
## and is scaled down to fit within that box, never stretched or cropped.
## Adjustable from the Inspector — rebuilds live.
@export_range(0.0, 1.0, 0.01) var max_icon_ratio: float = 0.8:
	set(value):
		max_icon_ratio = value
		if is_node_ready():
			_build_tile_grid()

@onready var _tile: Sprite2D = %Tile
## Must stay a [Node2D] (or another [CanvasItem]), never a plain [Node] — a
## Sprite2D's 2D transform only inherits through a chain of CanvasItem
## parents, so a plain-Node ancestor here would make every icon render
## relative to the viewport instead of to this component's own (possibly
## scaled) position in the scene.
@onready var _icons: Node2D = %Icons

## Every tile currently in the grid, including the original authored
## [member _tile] (always kept as the first entry, never freed).
var _tiles: Array[Sprite2D] = []
## Every icon currently placed, one per tile, in the same order as
## [member _tiles] — parented under [member _icons], not under their
## matching tile.
var _icon_nodes: Array[Sprite2D] = []
## The fitted grid's own column/row count, resolved by the last
## [method _build_tile_grid] — [member _icons]' children fill this shape in
## the same row-major order [AnimaGridMotion.grid_dimensions] expects.
var _columns: int = 0
var _rows: int = 0

func _ready() -> void:
	_build_tile_grid()

## Rebuilds the tile grid from scratch: clears any previously duplicated
## tiles and icons, computes how many whole tiles fit along each axis, and
## places a tile plus a matching icon (parented under [member _icons], not
## the tile) at each resolved position, centred within this component's own
## bounds.
func _build_tile_grid() -> void:
	var tile_size: Vector2 = _tile.get_rect().size * _tile.scale
	var container_size: Vector2 = size
	var columns := _fit_count(container_size.x, tile_size.x, min_gap)
	var rows := _fit_count(container_size.y, tile_size.y, min_gap)
	_columns = columns
	_rows = rows

	for tile in _tiles:
		if tile != _tile and is_instance_valid(tile):
			tile.queue_free()
	_tiles.clear()
	for icon in _icon_nodes:
		if is_instance_valid(icon):
			icon.queue_free()
	_icon_nodes.clear()

	if columns <= 0 or rows <= 0:
		_tile.visible = false
		return

	_tile.visible = true
	var icon_paths := _discover_icon_paths()
	var origin := _grid_origin(container_size, tile_size, columns, rows, min_gap)
	for row in rows:
		for col in columns:
			var index := row * columns + col
			var tile: Sprite2D = _tile if index == 0 else _tile.duplicate()
			if index > 0:
				%Tiles.add_child(tile)
			tile.visible = true
			var center := origin + Vector2(col, row) * (tile_size + Vector2(min_gap, min_gap)) + tile_size / 2.0
			tile.position = center
			_tiles.append(tile)
			_icon_nodes.append(_build_icon(center, tile_size, icon_paths, index))

## Creates one icon under [member _icons] at [param center] (the same
## position its matching tile sits at), showing one of [param icon_paths],
## scaled to at most [member max_icon_ratio] of [param tile_size] while
## preserving its own aspect ratio. A sibling of every other icon, not a
## child of its tile — [member _icons] is the whole layer `Anima.grid()`
## animates independently of the (static) tile frames.
func _build_icon(center: Vector2, tile_size: Vector2, icon_paths: Array, index: int) -> Sprite2D:
	var icon := Sprite2D.new()
	_icons.add_child(icon)
	icon.position = center
	icon.texture = _icon_texture(icon_paths, index)
	icon.scale = _icon_scale(icon.texture, tile_size)
	icon.modulate.a = 0.0
	return icon

## The uniform scale that fits [param texture]'s native size inside
## [param tile_size] * [member max_icon_ratio] without stretching it.
func _icon_scale(texture: Texture2D, tile_size: Vector2) -> Vector2:
	var native: Vector2 = texture.get_size()
	if native.x <= 0.0 or native.y <= 0.0:
		return Vector2.ONE
	var max_size: Vector2 = tile_size * max_icon_ratio
	var factor: float = minf(max_size.x / native.x, max_size.y / native.y)
	return Vector2(factor, factor)

## Real icon file paths under `assets/icons/` — empty when the folder has
## none yet, so every tile falls back to the placeholder swatch instead of
## erroring (the folder's file count isn't known until the scene runs, the
## explicit runtime-count exception in `project-rules.md`'s asset-loading rule).
func _discover_icon_paths() -> Array:
	var paths: Array = []
	var dir := DirAccess.open(ICONS_DIR)
	if dir == null:
		return paths
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".svg")):
			paths.append(ICONS_DIR + "/" + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	paths.sort()
	return paths

func _icon_texture(icon_paths: Array, index: int) -> Texture2D:
	if icon_paths.is_empty():
		return _placeholder_texture()
	var path: String = icon_paths[index % icon_paths.size()]
	if ResourceLoader.exists(path):
		return load(path)
	return _placeholder_texture()

## A flat-colour placeholder texture — used whenever no icon asset is
## available yet, so a tile shows an obvious swatch instead of nothing.
func _placeholder_texture() -> ImageTexture:
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.788235, 0.635294, 0.152941, 0.9))
	return ImageTexture.create_from_image(image)

## Whole tiles of length [param tile] that fit along one axis of length
## [param container], with at least [param gap] between neighbours —
## `floor((container + gap) / (tile + gap))`, the standard "N items, N-1
## gaps" fit. Never negative; `0` when even one tile doesn't fit.
static func _fit_count(container: float, tile: float, gap: float) -> int:
	if tile <= 0.0:
		return 0
	return maxi(floori((container + gap) / (tile + gap)), 0)

## Top-left offset that centres a [param columns] x [param rows] block of
## [param tile]-sized cells (with [param gap] between them) inside [param
## container], with equal leftover space on opposite sides.
static func _grid_origin(container: Vector2, tile: Vector2, columns: int, rows: int, gap: float) -> Vector2:
	var used := Vector2(
		columns * tile.x + maxi(columns - 1, 0) * gap,
		rows * tile.y + maxi(rows - 1, 0) * gap,
	)
	return (container - used) / 2.0

## One CSS `@keyframes pulse`-equivalent reveal, shared by every icon: fades
## in across the whole run while scale pulses up 15% and back at the
## midpoint — a single [AnimaKeyframeMotion] rather than two separate
## motions, since `scale` and `opacity` are independent tracks evaluated
## against the same clock (`tech-spec.md` §Keyframe motions).
const _ITEM_DURATION := 0.3

## ⚠️ Known limitation, accepted deliberately for now: keyframes are
## literal-valued only today — there is no way yet to write "this target's
## own current scale" inside a keyframe declaration (the deferred
## `AnimaValue`/"Dynamic values inside keyframes" work, still unbuilt —
## phase-12 phase-brief.md's Not This Phase). Every icon's resting scale
## actually differs (fit to its own texture by [method _icon_scale]), but
## this one shared literal (`Vector2.ONE`) snaps every icon to the SAME
## scale for the pulse regardless of its own fitted size — the correct,
## intended shape once `AnimaValue` exists is `"scale": ":scale"` /
## `":scale*1.15"`-style dynamic references instead of these literals, so
## this stays [AnimaGridMotion]-driven (not a per-icon workaround) ready for
## that swap in a later phase.
func _build_item_motion() -> AnimaKeyframeMotion:
	var pulse := Motion.keyframes({
		"from": {"opacity": 0.0, "scale": Vector2.ONE},
		50: {"scale": Vector2(1.15, 1.15)},
		"to": {"opacity": 1.0, "scale": Vector2.ONE},
	}).with_duration(_ITEM_DURATION)
	pulse.default_ease = AnimaEase.new()
	pulse.default_ease.kind = AnimaEase.Kind.EASE_IN_OUT
	return pulse

## Plays a grid-driven reveal on the icon layer only — the (static) tile
## frames underneath are untouched, since [member _icons] is its own sibling
## layer built exactly for this (see the class doc comment above). There is
## no `Anima.grid(...)` convenience shorthand; a grid motion is an
## [AnimaGridMotion] resource played the same way any other motion is,
## through [method Anima.play] — the same pattern
## `examples/playground/grid_motion_playground.gd` already uses.
func play() -> AnimaPlayback:
	var collection := AnimaTargetCollection.new()
	collection.kind = AnimaTargetCollection.Kind.CHILDREN

	var grid := AnimaGridMotion.new()
	grid.target_collection = collection
	grid.grid_dimensions = Vector2i(_columns, _rows)
	grid.distance_formula = AnimaGridMotion.DistanceFormula.EUCLIDEAN
	grid.start_point = Vector2i(_columns / 2, _rows / 2)
	grid.item_motion = _build_item_motion()
	grid.distribution.stagger_interval = 0.05

	# CHILDREN resolves against whatever node the motion is actually played
	# on — _icons, not this component — so it picks up exactly the icon
	# Sprite2D nodes _build_tile_grid() added, in the same row-major order
	# grid_dimensions expects, and never touches the tile frames.
	return Anima.play(grid, _icons)
