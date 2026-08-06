extends "res://addons/gut/test.gd"

## Wraps `InventoryGrid` (full-rect anchored, meant to fill `%InventoryContent`
## in the real scene) in a fixed-size, non-anchored parent so its resolved
## size is deterministic in a bare test tree.
func _make_grid(container_size: Vector2 = Vector2(600.0, 600.0)) -> Control:
	var wrapper := Control.new()
	wrapper.size = container_size
	add_child_autofree(wrapper)
	var grid: Control = preload("res://examples/showcase/grid/inventory_grid.tscn").instantiate()
	wrapper.add_child(grid)
	return grid

func test_fit_count_fits_whole_tiles_with_the_minimum_gap_and_never_clips():
	# 5 tiles of 100 with 10 gap: 5*100 + 4*10 = 540, fits in 540 exactly.
	assert_eq(InventoryGrid._fit_count(540.0, 100.0, 10.0), 5)
	# One unit short of what 5 tiles need (540) — must floor down to 4, not round up to 5.
	assert_eq(InventoryGrid._fit_count(539.0, 100.0, 10.0), 4)
	# A container that doesn't divide evenly at all.
	assert_eq(InventoryGrid._fit_count(250.0, 60.0, 8.0), 3) # 3*60+2*8=196 fits; 4*60+3*8=264 doesn't
	# Too small for even one tile.
	assert_eq(InventoryGrid._fit_count(50.0, 100.0, 10.0), 0)

func test_grid_origin_centres_the_block_with_equal_leftover_on_both_sides():
	var origin: Vector2 = InventoryGrid._grid_origin(Vector2(540.0, 540.0), Vector2(100.0, 100.0), 5, 5, 10.0)
	assert_almost_eq(origin.x, 0.0, 0.01, "an exact fit should leave zero leftover")
	assert_almost_eq(origin.y, 0.0, 0.01)

	# A container that doesn't divide evenly should still centre the used block.
	var uneven: Vector2 = InventoryGrid._grid_origin(Vector2(250.0, 250.0), Vector2(60.0, 60.0), 3, 3, 8.0)
	var used := 3 * 60.0 + 2 * 8.0 # 196
	var expected := (250.0 - used) / 2.0 # 27
	assert_almost_eq(uneven.x, expected, 0.01)
	assert_almost_eq(uneven.y, expected, 0.01)

func test_inventory_grid_fills_its_own_bounds_with_centred_whole_tiles():
	var grid := _make_grid()
	await get_tree().process_frame

	var tile: Sprite2D = grid.get_node("%Tile")
	var tile_size: Vector2 = tile.get_rect().size * tile.scale

	var tiles: Array = grid.get("_tiles")
	assert_gt(tiles.size(), 0, "sanity: a 600x600 area should fit at least one tile")

	for placed_tile in tiles:
		assert_true(placed_tile.visible, "every placed tile should be visible")
		var top_left: Vector2 = placed_tile.position - tile_size / 2.0
		assert_true(top_left.x >= -0.01, "no tile should start before the container's left edge")
		assert_true(top_left.y >= -0.01, "no tile should start before the container's top edge")
		assert_true(top_left.x + tile_size.x <= grid.size.x + 0.01, "no tile should be cut off at the container's right edge")
		assert_true(top_left.y + tile_size.y <= grid.size.y + 0.01, "no tile should be cut off at the container's bottom edge")

func test_increasing_min_gap_reduces_how_many_tiles_fit_and_rebuilds_live():
	var grid := _make_grid()
	await get_tree().process_frame

	var initial_count: int = grid.get("_tiles").size()
	grid.min_gap = 400.0 # deliberately huge, so far fewer tiles fit
	var reduced_count: int = grid.get("_tiles").size()

	assert_lt(reduced_count, initial_count, "a much larger minimum gap should visibly reduce how many tiles fit")

