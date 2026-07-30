# Anima Target-Bound Convenience API — Product Requirements Document

**Product:** Anima 2
**Feature:** `Anima.on()` target-bound motion API
**Status:** Draft
**Primary platform:** Godot 4.x
**Primary language:** GDScript
**Related systems:** `AnimaMotion`, `AnimaPropertyMotion`, relational choreography, Group Animation, Motion Composer

---

# 1. Executive summary

Anima 2 will provide a high-level target-bound API through:

```gdscript
Anima.on(target)
```

The API allows developers to create common property animations using discoverable methods such as:

```gdscript
Anima.on($Panel)
    .position(Vector2.ZERO, 0.4)

Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)

Anima.on($Icon)
    .scale(Vector2.ONE, 0.25)
    .ease(Ease.out_back())
```

`Anima.on()` is not a separate runtime or animation model.

It is a convenience facade that creates normal `AnimaMotion` resources—primarily `AnimaPropertyMotion`—using a target that has already been bound.

Conceptually:

```text
Anima.on(target)
        ↓
Target-bound motion factory
        ↓
Creates AnimaMotion resources
        ↓
Composed through then(), with(), Sequence, Parallel or Group
        ↓
Executed by AnimaPlayback
```

The feature should preserve the developer friendliness of the original Anima API while benefiting from Anima 2’s:

* Typed resources.
* Reusable motion definitions.
* Visual editing.
* Validation.
* Reversal.
* Interruptible playback.
* Native Animation compilation.
* Group-animation support.

The primary design principle is:

> **`Anima.on()` should make common property animation concise and discoverable without creating a second motion architecture.**

---

# 2. Problem statement

## 2.1 Generic property animation is flexible but verbose

The universal API may look like:

```gdscript
Motion.animate(
    $Panel,
    ^"modulate:a",
    1.0
)
    .duration(0.3)
    .ease(Ease.out_cubic())
```

This supports arbitrary properties, but requires developers to know:

* The exact property path.
* The correct property type.
* How common visual concepts map to Godot properties.
* That opacity is represented through `modulate:a`.
* Which property differs between `Control`, `Node2D` and `Node3D`.

For common operations, this creates unnecessary friction.

## 2.2 Long positional signatures become difficult to read

An API such as:

```gdscript
Anima.to(
    $Panel,
    ^"modulate:a",
    1.0,
    0.3,
    Ease.out_cubic()
)
```

requires developers to remember whether arguments mean:

```text
target
property
destination
duration
easing
```

Adding an explicit starting value would make the signature even less readable.

Anima should avoid positional arguments for optional motion behaviour.

## 2.3 Existing Anima users expect property conveniences

Previous Anima versions offered target-specific convenience APIs such as:

```gdscript
Anima.Node($Panel)
    .position(final_position, duration)
```

This API was discoverable and readable.

Anima 2 should preserve that benefit rather than forcing all developers to work directly with property paths and resource internals.

## 2.4 Convenience APIs can accidentally become separate systems

If `Anima.on()` implements its own:

* Playback.
* Reversal.
* Easing.
* Interruption.
* Scheduling.
* Property ownership.

it would duplicate the `Motion` architecture and create two implementations that must remain synchronised.

The convenience API must translate directly into the canonical motion-resource model.

## 2.5 Supporting every Godot property would be unsustainable

Creating a convenience method for every property on every Godot class would produce:

* A large API surface.
* Frequent compatibility work.
* Inconsistent coverage.
* Documentation complexity.
* A maintenance problem similar to creating custom animated subclasses.

The convenience API should cover common visual motion concepts while retaining a generic escape hatch.

---

# 3. Product definition

`Anima.on(target)` returns an `AnimaTargetMotionFactory`.

```gdscript
var panel_motion := Anima.on($Panel)
```

The factory is bound to one target but contains no active animation or mutable playback state.

Calling a property method creates a new motion:

```gdscript
var fade := panel_motion.opacity(1.0, 0.3)
var move := panel_motion.position(Vector2.ZERO, 0.4)
```

Both motions target the same node, but they are separate `AnimaMotion` definitions.

The factory may be reused safely:

```gdscript
var panel := Anima.on($Panel)

var enter_position := panel.position(Vector2.ZERO, 0.4)
var enter_opacity := panel.opacity(1.0, 0.25)
var exit_opacity := panel.opacity(0.0, 0.2)
```

The result of each convenience method should be equivalent to using `Motion.animate()`.

Example:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

must produce the same canonical motion as:

```gdscript
Motion.animate(
    $Panel,
    ^"modulate:a",
    1.0
)
    .duration(0.3)
```

---

# 4. Goals

## G1 — Make common property animation concise

Developers should be able to animate common visual properties without writing raw property paths.

