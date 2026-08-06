## Fills its own bounds with as many whole clones of the authored [member
## _tile] template as actually fit, each centred, spaced at least
## [member min_gap] apart — and gives each tile a matching icon loaded from
## `assets/icons/`, sized to at most [member max_icon_ratio] of the tile
## (`project-rules.md` §Example Scenes' auto-fit tile grid). Each icon is a
## child of its own tile, centred within it — [method play] targets the
## tracked [member _icon_nodes] directly rather than relying on a shared
## parent layer, so the icons still animate independently of the
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

## Every tile currently in the grid, including the original authored
## [member _tile] (always kept as the first entry, never freed).
var _tiles: Array[Sprite2D] = []
## Every icon currently placed, one per tile, in the same order as
## [member _tiles] — each parented under its own matching tile, centred
## within it.
var _icon_nodes: Array[Sprite2D] = []
## The fitted grid's own column/row count, resolved by the last
## [method _build_tile_grid] — [member _icon_nodes] fills this shape in the
## same row-major order [AnimaGridMotion.grid_dimensions] expects.
var _columns: int = 0
var _rows: int = 0

func _ready() -> void:
	_build_tile_grid()
	
	if get_parent() is Window:
		play()

## Rebuilds the tile grid from scratch: clears any previously duplicated
## tiles and icons, computes how many whole tiles fit along each axis, places
## every tile at its resolved position first, then gives each one its own
## centred icon in a second pass — duplicating tiles before any icon exists
## keeps a duplicated tile from also duplicating tile 0's icon as a child.
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
	_icon_nodes.clear()

	if columns <= 0 or rows <= 0:
		_tile.visible = false
		return

	_tile.visible = true
	var origin := _grid_origin(container_size, tile_size, columns, rows, min_gap)
	for row in rows:
		for col in columns:
			var index := row * columns + col
			var tile: Sprite2D = _tile if index == 0 else _tile.duplicate()
			if index > 0:
				%Tiles.add_child(tile)
			tile.visible = true
			tile.position = origin + Vector2(col, row) * (tile_size + Vector2(min_gap, min_gap)) + tile_size / 2.0
			tile.modulate.a = 0.0
			_tiles.append(tile)

	var icon_paths := _discover_icon_paths()
	for index in _tiles.size():
		var icon = _build_icon(_tiles[index], tile_size, icon_paths, index)
		
		_icon_nodes.append(icon)

## Creates one icon as a child of [param tile], centred within it — a plain
## [Sprite2D] at local [constant Vector2.ZERO] already renders centred on its
## parent's own origin, since both this component's tiles and every icon
## keep [member Sprite2D.centered]'s default of `true`. Shows one of [param
## icon_paths], scaled to at most [member max_icon_ratio] of [param
## tile_size] (the tile's own world-space size) while preserving its own
## aspect ratio — divided by [param tile]'s own [member Node2D.scale] since
## the icon's [member Node2D.scale] is now in the tile's local space, not
## world space, and would otherwise compound with it. Starts at full opacity
## — [method play] fades/pulses [param tile] itself, and Godot's own
## [member CanvasItem.modulate] cascades that to every child, this icon
## included, so the icon needs no reveal state of its own.
func _build_icon(tile: Sprite2D, tile_size: Vector2, icon_paths: Array, index: int) -> Sprite2D:
	var icon := Sprite2D.new()
	tile.add_child(icon)
	icon.position = Vector2.ZERO
	icon.texture = _icon_texture(icon_paths, index)
	icon.scale = _icon_scale(icon.texture, tile_size) / tile.scale
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

## One CSS `@keyframes pulse`-equivalent reveal, shared by every tile: fades
## in across the whole run while scale pulses up and back at the
## midpoint — a single [AnimaKeyframeMotion] rather than two separate
## motions, since `scale` and `opacity` are independent tracks evaluated
## against the same clock (`tech-spec.md` §Keyframe motions). Each tile's own
## icon child is carried along for free — Godot's own [member
## CanvasItem.modulate]/transform inheritance means animating the tile
## already fades and scales its icon with it, no second motion needed.
const _ITEM_DURATION := 0.3

## Plays a grid-driven reveal on the tiles — icon and frame together, since
## every icon is now a child of its own tile. Built on [method Anima.grid]:
## [method AnimaGridMotionFactory.keyframes] parses the same CSS `@keyframes
## pulse`-equivalent shape [member _ITEM_DURATION] describes — fading in
## across the whole run while scale pulses up and back at the midpoint —
## and [method AnimaGridMotionFactory.with_duration]/[method
## AnimaGridMotionFactory.with_ease] configure it in place
## (`tech-spec.md` §Grid convenience shorthand). Each tile's own current
## scale drives both the resting and peak keyframe values through
## [AnimaValue] — resolved independently per tile by the grid's own per-item
## context (`tech-spec.md` §Dynamic values). Every tile — the original
## template and every duplicate [method _build_tile_grid] adds — ends up a
## direct child of `%Tiles`, so [method Anima.grid]'s own [code]CHILDREN[/code]
## default resolves exactly the tile set with no override needed, back to a
## single fluent statement.
func play() -> AnimaPlayback:
	return Anima.grid(%Tiles) \
		.with_dimensions(Vector2i(_columns, _rows)) \
		.with_distance_formula(AnimaGridMotion.DistanceFormula.EUCLIDEAN) \
		.with_start_point(Vector2i(_columns / 2, _rows / 2)) \
		.with_stagger_interval(0.05) \
		.keyframes({
			"from": {"opacity": 0.0, "scale": AnimaValue.target(NodePath("scale"))},
			50: {"scale": AnimaValue.target(NodePath("scale")).add(Vector2(0.25, 0.25))},
			"to": {"opacity": 1.0, "scale": AnimaValue.target(NodePath("scale"))},
		}, _ITEM_DURATION) \
		.with_ease(AnimaEase.Kind.EASE_IN_OUT) \
		.play()
