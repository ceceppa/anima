---
weight: 400
title: "Animate relative values"
description: ""
icon: "developer_guide"
draft: false
---

Anima allows us to animate any property to an absolute or relative final value.
Positions can be animated to a relative one by using any of the built-in [anima_relative_position_*](/docs/anima-declaration/#anima_relative_position) helpers,
while for any other property we can use the [animate_as_relative](/docs/anima-declaration/#anima_as_relative) method.

The only thing to keep in mind is that 

## Example

```gdscript
Anima.begin_single_shot(true) \
  .then( Anima.Node(self).anima_scale_x(1.5).anima_as_relative() ) \
  .play()
```

This will increase the `scale:x` value of +1.5, from whatever the current value was at the time the animation was created.
