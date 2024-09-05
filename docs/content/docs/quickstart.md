---
weight: 200
title: "Quickstart"
description: ""
icon: "article"
date: "2024-09-04T14:52:56+01:00"
lastmod: "2024-09-04T14:52:56+01:00"
draft: false
toc: true
---

# Installation

There are two ways to install Anima: using the Asset Library or the GitHub repository.

## Using the Asset Library

The plugin is available on the [Asset Library](https://godotengine.org/asset-library/asset/1842).

![Anima Asset Library](/images/asset-library.png)

"To install Anima, follow these steps:

1. Open the AssetLib in Godot.
2. Search for "Anima" in the AssetLib.
3. Click on the "Anima" asset.
4. Click the "Download" button."

## Using the GitHub Repository

Clone the repository into your project's `addons` folder:

```bash
git clone https://github.com/ceceppa/anima-godot-4/ addons/anima
```

## Activating the Plugin

Once you have downloaded the plugin, you need to activate it in your project settings.

![Anima plugin settings](/images/activate-anima.png)
1. Click on the "Project" menu.
2. Click on "Project Settings".
3. Click on the "Plugins" tab.
4. Enable the "Anima" plugin.

## Using Anima

Anima offers a flexible and efficient approach to animation.
Instead of relying on custom nodes or resources, you can easily create animations using the intuitive Anima API.

Here's a simple example to get you started:

```gdscript
extends Label

func _ready():
    Anima.Node(self).anima_fade_in(1.0).play()
```

1. Create a new `Label` node.
2. Attach the script above to the `Label` node.
3. Run the scene.
