# Anima Group Animation — Product Requirements Document

**Product:** Anima 2
**Feature:** Group and Custom Group Animation
**Status:** Draft
**Primary platform:** Godot 4.x
**Primary authoring surfaces:** GDScript API, Inspector, Anima Motion Composer
**Primary resource:** `AnimaGroupMotion`

---

# 1. Executive summary

Anima Group Animation allows one reusable motion to be applied to a collection of Godot nodes.

The collection may be resolved from:

* The children of a `VBoxContainer`.
* The children of an `HBoxContainer`.
* The children of a `GridContainer`.
* The children of any other `Node`.
* An explicit custom list of unrelated nodes.
* A Godot scene group.
* A reusable target collection resource.
* A dynamically resolved target selector.

Once the targets are resolved, Anima controls **how the item motion is distributed across them**:

* Sequentially.
* In parallel.
* Staggered by a fixed interval.
* Staggered across a fixed total duration.
* In forward or reverse order.
* From the centre or edges.
* Across grid rows, columns or diagonals.
* Using a custom order.

Example:

```gdscript
Motion.group($MenuButtons.get_children())
    .apply(Motion.preset(&"button_pop"))
    .staggered(0.05)
```

Custom group example:

```gdscript
Motion.group([
    $Title,
    $Portrait,
    $ConfirmButton,
])
    .apply(Motion.fade_in())
    .sequential()
```

The fundamental separation is:

> **A target group defines who is animated. The group playback mode defines how those targets are animated.**

Group animation must remain distinct from structural composition:

* `Sequence` and `Parallel` compose different motion events.
* `Group` applies an item motion to multiple targets.

---

# 2. Problem statement

## 2.1 Repeated child animation requires manual orchestration

A common Godot UI pattern is animating every item inside a container:

```text
VBoxContainer
├── Button
├── Button
├── Button
└── Button
```

Without a group abstraction, developers must:

1. Retrieve the children.
2. Filter unsupported nodes.
3. Create an animation for every child.
4. Calculate delays manually.
5. Track completion.
6. Handle nodes being removed.
7. Reverse the order manually.
8. Reimplement grid ordering when needed.

This code is repetitive and easy to make inconsistent.

## 2.2 Containers are only one source of targets

Not every visual group shares a parent.

A dialog entrance might involve:

```text
Title
Portrait
Description
Confirm Button
```

These nodes may belong to different branches of the scene tree but still form one logical animation group.

Anima must support explicit custom target lists.

## 2.3 Sequential and staggered animation are often confused

Sequential group animation means:

```text
Item A finishes
    ↓
Item B starts
    ↓
Item C starts
```

Staggered group animation means:

```text
Item A starts
    ↓ 50 ms
Item B starts while A may still be running
    ↓ 50 ms
Item C starts while A and B may still be running
```

The feature must represent these as different playback modes.

## 2.4 Grid animation requires spatial ordering

A `GridContainer` may need to animate:

* Left to right.
* Top to bottom.
* By row.
* By column.
* Diagonally.
* From the centre.
* From a selected item.
* Based on distance from a point.

A plain child-list index is insufficient for these patterns.

## 2.5 Dynamic node collections create lifecycle problems

Targets may:

* Be added before playback.
* Be removed before playback.
* Leave the tree during playback.
* Be hidden.
* Be disabled.
* Change order.
* Be dynamically generated.

Anima must define when targets are resolved and how invalid targets are handled.

## 2.6 Group reversal must preserve relational intent

When a sequential or staggered group is reversed, Anima must understand the group structure.

Forward:

```text
A → B → C
```

Reverse:

```text
reverse(C) → reverse(B) → reverse(A)
```

This should not require the developer to build a second group manually.

---

# 3. Product definition

Anima Group Animation is a first-class `AnimaMotion` that:

1. Resolves a collection of targets.
2. Creates an independent item-motion playback for each target.
3. Orders the targets.
4. Schedules the item playbacks according to a group playback mode.
5. Tracks completion across all generated playbacks.
6. Supports forward and reverse playback.
7. Exposes the generated schedule in the Motion Composer timeline.

Conceptually:

```text
Target collection
        +
Item motion template
        +
Ordering strategy
        +
Playback mode
        ↓
Generated relational motion
```

Example:

```text
Children of MenuButtons
        +
Button Pop
        +
Forward
        +
Staggered every 50 ms
        ↓
Button 1 starts at 0.00
Button 2 starts at 0.05
Button 3 starts at 0.10
Button 4 starts at 0.15
```

---

# 4. Goals

## G1 — Animate container children without manual loops

A user can apply a motion to the children of a `VBoxContainer`, `HBoxContainer`, `GridContainer` or ordinary node.

## G2 — Support explicit custom groups

A user can define an ordered list of unrelated nodes and animate them as one group.

## G3 — Separate target selection from playback distribution

The target collection should be reusable independently from the motion and playback mode.

## G4 — Support distinct sequential, parallel and staggered modes

Each mode must have clear timing and completion semantics.

## G5 — Support predictable target ordering

Users can animate targets in forward, reverse, spatial or custom order.

## G6 — Support group reversal

The group can play backwards or change direction according to defined reversal policies.

## G7 — Integrate with the Motion Composer

Users can visually select targets, configure the group and inspect the generated timeline.

## G8 — Handle dynamic Godot scenes safely

Missing, removed or invalid targets must not crash the group playback.

## G9 — Preserve item independence

Each target receives an independent playback instance with its own:

* Resolved values.
* Current velocity.
* Playback direction.
* Interruption state.
* Execution history.

---

# 5. Non-goals

The initial Group Animation implementation will not:

