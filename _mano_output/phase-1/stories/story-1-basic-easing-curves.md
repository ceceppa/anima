### STORY-1: Basic easing curves

#### What and why
A Godot developer composing a motion picks how it feels, not just how long it takes. This story gives them a small set of real easing curves — linear, polynomial, sine, exponential, circular — so a motion's rate of change can be shaped instead of always moving at a constant speed.

#### Done when
- [ ] An easing curve can be constructed as any of the five supported kinds: linear, polynomial, sine, exponential, circular.
- [ ] Evaluating a non-linear curve at the midpoint of its range produces a value different from the midpoint value a linear curve produces.
- [ ] Evaluating any curve at the very start and very end of its range produces the range's start and end values.
- [ ] Test: a unit test evaluates each supported curve kind at several points between its start and end and confirms the non-linear kinds do not change at a constant rate.

#### Not this story
- No spring, decay, cubic Bézier, curve resource, callable evaluator, or custom sampled curve easing — deferred (see phase brief "Not This Phase").
- No Easing Studio editor panel or curve preview UI.

#### Notes
A Property motion built without an explicit easing curve defaults to this story's linear kind — verified in story-2.

#### Implementation Reference
- **Build:** `AnimaEase` resource, basic curve set
- **Data:** `tech-spec.md` §Data model (`AnimaEase` row) — supported kinds and default `exponent`
- **Rules:** `project-rules.md` §Naming
- **Test:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
