# UX Flow — Anima

## Composition Example Scene

**How it's accessed:** Open `examples/composition_playground.tscn` in the Godot editor and run the scene.

**How the user gets back:** Stop the running scene or close it in the editor. The scene has no in-app navigation.

**What the user sees:**
- The shared `ExampleHeader` with the Composition title and subtitle.
- A fixed content stage with the selected composition’s name, description, and compact counter.
- A row of shared `StateCard` artwork cards. Each card displays a different Region from the `cards.jpg` atlas; the scene title and selector provide the meaning, so the images are decorative.
- The shared `SelectorDock` for Sequence, Parallel, Stagger, Repeat, Race, and Conditional.

**What the user can do:**
- Choose one composition type from the selector dock.

**What happens on action:**
- Choosing a type updates the stage title, description, counter, and artwork-card animation, then plays that composition from its starting state.
- The header and content-stage frame stay in place while only the selected composition content changes.

## Group Motion Example Scene

**How it's accessed:** Open `examples/group_motion_playground.tscn` in the Godot editor and run the scene.

**How the user gets back:** Stop the running scene or close it in the editor. The scene has no in-app navigation.

**What the user sees:**
- The shared `ExampleHeader` with the Group Motion title and subtitle.
- A stage containing a single row or column of shared `StateCard` artwork cards, each showing a different Region from the shared atlas. The collection is never presented as a grid.
- One selector for Sequential, Parallel, and Stagger playback.
- One selector for First, Last, Center, Odd, Even, Random, and Index ordering.
- The shared playback controls for restarting the selected motion and playing its reverse.

**What the user can do:**
- Choose a playback mode.
- Choose an ordering mode.
- Restart the selected group motion or play it in reverse.

**What happens on action:**
- Choosing playback or ordering restarts the card animation from its starting state with the selected combination.
- Restart plays the selected combination forward again.
- Reverse plays the same resolved card collection backward.

## Motion Composer — Group Setup

**How it's accessed:** In the Motion Composer, add a Group Motion or select an existing Group Motion from the current motion.

**How the user gets back:** Select another motion in the Composer or return to the parent motion.

**What the user sees:**
- The selected group’s target collection and shared item motion.
- Group settings for playback, distribution, ordering, filters, completion, reverse order, and empty or invalid targets.
- Only the settings that apply to the selected option.
- An Inspect action for the resolved collection and a preview action for the authored group.

**What the user can do:**
- Configure one Group Motion.
- Open its inspection view or preview the configuration.

**What happens on action:**
- Editing a setting updates the same Group Motion used by code authoring.
- Opening inspection shows the current group’s resolved targets and validation state.
- Preview plays the current configuration; the author can stop it or play it in reverse, then continue editing.

## Motion Composer — Group Inspection

**How it's accessed:** Choose Inspect from Group Setup.

**How the user gets back:** Return to Group Setup.

**What the user sees:**
- The resolved target list in the collection’s current order.
- The group’s generated start timing as per-target details, without a timeline view.
- Validation and compile eligibility, with a plain-language reason when compilation is blocked.

**What the user can do:**
- Validate the group or compile an eligible group.
- Return to Group Setup to change the configuration.

**What happens on action:**
- Validation refreshes the displayed issues for the current configuration.
- Compiling an eligible group produces its native Animation; blocked groups remain in the inspection view with the reason shown.
