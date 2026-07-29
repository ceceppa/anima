The PRD below treats Anima’s current strengths—presets, advanced easing, groups/grids, reverse playback and relational composition—as assets, while moving the product away from being positioned as a Tween wrapper. The present implementation is dictionary-driven and schedules work through Godot’s Tween system, which makes a resource-based relational model a natural architectural break for the next major version.

# Anima 2 — Product Requirements Document

**Working product name:** Anima 2
**Editor name:** Anima Motion Composer
**Status:** Draft
**Product type:** Open-source Godot editor plugin and runtime library
**Primary platform:** Godot 4.x
**Primary language:** GDScript
**Optional future component:** Native GDExtension accelerator, only if justified by benchmarks

---

# 1. Executive summary

Anima began as a higher-level animation system for Godot at a time when the engine lacked convenient sequential and parallel Tween composition.

Godot now provides many of those low-level scheduling capabilities. Anima can no longer become essential by offering only more fluent Tween syntax, more presets or a larger easing catalogue.

Anima 2 will reposition the project as:

> **A relational interaction-motion system for Godot. Animations are authored as sequences, parallel groups, staggers and dependencies; timestamps are generated rather than manually maintained.**

The product will combine four major capabilities:

1. **Relational motion composition**

   * Sequence, parallel, stagger, wait, overlap, race, repeat and signal-driven events.
   * Relationships are the source of truth.
   * Absolute timestamps are derived.

2. **Responsive interaction motion**

   * Interruptible springs.
   * Velocity-preserving retargeting.
   * Smooth reversal.
   * Explicit conflict policies.
   * Layout and shared-element transitions.

3. **Reusable motion resources**

   * Motions, easings, behaviours and themes are first-class Godot resources.
   * The same resource can be created in code, edited visually, reused across scenes and compiled into native Godot animations.

4. **Anima Motion Composer**

   * A Godot editor dock for authoring relational motion.
   * A structured tree is the primary editor.
   * A generated timeline is used for preview and debugging.
   * Native Godot `Animation` clips remain editable in Godot’s existing Animation editor.

Anima 2 will not replace Godot’s Animation editor. It will sit above it as an orchestration and interaction-motion layer.

---

# 2. Product vision

## 2.1 Vision statement

Anima should make sophisticated motion feel like a native capability of every Godot node, without requiring custom copies of `Button`, `Panel`, `Container`, `Label` or other engine classes.

Developers and designers should be able to:

* Assign enter and exit motion to an ordinary Godot node.
* Animate layout changes automatically.
* Compose clips through relationships rather than timestamps.
* Use advanced easing and physical springs.
* Retarget an animation without snapping or restarting.
* Preview motion inside the Godot editor.
* Reuse motion through `.tres` resources.
* Compile static motion to a normal Godot `Animation`.
* Continue using Godot’s Animation editor for detailed property keyframes.

## 2.2 Positioning

### Godot Tween

A low-level imperative scheduling and interpolation primitive.

### Godot Animation

A timeline-first, keyframe-based animation asset.

### Anima

A declarative, relational and interaction-aware motion system.

Anima’s product category is not “Tween wrapper.”

Its category is:

> **Motion composition and interaction transitions.**

## 2.3 Product promise

A user should be able to describe intent:

```gdscript
Motion.sequence(
    Motion.fade_in(title),

    Motion.parallel(
        Motion.animation(panel_player, &"panel_enter"),
        Motion.to(background, ^"modulate:a", 0.6)
    ),

    Motion.stagger(
        buttons,
        Motion.preset(&"button_pop"),
        0.05
    )
)
```

Anima calculates the schedule:

```text
Fade title
    ↓
Panel animation and background fade together
    ↓
Buttons appear one after another
```

The user should not need to calculate or repair absolute start times.

---

# 3. Problem statement

## 3.1 Godot’s timeline model loses relationship intent

In a conventional timeline, events are placed at explicit times:

```text
Title fade:         0.00–0.30
Panel entrance:     0.30–0.80
Background fade:    0.30–0.50
Buttons stagger:    0.80–1.20
```

The timeline records when each event happens, but not why.

It does not preserve that:

* Panel entrance begins after title fade.
* Background fade starts with panel entrance.
* Button stagger begins after the parallel group completes.
* The parallel group completes when its longest child completes.

If the panel entrance duration changes, subsequent timestamps may need manual repair.

Anima should preserve these relationships explicitly.

## 3.2 Duration-based easing is insufficient for interaction motion

A duration and easing curve work for a static entrance animation.

They are weaker for interactions:

* Hover begins, then ends halfway through.
* A drag target changes while the object is still moving.
* A menu starts opening and is immediately closed.
* A card is reordered repeatedly.
* A spring is interrupted before settling.

Restarting from the current value without preserving velocity can create unnatural motion.

Anima should treat current value and velocity as part of animation state.

## 3.3 Layout animation is repeatedly hand-built

Godot developers commonly need to animate:

* Inventory item reordering.
* List insertion and deletion.
* Expanding panels.
* Responsive menu layout changes.
* Grid sorting.
* Cards moving between containers.
* Shared elements between screens.

Container-controlled positions make these transitions difficult to implement consistently.

Anima should provide automatic layout transitions as a first-class feature.

## 3.4 Existing Anima APIs are difficult to inspect and edit

Dictionary-based animation declarations are flexible, but have limitations:

* Limited autocomplete.
* String-based property names.
* Weak static analysis.
* Harder refactoring.
* No natural editor representation.
* Difficult resource reuse.
* No single source shared by visual and code workflows.

Anima should use typed resources and typed builders.

## 3.5 Custom animated node subclasses do not scale

Creating `AnimatedButton`, `AnimatedPanel`, `AnimatedContainer` and similar classes leads to:

* Duplicate engine node types.
* Conflicts with user scripts and other plugins.
* A large maintenance surface.
* Poor compatibility with existing scenes.
* Confusing node selection.
* Repeated implementation.

Anima should extend nodes through composition while making the capability appear native in the Inspector.

## 3.6 Rebuilding Godot’s complete Animation editor is wasteful

Godot’s existing editor already handles:

* Property selection.
* Keyframe insertion.
* Timeline scrubbing.
* Method tracks.
* Audio tracks.
* Native `Animation` resources.
* `AnimationPlayer` workflows.

Anima should not duplicate all of this.

It should add the relational orchestration layer that Godot does not provide.

---

# 4. Goals

## 4.1 Primary goals

### G1 — Establish relational composition as Anima’s source of truth

Users can author animations through relationships such as:

* Sequence.
* Parallel.
* Stagger.
* Delay.
* Overlap.
* Repeat.
* Wait for signal.
* Race.
* Conditional execution.

Absolute times are calculated.

### G2 — Make motion reusable and editable

Motion definitions are saved as typed Godot resources.

The same resource can be:

* Created through code.
* Edited in the Anima Motion Composer.
* Assigned in the Inspector.
* Shared between nodes.
* Nested inside other motions.
* Compiled to a native Godot `Animation`.

### G3 — Make interaction motion interruptible

Anima supports:

* Retargeting.
* Velocity preservation.
* Reversal.
* Replacement.
* Queueing.
* Blending where feasible.
* Cancellation.
* Per-property ownership.

### G4 — Make layout transitions automatic

Ordinary `Control` nodes can animate layout changes without being replaced by custom subclasses.

### G5 — Integrate with Godot rather than isolate users

Anima must support native Godot animations as motion events and compile static Anima motion into standard `Animation` resources.

### G6 — Provide a native-feeling visual workflow

The Motion Composer should feel consistent with the Godot editor while remaining independent from unsupported Animation-editor internals.

### G7 — Remain sustainable for a small maintainer team

The core release must:

