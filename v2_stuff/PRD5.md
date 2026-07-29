# Anima 2 — Advanced Motion, Production UX and Showcase Addendum

**Product:** Anima 2
**Document type:** Product Requirements Document addendum
**Revision:** 1.1
**Status:** Draft
**Primary platform:** Godot 4.x
**Related documents:**

* Anima 2 Core Product Requirements
* Group and Custom Group Animation PRD
* `Anima.on()` Target-Bound Convenience API PRD

---

# 1. Purpose

This document defines the capabilities added to the Anima 2 product direction after the `Anima.on()` convenience API was specified.

It covers:

1. CSS-inspired keyframe animation.
2. Dynamic values.
3. Automatic layout transitions.
4. Interruption-safe visual states.
5. Named milestones and gameplay synchronisation.
6. Playback completion, cancellation and restoration.
7. Progress-driven and scrubbable motion.
8. Playback clocks and manual stepping.
9. Forward and reverse speed multipliers.
10. Lifecycle-safe playback.
11. Motion debugging and property-conflict inspection.
12. Reduced-motion and animation-skipping behaviour.
13. Eased group-stagger distribution.
14. Catchy 2D and 3D example scenes.
15. Seamless and oddly satisfying showcase loops.
16. Reusable example and marketing artifact generation.
17. Architectural preparation for additive motion layers.
18. Future consideration of Motion Fields.

This document extends rather than replaces the architectural requirements in the related PRDs.

---

# 2. Product direction

Anima should not be limited to shortening property-interpolation code.

Its expanded product promise is:

> **Anima makes complex, responsive and interruptible motion safe to author, reuse, reverse, inspect and integrate with gameplay.**

Its strongest areas of differentiation should be:

* Relational composition.
* Reversible and interruptible motion.
* Group and grid animation.
* CSS-inspired keyframes.
* Runtime-adaptive dynamic values.
* Automatic layout transitions.
* Direction-specific playback behaviour.
* Reliable playback lifecycle semantics.
* Motion debugging and validation.
* Memorable examples that demonstrate practical game-development problems.

Anima should solve the problems surrounding animation, not only interpolation.

---

# 3. Product principles

## 3.1 Preserve relational intent

Developers should describe:

```text
Do this
With this
Then this
Wait
Continue
```

rather than manually calculating timestamps.

The preferred choreography API remains:

```gdscript
Anima.begin(self)
    .then(first_motion)
    .with(parallel_motion)
    .then(next_motion)
    .play()
```

`with()` starts alongside the latest step.

Multiple `with()` calls join the same parallel step:

```gdscript
Anima.begin(self)
    .then(a)
    .with(b)
    .with(c)
    .then(d)
```

This resolves to:

```text
Parallel
├── A
├── B
└── C

Then
└── D
```

## 3.2 Preserve Anima V1 strengths

Anima 2 should retain and modernise useful V1 capabilities, including:

* CSS-inspired keyframes.
* Dynamic values.
* Group and grid animations.
* Convenience property methods.
* Reverse playback.
* Custom group ordering.
* `then()` and `with()` composition.

The new architecture should feel like an evolution of Anima rather than an unrelated replacement.

## 3.3 One canonical motion model

Every authoring API must produce the same underlying `AnimaMotion` graph.

```text
Anima.on()
CSS-style keyframes
Dynamic values
Group builders
Motion Composer
Explicit resources
        ↓
Canonical AnimaMotion graph
        ↓
AnimaPlayback
```

Convenience APIs must not implement separate playback, easing, reversal or interruption systems.

## 3.4 Solve production edge cases

A feature is not complete merely because its ideal demonstration works.

Anima must define behaviour for:

* Interruptions.
* Reversal.
* Direction changes.
* Speed changes.
* Seeking.
* Removed targets.
* Changed layouts.
* Skipped animations.
* Reduced-motion settings.
* Conflicting property owners.
* Dynamic runtime values.
* Editor preview.
* Deterministic example capture.

## 3.5 Examples must use the public product

Showcase scenes must not rely on private shortcuts or hard-coded animation logic unavailable to users.

Every public demonstration should:

* Use documented APIs.
* Be understandable from its source.
* Double as a regression or integration test.
* Demonstrate a real capability.
* Avoid hiding complexity in bespoke demo-only code.

## 3.6 Avoid rebuilding unrelated Godot systems

Anima should not become:

* A skeletal animation system.
* A gameplay state-machine replacement.
* A complete cutscene editor.
* A clone of Godot’s Animation editor.
* A replacement for `AnimationTree`.

Anima may orchestrate or integrate with these systems where useful.

---

# 4. Scope summary

## 4.1 Near-term product scope

The following should be treated as part of the core Anima 2 product direction:

* CSS-inspired keyframes.
* Dynamic values.
* Automatic layout transitions.
* Pre-animation snapshots.
* `reverse()`, `revert()`, `complete()` and `cancel()`.
* Progress-based evaluation and seeking.
* Named markers.
* Playback clocks.
* Forward and reverse speed multipliers.
* Lifecycle-safe cleanup.
* Motion debugging.
* Reduced-motion completion semantics.
* Eased group-stagger distribution.
* A maintained example and showcase project.

## 4.2 Architectural preparation only

The runtime architecture should not prevent:

* Additive motion layers.
* Multiple weighted property contributions.
* Named interaction and feedback layers.

These are not required for the initial release.

## 4.3 Explicitly deferred product ideas

The following are recorded for future evaluation:

* Motion Fields.
* Full visual state-machine authoring.
* Continuously live dynamic-value tracking.
* Live group membership.
* Arbitrary spatial effectors.
* Complex weighted transform blending.

---

# 5. CSS-inspired keyframe animation

## 5.1 Problem

Simple property animation describes one transition:

```text
start → destination
```

Many useful motions require several stages:

```text
0% → 20% → 65% → 100%
```

Examples include:

* Bounce.
* Pulse.
* Anticipation.
* Overshoot.
* Multi-stage opacity.
* Combined position, scale and rotation.
* Stylised UI entrances.
* Damage and impact feedback.
* Seamless animated loops.

Building these as many separate property motions is verbose and can lose the conceptual relationship between keyframes.

## 5.2 Product definition

Anima must support a first-class:

```gdscript
class_name AnimaKeyframeMotion
extends AnimaMotion
```

A keyframe motion describes one or more properties at normalised offsets across a duration.

```gdscript
var pulse := Anima.on($Panel)
    .keyframes({
        "from": {
            opacity = 0.0,
        },
        50: {
            opacity = 1.0,
        },
        "to": {
            opacity = 0.0,
        },
    })
    .duration(0.6)
```

## 5.3 Grouped offset declarations

Anima should preserve the V1 ability to assign one declaration to multiple offsets:

```gdscript
var pulse := Anima.on($Panel)
    .keyframes({
        ["from", 10]: {
            opacity = 0.0,
        },
        [23, 50]: {
            opacity = 1.0,
        },
        [12, "to"]: {
            opacity = 0.0,
        },
    })
    .duration(0.6)
```

The public API should accept this structure directly.

Developers should not need to call:

```gdscript
AnimaKeyframesEngine.flatten_keyframes_data(...)
```

Flattening and normalisation should be internal.

## 5.4 Offset normalisation

Internally:

```text
"from" → 0.0
10     → 0.10
50     → 0.50
"to"   → 1.0
```

Input declaration order must not determine playback order.

The parser must:

1. Flatten grouped offsets.
2. Validate offsets.
3. Normalise them to `0.0–1.0`.
4. Sort them.
5. Detect duplicate property declarations at the same offset.
6. Generate canonical keyframe tracks.

## 5.5 Multiple properties

One keyframe block may animate several properties:

```gdscript
var entrance := Anima.on($Panel)
    .keyframes({
        "from": {
            opacity = 0.0,
            position = Vector2(0, 40),
            scale = Vector2(0.9, 0.9),
        },
        65: {
            opacity = 1.0,
            position = Vector2(0, -4),
            scale = Vector2(1.03, 1.03),
        },
        "to": {
            opacity = 1.0,
            position = Vector2.ZERO,
            scale = Vector2.ONE,
        },
    })
    .duration(0.5)
```

