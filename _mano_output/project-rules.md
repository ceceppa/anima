# Project Rules

The team agrees to follow these architectural decisions, styling standards, and workflow patterns. This list can be extended or modified as required down the line. The coding agent must follow these rules without exception on every single story.

---

## Folder Structure

**What:** Code lives under `addons/anima/motion/`, split into `motion/resources/` (`AnimaMotion` and every subtype) and `motion/runtime/` (`AnimaRuntime`, the scheduler, the evaluation loop, `AnimaPlayback`).

**Why:** Keeps the resource types authors configure separate from the runtime machinery that executes them, and leaves room under `addons/anima/` for a future non-motion module (an editor integration, for instance) to sit alongside `motion/` later without reorganising what's already there.

`resources/` holds every `AnimaMotion` subtype plus any construction-time-only resource or authoring helper that never implements the runtime contract (`estimate_duration()`/`create_runtime()`/`advance()`) — `AnimaEase` and the `Motion` builder are both this second kind, not `AnimaMotion` subtypes themselves.

**Pattern:**
```
addons/anima/
  motion/
    resources/
      anima_motion.gd          # base
      anima_sequence.gd
      anima_parallel.gd
      anima_property_motion.gd
      anima_ease.gd             # curve resource, not an AnimaMotion subtype — still lives with the other resources
      anima_motion_builder.gd   # class_name Motion — fluent builder/factory, not an AnimaMotion subtype either
      anima_behaviour.gd        # class_name AnimaBehaviour — per-node config resource, not an AnimaMotion subtype either
    runtime/
      anima_runtime.gd
      anima_playback.gd       # tracks one play() call's live state; paired with the runtime loop that advances it
      anima_node_proxy.gd     # class_name AnimaNodeProxy — returned by Anima.of(node); a runtime-facing object, not a motion resource
      anima.gd                # class_name Anima entry point
```

## Editor Boundaries

**What:** Editor-only group authoring, Inspector integration, previews, and generated timeline views live outside the runtime and resource layers. Editor code reads and edits motion resources through the same public contracts used by code authoring; it never creates a visual-only group format or bypasses runtime validation.

**Why:** The Motion Composer and Inspector must stay another authoring surface for the one Anima motion model, not a second implementation that drifts from playback.

**Pattern:**
```
addons/anima/
  motion/        # resources and runtime playback
  editor/        # Composer, Inspector, and preview integration
```

**What:** Every `addons/anima/editor/` panel state that currently has nothing actionable to show — no motion open, no group selected, an empty resolved-target list — states the concrete next action available from exactly that state, never a bare label or blank space with no path forward.

**Why:** The reported confusion behind Phase 8's Motion Composer entry-point work was exactly this: a dead-end message with no next step. Stating this as a standing rule keeps the next empty state a panel adds from repeating it.

**Pattern:**
- Bad: `"Select a Group Motion to edit it, or select a compatible parent to add one."` shown with no indication of how to do either from where the author actually is.
- Good: name the specific action reachable from this exact state — open a motion from the Inspector, pick a different motion from the graph, or add a group to the current selection.

**What:** Every `addons/anima/editor/` panel exposes its current empty/nothing-actionable-state message through a small, plain method that returns the string (`status_message()`, `workspace_status_message()`) — never text set only inline inside `_refresh()`'s UI-mutation code.

**Why:** `EditorInspectorPlugin`-derived panel classes can't be instantiated outside a real editor session, so a small testable method separate from the UI-mutation path is the only way to unit-test an empty state's wording and triggering condition — the pattern Phase 8 already established for `AnimaGroupComposer.status_message()` and `AnimaMotionComposer.workspace_status_message()`; every new panel state message follows it too.

**Pattern:**
```gdscript
func status_message() -> String:
    if _group == null:
        return "Select a Group Motion to edit, or add one to the current selection."
    return ""

func _refresh() -> void:
    _status_label.text = status_message()
```

**What:** The Motion Composer's active editing view is chosen from the currently selected motion's type through one shared switch — never a separate, divergent entry point per motion type (one path for opening a Group Motion's view, a different bespoke path for a Property Motion's).