## G2 — Improve discoverability

Autocomplete should expose supported motion concepts such as:

* Position.
* Scale.
* Rotation.
* Opacity.
* Colour.
* Size.

## G3 — Preserve Anima V1 familiarity

Existing users should recognise the API as an evolution of the original target-based convenience layer.

## G4 — Use the canonical motion model

Every convenience method must create a normal `AnimaMotion` resource.

## G5 — Support relational composition

Motions created through `Anima.on()` must work with:

* `then()`.
* `with()`.
* Sequence.
* Parallel.
* Groups.
* Stagger.
* Reverse playback.

## G6 — Support reusable target factories

A bound target factory may create multiple independent motions safely.

## G7 — Keep positional arguments understandable

Property methods may use:

```text
destination
optional duration
```

All other behaviour should use named fluent modifiers.

## G8 — Provide a generic escape hatch

Unsupported properties must remain animatable through:

* `.property()`.
* `Motion.animate()`.

## G9 — Work with group-item targets

The same semantic property API should support `Anima.item()` for Group Animation.

---

# 5. Non-goals

The initial `Anima.on()` implementation will not:

* Expose every property of every Godot class.
* Replace `Motion.animate()`.
* Implement its own runtime.
* Implement its own easing engine.
* Immediately play a motion by default.
* Allow arbitrary consecutive property methods to silently become parallel.
* Guarantee compile-time type checking for every property.
* Automatically infer unsupported custom-script properties.
* Mutate the target when the motion is created.
* Store playback state inside the target factory.
* Modify Godot node classes.
* Add methods directly to `Control`, `Node2D` or `Node3D`.

---

# 6. Terminology

## 6.1 Target-bound factory

The object returned from:

```gdscript
Anima.on(target)
```

It stores the target reference and creates motion definitions.

## 6.2 Convenience property method

A named method representing a common visual property:

```gdscript
.position(...)
.opacity(...)
.scale(...)
```

## 6.3 Generic property method

A method accepting an arbitrary property path:

```gdscript
.property(^"theme_override_constants/separation", 24, 0.3)
```

## 6.4 Motion modifier

A fluent operation applied to the created motion:

```gdscript
.from(...)
.ease(...)
.delay(...)
.interruption(...)
```

## 6.5 Canonical motion

The underlying `AnimaMotion` resource created by the convenience API.

---

# 7. Primary user stories

## US1 — Animate opacity without knowing Godot’s property path

As a developer, I want to animate opacity through a named method so that I do not need to remember `modulate:a`.

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

## US2 — Define an explicit starting value

As a developer, I want to define the initial value clearly without adding another positional argument.

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)
```

## US3 — Compose multiple target-bound motions

As a developer, I want to use `then()` and `with()` with motions created through `Anima.on()`.

```gdscript
Anima.begin(self)
    .then(
        Anima.on($Title)
            .opacity(1.0, 0.2)
            .from(0.0)
    )
    .with(
        Anima.on($Panel)
            .position(Vector2.ZERO, 0.4)
            .from(Vector2(0, 80))
    )
    .play()
```

## US4 — Reuse a target-bound factory

As a developer, I want to bind a node once and create several different motions.

```gdscript
var panel := Anima.on($Panel)

var enter := panel.opacity(1.0, 0.3)
var exit := panel.opacity(0.0, 0.2)
var move := panel.position(Vector2.ZERO, 0.4)
```

## US5 — Animate an uncommon property

As a developer, I want to use the same target-bound API for a property not covered by a convenience method.

```gdscript
Anima.on($Panel)
    .property(
        ^"theme_override_constants/separation",
        24,
        0.3
    )
```

## US6 — Apply the convenience API to Group items

As a developer, I want to define an item motion without binding it to one fixed node.

```gdscript
Anima.group($Buttons.get_children())
    .apply(
        Anima.item()
            .opacity(1.0, 0.2)
            .from(0.0)
    )
    .stagger(0.05)
```

## US7 — Reverse a convenience motion

As a developer, I want a motion created through `Anima.on()` to support normal Anima reversal.

```gdscript
var playback := Anima.play(
    Anima.on($Panel)
        .opacity(1.0, 0.3)
        .from(0.0)
)

playback.reverse()
```

---

# 8. API hierarchy

Anima should expose three motion-authoring levels.

## 8.1 Level 1 — `Anima.on()`

Primary convenience API for common animation.

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

Recommended for:

* Tutorials.
* Common UI animation.
* Game-code choreography.
* Discoverability.
* Existing Anima users.

## 8.2 Level 2 — `Motion`

Universal property and structural API.

```gdscript
Motion.animate(
    $Panel,
    ^"theme_override_constants/separation",
    24
)
    .duration(0.3)
