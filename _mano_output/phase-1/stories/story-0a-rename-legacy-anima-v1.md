### STORY-0a: Rename legacy Anima to AnimaV1

#### What and why
A Godot developer already using Anima 1.x needs their existing `Anima.begin(...)` calls to keep working after upgrading — just renamed to `AnimaV1.begin(...)` — because the new Phase 1 runtime needs the bare `Anima` name for its own entry point, and Godot doesn't allow two global classes with the same name. This story does the rename and confirms the existing v1 test suite and demos still run under the new name before anything new claims `Anima`.

#### Done when
- [ ] The legacy addon's public class is named `AnimaV1` instead of `Anima`; nothing under `addons/anima/` declares a global class named `Anima` anymore.
- [ ] Every existing call site — inside the addon itself, its tests, and the demo scenes — that used to reference the legacy class as `Anima` now references `AnimaV1`; none still reference a bare `Anima`.
- [ ] Test: the existing legacy unit and integration tests, updated to call `AnimaV1` instead of `Anima`, still pass with the same results as before the rename.

#### Not this story
- No new v2 entry point yet — that's story-3 (Runtime playback core), unblocked once this lands.
- No change to legacy behaviour, API shape, or file locations — only the global class name changes, everywhere it appears.
- No migration tooling or dictionary-compatibility shim — separate, later, deferred backlog items. In particular, the new name is not `AnimaLegacy`: that name is reserved by the deferred `AnimaLegacy.from_dictionary()` compatibility shim, a different, not-yet-built class.

#### Notes
This is an accepted breaking change for any external project calling `Anima.begin(...)` directly against the installed addon — they must switch to `AnimaV1.begin(...)` on upgrade. Internally, it is a repo-wide rename, not a single-line edit — see `tech-spec.md` §Key technical decisions and its ⚠️ Note for the exact file list found by the last scan (1 addon file, 4 legacy GUT tests, 13 demo scripts/scenes); confirm against a fresh search rather than trusting that count as final.

Blocks story-3: the new `class_name Anima` entry point cannot be declared until this rename lands.

#### Implementation Reference
- **Build:** rename `class_name Anima` → `class_name AnimaV1` in `addons/anima/core/anima.gd`; update every internal reference to the bare `Anima` identifier to match
- **Files:** `tech-spec.md` §Key technical decisions — the file list this touches
- **Rules:** `project-rules.md` §Folder Structure, §Architecture — this is the one sanctioned exception to "legacy stays untouched" / "no new-code dependency on legacy internals"; it edits existing legacy files directly, it does not add a new dependency on them
- **Do not:** rename anything else in the legacy addon (file paths, other class names, method names) — only the `Anima` global identifier changes

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
