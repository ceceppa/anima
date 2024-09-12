---
weight: 100
title: "Built in Animations"
description: ""
icon: "article"
date: "2024-09-04T15:20:16+01:00"
lastmod: "2024-09-04T15:20:16+01:00"
draft: false
---

Anima's extensive library of 89 built-in animations empowers you to create dynamic effects for your nodes, groups, and grids.

To apply an animation, simply use the `anima_animation` method. Provide the animation name and duration as arguments. Here's a quick example:

```gdscript
(
    Anima.Node(self)
    .anima_animation("tada", 0.7)
    .play()
)
```

As you can see, animating your game elements with Anima is incredibly straightforward!

## Animations

Here's a list of the animations available in Anima:

{{< tabs tabTotal="16">}}
{{% tab tabName="Attention seeker" %}}
- bounce
- flash
- headshake
- heartbeat
- jello
- pulse
- rubber band
- shake x
- shake y
- swing
- tada
- wobble
{{% /tab %}}

{{% tab tabName="Back entrances" %}}
- back in down
- back in left
- back in right
- back in up
{{% /tab %}}

{{% tab tabName="Back exits" %}}
- back out down
- back out left
- back out right
- back out up
{{% /tab %}}

{{% tab tabName="Bouncing entrances" %}}
- bouncing in
- bouncing in down
- bouncing in left
- bouncing in right
- bouncing in up
{{% /tab %}}

{{% tab tabName="Bouncing exits" %}}
- bounce out
- bounce out down
- bounce out left
- bounce out right
- bounce out up
{{% /tab %}}

{{% tab tabName="Fading entrances" %}}
- fade in
- fade in bottom left
- fade in bottom right
- fade in down
- fade in down big
- fade in left
- fade in left big
- fade in right
- fade in right big
- fade in small
- fade in top left
- fade in top right
- fade in up
- fade in up big
{{% /tab %}}

{{% tab tabName="Fading exits" %}}
- fade out
- fade out bottom left
- fade out bottom right
- fade out down
- fade out down big
- fade out left
- fade out left big
- fade out right
- fade out right big
- fade out top left
- fade out top right
- fade out up
- fade out up big
{{% /tab %}}

{{% tab tabName="Lightspeed" %}}
- light speed in left
- light speed in right
- light speed out left
- light speed out right
{{% /tab %}}

{{% tab tabName="Rotating entrances" %}}
- rotate in
- rotate in down left
- rotate in down right
- rotate in up left
- rotate in up right
{{% /tab %}}

{{% tab tabName="Rotating exits" %}}
- rotate out
- rotate out down left
- rotate out down right
- rotate out up left
- rotate out up right
{{% /tab %}}

{{% tab tabName="Slide exits" %}}
- slide out down
- slide out left
- slide out right
- slide out up
{{% /tab %}}

{{% tab tabName="Sliding entrances" %}}
- slide in down
- slide in left
- slide in right
- slide in up
{{% /tab %}}

{{% tab tabName="Specials" %}}
- hinge
- jack in the box
- roll in
- roll out
{{% /tab %}}

{{% tab tabName="Text" %}}
- typewrite
{{% /tab %}}

{{% tab tabName="Zooming entrances" %}}
- zoom in
- zoom in down
- zoom in down big
- zoom in left
- zoom in left big
- zoom in right
- zoom in right big
- zoom in up
- zoom in up big
{{% /tab %}}

{{% tab tabName="Zooming exits" %}}
- zoom out
- zoom out down
- zoom out down big
- zoom out left
- zoom out right
- zoom out up
{{% /tab %}}

{{< /tabs >}}

To use any of these animations, simply pass the animation name to the `anima_animation` method, for example:

```gdscript
(
    Anima.Node(self)
    .anima_animation("light speed out left", 0.7)
    .play()
)
```
