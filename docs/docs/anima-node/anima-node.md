---
sidebar_position: 1
---

# AnimaNode

## Usage

This node is used to handle the setup of all the animations supported by the addon.
There are two ways you can use it:

1. By manually adding the node to your scene
2. Via gdscript

### 1. Manually added to the scene

Suppose we have added the node to our scene and its name is "AnimaNode" now we can access its functionality with, for example:

```gdscript
$AnimaNode.then( Anima.Node($node).anima_animation("tada", 0.7) ).play()
```

### 2. Gdscript way

To add the node programmatically via gdscript you have to invoke the [begin](#begin) or [begin_single_shot](#begin-single-shot) function first:

```gdscript
Anima.begin(self) \
	.then( Anima.Node($node).anima_position_x(100, 0.3) ) \
	.play()

# OR

Anima.begin_single_shot(self) \
	.then( Anima.Node($node).anima_position_x(100, 0.3) ) \
	.play()
```

## Signals
### animation_started

Emitted when the animation or loop starts

```gdscript
signal animation_started
```

### animation_completed

Emitted when the animation or loop starts

```gdscript
signal animation_completed
```

### loop_started
Emitted when a loop starts

```gdscript
signal loop_started(loop_count: int)
```

### loop_completed

Emitted when a loop completes

```gdscript
signal loop_completed(loop_count: int)
```

## Methods

- [then(AnimationDeclaration)](#then-sequential-animations)
- [with(AnimationDeclaration)](#with-parallel-animations)
- [wait(delay)](#wait)
- [play()](#play)
- [play_with_delay(delay)](#play-with-delay)
- [play_with_speed(speed)](#play-with-delay)
- [play_backwards(delay)](#play-with-delay)
- [play_backwards_with_delay(delay)](#play-with-delay)
- [play_backwards_with_speed(speed)](#play-with-delay)
- [stop()](#stop)
- [clear()](#clear)
- [set_visibility_strategy(Anima.VISIBILITY_STRATEGY)](#set_visibility_strategy)
- [set_loop_strategy()](#set-loop-strategy)
- [get_length()](#get-length)
- [set_default_duration](#set-default-duration)

## Reference

### then: sequential animations

The `then` method allows you to animate elements in a sequence.

#### Syntax

```gdscript
then( data: AnimaAnimationDeclaration )
```

#### Example

![Example of sequential animation](/img/examples/then.gif)

```gdscript
Anima.begin_single_shot(self, 'sequential') \
	.then( Anima.Node($Logo).anima_position_x(100, 1) ) \
	.then( Anima.Node($Logo).anima_position_y(80, 1).anima_delay(-0.5) ) \
	.then( Anima.Node($Logo).anima_rotate(90, 1).anima_delay(0.5) ) \
	.play()
```

##### Timeline

When we play this animation, we can see the node moving in diagonal after about 0.5s, and for about 0.5s, as we used a negative delay to the 2nd animation:

![Sequential](/img/sequential.png)


### with: parallel animations

The `with` method allows you to animate elements in parallel.

#### Syntax

```gdscript
with( data: AnimationDeclaration )
```

#### Example

![Example of parallel animation](/img/examples/parallel.gif)

```gdscript
Anima.begin(self, 'parallel') \
	.then( Anima.Node($Logo).anima_position_x(100, 1) ) \
	.with( Anima.Node($Logo).anima_position_y(80, 1) ) \
	.with( Anima.Node($Logo).anima_rotate(90, 1) ) \
	.play()
```

### clear

Clears all the animations.

#### Syntax

```gdscript
anima.clear()
```

### get_length

Returns the total animation duration.

#### Syntax

```gdscript
anima.get_length()
```


### set_visibility_strategy

This method allows hiding all the nodes that will be animated when the animation hasn't started yet.
Let's have a look at the following gif:

[Hide strategy](../images/hide_strategy.gif)

we have three elements:

1. Window
2. Text
3. Button

We want all of them hidden for this kind of animation when it has not started yet.
A simple solution can hide them in the editor; it works. But I always end up forgetting to re-hide stuff after doing some test.
So this method is helpful to avoid this kind of distraction, as we can specify, during the creation of the animation, that we want to hide :)

#### Syntax

```
set_visibility_strategy(strategy: Anima.Visibility)
```

|Strategy|Description|
|---|---|
|Anima.Visibility.IGNORE|Leaves everything as it is|
|Anima.Visibility.HIDDEN_ONLY|Hides the element using the `.hide()` method|
|Anima.Visibility.TRANSPARENT_ONLY|Sets the modulate alpha channel to 0|
|Anima.Visibility.HIDDEN_AND_TRANSPARENT|Hides and makes the elements transparent|

`TRANSPARENT` and `HIDDEN` have a different impact on the node:

- A *transparent* node can still receive the focus and click events. So, a button will still show the hand cursor when hovered. But it will keep the space occupied
- A *HIDDEN* node cannot be clicked and does not occupy any space. So this means that when made visible, it will claim its space, and you might experience other elements being pushed to a different position.

#### Example

```gdscript
func _ready():
	Anima.begin(self, 'sequence_and_parallel') \
		.then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \
		.then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \
		.then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \
		.set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \
		.play_with_delay(0.5)
```


### loop

Loops the animation # given `times`.

**NOTE**: By default Anima will not re-calculate the relative data. See [set_loop_strategy](#set-loop-strategy) for more information.

#### Syntax

```gdscript
anima.loop(times: int = -1)
```

|Param|Type|Description|
|---|---|---|
|times|int|Number of loops to execute. Use `-1` to have an infinite loop.|

### loop\_with\_delay

Loops the animation # given `times` with an interval of # `seconds` between each loop

#### Syntax

```gdscript
anima.play_with_delay(delay: float, times: int)
```

|Param|Type|Description|
|---|---|---|
|delay|float|Delay before starting a new loop. **NOTE** it is not applied for the first loop|
|times|int|Number of loops to execute. Use `-1` to have an infinite loop.|

#### Example

```gdscript
Anima.begin(self, 'sequence_and_parallel') \
	.then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \
	.then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \
	.then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \
	.set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \
	.loop_with_delay(0.5, 5)
```

Loops the animation _5_ times and applies a delay of 0.5 seconds from the 2nd loop.

### loop_backwards

Loops the animation backwards X given `times`.

**NOTE**: By default Anima will not re-calculate the relative data. See [set_loop_strategy](#set-loop-strategy) for more information.

#### Syntax

```gdscript
anima.loop_backwards(times: int = -1)
```

|Param|Type|Description|
|---|---|---|
|times|int|Number of loops to execute. Use `-1` to have an infinite loop.|

### loop\_backwards\_with\_delay

Loops the animation backwards X given `times` with an interval of Y `seconds` between each loop

#### Syntax

```gdscript
anima.play_backwards_with_delay(delay: float, times: int)
```

|Param|Type|Description|
|---|---|---|
|delay|float|Delay before starting a new loop. **NOTE** it is not applied for the first loop|
|times|int|Number of loops to execute. Use `-1` to have an infinite loop.|

#### Example

```gdscript
Anima.begin(self, 'sequence_and_parallel') \
	.then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \
	.then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \
	.then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \
	.set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \
	.loop_backwards_with_delay(0.5, 5)
```

Loops the animation _5_ times and applies a delay of 0.5 seconds from the 2nd loop.

### play

Plays the entire animation

#### Syntax

```gdscript
anima.play()
```

### play\_with\_delay

Plays the entire animation after the specified delay has occurred.

#### Syntax

```gdscript
anima.play_with_delay()
```


#### Example

```gdscript
Anima.begin(self, 'sequence_and_parallel') \
	.then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \
	.then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \
	.then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \
	.set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \
	.play_with_delay(0.5)
```

Plays the animation after 0.5 seconds.

### play\_backwards

Plays the entire animation backwards.

#### Syntax

```gdscript
anima.play_backwards()
```

### play\_backwards\_with\_delay

Plays the entire animation backwards after the specified delay has occurred.

#### Syntax

```gdscript
anima.play_backwards_with_delay()
```


#### Example

```gdscript
Anima.begin(self, 'sequence_and_parallel') \
	.then( Anima.Node($Panel).anima_animation( "scale_y", 0.3 ) ) \
	.then( Anima.Node($Panel/MarginContainer/Label).anima_animation( "typewrite", 0.3 ) ) \
	.then( Anima.Node($Panel/CenterContainer/Button).anima_animation( "tada", 0.5 ).anima_delay(-0.5) ) \
	.set_visibility_strategy(Anima.Visibility.TRANSPARENT_ONLY) \
	.play_backwards_with_delay(0.5)
```

Plays the animation backwards after 0.5 seconds.

### stop

Stops the entire animation

#### Syntax

```gdscript
anima.stop()
```

### set\_loop\_strategy

Set what to do when a new loop starts

#### Syntax

```gdscript
set_loop_strategy(strategy: int)
```

|Strategy|Description|
|---|---|
|Anima.LOOP.USE_EXISTING_RELATIVE_DATA|(Default) Repeats the animation as it is, all the relative data calculated stays the same|
|Anima.LOOP.RECALCULATE_RELATIVE_DATA|Re-calculate the relative data before starting the animation again|

To understand the difference between those two properties, let's consider the following code:

```gdscript
var anima = Anima.begin(self)
anima.then({ node = $Node, to = 10, relative = true, property = "position:x" })
```

We asked Anima to animate the X position of 10 pixels from its relative position. For example, suppose its starting position is `Vector2(30, 7)`, then at the end of the 1st loop, the node X position will be `Vector2(30, 17)`.

#### USE_EXISTING_RELATIVE_DATA

The relative data is only calculated once. This means that if we animate a node relative to its current property when the new loop starts, we will use the same initial and final value.

So, looking at the example above, Anima resets the Node position to its initial value `Vector2(30, 7)`. And at the end of the loop, the final position will be once again `Vector2(30, 17)`.

#### RECALCULATE_RELATIVE_DATA

This strategy recalculates the relative data before starting the new loop.

So, looking at the example above, we'll have:

|Loop|Initial position|Final position|
|---|---|---|
|1|Vector2(30, 7)|Vector2(30, 17)|
|2|Vector2(30, 17)|Vector2(30, 27)| 
|3|Vector2(30, 27)|Vector2(30, 37)|
|...n|Vector2(30, n - 1)|Vector2(30, (n - 1) + 10)|

As you can see, using this strategy keeps incrementing the fina value indefinitely.

### wait

Adds a delay for the next animation.

#### Syntax

```gdscript
wait(delay: float)
```

#### Example

```gdscript
.wait(0.3) # delays the next animation of 0.3 seconds
```

### set_default_duration

Sets the default animation duration.

**NOTE**: This value is used only if we don't set the animation duration value.