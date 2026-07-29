# UX Flow — Anima

## Composition Example Scene

**How it's accessed:** Opened directly in the Godot editor (`examples/composition_playground.tscn`) and run with Play Scene — there's no in-app navigation leading to it yet.

**How the user gets back:** Stop the running scene, or close it in the editor. There's nowhere else to go from here yet, so there's no in-scene "back" action.

**What the user sees:**
- A themed scene (the custom `Theme` from `project-rules.md` §Example Scenes, not default Godot control styling)
- A selector for which of this phase's composition types to preview: Sequence, Parallel, Stagger, Repeat, Race, Conditional
- A state-card area (the shared `StateCard` component) showing each node involved in the current composition and its state — waiting, playing, or completed
- A duration readout showing the current composition's reported kind and value (`Fixed`/`Estimated`/`Dynamic`/`Infinite` — the `AnimaDuration` concept from `tech-spec.md`)

**What the user can do:**
- Select a different composition type from the selector
- Restart the current composition's playback (the shared `PlaybackControls` component, restart action only this phase)

**What happens on action:**
- Selecting a composition type builds that composition using the Functional builder API and plays it immediately against the scene's demo nodes; the state cards update live as it plays
- Restarting cancels the current playback and starts the same composition fresh from the beginning

## Not this scene yet

- No scrubbing/seeking, speed control, reduced-motion toggle, or easing-curve/direction picker — those belong to the fuller playground vision (`v2_stuff/ex1.jpg`), which a later phase covers once the underlying seeking, speed, and reduced-motion features actually exist.
- Relationship timing modifiers (overlap, start-offset) aren't a separate interactive control — they show up as part of how the Sequence example is composed, not as their own toggle.
- No navigation to or from other example scenes — this phase ships exactly one; the multi-scene "playground" is future scope.
