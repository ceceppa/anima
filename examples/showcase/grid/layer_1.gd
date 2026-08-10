## Scene 1's Inventory Hook layer. The tile grid itself is owned entirely by
## the `%InventoryGrid` component (`inventory_grid.gd`) instanced inside
## `%InventoryContent` — this script has nothing left to drive for it.
##
## [method play] is not auto-called from [method Node._ready] — the parent
## showcase orchestrator (`grid_showcase.gd`) calls it explicitly when Scene
## 1's beat starts, the same way it drives every other scene, and awaits the
## returned [AnimaPlayback]'s [signal AnimaPlayback.finished] before moving on
## (`_mano_output/phase-14/stories/story-7g-await-driven-scene-sequencing.md`).
class_name InventoryHookLayer
extends Control

func play() -> AnimaPlayback:
	return %InventoryGrid.play()