* Avoid a mandatory engine fork.
* Avoid mandatory platform-specific binaries.
* Avoid duplicating every Godot node.
* Avoid depending on undocumented editor-tree traversal.
* Minimise per-version maintenance.

---

# 5. Non-goals

Anima 2 will not initially:

* Replace Godot’s Animation editor.
* Replace `AnimationTree`.
* Replace skeletal animation systems.
* Implement a complete vector-animation renderer.
* Implement Rive, Spine or Lottie rendering.
* Ship a custom Godot engine build.
* Require a C++ runtime.
* Automatically intercept every property assignment on every Godot object.
* Provide a full unrestricted visual programming graph.
* Rebuild audio, method and skeletal track editors.
* Guarantee lossless conversion from arbitrary Godot timelines back into relational motion.
* Make every dynamic interaction motion compile into a fixed timeline.
* Add multiplayer replication semantics.
* Add a cloud service or proprietary format.

---

# 6. Product principles

## 6.1 Relationships before timestamps

The user expresses:

* “After this.”
* “With this.”
* “When all finish.”
* “Start shortly before the previous event ends.”
* “Wait for this signal.”

The compiler determines exact times when possible.

## 6.2 Composition over inheritance

Anima capabilities attach to ordinary Godot nodes.

Users should not need:

* `AnimatedButton`.
* `AnimatedPanel`.
* `AnimatedContainer`.
* `AnimatedLabel`.

## 6.3 Static motion compiles; dynamic motion stays dynamic

Static motion should compile to native Godot assets.

Motion requiring runtime state remains Anima-native:

* Velocity-preserving springs.
* Interactive retargeting.
* Signal waits.
* Dynamic layout transitions.
* Shared-element transitions.
* Gesture-controlled motion.

## 6.4 One data model, multiple authoring surfaces

Code, Inspector and Motion Composer must all generate the same `AnimaMotion` resource model.

No separate visual-only format.

## 6.5 Godot-native where possible

Use:

* `Resource`.
* `NodePath`.
* `StringName`.
* `Animation`.
* `AnimationPlayer`.
* `EditorInspectorPlugin`.
* `EditorUndoRedoManager`.
* Standard Godot serialization.

## 6.6 Graceful degradation

Unsupported integration must fail safely.

Optional editor conveniences must not be required for runtime correctness.

## 6.7 Motion should remain comprehensible

The editor should reveal:

* Execution order.
* Parallel groups.
* Derived duration.
* Critical path.
* Delays and overlaps.
* Runtime-only events.
* Compiler output type.

---

# 7. Target users

## 7.1 Solo game developer

Needs polished UI motion without building an animation framework.

Primary needs:

* Presets.
* Enter/exit animations.
* Layout transitions.
* Simple visual authoring.
* Minimal setup.

## 7.2 Gameplay programmer

Needs responsive, interruptible motion.

Primary needs:

* Typed API.
* Retargetable springs.
* Callbacks and signals.
* Runtime control.
* Deterministic behaviour.
* Debugging tools.

## 7.3 UI designer or technical designer

Needs to create and tune motion visually.

Primary needs:

* Live preview.
* Easing studio.
* Inspector controls.
* Reusable motion resources.
* Minimal code.
* Device-size previews.

## 7.4 Tool developer

Needs to integrate custom animation sources.

Primary needs:

* Adapter interface.
* Compiler API.
* Custom motion event types.
* Resource extensibility.

## 7.5 Existing Anima user

Needs a migration path that preserves the conceptual value of existing animations.

Primary needs:

* Compatibility guide.
* Conversion utilities.
* Preset continuity.
* Clear breaking-change documentation.

---

# 8. Core user journeys

## 8.1 Add enter and exit motion to an existing node

1. User selects an ordinary `Panel`.
2. The Inspector displays an **Anima** section.
3. User selects **Enable Anima**.
4. User assigns:

   * `panel_enter.tres`.
   * `panel_exit.tres`.
5. User previews both motions in the editor.
6. At runtime:

```gdscript
await Anima.enter($Panel)
await Anima.exit($Panel)
```

No custom node type is required.

## 8.2 Compose a dialog entrance

1. User creates an `AnimaMotion`.
2. User adds a Sequence.
3. User adds a Parallel group.
4. User references an existing Godot `Animation` for the panel.
5. User adds an Anima opacity transition for the background.
6. User adds a Stagger group for buttons.
7. User previews the generated timeline.
8. User changes the panel animation duration.
9. Downstream events move automatically.
10. User saves the motion as `dialog_enter.tres`.

## 8.3 Animate a reordered inventory grid

1. User enables automatic layout transition on a `GridContainer`.
2. User changes child order.
3. The container performs its normal layout.
4. Anima captures the previous and new rectangles.
5. Children visually animate from old positions to new positions.
6. Repeated changes retarget smoothly.

## 8.4 Create a responsive hover animation

1. User assigns a spring scale behaviour to a button’s hover state.
2. Pointer enters.
3. The button begins scaling up.
4. Pointer exits before completion.
5. Motion reverses or retargets while preserving velocity.
6. No snap or restart occurs.

## 8.5 Compile an Anima clip to native Animation

1. User opens an `AnimaMotion`.
2. User selects **Compile to Animation**.
3. Compiler analyses every channel.
4. Native-compatible channels use ordinary tracks.
5. Suitable scalar curves use piecewise Bézier tracks.
6. Complex curves use adaptive sampled keys.
7. Runtime-only events are reported.
8. A normal Godot `Animation` resource is generated.

## 8.6 Edit a native clip from the Motion Composer

1. A motion event references `dialog_open` on an `AnimationPlayer`.
2. User double-clicks the event.
3. Godot selects the relevant player and clip.
4. Godot’s native Animation panel opens.
5. User edits keyframes.
6. The Anima Motion Composer updates the derived duration.

---

# 9. Functional scope

The product is divided into eight major systems:

1. Motion resource model.
2. Relational scheduler and runtime.
3. Easing and physical-motion system.
4. Layout and shared-element transitions.
5. Composition-based node behaviour.
6. Native Animation compiler and integration.
7. Anima Motion Composer.
8. Preset, adapter and extension ecosystem.

---

# 10. Motion resource model

## 10.1 Base resource

```gdscript
class_name AnimaMotion
extends Resource
```

Common fields:

```gdscript
@export var display_name: String
@export var enabled := true
@export var delay := 0.0
@export var speed := 1.0
@export var tags: PackedStringArray
@export var metadata: Dictionary
```

Common runtime methods:

```gdscript
func estimate_duration(context: AnimaContext) -> AnimaDuration
func create_runtime(context: AnimaContext) -> AnimaMotionInstance
func validate(context: AnimaContext) -> Array[AnimaIssue]
```

## 10.2 Composite motion types

### AnimaSequence

Runs children one after another.

```gdscript
class_name AnimaSequence
extends AnimaMotion

@export var children: Array[AnimaMotion]
```

Completion occurs when the final enabled child completes.

### AnimaParallel

Starts children together.

```gdscript
class_name AnimaParallel
extends AnimaMotion

enum CompletionPolicy {
    ALL_CHILDREN,
    FIRST_CHILD,
    NAMED_CHILD
}

@export var children: Array[AnimaMotion]
@export var completion_policy := CompletionPolicy.ALL_CHILDREN
@export var named_completion_child: StringName
```

For `ALL_CHILDREN`, duration is the longest child duration.

### AnimaStagger

Creates repeated or mapped child motion with relative offsets.

```gdscript
class_name AnimaStagger
extends AnimaMotion

enum Order {
    FORWARD,
    REVERSE,
    FROM_CENTER,
    FROM_EDGES,
    RANDOM,
    CUSTOM
}

@export var template: AnimaMotion
@export var interval := 0.05
@export var order := Order.FORWARD
@export var selector: AnimaTargetSelector
```

### AnimaRepeat

Repeats a child motion.