```

Recommended for:

* Arbitrary properties.
* Custom scripts.
* Resource construction.
* Structural composition.
* Plugin extensions.
* Advanced users.

## 8.3 Level 3 — Explicit resource classes

```gdscript
var motion := AnimaPropertyMotion.new()
motion.target = ...
motion.property = ^"modulate:a"
motion.to_value = 1.0
motion.duration = 0.3
```

Recommended for:

* Motion Composer.
* Compiler.
* Migration tools.
* Tests.
* Extension authors.

All three levels must create equivalent resources.

---

# 9. Core API

## 9.1 Entry point

```gdscript
static func on(target: Node) -> AnimaTargetMotionFactory
```

Example:

```gdscript
var panel := Anima.on($Panel)
```

Validation:

* Target must not be `null`.
* Target may be outside the scene tree when creating the motion.
* Target validity is rechecked when playback begins.
* Persistent resources should store a target reference rather than a live object reference.

## 9.2 Factory class

```gdscript
class_name AnimaTargetMotionFactory
extends RefCounted
```

Internal fields:

```gdscript
var _target_reference: AnimaTargetReference
```

The factory must not contain:

* Current property selection.
* Current motion.
* Current duration.
* Current easing.
* Current playback.
* Current velocity.

## 9.3 Factory immutability

Every property method creates a new motion.

```gdscript
var target := Anima.on($Panel)

var opacity_motion := target.opacity(1.0, 0.3)
var position_motion := target.position(Vector2.ZERO, 0.4)
```

Calling `position()` must not modify `opacity_motion`.

## 9.4 Return type

Convenience property methods should return an `AnimaPropertyMotion` or a specialised subclass with the standard motion-modifier API.

Example:

```gdscript
func opacity(
    destination: float,
    duration: float = -1.0
) -> AnimaPropertyMotion
```

Where practical, returning `AnimaPropertyMotion` directly is preferred over maintaining a separate convenience-builder type.

---

# 10. Positional argument policy

## 10.1 Property-method rule

Convenience methods may accept:

```text
destination
optional duration
```

Example:

```gdscript
.position(Vector2.ZERO, 0.4)
.opacity(1.0, 0.3)
.scale(Vector2.ONE, 0.25)
```

## 10.2 Generic animate rule

The generic API accepts:

```text
target
property
destination
```

Example:

```gdscript
Motion.animate(
    $Panel,
    ^"modulate:a",
    1.0
)
```

## 10.3 Optional behaviour rule

These must not be positional:

* Starting value.
* Ease.
* Delay.
* Interruption.
* Relative mode.
* Reverse policy.
* Loop.
* Completion threshold.
* Playback clock.

Use fluent methods:

```gdscript
Anima.on($Panel)
    .position(Vector2.ZERO, 0.4)
    .from(Vector2(0, 80))
    .ease(Ease.out_back())
    .delay(0.1)
    .interruption(AnimaInterruption.RETARGET)
```

## 10.4 Duration default

If duration is omitted:

```gdscript
Anima.on($Panel)
    .opacity(1.0)
```

the motion should use:

1. Motion-specific override, when supplied later.
2. Node behaviour default.
3. Motion-theme default.
4. Global Anima default.

The resolved duration should not be copied into the motion prematurely when inheritance is intended.

---

# 11. Starting-value semantics

## 11.1 Default start

When `.from()` is omitted, Anima captures the property value when that motion begins.

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

If opacity is `0.4` when the motion starts:

```text
0.4 → 1.0
```

## 11.2 Explicit start

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)
```

The motion starts from `0.0`.

The target should be assigned the starting value only when the property motion itself begins.

Example:

```gdscript
Anima.begin(self)
    .wait(1.0)
    .then(
        Anima.on($Panel)
            .opacity(1.0, 0.3)
            .from(0.0)
    )
    .play()
```

The panel should not be changed to `0.0` during the one-second wait unless an explicit preparation mode requests this.

## 11.3 Relative destination

Provide explicit relative methods:

```gdscript
Anima.on($Panel)
    .move_by(Vector2(0, -20), 0.3)

Anima.on($Panel)
    .rotate_by(PI / 4.0, 0.3)
```

The destination is calculated from the property value captured when the motion begins.

## 11.4 Generic relative property

```gdscript
Anima.on($Panel)
    .property_by(
        ^"position:x",
        100.0,
        0.3
    )
```

## 11.5 Future start modes

The architecture may reserve support for:

* Current value when the child starts.
* Value captured when the parent playback starts.
* Explicit value.
* Relative to current.
* Relative to destination.
* Dynamic callable.

Only current-at-motion-start and explicit starting values are required for the initial release.

---

# 12. Initial convenience property set

