---
sidebar_position: 1
---

# Introduction

We believe that creating animation should be easy for any skill level; that's why we created Anima.

It allows you to run sequential and parallel animations with few lines of code and simple syntax.
You can pick any of the 89 animations and 33 easings or add your own.

![Anima 3D Boxes demo](/img/anima.gif)

## Installation

The plugin is available on the [Asset Library](https://godotengine.org/asset-library/asset/852).

### Manual Download

The latest version can be manually downloaded by cloning [this repo](https://github.com/ceceppa/anima) and copying the contents of `addons/anima` into the same folder in your project.

## Custom nodes

Anima provides those two additional nodes:

- [AnimaNode](/docs/animate-node), used to handle the setup of all the animations supported by the addon
- [AnimaTween](/docs/anima-tween), is the custom Tween used that allows the magic to happen :)

## Animation Declaration

Animation declarations are used to tell anima how to animate a single node, group or grid:

- [AnimaDeclarationNode](/docs/anima-declaration)

## Example

```gdscript
Anima.begin(self) \
  .then(
    Anima.Node($node) \
      .anima_animation("tada", 0.7)
  ).play()
```

**NOTE** in Godot 4.0 you'll be able to wrap everything in parenthesis to avoid repeating "[variable].":

```gdscript
# Works on Godot 4.0 only:

var anima = (
  Anima.begin(self)
  .then(Anima.Node($node).anima_animation("tada", 0.7))
).play()
```

## Live demo

Do you want to give it a try? Here is a live demo with some examples: [https://anima.ceceppa.me/demo](https://anima.ceceppa.me/demo)