Convenience names should resolve to canonical Godot properties:

```text
opacity  → modulate:a
position → position
scale    → scale
rotation → rotation
color    → modulate
size     → size
```

Arbitrary property paths should also be supported:

```gdscript
var motion := Anima.on($Panel)
    .keyframes({
        "from": {
            ^"theme_override_constants/separation": 4,
        },
        "to": {
            ^"theme_override_constants/separation": 24,
        },
    })
```

## 5.6 Programmatic construction

A fluent alternative should be available:

```gdscript
var pulse := Motion.keyframes()
    .at(["from", 10], {
        opacity = 0.0,
    })
    .at([23, 50], {
        opacity = 1.0,
    })
    .at([12, "to"], {
        opacity = 0.0,
    })
    .duration(0.6)
```

Both forms must create the same `AnimaKeyframeMotion`.

## 5.7 Per-segment easing

Keyframe segments should support independent easing.

```gdscript
var bounce := Anima.on($Panel)
    .keyframes({
        "from": {
            scale = Vector2(0.8, 0.8),
            _ease = Ease.out_cubic(),
        },
        70: {
            scale = Vector2(1.08, 1.08),
            _ease = Ease.in_out_sine(),
        },
        "to": {
            scale = Vector2.ONE,
        },
    })
```

Reserved metadata must use a clear namespace.

Potential reserved keys:

```text
_ease
_hold
_marker
_callback
```

The canonical resource should store metadata separately from animated properties.

## 5.8 Reversal

For automatic keyframe reversal:

* Keyframe order reverses.
* Offset becomes `1.0 - original_offset`.
* Segment easing is mirrored.
* Resolved dynamic values are reused from the execution record.
* Pure property tracks are automatically reversible.
* Callback or side-effect tracks require explicit backward behaviour.

## 5.9 Motion Composer

The Composer must support:

* Keyframe-track creation.
* Percentage editing.
* Multiple properties.
* Per-segment easing.
* Grouped-offset visualisation.
* Forward and backward preview.
* Dynamic-value indicators.
* Loop preview.
* Validation.
* Conversion between semantic and canonical property names.

---

# 6. Dynamic values

## 6.1 Problem

Fixed values are insufficient for reusable motion.

A reusable animation may depend on:

* Target width.
* Target height.
* Parent size.
* Viewport dimensions.
* Pointer position.
* Group index.
* Grid row or column.
* Runtime game state.
* Values resolved after layout.

Anima V1 supported expressions such as:

```gdscript
"-.:size:x"
```

meaning:

> Use the negative width of the current animated target.

This capability must remain.

## 6.2 Product definition

A dynamic value is an `AnimaValue` resolved against the current playback context.

```gdscript
class_name AnimaValue
extends Resource

func resolve(context: AnimaValueContext) -> Variant:
    return null
```

A motion property may accept:

* A fixed value.
* An `AnimaValue`.
* A supported callable wrapper.

## 6.3 Typed API

The primary Anima 2 API should use typed value expressions:

```gdscript
Anima.on($Panel)
    .position_x(0.0, 0.4)
    .from(
        Value.target(^"size:x").negative()
    )
```

Inside a group:

```gdscript
Anima.group($Grid.get_children())
    .apply(
        Anima.item()
            .position_x(0.0, 0.4)
            .from(
                Value.target(^"size:x").negative()
            )
    )
    .stagger(0.05)
```

Each item resolves its own width independently.

## 6.4 Value sources

Initial value sources:

```gdscript
Value.constant(20.0)

Value.target(^"size:x")

Value.node(
    ^"../Icon",
    ^"size:x"
)

Value.root(
    ^"viewport_rect:size:x"
)

Value.context(
    &"pointer_position"
)

Value.group_index()

Value.group_count()

Value.group_normalised_index()

Value.grid_row()

Value.grid_column()
```

## 6.5 Arithmetic composition

Dynamic values should support structural arithmetic:

```gdscript
Value.target(^"size:x")
    .multiply(-0.5)
    .subtract(12.0)
```

Initial operations:

* `add()`
* `subtract()`
* `multiply()`
* `divide()`
* `negative()`
* `absolute()`
* `minimum()`
* `maximum()`
* `clamp()`
* `map()`

Vector helpers:

* `x()`
* `y()`
* `z()`
* `component()`

## 6.6 Callable fallback

For calculations that cannot be represented structurally:

```gdscript
Anima.on($Panel)
    .position_x(0.0, 0.4)
    .from(
        Value.call(func(context: AnimaValueContext):
            return -context.target.size.x
        )
    )
```

Callable values must be marked as:

* Runtime-only.
* Potentially non-serialisable.
* Potentially non-compilable.
* Potentially unavailable in editor preview.

## 6.7 Resolution timing

```gdscript
enum AnimaValueResolution {
    MOTION_START,
    PLAYBACK_START,
    EACH_FRAME,
}
```

### Motion start

Resolve when the specific property motion begins.

This should be the default.

### Playback start

Resolve when the root playback begins.

Useful when later scene changes must not affect the value.

### Each frame

Continuously resolve against changing state.

This is deferred and should be treated as tracking or constraint motion rather than ordinary endpoint interpolation.

## 6.8 Keyframe integration

Dynamic values must work inside keyframes:

```gdscript
Anima.on($Panel)
    .keyframes({
        "from": {
            position_x = Value.target(^"size:x").negative(),
            opacity = 0.0,
        },
        "to": {
            position_x = 0.0,
            opacity = 1.0,
        },
    })
    .duration(0.5)
```

## 6.9 Execution record

When a dynamic value resolves, Anima must record the result.

```text
Declared value:
    negative target width

Resolved value:
    -128
```

Mid-playback reversal must reuse `-128`.

It must not recalculate against a target whose dimensions may have changed.

A fresh playback may resolve the value again.

## 6.10 Legacy compatibility

Legacy string syntax should remain available for migration:

```gdscript
.from("-.:size:x")
```

Internally:

```text
"-.:size:x"
        ↓
Negative(
    TargetProperty("size:x")
)
```

The typed API should be preferred in new documentation.

---

# 7. Automatic layout transitions

## 7.1 Problem

Godot containers control the positions and sizes of their children.

Developers often struggle to animate:

* Expanding sections.
* Collapsing sections.
* Reordered lists.
* Re-sorted grids.
* Changed column counts.
* Added controls.
* Removed controls.
* Responsive layout changes.
* Text-driven resizing.
* Localisation changes.
* Reparented elements.

Direct property animation frequently fights the container.

The developer should not need to calculate every old and new rectangle manually.

## 7.2 Product definition

Anima should provide first-class layout transitions:

```gdscript
Anima.layout($InventoryPanel)
    .change(func():
        $DetailsPanel.visible = true
        $ItemsGrid.columns = 4
        $Description.text = selected_item.description
    )
    .duration(0.35)
    .play()
```

Anima captures the layout before and after the mutation and animates the visual difference.

## 7.3 Core algorithm

The transition should follow a FLIP-style process:

```text
First
    Capture current layout

Last
    Apply mutation and allow layout recalculation

Invert
    Apply inverse visual transforms

Play
    Animate visual transforms back to identity
```

For `Control` nodes, visual-only transforms should be preferred where possible so the container remains authoritative.

## 7.4 Required workflow

1. Identify affected controls.
2. Capture initial geometry.
3. Capture visual state where required.
4. Execute the user mutation.
5. Wait for layout recalculation.
6. Capture final geometry.
7. Determine added, removed, moved and resized targets.
8. Apply inverse visual transforms.
9. Play the transition.
10. Remove temporary state.
11. Leave nodes in their actual final layout.

## 7.5 API examples

### General mutation

```gdscript
Anima.layout($Menu)
    .change(func():
        apply_new_menu_state()
    )
    .duration(0.35)
    .ease(Ease.out_cubic())
    .play()
```

### Expand and collapse

```gdscript
Anima.layout($SettingsMenu)
    .change(func():
        $AdvancedSettings.visible = true
    )
    .duration(0.3)
    .play()
```