The initial convenience API should focus on common visual concepts.

## 12.1 Position

```gdscript
Anima.on(target)
    .position(destination, duration)
```

Expected target types:

* `Control`.
* `Node2D`.
* `Node3D`.

Value types:

* `Vector2` for `Control`.
* `Vector2` for `Node2D`.
* `Vector3` for `Node3D`.

Because GDScript cannot provide convenient overloads for every case, the public argument may be `Variant`, with runtime and editor validation.

## 12.2 Position axes

```gdscript
.position_x(destination, duration)
.position_y(destination, duration)
.position_z(destination, duration)
```

`position_z()` is valid only for supported 3D targets.

Axis-specific methods should be included only if they materially improve common workflows.

## 12.3 Relative movement

```gdscript
.move_by(offset, duration)
```

Value type follows the target’s position type.

## 12.4 Scale

```gdscript
.scale(destination, duration)
.scale_by(offset, duration)
```

Supported:

* `Control`.
* `Node2D`.
* `Node3D`.

## 12.5 Rotation

```gdscript
.rotation(destination, duration)
.rotate_by(offset, duration)
```

Units follow Godot property conventions.

Potential convenience aliases:

```gdscript
.rotation_degrees(destination, duration)
.rotate_degrees_by(offset, duration)
```

These should only be added if the target classes expose consistent degree-based properties.

## 12.6 Opacity

```gdscript
.opacity(destination: float, duration: float = -1.0)
```

Default mapping for `CanvasItem`:

```text
modulate:a
```

The accepted destination range should normally be:

```text
0.0–1.0
```

Values outside this range should either:

* Be clamped.
* Produce validation warnings.
* Be allowed explicitly.

Recommended default:

* Allow the value.
* Warn in validation when outside the conventional range.

## 12.7 Colour

```gdscript
.colour(destination: Color, duration: float = -1.0)
```

Default mapping:

```text
modulate
```

Possible alias:

```gdscript
.color(...)
```

API naming should follow one spelling consistently. Because Godot uses `Color`, `.color()` is likely the least surprising code API.

## 12.8 Size

```gdscript
.size(destination: Vector2, duration: float = -1.0)
```

Initial support:

* `Control`.

The method must document interaction with:

* Containers.
* Minimum sizes.
* Anchors.
* Layout recalculation.

For container-controlled nodes, users should generally prefer Layout Transition rather than directly animating layout-owned size.

## 12.9 Generic property

```gdscript
.property(
    property: NodePath,
    destination: Variant,
    duration: float = -1.0
)
```

Example:

```gdscript
Anima.on($Panel)
    .property(
        ^"theme_override_constants/separation",
        24,
        0.3
    )
```

This should delegate directly to `Motion.animate()`.

## 12.10 Shader parameter

Potential convenience:

```gdscript
.shader_parameter(
    parameter: StringName,
    destination: Variant,
    duration: float = -1.0
)
```

This may use a dedicated `AnimaShaderMotion` adapter rather than a normal property path.

This method may be deferred from the minimum release.

---

# 13. Motion modifiers

Motions created through `Anima.on()` must support the same modifiers as canonical property motions.

## 13.1 Starting value

```gdscript
.from(value)
.from_current()
```

`from_current()` is optional because current-at-start is the default, but may improve explicitness.

## 13.2 Duration

```gdscript
.duration(0.3)
```

This overrides any duration passed to the convenience property method.

If both are provided:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .duration(0.5)
```

the fluent modifier should win.

The editor or debug mode may warn about redundant overrides.

## 13.3 Easing

```gdscript
.ease(Ease.out_cubic())
```

## 13.4 Delay

```gdscript
.delay(0.1)
```

## 13.5 Interruption

```gdscript
.interruption(AnimaInterruption.RETARGET)
```

## 13.6 Reversal

```gdscript
.reversibility(AnimaReversibility.AUTOMATIC)
```

Property motions should default to automatic reversal where values and easing support it.

## 13.7 Relative mode

Relative behaviour should preferably be expressed through dedicated methods such as `move_by()`.

The generic API may expose:

```gdscript
.relative()
```

but documentation should prefer semantic methods.

## 13.8 Looping

```gdscript
.repeat(3)
.alternate()
```

The exact looping API is part of the broader motion system.

---

# 14. Relational choreography integration

## 14.1 `then()`

Starts a motion after the previous step completes.

```gdscript
Anima.begin(self)
    .then(
        Anima.on($Panel)
            .opacity(1.0, 0.3)
    )
```

## 14.2 `with()`

Starts a motion alongside the most recent step.

```gdscript
Anima.begin(self)
    .then(
        Anima.on($Panel)
            .position(Vector2.ZERO, 0.4)
    )
    .with(
        Anima.on($Panel)
            .opacity(1.0, 0.25)
    )
    .play()
