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
- Production-ready by default: a feature isn't complete just because its ideal demo works — interruption, reversal, direction/speed changes, seeking, removed targets, layout changes, skipped/reduced motion, property conflicts, and editor preview must all be defined, not left as edge cases.

## Items

### AnimaMotion base resource
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Base Resource class shared by every motion type (composite and leaf): display_name, enabled, delay, speed, tags, metadata, plus estimate_duration/create_runtime/validate methods.
  Every composite and leaf motion type extends this.
  Full schema: PRD.md §10.1.
- **Status:** resolved

### Sequence composition (AnimaSequence)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Runs child motions one after another; completes when the final enabled child completes.
  The core building block for "after this" relationships (G1).
  PRD.md §10.2.
- **Status:** resolved

### Parallel composition (AnimaParallel)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Starts all children together; a completion policy (all children / first child / a named child) decides when the group finishes.
  For "all children", duration is the longest child's duration.
  PRD.md §10.2.
- **Status:** resolved

### Stagger composition (AnimaStagger)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Repeats a template motion across a target selector with an interval and an order (forward, reverse, from-center, from-edges, random, custom).
  Used for effects like buttons appearing one after another.
  PRD.md §10.2.
- **Status:** resolved

### Repeat composition (AnimaRepeat)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Repeats a child motion a given count, with an optional delay between repeats and an alternate (ping-pong) mode.
  PRD.md §10.2.
- **Status:** resolved

### Race composition (AnimaRace)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Runs children concurrently and completes on the first completion, optionally cancelling the remaining children.
  PRD.md §10.2.
- **Status:** resolved

### Conditional branch (AnimaConditional)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Selects between a when_true and when_false child motion at runtime based on a condition.
  Runtime-only unless the condition can be resolved at compile time.
  PRD.md §10.2.
- **Status:** resolved

### Property motion leaf type
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Property motion leaf: animates one property from/to a value.
  The only leaf type in Phase 1 — enough to make Sequence/Parallel structure produce visible motion.
  Full schema: PRD.md §10.3.
- **Status:** resolved

### Relationship timing modifiers (start offset, overlap, after-start)
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Start offset, "overlap previous" (start before the previous child completes), and "start after previous begins" — relative timing between children beyond strict Sequence/Parallel.
  Completion threshold is exact-end only this phase; spring-settled, visually-settled, named-marker, and signal thresholds need features not built yet.
  PRD.md §10.4.
- **Status:** resolved

### Duration model (Fixed/Estimated/Dynamic/Infinite) — runtime only
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Motions report a duration kind, not just a number: Fixed, Estimated, Dynamic, or Infinite — the runtime/data-model concept only.
  Editor visual distinction (solid/striped/dashed/arrow bars) needs the Motion Composer, which doesn't exist yet.
  PRD.md §11.
- **Status:** resolved

### Functional builder API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Fluent, chainable GDScript builder (Motion.sequence/parallel/stagger/... with .duration()/.ease() chaining) designed for autocomplete and readability when nested.
  Primary code-first authoring surface.
  PRD.md §12.2.
- **Status:** resolved

### Explicit resource API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Motions can be constructed directly as typed Resource objects (e.g. AnimaSequence.new(), assigning a `children` array) without the builder.
  PRD.md §12.3.
- **Status:** resolved

### Runtime playback API
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Anima.play(motion, node) returns a playback object with an awaitable `finished` signal plus pause/resume/cancel/reverse/seek/set_speed controls.
  PRD.md §12.4.
- **Status:** resolved

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
- **Status:** resolved

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
- **Status:** resolved

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
- **Status:** resolved

### Central per-frame evaluation loop
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  Prefer one central evaluation loop over one Tween per property, to cut allocations, simplify velocity tracking, support interruption, and keep debugging deterministic.
  Godot Tween may still back simple compiled cases but must not define the core runtime model.
  PRD.md §17.4.
- **Status:** resolved

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

### AnimaGroupMotion resource
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  First-class AnimaMotion resource applying one item motion to a resolved target collection: targets, item_motion, playback_mode, order, target_resolution, interval/total_stagger_duration/gap, include-parent/hidden/internal flags, reverse/invalid-target policies.
  Dedicated resource (not builder sugar) because it needs target collections, ordering, runtime expansion, editor representation, reversal policies, and compilation reporting (PRD3.md §28.1).
  One resource with a playback_mode enum, not separate Sequential/Parallel/Stagger subclasses — target/item-motion config is shared and mode-switching shouldn't require replacing the resource (§28.2).
  Complements, not replaces, the general-purpose AnimaStagger structural motion: AnimaStagger is for explicitly authored child motions, AnimaGroupMotion-in-staggered-mode is one item-motion template distributed across resolved targets (§28.3).
  PRD3.md §3, §8.1.
- **Status:** backlog

### Target collection resource model (AnimaTargetCollection)
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Base Resource every target-collection type extends: resolve(context) -> Array[Node] required; validate(context) -> Array[AnimaIssue] and describe() -> String optional.
  PRD3.md §9.1.
- **Status:** backlog

### Children target collection
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Resolves targets from a parent node's children: parent reference, recursive, include_parent, include_hidden, include_internal_children, type_filter.
  Usage: TargetCollection.children_of($VBoxContainer).
  PRD3.md §9.2.
- **Status:** backlog

### Explicit target collection
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  An ordered list of unrelated nodes animated as one group; explicit list order must be preserved.
  Targets stored as scene-relative NodePath-style references (with editor validation/repair for missing references), never live Node references, so the resource stays safely reusable across scenes (§28.4).
  Usage: TargetCollection.nodes([$Title, $Portrait, $ConfirmButton]).
  PRD3.md §9.2.
- **Status:** backlog

### Scene-group target collection
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Resolves targets from a Godot scene group, optionally restricted to a root node.
  Usage: TargetCollection.scene_group(&"inventory_items").
  PRD3.md §9.2.
- **Status:** backlog

### Descendant target collection
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Resolves recursive descendants with optional type/Godot-group/name filtering.
  May be introduced after the basic children collection ships.
  PRD3.md §9.2.
- **Status:** backlog

### Runtime (callable) target collection
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  A callable or adapter resolves targets at playback time; code-only, may not be serialisable, and the editor must clearly mark such collections as runtime-resolved.
  Usage: TargetCollection.from_callable(func(): return active_cards).
  PRD3.md §9.2, §11.4.
- **Status:** backlog

### Target resolution timing policy
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  When the target collection is evaluated: at playback start (default — reflects current membership/order, stable for one playback), snapshot (fixed list resolved before playback; scene-relative references only, never live object refs, for resources shared across scenes), or live (observes membership changes during playback — deferred, not required for the first release; the enum value is reserved but reports unsupported until implemented).
  PRD3.md §10.
- **Status:** backlog

### Group target filtering
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Type filter (e.g. .of_type(Button)); visibility filter (all / visible-property / visible-in-tree); disabled-state filter for BaseButton-like controls (include/exclude/only, advanced option); custom predicate callable (code-only, may block serialization/editor preview — editor must mark such collections runtime-resolved).
  PRD3.md §11.
- **Status:** backlog

### Sequential group playback mode
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Each generated item motion begins only after the previous one completes, plus a configurable gap; start(n) = end(n-1) + gap.
  Group completes when the final item completes.
  PRD3.md §8.3 (Sequential).
- **Status:** backlog

### Parallel group playback mode
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  All generated item motions start together (start(n) = 0); default completion waits for every item motion; group duration is the longest item's duration.
  PRD3.md §8.3 (Parallel).
- **Status:** backlog

### Staggered group playback mode
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Each item starts after a configured offset regardless of whether the previous item finished; group completes when the final active item completes.
  Two mutually exclusive timing modes: fixed interval (start(n) = n × interval) or fixed total distribution duration (interval = total / max(N-1, 1)); if both are set, the editor must require choosing one active mode rather than silently picking.
  PRD3.md §8.3 (Staggered), §8.4.
- **Status:** backlog

### Group completion policy
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  ALL_ITEMS (default) / FIRST_ITEM (advanced-only, for orchestration) / LAST_STARTED_ITEM.
  PRD3.md §8.5.
- **Status:** backlog

### Empty group handling
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  When zero valid targets resolve, the group completes immediately; configurable policy COMPLETE / WARN_AND_COMPLETE (default) / ERROR. Not a runtime error by default.
  PRD3.md §8.6.
- **Status:** backlog