### Inventory sorting

```gdscript
Anima.layout($InventoryGrid)
    .change(func():
        sort_inventory_by_rarity()
    )
    .duration(0.4)
    .play()
```

### Added and removed items

```gdscript
Anima.layout($QuestList)
    .change(func():
        remove_completed_quest()
        add_new_quest()
    )
    .enter(quest_enter_motion)
    .exit(quest_exit_motion)
    .play()
```

## 7.6 Result categories

Each affected target should be classified as:

* Unchanged.
* Moved.
* Resized.
* Moved and resized.
* Added.
* Removed.
* Reparented.
* Invalid.

## 7.7 Added targets

Added targets should support an entrance motion while their final layout remains authoritative.

## 7.8 Removed targets

Removed targets may need to remain visually available during their exit.

Anima may:

1. Capture a visual snapshot or temporary presentation.
2. Remove the actual node from the layout.
3. Place the temporary presentation in an overlay.
4. Animate the exit.
5. Release the temporary object.

## 7.9 Reparented targets

For shared nodes that move between parents:

* Capture global geometry before mutation.
* Capture global geometry after mutation.
* Animate through an overlay or visual transform.
* Preserve the final hierarchy.

## 7.10 Nested containers

Potential policies:

```gdscript
enum AnimaNestedLayoutPolicy {
    ROOTS_ONLY,
    LEAVES_ONLY,
    SMART,
    ALL,
}
```

Recommended default:

```text
SMART
```

The runtime should prevent unintended parent-child transform compounding.

## 7.11 Clipping

Potential policies:

```gdscript
enum AnimaLayoutClipPolicy {
    RESPECT,
    OVERLAY,
    TEMPORARILY_DISABLE,
}
```

## 7.12 Interruption

When another mutation occurs during an active transition:

* Capture the current visual state.
* Treat it as the new initial state.
* Apply the new mutation.
* Retarget toward the new final layout.
* Avoid snapping to old logical endpoints.

Recommended default:

```text
RETARGET
```

## 7.13 Reversal and restoration

A completed layout transition may reverse only when:

* Initial and final snapshots remain valid.
* Removed targets can be restored.
* Added targets can be removed safely.
* The original hierarchy can be reconstructed.

Otherwise Anima should offer restoration or retargeting rather than claiming exact reverse support.

The API must distinguish:

```gdscript
playback.reverse()
playback.revert()
```

## 7.14 Group integration

Moved or added items may be staggered:

```gdscript
Anima.layout($InventoryGrid)
    .change(func():
        sort_inventory()
    )
    .stagger(0.025)
    .stagger_order(AnimaGroupOrder.FROM_CENTER)
    .play()
```

---

# 8. Interruption-safe visual states

## 8.1 Problem

Interactive game UIs frequently receive state changes before the previous animation finishes.

Examples:

```text
Open
Close before opening completes
Open again
Hover
Press
Disable
Hide
Free target
Change scene
```

Killing the previous animation does not define the correct resulting state.

## 8.2 Product definition

Anima should safely transition between named visual states.

```gdscript
var menu_state := Anima.states($Menu)

menu_state.define(&"closed", menu_closed_motion)
menu_state.define(&"open", menu_open_motion)
```

Usage:

```gdscript
menu_state.go(&"open")
menu_state.go(&"closed")
```

## 8.3 Required behaviour

When changing state, Anima should determine whether to:

* Continue.
* Reverse.
* Retarget.
* Replace.
* Queue.
* Cancel.
* Complete the current transition.

It must also define:

* Current logical state.
* Current visual state.
* Destination state.
* Input availability.
* Completion-event behaviour.

## 8.4 Scope limitation

This is not a general-purpose gameplay state machine.

Initial scope:

* Named visual states.
* One current state.
* One destination state.
* Optional explicit transitions.
* Automatic interruption policies.
* `AnimaBehaviour` integration.

Deferred:

* Nested state machines.
* Arbitrary condition graphs.
* Boolean expression editors.
* Gameplay data flow.
* Complex transition routing.

## 8.5 Reversal optimisation

Anima may reverse the active transition when:

* The graph is reversible.
* Its endpoints match the requested states.
* No irreversible side effect invalidated the transition.

Otherwise it should retarget.

---

# 9. Named markers and semantic milestones

## 9.1 Problem

Gameplay logic is often tied to animation duration:

```gdscript
await get_tree().create_timer(0.4).timeout
apply_damage()
```

This breaks when motion:

* Changes duration.
* Changes speed.
* Is skipped.
* Is reversed.
* Is interrupted.
* Is manually seeked.
* Starts late.

## 9.2 Product definition

Motions should support semantic markers:

```gdscript
var attack := Motion.sequence(
    wind_up,
    Motion.mark(&"hit"),
    follow_through,
    Motion.mark(&"recovered")
)
```

Markers belong to the relational graph. Their absolute timestamps are generated.

## 9.3 Runtime API

```gdscript
var playback := Anima.play(attack)

await playback.reached(&"hit")
apply_damage()

await playback.reached(&"recovered")
can_attack = true
```

Additional operations:

```gdscript
playback.seek_marker(&"hit")
playback.play_to(&"hit")
playback.play_from(&"hit")
playback.play_between(&"hit", &"recovered")
playback.reverse_to(&"hit")
```

## 9.4 Marker event policies

```gdscript
enum AnimaMarkerPolicy {
    SUPPRESS,
    EMIT_CROSSED,
    EMIT_DESTINATION_ONLY,
}
```

## 9.5 Direction behaviour

```gdscript
enum AnimaMarkerDirectionPolicy {
    FORWARD_ONLY,
    BACKWARD_ONLY,
    BOTH,
}
```

Marker events should report:

* Name.
* Direction.
* Loop index.
* Playback progress.
* Whether they were crossed through seeking or completion.

---

# 10. Playback state semantics

## 10.1 Required playback operations

### Cancel

```gdscript
playback.cancel()
```

Meaning:

> Stop playback without claiming it completed.

Default:

* Keep current visual values.
* Cancel pending child motions.
* Do not emit normal completion.
* Emit cancellation.
* Release ownership.

### Complete

```gdscript
playback.complete()
```

Meaning:

> Reach the valid final visual and logical state.

Required behaviour:

* Apply final values.
* Resolve cleanup.
* Process markers according to policy.
* Mark the playback complete.
* Emit completion once.

### Revert

```gdscript
playback.revert()
```

Meaning:

> Restore the state captured before playback affected the target.

### Reverse

```gdscript
playback.reverse()
```

Meaning:

> Play the current execution backwards from its current progress.

Reverse and revert are not equivalent.

## 10.2 Completion behaviour

```gdscript
enum AnimaCompletionBehaviour {
    KEEP_FINAL,
    RESTORE_INITIAL,
}
```

## 10.3 Cancellation behaviour

```gdscript
enum AnimaCancellationBehaviour {
    KEEP_CURRENT,
    RESTORE_INITIAL,
    COMPLETE,
}
```

Recommended default:

```text
KEEP_CURRENT
```

## 10.4 Pre-animation snapshots

Snapshots may contain:

* Property values.
* Target identity.
* Layout rectangle.
* Parent.
* Child index.
* Visibility.
* Focus state.
* Temporary presentation state.

Snapshots support:

* Reverse playback.
* Dynamic-value reversal.
* `revert()`.
* Layout transitions.
* Editor preview.
* Reduced-motion completion.
* Interrupted transitions.

---

# 11. Progress-driven and scrubbable motion

## 11.1 Product definition

Anima must support evaluating motion by normalised progress.

```gdscript
var playback := Anima.prepare(drawer_motion)

playback.set_progress(0.0)
playback.set_progress(0.35)
playback.set_progress(1.0)
```

## 11.2 Interaction use case

```gdscript
func _on_dragged(distance: float) -> void:
    drawer_playback.set_progress(
        clampf(
            distance / drawer_width,
            0.0,
            1.0
        )
    )
```

On release:

```gdscript
if drawer_playback.get_progress() > 0.5:
    drawer_playback.animate_to_progress(1.0)
else:
    drawer_playback.animate_to_progress(0.0)
```

