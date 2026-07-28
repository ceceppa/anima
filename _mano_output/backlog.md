# Backlog

<!-- Future work, deferred items, and ideas. -->
<!-- `mano start` owns backlog curation during scoping. `mano review` appends or resolves items during review. -->
<!-- You can edit this file directly at any time. -->

## Core Product Principles

- Relationships before timestamps: users describe "after this," "with this," "wait for this signal" — Anima calculates absolute schedules; the user never repairs timestamps by hand.
- Composition over inheritance: Anima attaches to ordinary Godot nodes. Users should never need AnimatedButton, AnimatedPanel, AnimatedContainer, or AnimatedLabel subclasses.
- Static motion compiles, dynamic motion stays dynamic: anything reducible to a native Animation should compile to one; anything needing runtime state (springs, retargeting, signal waits, layout, shared elements) stays Anima-native.
- One data model, multiple authoring surfaces: code, the Inspector, and the Motion Composer must all produce the same AnimaMotion resource — no separate visual-only format.
- Graceful degradation: unsupported integrations fail safely; optional editor conveniences are never required for runtime correctness.
- Motion should stay comprehensible: the editor should always be able to show execution order, parallel groups, derived duration, and the critical path — never just a black-box result.

## Items

### AnimaMotion base resource
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Base Resource class shared by every motion type (composite and leaf): display_name, enabled, delay, speed, tags, metadata, plus estimate_duration/create_runtime/validate methods.
  Every composite and leaf motion type extends this.
  Full schema: PRD.md §10.1.
- **Status:** in-phase-1

### Sequence composition (AnimaSequence)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Runs child motions one after another; completes when the final enabled child completes.
  The core building block for "after this" relationships (G1).
  PRD.md §10.2.
- **Status:** in-phase-1

### Parallel composition (AnimaParallel)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Starts all children together; a completion policy (all children / first child / a named child) decides when the group finishes.
  For "all children", duration is the longest child's duration.
  PRD.md §10.2.
- **Status:** in-phase-1

### Stagger composition (AnimaStagger)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Repeats a template motion across a target selector with an interval and an order (forward, reverse, from-center, from-edges, random, custom).
  Used for effects like buttons appearing one after another.
  PRD.md §10.2.
- **Status:** backlog

### Repeat composition (AnimaRepeat)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Repeats a child motion a given count, with an optional delay between repeats and an alternate (ping-pong) mode.
  PRD.md §10.2.
- **Status:** backlog

### Race composition (AnimaRace)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Runs children concurrently and completes on the first completion, optionally cancelling the remaining children.
  PRD.md §10.2.
- **Status:** backlog

### Conditional branch (AnimaConditional)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Selects between a when_true and when_false child motion at runtime based on a condition.
  Runtime-only unless the condition can be resolved at compile time.
  PRD.md §10.2.
- **Status:** backlog

### Property motion leaf type
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Property motion leaf: animates one property from/to a value.
  The only leaf type in Phase 1 — enough to make Sequence/Parallel structure produce visible motion.
  Full schema: PRD.md §10.3.
- **Status:** in-phase-1

### Relationship timing modifiers
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Start offset, "overlap previous" (start before the previous child completes), "start after previous begins", and configurable completion thresholds (exact end / spring settled / visually settled / named marker / signal / custom callback).
  PRD.md §10.4.
- **Status:** backlog

### Duration model (Fixed/Estimated/Dynamic/Infinite)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Motions report a duration kind, not just a number: Fixed, Estimated, Dynamic, or Infinite.
  The editor must visually distinguish these (solid bar / striped-or-faded / dashed open-ended / continuation arrow).
  PRD.md §11.
- **Status:** backlog

### Functional builder API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Fluent, chainable GDScript builder (Motion.sequence/parallel/stagger/... with .duration()/.ease() chaining) designed for autocomplete and readability when nested.
  Primary code-first authoring surface.
  PRD.md §12.2.
- **Status:** backlog

### Explicit resource API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Motions can be constructed directly as typed Resource objects (e.g. AnimaSequence.new(), assigning a `children` array) without the builder.
  PRD.md §12.3.
- **Status:** in-phase-1

### Runtime playback API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Anima.play(motion, node) returns a playback object with an awaitable `finished` signal plus pause/resume/cancel/reverse/seek/set_speed controls.
  PRD.md §12.4.
- **Status:** in-phase-1

### Node proxy API (Anima.of)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  A lightweight proxy (Anima.of($Node)) exposes enter()/exit()/to()/transition_to() without modifying the node's class — the "native-feeling" runtime surface used both standalone and by AnimaBehaviour-bound nodes.
  PRD.md §12.5, §16.8.
- **Status:** backlog

### Legacy dictionary compatibility API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  AnimaLegacy.from_dictionary() converts an old dictionary-based Anima declaration into an AnimaMotion resource and emits migration warnings.
  Must stay a compatibility shim only — it must not define the new architecture.
  PRD.md §12.6.
- **Status:** backlog

