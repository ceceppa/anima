### story-2: Core runtime concept guides

#### What and why
A developer new to Anima has no conceptual walkthrough for its core runtime mechanisms — only source code and the generated member-by-member reference. This story adds six guides, each explaining one mechanism in plain language with a runnable example, so a newcomer can learn *how* and *why* before reaching for the generated reference to look up exact members.

#### Done when
- [ ] The Guides section contains six new pages, each with at least one runnable `gdscript` code block:
  - Reusable vs. Single-Shot — explains that a saved `AnimaMotion` resource can be played many times, and how to get independent per-play state when needed.
  - Multiple animations — explains combining animations with `.then()`/`.with()`.
  - Animate relative values — explains animating a value relative to wherever a target currently is, instead of to a fixed destination.
  - Dynamic Value — explains `AnimaValue`, reading a live property instead of a fixed literal.
  - AnimaKeyframeMotion — explains authoring a multi-stop animation across one duration.
  - AnimaKeyframeTrack — explains what one property's stop sequence inside a keyframe motion is and how it's structured.
- [ ] Each of the six pages links to its matching generated reference page under the Anima Addon section instead of restating that page's member list.

#### Not this story
- No change to the `motion-composer` editor-tool guide.
- No Feature or Tutorial pages — those are story-1 and story-3.
- No new runtime API, behaviour, or field — every guide documents an already-shipped mechanism.

#### Implementation Reference
- **Build:** `docs/content/docs/guides/reusable-vs-single-shot.md`, `multiple-animations.md`, `animating-relative-values.md`, `dynamic-values.md`, `keyframe-motion.md`, `keyframe-track.md` — plain `.md` pages, sibling to `docs/content/docs/guides/motion-composer/` — `tech-spec.md` §Documentation site structure (phase-19), `project-rules.md` §Documentation.
- **Data — Reusable vs. Single-Shot:** `Anima.animation(name)` caches and returns the identical shared resource on every call; a caller needing independent per-use state duplicates it (`Resource.duplicate()`) before overriding anything on the copy — `tech-spec.md` §Animation catalog ("`Anima` lazily loads and caches...").
- **Data — Multiple animations:** `.then(other)`/`.with(other)` chain composition — `tech-spec.md` §Convenience method interface and the `Anima.on()` example already in `docs/content/docs/anima/_index.md`'s "Getting started" section. Go beyond that existing example (e.g. `.wait()`, delay stacking, more than two combined motions) rather than repeating it verbatim — `tech-spec.md` §Key technical decisions (`.wait()`).
- **Data — Animate relative values:** `move_by()`/`scale_by()`/`rotate_by()`, `.relative()`, `AnimaPropertyMotion.is_relative` — `tech-spec.md` §Convenience method interface.
- **Data — Dynamic Value:** `AnimaValue` sources (`.target()`, `.node()`, `.root()`, `.context()`, group/grid position sources), arithmetic composition, `.length()` — `tech-spec.md` §Dynamic values and §Dynamic value interface.
- **Data — AnimaKeyframeMotion / AnimaKeyframeTrack:** authoring via `Motion.keyframes()`/`.at()`, tracks, stops, offsets, easing, pivot, duration (including the dynamic-duration form) — `tech-spec.md` §Keyframe motions and §Keyframe interface.
- **Rules:** runnable-example requirement — `project-rules.md` §Documentation.
- **Do not:** don't restate a generated reference page's full member list; don't introduce or imply any mechanism not already defined in `tech-spec.md`.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