func test_a_container_too_small_for_even_one_tile_places_no_tiles():
	var grid := _make_grid(Vector2(1.0, 1.0)) # smaller than any real tile
	await get_tree().process_frame

	var tiles: Array = grid.get("_tiles")
	assert_eq(tiles.size(), 0, "no tiles should be placed when the container can't fit even one")
	assert_false(grid.get_node("%Tile").visible, "the template tile itself should also be hidden, not left dangling on screen")

func test_every_tile_has_a_matching_icon_under_icons_no_larger_than_the_configured_ratio():
	var grid := _make_grid()
	await get_tree().process_frame

	var tile: Sprite2D = grid.get_node("%Tile")
	var tile_size: Vector2 = tile.get_rect().size * tile.scale
	var tiles: Array = grid.get("_tiles")
	var icons: Array = grid.get("_icon_nodes")
	var icons_node: Node = grid.get_node("%Icons")
	assert_gt(tiles.size(), 0, "sanity: at least one tile should be placed")
	assert_eq(icons.size(), tiles.size(), "there should be exactly one icon per tile")

	for i in tiles.size():
		var placed_tile: Sprite2D = tiles[i]
		var icon: Sprite2D = icons[i]
		assert_eq(icon.get_parent(), icons_node, "an icon should be a child of %Icons, not of its tile — so Anima.grid($Icons) can animate the icon layer independently")
		assert_not_null(icon.texture, "the icon should always have a real texture (real icon or placeholder)")
		assert_almost_eq(icon.position.x, placed_tile.position.x, 0.01, "the icon should sit at the same position as its matching tile")
		assert_almost_eq(icon.position.y, placed_tile.position.y, 0.01, "the icon should sit at the same position as its matching tile")

		var native: Vector2 = icon.texture.get_size()
		var visible_size: Vector2 = native * icon.scale
		assert_true(visible_size.x <= tile_size.x * grid.max_icon_ratio + 0.5, "the icon's width should never exceed the configured ratio of its tile")
		assert_true(visible_size.y <= tile_size.y * grid.max_icon_ratio + 0.5, "the icon's height should never exceed the configured ratio of its tile")

func test_lowering_max_icon_ratio_visibly_shrinks_every_icon():
	var grid := _make_grid()
	await get_tree().process_frame

	var first_icon: Sprite2D = grid.get("_icon_nodes")[0]
	var initial_scale: Vector2 = first_icon.scale

	grid.max_icon_ratio = 0.2 # much smaller than the default 0.8
	var shrunk_icon: Sprite2D = grid.get("_icon_nodes")[0]

	assert_lt(shrunk_icon.scale.x, initial_scale.x, "lowering the maximum icon ratio should visibly shrink the icon")

func test_missing_icon_assets_still_render_using_the_established_placeholder():
	var grid := _make_grid()
	await get_tree().process_frame

	# _discover_icon_paths() reads the real assets/icons/ folder (which has
	# real icons today); simulate an empty folder by asking directly for the
	# placeholder path, confirming it never errors and always returns a texture.
	var placeholder: Texture2D = grid._icon_texture([], 0)
	assert_not_null(placeholder, "an empty icon set should still produce a real, visible placeholder texture")

