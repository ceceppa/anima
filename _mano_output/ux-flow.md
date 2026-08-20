# UX Flow — Anima

## Demo Selector

**How it's accessed:** Open the playground's entry scene in the Godot editor and run it — this is now the starting point for browsing the example playground.

**How the user gets back:** Stop the running scene or close it in the editor. There is no screen above this one.

**What the user sees:**
- The shared `ExampleHeader`.
- Two category tabs: 2D and 3D.
- Under the selected tab, a list of that category's demos: Composition, Group Motion, Convenience Motion, Grid Motion, and Animation Catalog under 2D; 3D Motion under 3D.
- A layout following the `v2_stuff/main-menu.jpeg` reference.

**What the user can do:**
- Choose the 2D or 3D tab.
- Choose a demo from the visible list to open it.

**What happens on action:**
- Choosing a tab shows only that category's demo list; the other category's demos are hidden, never removed.
- Choosing a demo opens that demo's existing scene, unchanged from how it behaves today.

## Composition Example Scene

**How it's accessed:** Choose Composition from the Demo Selector's 2D tab.

**How the user gets back:** Return to the Demo Selector, or stop the running scene/close it in the editor.

**What the user sees:**
- The shared `ExampleHeader` with the Composition title and subtitle.
- A fixed content stage with the selected composition’s name, description, and compact counter.
- A row of shared `Card` artwork cards. Each card displays a different Region from the `cards.jpg` atlas; the scene title and selector provide the meaning, so the images are decorative.
- The shared `SelectorDock` for Sequence, Parallel, Stagger, Repeat, Race, and Conditional.

**What the user can do:**
- Choose one composition type from the selector dock.

**What happens on action:**
- Choosing a type updates the stage title, description, counter, and artwork-card animation, then plays that composition from its starting state.
- The header and content-stage frame stay in place while only the selected composition content changes.

## Group Motion Example Scene

**How it's accessed:** Choose Group Motion from the Demo Selector's 2D tab.

**How the user gets back:** Return to the Demo Selector, or stop the running scene/close it in the editor.

**What the user sees:**
- The shared `ExampleHeader` with the Group Motion title and subtitle.
- A stage containing a single row or column of shared `Card` artwork cards, each showing a different Region from the shared atlas. The collection is never presented as a grid.
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

## Convenience Motion Example Scene

**How it's accessed:** Choose Convenience Motion from the Demo Selector's 2D tab.

**How the user gets back:** Return to the Demo Selector, or stop the running scene/close it in the editor.

**What the user sees:**
- The shared example header and one Card stage.
- A short, read-only `Anima.on()` example for the selected motion.
- A selector for the supported convenience-motion families and shared restart/reverse controls.

**What the user can do:**
- Choose a convenience-motion family.
- Restart the selected motion or play it in reverse.

**What happens on action:**
- Choosing a family changes the example line and replays the matching Card motion.
- Restart and reverse replay the same selected motion from its recorded state, demonstrating that convenience authoring uses normal playback behaviour.

## Grid Motion Example Scene

**How it's accessed:** Choose Grid Motion from the Demo Selector's 2D tab.

**How the user gets back:** Return to the Demo Selector, or stop the running scene/close it in the editor.

**What the user sees:**
- The shared example header and a 5×5 `GridContainer` of Cards.
- The currently selected propagation formula, Order From choice, and selected start Card.
- An Order From selector for Top, Bottom, Center, Together, Odd, Even, Random, and Index; Top is selected by default.
- A Formula control, shared restart/reverse controls, and no rank, timeline, speed, or reduced-motion UI.

**What the user can do:**
- Choose an Order From mode or choose the start Card by selecting any tile in the grid.
- Open the Formula Picker, then restart the selected motion or play it in reverse.

**What happens on action:**
- Tapping any Card makes that tile the persistent start point and immediately replays the currently selected grid propagation. It remains the start point for the selected animation and every later replay or configuration change until the user taps a different Card; it is not assumed to be the grid centre.
- Choosing an Order From mode changes the grid ordering and immediately replays it. Center is an explicit choice, not the default start point.
- Choosing a formula preserves the chosen Order From mode and start point whenever that mode uses a point, then replays the same grid with that propagation.
- Restart and reverse replay the resulting grid schedule; the demonstration never adds a separate playback model.

## Grid Formula Picker

**How it's accessed:** Choose Formula from the Grid Motion Example Scene.