## 11.3 Required API

```gdscript
playback.get_progress() -> float
playback.set_progress(progress: float)
playback.seek_time(seconds: float)
playback.animate_to_progress(progress: float)
playback.seek_marker(marker: StringName)
```

## 11.4 Seek event policy

```gdscript
enum AnimaSeekEventPolicy {
    SUPPRESS,
    EMIT_CROSSED,
}
```

## 11.5 Runtime requirement

The evaluator must support:

```text
Evaluate the motion graph at progress P
```

It must not depend exclusively on incrementing elapsed time.

This supports:

* Reversal.
* Editor scrubbing.
* Gesture-driven animation.
* Native compilation sampling.
* Deterministic tests.
* Manual stepping.
* Reduced-motion completion.

---

# 12. Playback clocks and manual stepping

## 12.1 Clock types

```gdscript
enum AnimaClock {
    PROCESS,
    PHYSICS,
    UNSCALED,
    MANUAL,
}
```

## 12.2 Examples

### Unscaled UI animation

```gdscript
Anima.play(pause_menu_motion)
    .clock(AnimaClock.UNSCALED)
```

### Manual stepping

```gdscript
var playback := Anima.play(motion)
    .clock(AnimaClock.MANUAL)

playback.step(1.0 / 60.0)
```

## 12.3 Clock mutation

Recommended initial behaviour:

```text
The playback clock cannot change after playback begins.
```

---

# 13. Forward and reverse speed multipliers

## 13.1 Problem

Forward and reverse motion often require different pacing.

Example:

```text
Menu opening:
    0.40 seconds

Menu closing:
    0.25 seconds
```

The closing motion may still be the structural reverse of the opening motion, but it should run faster.

Without a reverse-speed setting, developers must:

* Duplicate an exit motion.
* Modify authored durations.
* Manually adjust speed after reversing.
* Duplicate choreography solely to change pacing.

## 13.2 Product definition

Every motion and playback may define:

```gdscript
forward_speed: float = 1.0
reverse_speed: float = 1.0
```

Example:

```gdscript
var menu_motion := Motion.sequence(
    panel_enter,
    buttons_enter
)
    .forward_speed(1.0)
    .reverse_speed(1.5)
```

Usage:

```gdscript
var playback := Anima.play(menu_motion)

playback.reverse()
```

The reverse direction automatically runs at `1.5×`.

## 13.3 General playback speed

A playback may also define a general multiplier:

```gdscript
var playback := Anima.play(menu_motion)
    .speed(1.25)
```

The general speed affects both directions.

Direction-specific runtime configuration may also be supported:

```gdscript
var playback := Anima.play(menu_motion)
    .forward_speed(1.0)
    .reverse_speed(1.5)
```

## 13.4 Effective speed

The effective speed should be calculated as:

```text
effective speed =
    scope speed
    × playback speed
    × parent motion speed
    × local motion speed
    × direction speed
```

Implementations may simplify the number of exposed levels initially, but the calculation model should be consistent.

Example:

```text
Playback speed:
    1.2×

Reverse speed:
    1.5×

Effective reverse speed:
    1.8×
```

## 13.5 Duration relationship

Authored duration remains unchanged.

For a one-second motion:

```text
Forward at 1.0×:
    1.00 seconds

Reverse at 1.5×:
    0.67 seconds
```

Speed is a playback multiplier, not a destructive change to the motion definition.

## 13.6 Direction must remain separate from speed

Negative speeds should not be used to reverse playback.

Avoid:

```gdscript
playback.set_speed(-1.5)
```

Use:

```gdscript
playback.reverse()
playback.set_speed(1.5)
```

Direction affects:

* Graph traversal.
* Sequence order.
* Group order.
* Marker semantics.
* Callback behaviour.
* Execution history.

Speed affects how quickly that direction is evaluated.

Speed values must be greater than zero.

Pause should use:

```gdscript
playback.pause()
```

rather than a zero speed multiplier.

## 13.7 Mid-flight reversal

Changing direction must preserve current progress.

```gdscript
var playback := Anima.play(menu_motion)

# Playback is currently at 60%.
playback.reverse()
```

Expected behaviour:

* Progress remains at `0.60`.
* Direction changes immediately.
* Reverse speed applies immediately.
* Values do not snap.
* Dynamic values are not recalculated.
* Pending structural events are rescheduled backwards.
* Current execution history remains valid.

## 13.8 Group behaviour

A group speed multiplier must scale the entire generated schedule:

* Item-motion durations.
* Stagger intervals.
* Sequential gaps.
* Delays.
* Marker timing.
* Generated start offsets.

Example:

```gdscript
var group := Anima.group(items)
    .apply(item_motion)
    .stagger(0.05)
    .reverse_speed(2.0)
```

At `2×` reverse speed, the stagger interval effectively becomes `0.025` seconds.

The target order still follows the group’s reverse-order policy.

## 13.9 Nested speed multipliers

Nested speed multipliers compose.

```gdscript
var item_motion := Anima.item()
    .opacity(1.0, 0.4)
    .speed(1.2)

var group := Anima.group(items)
    .apply(item_motion)
    .speed(1.5)
```

Effective item speed:

```text
1.2 × 1.5 = 1.8×
```

The Motion Inspector must show how the final value was produced.

## 13.10 Springs

Timeline-based easing scales directly through time.

Physical springs should scale simulation time:

```text
simulation delta =
    frame delta × effective speed
```

This preserves the authored spring characteristics while changing real-time duration.

Physical retargeting remains distinct from exact timeline reversal:

```gdscript
playback.retarget_to_start()
playback.reverse_timeline()
```

## 13.11 Markers

Speed changes affect when a marker is reached in real time, but not:

* Marker order.
* Marker identity.
* Marker direction policy.
* Marker position within the authored graph.

## 13.12 Manual stepping

Manual stepping must apply effective speed consistently:

```text
evaluated delta =
    supplied manual delta × effective speed
```

## 13.13 Reduced motion

Reduced-motion policy may override speed by:

* Completing immediately.
* Selecting a simpler motion.
* Removing stagger.
* Applying a dedicated reduced-motion speed.

## 13.14 Composer integration

The Motion Composer should provide:

* Forward-speed field.
* Reverse-speed field.
* General preview-speed control.
* Effective forward duration.
* Effective reverse duration.
* Forward preview.
* Backward preview.
* Mid-playback reverse.
* Optional direction-speed visualisation.

## 13.15 Debug information

The Motion Inspector should show:

```text
Authored duration:
    0.40 s

Local motion speed:
    1.20×

Parent group speed:
    1.50×

Playback speed:
    1.00×

Direction:
    Reverse

Reverse multiplier:
    1.40×

Effective speed:
    2.52×

Estimated remaining duration:
    0.09 s
```

## 13.16 Acceptance criteria

* Forward and reverse speed may differ.
* Mid-flight direction changes preserve progress.
* Direction-specific speed applies immediately.
* Negative speed is rejected.
* Group timing scales as one coherent schedule.
* Marker semantics remain stable.
* Dynamic values are not re-resolved after speed changes.
* Manual stepping respects effective speed.
* Effective timing is inspectable.
* Speed modifiers do not mutate authored duration.

---

# 14. Lifecycle-safe playback

## 14.1 Lifecycle policies

```gdscript
enum AnimaLifecycleBehaviour {
    CONTINUE,
    PAUSE,
    CANCEL,
    REVERT,
}
```

Potential API:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .on_exit_tree(AnimaLifecycleBehaviour.CANCEL)
```

Or:

```gdscript
Anima.play(motion)
    .linked_to($Panel)
```

## 14.2 Recommended defaults

```text
Target freed:
    Cancel affected motion safely.

Playback root freed:
    Cancel complete playback.

Target hidden:
    Continue.

Scene tree paused:
    Follow selected clock.

Target reparented:
    Continue when references remain valid.

Layout target removed:
    Follow layout-exit policy.
