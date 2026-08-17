---
title: "Anima.group"
description: "Every method Anima.group() gives you for animating an explicit set of nodes"
---

`Anima.group(targets)` hides target resolution and per-item scheduling
behind one call — the same underlying `AnimaGroupMotion` resource you could
build and configure by hand. This page covers everything the factory
exposes.

## Two ways to name your targets

```gdscript
Anima.group([$CardA, $CardB, $CardC])   # an explicit array of nodes

Anima.group($CardList)                  # a container node — its children become the targets
```

Unlike `Anima.on()`, `Anima.group()` has no default motion — you always have
to say what each item does, since there's nothing sensible to default to
for an arbitrary set of nodes.

## Giving it a motion

```gdscript
Anima.group($CardList) \
    .keyframes({"from": {"opacity": 0.0}, "to": {"opacity": 1.0}}, 0.3) \
    .play()

# or hand it an already-built motion — item motions apply per-item at
# runtime, so build them with Motion, not Anima.on() (which captures one
# specific target up front):
var fade := Motion.to(^"modulate:a", 1.0)
Anima.group($CardList).with_item_motion(fade).play()
```

`.keyframes(initial = {}, duration = 0.0)` builds a keyframe motion the same
way [Keyframes](keyframes) describes, sets it as the item motion, and
returns the factory (not the built motion) so `.play()` stays reachable at
the end of the chain.

## Shaping the item motion further

Once an item motion exists (via `.keyframes()` or `.with_item_motion()`),
these reach into it directly:

```gdscript
Anima.group($CardList).keyframes({...}).with_duration(0.5)
Anima.group($CardList).keyframes({...}).with_ease(AnimaEase.Kind.EASE_OUT_BACK)
Anima.group($CardList).keyframes({...}).with_pivot(AnimaPivot.Kind.CENTER)
```

Calling any of these before an item motion exists reports an error and
leaves the factory unchanged — there's nothing yet to set the field on.

## Delay, callbacks, and combining

```gdscript
Anima.group($CardList).keyframes({...}).with_delay(0.2)     # delay before the whole group starts
Anima.group($CardList).keyframes({...}).wait(0.5)            # delay before whatever's .then()'d next
Anima.group($CardList).keyframes({...}).on_started(func(): print("started"))
Anima.group($CardList).keyframes({...}).on_completed(func(): print("done"))
```

`.then(other)`/`.with(other)` combine the group with another motion, same
as any motion — see [Multiple animations](multiple-animations) — but return
the resulting composite motion, not the factory, since nothing else needs
to configure this specific group once it's being combined with something
else.

## Playing it, or getting the raw resource

```gdscript
Anima.group($CardList).keyframes({...}).play()

var motion := Anima.group($CardList).keyframes({...}).motion   # the raw AnimaGroupMotion, for saving or playing elsewhere
```

`.play()` reports an error and returns `null` if no item motion was ever
set — the same "nothing to play" failure every other factory has.

## What the factory is convenience sugar over

`Anima.group()` builds and configures an `AnimaGroupMotion` resource —
`target_collection`, `item_motion`, `playback_mode`, `distribution`,
`order`, `sequential_gap`, `completion_policy`, `reverse_order_policy`,
`invalid_target_policy`, `empty_group_policy`. The factory only exposes a
convenience path to the common ones above; for anything else, build or edit
the resource directly. See the generated
[AnimaGroupMotion](../../anima/anima-group-motion) and
[AnimaGroupMotionFactory](../../anima/anima-group-motion-factory) reference
pages for the complete field/method list.