**How the user gets back:** Choose a formula to return to the Grid Motion Example Scene, or close the picker to keep the current formula.

**What the user sees:**
- The available formula names: Euclidean, Manhattan, Chebyshev, Row, Column, Diagonal, Anti-diagonal, Clockwise, Anticlockwise, Spiral Inward, Spiral Outward, Serpentine Row, and Serpentine Column.
- A plain-language one-line explanation for the highlighted formula.

**What the user can do:**
- Select one formula.

**What happens on action:**
- Selecting a formula closes the picker and returns to the Grid Motion Example Scene, where the 5×5 grid immediately demonstrates it with the currently selected order and start point.

## 3D Motion Example Scene

**How it's accessed:** Choose 3D Motion from the Demo Selector's 3D tab.

**How the user gets back:** Return to the Demo Selector, or stop the running scene/close it in the editor.

**What the user sees:**
- The same shared example header and playback controls as the 2D Convenience Motion Example Scene.
- A single 3D Icosahedron Card in place of the 2D artwork Card, styled after the provided reference image with no text on it.
- A selector for the convenience-motion families that are valid for a 3D target, and a short read-only `Anima.on()` example for the selected one.

**What the user can do:**
- Choose a motion family.
- Restart the selected motion or play it in reverse.

**What happens on action:**
- Choosing a family changes the example line and replays the matching motion on the 3D card.
- Restart and reverse replay the same selected motion from its recorded state, the same way the 2D playground's controls do.

## Motion Composer — Workspace

**How it's accessed:** Either select an authored Anima motion resource in Godot's Inspector and choose Open in Motion Composer, or select any scene node that carries an Anima motion — an "Anima" Inspector section on the node itself offers the same Open in Motion Composer action, without first having to find and expand the motion resource field. Either path opens the Anima bottom panel with that motion as the current resource graph.

**How the user gets back:** Close the bottom panel or select a different motion resource in the Inspector to begin a new workspace session.

**What the user sees:**
- The current motion and its place in the opened resource graph.
- The selected motion’s editing view, in the form that matches what's actually selected: Group Setup for a Group Motion, Property Motion Editing for a Property Motion.
- The currently selected scene node, or a clear message that a node must be selected before targets can be resolved or previewed.
- If nothing has been opened yet, a message explaining what to do next (select a node with an Anima motion, or open one from the Inspector) instead of a blank panel.

**What the user can do:**
- Select a motion in the opened graph, including its parent, to change what they are editing.
- Select a scene node in Godot to provide the current target and preview context.

**What happens on action:**
- Selecting any motion in the graph — a Group Motion or a Property Motion — opens straight into that motion's own type-appropriate editing view. Switching between them is the same one action regardless of type; there is no separate mode toggle to find first and no blank state in between.
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
- When the selected motion isn't itself a group, a message naming what to do next: select a Group Motion elsewhere in the graph, or add one to the current selection if it can hold one.
- When the group has no target collection or item motion assigned yet, a message naming the concrete next step — assign a target collection and an item motion — instead of an empty graph with Inspect and Preview controls that have nothing to act on.

**What the user can do:**
- Configure one Group Motion.
- Open its inspection view or preview its current configuration.

**What happens on action:**
- Editing a setting updates the same Group Motion used by code authoring and supports normal editor undo and redo.
- Inspect opens the current group’s inspection view in the same workspace session.
- Preview uses the selected scene node and current settings. The author can stop it or play it in reverse, then continue editing; if the context is missing or invalid, the setup view explains why preview cannot start.

## Motion Composer — Property Motion Editing

**How it's accessed:** Select a Property Motion in the Composer workspace graph — a leaf motion that isn't a Group Motion.

**How the user gets back:** Select another motion in the workspace, or return to the parent motion.

**What the user sees:**
- The selected Property Motion's target property, easing (including the full restored curve library) and optional pivot choice, duration, and delay.
- Only settings that apply to the selected easing kind.
- When the selected motion isn't a Property Motion, a message naming what to do next: select a Property Motion elsewhere in the graph.

**What the user can do:**
- Configure the selected Property Motion's settings.
- Select a different motion in the graph to switch what's being edited.

**What happens on action:**
- Editing a setting updates the same AnimaPropertyMotion resource used by code authoring and supports normal editor undo and redo.
- Selecting a different motion in the graph switches directly into that motion's own editing view — Group Setup for a Group Motion, this view for another Property Motion — with no intermediate blank state.