### AnimaEase resource — basic curve set
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Typed easing resource, narrowed to a basic curve set for Phase 1: linear, polynomial, sine, exponential, circular.
  Gives Phase 1 motion real feel without the advanced easing modes.
  PRD.md §13.1.
- **Status:** in-phase-1

### Parameterised spring easing
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Simple response/bounce spring parameters, plus an advanced physics mode (mass, stiffness, damping, initial_velocity, settle_velocity, settle_distance).
  Open decision on which model is the default-visible one — see "Open decision: spring parameter model".
  PRD.md §13.2.
- **Status:** backlog

### Spring completion & retargeting
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Spring completes when distance-from-target and velocity both fall below configured thresholds, with modes: strictly settled / visually settled / fixed preview duration / manual.
  Retargeting reads current value + velocity and continues without resetting state.
  PRD.md §13.3, §13.4.
- **Status:** backlog

### Interruption policies
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Explicit per-motion interruption behaviour when a new target arrives mid-playback: replace, retarget, reverse, queue, cancel, complete-current, or ignore-new.
  PRD.md §13.5.
- **Status:** backlog

### Per-property ownership tracking
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Runtime tracks ownership keyed by (target instance ID + property path) so two unrelated motions can't silently fight over the same property.
  PRD.md §13.6.
- **Status:** backlog

### Easing Studio (editor tool)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Editor panel: animated preview, position/velocity/optional-acceleration graphs, overshoot display, estimated settling time, parameter controls, preset comparison, copy/paste, save-as-AnimaEase, preview-on-selected-node, reduced-motion alternative.
  PRD.md §13.7.
- **Status:** backlog

### FLIP-style automatic layout transitions
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Capture the old rect, let Godot lay out normally, capture the new rect, apply an inverse visual offset, animate back to identity.
  Godot's own layout stays authoritative — Anima only controls the temporary visual transform.
  PRD.md §14.2.
- **Status:** backlog

### Layout transition APIs (explicit / capture / automatic)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Three authoring forms: an explicit animate_changes() transaction, a manual capture_layout()+.play(), and a fully automatic Inspector toggle (duration/ease/position/size/scale/rotation/interruption policy).
  PRD.md §14.3.
- **Status:** backlog

### Repeated layout retargeting
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  If layout changes again mid-transition: capture the current visual state, preserve velocities where practical, update targets — no snap back to the previous destination.
  PRD.md §14.4.
- **Status:** backlog

### Layout child insertion/removal behaviour
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Configurable motion_in for new children (optionally excluded from FLIP inversion; parent may animate its own size) and motion_out for removed children (removal delayed until exit completes; optional placeholder preserves layout).
  PRD.md §14.5, §14.6.
- **Status:** backlog

### Layout transition scope limits (initial release)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Initial support limited to Control nodes, standard Godot containers, position/size, and nodes within the same viewport.
  3D layout and arbitrary custom drawing are explicitly out of scope.
  PRD.md §14.7.
- **Status:** backlog