```

This resolves to:

```text
Parallel
├── Position
└── Opacity
```

## 14.3 Multiple `with()` calls

```gdscript
Anima.begin(self)
    .then(a)
    .with(b)
    .with(c)
    .then(d)
```

must mean:

```text
Parallel
├── A
├── B
└── C

Then D
```

## 14.4 No implicit multi-property composition

This should not be supported:

```gdscript
Anima.on($Panel)
    .position(Vector2.ZERO, 0.4)
    .opacity(1.0, 0.3)
```

because `.position()` already returns a motion, not the target factory.

Developers should use:

```gdscript
Anima.begin(self)
    .then(
        Anima.on($Panel).position(Vector2.ZERO, 0.4)
    )
    .with(
        Anima.on($Panel).opacity(1.0, 0.3)
    )
```

or:

```gdscript
Motion.parallel(
    Anima.on($Panel).position(Vector2.ZERO, 0.4),
    Anima.on($Panel).opacity(1.0, 0.3)
)
```

This keeps parallelism explicit.

---

# 15. Group-item convenience API

## 15.1 Entry point

```gdscript
Anima.item()
```

returns an `AnimaItemMotionFactory`.

The item target is resolved separately for every Group Animation target.

## 15.2 Example

```gdscript
Anima.group($Buttons.get_children())
    .apply(
        Anima.item()
            .opacity(1.0, 0.2)
            .from(0.0)
    )
    .stagger(0.05)
```

## 15.3 Canonical representation

The created property motion should contain:

```text
Target mode: Current group item
Property: modulate:a
Destination: 1.0
Duration: 0.2
Starting value: 0.0
```

## 15.4 Shared API surface

`Anima.item()` should expose the same property methods as `Anima.on()` where meaningful:

* Position.
* Move by.
* Scale.
* Rotation.
* Opacity.
* Colour.
* Size.
* Generic property.

## 15.5 Group item context

Dynamic destination values may receive group item context:

```gdscript
Anima.item()
    .opacity(
        func(context: AnimaGroupItemContext):
            return lerp(
                0.5,
                1.0,
                context.normalised_index
            ),
        0.2
    )
```

Dynamic destinations may be deferred from the minimum release, but the architecture should not prevent them.

---

# 16. Type validation

## 16.1 Validation timing

Validation should occur:

* When the motion is created, if the target and property are available.
* In the Motion Composer.
* Before playback.
* During compilation.
* At runtime if the target type has changed.

## 16.2 Type mismatch

Example:

```gdscript
Anima.on($Node3D)
    .position(Vector2.ZERO, 0.3)
```

Error:

```text
Cannot animate Node3D.position to Vector2.
Expected Vector3 but received Vector2.
```

## 16.3 Unsupported target

Example:

```gdscript
Anima.on($AudioPlayer)
    .opacity(1.0, 0.3)
```

Error:

```text
Opacity is not supported for AudioStreamPlayer.
Use property() for a supported property or select a CanvasItem target.
```

## 16.4 Missing property

Generic property:

```gdscript
Anima.on($Panel)
    .property(^"invalid_property", 10, 0.3)
```

should produce an actionable validation error before playback where possible.

## 16.5 Variant-based signatures

Because GDScript cannot provide robust overloads for all supported node classes, some convenience methods may accept `Variant`.

The API must compensate through:

* Clear documentation.
* Runtime validation.
* Editor warnings.
* Typed generated C# wrappers where practical.

---

# 17. Target-reference behaviour

## 17.1 Runtime-created motion

For motion created and played immediately:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .play()
```

the target may be stored through a runtime object reference.

## 17.2 Saved resource

For a motion saved as a resource, the target must be represented through `AnimaTargetReference`.

Potential target modes:

```text
Explicit NodePath
Relative to playback root
Current context target
Current group item
Named target
```

## 17.3 Scene portability

A saved motion should not permanently reference one live object instance.

Example:

```gdscript
var reusable := Anima.on($Panel)
    .opacity(1.0, 0.3)
```

If saved, the system should either:

* Convert the node reference to a scene-relative NodePath.
* Ask the user to select the target-resolution mode.
* Refuse to save an unsafe live reference.

## 17.4 Context-target convenience

A reusable motion may target the playback context:

```gdscript
Anima.on_target()
    .opacity(1.0, 0.3)
```

This may be useful for reusable presets.

However, this overlaps conceptually with `Anima.item()` and should be named carefully.

Potential API:

```gdscript
Anima.target()
```

This is not required for the initial `Anima.on()` release.

---

# 18. Motion Composer integration

## 18.1 Canonical display

