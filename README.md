# Anima

Anima is an add-on for the Godot game engine that simplifies the process of creating dynamic and impactful UI animations.

## Introduction

![Example of animation created with anima](https://media.githubusercontent.com/media/ceceppa/anima/main/docs/static/img/anima.gif)

Working with Godot's Tween to create UI animations can be quite challenging.
However, Anima, an add-on for Godot, simplifies the process by allowing you to create animations using a clear and concise syntax with just a few lines of code.
With 89 built-in animations and 33 easing options, Anima provides a vast array of options to choose from.
Moreover, you can easily add your animations using a syntax similar to CSS, making it a convenient tool for developers.

### Table of Contents

- Installation
- Documentation & Demo
- Differences between Anima and Godot Tween
- Stay in Touch
- Contribution
- License

## Installation

This is a regular editor plugin. Copy the contents of addons/Anima into the same folder in your project, and activate it in your project settings.

## Documentation & Demo

Check out [documentation]([https://anima.ceceppa.me](https://ceceppa.github.io/anima/)), [demo code](https://github.com/ceceppa/anima-demos) and [live examples](https://anima.ceceppa.me/demo).

## Differences between Anima and Godot Tween

|                                                | Anima                                                      | Tween         |
| ---------------------------------------------- | ---------------------------------------------------------- | ------------- |
| Chaining                                       | support for sequential, parallel and concurrent animations | Only Godot 4  |
| Easing                                         | 33 built-in, more can be added programmatically            | limited       |
| Use Curve as easing                            | yes                                                        | no            |
| Set Pivot point                                | yes (2D Only)                                              | no            |
| Create and reuse custom animations             | 89 built-in, more can be added programmatically            | No            |
| Animate elements in group or grids             | yes                                                        | No            |
| Multiple distance formulas for Grid animations | yes                                                        | no            |
| Loop                                           | Infinite, Times, and delayed loops                         | Infinite only |
| Animate relative values                        | yes                                                        | Only Godot 4  |
| Play/Loop backwards                            | yes                                                        | no            |
| Dynamic values                                 | yes                                                        | no            |
| CSS-Like animations                            | yes                                                        | no            |

## Example

```gdscript
var anima = Anima.Node($Node).anima_keyframes({
    from = {
        opacity = 0,
        scale = Vector2(0.5, 0.5),
    },
    to = {
        opacity = 1,
        scale = Vector2.ONE
    },
    easing = Anima.EASING.EASE_OUT_BACK,
})

await anima.play()

anima.play_reverse_with_delay(1)
```

## Built-in animations

Original source: https://github.com/animate-css/animate.css

## Stay in Touch

- [Twitter](https://twitter.com/ceceppa)
- [Discord](https://discord.gg/zgtF3us5yN)

## Contribution

Contributions are welcome and are accepted via pull requests.

## License

MIT

Copyright (c) 2021-present, Alessandro Senese (ceceppa)