### Shared-element identity & Inspector controls
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Nodes get a motion_id (stored via AnimaBehaviour, since native classes can't gain new properties) plus per-element toggles for including position/size/rotation/opacity/modulate, and a snapshot mode.
  PRD.md §15.2.
- **Status:** backlog

### Shared-element runtime transition
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Finds source+destination by motion_id, captures both visual states, hides/masks originals, builds a transition representation, animates between states, restores the destination, disposes the representation.
  PRD.md §15.3.
- **Status:** backlog

### Shared-element snapshot modes
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Live node reparenting where safe, viewport-texture snapshot, custom adapter, or a simple transform-only transition as fallback.
  PRD.md §15.4.
- **Status:** backlog

### Scene-level shared-element transitions
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Anima.transition_scene(current, next, shared_elements=true) orchestrates the shared-element transition; scene loading itself stays owned by the application, not Anima.
  PRD.md §15.5.
- **Status:** backlog

### AnimaBehaviour resource
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Per-node config resource: identity (motion_id), lifecycle (motion_in/out, play_in_on_ready, hide_after_out), defaults (duration/ease/interruption), layout toggle, state bindings, reduced-motion field.
  PRD.md §16.1.
- **Status:** backlog

### Behaviour storage without node subclassing
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Behaviour resource stored in node metadata (_anima_behaviour) plus membership in a private discovery group (_anima_enabled), surfaced through a custom Inspector plugin — no new node class required.
  Still an open decision vs. a hidden node — see "Open decision: behaviour storage mechanism".
  PRD.md §16.2.
- **Status:** backlog

### Runtime state separation from behaviour config
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  AnimaBehaviour holds configuration only; per-instance runtime state (active playbacks, property states, previous layout rect) lives in a separate AnimaNodeInstance, so shared resources never share mutable playback state.
  PRD.md §16.3.
- **Status:** backlog

### Anima Inspector section for ordinary nodes
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Selecting a supported node shows an "Anima" section: an Enable Anima toggle before activation, then Lifecycle/Defaults/Layout/States/Shared Element/Accessibility groups plus Open Motion Composer / Remove Anima after.
  PRD.md §16.4, §20.2.
- **Status:** backlog

### Undo/redo for all Anima Inspector edits
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Enable, disable, resource assignment, removal, and every settings change must go through EditorUndoRedoManager so all of it is reversible.
  PRD.md §16.5.
- **Status:** backlog

### Behaviour inheritance & override resolution
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Resolution order: node-level override → nearest inheriting parent behaviour → scene-level motion theme → project-level defaults.
  Fields expose Use Override / Inherit / Use Theme Default.
  PRD.md §16.6.
- **Status:** backlog

### State bindings for common control states
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Ordinary controls bind Idle/Hover/Pressed/Focused/Disabled/Checked/Custom states to motion resources.
  Each binding defines enter motion, exit motion, interruption policy, priority, target property set, and a reduced-motion alternative.
  PRD.md §16.7.
- **Status:** backlog

### Lazy runtime manager, no mandatory autoload
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  The first runtime request lazily creates an internal AnimaRuntime node in the current scene tree — no required project.godot autoload entry.
  Survives scene changes where the engine allows; optional explicit setup for advanced users.
  PRD.md §17.1.
- **Status:** in-phase-1

### Runtime manager responsibilities
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Owns active playbacks, per-property state, layout observers, signal waits, behaviour registration, the adapter registry, debug events, frame updates, and cleanup when targets leave the tree.
  PRD.md §17.2.
- **Status:** backlog

### Relational scheduler
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Resolves motion resources into executable instances: nested sequences/parallels, dynamic child duration, cancellation propagation, completion policies, runtime waits, reverse playback where supported, loops, speed scaling, pause/resume.
  PRD.md §17.3.
- **Status:** in-phase-1

### Central per-frame evaluation loop
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Prefer one central evaluation loop over one Tween per property, to cut allocations, simplify velocity tracking, support interruption, and keep debugging deterministic.
  Godot Tween may still back simple compiled cases but must not define the core runtime model.
  PRD.md §17.4.
- **Status:** in-phase-1

### Clock modes (Idle/Physics/Manual)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Motion updates can run on idle frames, physics frames, or be advanced manually by the caller — useful for tests, replay, deterministic previews, and tooling.
  PRD.md §17.5.
- **Status:** backlog

### Native Animation as a first-class motion event
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  An Anima graph can reference an AnimationPlayer clip: read duration, detect changes, play forward/backward, control speed, respect completion markers and cancellation, and open the clip in Godot's own editor.
  PRD.md §18.1.
- **Status:** backlog

### Anima to Animation compiler
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Compiles compatible static motions into a standard Godot Animation resource; returns the animation plus a compile report and any issues.
  PRD.md §18.2.
- **Status:** backlog

### Compilation modes (native / Bezier / adaptive / runtime-driver)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Per-channel: ordinary value tracks where directly representable, piecewise Bezier within tolerance, adaptive sampled keys for complex/multidimensional/bounce curves, or a non-default runtime-driver event when behaviour genuinely depends on runtime state.
  PRD.md §18.3.
- **Status:** backlog

### Adaptive curve sampling algorithm
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Recursive endpoint/midpoint subdivision against a configurable error tolerance and max-subdivision depth (error_tolerance, max_subdivisions, prefer_bezier, allow_runtime_driver, preserve_source_metadata).
  PRD.md §18.4.
- **Status:** backlog

### Compiler report & generated-resource metadata
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Human-readable per-channel compile report (counts by mode, output duration, max approximation error) plus embedded metadata on the generated Animation (source UID, content hash, compiler version/settings, timestamp, generated marker).
  PRD.md §18.5, §18.6.
- **Status:** backlog

### Rebuild/detach workflow for generated animations
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Editor shows generated-animation status (out of date, Rebuild, Open Output, Detach From Anima).
  Manual edits to generated assets must be marked detached, overwritten only after explicit confirmation, or copied into a new non-generated asset.
  PRD.md §18.7.
- **Status:** backlog

### Import native Animation into Anima
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Imports a native Animation as a flat scheduled group of leaf property motions / native-animation reference with absolute offsets.
  Must not pretend to reconstruct lost sequence/parallel intent unless Anima-specific metadata already exists.
  PRD.md §18.8.
- **Status:** backlog

### Motion Composer primary layout
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Toolbar, Motion Structure panel, Inspector panel, Preview viewport, generated Timeline Preview, status/validation bar.
  PRD.md §19.2.
- **Status:** backlog

### Motion Structure panel (source of truth)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Editable tree of the relational structure: add/delete/duplicate/rename/reorder, drag between groups, wrap selection in Sequence/Parallel/Stagger, collapse, disable, copy/paste, convert leaf type, extract to reusable motion, replace with referenced resource.
  Must visibly label "Source of truth: relational motion structure."
  PRD.md §19.3, §19.4.
- **Status:** backlog

### Motion Composer toolbar
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Preview/Play/Pause/Stop/Reset, Compile to Animation, Open native clip, Add Sequence/Parallel/Stagger/Motion/Wait/Callback, Undo/Redo, Validation, Composer settings.
  PRD.md §19.5.
- **Status:** backlog

### Motion Composer Inspector tabs
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  General / Timing / Motion / Target / Advanced / Accessibility tabs, exposing name/tags; delay/speed/completion policy/overlap/repeat; easing/spring/duration/from-to/interruption; target node/property/selector/group; clock mode/adapter settings/debug markers; reduced-motion/skip policy/duration scaling.
  PRD.md §19.6.
- **Status:** backlog

### Preview viewport
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Scene preview with fit/zoom/device-size presets, pause/scrub/reset, preview-selection-only vs full motion, overlays for target outlines, layout rectangles, shared-element IDs, and motion paths.
  PRD.md §19.7.
- **Status:** backlog

### Generated (derived, read-only) timeline
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Shows derived start/end/duration, parallel overlaps, stagger distribution, dynamic waits, infinite events, critical path, playhead, selection sync.
  Direct manipulation is limited to edits that create semantic relationships (drag earlier = overlap-previous, drag later = delay-after-previous) — never arbitrary absolute timing.
  PRD.md §19.8.
- **Status:** backlog

### Critical-path highlighting
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  For nested parallel groups, the editor highlights which child actually determines the group's completion time.
  PRD.md §19.9.
- **Status:** backlog

### Dynamic/estimated duration display
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Signal waits show "Duration: runtime"; estimated springs show an "Estimated settle: ~X s" label.
  PRD.md §19.10.
- **Status:** backlog

### Native clip round-trip from the Composer
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Double-clicking a Godot-Animation leaf resolves and selects the AnimationPlayer + clip and opens Godot's native Animation panel.
  The Composer refreshes when the native animation changes.
  PRD.md §19.11.
- **Status:** backlog

### Easing panel (curve preview)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Inspector curve preview across standard/spring/bounce/elastic/Bezier/custom-curve modes, with position/velocity/optional-acceleration graphs and preset/parameter/save/compare/mirror/reverse/copy/reduced-motion controls.
  PRD.md §19.12.
- **Status:** backlog

### Composer validation/issues panel
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Lists errors/warnings/info (unresolved target, uncompilable runtime signal wait, stale generated animation, duplicate-property writers, estimated spring duration); selecting an issue focuses the relevant motion.
  PRD.md §19.13.
- **Status:** backlog

### Editor state persistence
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Remembers panel sizes, collapsed groups, selection, timeline/preview zoom, inspector tab, filter state.
  Project data and user-local editor state must be stored separately.
  PRD.md §19.14.
- **Status:** backlog

### EditorInspectorPlugin for Anima
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Surfaces Anima fields on supported classes: Control, Node2D, basic-transform Node3D, CanvasItem, plus adapter-registered classes.
  PRD.md §20.1.
- **Status:** backlog

### Inspector preview actions
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Preview In / Preview Out / Reset / Open motion / Create new motion / Compile motion buttons directly in the Inspector.
  PRD.md §20.3.
- **Status:** backlog

### Scene-inheritance-aware override display
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  The Inspector must visibly distinguish a local value, an inherited value, a theme value, and a project default for inherited scenes.
  PRD.md §20.4.
- **Status:** backlog

### Legacy preset audit
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Every existing Anima preset gets classified as keep / rename / reimplement / deprecate / remove before Anima 2 ships its own preset set.
  PRD.md §21.1.
- **Status:** backlog

### Preset resource model & categories
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Presets are normal AnimaMotion resources, organised into categories: attention, entrance, exit, emphasis, transform, UI interaction, layout, feedback, camera, text, reduced motion.
  PRD.md §21.2.
- **Status:** backlog

### Preset browser
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Search, tags, preview, favourites, recently-used, filter by target type / runtime-only, drag into Motion Structure, duplicate into project, create custom preset.
  PRD.md §21.3.
- **Status:** backlog

### Motion themes (AnimaMotionTheme)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Project-level theme resource bundling duration/easing/spring tokens, named motions, reduced-motion mappings, default interruption policy, and stagger intervals.
  PRD.md §21.4.
- **Status:** backlog

### Playable adapter interface
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  AnimaPlayableAdapter contract (supports / get_duration / create_instance) lets external playback systems join relational composition without becoming part of Anima core.
  PRD.md §22.2.
- **Status:** backlog

### Core adapters (initial release)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Godot property, AnimationPlayer, AudioStreamPlayer, ShaderMaterial, Callable, Signal, and layout-transition adapters ship in the initial release.
  AnimatedSprite, camera shake, particles, dialogue systems, and third-party runtimes (Spine/Rive/Lottie) are later, documented-only integrations — Anima does not own their rendering.
  PRD.md §22.3, §22.4.
- **Status:** backlog

### Per-motion reduced-motion alternatives
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Each motion/behaviour may define an alternative motion, a duration scale, a disable-motion flag, an opacity-only fallback, or an instant transition.
  PRD.md §23.1.
- **Status:** backlog

### Global reduced-motion setting
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  AnimaSettings.reduced_motion supports System / Enabled / Disabled.
  PRD.md §23.2.
- **Status:** backlog

### Advisory motion-safety validation
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Editor may warn (non-blocking) about excessive flashing, large repeated movement, long blocking motion, a missing reduced-motion alternative for important navigation, or infinite motion without a pause condition.
  PRD.md §23.3.
- **Status:** backlog

### Runtime debugger panel
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Optional editor panel listing active motions with target, property ownership, current value/velocity, target value, elapsed time, current branch, waiting signals, queue state.
  PRD.md §24.1.
- **Status:** backlog

### Structured motion trace
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  A playback can emit a timestamped structured trace of start/complete events per node, for debugging.
  PRD.md §24.2.
- **Status:** backlog

### Debug viewport overlay
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Optional overlay: target bounds, layout old/new rectangles, velocity vectors, shared-element matching, property conflicts, motion IDs.
  PRD.md §24.3.
- **Status:** backlog

### Configurable logging levels
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Off / Errors / Warnings / Lifecycle / Verbose.
  PRD.md §24.4.
- **Status:** backlog

### Static motion validation
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Missing targets, invalid properties, unsupported value types, empty composites, recursive motion references, invalid completion child, negative durations, runtime-only motion inside a native-only compile, multiple writers to the same property, missing AnimationPlayer clip, invalid signal, infinite child inside a finite sequence, shared-element ID collisions.
  PRD.md §25.1.
- **Status:** backlog

### Runtime validation
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Detect target removed, property type changed, signal source freed, adapter unavailable, layout transition target moved across an unsupported viewport, stale compiler output.
  PRD.md §25.2.
- **Status:** backlog

### Performance validation targets & benchmark suite
- **Type:** tech-debt
- **Source:** PRD.md
- **Context:**
  Provisional (non-guaranteed) targets: 100 concurrent property motions with no measurable frame degradation, 1,000 lightweight motions at interactive frame rates, no recurring per-property allocation after setup, 100-control layout transition with no visible hitch, editor-preview response within one frame of scrub.
  Benchmark suite spans scalar/Vector2/colour/spring/retargeting/stagger/layout/shared-element/compiled-Animation/legacy-Anima/Tween-baseline across desktop, Android, Web, low-end hardware.
  PRD.md §26.2, §26.3.
- **Status:** backlog

### Open decision: native-accelerator (GDExtension) gate
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  A GDExtension accelerator may only be considered once a reproducible benchmark shows a significant bottleneck in Anima's own evaluation (not property writes/layout), native implementation would meaningfully help, and build/release automation covers the needed platforms.
  Do not build in the initial release; GDScript remains the fallback.
  PRD.md §26.1, §26.4.
- **Status:** resolved

### Open decision: Godot version support policy
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  The document requires picking and stating one clear supported Godot 4.x minor range (plus a deprecation policy) rather than claiming broad compatibility — the specific version numbers are not yet chosen.
  PRD.md §27.1.
- **Status:** resolved

### Automated compatibility CI
- **Type:** test
- **Source:** PRD.md
- **Context:**
  CI coverage for plugin activation, resource loading, runtime playback, editor-plugin startup, compiler output, demo scenes, and headless unit tests, across every supported Godot version.
  PRD.md §27.2.
- **Status:** backlog

### C# API wrapper (later)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  A public-runtime-API C# wrapper follows once the GDScript API is stable.
  Resources stay language-independent; no feature may depend on GDScript-only dictionary conventions.
  PRD.md §27.3.
- **Status:** backlog

### Legacy-project migration tool
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  "Tools → Anima → Migrate Legacy Project" scans for legacy Anima resources, animation definitions, old class names, old autoload entries, old preset references, and legacy demo patterns.
  PRD.md §28.2.
- **Status:** backlog

### Per-item migration conversion report
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Each migrated item is reported as converted automatically / converted with warnings / requires manual migration / unsupported.
  PRD.md §28.3.
- **Status:** backlog

### Legacy dictionary to resource conversion mapping
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  AnimaLegacy.convert() turns a legacy dictionary declaration (node/property/from/to/duration) into an AnimaPropertyMotion.
  Legacy `then` maps to Sequence; legacy `with` maps to Parallel or a shared-start relationship.
  PRD.md §28.4.
- **Status:** backlog

### Preset name compatibility mapping
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  A legacy-preset-name to new-motion-resource mapping ships so deprecated preset names produce clear warnings instead of silently breaking.
  PRD.md §28.5.
- **Status:** backlog

### Migration documentation
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Concept mapping, API mapping, before/after examples, common edge cases, removed behaviours, new recommended patterns.
  PRD.md §28.6.
- **Status:** backlog

### Full documentation structure
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Intro / why-Anima / installation / five-minute tutorial, through motion resources, code API, Composer, easing/springs, interruptions, layout, shared elements, node behaviours, native-Animation integration, compiler, accessibility, adapters, migration, troubleshooting, API reference.
  PRD.md §29.1.
- **Status:** backlog

### Interactive documentation examples
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Dialog entrance, button interactions, inventory reorder, shared-element item details, interruptible menu, signal-driven sequence, native-Animation integration, compile-to-Animation.
  PRD.md §29.2.
- **Status:** backlog

### Polished demo project
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Motion gallery, easing laboratory, layout playground, shared-element example, runtime debugger, Composer example resources.
  PRD.md §29.3.
- **Status:** backlog

### Documentation quality gate
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  No release ships with broken links, missing API pages, examples incompatible with the supported Godot version, or unexplained required setup.
  PRD.md §29.4.
- **Status:** backlog

### Add-on install & no forced project mutation
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Standard addons/anima install + enable.
  Any optional project-settings changes the plugin makes must be explicit, idempotent, and reversible — no repeated silent rewrites of project.godot.
  PRD.md §30.1, §30.2.
- **Status:** backlog

### Asset-store listing package
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Version-compatibility statement, screenshots, short demo video, feature comparison against current Godot capabilities, a Motion Composer image, install instructions, migration notice.
  PRD.md §30.3.
- **Status:** backlog

### Safety constraints on callbacks, imports, and generated files
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  No editor-generated arbitrary code; callback references stay visible in resources; imported resources are validated; editor preview avoids running unsafe application logic by default; signal waits get simulation controls in preview; file writes stay inside expected project paths; generated resources never overwrite user files without confirmation.
  PRD.md §31.
- **Status:** backlog

### Adoption & product-value success criteria
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Target: ≥5 external beta teams, ≥3 production teams, ≥3 teams using interruptible motion/layout transitions/the Composer, users creating reusable motion resources (not just running presets), ≥1 external contributor.
  Measured without invasive telemetry (asset-store installs, GitHub release downloads).
  PRD.md §32.1, §32.2.
- **Status:** backlog

### Usability & sustainability metrics
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Track install-to-first-motion time, time to build a dialog entrance, Sequence-vs-Parallel comprehension, timeline-repair frequency after duration changes, ability to diagnose why an event starts when it does, ability to find compiler errors, maintenance effort per Godot minor release, open compatibility issues, external-contribution success rate.
  PRD.md §32.3, §32.4.
- **Status:** backlog

### Kill / reduce-scope criteria
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  If, after a meaningful public beta, Composer usage stays negligible, real projects use only presets, compatibility maintenance exceeds sustainable capacity, layout/interaction features show no clear adoption, or no external teams validate the new direction — move to maintenance-focused mode rather than expanding scope further.
  PRD.md §32.5.
- **Status:** backlog

### Engineering sustainability constraints (G7)
- **Type:** tech-debt
- **Source:** PRD.md
- **Context:**
  No mandatory engine fork, no mandatory platform-specific binaries, don't duplicate every Godot node type, don't rely on undocumented editor-tree traversal for core features, keep optional hacks isolated/disabled by default, add editor-startup tests to catch breakage across Godot versions early.
  PRD.md §4.1 (G7), §36.2.
- **Status:** backlog

### Comprehensive unit test coverage
- **Type:** test
- **Source:** PRD.md
- **Context:**
  Sequence/parallel/nested duration math, delay/overlap, stagger ordering, repeat, race, cancellation, reverse, spring solver, retarget velocity, property-conflict policies, adaptive sampling, resource serialization, migration mappings.
  PRD.md §34.1.
- **Status:** backlog

### Integration test coverage
- **Type:** test
- **Source:** PRD.md
- **Context:**
  Scene-tree lifecycle & target removal, Inspector enable/disable, undo/redo, behaviour inheritance, native-Animation playback, compiler output, layout reorder, shared-element transition, editor preview, plugin reload.
  PRD.md §34.2.
- **Status:** backlog

### Golden tests for animation output
- **Type:** test
- **Source:** PRD.md
- **Context:**
  Known-good outputs kept for easing samples, spring trajectories, compiled keyframes, generated-resource metadata, and timeline resolution, to catch silent regressions.
  PRD.md §34.3.
- **Status:** backlog

### Visual regression tests
- **Type:** test
- **Source:** PRD.md
- **Context:**
  Demo-scene screenshots, layout-transition frames, editor panel layouts, and preview output compared where practical.
  PRD.md §34.4.
- **Status:** backlog

### Open decision: motion resource granularity
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  Should every leaf be a separate .tres Resource, or can simple leaves be embedded lightweight subresources?
  Document's recommendation: everything is a Resource; the Composer creates embedded subresources by default; users can extract any motion to an external .tres.
  PRD.md §37.1.
- **Status:** backlog

### Open decision: behaviour storage mechanism
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  Metadata Resource + private group + Inspector plugin vs. a hidden node (see "Behaviour storage without node subclassing").
  Document recommends the metadata approach initially, re-evaluating only if metadata serialization proves impractical.
  PRD.md §37.2.
- **Status:** backlog

### Open decision: timeline direct-manipulation scope
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  How far should dragging in the generated timeline be allowed to go?
  Document recommends supporting only semantic edits (creating Overlap/Delay relationships) and never making absolute position the default source of truth.
  PRD.md §37.3.
- **Status:** backlog

### Open decision: spring parameter model exposed by default
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  Simple response/bounce vs. mass/stiffness/damping vs. both.
  Document recommends simple response/bounce as the default surface, with advanced physics parameters behind an expandable/advanced section.
  PRD.md §37.4.
- **Status:** backlog

### Open decision: native-Animation import strategy
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  Should an imported native Animation stay a referenced leaf by default, with full track conversion only as an explicit advanced command?
  Document recommends yes — referenced leaf by default.
  PRD.md §37.5.
- **Status:** backlog

### Open decision: final version name/number
- **Type:** spec-gap
- **Source:** PRD.md
- **Context:**
  "Anima 2" is used as a working/dev codename only.
  Document recommends deciding the actual semantic version at release time, based on the release and migration strategy.
  PRD.md §37.6, header.
- **Status:** backlog

### PRD's suggested Minimum Lovable Product
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  The document's own proposed first-release slice: typed AnimaMotion resources, Sequence+Parallel, property motion, native-Animation event, basic easing, AnimaBehaviour, enter/exit Inspector fields, Composer structure tree, generated timeline preview, preview viewport, open-native-clip, one interruptible spring, one layout-transition example, high-quality docs/demo (§38).
  Foundation-conflict note for `mano start`: migration tooling (§28) sits in the last release phase and is excluded from this MLP list, yet §7.5 and §28 both treat a migration path as a primary need for existing Anima users — this tension is unresolved in the source document and should be settled during phase scoping, not assumed either way.
- **Status:** backlog

### Additional leaf motion types
- **Type:** feature
- **Source:** Phase 1 split
- **Context:**
  Keyframe motion, native-Animation reference, signal wait, delay, callback, audio, shader-parameter, layout, shared-element, and nested-motion-reference leaves.
  Extends the Phase 1 Property motion leaf type once shipped. Full per-type schemas: PRD.md §10.3.
- **Status:** backlog

### AnimaEase advanced modes
- **Type:** feature
- **Source:** Phase 1 split
- **Context:**
  Back, bounce, elastic, cubic Bezier, curve resource, callable evaluator, spring, decay, and custom sampled curve easing.
  Extends the Phase 1 AnimaEase basic curve set once shipped. PRD.md §13.1.
- **Status:** backlog

### Reversibility declared per motion (Automatic/Explicit/Forward-only)
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Every motion declares a Reversibility: AUTOMATIC (Anima derives the reverse), EXPLICIT (author supplies reverse behaviour), or FORWARD_ONLY (reversing is a validation error or follows a configured skip policy).
  Prevents Anima from pretending every event can be meaningfully reversed.
  PRD2.md — "Reversibility is part of the motion definition".
- **Status:** backlog

### Three distinct reverse operations (play backwards / reverse timeline / retarget to start)
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  The original PRD grouped these under one "reverse" idea; they must be distinct: Anima.play_backwards(motion, context) (run from completed state to initial state), playback.reverse() (flip the current timeline's direction from wherever it is), and playback.retarget_to_start() (physically retarget, e.g. a spring's target changes to its initial value while keeping current velocity, instead of retracing the calculated path).
  API should expose the distinction explicitly (reverse_timeline() vs retarget_to_start()).
  PRD2.md — "Define three separate operations".
- **Status:** backlog

### Timeline-reversal semantics
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  playback.reverse() must preserve current values, reverse the relational execution cursor without restarting from the end, trigger reverse-event semantics when markers are crossed, and allow repeated direction changes.
  Needed for menu open/close, hover/focus, expand/collapse, reversible panels, interaction previews.
  PRD2.md — "Reverse the current timeline".
- **Status:** backlog

### Per-motion-type reversal contract
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Defines how each motion type reverses: Property motion (to→from, with mirrored easing so the reversed trajectory matches the forward one); Sequence (children reverse in reverse order); Parallel (children reverse, stay parallel); Delay (same duration, mirrored position in the graph).
  PRD2.md — "Reverse rules for each motion type".
- **Status:** backlog

### Stagger reversal & ReverseStaggerPolicy
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  A chronological reverse inverts the resolved stagger order.
  Resource exposes ReverseStaggerPolicy: REVERSE_ORDER (default — reconstructs the initial visual state in chronological reverse), KEEP_ORDER, CUSTOM.
  PRD2.md — "Stagger".
- **Status:** backlog

### Open decision: Repeat reversal rules
- **Type:** spec-gap
- **Source:** PRD2.md
- **Context:**
  Not yet defined: whether completed iterations of AnimaRepeat are reversed, whether only the current iteration reverses, how alternating repeats behave, and whether infinite repetition can enter reverse mode at all.
  PRD2.md — "Repeat".
- **Status:** backlog

### Native Animation reversal via AnimationPlayer
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  When an Anima event references a native clip, use AnimationPlayer's own backwards playback (Godot supports this directly) rather than building custom reversal logic for native clips.
  PRD2.md — "Native Godot Animation".
- **Status:** backlog

### Spring reversal: exact timeline vs physical retarget
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Springs must support both, and must not treat them as equivalent: exact timeline reversal (retraces the calculated path backwards) and physical retargeting to the initial state (changes the spring's target while preserving current velocity — usually the more natural choice for interactive UI).
  PRD2.md — "Spring".
- **Status:** backlog

### Layout-transition reversal with staleness check
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  If both layout snapshots are still valid, reversing returns from the new layout to the previous one.
  If the application has since changed the layout again, Anima retargets to the current layout instead of replaying stale geometry.
  PRD2.md — "Layout transition".
- **Status:** backlog

### Shared-element transition reversal
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Reverses source/destination roles, provided both states still exist or snapshots were retained.
  PRD2.md — "Shared-element transition".
- **Status:** backlog

### Open decision: callback reversal mechanism
- **Type:** spec-gap
- **Source:** PRD2.md
- **Context:**
  A callback is not automatically reversible. Two alternative shapes are proposed and neither is chosen yet: an explicit forward/backward Callable pair (Motion.callback({forward=..., backward=...})), or a reversible command object (AnimaCommand with execute()/undo()).
  PRD2.md — "Callback".
- **Status:** backlog

### Signal-wait reverse policy (ReverseEventPolicy)
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Waiting for a signal has no automatic reverse. Resource exposes ReverseEventPolicy: SKIP, REQUIRE_EXPLICIT, RUN_REVERSE_EVENT, ERROR.
  Safest default for authored motions is REQUIRE_EXPLICIT.
  PRD2.md — "Signal wait".
- **Status:** backlog

### Race/Conditional reversal replays the branch actually taken
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Reversing a completed Race or Conditional motion must reverse the branch that actually ran, not re-evaluate the condition and potentially pick a different one.
  Requires the playback to retain an execution trace (selected conditional branch, race winner, completed-iteration count).
  PRD2.md — "Race and conditionals".
- **Status:** backlog

### Runtime execution-history recording (AnimaExecutionRecord)
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Reversing a dynamic graph can't always be derived from the resource alone. Runtime must record selected conditional branches, race winners, resolved dynamic values, stagger ordering, executed callbacks, completed loops, native clip state, runtime durations, layout snapshots — an AnimaExecutionRecord tree (motion_id, selected_branch, resolved_targets, resolved_values, children).
  playback.reverse() reverses what actually happened, not what might happen now. Called out as an important architectural requirement.
  PRD2.md — "Add graph execution history".
- **Status:** backlog

### Motion Composer: direction & reversibility toolbar
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Add Play Forward, Play Backward, Reverse Current Playback, Reset to Start, Reset to End controls.
  PRD2.md — "Update the Motion Composer" / Toolbar.
- **Status:** backlog

### Motion Composer: reversibility structure indicators
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Each event in the Motion Structure tree shows its reversibility at a glance: ↔ automatically reversible, ⇄ explicit reverse defined, → forward only.
  PRD2.md — "Structure indicators".
- **Status:** backlog

### Motion Composer: reversal validation messages
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Issues panel reports reversal-specific problems: a callback with no reverse action (warning), a Signal Wait that can't reverse automatically (error), a native Animation using AnimationPlayer backwards playback (info), a dynamic target that must be recorded to support runtime reversal (warning).
  PRD2.md — "Validation".
- **Status:** backlog

### Motion Composer: bidirectional timeline preview
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Generated timeline supports forward and backward playheads, direction arrows, reverse-callback markers, mirrored stagger preview, and switching direction mid-scrub.
  PRD2.md — "Timeline preview".
- **Status:** backlog

### Motion Composer: Inspector Reverse section
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Per-motion Inspector section: Reversibility (Automatic/Explicit/Forward-only), reverse-easing mode (mirror automatically), callback policy, stagger policy, spring behaviour (retarget physically vs timeline reversal), and an optional explicit reverse-motion resource.
  PRD2.md — "Inspector".
- **Status:** backlog

### Compiler: backward-playback support & reversibility metadata
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Compiled native Animation resources can normally be played backwards via AnimationPlayer; compiler metadata records whether callbacks/dynamic events retain equivalent reverse semantics — a successful forward compilation does not automatically mean the whole motion is safely reversible.
  Compile report states forward vs backward playback fidelity separately, with channel-by-channel reversibility counts.
  PRD2.md — "Update the compiler".
- **Status:** backlog

### Reversible-motion acceptance criteria (epic)
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Dedicated epic: Sequence/Parallel/Stagger reverse correctly per their rules; easing mirrors correctly; reversing halfway doesn't snap to either end; direction can change repeatedly; dynamic values use recorded forward values; Conditional reverses the branch actually executed; callbacks require explicit reverse behaviour; native animations use backwards playback; property ownership stays valid while direction changes; layout transitions don't restore stale layouts; forward-only events are reported before playback where detectable.
  PRD2.md — "Update the acceptance criteria".
- **Status:** backlog

### Revised four-pillar product framing
- **Type:** feature
- **Source:** PRD2.md
- **Context:**
  Reframes Anima 2 around four pillars: relational composition; bidirectional & interruptible motion (play backwards, reverse midway, or physically retarget while preserving state); automatic interaction & layout transitions; native Godot authoring & compilation.
  Updates/extends PRD.md's original single-line product-category framing (§2.2) to give "bidirectional and interruptible motion" equal billing with relational composition.
  PRD2.md — "Revised core pillars".
- **Status:** backlog
