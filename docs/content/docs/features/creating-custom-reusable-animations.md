---
weight: 300
title: "Creating Custom Reusable Animations"
description: ""
icon: "article"
date: "2024-09-04T15:55:20+01:00"
lastmod: "2024-09-04T15:55:20+01:00"
draft: true
toc: true
---

Anima's CSS-like syntax makes it easy to create reusable animations that can be applied across your game with a few lines of code.

All the built-in animations take advantage of this feature, for example:

```gdscript
var KEYFRAMES := {
	[0, 100]: {
		scale = Vector3.ONE,
		"rotate:y" = 0,
	},
	[10, 20]: {
		scale = Vector3(0.9, 0.9, 0.9),
		"rotate:y" = -0.0523599
	},
	[30, 50, 70, 90]: {
		scale = Vector3(1.1, 1.1, 1.1),
		"rotate:y" = 0.0523599
	},
	[40, 60, 80]: {
		scale = Vector3(1.1, 1.1, 1.1),
		"rotate:y" = -0.0523599
	},
	"pivot": ANIMA.PIVOT.CENTER
}
```

