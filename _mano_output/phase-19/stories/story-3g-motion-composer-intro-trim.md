### story-3g: Trim the Motion Composer guide's opening description

#### What and why
The Motion Composer guide's opening paragraph — describing it as "a bottom-panel dock" — isn't wanted. This story removes it.

#### Done when
- [ ] The Motion Composer guide's "What it does" section no longer contains the paragraph beginning "The Motion Composer is a bottom-panel dock...".
- [ ] The section still reads naturally without that paragraph — no dangling reference to it from the surrounding text.

#### Not this story
- No other change to the Motion Composer guide's content, screenshots, or structure.

#### Implementation Reference
- **Files:** `docs/content/docs/guides/motion-composer/index.md` — remove the paragraph under `## What it does` beginning "The Motion Composer is a bottom-panel dock, labelled **Anima**, that lets you open any `AnimaMotion` resource and edit it...". Check whether the section's opening line ("It has three views, and you move between them as you work:") still reads naturally as the section's first sentence once the removed paragraph is gone; adjust only if it doesn't.
- **Do not:** don't remove or alter the three-views list, the rest of the guide, or any of its screenshot placeholders.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