```gdscript
@export var child: AnimaMotion
@export var count := 1
@export var delay_between := 0.0
@export var alternate := false
```

### AnimaRace

Runs children concurrently and completes when the first completion condition is met.

```gdscript
@export var children: Array[AnimaMotion]
@export var cancel_remaining := true
```

### AnimaConditional

Selects a branch at runtime.

```gdscript
@export var condition: AnimaCondition
@export var when_true: AnimaMotion
@export var when_false: AnimaMotion
```

This type is runtime-only unless the condition is resolvable at compile time.

## 10.3 Leaf motion types

### AnimaPropertyMotion

Animates one property.

```gdscript
@export var target: AnimaTargetReference
@export var property: NodePath
@export var from_mode: AnimaValueMode
@export var from_value: Variant
@export var to_mode: AnimaValueMode
@export var to_value: Variant
@export var duration := 0.3
@export var easing: AnimaEase
@export var relative := false
```

### AnimaKeyframeMotion

Contains property keyframes using normalised positions.

```gdscript
@export var tracks: Array[AnimaKeyframeTrack]
@export var duration := 1.0
```

### AnimaGodotAnimationMotion

References a native Godot animation.

```gdscript
@export var player_path: NodePath
@export var animation_name: StringName
@export var playback_speed := 1.0
@export var play_backwards := false
```

### AnimaSignalWait

Completes after a signal.

```gdscript
@export var target: AnimaTargetReference
@export var signal_name: StringName
@export var timeout := -1.0
```

### AnimaDelay

Waits for a duration.

### AnimaCallback

Executes a callable or method reference.

### AnimaAudioMotion

Controls an `AudioStreamPlayer`.

### AnimaShaderMotion

Animates a shader parameter.

### AnimaLayoutMotion

Executes or observes a layout transition.

### AnimaSharedElementMotion

Transitions a visual element between two layouts or scene states.

### AnimaNestedMotion

References another `AnimaMotion` resource.

## 10.4 Relationship modifiers

Composite structure should cover most relationships.

Additional timing modifiers are required.

### Start offset

Starts a child after a relative offset.

### Overlap previous

Starts before the previous child completes.

```gdscript
Motion.overlap(previous, 0.15, current)
```

Meaning:

> Begin `current` 150 milliseconds before `previous` completes.

### Start after previous begins

```gdscript
Motion.after_start(previous, 0.1, current)
```

### Completion threshold

A child may report completion based on:

* Exact end.
* Spring settled.
* Visually settled.
* Named marker.
* Signal.
* Custom callback.

---

# 11. Duration model

Not every motion has a fixed duration.

Introduce:

```gdscript
class_name AnimaDuration
extends RefCounted

enum Kind {
    FIXED,
    ESTIMATED,
    DYNAMIC,
    INFINITE
}

var kind: Kind
var seconds: float
```

Examples:

* Normal property tween: `FIXED`.
* Spring with settling prediction: `ESTIMATED`.
* Wait for signal: `DYNAMIC`.
* Infinite repeat: `INFINITE`.

The editor must visibly distinguish these states.

Timeline representations:

* Fixed: solid bar.
* Estimated: striped or softly faded edge.
* Dynamic: dashed open-ended bar.
* Infinite: bar with continuation arrow.

---

# 12. Typed code API

## 12.1 Design objectives

The public API must:

* Be concise.
* Support autocomplete.
* Prefer `NodePath` literals.
* Avoid mandatory dictionaries.
* Map directly to resources.
* Remain readable when nested.
* Work in GDScript.
* Provide a parallel C# API later.

## 12.2 Functional builder API

```gdscript
var dialog_enter := Motion.sequence(
    Motion.fade_in($Title)
        .duration(0.25)
        .ease(Ease.out_cubic()),

    Motion.parallel(
        Motion.animation($AnimationPlayer, &"dialog_open"),

        Motion.to($Background, ^"modulate:a", 0.6)
            .duration(0.2)
    ),

    Motion.stagger(
        $Buttons.get_children(),
        Motion.preset(&"button_pop"),
        0.05
    )
)
```

## 12.3 Explicit resource API

```gdscript
var sequence := AnimaSequence.new()
sequence.children = [
    title_motion,
    content_parallel,
    button_stagger,
]
```

## 12.4 Runtime API

```gdscript
var playback := Anima.play(dialog_enter, self)
await playback.finished
```

Playback controls:

```gdscript
playback.pause()
playback.resume()
playback.cancel()
playback.reverse()
playback.seek(0.5)
playback.set_speed(1.5)
```

## 12.5 Node proxy API

```gdscript
var panel := Anima.of($Panel)

panel.enter()
panel.exit()
panel.to(^"position:x", 10.0)
panel.transition_to(&"expanded")
```

The proxy provides a native-feeling surface without modifying the node class.

## 12.6 Compatibility API

An optional compatibility package may temporarily support old declarations:

```gdscript
AnimaLegacy.from_dictionary(old_definition)
```

This should return a new `AnimaMotion` and emit migration warnings.

The compatibility API must not define the new architecture.

---

# 13. Easing and physical-motion system

## 13.1 AnimaEase resource

```gdscript
class_name AnimaEase
extends Resource
```

Supported types:

* Linear.
* Polynomial.
* Sine.
* Exponential.
* Circular.
* Back.
* Bounce.
* Elastic.
* Cubic Bézier.
* Curve resource.
* Callable evaluator.
* Spring.
* Decay.
* Custom sampled curve.

## 13.2 Parameterised easing

Example:

```gdscript
Ease.spring({
    response = 0.35,
    bounce = 0.2,
    initial_velocity = 0.0
})
```

Advanced form:

```gdscript
Ease.spring_physics({
    mass = 1.0,
    stiffness = 180.0,
    damping = 18.0,
    initial_velocity = 0.0,
    settle_velocity = 0.001,
    settle_distance = 0.001
})
```

## 13.3 Spring completion

Spring motion completes when both are below configured thresholds:

* Distance from target.
* Velocity.

Completion modes:

```text
Strictly Settled
Visually Settled
Fixed Preview Duration
Manual
```

## 13.4 Retargeting

When a target changes during playback:

1. Read current value.
2. Read current velocity.
3. Preserve or transform velocity according to policy.
4. Update target.
5. Continue evaluation without resetting the state.

## 13.5 Interruption policies

```gdscript
enum AnimaInterruption {
    REPLACE,
    RETARGET,
    REVERSE,
    QUEUE,
    CANCEL,
    COMPLETE_CURRENT,
    IGNORE_NEW
}
```

### Replace

Stops current motion and starts the new motion from current value.

### Retarget

Changes target while preserving velocity where possible.

### Reverse

Reverses the active motion.

### Queue

Waits for active ownership to finish.

### Cancel

Stops active motion and leaves current value unchanged.

### Complete current

Immediately applies the current target before starting the next motion.

### Ignore new

Rejects the incoming request.

## 13.6 Property ownership

The runtime maintains ownership per target property.

Key:

```text
target instance ID + property path
```

State:

```gdscript
class AnimaPropertyState:
    var current_value: Variant
    var current_velocity: Variant
    var owner: AnimaMotionInstance
    var target_value: Variant
    var interruption_policy: int
```

This prevents two unrelated motions from silently fighting over the same property.

## 13.7 Easing Studio

The editor must provide:

* Animated preview.
* Position graph.
* Velocity graph.
* Optional acceleration graph.
* Overshoot display.
* Estimated settling time.
* Parameter controls.
* Preset comparison.
* Copy/paste values.
* Save as `AnimaEase`.
* Preview on selected node.
* Reduced-motion alternative.

---

# 14. Layout transitions

## 14.1 Objective

Animate visual changes caused by:

* Container reordering.
* Child insertion.
* Child removal.
* Size changes.
* Responsive layout.
* Visibility changes.
* Parent changes where supported.

