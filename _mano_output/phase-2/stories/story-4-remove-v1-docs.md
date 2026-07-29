### STORY-4: Remove stale v1 documentation

#### What and why
A developer browsing the docs site no longer finds any page describing a class, guide, or tutorial for the v1 addon that was deleted from the repository — every page they can reach describes only the current, working API.

#### Done when
- [ ] The v1-only class-reference pages under `docs/content/docs/anima/` — the pages describing `AnimaNode`, `AnimaTween`, the declaration grid, the declaration group, and `Constants` — no longer exist
- [ ] The v1-specific guides under `docs/content/docs/guides/`, tutorials under `docs/content/docs/tutorials/`, and features under `docs/content/docs/features/` no longer exist
- [ ] Searching the docs site content for any reference to a deleted v1 class or v1-only workflow returns nothing
- [ ] With story-1, story-2, and story-3's pages in place and this story's removals applied, the docs site builds without error

#### Not this story
- No new guides, tutorials, or features describing the v2 API — that's a separately deferred backlog item, not this phase.
- No changes to the class-reference pages this phase already replaces with new v2 content (the page at `docs/content/docs/anima/anima.md` is overwritten by story-2, not deleted here).

#### Notes
Depends on: story-1, story-2, story-3 (the docs-site build check needs all new pages in place, not just the removals, to verify the site as a whole).

This is the phase's integration story: its last acceptance criterion exercises the full Phase 2 outcome end to end, not just this story's own removals.

#### Implementation Reference
- **Build:** deletions only, plus one full-site build verification
- **Files:** the current contents of `docs/content/docs/anima/`, `docs/content/docs/guides/`, `docs/content/docs/tutorials/`, `docs/content/docs/features/` — read the directory to identify exactly which files describe v1-only content before deleting
- **Do not:** delete `docs/content/docs/anima/anima.md` — story-2 owns that file's content going forward
- **Do not:** delete section index pages (e.g. `_index.md` files) outright if they still serve as valid section landing pages for v2 content — update them if they reference v1 concepts, rather than removing the section entirely

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
