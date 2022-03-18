---
sidebar_position: 3
---

# Multiple animations

Both [begin](/docs/anima/#begin) and [beging_single_shot](/docs/anima/#begin_single_shot) accept an animation name as second parameter:

```gdscript
begin(node: Node, animation_name = 'Anima', is_single_shot := false) -> AnimaNode:
begin_single_shot(node: Node, animation_name = 'Anima') -> AnimaNode:
```

Ths `animation_name` parameter is used by Anima to see if an [AnimaNode](/docs/anima-node/) with that name already exists;
and if so, reuse it; otherwise, create a new one.

:::caution

Any time Anima finds an AnimaNode, after calling `begin` or `begin_single_shot`, it will automatically stop and clear any animation attached.
:::

## When to use a custom animation name?

Generally, we want to reuse a single AnimaNode without the need of adding several AnimaNode to the scene.
But there might be cases when we want to play unrelated animations that could co-occur, for example:

```gdscript
func set_position(position: Vector2, default := false) -> void:
   animate_param("position", position)

func set_size(size: Vector2, default := false) -> void:
   animate_param("size", size)

func set_scale(scale: Vector2, default := false) -> void:
   animate_param("scale", scale)

func animate_param(property: String, value, from = null) -> void:
    Anima.begin_single_shot(self, property) `
        then( Anima.Node(self).anima_property(property, value, 0.3).anima_from(from) ) `
        .play()
```

This code is part of the Animatable component.

As we can see, it allows us to animate the control's position, size and scale from another script when setting one of those properties.
The problem here is we have no control over how and when these methods will be called.
We might call one or more methods simultaneously or with a delay.
We have no control over this, and we can't use a single AnimaNode, as we could risk interrupting an ongoing animation to animate another property.

So, using different animation names will create their AnimaNode, but will reuse the same one if we try to animate the same property.
