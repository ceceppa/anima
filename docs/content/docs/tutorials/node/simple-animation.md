---
weight: 100
title: "Simple Animation"
description: ""
icon: "developer_guide"
draft: false
---

Let's implement the following animation:

{{< video src="/popup.webm" >}}

As we can see the animation is made of 3 components:

1. Popup panel
2. Text
3. Button

To create the animation in Godot let's consider this basic Hierarchy:

![Popup example hierarchy](/images/tutorials/node-popup.png)

Before writing any code let's see how the animation is made:

- The panel opens
  - → **then** the text is animated
    - → **then** the button is animated but its starting time is anticipated of about 0.2 seconds

In this example the _Panel_ opening is realized animating the `scale:y` property from **0** → **1**. The _Label_ uses the [built-in](/ciao) **typewrite** animation; while the _Button_ uses the **tada** one.

We want to animate the popup as soon as the scene is open, so let's add our code inside the `_ready` function:

## The animation

Because we're animating a single node we're going to use the [Anima.Node](/docs/anima/anima-node/) utility class and its [anima_scale_y](/docs/anima/anima-node#anima_scale_y) method:

```gdscript
Anima.Node(self).anima_scale_y(1.0, 0.3).anima_from(0)
```

The second parameter of `anima_scale_y` indicates the duration in seconds, and in this case is **0.3 seconds**.

{{< alert context="warning" text="We have manually specified the **from** value because, if omitted, Anima would use the `scale:y` value we have [when the animation is created](/docs/tutorials/basics/fundamentals/)." />}}

### The Text

As we said before the text is animated by using the built-in **typewrite** animation:

```gdscript
(
    #Previous code
    Anima.Node(self).anima_scale_y(1.0, 0.3).anima_from(0) # The panel

    # The text
    .then(Anima.Node($VBoxContainer/Label))
    .anima_animation("typewrite", 0.01)
)
```

Once again we used the [Anima.Node](/docs/anima/anima-node/) utility class because we're animating a single node. While the [anima_animation](/docs/docs/anima-declaration/#anima_animation) let us specify the name of the animation to use and its duration.

{{< alert context="info" text="The **typewrite** animation is a special one where we specify the duration of animating the single character, instead of the entire animation." />}}

### The Button

The button animation starts slightly before the text one completes. So, before writing any code let's see how to achieve that:

We could define the animation as parallel, using the [with](/docs/anima/anima-node#with-parallel-animations) syntax, but because the text animation depends by its length we would need to manually calculate the delay to apply.

So, how can we solve this? By using a negative delay :)

```gdscript
(
    #Previous code
    Anima.Node(self).anima_scale_y(1.0, 0.3).anima_from(0) # The panel
    .then(Anima.Node($VBoxContainer/Label)) # The text
    .anima_animation("typewrite", 0.01)


    # The button
    .then(Anima.Node($VBoxContainer/Button) -0.1)
    .anima_animation('tada', 0.5 ).anima_delay(-0.1)
)
```

Now we don't need to worry about the length of the text as the button is always animated 0.1 second before the previous animation completes!

{{< alert context="info" text="If we have a look at the [anima_delay](/docs/anima/anima-node#anima_delay) documentation, we can see that we can also pass a negative number to anticipate the start of a sequential or parallel animation." />}}
