class_name SelectorDock
extends PanelContainer

const INDICATOR_BG := Color(0.309804, 0.27451, 0.898039, 1.0) # accent
const INDICATOR_RADIUS := 12
const MOVE_DURATION := 0.26

## [HFlowContainer] (horizontal, wrapping) in the default `selector_dock.tscn`,
## or [VBoxContainer] in `selector_dock_vertical.tscn` — the indicator
## geometry below only ever reads a child's actual laid-out rect, so either
## orientation works with no script changes (project-rules.md §Selector
## Orientation).
@onready var _items_box: Container = %Items

## The indicator's logical target, updated synchronously on every select() —
## independent of how far the animated (tweened) visual has actually moved,
## so callers (and tests) can always read where the indicator is headed.
var indicator_target_position := Vector2.ZERO
var indicator_target_size := Vector2.ZERO
var _is_first_time := true

var _indicator_position := Vector2.ZERO:
	set(value):
		_indicator_position = value
		queue_redraw()
var _indicator_size := Vector2.ZERO:
	set(value):
		_indicator_size = value
		queue_redraw()

var _indicator_tween: Tween
var selected_index := -1

func _ready() -> void:
	var dock_style := StyleBoxFlat.new()
	dock_style.bg_color = Color(0.0705882, 0.0941176, 0.14902, 0.85)
	dock_style.border_width_left = 1
	dock_style.border_width_top = 1
	dock_style.border_width_right = 1
	dock_style.border_width_bottom = 1
	dock_style.border_color = Color(0.117647, 0.160784, 0.231373, 1.0)
	dock_style.corner_radius_top_left = 16
	dock_style.corner_radius_top_right = 16
	dock_style.corner_radius_bottom_right = 16
	dock_style.corner_radius_bottom_left = 16
	dock_style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	dock_style.shadow_size = 8
	dock_style.content_margin_left = 6
	dock_style.content_margin_right = 6
	dock_style.content_margin_top = 6
	dock_style.content_margin_bottom = 6

	add_theme_stylebox_override("panel", dock_style)

## Drawn directly (rather than as a real child Control) so the sliding
## indicator can be freely positioned without fighting the HBoxContainer's
## own layout pass, which repositions every direct child it owns.
func _draw() -> void:
	if _indicator_size == Vector2.ZERO:
		return
	var style := StyleBoxFlat.new()
	style.bg_color = INDICATOR_BG
	style.corner_radius_top_left = INDICATOR_RADIUS
	style.corner_radius_top_right = INDICATOR_RADIUS
	style.corner_radius_bottom_right = INDICATOR_RADIUS
	style.corner_radius_bottom_left = INDICATOR_RADIUS
	style.shadow_color = Color(INDICATOR_BG.r, INDICATOR_BG.g, INDICATOR_BG.b, 0.3)
	style.shadow_size = 8
	draw_style_box(style, Rect2(_indicator_position, _indicator_size))

func add_item(button: SelectorButton) -> void:
	_items_box.add_child(button)

func get_item_count() -> int:
	return _items_box.get_child_count()

func get_item(index: int) -> SelectorButton:
	return _items_box.get_child(index)

## Removes every current item and resets the "first selection" state, so a
## caller that repopulates this dock with a new item set (the Animation
## Catalog Playground's grid does this per category) gets the same one-frame
## layout-settle wait [method select] already gives its actual first call —
## without this, a `select()` right after repopulating reads the new item's
## rect before the container's layout pass has placed it, and the indicator
## drifts to a stale position.
func clear_items() -> void:
	for i in range(_items_box.get_child_count() - 1, -1, -1):
		var item := _items_box.get_child(i)
		_items_box.remove_child(item)
		item.free()
	_is_first_time = true
	selected_index = -1
	_indicator_size = Vector2.ZERO

## Moves the shared indicator behind the SelectorButton at `index` and marks
## it (and only it) selected.
func select(index: int) -> void:
	if index < 0 or index >= _items_box.get_child_count():
		return

	if _is_first_time:
		await get_tree().process_frame

		_is_first_time = false

	selected_index = index
	for i in range(_items_box.get_child_count()):
		var button: SelectorButton = _items_box.get_child(i)
		button.set_selected(i == index)

	var rect := _rect_for_index(index)
	_move_indicator_to(rect.position, rect.size)

## Reads the target's actual laid-out rect, relative to this dock — correct
## across however many rows [member _items_box] (an [HFlowContainer], so a
## wide item set wraps) has actually placed it on. [method select]'s
## `_is_first_time` guard already awaits one frame before the first call
## here, so the container's sort pass has already run by the time this reads
## `position`/`size`; the item set never changes after that, so every later
## call reads an already-settled layout too.
func _rect_for_index(index: int) -> Rect2:
	var target: Control = _items_box.get_child(index)
	return Rect2(_items_box.position + target.position, target.size)

func _move_indicator_to(target_position: Vector2, target_size: Vector2) -> void:
	indicator_target_position = target_position
	indicator_target_size = target_size

	if _indicator_tween != null and _indicator_tween.is_valid():
		_indicator_tween.kill()

	if _indicator_size == Vector2.ZERO:
		# First selection — snap instead of animating in from a zero-size rect.
		_indicator_position = target_position
		_indicator_size = target_size
		return

	_indicator_tween = create_tween()
	_indicator_tween.set_parallel(true)
	_indicator_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_indicator_tween.tween_property(self, "_indicator_position", target_position, MOVE_DURATION)
	_indicator_tween.tween_property(self, "_indicator_size", target_size, MOVE_DURATION)