**Why:** Phase 8's review traced the original discoverability complaint to exactly this kind of divergence — one motion type had a working path in, another didn't. A single type-driven switch keeps adding a new editing view (this phase's Property Motion Editing, alongside the existing Group Setup) a matter of adding one match arm, not wiring a second parallel mechanism.

**Pattern:**
```gdscript
func _open_motion(motion: AnimaMotion) -> void:
    match true:
        motion is AnimaGroupMotion:
            _show_group_setup(motion)
        motion is AnimaPropertyMotion:
            _show_property_motion_editing(motion)
```

## Naming

**What:** Every GDScript type is declared with `class_name` in PascalCase, prefixed `Anima` (`AnimaMotion`, `AnimaSequence`, `AnimaPropertyMotion`, …). The file name mirrors the class name in snake_case.

**Why:** Matches Godot's own global-class convention and keeps every type discoverable by name; a mismatched file/class name is a common source of GDScript's duplicate-class-name errors.

**Pattern:**
```
# addons/anima/motion/resources/anima_sequence.gd
class_name AnimaSequence
extends AnimaMotion
```

Exception: the fluent builder class is named `Motion` (`tech-spec.md` §Data model `Motion` row) — unprefixed, since `AnimaMotion` already names the base resource type and `Motion.sequence(...)` is the intended authoring surface. This is the only *unprefixed* type in the addon's public API; it is a one-off carve-out for this specific name clash, not a pattern to extend to future classes.

**What:** A composite motion *resource* class that exists purely as an implementation detail beneath a convenience entry point (`Anima.on()`/`Anima.group()`/`Anima.grid()`) or the `Motion` builder — never meant to be constructed directly by an author — is declared `class_name _AnimaXxx`: still `Anima`-prefixed and PascalCase, with one leading underscore marking it internal-by-convention. A type an author is meant to construct, save, or inspect directly (`AnimaPropertyMotion`, `AnimaKeyframeMotion`, `AnimaGroupMotion`, `AnimaGridMotion`, and similar) keeps the plain, unprefixed-by-underscore form.

**Why:** GDScript has no true access-control keyword for class visibility — every `class_name` is globally addressable — so a leading underscore is the established GDScript community convention for "internal, not part of the intended surface," and it's what keeps `AnimaSequence`/`AnimaParallel`-style composition plumbing from competing with `Anima.on`/`Anima.group`/`Anima.grid` in autocomplete and the "New Resource" picker (`tech-spec.md` §Key technical decisions).

The file name stays unprefixed (`anima_sequence.gd`, not `_anima_sequence.gd`) — this is the one deliberate exception to "the file name mirrors the class name" above, since the underscore marks the class as internal-by-convention, not the file itself.

**Pattern:**
```gdscript
# addons/anima/motion/resources/anima_sequence.gd
class_name _AnimaSequence
extends AnimaMotion
```

**What:** An `AnimaEase` field that only applies to one specific `kind` is prefixed with a short form of that kind's name (`spring_response`, `spring_stiffness`, `elastic_amplitude`, `bezier_p1`, `decay_rate`, `back_overshoot`) — never a bare name that could belong to any kind (`response`, `amplitude`, `rate`).

**Why:** `AnimaEase` holds every kind's fields on one shared Resource (`tech-spec.md` §Data model), so an unprefixed field name can't tell a reader which `kind` it actually belongs to at a glance, or whether it's read at all for the current `kind`.

**Pattern:**
```
# addons/anima/motion/resources/anima_ease.gd
@export var spring_response: float = 0.5   # SPRING only
@export var elastic_period: float = 0.3    # ELASTIC only
```

## Animation Catalog

**What:** A catalog preset's `.tres` lives under `addons/anima/presets/<category>/<name>.tres`, one lowercase folder per category, mirroring Anima v1's own 16 source folders exactly — `attention_seeker/`, `back_entrances/`, `back_exits/`, `bouncing_entrances/`, `bouncing_exits/`, `fading_entrances/`, `fading_exits/`, `lightspeed/`, `rotating_entrances/`, `rotating_exits/`, `slide_exits/`, `sliding_entrances/`, `specials/`, `text/`, `zooming_entrances/`, `zooming_exits/` (`tech-spec.md` §Animation catalog owns the full list). The file stem is the exact registry name `Anima.animation(name)` looks up — no transformation between filename and lookup string.

**Why:** `Anima.animation(name)` (`tech-spec.md` §Animation catalog) resolves a name to a resource; keeping the filename and the lookup name identical, one folder per category, means a contributor can find any of the 99 ported presets from either direction — by name in code, or by browsing the matching category folder — with no separate mapping table to keep in sync. Mirroring v1's own folder split (phase-18) instead of collapsing by `_in`/`_out` suffix keeps each folder to a browsable, single-style size (4-14 presets) rather than one 44-item catch-all.

**Pattern:**
```
addons/anima/presets/
  attention_seeker/
    tada.tres
    heartbeat.tres
  fading_entrances/
    fade_in.tres
  fading_exits/
    fade_out_left_big.tres
  bouncing_entrances/
    bouncing_in_left.tres
  specials/
    hinge.tres
  text/
    typewrite.tres
```

**What:** When porting a v1 dynamic-value formula string, use the same canonical `AnimaValue` mapping for every occurrence of a given v1 idiom — `.` (self) always becomes `AnimaValue.target(property)`, `..` (parent) always becomes `AnimaValue.node(^"..", property)`, and a shared arithmetic shape (e.g. "negate mine, subtract the parent's") is built the same chain of `.negative()`/`.subtract()`/etc. every time it recurs. Do not invent a second, differently-shaped `AnimaValue` chain for a formula pattern already ported elsewhere in the catalog.

**Why:** 99 presets, several sharing the same v1 formula idiom (e.g. every `*_big` fade/slide exit measures against its own size and its parent's), are likely ported across more than one story; a consistent mapping keeps two presets that use the same v1 pattern readable the same way, instead of each implementer re-deriving their own equivalent expression.

**Pattern:**
```gdscript
# v1: "translate:x": "-:size:x - ..:size:x"
AnimaValue.target(^"size:x").negative().subtract(AnimaValue.node(^"..", ^"size:x"))
```

**What:** Each ported preset gets a unit test asserting its resolved keyframe values at representative offsets (`0.0`, an interior stop, `1.0`) — for a preset with a dynamic-value formula, resolved against a known target/parent size — not only a smoke test that the `.tres` loads without error.

**Why:** A silently wrong translation (a flipped sign, a swapped `.target()`/`.node()`) still loads and plays without erroring; only asserting the actual resolved values catches a mistranslation, which is the highest-acknowledged risk in `phase-brief.md` for this catalog.

**Pattern:**
```gdscript
# tests/presets/FadeOutLeftBig.test.gd
func test_translate_x_at_offset_1_accounts_for_own_and_parent_size():
    var resolved := _stop_value_at(preset, "translate:x", 1.0, context)
    assert_eq(resolved, -own_size.x - parent_size.x)
```

## Selector Orientation

**What:** `SelectorDock`'s indicator geometry (`_move_indicator_to`, `_rect_for_index`) already reads each selected item's actual laid-out `position`/`size` — it has no horizontal-only assumption. A vertical selector (e.g. a category sidebar) is a second scene reusing the exact same `selector_dock.gd` script, with its `%Items` container swapped from `HFlowContainer` to `VBoxContainer` — never a second script or a copy of the indicator-drawing code.

**Why:** Re-implementing indicator math for "vertical mode" would fork the one place selection-indicator behaviour lives, the same duplication risk `Card`/`SelectorButton`/`ExampleHeader` were already extracted to prevent. The geometry code was already orientation-agnostic by construction; only the container's layout direction needs to change.

**Pattern:**
```
examples/playground/shared/components/
  selector_dock.gd              # unchanged — same script, both orientations
  selector_dock.tscn             # %Items: HFlowContainer (horizontal)
  selector_dock_vertical.tscn    # %Items: VBoxContainer (vertical) — same script attached
```

## Architecture

**What:** The public entry point (`Anima.play(...)`) is exposed through a `class_name`-declared script, never through a `project.godot` autoload. Do not add anything under `[autoload]`.

**Why:** The tech spec requires zero mandatory setup — nothing should need registering in `project.godot` before `Anima.play()` works.

**Pattern:**
```
# addons/anima/motion/runtime/anima.gd
class_name Anima
extends RefCounted

static func play(motion: AnimaMotion, target: Node) -> AnimaPlayback:
    ...
```

**What:** A lazily-created runtime singleton (like `AnimaRuntime`) adds itself to the scene tree with `add_child.call_deferred(...)`, never a direct `add_child(...)`.

**Why:** The call that first creates the singleton often happens from inside another node's own `_ready()` — e.g. a scene that calls `Anima.play()` as soon as it loads — and at that exact moment the scene tree root can still be mid-`add_child()` for the scene itself. Godot rejects a direct, reentrant `add_child()` on a node that's still busy with its own `add_child()` call ("Parent node is busy setting up children"); this went undetected through three phases of tests because no test happened to call `Anima.play()` from a real node's `_ready()` during actual scene load. Deferring sidesteps the reentrancy entirely, for this singleton and any future one.

**Pattern:**
```
# addons/anima/motion/runtime/anima_runtime.gd
static func get_singleton() -> AnimaRuntime:
    if _instance == null:
        _instance = AnimaRuntime.new()
        (Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(_instance)
    return _instance
```

**What:** Resources hold authored group configuration only. Resolved targets, ordering, ranks, offsets, active instances, and reversal history belong to a playback or execution record created for one run.

**Why:** A reusable Resource must not leak mutable state between concurrent plays, previews, or scene instances.

**Pattern:**
- Create a fresh execution record when playback begins.
- Pass that record to runtime, preview, tracing, and reverse operations instead of recomputing schedule state independently.
- Follow the group contract in `tech-spec.md`; do not add uncontracted configuration fields inline.

## Signal Connections

**What:** Connect a signal through the editor/scene file — the Node panel's drag-and-connect, which produces a `[connection signal="..." from="..." to="..." method="..."]` line in the `.tscn` — whenever both the emitting node and the receiving node/method already exist in that scene at edit time. Only connect with GDScript (`.connect()`) when the emitting node doesn't exist until runtime — an instantiated template, a node built in a loop, or similar — where there is no scene-file node to wire.

**Why:** An editor-declared connection is visible and editable directly in the `.tscn`/Node panel without opening the script, and is Godot's own default authoring path; a code-only connection for a node that was already sitting in the scene is a second, harder-to-discover source of the same wiring, and is easy to leave stale or duplicated when a node is renamed, removed, or reconnected.

**Pattern:**
```
# Preferred — an editor-connected signal on a node already in the scene:
[connection signal="reverse_pressed" from="Margin/Content/PlaybackControls" to="." method="_on_playback_controls_reverse_pressed"]

# GDScript only when the node doesn't exist until runtime:
for family in FAMILY_ORDER:
    var button: SelectorButton = SELECTOR_BUTTON.instantiate()
    button.pressed.connect(select_family.bind(family))
```

## Patterns

**What:** Every `AnimaMotion` subtype implements all three base-contract methods explicitly — `estimate_duration()`, `create_runtime()`, `validate()`. Never rely on an inherited default that silently returns a zero, empty, or no-op result.

**Why:** The scheduler treats every motion type polymorphically through this contract; a subtype that skips one method fails silently at runtime instead of erroring, which is far harder to debug in a relational system.

**Pattern:**
```
class_name AnimaPropertyMotion
extends AnimaMotion

func estimate_duration() -> float:
    return duration

func validate() -> Array[String]:
    var errors: Array[String] = []
    if target_property.is_empty():
        errors.append("target_property is required")
    return errors
```

## Node Liveness

**What:** Check whether a `Node` reference is still alive with `is_instance_valid(node)`, never `node != null` / `node == null`. If code needs to distinguish "a reference was ever supplied" from "it's alive right now," capture the former in its own `bool` at the point the reference is still known-good — a freed `Node` still compares equal to `null` via `==`/`!=`, so a later plain null-check can no longer tell the two cases apart.

**Why:** A freed, non-`RefCounted` `Object` still compares equal to `null` via `==`/`!=` in this engine version — a plain `target != null` guard silently stops working the moment the exact thing it's supposed to catch (a freed target) happens, which is precisely the failure mode this rule prevents.

**Pattern:**
```gdscript
var _has_target: bool = false

func _init(p_target: Node = null) -> void:
    target = p_target
    _has_target = p_target != null  # captured while target is still known-good

func _advance() -> void:
    if _has_target and not is_instance_valid(target):
        cancel()
        return
```

## Derived Scheduling

**What:** Resolve, filter, order, rank, and schedule a target collection once per execution through shared group helpers. Consumers use the resulting execution record rather than recalculating order or start offsets.

**Why:** Playback, reverse, compiler output, diagnostics, and the Composer must agree on the same group schedule.

**Pattern:**
- Keep target resolution and schedule derivation separate from leaf-motion evaluation.
- Treat generated timeline rows and preview highlights as read-only projections of the execution record.
- Route a missing group behaviour back to `tech-spec.md` instead of encoding a local scheduling exception.

## Testing

**What:** Every piece of code ships with a test — no exceptions. Tests use GUT ([bitwes/Gut](https://github.com/bitwes/Gut)), already installed at `addons/gut`, and live flat in `tests/`. A unit test is named `<ClassName>.test.gd` for the type it covers. An integration test — exercising behaviour across multiple classes through the public `Anima.<...>` entry point — is named `Anima.integration.<name>.test.gd`. A story that introduces one type needs at least the unit test; a story that composes multiple types together through `Anima.play()` (or another `Anima.<...>` entry point) also needs an integration test.

**Why:** GUT is already the project's test runner. Unit tests are named after the class they cover; integration tests are named after the entry point they exercise (`Anima`) rather than an arbitrary label, since every integration test drives the system the same way a real caller does — through `Anima.<something>`.

**Pattern:**
```
tests/AnimaSequence.test.gd
tests/AnimaParallel.test.gd
tests/Anima.integration.playback.test.gd
```

**What:** Never write a throwaway smoke-test script to verify behaviour and then delete it once it passes. If a check is worth writing to confirm something works, it's worth keeping as a permanent test under `tests/`, following the naming convention above.

**Why:** A disposable smoke test still has to catch a real bug to earn its keep — deleting it after one green run throws away that coverage and lets the same regression slip back in silently later, unnoticed until it breaks something a user can see.

**Pattern:**
```
tests/Anima.integration.composition_playground.test.gd   # kept, not deleted after the one-off check that motivated it
```

**What:** Scheduling code is tested through deterministic, observable group outcomes before editor presentation is tested.

**Why:** A visually plausible group can still have incorrect ranks, offsets, completion, or reversal behaviour that later surfaces across every authoring surface.

**Pattern:**
- Unit-test pure resolution, ordering, and schedule derivation with fixed inputs and seeds.
- Integration-test runtime playback and lifecycle through the public facade.
- Treat Composer and compiler tests as consumers of the same established execution record.

## Documentation

**What:** GDScript `##` comments are the canonical public API documentation. Every public class, function, property, signal, enum, and enum value has a complete comment directly above its declaration; changing public behaviour means updating that comment in the same story. The online API reference is generated from these comments, never maintained as a competing hand-written copy.

**Why:** The Godot editor is where authors discover and search Anima APIs. One source of truth gives them useful in-editor help and prevents the website from drifting away from the code.

**Pattern:**
```gdscript
## Plays [param motion] on [param target] and returns controls for this one run.
##
## A motion describes an animation. A target is the node that visibly changes.
## [param target] is optional when the motion already chooses its targets.
static func play(motion: AnimaMotion, target: Node = null) -> AnimaPlayback:
    ...
```
Use Godot's `[ClassName]`, `[method Class.name]`, and `[param name]` reference syntax when it helps navigation in the editor.

**What:** Public comments are written for someone new to Godot and programming. A class comment states what the feature lets an author achieve and defines unfamiliar Godot terms the first time they appear. A property comment says what changing it visibly changes and its default or allowed choices. A method comment states the action, what each input means, what it returns or changes, and any outcome an author needs to know. Signal, enum, and enum-value comments state when they occur or what each choice means in plain language.

**Why:** A one-line technical label is searchable but does not help a newcomer decide whether the API is the right tool or use it safely.

**Pattern:**
- Start with the author-visible outcome, not the implementation detail.
- Use a short follow-up paragraph when inputs, defaults, interruption, determinism, or reduced motion materially change the result.
- Keep every example self-contained and minimal; explain any Godot-specific word in the example before relying on it.

**What:** Generated online pages retain the established reference shape from `v2_stuff/doc.example.md`: front matter, one-line description, Overview, Inheritance, Availability, Quick example, and only the applicable API sections. The generator derives page prose and API lists from code comments; it does not require contributors to maintain a second explanation under `docs/content/docs/anima/`.

**Why:** The website and the editor should answer the same questions in the same language while the generated page retains a skimmable reference structure.

**Pattern:**
- Keep enough context in class and member comments to populate the matching online section.
- Include Determinism, Performance notes, Reduced motion, or Interruption behaviour only when the API has that behaviour.
- Generation tooling and the Hugo pipeline are defined by `_mano_output/tech-spec.md`; do not add a second documentation format inline.

**What:** Every script added under `addons/anima/editor/` ships with a companion usage guide at `docs/content/docs/guides/<slug>/index.md` — under the dedicated `Guides` section, not nested inside `anima/` — written in the same story that adds the script. Unlike the generated API pages above, this is hand-written prose covering what the tool is for and how to use it from inside the Godot editor: where the panel/dock lives, what each control does, and a short numbered walkthrough. It documents editor workflow, not public members, so it is not the "second explanation" the rule above warns against. If a step is clearer with a screenshot, embed an `![alt](placeholder.png)` reference to an image co-located in the same guide folder (Hugo leaf-bundle style) and add an HTML comment directly below it stating exactly what to capture — panel name, editor state, what must be visible. Capture the screenshot directly when able to drive the Godot editor UI; otherwise leave the placeholder and comment for the user to capture manually.

**Why:** An editor tool only reads as a shipped feature once someone can find and drive it; the generated class page documents its public API, not the dock someone opens in the Godot editor or what pressing each control does. Guides live in their own top-level `Guides` section — sibling to `Anima Addon`, with its own `docs/content/docs/guides/_index.md` menu entry (`weight`, `title`, `icon` front matter, matching `anima/_index.md`'s pattern) — because a workflow walkthrough and a generated API reference are different kinds of page a reader browses separately, not a subsection of the class reference.

**Pattern:**
```
docs/content/docs/guides/motion-composer/
  index.md
  panel-default.png          # placeholder until captured
```
```md
---
title: "Motion Composer"
---

## What it does
...

## How to use it
1. Select a node with an `AnimaMotion` resource assigned.
2. Open the **Motion Composer** dock from the bottom panel.

![Motion Composer default state](panel-default.png)
<!-- PLACEHOLDER: screenshot needed — Motion Composer dock, docked open, a single AnimaPropertyMotion selected, default/empty state -->
```

**What:** A hand-written page about a *runtime* concept (not an `addons/anima/editor/` tool) lives in one of three sections by kind, each with its own `_index.md` (`weight`, `title`, `description`, `icon`, `draft: false`, matching `anima/_index.md`'s existing shape — exact weight values and current section list are `tech-spec.md` §Documentation site structure's, not repeated here): a scannable "what ships" catalogue at `docs/content/docs/features/<slug>.md`; a conceptual "how/why does X work" walkthrough at `docs/content/docs/guides/<slug>.md`, sibling to the existing `motion-composer/` editor-tool guide; a numbered, sequential "build this" walkthrough as a leaf bundle at `docs/content/docs/tutorials/<NN>-<slug>/index.md`, ordered by its own page-level `weight`.

**Why:** A Feature, a Guide, and a Tutorial answer different reader questions — what exists, how does one mechanism work, walk me through building something — and each already has (or, this phase, gains) its own top-level nav section for that reason. Filing a runtime-concept guide inside the generated `anima/` reference, or a build-something walkthrough inside the topic-parallel `Guides` section, would put a reader-question in the wrong drawer.

**Pattern:**
```
docs/content/docs/
  features/
    built-in-animations.md
    built-in-easings.md
  guides/
    motion-composer/index.md   # editor-tool guide, existing
    dynamic-values.md          # runtime-concept guide, plain .md — no images
  tutorials/
    01-basic-animation/index.md
    02-popup-animation/index.md
```

**What:** Every Feature, Guide, and Tutorial page contains at least one fenced ` ```gdscript ` code block a reader can copy directly into their own project and run — never a prose-only explanation. A Tutorial additionally states in its own prose which earlier tutorial it continues from, since Tutorials are ordered and cumulative while Guides and Features are topic-parallel and stand alone.

**Why:** A newcomer deciding whether to trust a claim about Anima needs to see it work, not just read that it does — the same posture `anima/_index.md`'s "Getting started" section already takes, extended uniformly to every hand-written page rather than left to each contributor's judgment.

**Pattern:**
```md
Reading a property mid-flight isn't exposed today — but `AnimaValue` can read
any node's *current* property to build a new animation from it:

```gdscript
var pulse := Anima.on($Card).scale(Vector2(1.2, 1.2)) \
    .from(AnimaValue.target(^"scale"))
```
```

**What:** In a Feature, Guide, or Tutorial code example, a motion built via `Anima.on(target)` plays with `.play()` chained directly on it, not `Anima.play(motion, target)`. The explicit two-argument form is reserved for a motion with no captured target — a bare `Anima.animation(name)` catalog preset, or a `.duplicate()` of one — where `.play()` would report an error and return `null`.

**Why:** `.play()` is the convenience form `Anima.on()` exists to make reachable — repeating the target a second argument later, when the motion already captured it, contradicts the "hides the complexity" pitch these pages are making. `docs/content/docs/anima/_index.md`'s own "Getting started" section already favours `Anima.on()` over hand-built `Motion.to()` for the identical reason; this rule keeps every hand-written page consistent with it.

**Pattern:**
```gdscript
# Built via Anima.on() — captured a target, so .play() works:
var fade_in := Anima.on($Label).opacity(1.0).from(0.0).with_duration(0.5)
fade_in.play()

# No captured target (a catalog preset, or a duplicate of one) — .play() would
# error; use the explicit form instead:
var my_tada := Anima.animation("tada").duplicate(true) as AnimaMotion
Anima.play(my_tada, $Card)
```

## Example Scenes

**What:** `examples/` splits by what a scene demonstrates. A scene an author *runs* to see the runtime motion API in action — driven by `Anima.play()`, restart/reverse controls, the shared theme and components below — lives under `examples/playground/`. A scene that showcases an `addons/anima/editor/` tool itself — something an author *opens in the Godot editor* to see a panel like the Motion Composer at work, not something that runs as a game — lives under `examples/editor/`. A scripted, self-contained scene built to be captured (screen-recorded or exported via Godot's Movie Writer) for marketing/social content, rather than to demo an API to a developer, lives under `examples/showcase/`. The Demo Selector — the entry-point scene that lists and opens the playground demos — lives directly under `examples/`, not inside `examples/playground/`: it is the shared entry point above the three-way split, not one specific `examples/playground/` demo itself.

**Why:** These are three different audiences and three different ways of consuming the example: playing a scene, opening it and driving the editor around it, or watching a fixed sequence play through once for capture. Keeping them in separate top-level folders keeps `examples/playground/`'s shared runtime chrome (theme, `Card`, `PlaybackControls`, `SelectorDock`, …) from being assumed by scenes that don't need it — an editor-tooling showcase, or a showcase scene with no restart/reverse controls at all. The Demo Selector sits above that split by construction — nesting the whole-project entry point inside just one of the categories it points into would misrepresent what it is.

**Pattern:**
```
examples/
  demo_selector.tscn   # entry point — lists and opens the playground demos
  demo_selector.gd
  playground/     # runtime motion scenes — Anima.play(), restart/reverse controls
  editor/         # showcase scenes for addons/anima/editor/ tools — opened in the Godot editor, not run
  showcase/       # scripted scenes built for external capture — no dev playback controls
```

**What:** A scene under `examples/showcase/<name>/` is self-contained: its own scene tree, its own visual assets under `examples/showcase/<name>/assets/`, and its own script — never `examples/playground/shared/`'s theme or components (`Card`, `PlaybackControls`, `SelectorDock`, `ExampleHeader`). It plays its full sequence automatically from `_ready()` with no button press or other input required, since the point is a clean, deterministic capture, not an author interacting with it. Any timing value a human will want to retune between takes (a stagger delay, a scene-transition point) is an `@export` on the scene's own script, following the existing Editor-Authored Content rule below, not a hardcoded literal.

**Why:** A showcase scene targets a viewer on social media, not a developer evaluating the API — reusing the playground's dev-facing restart/reverse/speed controls or shared theme would show the wrong chrome in the capture. Keeping its assets scoped under its own `assets/` folder (rather than the shared `examples/playground/images/`) keeps art supplied for one specific piece of content from being mistaken for reusable playground artwork.

**Pattern:**
```
examples/showcase/
  grid/
    assets/
      background.jpg
    grid_showcase.tscn
    grid_showcase.gd        # plays the full sequence in _ready(); no restart/reverse controls
```

**What:** The `examples/editor/` showcase for the Motion Composer's four editor panels is one scene, `motion_composer_showcase.tscn`, holding four labelled nodes — one carrying an authored Group Motion, one carrying an authored Property Motion, one carrying a compiled/resolved group ready for inspection, and one with no motion assigned — not four separate scene files. It uses plain Godot nodes with no shared theme or `examples/playground/shared/` component; `examples/editor/` scenes are opened and clicked through, not run, so the playground's runtime visual chrome does not apply.

**Why:** `ux-flow.md`'s Editor Tooling Showcase Scene defines this as one scene a developer opens and clicks through node by node to see each Motion Composer state live; four separate project files would mean opening and closing four scenes to see four states of the same dock.

**Pattern:**
```
examples/editor/
  motion_composer_showcase.tscn
    GroupMotionExample      # AnimaGroupMotion assigned — opens Group Setup
    PropertyMotionExample   # AnimaPropertyMotion assigned — opens Property Motion Editing
    ResolvedGroupExample    # compiled/resolved group — opens Group Inspection
    EmptyExample            # no motion assigned — opens the top-level entry-point empty state
```

**What:** UI-facing example/demo scenes under `examples/playground/` (starting with this phase's composition example) use a custom Godot `Theme` resource applied at the scene root — never the engine's default, unthemed control styling. Reusable visual pieces (artwork cards, playback control bars, tab strips, and similar) are built as their own scenes/scripts under `examples/playground/shared/`, not duplicated per example scene.

**Why:** The design brief calls for a custom, dark, luminous scene rather than stock Godot widget styling; shared, themed components keep example scenes consistent.

**Pattern:**
```
examples/
  playground/
    shared/
      theme/
        anima_examples.tres       # custom Theme resource, applied at each example scene's root
      components/
        example_header.tscn       # icon + title + subtitle (+ optional counter), shared by every example scene
        example_header.gd
        card.tscn                 # shared artwork card animated by Anima
        card.gd
        playback_controls.tscn    # restart/play-pause/speed, etc.
        playback_controls.gd
        selector_dock.tscn        # owns the shared background + the sliding selected-item indicator
        selector_dock.gd
        selector_button.tscn      # one item inside a SelectorDock — label colour/weight only, no own fill
        selector_button.gd
    images/
      cards.jpg                  # 4 × 3 Card artwork atlas
    composition_playground.tscn   # this phase's example scene, composed from the shared components above
```

**What:** Every runnable playground scene extends the shared `ExamplePlayground`
root script. HiDPI content scaling lives in its own standalone add-on under
`addons/hidpi_scale/`, not inline on `ExamplePlayground` — `ExamplePlayground`
calls into the add-on from `_ready()`; individual playgrounds do not duplicate
a local scaling helper of their own, and the add-on itself carries no
Anima-specific behaviour or dependency, so it stays reusable outside this
project too.

**Why:** Examples must remain legible at the display scale the author actually
uses. Extracting the scaling logic into its own add-on (`tech-spec.md`
§Example playground: navigation and scaling) keeps that behaviour reusable on
its own, separate from the Anima product addon; a shared `ExamplePlayground`
root still keeps every playground's behaviour consistent as more demos are
added.

**Pattern:**
```gdscript
# addons/hidpi_scale/hidpi_scale.gd
class_name HiDPIScale
extends RefCounted
# owns display-scale detection and node scaling only — no Anima dependency

# examples/playground/shared/components/example_playground.gd
class_name ExamplePlayground
extends Control

func _ready() -> void:
    HiDPIScale.apply_to(self)

# examples/playground/a_playground.gd
extends ExamplePlayground

func _ready() -> void:
    super._ready()
    # scene-specific setup
```

**What:** Example-scene component scripts use plain descriptive names (`Card`, `PlaybackControls`), not the `Anima`-prefixed `class_name` convention.

**Why:** The `Anima` prefix is reserved for the addon's own public runtime/resource API (see Naming); example-only UI helpers aren't part of that surface, and prefixing them the same way would blur which classes ship in the addon versus which live only in the examples project.

**Pattern:**
```
# examples/playground/shared/components/card.gd
class_name Card
extends PanelContainer
```

**What:** `Card` draws from the single `examples/playground/images/cards.jpg` atlas through Godot's Region feature. The atlas is 1536×1023 pixels, arranged as four columns by three rows; every card region is 384×341 pixels. Scene authoring selects a zero-based cell index in row-major order and derives the Region offset from that index. The component has no state enum or letter-label fallback. `set_progress(t)` remains the only runtime visual driver, animating the frame's border, glow, opacity, and scale.

**Why:** One atlas keeps related artwork together and makes every Card selection deterministic. Fixed regions prevent accidental cropping drift or stretched art across examples.

**Pattern:**
```
# examples/playground/shared/components/card.gd
class_name Card
extends PanelContainer

# index 0: Region(0, 0, 384, 341)
# index 1: Region(384, 0, 384, 341)
# index 4: Region(0, 341, 384, 341)
# column = index % 4; row = index / 4
func set_progress(t: float) -> void:
    ...
```

**What:** The 3D counterpart of `Card` — the Icosahedron used by the 3D Motion Example Scene — is its own shared component under `examples/playground/shared/components/`, named `Card3D` (plain descriptive name, same convention as `Card`), never built inline in the 3D playground scene. Its source mesh lives under `examples/playground/models/`; its fresnel-rim/emissive-core look is a dedicated `ShaderMaterial` resource under `examples/playground/shared/materials/`, not shader code inline in the component script or scene. `Card3D` mirrors `Card`'s `set_progress(t)` contract — the same single runtime visual driver, translated to the 3D component's own emissive intensity, fresnel strength, and scale pulse — so a playground can swap between them without a different animation-driving API.

**Why:** The 3D playground is the first of what could become more than one 3D example; keeping the mesh, shader, and motion-progress-driven visual language in one reusable component avoids the same duplication risk `Card`, `SelectorButton`, and `ExampleHeader` were already extracted to prevent.

**Pattern:**
```
examples/playground/
  models/
    card.obj                   # Icosahedron source mesh
  shared/
    materials/
      card_3d.gdshader          # fresnel rim + emissive core
    components/
      card_3d.tscn              # shared 3D card
      card_3d.gd
```
```gdscript
# examples/playground/shared/components/card_3d.gd
class_name Card3D
extends Node3D

func set_progress(t: float) -> void:
    ...  # drives emissive intensity, fresnel strength, and the same scale pulse Card uses
```

**What:** A toggle/segment-style item inside a selector (like the composition-type selector) is built from the shared `SelectorButton` component under `examples/playground/shared/components/` — never an ad-hoc `StyleBoxFlat` constructed inline in a scene script. Its content margins — `24px` left/right, `12px` top/bottom, `12px` corner radius — are the one canonical button-padding value for every button in an example scene, toggle or not; the shared theme's own Button style (`anima_examples.tres`) must match it.

**Why:** This padding value existed only once, inline, in a scene script's ad-hoc `StyleBoxFlat` — it silently diverged from the shared theme's own Button style, which had no padding at all, and the mismatch went unnoticed until a real button visibly had no left/right margin. Pulling it into one shared component prevents that same drift on the next button a future example scene adds.

**Pattern:**
```
# examples/playground/shared/components/selector_button.gd
class_name SelectorButton
extends Button

func set_selected(selected: bool) -> void:
    ...  # label colour/weight only — no own background fill (see SelectorDock)
```

**What:** The selector's shared background, border, and the visible selected-state indicator are owned by a separate `SelectorDock` component, not by each `SelectorButton`. `SelectorDock` holds one indicator child that repositions and resizes to sit behind whichever `SelectorButton` is currently selected; the buttons themselves only change label colour/weight and never render their own selected-state background fill.

**Why:** The design direction (`design-brief.md` § Selector dock) calls for one indicator that physically animates between items. If each button also kept its own selected-fill logic, there would be two independent sources of "selected" visual truth animating separately instead of one shared, single-owner indicator.

**Pattern:**
```
# examples/playground/shared/components/selector_dock.gd
class_name SelectorDock
extends PanelContainer

func select(index: int) -> void:
    ...  # animates the shared indicator to the SelectorButton at `index`
```

**What:** Every example scene's top-level header is the shared `ExampleHeader` component under `examples/playground/shared/components/` (icon + title + subtitle) — never a scene-specific title `Label` built inline. The per-type counter lives on the stage's own type-title row (it changes as the user switches composition type), not on `ExampleHeader`.

**Why:** `design-brief.md` scopes the header as reusable across every future example scene; building it once now, the same way `Card` and `SelectorButton` were extracted, prevents it being reimplemented (and drifting) per scene later.

**Pattern:**
```
# examples/playground/shared/components/example_header.gd
class_name ExampleHeader
extends PanelContainer

@export var title: String = "": ...
@export var subtitle: String = "": ...
@export var icon: String = "": ...
```
See **Editor-Authored Content** below for why these are exports, not setter methods called from a parent script.

**What:** Static, per-scene authoring content — labels, titles, subtitles, icons, and any other value that is fixed for the life of one scene instance — is exposed as an `@export` property on the component and set directly in the `.tscn` via the editor Inspector. It is not assigned imperatively from a parent scene's script (e.g. calling `_header.set_title(...)` from `composition_playground.gd`'s `_ready()`). Reserve code-driven setters for values that genuinely change at runtime — `Card.set_progress(t)`, `SelectorDock.select(index)` — where there's nothing for the editor to author because the value doesn't exist until the scene runs.

**Why:** A value like `ExampleHeader`'s title or icon never changes once the scene is built; hardcoding it in a parent script's `_ready()` hides that content from the editor and from anyone opening the `.tscn` — reading the script becomes the only way to see what an example scene actually says. Exporting it keeps the content visible and editable in the Inspector, matching how Godot scenes are meant to be authored.

**Pattern:**
```
# examples/playground/shared/components/example_header.gd
@export var title: String = "":
    set(value):
        title = value
        if is_node_ready():
            _title.text = value
```
```
# examples/playground/composition_playground.tscn — authored in the editor Inspector,
# not assigned in composition_playground.gd
[node name="Header" parent="..." instance=ExtResource("...")]
title = "Composition"
subtitle = "Combine simple animations into expressive flows."
icon = "✦"
```

**What:** A component's fixed child nodes — a `MeshInstance3D` and its mesh/material, a `TextureRect`, or any other child that exists for the life of the scene — are added and wired up directly in the `.tscn` via the editor, not constructed and attached in `_ready()`/`_init()` with code (`MeshInstance3D.new()`, `add_child(...)`, a `ShaderMaterial.new()` assigned at runtime). Reserve runtime construction for children that genuinely can't exist until the scene runs — a count only known at runtime, a pooled/dynamic instance. This applies wherever a scene is being composed, not only `examples/playground/`: example components and `addons/anima/editor/` panels alike.

**Why:** A child built entirely in code is invisible in the Godot editor's own scene tree and viewport until the scene actually runs — no mesh preview, no Inspector access to its material's shader parameters, nothing to click on while iterating. `Card3D` originally built its `MeshInstance3D` and `ShaderMaterial` in `_ready()`, which made it hard to visually debug for exactly this reason. Authoring the node in the `.tscn` instead makes it inspectable and editable the same way every other node in the project already is.

**Pattern:**
```gdscript
# Bad — constructs and attaches the child entirely in code
func _ready() -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.mesh = preload("res://.../card.obj")
    mesh_instance.material_override = ShaderMaterial.new()
    add_child(mesh_instance)

# Good — card_3d.tscn owns the MeshInstance3D node (mesh + material_override
# assigned in the editor Inspector); the script only grabs it via @onready
# and drives runtime-only values (e.g. a shader's `progress` parameter).
@onready var _mesh_instance: MeshInstance3D = %MeshInstance
```

**What:** A known, fixed image or shader asset — a background, a frame, an icon whose file path is known at authoring time — is assigned as an `ext_resource` directly in the `.tscn` (or set on the node's property in the editor Inspector), never fetched with `load(...)`/`preload(...)`/`ResourceLoader` in a script. This applies wherever a scene is being composed, the same scope as the fixed-child-nodes rule above. It does not cover a resource whose *count* or *identity* genuinely isn't known until runtime (e.g. scanning a folder of user-supplied icons where the number of files varies) — that case still needs code to discover and load what's actually present, the same "count only known at runtime" exception the fixed-child-nodes rule already carves out. It also doesn't cover a texture generated procedurally with no source file (a placeholder swatch, a `GradientTexture2D`) — there's no asset path to leak out of the `.tscn` in the first place.

**Why:** A `load("res://...")` path string in a script is invisible to the editor's own dependency tracking and preview until the scene actually runs, and can fail silently at runtime with no compile-time signal — the `.tscn`'s `ext_resource` table is the one place every asset a scene depends on is already declared and inspectable, and a code-based load duplicates that without the editor ever knowing about it.

**Pattern:**
```gdscript
# Bad — loads a known, fixed asset by path string at runtime
func _ready() -> void:
    _background.texture = load("res://examples/showcase/grid/assets/background.jpg")

# Good — the .tscn's own ext_resource assigns it; the script only reads the node
# [ext_resource type="Texture2D" path="res://.../background.jpg" id="2"]
# [node name="Background" type="TextureRect" parent="."]
# texture = ExtResource("2")

# Still fine — the set of files isn't known until the scene runs
func _discover_icon_paths() -> Array:
    var dir := DirAccess.open("res://.../assets/icons")
    ...
```

**What:** Any `examples/playground/shared/components/` element that needs a genuine radial gradient fill or a soft accent glow — a stage background, a card frame — builds it with a `GradientTexture2D` set to `fill = GradientTexture2D.FILL_RADIAL`, the same technique the stage background glow already uses. Never a second mechanism for the same look — no inline shader, no hand-drawn `_draw()` override. This doesn't cover a genuinely flat fill (e.g. the playback buttons' flat `accent` fill and border) — a gradient/glow was tried there and dropped for reading as visual noise; `StyleBoxFlat` is the right tool for a flat colour with a border, not a workaround this rule forbids.

**Why:** The radial-gradient technique is already proven and reused across every 2D playground's stage background; a different mechanism for the same visual effect elsewhere would only fork how one look is achieved, with no benefit, and make the next glow/gradient addition a fresh decision instead of a known pattern.

**Pattern:**
```gdscript
var gradient := Gradient.new()
gradient.set_color(0, accent_soft)  # centre highlight
gradient.set_color(1, accent)       # edge

var texture := GradientTexture2D.new()
texture.gradient = gradient
texture.fill = GradientTexture2D.FILL_RADIAL
```

---

<!-- Do not add a "Workflow", "How to use", or "Implementation guide" section. The rules in this file are the instructions; meta-guidance about applying them lives in AGENTS.md. -->
