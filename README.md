# Anima

Anima is an addon for Godot that allows you to create sequential and parallel animations with less code compared to Tween.

## Introduction

![Anima](https://anima.ceceppa.me/anima.gif)

Creating sequential and parallel animations using Tween can be a bit tedious, and Anima allows you doing that with few lines of code and a simple syntax.
It has built-in about 89 animations and 33 easings, with the ability to easily add your own.
You can also add your own with a CSS inspired syntax.

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

Check out [documentation](https://anima.ceceppa.me), [demo code](https://github.com/ceceppa/anima-demos) and [live examples](https://anima.ceceppa.me/demo).

## Differences between Anima and Godot Tween

|                                    | Anima                                                      | Tween                                 |
|---|---|---|
| Chaining                           | support for sequential, parallel and concurrent animations | possible but need to be done manually |
| Easing                             | 33 built-in, (it will be extended in 0.2)            | 10 and no support for custom ones     |
| Create and reuse custom animations | 89 built-in, more can be added programmatically            | possible but not as easy              |
| Animate elements in group          | yes (it will be extended in 0.2)                           | possible but need to manually animate each individual element|
| Loop                               | Infinite, Times, and delayed loops                         | Infinite only               |
| Animate relative values            | yes                                                        | possible but need to be done manually                                    |
| Play/Loop backwards                | yes                                                        | no                                    |
| Change speed on fly                | 0.4                                                        | no                                    |
| Animation path (position only)     | 0.5                                                        | no                                    |

What does it mean in terms of code? Here an overview of Anima vs Godot Tween code for simple animation:

![Anima vs Godot](https://anima.ceceppa.me/code-difference.png)

For more info about the differences have a look [here](https://anima.ceceppa.me/doc/#anima-vs-tween)

## Stay in Touch

- [Twitter](https://twitter.com/ceceppa)
- [Discord](https://discord.gg/zgtF3us5yN)

## Contribution

Contributions are welcome and are accepted via pull requests.

## License

MIT

Copyright (c) 2021-present, Alessandro Senese (ceceppa)