## 14.2 FLIP-style model

The layout system will:

1. Capture old global and local rectangles.
2. Allow Godot to calculate the new layout.
3. Capture new rectangles.
4. Apply inverse visual offsets.
5. Animate offsets back to identity.

The layout assigned by Godot remains authoritative.

Anima only controls the temporary visual transformation.

## 14.3 API

Explicit transaction:

```gdscript
await Anima.layout($InventoryGrid).animate_changes(func():
    inventory.sort_custom(compare_items)
    rebuild_inventory()
)
```

Capture form:

```gdscript
var transition := Anima.capture_layout($InventoryGrid)

update_children()

transition.play()
```

Automatic form:

```text
Inspector
Anima
└── Layout Changes
    ├── Enabled
    ├── Duration
    ├── Ease
    ├── Position
    ├── Size
    ├── Scale
    ├── Rotation
    └── Interruption Policy
```

## 14.4 Repeated changes

If layout changes again before transition completion:

* Current visual state is captured.
* Existing velocities are preserved where practical.
* Targets are updated.
* No snap to the previous destination occurs.

## 14.5 Child insertion

Configurable behaviour:

* Existing children transition to new positions.
* New child plays `motion_in`.
* New child may be excluded from FLIP inversion.
* Parent may animate its size.

## 14.6 Child removal

Configurable behaviour:

* Removed child plays `motion_out`.
* Removal from the container is delayed until exit completion.
* A placeholder optionally preserves layout during exit.
* Remaining children then transition.

## 14.7 Layout transition limitations

Initial release may limit support to:

* `Control`.
* Standard Godot containers.
* Position and size.
* Nodes in the same viewport.

3D layout and arbitrary custom drawing are out of scope.

---

# 15. Shared-element transitions

## 15.1 Objective

Animate a visually related element between two UI states or scenes.

Examples:

* Inventory thumbnail to item-detail image.
* Card in a deck to enlarged card view.
* Selected character portrait to character-details screen.
* List item to modal header.

## 15.2 Identity

Nodes expose:

```gdscript
@export var motion_id: StringName
```

Because Anima cannot add actual properties to native node classes, this is stored through `AnimaBehaviour`.

Inspector:

```text
Anima
└── Shared Element
    ├── Motion ID
    ├── Include position
    ├── Include size
    ├── Include rotation
    ├── Include opacity
    ├── Include modulate
    └── Snapshot mode
```

## 15.3 Runtime process

1. Find source and destination by `motion_id`.
2. Capture source visual state.
3. Capture destination visual state.
4. Temporarily hide or mask originals.
5. Create a transition representation.
6. Animate between states.
7. Restore destination.
8. Dispose of transition representation.

## 15.4 Snapshot modes

* Live node reparenting where safe.
* Viewport texture snapshot.
* Custom adapter.
* Simple transform-only transition.

## 15.5 Scene transitions

Anima may expose:

```gdscript
await Anima.transition_scene(
    current_scene,
    next_scene,
    shared_elements = true
)
```

Scene loading remains owned by the application.

Anima only orchestrates the transition.

---

# 16. Composition that looks like inheritance

## 16.1 AnimaBehaviour resource

```gdscript
class_name AnimaBehaviour
extends Resource
```

Fields:

```gdscript
@export_group("Identity")
@export var enabled := true
@export var motion_id: StringName

@export_group("Lifecycle")
@export var motion_in: AnimaMotion
@export var motion_out: AnimaMotion
@export var play_in_on_ready := false
@export var hide_after_out := true

@export_group("Defaults")
@export var default_duration := 0.3
@export var default_ease: AnimaEase
@export var interruption := AnimaInterruption.RETARGET

@export_group("Layout")
@export var animate_layout_changes := false
@export var layout_motion: AnimaMotion

@export_group("State")
@export var state_bindings: Array[AnimaStateBinding]

@export_group("Accessibility")
@export var reduced_motion: AnimaMotion
```

## 16.2 Storage

The behaviour is associated with the target node without changing its class.

Preferred initial approach:

* Store the resource in node metadata.
* Add the node to a private Anima group for discovery.
* Use a custom Inspector plugin to expose the fields.

Metadata key:

```gdscript
const BEHAVIOUR_META := &"_anima_behaviour"
```

Group:

```gdscript
const ENABLED_GROUP := &"_anima_enabled"
```

## 16.3 Runtime state separation

`AnimaBehaviour` stores configuration only.

Per-instance runtime state is stored separately:

```gdscript
class_name AnimaNodeInstance
extends RefCounted

var target: Node
var behaviour: AnimaBehaviour
var active_playbacks: Array[AnimaPlayback]
var property_states: Dictionary
var previous_layout_rect: Rect2
```

This prevents shared resources from sharing mutable playback state.

## 16.4 Inspector presentation

Selecting an ordinary Godot node displays:

```text
Anima

Enable Anima

Lifecycle
  Motion In
  Motion Out
  Play In On Ready
  Hide After Out

Defaults
  Duration
  Ease
  Interruption

Layout
  Animate Changes
  Layout Motion

States
  Idle
  Hover
  Pressed
  Focused
  Disabled

Accessibility
  Reduced Motion
```

## 16.5 Undo and redo

All Inspector changes must use `EditorUndoRedoManager`.

Enable, disable, assign resource, remove behaviour and modify settings must be reversible.

## 16.6 Inheritance and defaults

Resolution order:

1. Node-level override.
2. Nearest parent behaviour with inheritance enabled.
3. Scene-level motion theme.
4. Project-level Anima defaults.

Fields should support:

```text
Use Override
Inherit
Use Theme Default
```

## 16.7 State bindings

Ordinary controls can bind states to motion:

```text
Idle
Hover
Pressed
Focused
Disabled
Checked
Custom
```

Example:

```text
Hover → button_hover.tres
Pressed → button_press.tres
Disabled → button_disabled.tres
```

A binding defines:

* Enter motion.
* Exit motion.
* Interruption policy.
* Priority.
* Target property set.
* Reduced-motion alternative.

## 16.8 Runtime access

```gdscript
var animated := Anima.of($Panel)

await animated.enter()
await animated.exit()
animated.transition_to(&"expanded")
animated.to(^"modulate:a", 0.5)
```

---

# 17. Runtime manager

## 17.1 No mandatory autoload

Anima should not require persistent mutation of `project.godot`.

Default behaviour:

* The first runtime request lazily creates an internal `AnimaRuntime` node.
* The node is added internally to the current scene tree.
* It is not shown as a normal application node where Godot internal-node support allows this.
* It survives scene changes where appropriate.

Optional explicit setup may be supported for advanced users.

## 17.2 Responsibilities

The runtime manager owns:

* Active playbacks.
* Per-property state.
* Layout observers.
* Signal waits.
* Behaviour registration.
* Adapter registry.
* Debug events.
* Frame updates.
* Cleanup when targets leave the tree.

## 17.3 Scheduler

The scheduler resolves motion resources into executable instances.

It must support:

* Nested sequences.
* Nested parallels.
* Dynamic child duration.
* Cancellation propagation.
* Completion policies.
* Runtime waits.
* Reverse playback where semantically supported.
* Loops.
* Speed scaling.
* Pause and resume.

## 17.4 Central process loop

Initial implementation should prefer a central evaluation loop over creating one Tween object per property.

Goals:

* Reduce allocations.
* Simplify velocity tracking.
* Support interruption.
* Make debugging deterministic.
* Allow future optimisation.

Godot Tween may still be used internally for simple compiled cases, but should not define the core runtime model.

## 17.5 Clock modes

```gdscript
enum AnimaClockMode {
    IDLE,
    PHYSICS,
    MANUAL
}
```

### Idle

Updates during normal frame processing.

### Physics

Updates on physics frames.

