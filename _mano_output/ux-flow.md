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

## Motion Composer — Workspace

**How it's accessed:** Select an authored Anima motion in Godot’s Inspector and choose Open in Motion Composer. The Anima bottom panel opens with that motion as the current resource graph.

**How the user gets back:** Close the bottom panel or select a different motion resource in the Inspector to begin a new workspace session.

**What the user sees:**
- The current motion and its place in the opened resource graph.
- The selected motion’s editing view.
- The currently selected scene node, or a clear message that a node must be selected before targets can be resolved or previewed.

**What the user can do:**
- Select a motion in the opened graph, including its parent, to change what they are editing.
- Select a scene node in Godot to provide the current target and preview context.

**What happens on action:**
- Selecting a motion opens its editing view without creating another copy of the resource.
- Selecting a scene node makes it the context for resolving or previewing the current group; without one, the group remains editable but those actions explain what is missing.
- A compatible composite parent offers Add Group Motion. Choosing it creates and selects a new group; opening a standalone Group Motion selects it directly.

## Motion Composer — Group Setup

**How it's accessed:** Select a Group Motion in the Composer workspace, either an existing group or one just added to a compatible parent.

**How the user gets back:** Select another motion in the workspace or return to the parent motion.

**What the user sees:**
- The selected group’s target collection and shared item motion.
- Settings for playback, distribution, ordering, filters, completion, reverse order, and empty or invalid targets.
- Only settings that apply to the selected option.
- Inspect and Preview controls for this same group.

**What the user can do:**
- Configure one Group Motion.
- Open its inspection view or preview its current configuration.

**What happens on action:**
- Editing a setting updates the same Group Motion used by code authoring and supports normal editor undo and redo.
- Inspect opens the current group’s inspection view in the same workspace session.
- Preview uses the selected scene node and current settings. The author can stop it or play it in reverse, then continue editing; if the context is missing or invalid, the setup view explains why preview cannot start.

## Motion Composer — Group Inspection

**How it's accessed:** Choose Inspect from Group Setup.

**How the user gets back:** Return to Group Setup for the same selected group, or select another motion in the workspace.

**What the user sees:**
- The resolved target list in the collection’s current order.
- Each target’s generated start timing as a detail list, without a timeline or visible rank labels.
- Validation and compile eligibility, including a plain-language reason when compilation is blocked.

**What the user can do:**
- Refresh validation, then compile when the group is eligible.
- Return to Group Setup to change the current group.

**What happens on action:**
- Validation refreshes the displayed issues from the current resource and scene-node context.
- Compiling an eligible group produces its native Animation. A blocked group remains inspectable with its reason, so the author can return to setup and correct it.
