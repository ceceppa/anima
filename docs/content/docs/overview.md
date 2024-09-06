---
weight: 100
title: "Overview"
description: ""
icon: "article"
date: "2024-09-04T15:08:29+01:00"
lastmod: "2024-09-04T15:08:29+01:00"
draft: false
toc: true
---

Anima makes animation accessible to everyone, regardless of skill level. With just a few lines of code and simple syntax, you can effortlessly create sequential and parallel animations. Choose from our extensive library of 89 animations and 33 easing functions, or customize your own to match your vision.

## Classes

Anima provides a set of classes that allow you to animate nodes in a simple and intuitive way.
Here is a list of the available:

- [Anima.Node](/docs/anima/anima-node/): A utility class that provides a simple way to animate a single node
- [Anima.Nodes](/docs/anima/anima-nodes/): A utility class that provides a simple way to animate multiple nodes
- [Anima.Group](/docs/anima/anima-group/): A utility class that provides a simple way to animate children nodes of a parent node in a group layout
- [Anima.Grid](/docs/anima/anima-grid/): A utility class that provides a simple way to animate children nodes of a parent node in a grid layout

## Example

### Single node

```gdscript
(
  Anima.Node(self)
  .anima_animation("tada", 0.7)
  .play()
)
```

### Multiple nodes

```gdscript
(
  Anima.Nodes([self, $Button, $AnotherNode], 0.1)
  .anima_animation("fadeIn", 0.5)
  .play()
)
```

### Group layout

```gdscript
(
  Anima.Group(self, 0.05)
  .anima_animation("fadeIn", 0.5)
  .play()
)
```

### Grid layout

```gdscript
(
  Anima.Grid(self, 0.2)
  .anima_animation("fadeIn", 0.5)
  .play()
)
```

## Live demo

Do you want to give it a try? Here is a live demo with some examples: [https://ceceppa.me/anima-demo](https://ceceppa.me/anima-demo)

