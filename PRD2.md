Reversibility is part of the motion definition

Every motion declares whether it is:

enum Reversibility {
    AUTOMATIC,
    EXPLICIT,
    FORWARD_ONLY,
}
Automatic: Anima can derive the reverse.
Explicit: the author supplies reverse behaviour.
Forward only: reversing produces a validation error or follows a configured skip policy.

This prevents Anima from pretending every event can be meaningfully reversed.

Define three separate operations

The PRD currently risks grouping several different ideas under “reverse.” They should be distinct.

1. Play backwards from the end
await Anima.play_backwards(motion, context)

The motion begins from its completed state and runs to its initial state.

Example:

Forward:
Fade title → Parallel(panel, background) → Stagger buttons

Backward:
Reverse stagger → Parallel(reverse panel, reverse background) → Fade title out
2. Reverse the current timeline
playback.reverse()

If the motion is 40% complete, its timeline cursor changes direction from that exact point.

This should:

Preserve the current values.
Reverse the relational execution cursor.
Avoid restarting from the end.
Trigger reverse event semantics when markers are crossed.
Allow repeated direction changes.

This is especially useful for:

Menu open/close.
Hover/focus.
Expand/collapse.
Reversible panels.
Interaction previews.
3. Retarget physically to the initial state
playback.retarget_to_start()

This is not the same as reversing a timeline.

For a spring:

Timeline reversal retraces the calculated path backwards.
Physical retargeting changes the spring’s target to its initial value while preserving current velocity.

The second usually looks more natural for interactive UI.

The API should make that distinction explicit:

playback.reverse_timeline()
playback.retarget_to_start()
Reverse rules for each motion type

The PRD should include a reversal contract.

Property motion
from → to

becomes:

to → from

The easing must be mirrored so the reversed trajectory matches the forward trajectory.

Sequence
Sequence(A, B, C)

becomes:

Sequence(reverse(C), reverse(B), reverse(A))
Parallel
Parallel(A, B)

becomes:

Parallel(reverse(A), reverse(B))

Children remain parallel.

Stagger

A chronological reverse should invert the resolved stagger order.

Forward:

Item 1 → Item 2 → Item 3

Backward:

reverse(Item 3) → reverse(Item 2) → reverse(Item 1)

The resource may also expose:

enum ReverseStaggerPolicy {
    REVERSE_ORDER,
    KEEP_ORDER,
    CUSTOM,
}

REVERSE_ORDER should be the default because it reconstructs the initial visual state in chronological reverse.

Delay

A delay remains the same duration but appears at its mirrored position in the graph.

Repeat

Rules need to define:

Whether completed iterations are reversed.
Whether only the current iteration reverses.
How alternating repeats behave.
Whether infinite repetition can enter reverse mode.
Native Godot Animation

Use AnimationPlayer’s backwards playback when an Anima event references a native clip. Godot supports this directly.

Spring

Provide both:

Exact timeline reversal.
Physical retargeting to the initial state.

These should not be treated as equivalent.

Layout transition

If both layout snapshots remain valid, reversing returns from the new layout to the previous layout.

If the application has already changed the underlying layout again, Anima should retarget to the current layout instead of replaying stale geometry.

Shared-element transition

Reverse source and destination roles, provided both states still exist or snapshots were retained.

Callback

A callback is not automatically reversible.

Require an explicit pair:

Motion.callback({
    forward = Callable(self, "equip_item"),
    backward = Callable(self, "unequip_item"),
})

Or a reversible command:

class_name AnimaCommand

func execute() -> void:
    pass

func undo() -> void:
    pass
Signal wait

Waiting for a signal has no obvious automatic reverse.

Possible policies:

enum ReverseEventPolicy {
    SKIP,
    REQUIRE_EXPLICIT,
    RUN_REVERSE_EVENT,
    ERROR,
}

The safest default for authored motions is REQUIRE_EXPLICIT.

Race and conditionals

These require recorded execution history.

When reversing a completed motion, Anima should reverse the branch that actually ran—not re-evaluate the condition and potentially choose another one.

That means playback should retain an execution trace:

Conditional selected: when_true
Race winner: cancel_button.pressed
Repeat completed iterations: 2
Add graph execution history

Reversing a dynamic graph cannot always be derived from the resource alone.

The runtime should record:

Selected conditional branches.
Race winners.
Resolved dynamic values.
Stagger target ordering.
Executed callbacks.
Completed loops.
Native clip state.
Runtime durations.
Layout snapshots.

This can be represented by:

class_name AnimaExecutionRecord
extends RefCounted

var motion_id: StringName
var selected_branch: int
var resolved_targets: Array[Object]
var resolved_values: Dictionary
var children: Array[AnimaExecutionRecord]

Then:

playback.reverse()

reverses what actually happened, rather than recalculating what might happen now.

This is an important architectural requirement.

Update the Motion Composer

The editor concept should include direction and reversibility.

Toolbar

Add:

Play Forward
Play Backward
Reverse Current Playback
Reset to Start
Reset to End
Structure indicators

Each event can display:

↔ Automatically reversible
⇄ Explicit reverse defined
→ Forward only
Validation

Examples:

Warning: Callback “Save Settings” has no reverse action
Error: Signal Wait cannot be reversed automatically
Info: Native Animation will use AnimationPlayer backwards playback
Warning: Dynamic target must be recorded to support runtime reversal
Timeline preview

The timeline should support:

Forward and backward playheads.
Direction arrows.
Reverse callback markers.
Mirrored stagger preview.
Switching direction while scrubbing.
Inspector

Add a Reverse section:

Reverse
  Reversibility        Automatic
  Reverse easing       Mirror automatically
  Callback policy      Require explicit
  Stagger policy       Reverse order
  Spring behaviour     Retarget physically
  Reverse motion       [Optional resource]
Update the compiler

For compiled native Animation resources:

The same generated animation can normally be played backwards through AnimationPlayer.
Compiler metadata should record whether callbacks and dynamic events retain equivalent reverse semantics.
A successful forward compilation does not automatically mean the entire motion is safely reversible.

The compiler report should say:

Compiled “dialog_enter”

Forward playback: fully native
Backward playback: native with warnings

8 property channels reversible
2 native animations reversible
1 callback has explicit reverse
1 signal wait will be skipped backwards
Update the acceptance criteria

Add a dedicated epic.

Reversible motion acceptance criteria
A completed Sequence plays backwards in reverse child order.
Parallel children remain parallel when reversed.
Stagger order reverses according to policy.
Easing is mirrored correctly.
Reversing halfway does not snap to the end or start.
Playback can change direction repeatedly.
Relative property motions return to the captured initial state.
Dynamic values use recorded forward values during reversal.
Conditional motion reverses the branch that actually executed.
Callbacks require explicit reverse behaviour or a declared policy.
Native animations use backwards playback correctly.
Property ownership remains valid while changing direction.
Layout transitions do not restore stale layouts.
Forward-only events are reported before playback where detectable.

Revised core pillars

I would now describe Anima 2 through four pillars:

Relational composition
Sequence, parallelism and dependencies instead of manually maintained timestamps.
Bidirectional and interruptible motion
Play backwards, reverse midway or physically retarget while preserving state.
Automatic interaction and layout transitions
Node behaviours, layouts and shared elements.
Native Godot authoring and compilation
Use Godot animations as leaves and compile static Anima motion back to native assets.