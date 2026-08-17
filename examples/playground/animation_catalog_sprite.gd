## A Sprite2D with a synthetic `size` property, so a preset whose dynamic
## offset reads `size:x`/`size:y` (Godot's `Control.size`, the convention
## every ported catalog preset assumes — tech-spec.md §Animation catalog)
## still resolves correctly when that preset's secondary copy plays on this
## Sprite2D target in the Animation Catalog Playground's "Both" mode
## (story-1c). Sprite2D has no native `size`; without this, `AnimaValue
## .target(^"size:x")` would resolve to `null` and error during arithmetic.
## Read-only: no preset ever writes to `size`, only reads it.
class_name AnimationCatalogSprite
extends Sprite2D

var size: Vector2:
	get:
		if texture == null:
			return Vector2.ZERO
		return texture.get_size()
