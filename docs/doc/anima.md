# Anima

Once activated, the addon will add the Anima singleton class to your project. This class allows you to set up animations and create your own.

## Custom nodes

Anima provides those two additional nodes:

- [AnimaNode](/doc/anima-node.html), used to handle the setup of all the animations supported by the addon
- [AnimaTween](/doc/anima-tween.html), is the custom Tween used that allows the magic to happen :)

## Syntax

- [begin(node, animation_name)](#begin)
- [register_animation(script, animation_name)](#register-animation)
- [get_available_animations()](#get-available-animations)

## Enums

### Pivot

```gdscript
enum PIVOT {
	CENTER,
	CENTER_BOTTOM,
	TOP_CENTER,
	TOP_LEFT,
	LEFT_BOTTOM,
	RIGHT_BOTTOM
}

```

### Visibility
```gdscript
enum VISIBILITY {
	IGNORE,
	HIDDEN_ONLY,
	TRANSPARENT_ONLY,
	HIDDEN_AND_TRANSPARENT
}

```

### Group / Grid
```gdscript
enum GRID {
	TOGETHER,
	SEQUENCE_TOP_LEFT
	COLUMNS_ODD,
	COLUMNS_EVEN,
	ROWS_ODD,
	ROWS_EVEN,
	ODD,
	EVEN,
	FROM_CENTER,
	FROM_POINT
}
```

### Loop
```gdscript
enum LOOP {
	RECALCULATE_RELATIVE_DATA,
	USE_EXISTING_RELATIVE_DATA,
}
```

## Reference

### begin

This method is used to programmatically add the AnimaNode to the scene as child of the specified **node** one.
It will return the AnimaNode added attached to the specified **node**.

**NOTE**: You can call `begin` multiple times and Anima will only add one AnimaNode to the specified one for each `animation_name` specified.

#### Syntax
```gdscript
begin(node: Node, animation_name = 'Anima') -> AnimaNode:
```

|Parameter|Type|Description|
|---|---|---|
|node|Node|The node where to attache the AnimaNode generated during the process|
|animation_name|String|_(optional)_ The animation name.|

#### Example

```gdscript
var anima := Anima.begin(self, 'my cool animation')
```

### register_animation

This method allows to add your own animation to the list of the available one.

For more information look at: [How to register a new animation](/doc/custom-animations.md#how-to-register-a-new-animation)

#### Syntax

```gdscript
register_animation(script, animation_name: String) -> void:
```

|Parameter|Type|Description|
|---|---|---|
|script|Script|The script to invoke|
|animation_name|String|The animation name|

#### Example

```gdscript
register_animation(self, 'cool_animation')

# Now you can use it
anima.then({ node = $node, animation = 'cool_animation' })
```

### get_available_animations

Returns a list of all the animations available

#### Syntax

```gdscript
get_available_animations() -> Array:
```