### Manual

Caller advances time explicitly.

Useful for:

* Tests.
* Replay.
* Deterministic previews.
* Tools.

---

# 18. Native Godot Animation integration

## 18.1 Native Animation as a first-class event

An Anima graph can reference a native `AnimationPlayer` clip.

Requirements:

* Read duration.
* Detect animation changes.
* Support forward and backward playback.
* Support speed.
* Support completion markers.
* Open the clip in Godot’s editor.
* Respect cancellation.

## 18.2 Compiler

Anima can compile compatible static motions into a normal `Animation`.

Compiler input:

```gdscript
AnimaCompiler.compile(
    motion,
    target_root,
    options
)
```

Compiler output:

```gdscript
class_name AnimaCompileResult

var animation: Animation
var report: AnimaCompileReport
var issues: Array[AnimaIssue]
```

## 18.3 Compilation modes

### Native value transitions

Use ordinary value tracks where Godot can represent the result directly.

### Piecewise Bézier

Use scalar Bézier tracks when the curve can be represented within the configured tolerance.

### Adaptive sampled keys

Use generated value keys where:

* Curve is complex.
* Property is multidimensional.
* Bézier output would be excessively complicated.
* Easing contains bounce or repeated oscillation.
* Target type is unsuitable for Bézier tracks.

### Runtime driver

Use an Anima runtime event where the behaviour fundamentally depends on runtime state.

Runtime drivers are not the default compiled output.

## 18.4 Adaptive sampling

The compiler should recursively subdivide curve segments.

Algorithm:

1. Evaluate endpoints.
2. Evaluate midpoint.
3. Compare actual midpoint with linear interpolation.
4. If error exceeds tolerance, subdivide.
5. Continue until tolerance or maximum depth.

Options:

```gdscript
class_name AnimaCompileOptions

var error_tolerance := 0.001
var max_subdivisions := 12
var prefer_bezier := true
var allow_runtime_driver := false
var preserve_source_metadata := true
```

## 18.5 Compiler report

Example:

```text
Compiled “dialog_enter”

7 channels compiled as native value tracks
2 channels compiled as Bézier tracks
1 elastic channel compiled to 22 sampled keys
1 signal wait cannot compile
0 runtime drivers generated

Output duration: 1.62 seconds
Maximum approximation error: 0.0008
```

## 18.6 Generated-resource metadata

The generated animation should include:

```text
Anima source resource UID
Source content hash
Compiler version
Compiler settings
Generated timestamp
Generated marker
```

The source `AnimaMotion` remains authoritative.

## 18.7 Rebuild workflow

The editor displays:

```text
Generated Animation
Status: Out of date
[Rebuild]
[Open Output]
[Detach From Anima]
```

Manual edits to generated assets should either:

* Mark the asset detached.
* Be overwritten only after explicit confirmation.
* Be copied into a new non-generated asset.

## 18.8 Import from Animation

A native `Animation` may be imported into Anima.

The import creates:

* A flat scheduled group.
* Leaf property motions or a native-animation reference.
* Absolute offsets where relationships cannot be inferred.

Anima must not pretend it can reconstruct lost sequence/parallel intent.

If Anima metadata exists, structured reconstruction may be attempted.

---

# 19. Anima Motion Composer

## 19.1 Objective

Provide a visual editor for relational motion without replacing Godot’s native timeline editor.

## 19.2 Primary layout

The Motion Composer contains:

1. Top toolbar.
2. Motion Structure panel.
3. Inspector panel.
4. Preview viewport.
5. Generated Timeline Preview.
6. Status and validation bar.

## 19.3 Source of truth

The **Motion Structure** is authoritative.

The timeline is derived.

The editor must clearly communicate this.

Status label:

```text
Source of truth: relational motion structure
```

## 19.4 Motion Structure panel

Tree example:

```text
Sequence
├── Fade Title
├── Parallel
│   ├── Animation: dialog_open
│   └── Spring: background opacity
├── Stagger Buttons
│   ├── Animation: button_pop / Audio
│   ├── Animation: button_pop / Video
│   └── Animation: button_pop / Controls
└── Wait for Signal: continue_button.pressed
```

Supported interactions:

* Add child.
* Delete.
* Duplicate.
* Rename.
* Reorder.
* Drag into group.
* Drag out of group.
* Wrap selection in Sequence.
* Wrap selection in Parallel.
* Wrap selection in Stagger.
* Collapse and expand.
* Disable temporarily.
* Copy and paste.
* Convert leaf type where valid.
* Extract selection into reusable motion.
* Replace with referenced resource.

## 19.5 Toolbar

Required controls:

* Preview.
* Play.
* Pause.
* Stop.
* Reset.
* Compile to Animation.
* Open native clip.
* Add Sequence.
* Add Parallel.
* Add Stagger.
* Add Motion.
* Add Wait.
* Add Callback.
* Undo.
* Redo.
* Validation.
* Composer settings.

## 19.6 Inspector panel

Tabs:

```text
General
Timing
Motion
Target
Advanced
Accessibility
```

### General

* Name.
* Type.
* Enabled.
* Tags.
* Description.

### Timing

* Delay.
* Speed.
* Completion policy.
* Start relationship.
* Overlap.
* Repeat.
* Completion threshold.

### Motion

* Easing.
* Spring settings.
* Duration.
* From and to values.
* Relative mode.
* Interruption policy.

### Target

* Target node.
* Property.
* Selector.
* Group.
* Child mapping.

### Advanced

* Clock mode.
* Update priority.
* Runtime-only flags.
* Adapter settings.
* Debug markers.

### Accessibility

* Reduced-motion alternative.
* Skip policy.
* Duration scaling.

## 19.7 Preview viewport

Capabilities:

* Preview current scene.
* Fit.
* Zoom.
* Device-size presets.
* Pause.
* Scrub.
* Reset.
* Preview selection only.
* Preview full motion.
* Show target outlines.
* Show layout rectangles.
* Show shared-element IDs.
* Show motion paths where applicable.

## 19.8 Generated timeline

The timeline displays:

* Derived start.
* Derived end.
* Duration.
* Parallel overlaps.
* Stagger distribution.
* Dynamic waits.
* Infinite events.
* Critical path.
* Playhead.
* Selection synchronisation.

The timeline should generally be read-only.

Permitted direct manipulation should create semantic relationships.

Examples:

Dragging an item earlier may create:

```text
Overlap previous by 0.10 seconds
```

Dragging an item later may create:

```text
Delay after previous: 0.15 seconds
```

The UI must not silently convert the motion into arbitrary absolute timing.

## 19.9 Critical path

For nested parallel groups, the editor highlights the child determining group completion.

Example:

```text
Parallel — duration 1.60 s
├── dialog_open — 1.20 s
└── background spring — ~1.60 s  ← critical path
```

## 19.10 Dynamic duration display

Dynamic signal wait:

```text
Wait for Signal
Duration: runtime
```

Estimated spring:

```text
Spring
Estimated settle: ~0.62 s
```

## 19.11 Native clip workflow

Double-clicking a `Godot Animation` leaf should:

1. Resolve the referenced `AnimationPlayer`.
2. Select it in the scene tree.
3. Select the animation.
4. Open Godot’s Animation panel.

The Composer should refresh when the native animation changes.

## 19.12 Easing panel

The Inspector includes a curve preview.

Modes:

* Standard ease.
* Spring.
* Bounce.
* Elastic.
* Bézier.
* Custom Curve.

Graphs:

* Position.
* Velocity.
* Optional acceleration.

Controls:

* Preset.
* Parameters.
* Save.
* Compare.
* Mirror.
* Reverse.
* Copy values.
* Reduced-motion variant.

## 19.13 Error reporting

Issues panel examples:

```text
Error: target node cannot be resolved
Warning: motion contains runtime signal wait and cannot fully compile
Warning: generated Animation is out of date
Warning: two parallel children write the same property
Info: spring duration is estimated
```

Selecting an issue focuses the relevant motion.

## 19.14 Editor persistence

The editor remembers:

* Panel sizes.
* Collapsed groups.
* Selected motion.
* Timeline zoom.
* Preview zoom.
* Inspector tab.
* Filter state.

Project data and user-local editor state must be stored separately.

---

# 20. Godot Inspector integration

## 20.1 Inspector plugin

An `EditorInspectorPlugin` will display Anima fields for supported nodes.

Initial supported classes:

* `Control`.
* `Node2D`.
* `Node3D` for basic transforms.
* `CanvasItem`.
* Nodes supported by registered adapters.

## 20.2 Enable flow

Before enabled:

```text
Anima
[Enable Anima]
```

After enabled:

```text
Anima
Lifecycle
Defaults
Layout
States
Shared Element
Accessibility

[Open Motion Composer]
[Remove Anima]
```

## 20.3 Preview actions

Buttons:

* Preview In.
* Preview Out.
* Reset.
* Open motion.
* Create new motion.
* Compile motion.

## 20.4 Scene inheritance

Behaviour overrides must work with inherited scenes.

The UI should identify:

* Local value.
* Inherited value.
* Theme value.
* Project default.

---

# 21. Preset library

## 21.1 Existing presets

Existing Anima presets should be audited and classified:

* Keep.
* Rename.
* Reimplement.
* Deprecate.
* Remove.

## 21.2 Preset resource model

Presets should be normal `AnimaMotion` resources.

Categories:

* Attention.
* Entrance.
* Exit.
* Emphasis.
* Transform.
* UI interaction.
* Layout.
* Feedback.
* Camera.
* Text.
* Reduced motion.

## 21.3 Preset browser

Features:

* Search.
* Tags.
* Preview.
* Favourites.
* Recently used.
* Filter by target type.
* Filter by runtime-only.
* Drag into Motion Structure.
* Duplicate into project.
* Create custom preset.

## 21.4 Motion themes

```gdscript
class_name AnimaMotionTheme
extends Resource
```

Theme contents:

* Duration tokens.
* Easing tokens.
* Spring tokens.
* Named motions.
* Reduced-motion mappings.
* Default interruption policy.
* Stagger intervals.

Example:

```text
Duration
  instant: 0.10
  fast: 0.18
  normal: 0.30
  slow: 0.50

Ease
  standard
  expressive
  exit
  spring-soft

Motion
  dialog-enter
  dialog-exit
  button-hover
  error-shake
```

---

# 22. Adapter system

## 22.1 Purpose

Allow external or specialised playback systems to participate in relational composition without making them part of Anima’s core.

## 22.2 Interface

```gdscript
class_name AnimaPlayableAdapter
extends RefCounted

func supports(target: Object) -> bool
func get_duration(event: AnimaMotion, context: AnimaContext) -> AnimaDuration
func create_instance(event: AnimaMotion, context: AnimaContext) -> AnimaMotionInstance
```

## 22.3 Core adapters

Initial release:

* Godot property.
* AnimationPlayer.
* AudioStreamPlayer.
* ShaderMaterial.
* Callable.
* Signal.
* Layout transition.

Later possibilities:

* AnimatedSprite.
* Camera shake.
* Particle systems.
* Dialogue system.
* Third-party animation runtimes.

## 22.4 External integrations

Anima may document integration for:

* Spine.
* Rive.
* Lottie.
* Dialogue plugins.
* State-machine plugins.

Anima will not own their rendering implementation.

---

# 23. Accessibility and reduced motion

## 23.1 Reduced-motion support

Each motion or behaviour may provide:

* Alternative motion.
* Duration scale.
* Disable motion.
* Opacity-only fallback.
* Instant transition.

## 23.2 Global setting

```gdscript
AnimaSettings.reduced_motion = true
```

Possible values:

```text
System
Enabled
Disabled
```

## 23.3 Motion validation

The editor may warn about:

* Excessive flashing.
* Large repeated movement.
* Long blocking motion.
* Missing reduced-motion alternative for important navigation.
* Infinite motion without a pause condition.

These warnings are advisory.

---

# 24. Debugging and observability

## 24.1 Runtime debugger

Optional editor panel showing:

* Active motions.
* Target.
* Property ownership.
* Current value.
* Current velocity.
* Target value.
* Elapsed time.
* Current branch.
* Waiting signals.
* Queue state.

## 24.2 Motion trace

A playback can emit a structured trace:

```text
00.000 Sequence started
00.000 Fade Title started
00.250 Fade Title completed
00.250 Parallel started
00.250 dialog_open started
00.250 background spring started
01.450 dialog_open completed
01.832 background spring visually settled
01.832 Parallel completed
```

## 24.3 Debug overlay

Optional viewport overlay:

* Target bounds.
* Layout old/new rectangles.
* Velocity vectors.
* Shared-element matching.
* Property conflicts.
* Motion IDs.

## 24.4 Logging levels

```text
Off
Errors
Warnings
Lifecycle
Verbose
```

---

# 25. Validation

## 25.1 Static validation

Validate:

* Missing targets.
* Invalid properties.
* Unsupported value types.
* Empty composites.
* Recursive motion references.
* Invalid completion child.
* Negative durations.
* Runtime-only motion in native-only compile.
* Multiple writers to the same property.
* Missing AnimationPlayer clip.
* Invalid signal.
* Infinite child inside finite sequence.
* Shared-element ID collisions.

## 25.2 Runtime validation

Detect:

* Target removed.
* Property type changed.
* Signal source freed.
* Adapter unavailable.
* Layout transition target moved across unsupported viewport.
* Compiler output stale.

---

# 26. Performance requirements

## 26.1 General principle

Do not rewrite in C++ before profiling proves a user-visible bottleneck.

## 26.2 Initial runtime targets

Provisional targets on reference desktop hardware:

* 100 concurrent property motions without measurable frame degradation.
* 1,000 lightweight property motions maintaining interactive frame rates.
* No recurring allocation per active property after initial setup where practical.
* Layout transition of 100 controls without visible hitch after capture.
* Editor preview response within one frame after scrub input for ordinary scenes.

These are validation targets, not guarantees for all hardware.

## 26.3 Benchmark suite

Scenarios:

* 10, 100, 1,000 and 10,000 scalar properties.
* Vector2 transforms.
* Colours and opacity.
* Springs.
* Repeated retargeting.
* Grid staggering.
* Layout reordering.
* Shared-element snapshots.
* Native compiled Animation comparison.
* Current Anima comparison.
* Godot Tween baseline.

Platforms:

* Desktop.
* Android.
* Web.
* Lower-end reference hardware where available.

## 26.4 Native accelerator decision gate

A GDExtension may be considered only when:

* A reproducible benchmark demonstrates a significant bottleneck.
* The bottleneck is in Anima evaluation rather than property writes or layout.
* A native implementation provides meaningful improvement.
* Build and release automation covers required platforms.
* GDScript remains a supported fallback where possible.

---

# 27. Compatibility requirements

## 27.1 Godot version policy

Define:

* Minimum supported version.
* Latest tested version.
* Compatibility branch policy.
* Deprecation policy.

The initial Anima 2 release should target one clearly stated Godot minor range rather than claiming broad compatibility without testing.

## 27.2 Automated compatibility tests

CI should cover:

* Plugin activation.
* Resource loading.
* Runtime playback.
* Editor plugin startup.
* Compiler output.
* Demo scenes.
* Headless unit tests.
* Supported Godot versions.

## 27.3 C# support

C# support is desirable but should follow a stable GDScript API.

Requirements:

* Resources remain language-independent.
* Public runtime API receives a C# wrapper.
* Generated docs show both languages where supported.
* No feature should depend on GDScript-only dictionary conventions.

