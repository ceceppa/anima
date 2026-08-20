# Phase Review — [Project Name]

<!-- Always append new phase entries at the bottom of the file. Never insert between existing entries. -->
<!-- For follow-up fix work on an already-reviewed phase, append an ### Addendum subsection to the existing phase entry — do not create a new ## heading. -->
<!-- If you seed `_mano_output/reviews.md` from this file, keep the title and append real entries. Do not copy the example phase sections below as placeholders. -->

---

<!-- Default: `## Phase [N] Review — [Date]`
Owner opt-in: `## Phase [N] Review — Owner: [owner-slug] — [Date]` -->
## Phase [N] Review — [Date]

### Validation

- **Result:** [what happened, or `Not tested`]
- **Checked with:** [where or how the human checked it]
<!-- Omit `Checked with` when the human did not supply it. -->

### Phase checks

<!-- One row per Exit Criterion leaf, at the brief's own address. `signed off` is a criterion the human closed without reporting on — the ledger records the same attestation against it. -->

| # | Phase promise | Result | What happened |
|---|---|---|---|
| [E1a] | [Exit Criterion leaf] | passed / failed / not tested / signed off | [concrete result, or `Not tested`] |

### Questions

<!-- One row per Validation Plan question, at the brief's own address. Omit this section only when the brief has no Validation Plan. -->

| # | Question | Answer |
|---|---|---|
| [Q1] | [the question as the brief states it] | [what the human answered, or `unanswered at close`] |

### Decision

- **Choice:** [human choice, `Not enough evidence`, or `Not assessed`]
- **Why:** [stated reason, or a stated result that directly supports the choice]
<!-- Omit `Why` when the human supplied no reason. -->

### Assumptions

<!-- `accepted` is an assumption the human did not rule on and closed the phase on anyway. `inconclusive` is one they say they still cannot call. -->

| # | Assumption | Result | What showed this |
|---|-----------|---------|------------------------|
| [A1] | | confirmed / invalidated / inconclusive / accepted | |

### Backlog changes

- [Type] [Exact title] — [why it was added or rejected]
<!-- Write `None` when the review changed no backlog items. -->

### What we learned

<!-- Optional. Omit this entire section unless a reusable, surprising lesson changes future work. Name its destination when known. -->
- [Lesson] — [future decision, rule, or artifact it changes]

### Addendum — [Date]

<!-- Only present if follow-up fix work was reviewed after the main review. Append here; do not create a new ## Phase heading. -->

#### Validation

- **Result:** [what happened, or `Not tested`]
- **Checked with:** [where or how the human checked it]
<!-- Omit `Checked with` when the human did not supply it. -->

#### Decision update

- **Choice:** [changed choice, `Unchanged`, `Not enough evidence`, or omit this section]
- **Why:** [stated reason, or a stated result that directly supports the choice]
<!-- Omit `Why` when the human supplied no reason. -->

#### Outcome changes

- [Resolved, still open, new, or rejected backlog outcome]
<!-- Write `None` when the follow-up changed no outcomes. -->
