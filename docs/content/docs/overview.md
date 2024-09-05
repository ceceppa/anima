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

## Custom nodes

Anima provides those two additional nodes:

- [AnimaNode](/docs/animate-node), used to handle the setup of all the animations supported by the addon
- [AnimaTween](/docs/anima-tween), is the custom Tween used that allows the magic to happen :)

## Animation Declaration

Animation declarations are used to tell anima how to animate a single node, group or grid:

- [AnimaDeclarationNode](/docs/anima-declaration)

## Example

```gdscript
var anima = (
  Anima.begin(self)
  .then(Anima.Node($node).anima_animation("tada", 0.7))
).play()
```

## Live demo

Do you want to give it a try? Here is a live demo with some examples: [https://ceceppa.me/anima-demo](https://ceceppa.me/anima-demo)