## Regression: %Icons used to be a plain Node. A Sprite2D only inherits its
## ancestors' 2D transform through a chain of CanvasItem parents, so a
## plain-Node ancestor made every icon render relative to the viewport
## instead of to InventoryGrid's own (possibly scaled/offset) position —
## invisible testing InventoryGrid alone, obvious once nested inside
## layer_1's scaled InventoryFrame. Wrapping in a scaled, offset Node2D
## reproduces that real nesting.
func test_icons_track_their_tiles_even_under_a_scaled_offset_ancestor():
	var ancestor := Node2D.new()
	ancestor.position = Vector2(200.0, 150.0)
	ancestor.scale = Vector2(2.5, 2.5)
	add_child_autofree(ancestor)

	var wrapper := Control.new()
	wrapper.size = Vector2(600.0, 600.0)
	ancestor.add_child(wrapper)

	var grid: Control = preload("res://examples/showcase/grid/inventory_grid.tscn").instantiate()
	wrapper.add_child(grid)
	await get_tree().process_frame

	var tiles: Array = grid.get("_tiles")
	var icons: Array = grid.get("_icon_nodes")
	assert_gt(tiles.size(), 0, "sanity: at least one tile should be placed")

	for i in tiles.size():
		var tile: Sprite2D = tiles[i]
		var icon: Sprite2D = icons[i]
		var tile_global: Vector2 = tile.global_position
		var icon_global: Vector2 = icon.global_position
		assert_almost_eq(icon_global.x, tile_global.x, 0.5, "an icon's world position should track its tile even under a scaled/offset ancestor")
		assert_almost_eq(icon_global.y, tile_global.y, 0.5, "an icon's world position should track its tile even under a scaled/offset ancestor")
		# Sanity: the ancestor's transform should have actually moved the icon
		# away from its own raw local (pre-transform) position — proves
		# inheritance is real, not accidentally skipped (the exact bug this
		# test guards against).
		assert_true(icon_global.distance_to(icon.position) > 50.0, "sanity: the icon's world position should differ meaningfully from its untransformed local position")

func test_play_reveals_every_icon_via_a_grid_motion_without_touching_the_tiles():
	var grid := _make_grid()
	await get_tree().process_frame

	var icons: Array = grid.get("_icon_nodes")
	var tiles: Array = grid.get("_tiles")
	assert_gt(icons.size(), 0, "sanity: at least one icon should be placed")
	for icon in icons:
		assert_almost_eq(icon.modulate.a, 0.0, 0.01, "sanity: icons should start hidden before play() reveals them")

	var playback: AnimaPlayback = grid.play()
	assert_not_null(playback, "play() should return a real AnimaPlayback")
	for i in range(60): # 1s — comfortably covers the grid's own stagger + fade
		playback._advance(1.0 / 60.0)

	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	for icon in icons:
		assert_almost_eq(icon.modulate.a, 1.0, 0.01, "every icon should be fully revealed once the grid motion finishes")
	for tile in tiles:
		assert_almost_eq(tile.modulate.a, 1.0, 0.01, "the tile frames themselves should be untouched by play() — only the icon layer animates")

## Verifies the CSS `@keyframes pulse`-equivalent shape itself (scale up and
## back), not just the final revealed state — a final-state-only check can't
## tell a pulse apart from a motion that never scaled at all. Two icons are
## given deliberately different resting scales, so a regression back to
## Phase 13's shared-literal-scale workaround (every icon snapping to the
## same peak/rest value regardless of its own fitted size) would fail this
## test even though a single-icon check couldn't tell the difference.
func test_play_pulses_every_icons_scale_relative_to_its_own_resting_scale():
	var grid := _make_grid()
	await get_tree().process_frame

	var icons: Array = grid.get("_icon_nodes")
	assert_gt(icons.size(), 1, "sanity: at least two icons are needed to prove per-icon, not shared, scaling")
	icons[0].scale = Vector2(0.4, 0.4)
	icons[1].scale = Vector2(0.8, 0.8)

	var playback: AnimaPlayback = grid.play()

	var peak_x: Array = [0.0, 0.0]
	for i in range(60): # 1s — comfortably covers the grid's own stagger + fade
		playback._advance(1.0 / 60.0)
		peak_x[0] = maxf(peak_x[0], icons[0].scale.x)
		peak_x[1] = maxf(peak_x[1], icons[1].scale.x)

	assert_almost_eq(peak_x[0], 0.4 + 0.15, 0.01, "an icon should peak 0.15 above its own resting scale")
	assert_almost_eq(peak_x[1], 0.8 + 0.15, 0.01, "a differently-sized icon should peak 0.15 above its own resting scale, not another icon's")
	assert_eq(playback.state, AnimaPlayback.State.FINISHED)
	assert_almost_eq(icons[0].scale.x, 0.4, 0.01, "an icon should settle back to its own resting scale, not a shared literal")
	assert_almost_eq(icons[1].scale.x, 0.8, 0.01, "a differently-sized icon should settle back to its own resting scale, not a shared literal")
