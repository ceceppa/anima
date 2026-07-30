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
    runtime/
      anima_runtime.gd
      anima_playback.gd       # tracks one play() call's live state; paired with the runtime loop that advances it
      anima.gd                # class_name Anima entry point
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

Exception: the fluent builder class is named `Motion` (`tech-spec.md` §Data model `Motion` row) — unprefixed, since `AnimaMotion` already names the base resource type and `Motion.sequence(...)` is the intended authoring surface. This is the only unprefixed type in the addon's public API; it is a one-off carve-out for this specific name clash, not a pattern to extend to future classes.

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

## Documentation

**What:** Every public class ships a documentation page at `docs/content/docs/anima/<kebab-case-class-name>.md` (e.g. `AnimaPropertyMotion` → `anima-property-motion.md`). Follow the structure in `v2_stuff/doc.example.md`: front-matter, a one-line description, Overview, Inheritance, Availability, Quick example, then whichever of Properties / Methods / Signals / Enumerations / Constants the class actually has. Sections the template marks as conditional (Determinism, Performance notes, Reduced motion, Interruption behaviour, and similar) are included only when they genuinely apply to that class — do not add a section with nothing to say just to match the template. The Availability section's Godot version comes from `tech-spec.md`'s Platform constraints, not a restated number.

**Why:** Keeps every class's documentation the same shape as the class count grows, instead of each page inventing its own structure.

**Pattern:**
```markdown
---
title: "AnimaPropertyMotion"
description: "Animates a single property on a node from one value to another."
godot_version: "4.x"
anima_version: "2.x"
api_type: "class"
---

# AnimaPropertyMotion

...
```
See `v2_stuff/doc.example.md` for the full section-by-section structure.

**What:** Write every page for a reader with zero prior Godot or programming experience — define a Godot-specific term (`Resource`, `NodePath`, `signal`, and similar) the first time it's used on a page, avoid unexplained jargon, and keep the Quick example minimal and runnable standalone.

**Why:** Anima's own audience includes developers new to both Godot and programming, not just developers new to Anima; a page that assumes prior GDScript familiarity fails that reader.

**Pattern:**
- Before using a Godot-specific term for the first time on a page, explain what it means in one clause.
- The Quick example section must not depend on setup the reader hasn't already seen on that same page.

## Example Scenes