## Motion Composer — Group Inspection

**How it's accessed:** Choose Inspect from Group Setup.

**How the user gets back:** Return to Group Setup for the same selected group, or select another motion in the workspace.

**What the user sees:**
- The resolved target list in the collection’s current order.
- Each target’s generated start timing as a detail list, without a timeline or visible rank labels.
- Validation and compile eligibility, including a plain-language reason when compilation is blocked.
- When the resolved target list is empty, a message naming the concrete next step — return to Group Setup and assign a target collection — instead of a blank list with no explanation.

**What the user can do:**
- Refresh validation, then compile when the group is eligible.
- Return to Group Setup to change the current group.

**What happens on action:**
- Validation refreshes the displayed issues from the current resource and scene-node context.
- Compiling an eligible group produces its native Animation. A blocked group remains inspectable with its reason, so the author can return to setup and correct it.

## Animation Catalog Playground

**How it's accessed:** Choose Animation Catalog from the Demo Selector's 2D tab.

**How the user gets back:** Return to the Demo Selector, or stop the running scene/close it in the editor.

**What the user sees:**
- The shared example header, and a category sidebar listing all 16 categories, mirroring Anima v1's own source folders (Attention Seeker, Back Entrances, Back Exits, Bouncing Entrances, Bouncing Exits, Fading Entrances, Fading Exits, Lightspeed, Rotating Entrances, Rotating Exits, Slide Exits, Sliding Entrances, Specials, Text, Zooming Entrances, Zooming Exits) — one is always selected, Attention Seeker by default on first open.
- A target-mode control (`Both` / `Control` / `Sprite2D`) at the top of the stage — `Both` selected by default.
- A live preview stage below it: with `Both` selected, a split view — a plain "anima" label on the left (the target every preset except `lightspeed` plays on), the sprite placeholder on the right (the target `lightspeed` presets play on). No separate title text — the grid's own selected button already names the current preset.
- A grid of buttons below the stage, one per preset in the selected category — one is always selected, the first in the category by default when the category changes.
- The shared playback controls (restart, reverse, complete, revert, speed, reduced-motion) — unchanged from every other playground, acting on whatever preset is currently playing.

**What the user can do:**
- Choose a different category from the sidebar.
- Choose a different preset from the grid.
- Choose a different target-mode (`Both` / `Control` / `Sprite2D`).
- Use the shared playback controls on the currently playing preset.

**What happens on action:**
- Choosing a category updates the grid to that category's presets and immediately plays the first one on its target — the previous category's selection is not remembered when switching back to it later.
- Choosing a preset from the grid immediately replays that exact preset, on whichever target it's compatible with, from its start; no confirmation step, since nothing here is destructive.
- Choosing `Control` shows only the label, full width; choosing `Sprite2D` shows only the sprite, full width; choosing `Both` shows the split view again. This only changes which target(s) are visible — it never changes which target the current preset actually animates on, so picking a mode that hides the animating target just shows nothing moving until `Both` (or the matching mode) is chosen again.
- Every category and every preset within it is always available — nothing in this playground is ever locked or requires unlocking; the only exclusion is that a preset from one category is never shown while a different category is selected.
- The playback controls behave exactly as they already do on every other playground scene; this phase adds no new control.

## Editor Tooling Showcase Scene

**How it's accessed:** Open `examples/editor/motion_composer_showcase.tscn` in the Godot editor. This scene is opened and explored in the editor, not run.

**How the user gets back:** Select a different node in the Scene panel, or close the scene tab. The scene has no in-app navigation of its own.

**What the user sees:**
- A Scene panel with four labelled nodes, one per editor panel this showcase demonstrates: a node carrying an authored Group Motion, a node carrying an authored Property Motion, a node carrying a compiled/resolved group ready for inspection, and a node with no motion assigned yet.
- Selecting any of the four opens the same "Anima" Inspector section and Motion Composer a real project uses, showing that node's matching state.

**What the user can do:**
- Select any of the four nodes to see its matching Motion Composer state live: Group Setup, Property Motion Editing, Group Inspection, or the top-level empty-state entry point.

**What happens on action:**
- Selecting a node opens the real Motion Composer workspace, not a showcase-only mock — what the developer sees here is exactly what they'll get once they wire up their own motions.
