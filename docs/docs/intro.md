---
sidebar_position: 1
---
# Introduction

We believe that creating animations should be accessible to people of all skill levels. That's why we developed Anima – to make it easy for you to create beautiful, dynamic animations with just a few lines of code and a simple syntax. With 89 built-in animations and 36 easing functions to choose from, plus the ability to add your own custom animations, Anima has everything you need to bring your projects to life. So why wait? Start creating stunning animations with Anima today!

![Anima 3D Boxes demo](/img/anima.gif)

## Installation

The plugin is available on the [Asset Library](https://godotengine.org/asset-library/asset/852).

### Manual Download

The latest version can be manually downloaded by cloning [this repo](https://github.com/ceceppa/anima) and copying the contents of `addons/anima` into the same folder in your project.

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

## Demo

Are you curious to see the kinds of animations you can easily create with Anima? Check out these examples and get inspired to bring your projects to life! [https://anima.ceceppa.me/demo](https://anima.ceceppa.me/demo)
