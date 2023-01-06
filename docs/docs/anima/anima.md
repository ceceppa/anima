---
sidebar_position: 1
---

# Anima

The `Anima` class is the starting point for creating an animation, and it returns the [AnimaNode](/doc/anima-node.html), which lets you specify the details of your animation.

## Syntax

- [begin(node, animation_name, is_single_shot)](#begin)
- [begin_single_shot(node, animation_name)](#begin_single_shot)

### Example

```gdscript
Anima.begin(self, "my animation").then(...)

// or

Anima.begin_single_shot(self, "my animation").then(...)
```

## Reference

### begin

The `begin` method adds an AnimaNode as a child of the specified node and returns the instance of the new node added.

#### Syntax
```gdscript
begin(node: Node, animation_name = 'Anima', is_single_shot := false) -> AnimaNode:
```

|Parameter|Type|Default|Description|
|---|---|---|---|
|node|Node||The node where to attach the AnimaNode generated during the process|
|animation_name|String|Anima|_(optional)_ The animation name.|
|is_single_shot|bool|false|_(optional)_ If true, automatically removes the AnimaNode created once the animation completes|

**NOTE**: It's important to remember that when you call the `begin` method, it checks if an `AnimaNode` with the given name already exists. If it doesn't, it will create one. So, calling `begin` multiple times with the same name results in reusing the same `AnimaNode` over and over.

#### Example

```gdscript
var anima: AnimaNode = Anima.begin(self)
var anima: AnimaNode = Anima.begin(self, 'my cool animation')
var anima: AnimaNode = Anima.begin(self, 'my cool animation', true)
```

### begin_single_shot

The `begin_single_shot` method is simply a shortcut for the `begin` method, with the parameter `is_single_shot` set to *true*. This method can be a convenient way to keep your Scene Tree clean, as it automatically destroys the [AnimaNode](/docs/anima-node/) once the animation has been completed.

#### Syntax
```gdscript
begin(node: Node, animation_name = 'Anima') -> AnimaNode:
```

|Parameter|Type|Default|Description|
|---|---|---|---|
|node|Node||The node where to attache the AnimaNode generated during the process|
|animation_name|String|Anima|_(optional)_ The animation name.|

#### Example

```gdscript
var anima: AnimaNode = Anima.begin(self, 'my cool animation')
var anima: AnimaNode = Anima.begin(self)
```
