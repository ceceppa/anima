# Progress — Anima — Phase 20

<!-- mano-progress: v2 -->
<!-- contract: 6d465eb3cb0a4aa8 -->

## Scope

| # | What | Status |
|---|------|--------|
| S1a | Playground navigation and consistency — Demo selector | done |
| S1a+1 | each playground must have a "go back" button in the header to return to… | done |
| S1b | Playground navigation and consistency — Consistent scaling across playgrounds | done |

## Exit Criteria

| # | Criterion | Status |
|---|-----------|--------|
| E1a | Demo selector — Open the playground: a 2D/3D selector is visible | met |
| E1a+1 | Open any existing playground demo: a "go back" button in the header ret… | met |
| E1b | Demo selector — Select 2D: only 2D demos are shown | met |
| E1c | Demo selector — Select 3D: only 3D demos are shown | met |
| E2a | Consistent scaling — Open any existing playground demo on a high-DPI display: it renders at the same relative size and clarity as the others | met |
| E2b | Consistent scaling — Compare two different playground demos side by side at a non-default display scale: their scaling behaves identically | met |

## Row Contracts

### S1a+1
affects: E1a+1

```text
each playground must have a "go back" button in the header to return to demo selector
```

### E1a+1
```text
Open any existing playground demo: a "go back" button in the header returns to the demo selector.
```

### E2a
reason: Verifying that the running example actually renders at the correct, matching scale on a real high-DPI display is an experiential/visual check — this headless CI environment has no real display to report a non-1.0 scale from, so the display_scale > 1.0 branch in HiDPIScale.apply_to() cannot be honestly exercised here. The extraction itself is covered: HiDPIScale.test.gd verifies the normal-density (1.0) branch leaves the window's content_scale_factor unchanged, and the full existing test suite (including every playground scene) still passes after the refactor, confirming no regression. A human should confirm on an actual HiDPI display that every playground scene (including the new Demo Selector) renders at a consistent, correctly-scaled size.
provenance: human sign-off at review, 2026-08-21

### E2b
reason: Verifying that the running example actually renders at the correct, matching scale on a real high-DPI display is an experiential/visual check — this headless CI environment has no real display to report a non-1.0 scale from, so the display_scale > 1.0 branch in HiDPIScale.apply_to() cannot be honestly exercised here. The extraction itself is covered: HiDPIScale.test.gd verifies the normal-density (1.0) branch leaves the window's content_scale_factor unchanged, and the full existing test suite (including every playground scene) still passes after the refactor, confirming no regression. A human should confirm on an actual HiDPI display that every playground scene (including the new Demo Selector) renders at a consistent, correctly-scaled size.
provenance: human sign-off at review, 2026-08-21