A motion created through:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)
```

should appear in the Motion Composer as:

```text
Property Motion: Panel opacity
├── Target: Panel
├── Property: Opacity
├── From: 0.0
├── To: 1.0
├── Duration: 0.3 s
└── Ease: Default
```

## 18.2 Semantic property names

Where the property was created through a convenience method, the Composer should display the semantic name:

```text
Opacity
Position
Scale
Rotation
Colour
Size
```

rather than only the underlying Godot property path.

An advanced field may show:

```text
Underlying property: modulate:a
```

## 18.3 Round-trip editing

Editing the motion in the Composer must modify the canonical resource.

The editor is not required to regenerate the exact original source-code expression.

The resource remains the shared model.

## 18.4 API origin metadata

Optional editor-only metadata may record:

```text
Created through: Anima.on().opacity()
```

This must not affect runtime behaviour.

## 18.5 Property selector

For generic property motions, the Composer should provide:

* Searchable target-property list.
* Type information.
* Current value.
* Common-property shortcuts.
* Validation.

---

# 19. Native Animation compilation

Motions created through `Anima.on()` compile exactly like equivalent `AnimaPropertyMotion` resources.

There should be no compiler distinction between:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

and:

```gdscript
Motion.animate(
    $Panel,
    ^"modulate:a",
    1.0
)
    .duration(0.3)
```

Compilation must use the canonical property path and values.

Compiler report may retain semantic naming:

```text
Compiled property:
Panel opacity → modulate:a
```

---

# 20. Reversal and interruption

## 20.1 Reversal

Convenience motions inherit standard property reversal.

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)
```

reverses to:

```text
1.0 → 0.0
```

The easing is mirrored according to the canonical reversal rules.

## 20.2 Current-value motions

A motion without explicit `.from()` must record the resolved starting value for reversal.

Example:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

If playback starts at `0.42`, reverse playback should return to `0.42`, not an arbitrary default.

## 20.3 Interruption

Convenience motions use the standard property-ownership and interruption systems.

```gdscript
Anima.on($Panel)
    .position(Vector2.ZERO, 0.4)
    .interruption(AnimaInterruption.RETARGET)
```

No convenience-specific interruption implementation is permitted.

---

# 21. Documentation requirements

## 21.1 Getting-started documentation

The first property animation shown to new users should use:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)
    .play()
```

## 21.2 Composition documentation

Show:

```gdscript
Anima.begin(self)
    .then(
        Anima.on($Panel)
            .position(Vector2.ZERO, 0.4)
    )
    .with(
        Anima.on($Panel)
            .opacity(1.0, 0.25)
    )
    .play()
```

## 21.3 Generic-property progression

Explain the escape hatch:

```gdscript
Anima.on($Panel)
    .property(
        ^"theme_override_constants/separation",
        24,
        0.3
    )
```

Then introduce:

```gdscript
Motion.animate(...)
```

for advanced and structural work.

## 21.4 Equivalence documentation

Documentation should demonstrate that:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

is equivalent to:

```gdscript
Motion.animate(
    $Panel,
    ^"modulate:a",
    1.0
)
    .duration(0.3)
```

This helps users understand that the APIs are layered rather than competing.

## 21.5 Migration guide

Map old syntax:

```gdscript
Anima.Node($Panel)
    .position(final_position, duration)
```

to:

```gdscript
Anima.on($Panel)
    .position(final_position, duration)
```

---

# 22. Migration from Anima V1

## 22.1 Naming migration

```text
Anima.Node(target)
    ↓
Anima.on(target)
```

## 22.2 Property-method migration

Where semantics remain unchanged:

```gdscript
Anima.Node($Panel)
    .position(value, duration)
```

becomes:

```gdscript
Anima.on($Panel)
    .position(value, duration)
```

## 22.3 Generic animation migration

Old:

```gdscript
Anima.Node($Panel)
    .anima_property(^"modulate:a")
    .anima_to(1.0)
    .anima_duration(0.3)
```

Possible new form:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

or:

```gdscript
Motion.animate(
    $Panel,
    ^"modulate:a",
    1.0
)
    .duration(0.3)
