---
sidebar_position: 1
---

# Anima

Once activated, the addon will add the Anima singleton class to your project.

## Custom nodes

Anima provides those two additional nodes:

- [AnimaNode](/doc/anima-node.html), used to handle the setup of all the animations supported by the addon
- [AnimaTween](/doc/anima-tween.html), is the custom Tween used that allows the magic to happen :)

## Syntax

- [begin(node, animation_name, is_single_shot)](#begin)
- [begin_single_shot(node, animation_name)](#begin_single_shot)


## Reference

### begin

This method is used to programmatically add the AnimaNode to the scene as a child of the specified **node** one.
It will return the AnimaNode added attached to the specified **node**.

#### Syntax
```gdscript
begin(node: Node, animation_name = 'Anima', is_single_shot := false) -> AnimaNode:
```

|Parameter|Type|Default|Description|
|---|---|---|---|
|node|Node||The node where to attache the AnimaNode generated during the process|
|animation_name|String|Anima|_(optional)_ The animation name.|
|is_single_shot|bool|false|_(optional)_ If true automatically frees the AnimaNode created by the scene once the animation completes|

**NOTE**: Anytime this method is called `Anima` will check if an `AnimaNode` already exists with the given name and, if not, creates one.
So, calling `begin` multiple times using the same name will result in reusing the same `AnimaNode` over and over.

The node created is not freed by default once an animation has completed unless `is_singl_shot` is set to true.

#### Example

```gdscript
var anima: AnimaNode = Anima.begin(self)
var anima: AnimaNode = Anima.begin(self, 'my cool animation')
var anima: AnimaNode = Anima.begin(self, 'my cool animation', true)
```

### begin_single_shot

This method is syntax sugar for the `begin` one automatically sets `is_single_shot` to true.

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