* Replace Godot containers.
* Control the final layout of container children.
* Automatically create UI nodes.
* Animate arbitrary objects that are not supported by the item motion.
* Recalculate a group continuously every frame by default.
* Guarantee stable behaviour when the target hierarchy is radically modified during playback.
* Implement arbitrary graph traversal queries.
* Implement a full CSS selector language.
* Automatically infer semantic groups from visual proximity.
* Allow every target to use a completely unrelated motion through the basic `AnimaGroupMotion` resource.
* Replicate group animation over multiplayer networking.
* Guarantee that all spatial ordering modes work for 3D nodes in the first release.

A mapping of different target-to-motion pairs may be introduced separately as an `AnimaMappedGroupMotion`.

---

# 6. Terminology

## 6.1 Structural group

A motion that controls relationships between different child motions.

Examples:

* `AnimaSequence`
* `AnimaParallel`
* `AnimaRace`

```text
Sequence
├── Fade title
├── Move panel
└── Reveal buttons
```

## 6.2 Target group

A collection of nodes that will receive the same item-motion template.

```text
Targets
├── Button A
├── Button B
└── Button C
```

## 6.3 Item motion

The reusable motion applied independently to every resolved target.

Example:

```text
Fade and slide upward
```

## 6.4 Playback mode

How the generated item-motion instances relate in time.

Supported initial modes:

* Sequential.
* Parallel.
* Staggered.

## 6.5 Target order

The order in which targets participate in sequential or staggered playback.

Examples:

* Forward.
* Reverse.
* From centre.
* Grid rows.
* Custom.

## 6.6 Target resolution

The moment at which the target collection is evaluated.

Examples:

* At playback start.
* Snapshot at authoring or creation.
* Live observation.

---

# 7. Primary user stories

## US1 — Animate children of a VBoxContainer sequentially

As a Godot developer, I want every child of a `VBoxContainer` to animate one after another so that I do not need to create and schedule each animation manually.

```gdscript
Motion.group_children($Menu)
    .apply(Motion.fade_in())
    .sequential()
```

## US2 — Animate children with staggered overlap

As a UI designer, I want each menu item to start shortly after the previous item so that the entrance feels faster than a fully sequential animation.

```gdscript
Motion.group_children($Menu)
    .apply(Motion.preset(&"slide_up"))
    .staggered(0.05)
```

## US3 — Animate all items in parallel

As a developer, I want to apply the same animation to every selected item at the same time.

```gdscript
Motion.group(items)
    .apply(Motion.scale_to(Vector2.ONE))
    .parallel()
```

## US4 — Animate unrelated nodes as one custom group

As a UI designer, I want to animate a title, portrait and confirmation button in a specific order even though they do not share a parent.

```gdscript
Motion.group([
    $Title,
    $Portrait,
    $ConfirmButton,
])
    .apply(Motion.fade_in())
    .sequential()
```

## US5 — Animate a grid diagonally

As a game developer, I want inventory items to appear diagonally across a grid.

```gdscript
Motion.group_children($InventoryGrid)
    .order(AnimaGroupOrder.GRID_DIAGONAL)
    .apply(Motion.preset(&"item_pop"))
    .staggered(0.04)
```

## US6 — Reverse a group entrance

As a developer, I want a group entrance to reverse automatically when the interface closes.

```gdscript
var playback := Anima.play(menu_group)
playback.reverse()
```

## US7 — Preview generated item timings

As a designer, I want to see every generated item row in the timeline so that I understand how the group will play.

## US8 — Reuse a target collection

As a developer, I want to define a collection once and apply different motions to it.

```gdscript
var menu_items := TargetCollection.children_of($MenuButtons)

var enter := Motion.group(menu_items).apply(button_enter)
var exit := Motion.group(menu_items).apply(button_exit)
```

---

# 8. Functional requirements

## 8.1 Group motion resource

The system must provide:

```gdscript
class_name AnimaGroupMotion
extends AnimaMotion
```

Proposed fields:

```gdscript
@export var targets: AnimaTargetCollection
@export var item_motion: AnimaMotion

@export var playback_mode := AnimaGroupPlaybackMode.STAGGERED
@export var order := AnimaGroupOrder.FORWARD
@export var target_resolution := AnimaTargetResolution.AT_PLAYBACK_START

@export var interval := 0.05
@export var total_stagger_duration := -1.0
@export var gap := 0.0

@export var include_parent := false
@export var include_hidden := true
@export var include_internal_children := false

@export var reverse_order_policy := AnimaReverseOrderPolicy.REVERSE_ORDER
@export var invalid_target_policy := AnimaInvalidTargetPolicy.SKIP
```

## 8.2 Item-motion instantiation

For every resolved target, the group must create a separate playback instance.

Conceptually:

```gdscript
for target in resolved_targets:
    var context := parent_context.for_target(target)
    var playback := item_motion.create_playback(context)
    generated_playbacks.append(playback)
```

The same `AnimaMotion` resource may be reused, but each playback state must be independent.

## 8.3 Supported playback modes

```gdscript
enum AnimaGroupPlaybackMode {
    SEQUENTIAL,
    PARALLEL,
    STAGGERED,
}
```

### Sequential

Each generated item motion begins after the previous item motion completes.

```text
A █████
       B █████
              C █████
```

Start-time calculation:

```text
start(0) = 0

start(n) =
    end(n - 1) + gap
```

Group completion occurs when the final item completes.

### Parallel

All generated item motions start together.

```text
A █████
B ███████
C ███
```

Start-time calculation:

```text
start(n) = 0
```

Default completion occurs when all item motions complete.

The group duration is determined by the longest generated item motion.

### Staggered

Each generated item motion starts after a configured offset, regardless of whether the previous item has completed.

```text
A ███████
   B ███████
      C ███████
```

Fixed-interval calculation:

```text
start(n) = n × interval
```

The group completes when the final active item motion completes.

## 8.4 Stagger duration modes

The group should support two stagger configuration methods.

### Fixed interval

```gdscript
group.interval = 0.05
```

Every item begins 50 milliseconds after the previous item.

