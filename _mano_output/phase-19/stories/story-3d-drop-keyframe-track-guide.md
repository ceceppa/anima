### story-3d: Drop the AnimaKeyframeTrack guide, rename AnimaKeyframeMotion to Keyframes

#### What and why
Two of the six runtime Guides overlapped closely enough (one page's per-stop field detail duplicated territory the generated reference already owns) that a separate `AnimaKeyframeTrack` guide isn't earning its place. This story removes it and renames the remaining keyframe guide from the class name `AnimaKeyframeMotion` to the more general "Keyframes", since it's the one guide covering the whole concept now.

#### Done when
- [ ] The Guides section no longer has an `AnimaKeyframeTrack` page.
- [ ] The guide previously titled "AnimaKeyframeMotion" is now titled "Keyframes".
- [ ] Every page that linked to the removed `AnimaKeyframeTrack` guide or the old "AnimaKeyframeMotion" guide now links to the renamed "Keyframes" guide instead, and no page links to a page that no longer exists.

#### Not this story
- No change to the guide's actual explanation of keyframe authoring — only its title, filename, and other pages' links to it.
- No change to the generated `AnimaKeyframeTrack`/`AnimaKeyframeStop`/`AnimaKeyframeMotion` reference pages under Anima Addon — those stay exactly as generated.

#### Implementation Reference
- **Files:** delete `docs/content/docs/guides/keyframe-track.md`. Rename `docs/content/docs/guides/keyframe-motion.md` to `docs/content/docs/guides/keyframes.md`; change its front matter `title` from `"AnimaKeyframeMotion"` to `"Keyframes"`.
- **Cross-link fixups** (every link pointing at the removed or renamed page, per this phase's own content): `docs/content/docs/guides/dynamic-values.md` (two links — one to the removed Track guide, one to the renamed Motion guide), `docs/content/docs/features/built-in-animations.md` (one link), `docs/content/docs/tutorials/02-popup-animation/index.md` (one link plus its surrounding prose, which still names "AnimaKeyframeMotion").
- **Reference pointers:** now that there's no dedicated Track guide, add a line in the renamed Keyframes guide cross-linking the generated `AnimaKeyframeTrack`/`AnimaKeyframeStop` reference pages (it already links `AnimaKeyframeMotion`'s own generated page) — `project-rules.md` §Documentation's "cross-link instead of restating" convention.
- **Rules:** placement/front-matter convention — `project-rules.md` §Documentation.
- **Do not:** don't change any other guide; don't touch the generated `docs/content/docs/anima/` pages.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