```

## 14.3 Cleanup requirements

Cancellation must:

* Disconnect signals.
* Release property ownership.
* Stop pending callbacks.
* Release layout overlays.
* Clear runtime records.
* Emit one terminal result.

---

# 15. Motion debugging and conflict inspection

## 15.1 Product definition

Anima should provide a live Motion Inspector.

Example:

```text
Target:
    SettingsButton

Property:
    offset_transform_position

Logical value:
    (420, 180)

Visual value:
    (420, 176)

Active motion:
    button_hover

Progress:
    63%

Direction:
    Reverse

Effective speed:
    1.5×

Interruption policy:
    Retarget

Previous motion:
    menu_enter

Layout owner:
    VBoxContainer
```

## 15.2 Property conflict report

```text
Property conflict detected

Target:
    InventoryButton

Property:
    scale

Existing motion:
    button_hover

Incoming motion:
    damage_pulse

Resolution:
    REPLACE
```

## 15.3 Required information

The inspector should expose:

* Playback hierarchy.
* Active motion.
* Target.
* Property.
* Current value.
* Starting value.
* Destination value.
* Velocity.
* Progress.
* Direction.
* Clock.
* Effective speed.
* Authored and effective duration.
* Owner.
* Interruption policy.
* Dynamic value expression.
* Resolved dynamic value.
* Group item index.
* Layout source.
* Captured snapshot.
* Previous owner.
* Conflict resolution.
* Marker history.

## 15.4 Debug overhead

Tracing must be optional.

It should be possible to:

* Disable tracing.
* Enable it globally.
* Enable it per playback.
* Limit history size.
* Strip tracing from production exports.

---

# 16. Reduced-motion and safe skipping

## 16.1 Reduced-motion policy

```gdscript
enum AnimaReducedMotionPolicy {
    FULL,
    SHORTEN,
    SIMPLIFY,
    COMPLETE_IMMEDIATELY,
    CUSTOM,
}
```

## 16.2 Motion alternatives

```gdscript
motion.reduced_motion(
    Anima.on($Panel)
        .opacity(1.0, 0.1)
)
```

Example:

```text
Full motion:
    Slide, scale and fade.

Reduced motion:
    Fade only.
```

## 16.3 Safe completion

When motion is skipped or completed immediately:

* Final visual values must be applied.
* Layout state must be committed.
* Temporary nodes must be cleaned up.
* Focus must be correct.
* Input state must be correct.
* Marker policy must be respected.
* Completion must be emitted once.

## 16.4 Group and layout behaviour

Reduced-motion mode may:

* Remove staggering.
* Reduce movement distance.
* Replace movement with opacity.
* Complete layout movement immediately.
* Preserve enter and exit visibility semantics.

---

# 17. Eased group-stagger distribution

## 17.1 Product definition

Anima Group Animation should support easing the distribution of item start offsets.

```gdscript
Anima.group(items)
    .apply(item_motion)
    .stagger_across(0.4)
    .origin(AnimaGroupOrigin.CENTER)
    .distribution(Ease.out_cubic())
```

## 17.2 Calculation

```text
start offset =
    distribution ease(normalised rank)
    × total stagger duration
```

## 17.3 Group origins

```gdscript
enum AnimaGroupOrigin {
    FIRST,
    CENTER,
    LAST,
    INDEX,
    POINT,
}
```

## 17.4 Equal-rank waves

Items with equal ordering rank should start together.

```text
Rank 0:
    Centre item

Rank 1:
    Adjacent items

Rank 2:
    Outer items
```

This supports satisfying ripple effects without manually creating parallel subgroups.

## 17.5 Reverse behaviour

Reverse distribution must use the target order and ranks resolved for the current execution.

Random order must not be regenerated.

---

# 18. Example and showcase strategy

## 18.1 Purpose

Anima V1 benefited from visual examples that immediately demonstrated what the plugin could do.

Anima 2 should continue this approach with a maintained collection of:

* Focused feature examples.
* Production-oriented scenarios.
* Visually memorable showcase scenes.
* Seamless loops suitable for documentation and social media.
* Examples that also serve as integration tests.

The example project is a product surface, not an afterthought.

## 18.2 Example design principles

Every example should be:

### Understandable

A developer should be able to identify the feature within a few seconds.

### Focused

Each scene should have one primary capability, even when secondary features support it.

### Attractive

The visual result should be polished enough to make the feature memorable.

### Reproducible

The animation must behave deterministically when a fixed seed is selected.

### Inspectable

The source scene, motion resources and script should be easy to open and understand.

### Interactive

Where relevant, examples should let users:

* Play.
* Pause.
* Reverse.
* Change speed.
* Scrub progress.
* Toggle reduced motion.
* Trigger interruptions.
* Show debug information.
* Reset the scene.

### Loopable

Showcase scenes should support a clean repeated cycle where the feature naturally allows it.

### Honest

A scene must not imply functionality that depends on unreleased or private code.

## 18.3 Example tiers

The example project should contain three tiers.

### Tier 1 — Minimal examples

Purpose:

* Explain one API.
* Support documentation.
* Act as regression tests.

Characteristics:

* Minimal assets.
* Short scripts.
* One feature.
* Clear labels.
* No decorative complexity.

Example:

```text
Property Motion
Opacity: 0 → 1
Duration: 0.3 s
Reverse speed: 1.5×
```

### Tier 2 — Practical game UI examples

Purpose:

* Demonstrate realistic usage.
* Solve actual Godot workflow problems.

Examples:

* Inventory sorting.
* Expandable settings menu.
* Quest-list item insertion.
* Interruptible pause menu.
* Drag-driven drawer.
* Attack marker synchronisation.
* Reduced-motion alternatives.

### Tier 3 — Showcase scenes

Purpose:

* Make Anima visually memorable.
* Produce website, launch and social content.
* Demonstrate multiple mature features together.

These scenes may be more visually elaborate, but must still use the public API.

---

# 19. Proposed 2D showcase scenes

## 19.1 Grid Bloom

**Primary features:**

* Grid groups.
* From-point ordering.
* Eased stagger distribution.
* Dynamic values.
* Reverse speed.
* CSS-style item keyframes.

**Concept:**

A field of colourful tiles blooms outward from a selected point, overshoots slightly and settles. It then collapses back toward the origin at a faster reverse speed.

```gdscript
Anima.group($Grid.get_children())
    .order_from_point(origin)
    .apply(tile_bloom)
    .stagger_across(0.6)
    .distribution(Ease.out_cubic())
    .reverse_speed(1.5)
