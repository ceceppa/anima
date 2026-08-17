### story-3i: Split into three exhaustive Anima.on/group/grid guides

#### What and why
The combined `on-group-grid.md` guide gave each of `Anima.on()`, `Anima.group()`, and `Anima.grid()` one teaser example — enough to show they exist, not enough to actually use one instead of reading source. Since the whole point of these three factories is hiding real complexity (target resolution, item motions, distance-formula scheduling) behind a short call, their guides need to show everything reachable through that short call, not just a taste of it. This story splits the combined page into three, each exhaustive of its own factory's surface.

#### Done when
- [ ] The Guides section no longer has a single combined `Anima.on/group/grid` page.
- [ ] There is a page dedicated to `Anima.on()` that demonstrates every semantic method it exposes (position, move-by, scale, scale-by, rotation, rotate-by, opacity, color, size, property, property-by, keyframes) and every modifier available on the motion it returns (from/from-current, with-duration, with-ease, with-delay, relative, with-pivot), each with its own runnable example or grouped where multiple methods share an identical shape.
- [ ] There is a page dedicated to `Anima.group()` that demonstrates: both accepted target forms (a container node, an explicit array), every chain method it exposes (with-item-motion, keyframes, with-duration, with-ease, with-pivot, with-delay, on-started, on-completed, wait, then, with, motion, play), and links to the `AnimaGroupMotion` resource fields the factory is convenience sugar over.
- [ ] There is a page dedicated to `Anima.grid()` that demonstrates: the container/grid-size setup, every one of the 13 distance-formula preset methods (named, not just one example), the manual configuration methods (with-distance-formula, with-dimensions, with-start-point, with-stagger-interval), and the same shared chain methods `Anima.group()`'s page covers, and links to the `AnimaGridMotion` resource fields the factory is convenience sugar over.

#### Not this story
- No change to any other guide.
- No new runtime behaviour — every method shown must already exist per `tech-spec.md`; this story documents, it doesn't add.
- No exhaustive re-documentation of `AnimaPlayback` (what `.play()` returns) — link to its generated reference instead of restating its own methods.

#### Implementation Reference
- **Files:** delete `docs/content/docs/guides/on-group-grid.md`. Add `docs/content/docs/guides/anima-on.md`, `docs/content/docs/guides/anima-group.md`, `docs/content/docs/guides/anima-grid.md` — plain `.md` pages, same convention as every other guide (`project-rules.md` §Documentation, `tech-spec.md` §Documentation site structure).
- **Cross-link fixups:** any page linking to the removed `on-group-grid` guide now links to whichever of the three new pages is most relevant to that context.
- **`Anima.on()` full surface:** `tech-spec.md` §Convenience method interface, the `AnimaOnMotionFactory`/`AnimaItemMotionFactory` rows and the "Modifiers on the returned `AnimaPropertyMotion`" rows, plus the base `AnimaMotion` chain rows (`.then()`, `.with()`, `.play()`, `.on_started()`/`.on_completed()`, `.repeat()`, `.with_speed()`, `.wait()`) — every method in those rows is in scope.
- **`Anima.group()` full surface:** `tech-spec.md` §Group convenience shorthand and its interface table (`.with_item_motion()`, `.keyframes()`, `.with_duration()`/`.with_ease()`/`.with_pivot()`, `.with_delay()`, `.on_started()`/`.on_completed()`, `.wait()`, `.then()`/`.with()`, `.motion`, `.play()`). Resource-level fields to link, not restate: `AnimaGroupMotion`'s field list — `tech-spec.md` §Data model.
- **`Anima.grid()` full surface:** `tech-spec.md` §Grid convenience shorthand and its interface table — all 13 named distance-formula presets (`.radial()`, `.diamond()`, `.box()`, `.by_row()`, `.by_column()`, `.diagonal()`, `.anti_diagonal()`, `.clockwise()`, `.counter_clockwise()`, `.spiral_in()`, `.spiral_out()`, `.serpentine_row()`, `.serpentine_column()`), `.with_distance_formula()`, `.with_dimensions()`, `.with_start_point()`, `.with_stagger_interval()`, plus the same shared chain methods `Anima.group()`'s page covers. Resource-level fields to link, not restate: `AnimaGridMotion`'s field list — `tech-spec.md` §Data model.
- **Rules:** runnable-example and `.play()`-convenience-form conventions — `project-rules.md` §Documentation, `tech-spec.md` §Documentation site structure ("Runnable-example convention"). Cross-link instead of restating the generated reference's member list — same convention every other guide already follows.
- **Do not:** don't invent a method not named in `tech-spec.md`; don't fully re-document `AnimaPlayback`, `AnimaGroupMotion`, or `AnimaGridMotion` — link to their generated reference pages for exact fields.

---
<!-- ⚠️ When this story is implemented, mark it done via `stories.js set-status` (AGENTS.md step 11) — don't hand-edit the index. -->