### Fixed total distribution duration

```gdscript
group.total_stagger_duration = 0.4
```

For `N` items:

```text
interval =
    total_stagger_duration / max(N - 1, 1)
```

Example for five items:

```text
0.00
0.10
0.20
0.30
0.40
```

If both values are set, the editor must require one active timing mode rather than silently choosing one.

Suggested enum:

```gdscript
enum AnimaStaggerTimingMode {
    FIXED_INTERVAL,
    TOTAL_DISTRIBUTION,
}
```

## 8.5 Group completion

The group must report completion only after the configured completion condition is satisfied.

Initial completion policy:

```gdscript
enum AnimaGroupCompletionPolicy {
    ALL_ITEMS,
    FIRST_ITEM,
    LAST_STARTED_ITEM,
}
```

Default:

```text
ALL_ITEMS
```

`FIRST_ITEM` is primarily useful for advanced orchestration and should be hidden under advanced options.

## 8.6 Empty groups

When zero valid targets are resolved:

* The group completes immediately.
* A warning may be emitted in debug mode.
* Empty groups are not runtime errors by default.

Configurable policy:

```gdscript
enum AnimaEmptyGroupPolicy {
    COMPLETE,
    WARN_AND_COMPLETE,
    ERROR,
}
```

Default:

```text
WARN_AND_COMPLETE
```

---

# 9. Target collection resource

## 9.1 Base resource

```gdscript
class_name AnimaTargetCollection
extends Resource
```

Required method:

```gdscript
func resolve(context: AnimaContext) -> Array[Node]:
    return []
```

Optional methods:

```gdscript
func validate(context: AnimaContext) -> Array[AnimaIssue]
func describe() -> String
```

## 9.2 Collection types

### Children collection

```gdscript
class_name AnimaChildrenTargetCollection
extends AnimaTargetCollection
```

Fields:

```gdscript
@export var parent: AnimaTargetReference
@export var recursive := false
@export var include_parent := false
@export var include_hidden := true
@export var include_internal_children := false
@export var type_filter: StringName
```

Usage:

```gdscript
TargetCollection.children_of($VBoxContainer)
```

### Explicit collection

```gdscript
class_name AnimaExplicitTargetCollection
extends AnimaTargetCollection
```

Fields:

```gdscript
@export var targets: Array[AnimaTargetReference]
```

Usage:

```gdscript
TargetCollection.nodes([
    $Title,
    $Portrait,
    $ConfirmButton,
])
```

The explicit list order must be preserved.

### Scene-group collection

```gdscript
class_name AnimaSceneGroupTargetCollection
extends AnimaTargetCollection
```

Fields:

```gdscript
@export var group_name: StringName
@export var root: AnimaTargetReference
@export var restrict_to_root := true
```

Usage:

```gdscript
TargetCollection.scene_group(&"inventory_items")
```

### Descendant collection

```gdscript
class_name AnimaDescendantTargetCollection
extends AnimaTargetCollection
```

Supports:

* Recursive descendants.
* Optional type filtering.
* Optional Godot group filtering.
* Optional name filtering.

This may be introduced after the basic children collection.

### Runtime collection

A callable or adapter resolves targets at playback time.

This mode is code-only initially and may not be serialisable.

```gdscript
TargetCollection.from_callable(func():
    return active_cards
)
```

---

# 10. Target resolution policy

```gdscript
enum AnimaTargetResolution {
    AT_PLAYBACK_START,
    SNAPSHOT,
    LIVE,
}
```

## 10.1 At playback start

The collection resolves its targets when group playback begins.

This should be the default.

Benefits:

* Reflects current container membership.
* Reflects current child ordering.
* Supports dynamically generated interfaces.
* Produces a stable list for the duration of one playback.

## 10.2 Snapshot

The collection stores or resolves a fixed target list before playback.

Useful when:

* Exact order must remain stable.
* The resource represents specific scene nodes.
* Reversal must reuse the original target set.
* The application may modify the container before playback.

For resource assets shared across scenes, snapshot references must remain scene-relative rather than storing live object references.

## 10.3 Live

The target collection observes membership changes during playback.

Potential behaviour:

* Added targets join the active group.
* Removed targets are cancelled.
* Timing may be recalculated.

This is complex and is not required for the first release.

Initial status:

```text
Deferred
```

The API may reserve the enum value but should report it as unsupported until implemented.

---

# 11. Target filtering

The group must support target filtering.

## 11.1 Type filter

Examples:

```gdscript
TargetCollection.children_of($Menu)
    .of_type(Control)
```

Or:

```gdscript
TargetCollection.children_of($Menu)
    .of_type(Button)
```

## 11.2 Visibility filter

Options:

* Include hidden targets.
* Exclude hidden targets.
* Include only targets visible in the tree.

Suggested enum:

```gdscript
enum AnimaVisibilityFilter {
    ALL,
    VISIBLE_PROPERTY,
    VISIBLE_IN_TREE,
}
```

## 11.3 Disabled-state filter

For `BaseButton` and other supported controls:

* Include disabled.
* Exclude disabled.
* Only disabled.

This should be an optional advanced filter.

## 11.4 Custom predicate

Code-only initial support:

```gdscript
TargetCollection.children_of($Menu)
    .filter(func(node):
        return node.has_meta(&"animate")
    )
```

Custom predicates may prevent full serialization and editor preview.

The editor must clearly mark such collections as runtime-resolved.

---

# 12. Target ordering

## 12.1 Ordering enum

```gdscript
enum AnimaGroupOrder {
    FORWARD,
    REVERSE,
    FROM_CENTER,
    FROM_EDGES,
    RANDOM,
    GRID_ROWS,
    GRID_COLUMNS,
    GRID_DIAGONAL,
    DISTANCE_FROM_POINT,
    EXPLICIT,
    CUSTOM,
}
```

## 12.2 Forward

