### STORY-4: Sequence composition

#### What and why
A Godot developer wants to say "run this, then that" without computing absolute start times by hand. This story lets them compose property motions into a Sequence and play the whole thing as one unit.

#### Done when
- [ ] Playing a Sequence of two property motions runs the first to completion before the second's property begins changing.
- [ ] Playing a Sequence of three property motions completes — and reports success — only once the last one finishes.
- [ ] Pausing a running Sequence freezes whichever child is currently active; resuming continues that child from where it paused.
- [ ] Test: a unit test plays a Sequence of property motions across simulated frames and asserts the ordering and completion behaviour above.

#### Not this story
- No Parallel composition — separate story.
- No overlap, start-offset, or other relationship-timing modifiers between children — deferred; children always run strictly one after another.
- No nested Sequence-inside-Parallel integration test — that's story-6.

#### Notes
Depends on: story-0, story-3.

#### Implementation Reference
- **Build:** `AnimaSequence`, extends `AnimaMotion`
- **Data:** `tech-spec.md` §Data model (`AnimaSequence` row)
- **Rules:** `project-rules.md` §Patterns — implement the full base contract explicitly
- **Test:** `project-rules.md` §Testing

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
