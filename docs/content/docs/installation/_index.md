---
weight: 100
title: "Installation"
description: "Add Anima to a Godot project"
icon: "download"
draft: false
---

## 1. Copy the addon into your project

Download or clone Anima, then copy its `addons/anima/` folder into your own
Godot project's `addons/` folder, so you end up with
`res://addons/anima/plugin.cfg` alongside any other addons you already have.

## 2. Enable the plugin

In the Godot editor, open **Project > Project Settings > Plugins**, find
**Anima** in the list, and check its **Enable** box.

![Project Settings Plugins tab with Anima enabled](plugins-enabled.png)
<!-- PLACEHOLDER: screenshot needed — Godot editor's Project Settings > Plugins tab, the Anima row visible with its Enable checkbox checked -->

## 3. Verify it worked

Anima's classes (`Anima`, `Motion`, `AnimaValue`, and the rest) are globally
available as soon as the addon's files are in your project — you don't need
to write any setup code. Confirm it's working by playing a quick animation
from any script:

```gdscript
func _ready() -> void:
    Anima.play(Anima.on($SomeNode).fade_in(0.3), $SomeNode)
```

Run the scene. If `$SomeNode` fades in, Anima is installed and working.

## Next

Continue with [01: Basic Animation](../tutorials/01-basic-animation) for a
guided first animation, or browse [Features](../features) for what ships
out of the box.