Uses resolved collection order.

For direct children, this is the scene-tree child order.

For explicit collections, this is the explicit list order.

## 12.3 Reverse

Reverses the resolved order.

## 12.4 From centre

Targets closest to the logical centre animate first.

For an indexed list:

```text
Five targets:
3 → 2 and 4 → 1 and 5
```

For spatial layouts, distance from the collection’s visual centre may be used.

The resource must specify whether centre ordering is:

* Index-based.
* Spatial.

## 12.5 From edges

Targets furthest from the logical centre animate first.

## 12.6 Random

Targets are shuffled.

The group must support a seed:

```gdscript
@export var random_seed := 0
@export var randomise_seed_each_play := false
```

Requirements:

* A fixed seed produces deterministic order.
* Reversal uses the order originally resolved for that playback.
* Editor preview can regenerate or lock the seed.

## 12.7 Grid rows

Targets animate:

```text
Row 1, left to right
Row 2, left to right
Row 3, left to right
```

Options:

```gdscript
@export var reverse_rows := false
@export var reverse_items_in_row := false
```

## 12.8 Grid columns

Targets animate:

```text
Column 1, top to bottom
Column 2, top to bottom
Column 3, top to bottom
```

Options:

```gdscript
@export var reverse_columns := false
@export var reverse_items_in_column := false
```

## 12.9 Grid diagonal

Example:

```text
1 2 4
3 5 7
6 8 9
```

Potential diagonal directions:

```gdscript
enum AnimaGridDiagonal {
    TOP_LEFT_TO_BOTTOM_RIGHT,
    TOP_RIGHT_TO_BOTTOM_LEFT,
    BOTTOM_LEFT_TO_TOP_RIGHT,
    BOTTOM_RIGHT_TO_TOP_LEFT,
}
```

## 12.10 Distance from point

Targets are ordered by distance from:

* A target node.
* A local point.
* A global point.
* The collection’s centre.
* The pointer position captured at playback start.

```gdscript
Motion.group(items)
    .order_by_distance(pointer_position)
```

This may be deferred beyond the first group release.

## 12.11 Custom order

A callable returns:

* A reordered array.
* A numeric rank for each target.
* A comparator.

Code example:

```gdscript
group.custom_order(func(a: Node, b: Node):
    return a.get_meta(&"priority") < b.get_meta(&"priority")
)
```

Custom ordering is code-only unless represented through a registered ordering resource.

---

# 13. Grid resolution

## 13.1 GridContainer support

For a standard `GridContainer`, Anima should derive row and column information from:

* Child index.
* Configured column count.
* Valid animated-child count.

If the grid has `columns = C`:

```text
row = index / C
column = index % C
```

Filtering can create gaps.

The group must define whether ordering uses:

* Original child indices.
* Compact filtered indices.

Default:

```text
Compact filtered indices
```

This ensures excluded nodes do not create unexpected empty positions in the animation order.

## 13.2 Non-GridContainer spatial grids

A target collection may optionally infer rows and columns from target positions.

This requires:

* Positional tolerance.
* Stable sorting.
* Coordinate-space selection.

This is not required for the initial release.

## 13.3 Grid waves

A later extension may group items into simultaneous waves:

```text
Wave 1: top-left item
Wave 2: adjacent diagonal items
Wave 3: next diagonal
```

This differs from a flat stagger order because items in the same wave begin together.

Potential future resource:

```gdscript
@export var wave_parallelism := true
```

Initial release may flatten waves into equal-rank items with the same start offset.

---

# 14. Item motion behaviour

## 14.1 Target binding

The item motion must be authored relative to the current item target.

Example:

```gdscript
Motion.group(items)
    .apply(
        Motion.to_target(^"modulate:a", 1.0)
    )
```

Inside the item motion, the target should resolve to the generated item context.

## 14.2 Nested item motions

An item motion may itself contain:

* A Sequence.
* A Parallel group.
* Property motions.
* Native animations.
* Delays.
* Callbacks.
* Nested reusable motions.

Example:

```gdscript
var item_enter := Motion.sequence(
    Motion.parallel(
        Motion.fade_in(),
        Motion.move_by(Vector2(0, -12))
    ),
    Motion.scale_to(Vector2.ONE)
)
```

This entire motion is instantiated once per target.

## 14.3 Relative and captured values

Each item must independently capture:

* Initial property values.
* Relative offsets.
* Dynamic values.
* Target-specific data.

A group must not capture the first item’s values and reuse them for every target.

## 14.4 Per-item customisation

The group should support item context variables:

```text
index
reverse index
count
normalised index
row
column
target
```

Example:

```gdscript
Motion.to_target(
    ^"rotation",
    func(context):
        return lerp(-0.1, 0.1, context.normalised_index)
)
```

Proposed context:

```gdscript
class_name AnimaGroupItemContext
extends AnimaContext

var item_index: int
var reverse_index: int
var item_count: int
var normalised_index: float
var row: int
var column: int
```

## 14.5 Item-motion duration differences

Item motions may resolve to different durations because of:

* Dynamic values.
* Target-specific configuration.
* Spring settling.
* Native animation differences.
* Conditional branches.

Sequential mode must wait for the actual completion of the previous item.

Staggered mode must preserve configured start offsets even if item durations differ.

Parallel completion must account for all actual item completions.

---

# 15. Group reversal

## 15.1 Reverse modes

The group must support:

```gdscript
enum AnimaReverseOrderPolicy {
    REVERSE_ORDER,
    KEEP_ORDER,
    CUSTOM,
}
```

## 15.2 Sequential reversal

Forward:

```text
A → B → C
```

Default reverse:

```text
reverse(C) → reverse(B) → reverse(A)
```

## 15.3 Parallel reversal

All item motions remain parallel:

```text
Parallel(
    reverse(A),
    reverse(B),
    reverse(C)
)
```

