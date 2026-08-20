extends ExamplePlayground

## Entry point for the example playground (ux-flow.md §Demo Selector):
## groups the existing playground demos into 2D and 3D categories and opens
## whichever one the user picks. Ships no new demo content — only navigation
## to what already exists.

enum Category { TWO_D, THREE_D }

const CATEGORY_LABELS := {
	Category.TWO_D: "2D",
	Category.THREE_D: "3D",
}

## title / description / icon / scene path per demo, grouped by category —
## design-brief.md §Screen composition "phase-20 — Demo Selector".
const DEMOS := {
	Category.TWO_D: [
		{
			"title": "Composition",
			"description": "Sequence, Parallel, Stagger, Repeat, Race, Conditional.",
			"icon": "✦",
			"scene": "res://examples/playground/composition_playground.tscn",
		},
		{
			"title": "Group Motion",
			"description": "Playback mode and ordering across a card collection.",
			"icon": "◫",
			"scene": "res://examples/playground/group_motion_playground.tscn",
		},
		{
			"title": "Convenience Motion",
			"description": "Anima.on() families with a live code example.",
			"icon": "◆",
			"scene": "res://examples/playground/convenience_motion_playground.tscn",
		},
		{
			"title": "Grid Motion",
			"description": "Propagation formulas across a 5×5 card grid.",
			"icon": "▦",
			"scene": "res://examples/playground/grid_motion_playground.tscn",
		},
		{
			"title": "Animation Catalog",
			"description": "Every ported preset, browsable by category.",
			"icon": "☰",
			"scene": "res://examples/playground/animation_catalog_playground.tscn",
		},
	],
	Category.THREE_D: [
		{
			"title": "3D Motion",
			"description": "Anima.on() families for a 3D target.",
			"icon": "◈",
			"scene": "res://examples/playground/3d_motion_playground.tscn",
		},
	],
}

@onready var _selector: SelectorDock = %CategorySelector
@onready var _demo_grid: HFlowContainer = %DemoGrid
@onready var _info_label: Label = %InfoLabel

var _category_order: Array = []

func _ready() -> void:
	super._ready()

	for category in Category.values():
		var button: SelectorButton = preload("res://examples/playground/shared/components/selector_button.tscn").instantiate()
		button.text = CATEGORY_LABELS[category]
		button.pressed.connect(_select_category.bind(category))
		_selector.add_item(button)
		_category_order.append(category)

	_info_label.text = "Choose a demo to open it."

	await get_tree().process_frame

	_select_category(Category.TWO_D)

func _select_category(category: int) -> void:
	_selector.select(_category_order.find(category))
	_populate_grid(category)

func _populate_grid(category: int) -> void:
	for child in _demo_grid.get_children():
		_demo_grid.remove_child(child)
		child.free()

	for demo in DEMOS[category]:
		var card: DemoCard = preload("res://examples/playground/shared/components/demo_card.tscn").instantiate()
		card.title = demo["title"]
		card.description = demo["description"]
		card.icon_glyph = demo["icon"]
		card.pressed.connect(_open_demo.bind(demo["scene"]))
		_demo_grid.add_child(card)

func _open_demo(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