```

## 22.4 Legacy aliases

Temporary migration aliases may be provided:

```gdscript
Anima.Node(target)
```

with a deprecation warning:

```text
Anima.Node() is deprecated.
Use Anima.on() instead.
```

The alias should be removed according to the broader compatibility policy.

---

# 23. Performance requirements

`Anima.on()` must add negligible runtime overhead compared with constructing the equivalent canonical motion directly.

Requirements:

* Target factory creation must be lightweight.
* Convenience methods must not allocate playback state.
* Property resolution may be cached where safe.
* No per-frame convenience-layer logic.
* Created motions must use the normal runtime evaluator.
* Reusing a target factory must not retain generated motions.

Performance comparison:

```text
Anima.on(target).opacity(...)
≈
Motion.animate(target, ^"modulate:a", ...)
```

after resource construction.

---

# 24. Testing strategy

## 24.1 Unit tests

Test:

* `Anima.on()` rejects null targets.
* Factory stores the correct target reference.
* Calling two property methods creates independent motions.
* Opacity maps to `modulate:a`.
* Position resolves correctly for `Control`.
* Position resolves correctly for `Node2D`.
* Position resolves correctly for `Node3D`.
* Scale maps correctly.
* Rotation maps correctly.
* Colour maps correctly.
* Size validates supported targets.
* Generic property delegates correctly.
* Duration parameter is applied.
* `.duration()` overrides convenience duration.
* `.from()` sets explicit start mode.
* Omitted `.from()` uses current-at-start mode.

## 24.2 Equivalence tests

For every convenience method, compare its canonical resource with the equivalent `Motion.animate()` output.

Example:

```text
Anima.on(panel).opacity(1.0, 0.3)
```

must match:

```text
Motion.animate(panel, modulate:a, 1.0).duration(0.3)
```

## 24.3 Integration tests

Test:

* Composition through `then()`.
* Composition through `with()`.
* Reverse playback.
* Mid-flight retargeting.
* Group-item usage.
* Resource serialization.
* Motion Composer editing.
* Native Animation compilation.
* Target removal before playback.
* Target removal during playback.

## 24.4 Validation tests

Test:

* Invalid target class.
* Invalid destination type.
* Missing generic property.
* Unsupported `size()` target.
* Incorrect Vector2/Vector3 position.
* Saved motion with unsafe live target reference.

---

# 25. Acceptance criteria

## 25.1 Factory behaviour

* `Anima.on(target)` returns a reusable target-bound factory.
* The factory contains no playback state.
* Every convenience method creates a new independent motion.
* Creating a motion does not mutate the target.

## 25.2 Property convenience

* Position can be animated on supported 2D and 3D targets.
* Opacity can be animated on `CanvasItem`.
* Scale can be animated on supported targets.
* Rotation can be animated on supported targets.
* Colour can be animated on `CanvasItem`.
* Size can be animated on supported `Control` targets.
* Arbitrary properties can be animated through `.property()`.

## 25.3 API readability

* Common property methods require no more than destination and optional duration.
* Starting values are expressed through `.from()`.
* Easing is expressed through `.ease()`.
* Delay is expressed through `.delay()`.
* Interruption is expressed through `.interruption()`.
* No common method requires an ambiguous five-argument signature.

## 25.4 Canonical resource integration

* Every convenience motion produces an `AnimaMotion`.
* Convenience motions can be saved.
* Convenience motions can be opened in the Motion Composer.
* Convenience motions can be compiled.
* Convenience motions can be reversed.
* Convenience motions can be composed with other motion types.

## 25.5 Group integration

* `Anima.item()` provides matching convenience property methods.
* Every Group target receives independent values and playback state.
* Item motions do not retain a fixed target.

## 25.6 Developer experience

A developer can create and play a fade using:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
    .from(0.0)
    .play()
```

A developer can create a parallel position and opacity entrance using:

```gdscript
Anima.begin(self)
    .then(
        Anima.on($Panel)
            .position(Vector2.ZERO, 0.4)
            .from(Vector2(0, 80))
    )
    .with(
        Anima.on($Panel)
            .opacity(1.0, 0.25)
            .from(0.0)
    )
    .play()
```

No raw property path should be required for these examples.

---

# 26. Delivery phases

## Phase 1 — Factory and canonical mapping

Deliver:

* `Anima.on()`.
* `AnimaTargetMotionFactory`.
* Generic `.property()`.
* Position.
* Opacity.
* Scale.
* Rotation.
* Duration.
* `.from()`.
* `.ease()` compatibility.
* Unit tests for canonical equivalence.

Exit criteria:

* Common motions create valid `AnimaPropertyMotion` resources.
* No separate runtime logic exists.

## Phase 2 — Relational and runtime integration

Deliver:

* `then()` integration.
* `with()` integration.
* Reversal.
* Interruption.
* Playback shortcuts.
* Resource serialization.

Exit criteria:

* Convenience motions behave identically to generic property motions.

## Phase 3 — Group-item API

Deliver:

* `Anima.item()`.
* Matching convenience methods.
* Group target resolution.
* Item-context validation.

Exit criteria:

* A staggered opacity group can be defined without raw property paths.

## Phase 4 — Motion Composer integration

Deliver:

* Semantic property names.
* Underlying property display.
* Target validation.
* Round-trip resource editing.
* Convenience-method migration support.