**What:** UI-facing example/demo scenes (starting with this phase's composition example) use a custom Godot `Theme` resource applied at the scene root — never the engine's default, unthemed control styling. Reusable visual pieces (state cards, playback control bars, tab strips, and similar) are built as their own scenes/scripts under `examples/shared/`, not duplicated per example scene.

**Why:** The reference visual direction (`v2_stuff/ex1.jpg`) is a modern, custom-styled look, not stock Godot widget styling; shared, themed components built once keep every future example scene consistent instead of each one restyling controls from scratch.

**Pattern:**
```
examples/
  shared/
    theme/
      anima_examples.tres       # custom Theme resource, applied at each example scene's root
    components/
      example_header.tscn       # icon + title + subtitle (+ optional counter), shared by every example scene
      example_header.gd
      state_card.tscn           # e.g. the A/B/C motion-state cards in v2_stuff/ex1.jpg
      state_card.gd
      playback_controls.tscn    # restart/play-pause/speed, etc.
      playback_controls.gd
      selector_dock.tscn        # owns the shared background + the sliding selected-item indicator
      selector_dock.gd
      selector_button.tscn      # one item inside a SelectorDock — label colour/weight only, no own fill
      selector_button.gd
  composition_playground.tscn   # this phase's example scene, composed from the shared components above
```

**What:** Example-scene component scripts use plain descriptive names (`StateCard`, `PlaybackControls`), not the `Anima`-prefixed `class_name` convention.

**Why:** The `Anima` prefix is reserved for the addon's own public runtime/resource API (see Naming); example-only UI helpers aren't part of that surface, and prefixing them the same way would blur which classes ship in the addon versus which live only in the examples project.

**Pattern:**
```
# examples/shared/components/state_card.gd
class_name StateCard
extends PanelContainer
```

**What:** `StateCard` has no state of its own — no state field, no state enum, nothing a caller sets by name. It's one plain visual style (dark card, thin outline, soft shadow, bold label) that exposes `set_label(text: String)` and `set_progress(t: float)`, where `t` (`0.0`–`1.0`) continuously drives every visual property — border colour, glow, label colour, opacity, and a small scale pulse — from that one value, the same way any other node's properties get animated. `0.0` is at rest/not started, `1.0` is fully complete; nothing in between is a named state.

**Why:** An earlier version modelled this as a `WAITING | PLAYING | COMPLETED` enum with a `set_state()` call per transition, which meant the "complete" look snapped in abruptly the instant `t` crossed into that state instead of arriving smoothly. Collapsing it to one continuous driver removes the discrete jump entirely — there's no state boundary left to snap across, and every composition type in the example scene drives it the same way regardless of how many pulses it needs.

**Pattern:**
```
# examples/shared/components/state_card.gd
class_name StateCard
extends PanelContainer

func set_label(text: String) -> void:
    ...

func set_progress(t: float) -> void:
    ...
```

**What:** A toggle/segment-style item inside a selector (like the composition-type selector) is built from the shared `SelectorButton` component under `examples/shared/components/` — never an ad-hoc `StyleBoxFlat` constructed inline in a scene script. Its content margins — `24px` left/right, `12px` top/bottom, `12px` corner radius — are the one canonical button-padding value for every button in an example scene, toggle or not; the shared theme's own Button style (`anima_examples.tres`) must match it.

**Why:** This padding value existed only once, inline, in a scene script's ad-hoc `StyleBoxFlat` — it silently diverged from the shared theme's own Button style, which had no padding at all, and the mismatch went unnoticed until a real button visibly had no left/right margin. Pulling it into one shared component prevents that same drift on the next button a future example scene adds.

**Pattern:**
```
# examples/shared/components/selector_button.gd
class_name SelectorButton
extends Button

func set_selected(selected: bool) -> void:
    ...  # label colour/weight only — no own background fill (see SelectorDock)
```

**What:** The selector's shared background, border, and the visible selected-state indicator are owned by a separate `SelectorDock` component, not by each `SelectorButton`. `SelectorDock` holds one indicator child that repositions and resizes to sit behind whichever `SelectorButton` is currently selected; the buttons themselves only change label colour/weight and never render their own selected-state background fill.

**Why:** The design direction (`design-brief.md` § Selector dock) calls for one indicator that physically animates between items. If each button also kept its own selected-fill logic, there would be two independent sources of "selected" visual truth animating separately instead of one shared, single-owner indicator.

**Pattern:**
```
# examples/shared/components/selector_dock.gd
class_name SelectorDock
extends PanelContainer

func select(index: int) -> void:
    ...  # animates the shared indicator to the SelectorButton at `index`
```

**What:** Every example scene's top-level header is the shared `ExampleHeader` component under `examples/shared/components/` (icon + title + subtitle) — never a scene-specific title `Label` built inline. The per-type counter lives on the stage's own type-title row (it changes as the user switches composition type), not on `ExampleHeader`.

**Why:** `design-brief.md` scopes the header as reusable across every future example scene; building it once now, the same way `StateCard` and `SelectorButton` were extracted, prevents it being reimplemented (and drifting) per scene later.

**Pattern:**
```
# examples/shared/components/example_header.gd
class_name ExampleHeader
extends PanelContainer

@export var title: String = "": ...
@export var subtitle: String = "": ...
@export var icon: String = "": ...
```
See **Editor-Authored Content** below for why these are exports, not setter methods called from a parent script.

**What:** Static, per-scene authoring content — labels, titles, subtitles, icons, and any other value that is fixed for the life of one scene instance — is exposed as an `@export` property on the component and set directly in the `.tscn` via the editor Inspector. It is not assigned imperatively from a parent scene's script (e.g. calling `_header.set_title(...)` from `composition_playground.gd`'s `_ready()`). Reserve code-driven setters for values that genuinely change at runtime — `StateCard.set_progress(t)`, `SelectorDock.select(index)` — where there's nothing for the editor to author because the value doesn't exist until the scene runs.

**Why:** A value like `ExampleHeader`'s title or icon never changes once the scene is built; hardcoding it in a parent script's `_ready()` hides that content from the editor and from anyone opening the `.tscn` — reading the script becomes the only way to see what an example scene actually says. Exporting it keeps the content visible and editable in the Inspector, matching how Godot scenes are meant to be authored.

**Pattern:**
```
# examples/shared/components/example_header.gd
@export var title: String = "":
    set(value):
        title = value
        if is_node_ready():
            _title.text = value
```
```
# examples/composition_playground.tscn — authored in the editor Inspector,
# not assigned in composition_playground.gd
[node name="Header" parent="..." instance=ExtResource("...")]
title = "Composition"
subtitle = "Combine simple animations into expressive flows."
icon = "✦"
```

**What:** The `positive-fill` theme colour (`design-brief.md` § Colour palette) is used only for large or bold display text (≥18pt, or ≥14pt bold) — never for body or caption text.

**Why:** White text on `positive-fill` measures 3.7:1 contrast — it passes WCAG AA's large-text threshold (3:1) but fails the normal-text threshold (4.5:1); using it for small text would ship an inaccessible pairing.

**Pattern:**
```
# OK: StateCard's single large letter
# Not OK: a caption, status pill, or body label using positive-fill as its background
```

## ❌ Not yet

- Editor plugin / Inspector integration folder conventions — no editor-facing surface exists yet; don't scaffold `addons/anima/motion/editor/` until one is planned.

---

<!-- Do not add a "Workflow", "How to use", or "Implementation guide" section. The rules in this file are the instructions; meta-guidance about applying them lives in AGENTS.md. -->