```

**Loop structure:**

```text
Bloom outward
Hold briefly
Reverse inward
Move origin
Repeat
```

This is an ideal oddly satisfying loop because the forward and reverse states naturally connect.

## 19.2 Responsive Inventory

**Primary features:**

* Automatic layout transition.
* Grid sorting.
* Column-count changes.
* Enter and exit motion.
* Interruption retargeting.

**Concept:**

An inventory repeatedly switches between rarity, type and value sorting while changing between compact and expanded layouts.

The movement should remain smooth even when the user changes sorting before the previous transition finishes.

**Loop structure:**

```text
Sort by type
Expand details
Change columns
Sort by rarity
Collapse details
Return to initial order
```

The last state must match the first state exactly.

## 19.3 Elastic Menu

**Primary features:**

* Named visual states.
* Mid-flight reversal.
* Separate forward and reverse speed.
* Property conflict handling.
* Reduced-motion toggle.

**Concept:**

A polished game menu repeatedly opens and closes while simulated rapid user input interrupts it.

It should visibly demonstrate:

```text
Open
Close at 60%
Open again at 25%
Settle correctly
```

No snapping should occur.

## 19.4 Card Cascade

**Primary features:**

* Custom group.
* Sequential versus staggered timing.
* Eased distribution.
* Dynamic per-item values.
* Keyframe overshoot.

**Concept:**

Cards of different sizes cascade into a deck, fan outward and return.

Dynamic values ensure each card enters from an offset based on its own dimensions.

## 19.5 Kinetic Typography

**Primary features:**

* CSS-style keyframes.
* Group ordering.
* Dynamic target dimensions.
* Markers.
* Seamless looping.

**Concept:**

A word or short phrase assembles character by character, stretches, compresses and returns to its initial arrangement.

Typography should remain simple enough that source assets can be freely distributed.

## 19.6 Signal Strike

**Primary features:**

* Named markers.
* Awaitable milestones.
* Playback speed changes.
* Reverse marker behaviour.

**Concept:**

A simple 2D character or icon performs an attack.

The target flashes exactly when the `hit` marker is crossed. The scene allows the user to:

* Change speed.
* Reverse.
* Seek.
* Complete instantly.
* Suppress or emit crossed markers.

This is less decorative but highly valuable as a gameplay-integration example.

## 19.7 Infinite Conveyor

**Primary features:**

* Groups.
* Repetition.
* Relative movement.
* Item recycling.
* Deterministic looping.

**Concept:**

Objects move along a clean conveyor-like path, scale as they approach the centre and loop seamlessly.

This should demonstrate production-safe repetition without accumulating positional error.

---

# 20. Proposed 3D showcase scenes

3D examples should be included only where they demonstrate behaviour meaningfully different from 2D.

They should not exist solely to claim 3D support.

## 20.1 Kinetic Totems

**Primary features:**

* 3D group animation.
* Spatial ordering.
* Eased stagger.
* Keyframe scale and rotation.
* Forward and reverse speed.

**Concept:**

A grid or ring of abstract 3D pillars rises, rotates and settles in waves originating from a selected point.

The return motion should run faster and seamlessly restore the initial composition.

## 20.2 Orbiting Crystals

**Primary features:**

* Progress-driven motion.
* Dynamic values.
* Reverse playback.
* Manual scrubbing.
* Deterministic loops.

**Concept:**

Crystals orbit a central object while changing height, scale and rotation according to normalised progress.

The user can scrub the full composition directly.

A seamless full-cycle loop should be supported.

## 20.3 Satisfying Assembly

**Primary features:**

* Relational sequence and parallel composition.
* Markers.
* Group waves.
* Safe completion.
* Reversal.

**Concept:**

An abstract object assembles from several pieces:

```text
Base rises
Side pieces join in parallel
Core rotates into place
Marker: assembled
Object pulses
Sequence reverses
```

The scene should use simple primitives rather than requiring authored 3D models.

## 20.4 Spatial Ripple

**Primary features:**

* Spatial group ordering.
* Distance-based timing.
* Dynamic direction.
* Eased stagger distribution.

**Concept:**

A field of cubes reacts to a moving or selected point with a ripple of position, scale and colour.

This should initially use a captured point at playback start rather than a continuously moving Motion Field.

## 20.5 Camera Portal

**Primary features:**

* Multiple properties.
* Keyframes.
* Named markers.
* Speed and reverse-speed comparison.

**Concept:**

A simple camera moves through an abstract doorway while the environment animates relationally around it.

This is suitable only after camera and 3D property support are sufficiently stable.

---

# 21. Oddly satisfying loop requirements

## 21.1 Purpose

Seamless loops are useful for:

* Landing pages.
* README files.
* Documentation.
* Social posts.
* Release announcements.
* Plugin-store listings.
* Conference slides.
* Visual regression testing.

They also force the runtime to handle repeated playback without drift or state leakage.

## 21.2 Loop suitability

Not every feature should be forced into a loop.

A loop is appropriate when:

* The end state can return naturally to the start.
* Reverse playback is meaningful.
* The scene can reset without a visible cut.
* The loop does not imply unrealistic game behaviour.
* Repetition demonstrates stability.

## 21.3 Recommended loop patterns

### Forward, hold, reverse

```text
Play forward
Hold
Play backwards faster
Hold
Repeat
```

Useful for:

* Groups.
* Menus.
* Layout transformations.
* 3D assembly.

### Ping-pong

```text
0 → 1 → 0
```

Useful for:

* Keyframes.
* Progress-driven scenes.
* Pulses.
* Spatial waves.

### Circular

```text
0 → 1
where 1 visually equals 0
```

Useful for:

* Orbits.
* Conveyors.
* Rotating compositions.
* Continuous waves.

### State cycle

```text
State A
State B
State C
State A
```

Useful for:

* Layout examples.
* Sorting.
* Responsive UI.

## 21.4 Loop quality requirements

A showcase loop must:

* Return to the same visual state within tolerance.
* Return to the same logical state.
* Avoid accumulated floating-point drift.
* Avoid duplicated callbacks.
* Avoid retained temporary nodes.
* Avoid changing random order unless intentionally seeded.
* Avoid visible jumps at the edit boundary.
* Be repeatable for at least 100 cycles in automated validation.

## 21.5 Loop duration

Recommended showcase loops should generally remain between:

```text
4–12 seconds
```

Longer loops may be useful for full demonstration videos but are less reusable for embeds and social posts.

---

# 22. Example scene interaction shell

Every practical or showcase scene should use a shared example-shell component where relevant.

Suggested controls:

```text
Play
Pause
Reverse
Restart
Complete
Revert

Progress slider

Playback speed
Forward speed
Reverse speed

Reduced motion
Debug overlay
Loop enabled
```

The shell should display:

```text
Feature name
Current direction
Current progress
Effective speed
Current state
Active marker
```

This shell should be reusable rather than rebuilt for each scene.

It must be possible to hide the shell when capturing clean showcase footage.

---

# 23. Example scene contract

Every maintained example should contain:

1. A `.tscn` scene.
2. A minimal controlling script.
3. Reusable `.tres` motion resources where appropriate.
4. A short README.
5. A feature list.
6. Instructions for interaction.
7. A deterministic reset path.
8. A known loop duration where applicable.
9. A fixed random seed where randomisation is used.
10. At least one automated smoke or integration test.
11. A capture manifest.
12. Licensing information for included assets.

The example must expose a callable reset operation:

```gdscript
func reset_demo() -> void:
    pass
```

Looping examples should expose:

```gdscript
func play_showcase_loop() -> AnimaPlayback:
    pass
```

---

# 24. Artifact strategy

## 24.1 Definition

An example artifact is any reusable output created from a source demonstration.

Artifacts fall into three categories:

1. Source artifacts.
2. Presentation artifacts.
3. Verification artifacts.

The source scene is the primary artifact. Images and videos are derived artifacts.

## 24.2 Source artifacts

Source artifacts should include:

* Godot scene files.
* Motion resources.
* GDScript examples.
* Demo configuration.
* Capture configuration.
* Reusable UI shell.
* Minimal project assets.
* README documentation.

Suggested structure:

```text
examples/
├── 2d/
│   ├── grid_bloom/
│   │   ├── grid_bloom.tscn
│   │   ├── grid_bloom.gd
│   │   ├── README.md
│   │   ├── motions/
│   │   │   ├── tile_bloom.tres
│   │   │   └── tile_collapse.tres
│   │   └── capture.json
│   │
│   └── responsive_inventory/
│
├── 3d/
│   ├── kinetic_totems/
│   └── orbiting_crystals/
│
└── shared/
    ├── demo_shell/
    ├── capture_controller/
    └── debug_overlay/