### Target ordering strategies
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Forward (resolved order), reverse, from-centre, from-edges, random (seeded, deterministic for a fixed seed, editor can regenerate or lock), grid rows, grid columns, grid diagonal (4 directions), distance-from-point (node/local point/global point/collection centre/pointer position — may be deferred beyond first release), explicit, and custom (callable: reordered array, numeric rank, or comparator; code-only unless represented as a registered ordering resource).
  Centre/edges ordering is index-based (position in the resolved list), not spatial (on-screen distance) — resolved during import; consistent across every collection type regardless of on-screen layout.
  PRD3.md §12.
- **Status:** backlog

### Grid resolution for GridContainer
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Derives row/column from child index and configured column count (row = index / C, column = index % C).
  Default uses compact filtered indices (excludes gaps left by filtered-out nodes), not original child indices, so exclusions don't create unexpected empty positions.
  PRD3.md §13.1.
- **Status:** backlog

### Non-GridContainer spatial grid inference
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Optionally infers rows/columns from target positions (positional tolerance, stable sorting, coordinate-space selection) for layouts that aren't a GridContainer.
  Not required for the initial release.
  PRD3.md §13.2.
- **Status:** backlog

### Grid waves ordering (future)
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Groups items into simultaneous waves (e.g. diagonal bands) that start together, differing from a flat stagger where every item gets its own offset.
  Initial release may flatten waves into equal-rank items sharing one start offset.
  PRD3.md §13.3.
- **Status:** backlog

### Item motion target binding and per-item captured values
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  The item motion is authored relative to the current item's target; inside it, "the target" resolves to the generated per-item context.
  Each item must independently capture its own initial values, relative offsets, dynamic values, and target-specific data — a group must never capture the first item's values and reuse them for every target.
  PRD3.md §14.1, §14.3.
- **Status:** backlog

### Nested item motions
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  An item motion may itself be a Sequence, Parallel group, property motions, native animations, delays, callbacks, or nested reusable motions — instantiated once per resolved target.
  PRD3.md §14.2.
- **Status:** backlog

### Per-item context variables
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Item motions can read index, reverse_index, count, normalised_index, row, and column for the current target, e.g. to interpolate a value across the group.
  PRD3.md §14.4.
- **Status:** backlog

### Item-motion duration differences across targets
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Item motions may resolve to different durations per target (dynamic values, target-specific config, spring settling, native-animation differences, conditional branches).
  Sequential waits for each item's actual completion; staggered preserves configured start offsets regardless of duration differences; parallel completion accounts for all actual completions.
  PRD3.md §14.5.
- **Status:** backlog

