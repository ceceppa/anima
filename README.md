# Anima

Anima is an addon for Godot that allows you to create rich animation easily.

## Introduction

![Anima](https://anima.ceceppa.me/anima.gif)

Creating rich animations can be a bit tedious, and Anima solves this problem for you. Allowing to run sequential, parallel and concurrent animations with few lines of code.
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

Check out [documentation](https://anima.ceceppa.me) and [live examples](https://anima.ceceppa.me/demo).

## Differences between Anima and Godot Tween

|                                    | Anima                                                      | Tween                                 |
|---|---|---|
| Chaining                           | support for sequential, parallel and concurrent animations | possible but need to be done manually |
| Animate relative property          | yes                                                        | no                                    |
| Easing                             | 33 built-in, (it will be extended in 0.2)            | 10 and no support for custom ones     |
| Reverse animation                  | 0.2                                                        | no                                    |
| Change speed on fly                | 0.2                                                        | no                                    |
| Animation path (position only)     | 0.3                                                        | no                                    |
| Create and reuse custom animations | 89 built-in, more can be added programmatically            | possible but not as easy              |
| Animate elements in group          | yes (it will be extended in 0.2)                           | possible but need to manually animate each individual element|

## Stay in Touch

[Twitter](https://twitter.com/ceceppa)

## Contribution

Contributions are welcome and are accepted via pull requests.

## License

MIT

Copyright (c) 2021-present, Alessandro Senese (ceceppa)
