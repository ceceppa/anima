# Project Rules

The team agrees to follow these architectural decisions, styling standards, and workflow patterns. This list can change as the project evolves. The coding agent must follow every rule that applies to the current story.

---

## Components

<!-- Define shared components here only when the current project genuinely needs them.

Possible uses:
- Repeated interactive elements that should stay visually and behaviorally consistent
- Reusable form controls with project-specific accessibility or validation requirements
- Cross-screen UI building blocks that would otherwise drift
- Project-wide reuse, accessibility, placement, or extraction conventions prompted by the design brief

Do not duplicate the design brief's shared-component inventory here. If `design-brief.md` already names a component and this section has no extra implementation rule to add, leave it in the design brief only.

For each shared component rule, describe:
- what it is
- when it must be used
- the accessibility, placement, reuse, naming, ownership, or extraction constraint the coding agent must follow

Do not define a particular component's exact props, events, variants, defaults, or state transitions here. `tech-spec.md` owns that consumer-visible contract when a phase depends on it. Reference the spec instead of copying it.
-->

---

## Patterns

<!-- Define coding patterns here only when they are useful for this project now.

Possible uses:
- State and data-fetching boundaries
- Token or theme management if the project needs centralized design values
- Error-handling or form-handling conventions
- Extraction thresholds for when UI should become shared
-->

---

## Architecture

<!-- Define architectural rules here when the stack or project shape requires them.

Possible uses:
- Routing or entrypoint boundaries imposed by the framework
- Native/web/client-server separation rules
- File placement rules for services, modules, or screen containers
-->

---

## Accessibility

<!-- Record the agreed accessibility baseline here when `mano rules` establishes implementation rules. `mano ui` records its visual accessibility target in `design-brief.md` and does not edit this file. Example:

Accessibility level: WCAG 2.1 AA

### Interaction basics
- All interactive elements meet the minimum touch-target size defined in `tech-spec.md` (mirrored by the named code constant). Reference the owner; do not restate the number here in a second unit — see "Shared Values: One Canonical Home" in `_mano/rules/artifact.md`.
- Visible focus indicators are required for all interactive elements.
- Text and UI labels must meet the selected contrast target.
-->

---

<!-- Do not add a "Workflow", "How to use", or "Implementation guide" section. The rules in this file are the instructions; meta-guidance about applying them lives in AGENTS.md. -->