Exit criteria:

* Motions created through code are clearly represented in the Composer.

## Phase 5 — Expanded convenience set

Evaluate and potentially add:

* Size.
* Colour.
* Axis-specific position.
* Relative rotation.
* Shader parameters.
* Material properties.
* Camera-specific conveniences.

New convenience methods should only be added based on demonstrated usage.

---

# 27. Risks and mitigations

## 27.1 API duplication

**Risk:** `Anima.on()` and `Motion.animate()` diverge.

**Mitigation:**

Every convenience method must delegate to the canonical resource constructor. Maintain equivalence tests.

## 27.2 Excessive convenience methods

**Risk:** The API attempts to mirror every Godot property.

**Mitigation:**

Limit the initial set to universal visual concepts. Use `.property()` for everything else.

## 27.3 Weak typing

**Risk:** Variant-based values produce runtime errors.

**Mitigation:**

Validate immediately where possible and produce clear type-specific messages.

## 27.4 Ambiguous property semantics

**Risk:** `position()` behaves differently across `Control`, `Node2D` and `Node3D`.

**Mitigation:**

Resolve based on target type, document mappings and expose the resolved property in the Composer.

## 27.5 Target factory mistaken for playback

**Risk:** Users expect `Anima.on()` to retain animation state.

**Mitigation:**

Document it as a motion factory. Every property call creates a motion definition.

## 27.6 Implicit parallel expectations

**Risk:** Users attempt to chain `.position().opacity()`.

**Mitigation:**

Return a motion from the first property method and require explicit `with()` or `Motion.parallel()`.

## 27.7 Duration duplication

**Risk:** Duration can be supplied both positionally and through `.duration()`.

**Mitigation:**

Allow `.duration()` to override and document one style per example. Prefer the positional duration for common convenience usage.

---

# 28. Open decisions

## 28.1 Should duration remain positional?

Options:

```gdscript
Anima.on($Panel)
    .opacity(1.0, 0.3)
```

or:

```gdscript
Anima.on($Panel)
    .opacity(1.0)
    .duration(0.3)
```

Recommended:

Support both.

Use positional duration in beginner examples because the meaning is clear for a named property method.

Use `.duration()` when inherited defaults or advanced modifiers are being demonstrated.

## 28.2 Should the factory be named `Anima.on()`?

Recommended:

Yes.

It is shorter and more readable than:

```gdscript
Anima.Node(...)
Anima.target(...)
Anima.for_node(...)
```

It also avoids confusion with Godot’s `Node` type.

## 28.3 Should convenience methods return resources directly?

Recommended:

Return `AnimaPropertyMotion` directly where the standard fluent modifiers can live on the resource.

Avoid an extra builder type unless resource mutation rules make it necessary.

## 28.4 Should convenience resources be mutable?

Recommended:

During code construction, fluent methods may mutate the newly created motion and return `self`.

Once shared or saved, users should treat motion resources as definitions rather than active runtime state.

A future immutable builder may be considered if shared-resource mutation creates practical problems.

## 28.5 Should opacity map to `modulate:a` or `self_modulate:a`?

Recommended default:

```text
modulate:a
```

Potential explicit alternatives:

```gdscript
.opacity(...)
.self_opacity(...)
```

Do not add both until concrete use cases justify the extra API.

## 28.6 Should position convenience animate layout-owned Control properties?

Recommended:

Allow it with validation warnings.

For nodes controlled by a Container, suggest Layout Transition because direct position animation may be overwritten by layout.

---

# 29. Minimum viable release

The minimum useful `Anima.on()` release should contain:

1. `Anima.on(target)`.
2. Reusable target-bound factory.
3. `.position()`.
4. `.move_by()`.
5. `.scale()`.
6. `.rotation()`.
7. `.opacity()`.
8. `.color()`.
9. `.property()`.
10. Optional positional duration.
11. `.from()`.
12. `.duration()`.
13. `.ease()`.
14. `then()` and `with()` compatibility.
15. Normal reverse and interruption support.
16. Canonical equivalence tests.
17. Migration documentation from `Anima.Node()`.

`Anima.item()` may ship in the same release as Group Animation rather than the first `Anima.on()` milestone.

---

# 30. Final feature definition

> **`Anima.on()` is Anima 2’s target-bound convenience API for creating common property motions through readable, discoverable methods.**

It is built on top of the canonical `Motion` model:

```text
Anima.on(target).opacity(...)
        ↓
AnimaPropertyMotion
        ↓
Anima relational composition
        ↓
AnimaPlayback
```

The architectural boundary is:

> **`Anima.on()` names common motion concepts. `Motion` provides the universal model. Both produce the same resources and use the same runtime.**