Order has no timing effect but remains relevant for callbacks, debugging and deterministic execution.

## 15.4 Stagger reversal

Forward:

```text
A at 0.00
B at 0.05
C at 0.10
```

Default reverse:

```text
reverse(C) at 0.00
reverse(B) at 0.05
reverse(A) at 0.10
```

## 15.5 Keep-order reversal

A user may choose:

```text
reverse(A)
reverse(B)
reverse(C)
```

This reverses each item motion without reversing target order.

Useful for:

* Symmetrical effects.
* Cases where the exit should follow the same direction as the entrance.
* Custom artistic intent.

## 15.6 Mid-playback reversal

When an active group reverses:

* Active item playbacks reverse or physically retarget according to their own policies.
* Items that have not started must be rescheduled appropriately.
* Completed items may become pending reverse items.
* The group must preserve its resolved target order.
* Random groups must not generate a new random order.
* Dynamic collections must reverse the targets that participated in the current execution.

## 15.7 Execution record

The group playback must record:

```gdscript
class_name AnimaGroupExecutionRecord
extends RefCounted

var resolved_targets: Array[WeakRef]
var resolved_order: Array[int]
var generated_start_offsets: PackedFloat32Array
var completed_items: PackedInt32Array
var active_items: PackedInt32Array
var random_seed: int
```

This record is used for:

* Reversal.
* Debugging.
* Deterministic replay.
* Runtime inspection.

---

# 16. Runtime architecture

## 16.1 Group playback instance

```gdscript
class_name AnimaGroupPlayback
extends AnimaPlayback
```

Responsibilities:

* Resolve targets.
* Filter targets.
* Order targets.
* Create item playbacks.
* Calculate start offsets.
* Start item playbacks.
* Track completion.
* Propagate cancellation.
* Handle reversal.
* Generate execution records.
* Report child progress.

## 16.2 Generated item record

```gdscript
class_name AnimaGroupItemPlayback
extends RefCounted

var target: WeakRef
var original_index: int
var ordered_index: int
var row: int
var column: int
var start_offset: float
var playback: AnimaPlayback
```

## 16.3 Target validity

Before starting each generated item:

* Confirm the target still exists.
* Confirm it remains inside the scene tree where required.
* Confirm the item motion supports the target.
* Apply invalid-target policy.

## 16.4 Invalid-target policies

```gdscript
enum AnimaInvalidTargetPolicy {
    SKIP,
    CANCEL_GROUP,
    COMPLETE_ITEM,
    ERROR,
}
```

### Skip

Ignore the invalid item and continue.

Default policy.

### Cancel group

Cancel the complete group.

### Complete item

Treat the item as having completed successfully.

This differs from `SKIP` primarily in tracing and completion reporting.

### Error

Stop and emit an error.

Best used for tests or strict authoring.

## 16.5 Target removed during playback

Default behaviour:

1. Cancel that item playback.
2. Release its property ownership.
3. Mark the item as skipped.
4. Continue the group.
5. Complete when all remaining valid items complete.

Configurable strict behaviour may cancel the group.

## 16.6 Pause and resume

Pausing the group pauses:

* Active item playbacks.
* Pending start offsets.
* Sequential progression.
* Group elapsed time.

Resuming continues from the same state.

## 16.7 Cancellation

Cancelling a group must:

* Cancel active item playbacks.
* Prevent pending items from starting.
* Disconnect signals.
* Release property ownership.
* Emit one group cancellation result.

## 16.8 Speed changes

Changing group speed affects:

* Pending stagger offsets.
* Sequential gaps.
* Active item playback speed where supported.
* Estimated group duration.

---

# 17. Code API

## 17.1 Children convenience

```gdscript
var motion := Motion.group_children($Buttons)
    .apply(Motion.preset(&"button_pop"))
    .staggered(0.05)
```

## 17.2 Explicit targets

```gdscript
var motion := Motion.group([
    $Title,
    $Portrait,
    $ConfirmButton,
])
    .apply(Motion.fade_in())
    .sequential()
```

## 17.3 Reusable target collection

```gdscript
var targets := TargetCollection.children_of($InventoryGrid)

var enter := Motion.group(targets)
    .apply(item_enter)
    .order(AnimaGroupOrder.GRID_DIAGONAL)
    .staggered(0.04)

var exit := Motion.group(targets)
    .apply(item_exit)
    .order(AnimaGroupOrder.REVERSE)
    .staggered(0.03)
```

## 17.4 Parallel

```gdscript
var motion := Motion.group(menu_items)
    .apply(Motion.fade_in())
    .parallel()
```

## 17.5 Sequential with gap

```gdscript
var motion := Motion.group(menu_items)
    .apply(item_motion)
    .sequential(gap = 0.05)
```

## 17.6 Fixed-duration stagger distribution

```gdscript
var motion := Motion.group(items)
    .apply(item_motion)
    .stagger_across(0.5)
```

## 17.7 Order

```gdscript
var motion := Motion.group_children($Grid)
    .order(AnimaGroupOrder.FROM_CENTER)
    .apply(item_motion)
    .staggered(0.04)
```

## 17.8 Filters

```gdscript
var targets := TargetCollection.children_of($Menu)
    .of_type(Button)
    .visible_in_tree_only()
```

## 17.9 Reverse policy

```gdscript
var motion := Motion.group(items)
    .apply(item_motion)
    .staggered(0.05)
    .reverse_order(AnimaReverseOrderPolicy.REVERSE_ORDER)
```

## 17.10 Item context

```gdscript
var item_motion := Motion.to_target(
    ^"modulate:a",
    func(context: AnimaGroupItemContext):
        return lerp(0.4, 1.0, context.normalised_index)
)
```

---

# 18. Motion Composer requirements

## 18.1 Group node representation

The Motion Structure should display:

