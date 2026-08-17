### story-1a: Category taxonomy rework

#### What and why
Story-1 shipped the catalog under a collapsed 5-category scheme (Attention/Entrance/Exit/Special/Text), which put 44 unrelated presets under one "Entrance" folder — hard to browse. This story reworks the taxonomy to mirror Anima v1's own 16 source folders exactly, so each category stays a small, single-style group.

#### Done when
- [ ] The catalog's 99 presets live under 16 category folders mirroring Anima v1's own source folders exactly: `attention_seeker`, `back_entrances`, `back_exits`, `bouncing_entrances`, `bouncing_exits`, `fading_entrances`, `fading_exits`, `lightspeed`, `rotating_entrances`, `rotating_exits`, `slide_exits`, `sliding_entrances`, `specials`, `text`, `zooming_entrances`, `zooming_exits`.
- [ ] `Anima.animation(name)` and loading each preset's `.tres` directly still return the identical resource, for a preset from every one of the 16 categories.
- [ ] The playground scene (story-1) shows all 16 categories in its sidebar, and browsing every category still reaches all 99 presets with none missing.

#### Not this story
- No change to preset behaviour, values, or targets — this is a file/folder reorganisation and its downstream references only.

#### Implementation Reference
- **Files:** category folder layout and naming — `project-rules.md` §Animation Catalog. `tech-spec.md` §Animation catalog ("Category taxonomy") owns the authoritative 16-category list and the reasoning for the rework.
- **Build:** the registry (`addons/anima/motion/runtime/anima_animation_registry.gd`) name→path map updated to the new folder paths; the playground's own category-scanning helper needs no change (it already scans folder names generically).
- **Rules:** no new rule category — `project-rules.md` §Animation Catalog's existing folder-placement rule already describes "one folder per category"; only the concrete list of category names changed.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