---

# 28. Migration from Anima 0.x

## 28.1 Migration philosophy

Breaking changes are allowed, but existing users should not be abandoned.

## 28.2 Migration tool

Provide:

```text
Tools → Anima → Migrate Legacy Project
```

The tool scans for:

* Legacy Anima resources.
* Legacy animation definitions.
* Old class names.
* Old autoload entries.
* Old preset references.
* Legacy demo patterns.

## 28.3 Conversion output

For each migrated item:

```text
Converted automatically
Converted with warnings
Requires manual migration
Unsupported
```

## 28.4 Dictionary migration

Where possible:

```gdscript
var motion := AnimaLegacy.convert({
    node = $Panel,
    property = "opacity",
    from = 0,
    to = 1,
    duration = 0.3,
})
```

Produces:

```gdscript
AnimaPropertyMotion
```

Legacy `then` and `with` map to:

* `then` → Sequence.
* `with` → Parallel or shared start relationship.

## 28.5 Preset compatibility

Maintain a mapping:

```text
legacy preset name → new motion resource
```

Deprecated names should produce clear warnings.

## 28.6 Migration documentation

Required documentation:

* Concept mapping.
* API mapping.
* Before and after examples.
* Common edge cases.
* Removed behaviours.
* New recommended patterns.

---

# 29. Documentation requirements

## 29.1 Documentation structure

```text
Introduction
Why Anima
Installation
Five-minute tutorial
Relational composition
Motion resources
Code API
Motion Composer
Easing and springs
Interruptions
Layout transitions
Shared elements
Node behaviours
Native Animation integration
Compiler
Accessibility
Adapters
Migration
Troubleshooting
API reference
```

## 29.2 Interactive examples

Examples should include:

* Dialog entrance.
* Button interactions.
* Inventory reorder.
* Shared-element item details.
* Interruptible menu.
* Signal-driven sequence.
* Native Animation integration.
* Compile to Animation.

## 29.3 Demo project

A polished demo project should ship with:

* Motion gallery.
* Easing laboratory.
* Layout playground.
* Shared-element example.
* Runtime debugger.
* Composer example resources.

## 29.4 Documentation quality gate

No release should be published with:

* Broken links.
* Missing API pages.
* Examples incompatible with the supported Godot version.
* Unexplained required setup.

---

# 30. Installation and packaging

## 30.1 Default installation

Users install the `addons/anima` directory and enable the plugin.

## 30.2 No mandatory project mutation

The plugin must not repeatedly rewrite project settings.

Any optional project configuration must be:

* Explicit.
* Idempotent.
* Reversible.

## 30.3 Asset-store presentation

Package should include:

* Clear version compatibility.
* High-quality screenshots.
* Short demo video.
* Feature comparison based on current Godot capabilities.
* Motion Composer image.
* Installation instructions.
* Migration notice.

---

# 31. Security and safety

Anima executes callbacks and may reference signals.

Requirements:

* No arbitrary code is generated by the editor.
* Callback references are visible in resources.
* Imported resources are validated.
* Editor preview should avoid running unsafe application logic by default.
* Signal waits in editor preview should provide simulation controls.
* File writes must remain inside expected project paths.
* Generated resources must not overwrite user files without confirmation.

---

# 32. Success metrics

Because Anima is open source, measurement should not require invasive telemetry.

## 32.1 Adoption metrics

* Number of external beta projects.
* Number of production projects.
* Repeat use of multiple Anima features in the same project.
* Asset-store installs.
* GitHub releases downloaded.
* Documentation completion rate where available without tracking users invasively.

## 32.2 Product-value metrics

Target evidence:

* At least five external teams actively test the beta.
* At least three teams use Anima in a real production project.
* At least three teams use either:

  * Interruptible motion.
  * Layout transitions.
  * Relational Composer.
* Users create reusable project motion resources rather than only running presets.
* At least one external contributor adds or improves a motion type, adapter or preset.

## 32.3 Usability metrics

Observed or surveyed:

* Time from installation to first successful motion.
* Time to create a dialog entrance.
* Percentage of users who understand Sequence versus Parallel.
* Number of timeline repairs required after changing a child duration.
* Ability to identify why an event starts at a given time.
* Ability to find compiler errors.

## 32.4 Sustainability metrics

* Average maintenance effort per Godot minor release.
* Open compatibility issues.
* Time to validate a new Godot release.
* Number of platform-specific release artefacts.
* External contribution success rate.

## 32.5 Kill or reduce-scope criteria

Move the project into maintenance-focused mode if, after a meaningful public beta period:

* Relational Composer usage remains negligible.
* Real projects use only presets.
* Compatibility maintenance exceeds sustainable capacity.
* Layout and interaction features do not produce clear adoption.
* No external teams validate the new product direction.

---

# 33. Release strategy

## Phase 0 — Stabilise and validate direction

Deliverables:

* Current-version compatibility fixes.
* Working documentation.
* Updated demo.
* Public design proposal.
* User interviews or community feedback.
* Benchmark harness.
* Existing preset audit.

Exit criteria:

* Current Anima can be installed and demonstrated reliably.
* Product direction receives external validation.
* Core architectural decisions are recorded.

## Phase 1 — Resource and runtime foundation

Deliverables:

* `AnimaMotion`.
* Sequence.
* Parallel.
* Property motion.
* Delay.
* Nested motion.
* Typed API.
* Runtime scheduler.
* Playback controls.
* Basic easing resources.
* Manual tests and unit tests.

Exit criteria:

* A complete relational motion can be created in code.
* No editor is required.
* Nested durations resolve correctly.
* Cancellation works.

## Phase 2 — Composition-based behaviours

Deliverables:

* `AnimaBehaviour`.
* Inspector plugin.
* Enter and exit motion.
* `Anima.of(node)`.
* State bindings for common Control states.
* Runtime discovery.
* No mandatory autoload.

Exit criteria:

* Ordinary Godot nodes can use Anima without custom subclasses.
* Inspector changes serialize correctly.
* Shared resources do not share runtime state.

## Phase 3 — Motion Composer minimum viable product

Deliverables:

* Motion Structure tree.
* Inspector.
* Play, pause, stop and reset.
* Preview viewport.
* Generated timeline.
* Sequence and Parallel editing.
* Resource saving.
* Undo and redo.
* Validation panel.

Exit criteria:

* A user can build and preview a dialog entrance without code.
* Changing child duration updates derived timing.
* The tree remains source of truth.

## Phase 4 — Advanced easing and interaction motion

Deliverables:

* Spring solver.
* Easing Studio.
* Velocity tracking.
* Retargeting.
* Interruption policies.
* Property ownership.
* Runtime debugger.

Exit criteria:

* Hover reversal preserves continuous motion.
* Repeated target changes do not snap.
* Spring completion is predictable and configurable.

## Phase 5 — Stagger and layout transitions

Deliverables:

* Stagger resource and editor support.
* Automatic layout capture.
* Explicit layout transaction.
* Reordering.
* Insertion.
* Removal.
* Repeated retargeting.

Exit criteria:

* Inventory-grid reorder works without custom node subclasses.
* Layout can change repeatedly during active animation.
* Containers retain authority over final layout.

## Phase 6 — Native Animation integration

Deliverables:

* Native Animation event.
* Open native clip.
* Compiler.
* Adaptive sampling.
* Piecewise Bézier support.
* Compiler reports.
* Generated-resource tracking.

Exit criteria:

* A static Anima motion compiles to a standard `Animation`.
* Runtime-only events are clearly reported.
* Generated output can be used without Anima runtime where fully compiled.

## Phase 7 — Shared elements and ecosystem

Deliverables:

* Shared-element transitions.
* Adapter API.
* Motion themes.
* Preset browser.
* Reduced-motion mappings.
* Migration assistant.