```

## 24.3 Presentation artifacts

Presentation artifacts should include:

* High-quality master video.
* Seamless WebM or MP4 loop.
* GIF when required by the destination.
* Static poster frame.
* Thumbnail.
* Before-and-after image.
* Short vertical crop.
* Square crop.
* Documentation screenshot.
* Optional interactive exported build.

The master should not normally be a GIF.

A high-quality video or image sequence should be generated first, then converted into smaller delivery formats.

## 24.4 Verification artifacts

Verification artifacts should include:

* Expected final-state snapshots.
* Loop-boundary state comparison.
* Captured progress checkpoints.
* Performance measurements.
* Effective-duration reports.
* Marker event logs.
* Deterministic random seed.
* Compatibility metadata.
* Visual regression references where practical.

Example:

```json
{
  "scene": "grid_bloom.tscn",
  "seed": 19477,
  "loop_duration": 7.2,
  "capture_fps": 60,
  "resolution": [1920, 1080],
  "checkpoints": [0.0, 0.25, 0.5, 0.75, 1.0]
}
```

## 24.5 Artifact-first workflow

A showcase should be developed in this order:

1. Define the feature being demonstrated.
2. Define the initial and final logical states.
3. Build the smallest working scene.
4. Create reusable motion resources.
5. Add deterministic reset.
6. Add loop support where appropriate.
7. Add automated checks.
8. Add visual polish.
9. Capture a high-quality master.
10. Derive documentation and social artifacts.

Visual polish should not precede functional validation.

## 24.6 One source, multiple outputs

One well-designed showcase scene should generate:

* Example-project content.
* Documentation screenshots.
* README animation.
* Website loop.
* Bluesky post.
* Reddit clip.
* LinkedIn video.
* Release-note image.
* Benchmark scenario.
* Regression test.

This avoids maintaining separate one-off examples for every communication surface.

## 24.7 Capture manifest

Every showcase scene should declare its capture requirements.

Suggested fields:

```text
Scene path
Loop duration
Warm-up duration
Resolution
Frame rate
Camera
Random seed
UI overlay visibility
Background mode
Preferred crop
Poster-frame time
Reduced-motion variant
```

## 24.8 Deterministic capture controller

A shared capture controller should:

* Reset the scene.
* Apply the fixed seed.
* Apply the requested speed.
* Disable interactive overlays.
* Wait through warm-up frames.
* Start at a known progress.
* Run for a known duration.
* Stop on the exact loop boundary.
* Optionally capture poster frames.

## 24.9 Artifact formats

Recommended outputs:

```text
Source:
    .tscn
    .tres
    .gd
    .md
    .json

Master:
    high-quality video or image sequence

Documentation:
    .webm
    .png

Social:
    .mp4 or .webm
    optional .gif

Verification:
    .json
    images at known progress points
    benchmark reports
```

## 24.10 Aspect ratios

The capture pipeline should support:

```text
16:9
    Website, YouTube, documentation.

1:1
    Repository cards and some social posts.

9:16
    Vertical social previews.

4:3
    Editor-focused documentation where useful.
```

Scenes should place important content inside a safe central area so crops remain usable.

## 24.11 Asset policy

Showcase assets should preferably use:

* Godot primitives.
* Procedural shapes.
* Original simple vector assets.
* Openly distributable fonts.
* Clearly licensed audio.
* Clearly documented third-party assets.

The example project should not depend on assets that cannot be redistributed.

## 24.12 Artifact maintenance

Every example should specify:

```text
Feature owner
Last verified Anima version
Last verified Godot version
Capture version
Known limitations
```

When an API changes, examples and their derived artifacts should be regenerated from source rather than manually patched.

---

# 25. Example selection matrix

A feature should have at least one minimal example and may have one showcase example.

| Capability         | Minimal example    | Practical example  | Showcase             |
| ------------------ | ------------------ | ------------------ | -------------------- |
| `Anima.on()`       | Property panel     | Menu entrance      | Elastic Menu         |
| CSS keyframes      | Pulse square       | Damage feedback    | Kinetic Typography   |
| Dynamic values     | Width-based offset | Variable card list | Card Cascade         |
| Groups             | Button stagger     | Inventory reveal   | Grid Bloom           |
| Reverse speed      | Open/close panel   | Pause menu         | Elastic Menu         |
| Layout transitions | VBox expand        | Inventory sorting  | Responsive Inventory |
| Markers            | Marker counter     | Attack hit frame   | Signal Strike        |
| Progress control   | Slider-driven box  | Drag drawer        | Orbiting Crystals    |
| Reduced motion     | Full versus fade   | Settings menu      | Elastic Menu         |
| 3D groups          | Cube wave          | Assembly sequence  | Kinetic Totems       |

---

# 26. Showcase acceptance criteria

A showcase scene is ready when:

* Its primary capability is obvious within five seconds.
* The source uses public APIs.
* It has deterministic reset.
* It can run repeatedly without state leakage.
* It includes a minimal README.
* Its capture manifest is committed.
* It produces a clean master capture.
* It produces at least one documentation artifact.
* It produces at least one social-ready artifact.
* It passes its loop or final-state validation.
* It does not depend on unredistributable assets.
* It can run with the current supported Godot version.

---

# 27. Additive motion layers — architectural preparation only

## 27.1 Status

Additive motion layers are not part of the immediate implementation scope.

The architecture should avoid making them impossible.

## 27.2 Future model

```text
Final position =
    base layout position
    + interaction offset
    + feedback offset
```

Potential API:

```gdscript
Anima.on($Button)
    .move_by(Vector2(0, -6), 0.15)
    .layer(&"interaction")
    .blend(AnimaBlend.ADDITIVE)
```

Potential blend modes:

```gdscript
enum AnimaBlendMode {
    REPLACE,
    ADDITIVE,
    MULTIPLY,
}
```

## 27.3 Current architectural requirement

The central evaluator should not permanently assume:

```text
One property = exactly one possible contribution
```

The initial implementation may still enforce one replacing owner, but the contribution system should remain encapsulated.

---

# 28. Motion Fields — deferred concept

## 28.1 Status

Motion Fields are recorded as a future Group Animation capability.

They are not part of the current committed roadmap.

## 28.2 Concept

A Motion Field calculates influence per target:

```text
0.0 = no influence
1.0 = full influence
```

Potential uses:

* Delay.
* Scale.
* Opacity.
* Position.
* Rotation.
* Colour.
* Spring strength.
* Animation speed.

Potential API:

```gdscript
var field := Anima.field()
    .circle(pointer_position, 180.0)
    .falloff(Ease.out_cubic())
```

## 28.3 Reason for deferral

Motion Fields depend on stable:

* Group target resolution.
* Dynamic values.
* Spatial ordering.
* Progress evaluation.
* Runtime inspection.

They should be reconsidered after those foundations are proven.

---

# 29. Canonical model additions

## 29.1 Motion types

```text
AnimaKeyframeMotion
AnimaLayoutMotion
AnimaMarkerMotion
```

Visual state transitions may initially be represented through existing compositional motions.

## 29.2 Value resources

```text
AnimaValue
AnimaConstantValue
AnimaPropertyValue
AnimaContextValue
AnimaCallableValue
AnimaArithmeticValue
AnimaVectorComponentValue
```

## 29.3 Runtime records

```text
AnimaExecutionRecord
AnimaResolvedValueRecord
AnimaSnapshotRecord
AnimaMarkerRecord
AnimaLayoutSnapshot
AnimaPropertyOwnershipRecord
AnimaSpeedResolutionRecord
```

## 29.4 Playback result

```gdscript
enum AnimaPlaybackResult {
    COMPLETED,
    CANCELLED,
    REVERTED,
    TARGET_LOST,
    FAILED,
}
```

## 29.5 Playback state

```gdscript
enum AnimaPlaybackState {
    PREPARED,
    PLAYING,
    PAUSED,
    REVERSING,
    COMPLETING,
    REVERTING,
    COMPLETED,
    CANCELLED,
    FAILED,
}
```

---

# 30. Compiler requirements

## 30.1 Keyframes

Static keyframe motions should compile to native Animation tracks.

## 30.2 Dynamic values

Dynamic values may compile when:

* Targets are statically resolvable.
* Values can be resolved during compilation.
* Resolution does not depend on runtime-only context.

Otherwise, the compiler should report runtime evaluation.

## 30.3 Layout transitions

Mutation-based layout transitions are generally runtime-driven.

Captured static transitions may be compiled later, but this is not required initially.

## 30.4 Markers

Markers may compile to:

* Method tracks.
* Metadata.
* Anima runtime marker adapters.

The compiler must preserve semantics or report loss.

## 30.5 Speed

Authored forward and reverse speeds must be retained in Anima metadata.

A compiled fixed native animation may represent only one baked timing direction unless the output includes separate forward and backward variants.

The compiler should report:

```text
Forward compilation:
    Supported

Backward compilation:
    Supported through native reverse playback

Reverse speed:
    Runtime playback multiplier required
