---
sidebar_position: 2
---

# `begin` vs `begin_single_shot`

Anima offers built-in methods to add an AnimaNode programmatically to the scene:

- [begin](/docs/anima/#begin)
- [begin_single_shot](/docs/anima/#begin_single_shot)

When invoked, both methods append an AnimaNode to the node specified and:

- `begin` does not free the node once the animation is played, so it will stay in the scene and use memory
- `begin_single_shot` frees the node once the animation is played

## When to use `begin` or `begin_single_shot`

### `begin`

This method should be used when:

1. we need to initialised the animation on `_ready` (see [Understanding the current value](/docs/tutorial-basics/fundamentals))
2. we want to animate a node out using the same animation but played backwards
3. we want to animate an animation in loop

### `begin_single_shot`

This method should be use when:

1. When the current value needs to be used as initial values (see [Understanding the current value](/docs/tutorial-basics/fundamentals))
2. We want to free memory once the animation completes