Exit criteria:

* A complete item-list-to-detail transition works.
* Third parties can implement an adapter without modifying Anima core.
* Existing users have a documented migration path.

---

# 34. Testing strategy

## 34.1 Unit tests

Test:

* Sequence duration.
* Parallel duration.
* Nested composition.
* Delay and overlap.
* Stagger ordering.
* Repeat.
* Race.
* Cancellation.
* Reverse.
* Spring solver.
* Retarget velocity.
* Property conflict policies.
* Adaptive sampling.
* Resource serialization.
* Migration mappings.

## 34.2 Integration tests

Test:

* Scene-tree lifecycle.
* Target removal.
* Inspector enable and disable.
* Undo and redo.
* Behaviour inheritance.
* Native Animation playback.
* Compiler output.
* Layout reorder.
* Shared-element transition.
* Editor preview.
* Plugin reload.

## 34.3 Golden tests

Maintain known animation outputs for:

* Easing samples.
* Spring trajectories.
* Compiled keyframes.
* Generated resource metadata.
* Timeline resolution.

## 34.4 Visual regression tests

Where practical:

* Demo scene screenshots.
* Layout transition frames.
* Editor panel layouts.
* Preview output.

## 34.5 Performance tests

Run benchmark suite in CI or scheduled workflows where stable hardware is available.

---

# 35. Acceptance criteria by major epic

## 35.1 Relational composition

* Sequence waits for each child’s completion.
* Parallel starts all children together.
* Parallel duration is determined by its completion policy.
* Nested combinations resolve correctly.
* Dynamic waits are represented as dynamic.
* Relationships survive duration changes.
* Timeline timestamps are regenerated automatically.

## 35.2 Behaviour composition

* An ordinary Godot node can be Anima-enabled.
* No custom subclass is required.
* Configuration is visible in the Inspector.
* Configuration serializes with the scene.
* Shared resource configuration remains immutable at runtime.
* Enter and exit motion can be previewed.
* Removal is undoable.

## 35.3 Interruptible motion

* New targets can retarget an active motion.
* Current velocity is preserved for supported value types.
* Unsupported velocity types fall back predictably.
* Conflict policy is explicit.
* Cancellation cleans runtime ownership.
* Reversal does not snap.

## 35.4 Layout transitions

* Reordered children animate from old to new positions.
* Final layout matches Godot’s container output.
* Repeated changes retarget.
* New children can play enter motion.
* Removed children can play exit motion.
* No custom Container subclass is required.

## 35.5 Motion Composer

* User can create, reorder and nest motion events.
* User can preview and scrub.
* Timeline is derived.
* Dynamic durations are visually distinct.
* Native clips can be opened.
* Invalid targets produce actionable issues.
* All editing actions support undo and redo.
* Resources survive editor restart.

## 35.6 Compiler

* Static sequences compile.
* Static parallels compile.
* Native-compatible curves use efficient representations.
* Complex curves respect configured error tolerance.
* Runtime-only events are reported.
* Source and output synchronization status is visible.
* Compiled output works through `AnimationPlayer`.

---

# 36. Risks and mitigations

## 36.1 Scope expansion

**Risk:** Anima becomes a complete alternative animation engine.

**Mitigation:**

* Keep Godot Animation as the leaf-level editor.
* Keep rendering out of scope.
* Prioritise interaction motion and orchestration.
* Require a clear use case for each new event type.

## 36.2 Editor maintenance

**Risk:** UI breaks across Godot versions.

**Mitigation:**

* Use documented `EditorPlugin` and Inspector APIs.
* Avoid traversing undocumented editor trees for core features.
* Keep optional hacks isolated and disabled by default.
* Add editor startup tests.

## 36.3 Resource complexity

**Risk:** Too many small resource classes overwhelm users.

**Mitigation:**

* Provide builders and presets.
* Hide advanced fields.
* Use sensible defaults.
* Offer inline subresources.
* Keep the initial leaf-type set small.

## 36.4 Runtime conflict complexity

**Risk:** Multiple motions writing the same property produce unpredictable results.

**Mitigation:**

* Explicit ownership.
* Clear default policy.
* Validation warnings.
* Runtime debugger.
* Deterministic conflict resolution.

## 36.5 Compiler fidelity

**Risk:** Compiled Animation differs from Anima preview.

**Mitigation:**

* Error tolerance.
* Compiler report.
* Side-by-side preview.
* Golden tests.
* Runtime fallback for unsupported cases.

## 36.6 Layout edge cases

**Risk:** Custom containers or complex clipping break transitions.

**Mitigation:**

* Document supported cases.
* Provide adapter hooks.
* Detect unsupported conditions.
* Ship layout support incrementally.

## 36.7 One-maintainer sustainability

**Risk:** Anima 2 becomes too large to maintain.

**Mitigation:**

* GDScript-first.
* No mandatory binaries.
* Phased delivery.
* Strong non-goals.
* Stable extension points.
* Community contribution guides.
* Measure adoption before later phases.

---

# 37. Open product decisions

These decisions should be resolved before implementation reaches the editor phase.

## 37.1 Resource granularity

Should every leaf be a separate Resource, or can simple leaves be embedded lightweight subresources?

Recommended:

* All motions are Resources.
* Composer creates embedded subresources by default.
* Users can extract any motion into an external `.tres`.

## 37.2 Metadata versus hidden node

Recommended:

* Behaviour configuration stored as metadata Resource.
* Runtime manager stores state separately.
* Re-evaluate only if metadata serialization creates practical issues.

## 37.3 Timeline direct manipulation

Recommended:

* Support only semantic edits.
* Never make absolute position the default source of truth.

## 37.4 Spring parameter model

Possible public models:

* Response and bounce.
* Mass, stiffness and damping.
* Both, with one advanced mode.

Recommended:

* Simple response/bounce controls by default.
* Advanced physics parameters behind an expandable section.

## 37.5 Import strategy

Recommended:

* Native `Animation` remains a referenced leaf by default.
* Full track conversion is an explicit advanced command.

## 37.6 Version name

Options:

* Anima 1.0.
* Anima 2.
* Anima Motion.
* Anima Next.

Recommended:

* Use **Anima 2** as development codename.
* Decide final semantic version based on release and migration strategy.

---

# 38. Recommended minimum lovable product

The first public release should not attempt every feature in this PRD.

The minimum version capable of validating the new direction should include:

1. Typed `AnimaMotion` resources.
2. Sequence and Parallel.
3. Property motion.
4. Native Godot Animation event.
5. Basic easing resources.
6. Composition-based `AnimaBehaviour`.
7. Enter and exit fields in the Inspector.
8. Motion Composer structure tree.
9. Generated timeline preview.
10. Preview viewport.
11. Open native clip.
12. One interruptible spring implementation.
13. One automatic layout-transition example.
14. High-quality documentation and demo.

This proves the full proposition:

* Relational authoring.
* Godot integration.
* Composition without node subclasses.
* Responsive motion.
* Visual workflow.

Stagger, shared elements, full compiler sophistication and adapters can then expand from a validated foundation.

---

# 39. Final product definition

> **Anima is a relational interaction-motion system for Godot. It lets developers and designers compose motion through sequence, parallelism, staggering and dependencies; attach reusable behaviours to ordinary Godot nodes; create responsive interruptible transitions; animate layout changes; and combine or compile motion with native Godot animations.**

The Motion Composer does not replace Godot’s Animation editor.

Instead:

* Godot authors detailed clips.
* Anima authors relationships and interactions.
* The Anima runtime handles dynamic motion.
* The Anima compiler produces native assets where possible.

The central product distinction is:

> **Godot records when animation events happen. Anima records how animation events relate.**

This can be narrowed next into an implementation-ready Phase 1 specification with exact resource schemas, class responsibilities and acceptance tests.
