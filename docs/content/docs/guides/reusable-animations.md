---
weight: 100
title: "Reusable vs Single Shot"
description: ""
icon: "developer_guide"
draft: false
---


By default, Anima animations are configured as 'single-shot,' meaning the animated node is automatically removed from the scene once the animation completes.
However, if you're working with a looping animation, the node will remain in the scene even after the animation has looped indefinitely.
You're also able to force a reusable animation by using `as_reusable` method.

## When to use  reusable vs single shot

### `as_reusable`

This method should be used when:

1. we need to initialised the animation on `_ready` (see [Understanding the current value](/docs/tutorial/basics/fundamentals))
2. we want to animate a node out using the same animation but played backwards
3. we want to animate an animation in loop

### Single Shot

This method is useful when:

1. When the current value needs to be used as initial values (see [Understanding the current value](/docs/tutorial/basics/fundamentals))
2. We want to free memory once the animation completes
