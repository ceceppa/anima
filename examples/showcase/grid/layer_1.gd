## Scene 1's Inventory Hook layer. The tile grid itself is owned entirely by
## the `%InventoryGrid` component (`inventory_grid.gd`) instanced inside
## `%InventoryContent` — this script has nothing left to drive for it.
##
## [method play] is not auto-called from [method Node._ready] — the parent
## showcase orchestrator (`grid_showcase.gd`) calls it explicitly when Scene
## 1's beat starts, the same way it drives every other scene. Synchronous, no
## internal timer/await: the whole showcase is driven by manually-stepped
## deltas (`AnimaPlayback.step`/`_advance_show`) so a test can advance the
## entire ~15s sequence deterministically — an awaited real-time
## `SceneTreeTimer` here would never fire under that manual stepping.
class_name InventoryHookLayer
extends Control

func play() -> void:
	%InventoryGrid.play()