```text
Group: Menu Buttons
├── Targets: Children of ButtonsVBox
├── Mode: Staggered
├── Interval: 0.05 s
├── Order: Forward
└── Item Motion
    └── Button Pop
```

Custom target group:

```text
Group: Header Elements
├── Targets: Explicit List
│   ├── Title
│   ├── Portrait
│   └── Status Icon
├── Mode: Sequential
├── Gap: 0.04 s
└── Item Motion
    └── Fade and Slide
```

## 18.2 Group creation

Users can add a Group through:

```text
Add → Group
```

Creation options:

* Children of selected node.
* Explicit nodes.
* Godot scene group.
* Empty reusable target collection.

## 18.3 Drag-and-drop target creation

Users should be able to:

* Drag a container from the scene tree into the target field.
* Drag multiple selected scene nodes into an explicit target list.
* Reorder explicit targets.
* Remove targets.
* Locate a target in the scene tree.
* Replace a missing target.

## 18.4 Inspector fields

### General

```text
Name
Enabled
Item Motion
```

### Targets

```text
Collection Type
Parent
Recursive
Explicit Target List
Type Filter
Visibility Filter
Resolution Policy
```

### Distribution

```text
Playback Mode
Interval
Total Distribution Duration
Sequential Gap
Completion Policy
```

### Order

```text
Order
Grid Direction
Centre Mode
Random Seed
Custom Ordering Resource
```

### Reverse

```text
Reverse Order Policy
Reverse Item Motion
Mid-playback Reverse Behaviour
```

### Advanced

```text
Invalid Target Policy
Empty Group Policy
Include Internal Children
Compiler Behaviour
Debug Expansion
```

## 18.5 Generated target preview

The editor should show the currently resolved target list:

```text
Resolved targets: 4

1. AudioButton
2. VideoButton
3. ControlsButton
4. BackButton
```

For runtime-only collections:

```text
Targets are resolved at runtime
```

## 18.6 Grid preview

For grid orderings, the editor should display target ranks:

```text
1 2 4
3 5 7
6 8 9
```

This allows users to understand the selected ordering before playback.

## 18.7 Timeline representation

Collapsed:

```text
Menu Buttons Group    █████████████
```

Expanded:

```text
Audio Button          █████
Video Button             █████
Controls Button             █████
Back Button                    █████
```

The user can expand or collapse generated item rows.

Generated rows are not independent source nodes.

Editing a generated row should redirect the user to:

* The target collection.
* The item motion.
* The ordering configuration.

## 18.8 Critical path

For parallel and staggered groups, the timeline should indicate which item determines group completion.

Example:

```text
Group duration: 0.78 s
Critical item: BackButton
```

## 18.9 Playback controls

The Composer should support:

* Play group.
* Play selected item.
* Play from selected item.
* Play forwards.
* Play backwards.
* Reverse during playback.
* Reset all targets.
* Reset selected target.
* Regenerate random ordering.

## 18.10 Target highlighting

Selecting a generated target row highlights the corresponding node in the preview viewport.

The preview may show:

* Target bounds.
* Ordered index.
* Row and column.
* Start offset.

---

# 19. Inspector integration

A node with Anima behaviour may expose a group motion in fields such as:

```text
Anima
├── Motion In
├── Motion Out
└── Children Motion
    ├── Motion
    ├── Mode
    ├── Order
    └── Interval
```

However, the primary group configuration should remain inside an `AnimaGroupMotion` resource rather than duplicating all fields directly on every container.

Convenience action:

```text
Create Group Motion from Children
```

This action:

1. Creates an `AnimaGroupMotion`.
2. Creates a children target collection for the selected node.
3. Opens the motion in the Composer.

---

# 20. Native Animation integration

## 20.1 Native clip as item motion

A group may apply one native Godot Animation clip to every target.

Possible approach:

* Each target contains an `AnimationPlayer`.
* A relative player path is resolved from each target.
* An adapter plays the named clip.

Example:

```gdscript
Motion.group(items)
    .apply(
        Motion.animation_relative(
            ^"AnimationPlayer",
            &"item_enter"
        )
    )
    .staggered(0.05)
```

## 20.2 Compilation

A static group can compile to a native Godot `Animation` when:

* Targets are statically resolvable.
* Item motion is compilable.
* Ordering is deterministic.
* No live membership is required.
* No runtime-only filters or callbacks affect target selection.

The compiler expands the group into individual generated tracks.

Compiler report:

```text
Compiled Group “Menu Buttons”

4 targets resolved
Playback mode: Staggered
Ordering: Forward
Interval: 0.05 s
16 generated tracks
0 runtime-only events
```

## 20.3 Runtime-only conditions

The compiler must report when the group cannot fully compile:

```text
Target collection is resolved through a runtime callable.
Random order changes on every playback.
Live target membership is enabled.
Item motion contains a signal wait.
```

---

# 21. Validation requirements

## 21.1 Static validation

Detect:

* Missing target collection.
* Missing item motion.
* Explicit target reference cannot resolve.
* Unsupported playback mode.
* Negative interval.
* Negative sequential gap.
* Invalid total stagger duration.
* Both stagger timing modes active.
* Grid ordering applied to unresolved or unsupported layout.
* Recursive resource reference.
* Item motion references a fixed external target instead of item context.
* Random order has no deterministic seed during compilation.
* Live resolution requested but unsupported.
* Custom ordering resource missing.
* Unsupported target type.
* Duplicate explicit targets.

## 21.2 Duplicate targets

Default behaviour:

* Deduplicate targets.
* Preserve the first occurrence.
* Emit a warning.

Configurable policy:

```gdscript
enum AnimaDuplicateTargetPolicy {
    DEDUPLICATE,
    ALLOW,
    ERROR,
}
```

Allowing duplicates means the same target may receive multiple item playbacks and therefore must obey normal property-conflict policies.

## 21.3 Runtime validation

Detect:

