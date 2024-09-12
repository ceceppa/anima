---
weight: 200
title: "Built in Easings"
description: ""
icon: "article"
date: "2024-09-04T15:20:16+01:00"
lastmod: "2024-09-04T15:20:16+01:00"
draft: false
---

Anima provides about 33 easing functions that you can use to customize your animations.
Here's a list of the available easing functions:

## Usage

```gdscript
(
    Anima.Node(self)
    .anima_scale(Vector2.ONE, 0.7)
    .anima_from(Vector2.ZERO)
    .anima_easing(ANIMA.EASING.EASE_IN_OUT)
    .play()
)
```

## Built-in Easings

{{< easings >}}

## Custom Easings

Anima allows you create your own easing functions by specifying the easing points:

{{< custom-easing >}}

```gdscript
    Anima.Node(self)
    .anima_scale(Vector2.ONE, 0.7)
    .anima_from(Vector2.ZERO)
    .anima_easing([0.20, 0.20, 0.80, 0.80])
    .play()
```

