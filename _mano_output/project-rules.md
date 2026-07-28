# Project Rules

The team agrees to follow these architectural decisions, styling standards, and workflow patterns. This list can be extended or modified as required down the line. The coding agent must follow these rules without exception on every single story.

---

## Folder Structure

**What:** New Phase 1 code lives under `addons/anima/motion/` — a new subfolder, sibling to the legacy `core/`, `utils/`, and `animations/` folders, never inside them. Split into `motion/resources/` (`AnimaMotion` and every subtype) and `motion/runtime/` (`AnimaRuntime`, the scheduler, the evaluation loop).

**Why:** New code and legacy code stay in separate folders so it's always clear which system a file belongs to. This holds even though the legacy `Anima` entry point itself was renamed to `AnimaV1` — that's a content edit to an existing legacy file, not new files added into a legacy folder (see `tech-spec.md` §Key technical decisions).

**Pattern:**
```
addons/anima/
  core/          # legacy, untouched
  utils/         # legacy, untouched
  animations/    # legacy, untouched
  motion/        # new — Phase 1 and onward
    resources/
      anima_motion.gd
      anima_sequence.gd
    runtime/
      anima_runtime.gd
```

## Naming

**What:** Every new GDScript type is declared with `class_name` in PascalCase, prefixed `Anima` (`AnimaMotion`, `AnimaSequence`, `AnimaPropertyMotion`, …). The file name mirrors the class name in snake_case.

**Why:** Matches Godot's own global-class convention and keeps every new type discoverable by name; a mismatched file/class name is a common source of GDScript's duplicate-class-name errors.

**Pattern:**
```
# addons/anima/motion/resources/anima_sequence.gd
class_name AnimaSequence
extends AnimaMotion
```

## Architecture

**What:** The public entry point (`Anima.play(...)`) is exposed through a `class_name`-declared script, never through a `project.godot` autoload. Do not add, rename, or remove anything under `[autoload]` while implementing this phase.

**Why:** The tech spec requires zero mandatory setup, and the project already has one autoload registered for the legacy addon (`ANIMA`) — adding a second global identifier through `project.godot` risks colliding with it.

**Pattern:**
```
# addons/anima/motion/runtime/anima.gd
class_name Anima
extends RefCounted

static func play(motion: AnimaMotion, target: Node) -> AnimaPlayback:
    ...
```

**What:** New Phase 1 code must not import, extend, or otherwise reference anything under `addons/anima/core`, `addons/anima/utils`, or `addons/anima/animations` (the legacy implementation).

**Why:** Keeps the legacy addon independently removable and prevents the new runtime from silently depending on legacy internals that a later, separate compatibility layer (`AnimaLegacy`) is meant to isolate. This governs new code depending on legacy internals — it does not block the one sanctioned exception, the `Anima` → `AnimaV1` rename (`tech-spec.md` §Key technical decisions), which edits existing legacy files directly rather than adding a new dependency on them.

**Pattern:**
```
# Not allowed in Phase 1 code:
# extends "res://addons/anima/core/some_legacy_class.gd"
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

**What:** Every new piece of code ships with a test — no exceptions. Tests use GUT ([bitwes/Gut](https://github.com/bitwes/Gut)), already installed at `addons/gut`, and live flat in `tests/`. A unit test is named `<ClassName>.test.gd` for the type it covers. An integration test — exercising behaviour across multiple classes through the public `Anima.<...>` entry point — is named `Anima.integration.<name>.test.gd`. A story that introduces one type needs at least the unit test; a story that composes multiple types together through `Anima.play()` (or another `Anima.<...>` entry point) also needs an integration test.

**Why:** GUT is already the project's test runner. Unit tests are named after the class they cover; integration tests are named after the entry point they exercise (`Anima`) rather than an arbitrary label, since every integration test drives the system the same way a real caller does — through `Anima.<something>`. This also matches the existing legacy convention already in `tests/` (`Anima.integration.animations.test.gd`, `Anima.integration.backwards.test.gd`).

**Pattern:**
```
tests/AnimaSequence.test.gd
tests/AnimaParallel.test.gd
tests/Anima.integration.playback.test.gd
```

---

## ❌ Not yet

- Editor plugin / Inspector integration folder conventions — no editor-facing surface exists this phase; don't scaffold `addons/anima/motion/editor/` yet.

---

<!-- Do not add a "Workflow", "How to use", or "Implementation guide" section. The rules in this file are the instructions; meta-guidance about applying them lives in AGENTS.md. -->