### Group reversal policies
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  REVERSE_ORDER (default: reverse(C) → reverse(B) → reverse(A) for sequential; offsets mirrored for staggered) / KEEP_ORDER (reverse each item's motion without reversing target order — for symmetrical effects or matching entrance/exit direction) / CUSTOM.
  Parallel reversal keeps every item parallel; order affects callbacks/debugging/determinism only, not timing.
  PRD3.md §15.1-§15.5.
- **Status:** backlog

### Mid-playback group reversal
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Active item playbacks reverse or retarget per their own policy; not-yet-started items are rescheduled; completed items may become pending-reverse items.
  The group preserves its already-resolved target order (random groups don't reshuffle); dynamic collections reverse only the targets that actually participated in the current execution.
  PRD3.md §15.6.
- **Status:** backlog

### Group execution record
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Tracks resolved targets (weak refs), resolved order, generated start offsets, completed/active item indices, and the random seed used.
  Used for reversal, debugging, deterministic replay, and runtime inspection.
  PRD3.md §15.7.
- **Status:** backlog

### Group playback runtime responsibilities
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  AnimaGroupPlayback (extends AnimaPlayback) resolves/filters/orders targets, creates independent per-target item playbacks, calculates start offsets, starts/tracks/cancels them, handles reversal, and generates execution records.
  Each generated item record tracks its target, original/ordered index, row/column, start offset, and its own AnimaPlayback.
  PRD3.md §16.1-§16.2.
- **Status:** backlog

### Target validity and invalid-target policies
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Before starting each generated item, the group confirms the target still exists, remains in the required scene-tree context, and is supported by the item motion.
  Policy: SKIP (default, ignore and continue) / CANCEL_GROUP / COMPLETE_ITEM (counts as successful completion, differs from SKIP only in tracing/reporting) / ERROR (for tests/strict authoring).
  PRD3.md §16.3-§16.4.
- **Status:** backlog

### Target removed during playback
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Default: cancel that item's playback, release its property ownership, mark it skipped, continue the group, and complete once all remaining valid items finish.
  A configurable strict mode may cancel the whole group instead.
  PRD3.md §16.5.
- **Status:** backlog

### Group pause and resume
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Pausing a group pauses active item playbacks, pending stagger offsets, sequential progression, and the group's elapsed time together; resuming continues from that same state.
  PRD3.md §16.6.
- **Status:** backlog

### Group cancellation
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Cancels active item playbacks, prevents pending items from starting, disconnects signals, releases property ownership, and emits one group cancellation result.
  PRD3.md §16.7.
- **Status:** backlog

### Group speed changes
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Changing a group's playback speed affects pending stagger offsets, sequential gaps, active item playback speed (where the item motion supports it), and the estimated group duration.
  PRD3.md §16.8.
- **Status:** backlog

### Group code API surface
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Motion.group(nodes) / Motion.group_children(parent) with .apply(item_motion), .sequential([gap]), .parallel(), .staggered(interval), .stagger_across(total_duration), .order(...), .reverse_order(...); TargetCollection.children_of/.nodes/.scene_group/.from_callable; a TargetCollection can be built once and applied to multiple group motions (e.g. separate enter/exit motions).
  PRD3.md §7 (US1-US8), §17.
- **Status:** backlog

### Motion Composer: group node representation
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Motion Structure panel shows a Group node's target source, playback mode, interval/gap, order, and item motion as a labelled sub-tree (e.g. "Targets: Children of X", "Mode: Staggered").
  PRD3.md §18.1.
- **Status:** backlog

### Motion Composer: group creation and target authoring
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Add → Group, seeded from children-of-selected-node, explicit nodes, a Godot scene group, or an empty reusable collection.
  Drag-and-drop: drag a container into the target field, drag multiple selected scene nodes into an explicit list, reorder/remove explicit targets, locate a target in the scene tree, replace a missing target.
  PRD3.md §18.2-§18.3.
- **Status:** backlog

### Motion Composer: group Inspector fields
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  General (name/enabled/item motion), Targets (collection type/parent/recursive/explicit list/type+visibility filter/resolution policy), Distribution (playback mode/interval/total distribution duration/sequential gap/completion policy), Order (order/grid direction/centre mode/random seed/custom ordering resource), Reverse (reverse order policy/reverse item motion/mid-playback behaviour), Advanced (invalid-target policy/empty-group policy/include-internal-children/compiler behaviour/debug expansion).
  PRD3.md §18.4.
- **Status:** backlog

### Motion Composer: resolved target and grid rank preview
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Shows the currently resolved target list by name (or "targets are resolved at runtime" for runtime-only collections), and a grid rank preview (e.g. a numbered layout diagram) for grid orderings so the ordering can be understood before playback.
  PRD3.md §18.5-§18.6.
- **Status:** backlog

### Motion Composer: generated group timeline
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Collapsed (single group bar) or expanded (one row per generated item) timeline view; generated rows are not independent source nodes — editing one redirects to the owning target collection, item motion, or ordering config.
  For parallel/staggered groups, the timeline indicates which item determines group completion (critical path) and the resulting group duration.
  PRD3.md §18.7-§18.8.
- **Status:** backlog

### Motion Composer: group playback controls and target highlighting
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Play group / play selected item / play from selected item / play forwards or backwards / reverse during playback / reset all or selected targets / regenerate random ordering.
  Selecting a generated target row highlights the corresponding node in the preview viewport (bounds, ordered index, row/column, start offset).
  PRD3.md §18.9-§18.10.
- **Status:** backlog

### Inspector integration for node-level group motions
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  A node's Anima Inspector section may reference a group motion (e.g. a "Children Motion" field), but primary configuration stays inside the AnimaGroupMotion resource rather than duplicating every field per container.
  "Create Group Motion from Children" convenience action: creates an AnimaGroupMotion, creates a children target collection for the selected node, and opens it in the Composer.
  PRD3.md §19.
- **Status:** backlog

### Native Animation as group item motion
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  A group can apply one native Godot Animation clip to every target via a relative AnimationPlayer path resolved per target and an adapter that plays the named clip.
  PRD3.md §20.1.
- **Status:** backlog

### Static group compilation to native Animation
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  A group compiles to a native Animation when targets and ordering are statically resolvable, the item motion is compilable, and no live membership or runtime-only filters/callbacks are involved; the compiler expands the group into individual generated tracks.
  Compile report includes targets resolved, playback mode, ordering, interval, generated track count, and runtime-only event count; when it can't fully compile it reports the specific blocker (runtime-callable collection, non-deterministic random order, live membership, or a signal-wait inside the item motion).
  PRD3.md §20.2-§20.3.
- **Status:** backlog

### Group static and runtime validation
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Static: missing target collection/item motion, unresolvable explicit reference, unsupported mode, negative interval/gap, invalid or doubly-specified stagger duration, unsupported grid layout, recursive resource reference, item motion targeting a fixed external node instead of item context, non-deterministic random seed at compile time, unsupported live resolution, missing custom-ordering resource, unsupported target type, duplicate explicit targets.
  Runtime: target freed or left the tree during playback, item motion fails to resolve a property, target list changed after snapshot, inconsistent custom comparator, grid dimensions changed mid-playback, reversal requested without sufficient execution history.
  PRD3.md §21.1, §21.3.
- **Status:** backlog

### Duplicate target handling policy
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Default: deduplicate targets, keep the first occurrence, emit a warning.
  Configurable: ALLOW (the same target gets multiple item playbacks and is subject to normal property-conflict policy) / ERROR.
  PRD3.md §21.2.
- **Status:** backlog

### Group performance targets and benchmark suite
- **Type:** tech-debt
- **Source:** PRD3.md
- **Context:**
  Provisional targets: 100 ordinary UI targets with no visible scheduling hitch, 1,000 simple scalar item motions at interactive frame rates, no recurring per-frame allocation for resolution/ordering, reversal without unnecessary resource reconstruction, 500+ generated timeline rows without freezing the editor.
  Optimisation principles: resolve once per playback by default, reuse item-motion resources, allocate playback state per item only, weak target references, no per-frame membership polling unless live resolution is on.
  Benchmark matrix: 10/100/1,000/10,000 targets × sequential/parallel/staggered/reverse/random/grid-diagonal × target-removal-mid-playback × nested/spring item motions × native-compiled-output comparison.
  PRD3.md §22.
- **Status:** backlog

### Legacy group migration
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Maps legacy container groups, custom (explicit-list) groups, and grid groups onto AnimaGroupMotion with the matching target collection, order, and playback mode.
  Migration report lists resolved targets/mode/interval/order and per-item conversion result, plus warnings where legacy behaviour has no direct equivalent (e.g. a legacy group callback with no reverse action).
  Migration prioritises preserving observable timing over the cleanest new resource shape; where exact behaviour can't be inferred, it warns rather than silently changing timing.
  PRD3.md §23.
- **Status:** backlog

### Group unit test coverage
- **Type:** test
- **Source:** PRD3.md
- **Context:**
  Empty/single/multiple targets, explicit ordering, duplicate handling, sequential/parallel/stagger timing, total-duration staggering, reverse playback, random-seed determinism, grid row/column/diagonal ordering, item-context values, invalid-target policies.
  PRD3.md §26.1.
- **Status:** backlog

### Group integration test coverage
- **Type:** test
- **Source:** PRD3.md
- **Context:**
  VBoxContainer/HBoxContainer/GridContainer children, explicit unrelated nodes, targets added or removed before playback, target removed during playback, scene reload, a shared item-motion resource reused across groups, Motion Composer serialization, native Animation compilation.
  PRD3.md §26.2.
- **Status:** backlog

### Group visual demo scenes
- **Type:** test
- **Source:** PRD3.md
- **Context:**
  Sequential menu entrance, staggered button entrance, parallel card reveal, diagonal inventory grid, custom title/portrait/button group, random particle-like UI entrance, forward and backward group playback, mid-playback reversal.
  PRD3.md §26.3.
- **Status:** backlog

### AnimaMappedGroupMotion (future per-target motion mapping)
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  Deferred future resource letting different targets receive different motions (e.g. Title→title_motion, Portrait→portrait_motion, Button→button_motion), explicitly out of scope for the core AnimaGroupMotion resource — use a plain Sequence/Parallel for heterogeneous per-target motions until this exists.
  PRD3.md §5, §28.5.
- **Status:** backlog

### PRD3's suggested minimum viable Group Animation release
- **Type:** feature
- **Source:** PRD3.md
- **Context:**
  The document's own proposed first-release slice: AnimaGroupMotion, children + explicit target collections, sequential/parallel/fixed-interval-staggered modes, forward/reverse ordering, independent item playback, basic reversal, VBox/HBox/GridContainer support, code API, a basic Motion Composer group node with resolved-target preview and expandable timeline rows, and legacy migration documentation.
  Foundation-conflict note for `mano start`: this MVP list already spans PRD3.md's own §25 delivery phases 1 through 4 plus part of 6 (target collections, group playback, and Motion Composer support, which the document itself sequences as separate phases) — this tension between "minimum useful release" and the phased delivery plan is unresolved in the source and should be settled during phase scoping, not assumed either way.
- **Status:** backlog

### Anima.on() target-bound convenience API (core)
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Anima.on(target) -> AnimaTargetMotionFactory: a convenience facade that creates normal AnimaMotion resources (primarily AnimaPropertyMotion) from a target that's already bound, not a separate runtime or animation model.
  Chosen name over Anima.Node()/Anima.target()/Anima.for_node() — shorter, more readable, avoids confusion with Godot's own Node type (PRD4.md §28.2).
  Design principle: make common property animation concise and discoverable without creating a second motion architecture.
  PRD4.md §1, §3, §9.1.
- **Status:** backlog

### AnimaTargetMotionFactory
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  RefCounted factory bound to one target reference; must not hold current property selection, motion, duration, easing, playback, or velocity state.
  Safe to keep and reuse to create multiple independent motions against the same target.
  PRD4.md §9.2.
- **Status:** backlog

### Factory immutability and independent motions per call
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Every convenience property method call creates a new, independent motion; calling one method must never mutate a motion an earlier call already returned.
  During construction, fluent modifier methods may mutate the newly created motion and return self; once a motion is shared or saved it should be treated as a definition, not active runtime state (§28.4).
  PRD4.md §9.3.
- **Status:** backlog

### Canonical equivalence guarantee
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Every Anima.on() convenience call must produce a motion equivalent to the matching Motion.animate() call — no convenience-specific runtime, easing, reversal, interruption, or scheduling logic, to avoid a second motion architecture that has to stay in sync.
  Convenience methods return AnimaPropertyMotion directly (or a specialised subclass with the standard modifier API) rather than a separate convenience-builder type, where practical (§28.3).
  PRD4.md §2.4, §3, §9.4.
- **Status:** backlog

### Three-level motion-authoring hierarchy
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Level 1 Anima.on() — common/discoverable convenience. Level 2 Motion — universal property + structural API for arbitrary properties, custom scripts, and structural composition. Level 3 explicit resource classes — for the Motion Composer, compiler, migration tools, tests, and extension authors.
  All three levels must produce equivalent resources.
  PRD4.md §8.
- **Status:** backlog

### Convenience-method positional argument policy
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Convenience property methods accept only destination and an optional duration positionally; every other behaviour (starting value, ease, delay, interruption, relative mode, reverse policy, loop, completion threshold, clock) must be a named fluent modifier, never positional.
  The generic Motion.animate() accepts target/property/destination positionally instead.
  Both positional duration and .duration() are supported (§28.1) — positional for beginner examples where the named method already makes the meaning clear, .duration() when inherited defaults or advanced modifiers are being demonstrated; if both are given, .duration() wins and the editor/debug mode may warn about the redundancy.
  PRD4.md §2.2, §10.1-§10.3, §13.2.
- **Status:** backlog

### Convenience duration default and inheritance chain
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  When duration is omitted, resolution order is: motion-specific override (if supplied later) → node-behaviour default → motion-theme default → global Anima default.
  The resolved value must not be copied into the motion prematurely when inheritance is intended, so a later default change still applies.
  PRD4.md §10.4.
- **Status:** backlog

### Starting-value semantics (current-at-start vs explicit)
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Default: Anima captures the property's value at the moment that specific motion begins, not when it's authored or composed.
  .from(value) sets an explicit start instead; the target is only assigned that starting value when the property motion itself begins — never during an earlier wait/delay elsewhere in the same chain.
  PRD4.md §11.1-§11.2.
- **Status:** backlog

### Relative destination convenience methods
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  move_by(), rotate_by(), and a generic property_by() compute their destination from the property value captured when the motion begins, rather than an absolute destination.
  PRD4.md §11.3-§11.4.
- **Status:** backlog

### Reserved future starting-value modes
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Architecture should not block future start modes: value at child start, value at parent-playback start, explicit, relative-to-current, relative-to-destination, dynamic callable.
  Only current-at-start and explicit are required for the initial release.
  PRD4.md §11.5.
- **Status:** backlog

### Initial convenience property set
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  position (Control/Node2D/Node3D, Variant-typed with runtime+editor validation since GDScript can't overload cleanly), position_x/y/z (z only for 3D targets; axis methods included only where they clearly help), move_by, scale + scale_by, rotation + rotate_by (optional rotation_degrees/rotate_degrees_by only if target classes expose consistent degree-based properties).
  opacity → modulate:a (values outside 0..1 are allowed by default with a validation warning, not clamped or rejected; self_modulate:a stays out until a concrete use case justifies a second method, §28.5); colour → modulate, spelled .color() to match Godot's own Color naming (§12.7); size (Control only initially; must document container/minimum-size/anchor/layout-recalculation interaction, and steer container-controlled nodes toward Layout Transition instead, §12.8/§28.6 — the same steer applies to position on layout-owned Control properties, allowed with a validation warning rather than blocked).
  Generic .property() delegates directly to Motion.animate(); an optional shader_parameter convenience may use a dedicated adapter and may be deferred from the minimum release.
  PRD4.md §12.
- **Status:** backlog

### Motion modifiers on convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Shared modifier API: .from()/.from_current(), .duration(), .ease(), .delay(), .interruption(), .reversibility() (property motions default to automatic reversal where values/easing support it), .relative() (generic escape hatch — docs should prefer semantic methods like move_by()), .repeat()/.alternate() (exact looping API owned by the broader motion system, not this feature).
  PRD4.md §13.
- **Status:** backlog

### No implicit multi-property composition
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Chaining a second property method directly (e.g. .position().opacity()) is not supported, since the first call already returns a motion, not the factory.
  Parallel intent between two properties on the same target must be explicit via with() or Motion.parallel().
  PRD4.md §5, §14.4.
- **Status:** backlog

### Relational choreography integration for convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Motions created through Anima.on() work with then() and with() like any other motion.
  Multiple consecutive with() calls after one then() form one Parallel group of everything chained since that then(), not nested pairs.
  PRD4.md §14.1-§14.3.
- **Status:** backlog

### Group-item convenience API (Anima.item())
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Anima.item() -> AnimaItemMotionFactory: resolves its target separately per Group Animation target rather than binding one fixed node.
  Exposes the same convenience property methods as Anima.on() where meaningful: position, move_by, scale, rotation, opacity, colour, size, generic property.
  PRD4.md §15.1-§15.4.
- **Status:** backlog

### Group item context for dynamic convenience destinations
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  A convenience method's destination may be a callable receiving AnimaGroupItemContext (e.g. lerp by normalised_index) instead of a fixed value.
  May be deferred from the minimum release, but the architecture must not prevent it later.
  PRD4.md §15.5.
- **Status:** backlog

### Type validation for convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Validated when the motion is created (if target and property are already known), in the Motion Composer, before playback, during compilation, and at runtime if the target's type changed since creation.
  Type-mismatch and unsupported-target errors must name the expected type/property and suggest a fix (e.g. "use property() or select a CanvasItem target").
  PRD4.md §16.1-§16.4.
- **Status:** backlog

### Variant-typed signature compensation
- **Type:** tech-debt
- **Source:** PRD4.md
- **Context:**
  Since GDScript can't provide type-safe overloads for every supported node class, some convenience methods accept Variant.
  Compensated through documentation, runtime validation, editor warnings, and typed generated C# wrappers where practical.
  PRD4.md §16.5.
- **Status:** backlog

### Target-reference storage modes for convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  A motion created and played immediately may hold a runtime object reference; a motion saved as a resource must use AnimaTargetReference instead (explicit NodePath / relative-to-playback-root / current-context-target / current-group-item / named-target).
  Saving a motion still holding an unsafe live reference must convert it to a scene-relative reference, prompt for a resolution mode, or refuse to save — never persist a live object reference silently.
  PRD4.md §17.1-§17.3.
- **Status:** backlog

### Reserved context-target convenience (future)
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  A potential Anima.on_target()/Anima.target() API for reusable motions that target "the current playback context" rather than one fixed node.
  Explicitly overlaps conceptually with Anima.item() and needs careful naming to avoid confusion between them; not required for the initial Anima.on() release.
  PRD4.md §17.4.
- **Status:** backlog

### Motion Composer: canonical display of convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  A convenience-created motion displays its resolved target/property/from/to/duration/ease like any property motion, using the semantic convenience name (Opacity, Position, Scale, Rotation, Colour, Size) rather than only the raw property path.
  An advanced field shows the underlying Godot property path (e.g. "Underlying property: modulate:a").
  PRD4.md §18.1-§18.2.
- **Status:** backlog

### Motion Composer: round-trip editing and origin metadata
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Editing a convenience-created motion in the Composer edits the canonical resource directly; the editor is not required to regenerate the original source-code expression that created it — the resource is the shared model.
  Optional editor-only, non-runtime-affecting metadata may record which convenience call created a motion (e.g. "Created through: Anima.on().opacity()").
  PRD4.md §18.3-§18.4.
- **Status:** backlog

### Motion Composer: generic property selector
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  For generic .property() motions, the Composer offers a searchable target-property list with type information, current value, common-property shortcuts, and validation.
  PRD4.md §18.5.
- **Status:** backlog

### Native Animation compilation parity for convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  A convenience-created motion compiles identically to the equivalent explicit AnimaPropertyMotion — same property path and values, no compiler distinction between the two authoring styles.
  The compile report may retain the semantic name (e.g. "Panel opacity → modulate:a").
  PRD4.md §19.
- **Status:** backlog

### Reversal parity for convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Convenience motions use standard property reversal and easing-mirroring rules.
  A motion without an explicit .from() must record its resolved starting value so reverse playback returns to the value actually observed at start (e.g. 0.42), not an arbitrary default.
  PRD4.md §20.1-§20.2.
- **Status:** backlog

### Interruption parity for convenience motions
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Convenience motions use the standard property-ownership and interruption system exclusively — no convenience-specific interruption implementation is permitted.
  PRD4.md §20.3.
- **Status:** backlog

### Anima V1 migration for the target-bound API
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  Naming migration: Anima.Node(target) -> Anima.on(target); property-method calls migrate 1:1 where semantics are unchanged.
  Old anima_property()/anima_to()/anima_duration() chains map to a named convenience call (or Motion.animate() when no convenience method fits).
  An optional temporary Anima.Node() alias may ship with a deprecation warning, removed later per the broader compatibility policy.
  PRD4.md §21.5, §22.
- **Status:** backlog

### Getting-started and equivalence documentation
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  First tutorial example uses Anima.on().opacity().from().play(); a composition example shows then()/with(); an escape-hatch progression shows .property() then Motion.animate() for advanced/structural work.
  Explicit equivalence documentation demonstrates that Anima.on() and Motion.animate() produce the same resource, framing the levels as layered rather than competing.
  PRD4.md §21.1-§21.4.
- **Status:** backlog

### Convenience-layer performance requirements
- **Type:** tech-debt
- **Source:** PRD4.md
- **Context:**
  Must add negligible runtime overhead versus constructing the equivalent canonical motion directly: lightweight factory creation, no playback-state allocation in convenience methods, cacheable property resolution where safe, no per-frame convenience-layer logic, created motions use the normal runtime evaluator, and reusing a factory must not retain previously generated motions.
  PRD4.md §23.
- **Status:** backlog

### Convenience API unit test coverage
- **Type:** test
- **Source:** PRD4.md
- **Context:**
  Null-target rejection, correct stored target reference, independent motions from repeated calls, opacity maps to modulate:a, position resolves per target type (Control/Node2D/Node3D), scale/rotation/colour mapping, size target-support validation, generic-property delegation, duration parameter application and .duration()-overrides-positional precedence, .from() vs omitted-.from() start mode.
  PRD4.md §24.1.
- **Status:** backlog

### Convenience-vs-canonical equivalence tests
- **Type:** test
- **Source:** PRD4.md
- **Context:**
  For every convenience method, the resulting canonical resource is compared against the equivalent Motion.animate() output to catch the two APIs diverging.
  PRD4.md §24.2.
- **Status:** backlog

### Convenience API integration test coverage
- **Type:** test
- **Source:** PRD4.md
- **Context:**
  then()/with() composition, reverse playback, mid-flight retargeting, group-item usage, resource serialization, Motion Composer editing, native Animation compilation, target removal before and during playback.
  PRD4.md §24.3.
- **Status:** backlog

### Convenience API validation test coverage
- **Type:** test
- **Source:** PRD4.md
- **Context:**
  Invalid target class, invalid destination type, missing generic property, unsupported size() target, incorrect Vector2/Vector3 position type, a saved motion still holding an unsafe live target reference.
  PRD4.md §24.4.
- **Status:** backlog

### PRD4's suggested minimum viable Anima.on() release
- **Type:** feature
- **Source:** PRD4.md
- **Context:**
  The document's own proposed first-release slice: Anima.on(), reusable factory, position/move_by/scale/rotation/opacity/color/property, optional positional duration, .from()/.duration()/.ease(), then()/with() compatibility, normal reverse and interruption support, canonical-equivalence tests, and Anima.Node() migration documentation.
  Foundation-conflict note for `mano start`: this MVP list already spans PRD4.md's own §26 delivery phases 1 and 2 together, and explicitly excludes Anima.item() (deferred to ship alongside Group Animation rather than the first Anima.on() milestone) — this tension between "minimum useful release" and the phased delivery plan is unresolved in the source and should be settled during phase scoping, not assumed either way.
- **Status:** backlog

### AnimaKeyframeMotion resource
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  First-class AnimaMotion describing one or more properties at normalised offsets across a duration (CSS-inspired keyframes): Anima.on($Panel).keyframes({"from": {...}, 50: {...}, "to": {...}}).duration(0.6).
  PRD5.md §5.1-§5.2.
- **Status:** backlog

### Keyframe grouped-offset declarations
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  One declaration may target multiple offsets at once, e.g. ["from", 10]: {...} — preserved from Anima V1. Flattening/normalisation happens internally; developers never call the flattening engine directly.
  PRD5.md §5.3.
- **Status:** backlog

### Keyframe offset normalisation and parsing
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Parser must: flatten grouped offsets, validate them, normalise to 0.0-1.0 ("from"=0.0, "to"=1.0, numbers as percentages), sort them, detect duplicate property declarations at the same offset, and generate canonical keyframe tracks. Input declaration order must not determine playback order.
  PRD5.md §5.4.
- **Status:** backlog

### Multi-property keyframes with semantic names
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  One keyframe block may animate several properties at once. Convenience names resolve to canonical properties (opacity->modulate:a, position->position, scale->scale, rotation->rotation, color->modulate, size->size); arbitrary property paths are also supported directly.
  PRD5.md §5.5.
- **Status:** backlog

### Programmatic keyframe construction (Motion.keyframes())
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  A fluent alternative to the dictionary form: Motion.keyframes().at(["from", 10], {...}).at([23, 50], {...}).duration(0.6). Both forms must produce the same AnimaKeyframeMotion.
  PRD5.md §5.6.
- **Status:** backlog

### Per-segment keyframe easing and reserved metadata
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Each keyframe segment may set its own easing via a reserved key (_ease); other reserved keys are anticipated (_hold, _marker, _callback) under a clear namespace so they can't collide with real property names. Reserved metadata is stored separately from animated properties in the canonical resource.
  PRD5.md §5.7.
- **Status:** backlog

### Keyframe reversal
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Automatic reversal: keyframe order reverses, offset becomes 1.0 - original_offset, segment easing mirrors, resolved dynamic values are reused from the execution record (not recalculated). Pure property tracks reverse automatically; callback/side-effect tracks need explicit backward behaviour.
  PRD5.md §5.8.
- **Status:** backlog

### Motion Composer: keyframe editing
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Composer support for keyframe-track creation, percentage editing, multiple properties per track, per-segment easing, grouped-offset visualisation, forward/backward preview, dynamic-value indicators, loop preview, validation, and conversion between semantic and canonical property names.
  PRD5.md §5.9, §31.1.
- **Status:** backlog

### AnimaValue dynamic value resource
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  A dynamic value (AnimaValue) resolves against the current playback context: func resolve(context: AnimaValueContext) -> Variant. A motion property may accept a fixed value, an AnimaValue, or a supported callable wrapper instead.
  Preserves Anima V1's dynamic-expression capability (e.g. "-.:size:x" meaning "negative width of the current target") in typed form.
  PRD5.md §6.1-§6.2.
- **Status:** backlog

### Typed dynamic value API (Value.*)
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  The primary Anima 2 API expresses dynamic values through typed expressions, e.g. .from(Value.target(^"size:x").negative()). Works standalone and inside a Group, where each item resolves its own value independently.
  PRD5.md §6.3.
- **Status:** backlog

### Dynamic value sources
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Value.constant(), Value.target(property), Value.node(path, property), Value.root(property), Value.context(key), Value.group_index(), Value.group_count(), Value.group_normalised_index(), Value.grid_row(), Value.grid_column().
  PRD5.md §6.4.
- **Status:** backlog

### Dynamic value arithmetic composition
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Structural arithmetic chainable on a Value: add/subtract/multiply/divide/negative/absolute/minimum/maximum/clamp/map, plus vector helpers x()/y()/z()/component().
  PRD5.md §6.5.
- **Status:** backlog

### Dynamic value callable fallback
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Value.call(func(context): ...) covers calculations that can't be expressed structurally; must be marked runtime-only, potentially non-serialisable, potentially non-compilable, and potentially unavailable in editor preview.
  PRD5.md §6.6.
- **Status:** backlog

### Dynamic value resolution timing policy
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  MOTION_START (default — resolves when the specific property motion begins), PLAYBACK_START (resolves when the root playback begins, useful when later scene changes mustn't affect the value), EACH_FRAME (deferred — continuous resolution, treated as tracking/constraint motion rather than ordinary interpolation).
  PRD5.md §6.7.
- **Status:** backlog

### Dynamic values inside keyframes
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Any keyframe property value may be a dynamic Value instead of a fixed literal.
  PRD5.md §6.8.
- **Status:** backlog

### Dynamic value execution record
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  When a dynamic value resolves, Anima records the result; mid-playback reversal reuses the recorded value rather than recalculating against a target whose state may have changed. A fresh playback resolves the value again.
  PRD5.md §6.9.
- **Status:** backlog

### Legacy dynamic-value string syntax compatibility
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Legacy string expressions like .from("-.:size:x") remain available for migration, internally converted to the typed value graph (e.g. Negative(TargetProperty("size:x"))). Typed API is preferred in new documentation.
  PRD5.md §6.10, §32.2.
- **Status:** backlog

### Automatic layout transition core (Anima.layout())
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Anima.layout($Node).change(func(): ...).duration(...).play() captures the layout before and after an arbitrary mutation callback and animates the visual difference — the developer never computes old/new rectangles by hand.
  Elaborates on the original PRD.md "FLIP-style automatic layout transitions" / "Layout transition APIs" items with substantially more detail; worth reconciling when this area is phase-scoped.
  PRD5.md §7.1-§7.2.
- **Status:** backlog

### Layout transition FLIP algorithm and workflow
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  First (capture current layout) / Last (apply mutation, allow layout recalculation) / Invert (apply inverse visual transforms) / Play (animate transforms back to identity). For Control nodes, prefer visual-only transforms so the container stays authoritative.
  Full required workflow: identify affected controls, capture initial+final geometry, execute mutation, wait for recalculation, classify targets, invert, play, remove temporary state, leave nodes in their real final layout.
  PRD5.md §7.3-§7.4.
- **Status:** backlog

### Layout transition result categories
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Each affected target is classified as: unchanged, moved, resized, moved-and-resized, added, removed, reparented, or invalid.
  PRD5.md §7.6.
- **Status:** backlog

### Layout transition added/removed target handling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Added targets get an entrance motion while their final layout stays authoritative. Removed targets may need to stay visually present during exit: capture a snapshot/temporary presentation, remove the real node from layout, present it in an overlay, animate the exit, then release the temporary object.
  PRD5.md §7.7-§7.8.
- **Status:** backlog

### Layout transition reparented-target handling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  For shared nodes moving between parents: capture global geometry before and after the mutation, animate through an overlay or visual transform, preserve the final hierarchy.
  PRD5.md §7.9.
- **Status:** backlog

### Layout transition nested-container policy
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  ROOTS_ONLY / LEAVES_ONLY / SMART (recommended default) / ALL. The runtime must prevent unintended parent-child transform compounding.
  PRD5.md §7.10.
- **Status:** backlog

### Open decision: layout transition clipping policy default
- **Type:** spec-gap
- **Source:** PRD5.md
- **Context:**
  PRD5.md defines the policy options (RESPECT / OVERLAY / TEMPORARILY_DISABLE) for whether animated content is clipped by its container during a layout transition, but states no recommended default — unlike every neighbouring policy in the same section.
  PRD5.md §7.11.
- **Status:** backlog

### Layout transition mid-flight interruption
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  When another mutation occurs during an active transition: capture the current visual state as the new initial state, apply the new mutation, retarget toward the new final layout, avoid snapping to old logical endpoints. Recommended default: RETARGET.
  PRD5.md §7.12.
- **Status:** backlog

### Layout transition reversal and restoration
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  A completed transition may reverse only when initial/final snapshots remain valid, removed targets can be restored, added targets can be removed safely, and the original hierarchy can be reconstructed — otherwise Anima offers restoration/retargeting rather than claiming exact reverse support. API distinguishes playback.reverse() from playback.revert().
  PRD5.md §7.13.
- **Status:** backlog

### Layout transition group/stagger integration
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Moved or added items from a layout transition may be staggered, e.g. .stagger(0.025).stagger_order(AnimaGroupOrder.FROM_CENTER).
  PRD5.md §7.14.
- **Status:** backlog

### Motion Composer: layout transition tooling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Before/after bounds, movement paths, added/removed target markers, nested-container behaviour display, clip warnings.
  PRD5.md §31.2.
- **Status:** backlog

### Named visual states (Anima.states())
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Anima.states($Menu) lets code define named states (menu_state.define(&"open", motion)) and transition between them safely (menu_state.go(&"open")) instead of interactive UI killing an in-flight animation and losing track of the correct resulting state.
  Scope-limited: named visual states, one current + one destination state, optional explicit transitions, automatic interruption policies, AnimaBehaviour integration. Not a general gameplay state machine — nested state machines, arbitrary condition graphs, boolean expression editors, gameplay data flow, and complex transition routing are all deferred.
  PRD5.md §8.1-§8.4.
- **Status:** backlog

### Visual state transition interruption policies
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  When state changes mid-transition, Anima must determine whether to continue, reverse, retarget, replace, queue, cancel, or complete the current transition — and must define current logical state, current visual state, destination state, input availability, and completion-event behaviour.
  PRD5.md §8.3.
- **Status:** backlog

### Visual state reversal optimisation
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Anima may reverse the active transition when the graph is reversible, its endpoints match the requested states, and no irreversible side effect invalidated it — otherwise it retargets instead.
  PRD5.md §8.5.
- **Status:** backlog

### AnimaMarkerMotion and named markers
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Motion.mark(&"hit") places a semantic milestone inside a relational graph (e.g. Sequence(wind_up, Motion.mark(&"hit"), follow_through, Motion.mark(&"recovered"))); absolute timestamps are generated, never authored directly — solves gameplay logic currently tied to a hardcoded animation duration/timer.
  PRD5.md §9.1-§9.2.
- **Status:** backlog

### Marker runtime API
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  await playback.reached(&"hit"); playback.seek_marker(), play_to(), play_from(), play_between(), reverse_to() — lets gameplay code synchronise to animation milestones regardless of duration/speed/skip/reverse/interrupt/seek changes.
  PRD5.md §9.3.
- **Status:** backlog

### Marker event and direction policies
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Event policy: SUPPRESS / EMIT_CROSSED / EMIT_DESTINATION_ONLY. Direction policy: FORWARD_ONLY / BACKWARD_ONLY / BOTH. Marker events report name, direction, loop index, playback progress, and whether they were crossed via seeking or normal completion.
  PRD5.md §9.4-§9.5.
- **Status:** backlog

### Motion Composer: marker tooling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Add marker, rename marker, seek to marker, play between markers, configure direction policy.
  PRD5.md §31.3.
- **Status:** backlog

### Playback cancel/complete/revert/reverse operations
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  cancel() stops without claiming completion (keeps current visual values, cancels pending children, emits cancellation not completion, releases ownership). complete() reaches the valid final state (applies final values, resolves cleanup, processes markers, emits completion once). revert() restores the state captured before playback affected the target. reverse() plays the current execution backwards from its current progress. Reverse and revert are explicitly not equivalent.
  PRD5.md §10.1.
- **Status:** backlog

### Completion and cancellation behaviour policies
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Completion: KEEP_FINAL / RESTORE_INITIAL. Cancellation: KEEP_CURRENT (recommended default) / RESTORE_INITIAL / COMPLETE.
  PRD5.md §10.2-§10.3.
- **Status:** backlog

### Pre-animation snapshots
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Snapshots may capture property values, target identity, layout rectangle, parent, child index, visibility, focus state, and temporary presentation state. Used for reverse playback, dynamic-value reversal, revert(), layout transitions, editor preview, reduced-motion completion, and interrupted transitions.
  PRD5.md §10.4.
- **Status:** backlog

### Progress-based playback evaluation and seeking
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  playback.get_progress()/.set_progress(p)/.seek_time(s)/.animate_to_progress(p)/.seek_marker(name) — supports drag-driven interaction (e.g. a drawer that follows a pointer, then animates to the nearer end on release). Seek event policy: SUPPRESS / EMIT_CROSSED.
  PRD5.md §11.1-§11.4.
- **Status:** backlog

### Progress-driven evaluator requirement
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  The evaluator must support evaluating the motion graph at an arbitrary progress P, not depend exclusively on incrementing elapsed time — required for reversal, editor scrubbing, gesture-driven animation, native-compilation sampling, deterministic tests, manual stepping, and reduced-motion completion.
  PRD5.md §11.5.
- **Status:** backlog

### Playback clocks and manual stepping
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  AnimaClock: PROCESS / PHYSICS / UNSCALED / MANUAL. Example: .clock(AnimaClock.UNSCALED) for pause-menu animation; manual clock lets code drive playback.step(delta) directly. Recommended: the playback clock cannot change once playback has begun.
  PRD5.md §12.
- **Status:** backlog

### Forward and reverse speed multipliers
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Every motion and playback may define forward_speed/reverse_speed (default 1.0), e.g. an opening motion at 1.0x and its structural reverse (closing) at 1.5x, without duplicating the motion or hand-adjusting durations. A playback may also set a general .speed() multiplier affecting both directions.
  PRD5.md §13.1-§13.3.
- **Status:** backlog

### Effective speed calculation model
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  effective speed = scope speed x playback speed x parent motion speed x local motion speed x direction speed. Authored duration itself never changes — speed is a playback multiplier, not a destructive edit to the motion definition. Implementations may simplify how many levels are exposed initially, but the model stays consistent.
  PRD5.md §13.4-§13.5.
- **Status:** backlog

### Speed and direction kept as separate concepts
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Negative speed must never be used to reverse playback (speed values must stay greater than zero); direction is switched via reverse(), pacing via set_speed(). Mid-flight direction changes preserve current progress exactly, change direction and reverse speed immediately, don't snap values, don't re-resolve dynamic values, and reschedule pending structural events backwards while keeping execution history valid.
  PRD5.md §13.6-§13.7.
- **Status:** backlog

### Group speed scaling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  A group's speed multiplier scales its entire generated schedule together — item-motion durations, stagger intervals, sequential gaps, delays, marker timing, and generated start offsets — as one coherent schedule, not independently. Target order still follows the group's reverse-order policy.
  PRD5.md §13.8.
- **Status:** backlog

### Nested speed multiplier composition
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Speed multipliers at different levels (item motion, group, playback) compose multiplicatively (e.g. 1.2x item x 1.5x group = 1.8x effective) — the Motion Inspector must show how the final value was produced.
  PRD5.md §13.9.
- **Status:** backlog

### Spring simulation speed scaling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Timeline-based easing scales directly through time; physical springs instead scale simulation delta (frame delta x effective speed) to preserve authored spring characteristics while changing real-time duration. Physical retargeting (retarget_to_start()) stays distinct from exact timeline reversal (reverse_timeline()).
  PRD5.md §13.10.
- **Status:** backlog

### Speed effect on markers
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Speed changes affect when a marker is reached in real time, but never marker order, identity, direction policy, or position within the authored graph.
  PRD5.md §13.11.
- **Status:** backlog

### Manual stepping respects effective speed
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  evaluated delta = supplied manual delta x effective speed.
  PRD5.md §13.12.
- **Status:** backlog

### Reduced-motion speed override
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Reduced-motion policy may override speed by completing immediately, selecting a simpler motion, removing stagger, or applying a dedicated reduced-motion speed.
  PRD5.md §13.13.
- **Status:** backlog

### Motion Composer and Inspector: speed tooling
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Composer: forward-speed field, reverse-speed field, general preview-speed control, effective forward/reverse duration, forward/backward preview, mid-playback reverse, optional direction-speed visualisation. Inspector: full breakdown (authored duration, local/parent/playback speed, direction, reverse multiplier, effective speed, estimated remaining duration).
  PRD5.md §13.14-§13.15, §31.4.
- **Status:** backlog

### Lifecycle-safe playback policies
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Recommended defaults: target freed -> cancel affected motion safely; playback root freed -> cancel whole playback; target hidden -> continue; scene tree paused -> follow selected clock; target reparented -> continue if references remain valid; layout target removed -> follow layout-exit policy.
  PRD5.md §14.1-§14.2.
- **Status:** backlog

### Playback cleanup requirements on cancellation
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Cancellation must disconnect signals, release property ownership, stop pending callbacks, release layout overlays, clear runtime records, and emit exactly one terminal result.
  PRD5.md §14.3.
- **Status:** backlog

### Live Motion Inspector
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Debug panel exposing per-playback: hierarchy, active motion, target, property, current/starting/destination value, velocity, progress, direction, clock, effective speed, authored+effective duration, owner, interruption policy, dynamic-value expression and resolved value, group item index, layout source, captured snapshot, previous owner, conflict resolution, marker history.
  PRD5.md §15.1, §15.3.
- **Status:** backlog

### Property conflict report
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  When two motions target the same property, a report names the target, property, existing motion, incoming motion, and the resolution applied (e.g. REPLACE).
  PRD5.md §15.2.
- **Status:** backlog

### Debug tracing overhead controls
- **Type:** tech-debt
- **Source:** PRD5.md
- **Context:**
  Tracing must be optional: disable entirely, enable globally, enable per-playback, limit history size, and strip tracing from production exports.
  PRD5.md §15.4.
- **Status:** backlog

### Reduced-motion policy and alternatives
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Policy: FULL / SHORTEN / SIMPLIFY / COMPLETE_IMMEDIATELY / CUSTOM. A motion may declare motion.reduced_motion(alternative_motion) — e.g. full motion slides+scales+fades, reduced motion just fades.
  Elaborates on the original PRD.md's "Per-motion reduced-motion alternatives" / "Global reduced-motion setting" items; worth reconciling when this area is phase-scoped.
  PRD5.md §16.1-§16.2.
- **Status:** backlog

### Safe completion when motion is skipped
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  When skipped or completed immediately: final visual values must be applied, layout state committed, temporary nodes cleaned up, focus and input state correct, marker policy respected, completion emitted exactly once.
  PRD5.md §16.3.
- **Status:** backlog

### Reduced-motion group and layout behaviour
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Reduced-motion mode may remove staggering, reduce movement distance, replace movement with opacity, complete layout movement immediately, and must preserve enter/exit visibility semantics regardless.
  PRD5.md §16.4.
- **Status:** backlog

### Eased group-stagger distribution
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Group start offsets can follow an easing curve across the distribution instead of a flat interval: .stagger_across(0.4).origin(AnimaGroupOrigin.CENTER).distribution(Ease.out_cubic()). start offset = distribution_ease(normalised rank) x total stagger duration.
  PRD5.md §17.1-§17.2.
- **Status:** backlog

### Open decision: group-stagger origin default
- **Type:** spec-gap
- **Source:** PRD5.md
- **Context:**
  PRD5.md defines the stagger-distribution origin options (FIRST / CENTER / LAST / INDEX / POINT) but states no recommended default — unlike most other enums in this document.
  PRD5.md §17.3.
- **Status:** backlog

### Equal-rank stagger waves
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Items sharing the same ordering rank (e.g. equidistant from a stagger origin) start together as one wave, supporting ripple effects without manually building parallel subgroups.
  PRD5.md §17.4.
- **Status:** backlog

### Stagger reverse-distribution behaviour
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Reverse distribution must reuse the target order and ranks resolved for the current execution; random order must not be regenerated on reversal.
  PRD5.md §17.5.
- **Status:** backlog

### Example and showcase design principles
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  The example project is a product surface, not an afterthought. Every example must be understandable within seconds, focused on one primary capability, attractive, reproducible (deterministic under a fixed seed), inspectable, interactive where relevant (play/pause/reverse/speed/scrub/reduced-motion/interrupt/debug/reset), loopable where the feature naturally allows it, and honest (never implies functionality that depends on unreleased or private code).
  PRD5.md §18.1-§18.2, §3.5.
- **Status:** backlog

### Example project tiers
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Tier 1 minimal (one API, short script, regression test); Tier 2 practical game-UI scenarios (e.g. inventory sorting, interruptible pause menu, drag-driven drawer); Tier 3 showcase scenes (visually elaborate, multiple mature features together, still public-API-only). Every capability needs at least one minimal example and may have a showcase (see the selection matrix, PRD5.md §25).
  PRD5.md §18.3.
- **Status:** backlog

### Proposed 2D showcase scenes
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  Grid Bloom (grid groups + from-point ordering + eased stagger + dynamic values + reverse speed), Responsive Inventory (layout transitions + sorting + column changes + interruption retargeting), Elastic Menu (named states + mid-flight reversal + separate forward/reverse speed + conflict handling), Card Cascade (custom groups + eased distribution + dynamic per-item values), Kinetic Typography (keyframes + group ordering + markers + seamless loop), Signal Strike (markers + awaitable milestones + speed/reverse), Infinite Conveyor (groups + relative movement + deterministic looping).
  PRD5.md §19.
- **Status:** backlog

### Proposed 3D showcase scenes
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  3D examples only where they show behaviour meaningfully different from 2D. Kinetic Totems (3D group animation + spatial ordering + eased stagger), Orbiting Crystals (progress-driven motion + scrubbing), Satisfying Assembly (relational sequence/parallel + markers + group waves), Spatial Ripple (spatial group ordering + distance-based timing, captured point not a continuous Motion Field), Camera Portal (only once camera/3D property support is stable).
  PRD5.md §20.
- **Status:** backlog

### Oddly-satisfying loop requirements
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Loops serve landing pages, docs, social posts, and force the runtime to prove it handles repeated playback without drift/leakage. A loop is appropriate when the end state naturally returns to the start and reverse playback is meaningful. Patterns: forward-hold-reverse, ping-pong, circular, state-cycle. Quality bar: same visual+logical end state, no drift/duplicated callbacks/retained nodes/unintended random-order changes/boundary jumps, repeatable 100+ cycles, recommended 4-12s duration.
  PRD5.md §21.
- **Status:** backlog

### Example scene interaction shell
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  A shared, reusable UI shell for practical/showcase scenes: play/pause/reverse/restart/complete/revert, progress slider, playback/forward/reverse speed, reduced motion, debug overlay, loop toggle; displays feature name, direction, progress, effective speed, state, active marker. Must be hideable for clean showcase footage capture.
  PRD5.md §22.
- **Status:** backlog

### Example scene contract
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Every maintained example needs: a .tscn, a minimal controlling script, reusable .tres motion resources, a short README, a feature list, interaction instructions, a deterministic reset path (reset_demo()), a known loop duration where applicable, a fixed random seed where randomisation is used, at least one automated smoke/integration test, a capture manifest, and asset licensing info. Looping examples also expose play_showcase_loop().
  PRD5.md §23.
- **Status:** backlog

### Example artifact categories and structure
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Three artifact categories: source (the primary artifact — scenes, motion resources, scripts, README), presentation (derived — master video, seamless loop, GIF, poster, thumbnails, crops, screenshots), and verification (expected snapshots, loop-boundary comparison, progress checkpoints, performance measurements, marker logs, seed, compatibility metadata). One showcase scene should generate every downstream output (example content, docs, README animation, social crops, benchmark, regression test) rather than maintaining separate one-off assets per surface.
  PRD5.md §24.1-§24.3, §24.6.
- **Status:** backlog

### Deterministic showcase capture pipeline
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Every showcase declares a capture manifest (scene path, loop duration, warm-up, resolution, frame rate, camera, seed, overlay visibility, background, crop, poster-frame time, reduced-motion variant). A shared capture controller resets the scene, applies the fixed seed and requested speed, disables interactive overlays, waits through warm-up, starts at a known progress, runs a known duration, and stops exactly on the loop boundary. Supported aspect ratios: 16:9, 1:1, 9:16, 4:3 — important content stays inside a safe central area.
  PRD5.md §24.7-§24.10.
- **Status:** backlog

### Showcase asset and maintenance policy
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Showcase assets should prefer Godot primitives, procedural shapes, and clearly-licensed original/third-party material — never assets that can't be redistributed. Every example records its feature owner, last-verified Anima/Godot version, capture version, and known limitations; when an API changes, examples and derived artifacts are regenerated from source, not manually patched.
  PRD5.md §24.11-§24.12.
- **Status:** backlog

### Motion Composer: showcase capture mode
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  An optional capture mode (Composer or example shell) hides editor-only overlays, resets the motion, selects a fixed seed, runs exactly one loop at a configured preview speed, and stops at the defined boundary. Optional for the first Composer release but should be supported by shared example tooling regardless.
  PRD5.md §31.6.
- **Status:** backlog

### Showcase acceptance criteria
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  A showcase is ready when its primary capability reads within 5 seconds, the source uses only public APIs, it resets deterministically, it survives repeated runs without state leakage, it ships a README and a committed capture manifest, it produces a clean master plus at least one documentation and one social-ready artifact, it passes loop/final-state validation, it avoids unredistributable assets, and it runs on the currently supported Godot version.
  PRD5.md §26.
- **Status:** backlog

### Additive motion layers (architectural preparation)
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Not part of the immediate implementation scope, but the central evaluator must not permanently assume "one property = exactly one possible contribution" — the initial implementation may still enforce one replacing owner, but the contribution system stays encapsulated so additive/multiply blend modes (REPLACE/ADDITIVE/MULTIPLY) can be added later (e.g. layered interaction + feedback offsets) without a rearchitecture.
  PRD5.md §27.
- **Status:** backlog

### Motion Fields (deferred future concept)
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  A future Group Animation capability calculating per-target influence (0.0-1.0) from a spatial falloff (e.g. Anima.field().circle(pointer_position, 180.0).falloff(Ease.out_cubic())), applicable to delay/scale/opacity/position/rotation/colour/spring-strength/speed. Not part of the current committed roadmap — depends on group target resolution, dynamic values, spatial ordering, progress evaluation, and runtime inspection all being stable first.
  PRD5.md §28.
- **Status:** backlog

### Compiler support for advanced motion types
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Static keyframe motions compile to native Animation tracks. Dynamic values compile when targets are statically resolvable and resolution doesn't depend on runtime-only context (otherwise the compiler reports runtime evaluation). Mutation-based layout transitions are generally runtime-driven (captured static transitions compilable later, not required initially). Markers may compile to method tracks, metadata, or runtime marker adapters, preserving semantics or reporting loss. Authored forward/reverse speed is retained in Anima metadata even though a baked native animation captures only one direction unless separate forward/backward variants are output.
  PRD5.md §30.
- **Status:** backlog

### Motion Composer: snapshot inspection
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Inspect captured property values, captured layout, logical value, visual value, and a restore preview for any pre-animation snapshot.
  PRD5.md §31.5.
- **Status:** backlog

### Migration requirements for advanced motion features
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  Existing flattened keyframe data migrates to AnimaKeyframeMotion. Existing dynamic-value string expressions continue through a compatibility parser or convert to typed value graphs; per-item group/grid resolution must be preserved. Converted keyframe/dynamic-value motions require reversibility validation. Representative V1 examples are recreated (not copied), each documenting the V1 capability, its Anima 2 equivalent, any intentional API change, any behavioural improvement, and any unsupported legacy behaviour.
  PRD5.md §32.
- **Status:** backlog

### Performance requirements for advanced motion features
- **Type:** tech-debt
- **Source:** PRD5.md
- **Context:**
  Keyframes: cache normalised/sorted tracks, don't rebuild per frame, evaluate only active properties. Dynamic values: resolve once per timing policy, avoid repeated path parsing, cache validated accessors. Layout: capture only relevant controls, avoid recurring allocations, pool overlays, support 100+ moving UI items without a visible hitch. Seeking: repeated scrubbing must not reconstruct the full graph each time. Speed: changes must not rebuild the authored graph; direction changes reuse existing definitions/execution records. Showcases: profile with tracing on/off, normal/max speed, and repeated loop playback — polish must not hide poor runtime performance.
  PRD5.md §33.
- **Status:** backlog

### Test coverage: keyframes and dynamic values
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  Keyframes: from/to, grouped offsets, unsorted declarations, duplicate offsets, multiple properties, segment easing, forward/reverse playback, native compilation. Dynamic values: target property, relative node, context value, arithmetic, group per-item resolution, motion-start vs playback-start resolution, reverse reuses recorded values, legacy string parsing.
  PRD5.md §34.1-§34.2.
- **Status:** backlog

### Test coverage: layout transitions
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  VBox expansion, HBox reordering, grid sorting, column changes, added item, removed item, reparenting, nested containers, clipping, mid-flight mutation, revert, reduced-motion completion.
  PRD5.md §34.3.
- **Status:** backlog

### Test coverage: markers
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  Forward crossing, backward crossing, seek policies, loop markers, completion crossing, cancellation before marker, speed changes before marker.
  PRD5.md §34.4.
- **Status:** backlog

### Test coverage: speed multipliers
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  Default speed, general playback speed, forward speed, reverse speed, mid-flight reversal, nested speed multiplication, group stagger scaling, sequential-gap scaling, marker timing, manual stepping, spring simulation speed, invalid zero/negative speeds, reduced-motion override.
  PRD5.md §34.5.
- **Status:** backlog

### Test coverage: showcase loop determinism
- **Type:** test
- **Source:** PRD5.md
- **Context:**
  Initial/final logical state equality, initial/final visual state equality, no callback duplication, no temporary-node leakage, no random-order change with a fixed seed, no visible boundary jump, one hundred consecutive loops, capture duration matches the manifest.
  PRD5.md §34.6.
- **Status:** backlog

### PRD5's delivery-phase roadmap (Phases A-G)
- **Type:** feature
- **Source:** PRD5.md
- **Context:**
  The document's own proposed sequencing: A keyframes+dynamic values, B playback safety+speed foundation, C markers+gameplay integration, D automatic layout transitions, E group distribution+production tooling, F visual states, G example/showcase project (recommended to start early, incrementally, and never block runtime foundations).
  Foundation-conflict note for `mano start`: this phasing is independent of PRD.md's own Phase-1 runtime work and PRD3/PRD4's Group/Anima.on() phasing — all four documents' delivery suggestions will need reconciling against each other during phase scoping, not assumed compatible by default.
  PRD5.md §35.
- **Status:** backlog

### Documentation missing for Phase 1 classes
- **Type:** bug
- **Source:** Phase 1 review
- **Context:**
  Phase 1 shipped without developer documentation for any of its new classes: AnimaMotion, AnimaSequence, AnimaParallel, AnimaPropertyMotion, AnimaEase, AnimaPlayback, AnimaRuntime, Anima, AnimaMotionInstance, AnimaPropertyMotionInstance, AnimaSequenceInstance, AnimaParallelInstance.
  Needs a doc page for each once the documentation-page rule exists (see "Documentation page convention for new classes").
- **Status:** resolved

### Delete stale v1 documentation
- **Type:** bug
- **Source:** Phase 1 review
- **Context:**
  Existing documentation describes the legacy v1 classes (addons/anima/core, utils, animations) that were deleted from the repo during Phase 1.
  That documentation is now stale/dangling and should be deleted.
- **Status:** resolved

### Documentation page convention for new classes
- **Type:** rule-gap
- **Source:** Phase 1 review
- **Context:**
  Every new Anima class needs a doc page (front-matter + Overview/Inheritance/Quick example/Properties/Methods/Signals/Enums/Constants/Complete example/Interruption/Reduced motion/Determinism/Performance/Limitations/Related API/Source), written for developers with zero prior Godot/coding experience.
  No rule currently requires or shapes this.
  Full template supplied during Phase 1 review; also see v2_stuff/doc.example.md.
- **Status:** resolved

### Guides, tutorials, and features docs for the final v2 API
- **Type:** feature
- **Source:** User idea (Phase 2 scoping)
- **Context:**
  Once the v2 API is more complete, write new guides/tutorials/features documentation (fundamentals, reusable animations, multiple animations, dynamic values, relative motion, keyframes, etc.) based on the final API and code.
  Replaces the v1-based guides/tutorials/features content deleted in Phase 2.
- **Status:** backlog

### Basic example scene for relational composition
- **Type:** feature
- **Source:** User idea (Phase 3 scoping)
- **Context:**
  A Godot scene demonstrating the composition types built in this phase (Sequence, Parallel, Stagger, Repeat, Race, Conditional) running via Anima.play(), watchable and runnable in the editor.
  Proves the phase's exit criteria visually, distinct from GUT tests which only prove logical correctness.
- **Status:** resolved

### Relationship timing: spring/marker/signal completion thresholds
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  The deferred completion-threshold variants from relationship timing: spring-settled, visually-settled, named-marker, and signal thresholds.
  Extends the relationship-timing-modifiers item once spring easing, markers, and the signal-wait leaf type exist.
  PRD.md §10.4.
- **Status:** backlog

### Duration model: editor visual distinction
- **Type:** feature
- **Source:** PRD.md
- **Context:**
  The Motion Composer must visually distinguish duration kinds (solid bar / striped-or-faded / dashed open-ended / continuation arrow).
  Extends the duration-model item once the Motion Composer exists.
  PRD.md §11.
- **Status:** backlog
