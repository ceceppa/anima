# AnimaNodesProperties

In Godot different node uses different property names for the same property, for example the `scale` property is called

- `rect_scale` for Control nodes
- `scale` for Node2D nodes

So, this utility class helps Anima to figure out which property to animate given a property name :)

You can use the class methods to make your code work with any Node without worrying about the difference of names.

## Get methods

| Method       | Control node  | Node2D node        |
| ------------ | ------------- | ------------------ |
| get_position | rect_position | global_transform   |
| get_size     | get_size()    | texture.get_size() |
| get_scale    | rect_scale    | scale              |
| get_rotation | rect_rotation | rotation_degrees   |

## Set pivot

Sets the pivot point for Control and Node2D nodes.

### Syntax

```gdscript
func set_pivot(node: CanvasItem, pivot: Anima.PIVOT) -> void:
```

## get\_property\_initial\_value

Returns the current property value of the node

### Syntax

```gdscript
func get_property_initial_value(node: CanvasItem, property: String):
```