```

---

# 31. Motion Composer additions

The Composer should add:

## 31.1 Keyframes

* Percentage keyframes.
* Property tracks.
* Per-segment easing.
* Dynamic-value badges.
* Forward and reverse preview.

## 31.2 Layout

* Before and after bounds.
* Movement paths.
* Added and removed targets.
* Nested-container behaviour.
* Clip warnings.

## 31.3 Markers

* Add marker.
* Rename marker.
* Seek to marker.
* Play between markers.
* Direction policy.

## 31.4 Playback controls

* Progress scrubber.
* Time field.
* Forward speed.
* Reverse speed.
* Preview speed.
* Play forwards.
* Play backwards.
* Reverse current playback.
* Complete.
* Cancel.
* Revert.

## 31.5 Snapshot inspection

* Captured property values.
* Captured layout.
* Logical value.
* Visual value.
* Restore preview.

## 31.6 Showcase capture mode

The Composer or example shell may expose a capture mode that:

* Hides editor-only overlays.
* Resets the motion.
* Selects a fixed seed.
* Runs one exact loop.
* Uses configured preview speed.
* Stops at the defined boundary.

This is optional for the first Composer release but should be supported by shared example tooling.

---

# 32. Migration requirements

## 32.1 CSS-style keyframes

Existing flattened data should migrate to `AnimaKeyframeMotion`.

## 32.2 Dynamic expressions

Existing string expressions should either continue through a compatibility parser or be converted into typed value graphs.

## 32.3 Group and grid dynamic values

Per-item resolution must be preserved.

## 32.4 Reverse behaviour

Converted keyframe and dynamic-value motions must include reversibility validation.

## 32.5 Existing examples

Representative Anima V1 examples should be recreated rather than merely copied.

Each migrated example should identify:

* The V1 capability.
* The Anima 2 equivalent.
* Any intentional API change.
* Any behavioural improvement.
* Any unsupported legacy behaviour.

---

# 33. Performance requirements

## 33.1 Keyframes

* Avoid rebuilding sorted keyframe data every frame.
* Cache normalised tracks.
* Evaluate only active properties.

## 33.2 Dynamic values

* Resolve once according to timing policy.
* Avoid repeated path parsing.
* Cache validated property accessors.
* Record results efficiently.

## 33.3 Layout

* Capture only relevant controls.
* Avoid recurring layout allocations.
* Pool temporary overlays where practical.
* Support at least 100 moving UI items without a visible scheduling hitch on reference desktop hardware.

## 33.4 Seeking

Repeated scrubbing should avoid reconstructing the complete graph for every progress change.

## 33.5 Speed

Speed changes should not rebuild the authored motion graph.

Direction changes may update scheduling state but should reuse existing motion definitions and execution records.

## 33.6 Examples

Showcase polish must not hide poor runtime performance.

Every showcase should be profiled with:

* Debug tracing disabled.
* Debug tracing enabled.
* Normal speed.
* Maximum supported showcase speed.
* Repeated loop playback.

---

# 34. Testing requirements

## 34.1 Keyframes

Test:

* `from` and `to`.
* Grouped offsets.
* Unsorted declarations.
* Duplicate offsets.
* Multiple properties.
* Segment easing.
* Forward playback.
* Reverse playback.
* Native compilation.

## 34.2 Dynamic values

Test:

* Target property.
* Relative node.
* Context value.
* Arithmetic.
* Group per-item resolution.
* Motion-start resolution.
* Playback-start resolution.
* Reverse uses recorded values.
* Legacy string parsing.

## 34.3 Layout

Test:

* VBox expansion.
* HBox reordering.
* Grid sorting.
* Column changes.
* Added item.
* Removed item.
* Reparenting.
* Nested containers.
* Clipping.
* Mid-flight mutation.
* Revert.
* Reduced-motion completion.

## 34.4 Markers

Test:

* Forward crossing.
* Backward crossing.
* Seek policies.
* Loop markers.
* Completion crossing.
* Cancellation before marker.
* Speed changes before marker.

## 34.5 Speed

Test:

* Default speed.
* General playback speed.
* Forward speed.
* Reverse speed.
* Mid-flight reversal.
* Nested speed multiplication.
* Group stagger scaling.
* Sequential-gap scaling.
* Marker timing.
* Manual stepping.
* Spring simulation speed.
* Invalid zero or negative speeds.
* Reduced-motion override.

## 34.6 Showcase loops

Test:

* Initial and final logical state equality.
* Initial and final visual state equality.
* No callback duplication.
* No temporary-node leakage.
* No random-order change with fixed seed.
* No visible boundary jump.
* One hundred consecutive loops.
* Capture duration matches manifest.

---

# 35. Delivery roadmap

## Phase A — Keyframes and dynamic values

Deliver:

* `AnimaKeyframeMotion`.
* CSS-style input.
* Grouped offsets.
* Typed `AnimaValue`.
* Arithmetic values.
* Group-item resolution.
* Legacy expression parser.
* Execution-value records.

## Phase B — Playback safety and speed foundation

Deliver:

* Pre-animation snapshots.
* `cancel()`.
* `complete()`.
* `revert()`.
* Progress evaluation.
* Seeking.
* Manual clock.
* Lifecycle cleanup.
* General playback speed.
* Forward speed.
* Reverse speed.
* Effective-speed inspection.

Exit criteria:

* Motion can be safely interrupted, reversed, sped up, completed and restored.

## Phase C — Markers and gameplay integration

Deliver:

* Named markers.
* Awaitable marker signals.
* Marker seeking.
* Event policies.
* Loop and direction data.

## Phase D — Automatic layout transitions

Deliver:

* Before-and-after capture.
* Container-safe visual transforms.
* Move and resize.
* Added-item entrance.
* Removed-item exit.
* Interruption retargeting.
* Reduced-motion behaviour.

## Phase E — Group distribution and production tooling

Deliver:

* Eased stagger.
* Group origins.
* Equal-rank waves.
* Motion Inspector.
* Conflict reports.
* Dynamic-value tracing.
* Layout tracing.

## Phase F — Visual states

Deliver:

* Named visual states.
* Automatic retargeting.
* Reversal optimisation.
* `AnimaBehaviour` integration.
* Optional explicit transitions.

## Phase G — Example and showcase project

This work should begin early rather than waiting until every feature is complete.

Deliver incrementally:

### G1 — Shared example infrastructure

* Demo shell.
* Reset contract.
* Loop controller.
* Capture manifest.
* Debug overlay.
* Speed controls.
* Reduced-motion toggle.

### G2 — Minimal examples

One focused example per stable core capability.

### G3 — Practical examples

* Responsive Inventory.
* Elastic Menu.
* Signal Strike.
* Drag-controlled drawer.

### G4 — 2D showcases

* Grid Bloom.
* Card Cascade.
* Kinetic Typography.

### G5 — 3D showcases

* Kinetic Totems.
* Orbiting Crystals.
* Satisfying Assembly.

### G6 — Artifact pipeline

* Master captures.
* Documentation loops.
* Social crops.
* Poster frames.
* Verification artifacts.

Showcase work must follow feature stability. It must not delay runtime foundations.

---

# 36. Scope guardrails

The following should not block the first useful release:

* Additive layer implementation.
* Motion Fields.
* Full state-machine editor.
* Every-frame dynamic tracking.
* Live group membership.
* Perfect visual snapshots for every node type.
* Native compilation of runtime layout mutations.
* General-purpose expression language.
* Large numbers of elaborate showcase scenes.
* Bespoke art production.
* A custom video editor or capture application.

Start with a small set of reusable, high-quality examples rather than a large gallery of shallow demonstrations.

---

# 37. Final product definition

This addendum expands Anima into a production-oriented interaction-motion system.

The combined capability is:

> **Define motion through convenient properties, CSS-style keyframes, dynamic runtime values, groups, layouts and relational composition; then play, reverse, accelerate, seek, interrupt, complete, restore and inspect it safely.**

The strongest product promise is:

> **Developers describe the state change they want. Anima handles the motion structure, runtime values, direction, timing, layout differences and lifecycle required to reach it safely.**

The showcase promise is:

> **Every important Anima capability should have an example that is useful to developers, attractive enough to remember and reusable as documentation, marketing and verification material.**
