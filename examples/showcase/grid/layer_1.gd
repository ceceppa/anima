## Scene 1's Inventory Hook layer. The tile grid itself is owned entirely by
## the `%InventoryGrid` component (`inventory_grid.gd`) instanced inside
## `%InventoryContent` — this script has nothing left to drive for it.
class_name InventoryHookLayer
extends Control

func _ready() -> void:
	play()

func play() -> void:
	await get_tree().create_timer(0.1).timeout
	
	#%Banner.hide()
	%Scrim.hide()

	%InventoryGrid.play()
	