* Target freed during playback.
* Target leaves the scene tree.
* Item motion fails to resolve a property.
* Target list changes after snapshot.
* Custom comparator returns inconsistent results.
* Grid dimensions change during playback.
* Reversal requested without sufficient execution history.

---

# 22. Performance requirements

## 22.1 Initial targets

The feature should support:

* 100 ordinary UI targets without visible scheduling hitch.
* 1,000 simple scalar item motions at interactive frame rates on reference desktop hardware.
* Target resolution and ordering without recurring per-frame allocation.
* Group reversal without reconstructing unnecessary resources.
* Timeline expansion for at least 500 generated rows without freezing the editor.

These are validation targets rather than universal guarantees.

## 22.2 Optimisation principles

* Resolve targets once per playback by default.
* Reuse item-motion resources.
* Allocate playback state per item only.
* Avoid creating duplicate target resources.
* Cache grid rank data for one playback.
* Use weak target references.
* Do not poll scene membership every frame unless live resolution is enabled.

## 22.3 Benchmark scenarios

Test:

* 10, 100, 1,000 and 10,000 targets.
* Sequential groups.
* Parallel groups.
* Staggered groups.
* Reverse playback.
* Random ordering.
* Grid diagonal ordering.
* Target removal during playback.
* Nested item motions.
* Spring item motions.
* Native compiled output comparison.

---

# 23. Migration from legacy Anima groups

## 23.1 Legacy group mapping

Existing group functionality should map to:

```text
Legacy Group
    ↓
AnimaGroupMotion
```

Legacy container group:

```text
Target collection: Children
Playback mode: derived from legacy configuration
Item motion: converted legacy animation
```

Legacy custom group:

```text
Target collection: Explicit
Target order: legacy list order
Playback mode: derived from legacy configuration
```

Legacy grid animation:

```text
Target collection: Children of grid
Order: matching grid ordering
Playback mode: Staggered or Sequential
```

## 23.2 Migration report

Example:

```text
Converted group “menu_items”

Targets: children of MenuVBox
Mode: staggered
Interval: 0.05 s
Order: forward
Item motion: converted successfully

Warning:
Legacy group callback has no reverse action.
```

## 23.3 Behaviour preservation

Migration should prioritise preserving observable timing over producing the most elegant new resource structure.

Where exact behaviour cannot be inferred, the converter should generate warnings rather than silently changing timing.

---

# 24. Acceptance criteria

## 24.1 Target resolution

* Children of a selected parent can be resolved.
* Explicit unrelated targets can be resolved.
* Explicit target order is preserved.
* Scene-group targets can be resolved.
* Hidden targets follow the configured filter.
* Invalid targets follow the configured policy.
* Duplicate targets follow the configured policy.
* Default resolution occurs at playback start.

## 24.2 Sequential playback

* The second item starts only after the first completes.
* Different item durations are handled correctly.
* Configured gaps occur after each completion.
* The group completes after the final valid item.
* Reversal runs targets in reverse order by default.

## 24.3 Parallel playback

* All valid targets start on the same frame.
* Each target receives an independent playback.
* The group completes according to the completion policy.
* Reversal keeps item playbacks parallel.

## 24.4 Staggered playback

* Each target begins at the configured interval.
* Item durations may overlap.
* Fixed-total distribution calculates the correct interval.
* The group completes after all valid item motions complete.
* Default reverse playback mirrors target order.
* Mid-playback reversal does not regenerate random ordering.

## 24.5 Ordering

* Forward follows resolved order.
* Reverse inverts resolved order.
* Explicit list order is stable.
* Centre and edge modes produce deterministic ranks.
* Fixed random seed produces repeatable order.
* Grid row ordering matches configured grid columns.
* Grid column ordering matches configured grid columns.
* Grid diagonal ordering produces documented rank order.

## 24.6 Item motion

* Every target captures its own initial values.
* Relative values are calculated per target.
* Dynamic values receive item context.
* Nested item motions work.
* Item velocity and interruption state remain independent.
* One removed target does not corrupt other item playbacks.

## 24.7 Motion Composer

* A user can create a group from container children.
* A user can create an explicit target group.
* Explicit targets can be reordered.
* The resolved target list can be previewed.
* Grid ordering can be previewed.
* Generated timeline rows can be expanded and collapsed.
* Selecting a generated row identifies its source target.
* Editing supports undo and redo.
* Group resources survive editor restart.

## 24.8 Compilation

* A static group can compile to native Animation tracks.
* Generated item offsets match runtime scheduling within tolerance.
* Runtime-only target collections produce a clear compiler issue.
* Generated output records source group metadata.
* Reverse compatibility is included in the compiler report.

---

# 25. Delivery phases

## Phase 1 — Core target collections

Deliver:

* `AnimaTargetCollection`.
* Children collection.
* Explicit collection.
* At-playback-start resolution.
* Basic validation.
* Forward and reverse ordering.

Exit criteria:

* A list of valid targets can be resolved deterministically.
* Explicit custom groups work.

## Phase 2 — Core group playback

Deliver:

* `AnimaGroupMotion`.
* Sequential.
* Parallel.
* Fixed-interval stagger.
* Independent item playbacks.
* Cancellation.
* Pause and resume.
* Basic reversal.

Exit criteria:

* Groups work through code without editor support.
* Each target receives independent runtime state.

## Phase 3 — Ordering

Deliver:

* Forward.
* Reverse.
* Centre.
* Edges.
* Deterministic random.
* Grid rows.
* Grid columns.
* Grid diagonal.

Exit criteria:

* Ordering is deterministic and unit-tested.
* Grid ordering works with standard `GridContainer`.

## Phase 4 — Motion Composer support

Deliver:

* Group node.
* Target collection editor.
* Explicit target list.
* Container picker.
* Resolved target preview.
* Generated timeline expansion.
* Grid order preview.
* Validation issues.

Exit criteria:

* A group can be authored and previewed without code.

## Phase 5 — Advanced runtime behaviour

Deliver:

* Mid-playback reversal.
* Execution records.
* Target removal handling.
* Per-item context.
* Total-distribution stagger.
* Scene-group collections.
* Advanced filtering.

Exit criteria:

* Dynamic scenes and interactive reversal behave predictably.

## Phase 6 — Native compiler and migration

Deliver:

* Static group compilation.
* Compiler report.
* Legacy group conversion.
* Legacy custom-list conversion.
* Legacy grid conversion.

Exit criteria:

* Existing Anima group users can migrate representative animations.

---

# 26. Testing strategy

## 26.1 Unit tests

Test:

* Empty target collection.
* Single target.
* Multiple targets.
* Explicit ordering.
* Duplicate handling.
* Sequential timing.
* Parallel completion.
* Stagger interval.
* Total-duration staggering.
* Reverse playback.
* Random seed determinism.
* Grid row ordering.
* Grid column ordering.
* Grid diagonal ordering.
* Item-context values.
* Invalid target policies.

## 26.2 Integration tests

Test:

* VBoxContainer children.
* HBoxContainer children.
* GridContainer children.
* Explicit unrelated nodes.
* Targets added before playback.
* Targets removed before playback.
* Target removed during playback.
* Scene reloaded.
* Shared item-motion resource.
* Motion Composer serialization.
* Native Animation compilation.

## 26.3 Visual demo tests

Create demo scenes for:

* Sequential menu entrance.
* Staggered button entrance.
* Parallel card reveal.
* Diagonal inventory grid.
* Custom title/portrait/button group.
* Random particle-like UI entrance.
* Forward and backward group playback.
* Mid-playback reversal.

---

# 27. Risks and mitigations

## 27.1 Confusion between Group and Sequence

**Risk:** Users may not understand why Group is separate from Sequence.

**Mitigation:**

Use consistent language:

> Group selects targets. Sequence determines timing between different motions.

Show this distinction in documentation and editor tooltips.

## 27.2 Too many ordering options

**Risk:** The Inspector becomes overwhelming.

**Mitigation:**

Show common options first:

* Forward.
* Reverse.
* Centre.
* Random.

Place grid and custom orderings under advanced options.

## 27.3 Dynamic target instability

**Risk:** Scene changes during playback produce unpredictable behaviour.

**Mitigation:**

Resolve once at playback start by default. Defer live resolution.

## 27.4 Grid-order ambiguity

**Risk:** Filtering and hidden nodes change expected grid coordinates.

**Mitigation:**

Document compact filtered indexing as the default and provide an editor rank preview.

## 27.5 Reversal complexity

**Risk:** Reversing active groups causes inconsistent pending-item state.

**Mitigation:**

Design execution records and bidirectional scheduling into the first runtime implementation.

## 27.6 Excessive generated playbacks

**Risk:** Very large groups create allocation or editor-performance issues.

**Mitigation:**

Use lightweight playback instances, benchmark large groups and keep generated timeline rows collapsed by default.

---

# 28. Open decisions

## 28.1 Is Group a dedicated motion or builder sugar?

Recommended:

`AnimaGroupMotion` should be a dedicated first-class resource because it needs:

* Target collections.
* Ordering.
* Runtime expansion.
* Editor representation.
* Reversal policies.
* Compilation reporting.

## 28.2 Should Sequential, Parallel and Stagger be separate group subclasses?

Options:

```text
AnimaSequentialGroup
AnimaParallelGroup
AnimaStaggerGroup
```

Or:

```text
AnimaGroupMotion.playback_mode
```

Recommended:

Use one `AnimaGroupMotion` with a playback-mode enum.

The target and item-motion configuration are shared, and switching modes should not require replacing the resource.

## 28.3 Should Stagger remain a general structural motion?

Recommended:

Support both concepts:

* `AnimaStagger` for explicitly authored child motions.
* `AnimaGroupMotion` in staggered mode for one item-motion template distributed across targets.

Example structural stagger:

```text
Stagger
├── Fade title
├── Rotate icon
└── Move button
```

Example target-group stagger:

```text
Group
├── Targets: menu buttons
└── Item motion: button pop
```

## 28.4 Should custom target lists store NodePaths?

Recommended:

Use scene-relative target references serialised as NodePaths, with editor support for validating and repairing missing references.

Do not persist live Node references in reusable resources.

## 28.5 Should different targets support different motions?

Recommended:

Not in the core Group resource.

Use a normal Sequence or Parallel for heterogeneous motions.

A future `AnimaMappedGroupMotion` may support:

```text
Title → title_motion
Portrait → portrait_motion
Button → button_motion
```

## 28.6 Should live target membership be supported?

Recommended:

Defer until real use cases demonstrate that playback-start resolution is insufficient.

---

# 29. Minimum viable release

The minimum useful Group Animation release should contain:

1. `AnimaGroupMotion`.
2. Children target collection.
3. Explicit target collection.
4. Sequential mode.
5. Parallel mode.
6. Fixed-interval staggered mode.
7. Forward and reverse ordering.
8. Independent item playback.
9. Basic group reversal.
10. VBox, HBox and GridContainer support.
11. Code API.
12. Basic Motion Composer group node.
13. Resolved-target preview.
14. Expandable generated timeline rows.
15. Legacy group migration documentation.

Centre, edge, random, spatial and advanced grid patterns can follow after the core interaction has been validated.

---

# 30. Final feature definition

> **Anima Group Animation applies one reusable motion to a resolved collection of Godot nodes and controls how those item motions are distributed through sequence, parallelism, staggering and configurable ordering.**

It supports both:

* Container-based groups.
* Explicit custom groups.

Its architectural distinction is:

> **Targets define who participates. Playback mode defines how participation is scheduled. Item motion defines what happens to each participant.**
