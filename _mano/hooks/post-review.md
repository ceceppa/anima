# post-review hook

## Mode
check

## Inputs
- `_mano_output/reviews.md`
- `_mano_output/backlog.md`
- the exact `BRIEF` path from the state projection

## Checklist

- Classify the phase by substance, not terminology. A newly implemented or changed developer-facing capability counts as an API or function for these checks even when the brief or review calls it a feature, behaviour, visual feature, motion, demo, or scenario. Do not require the artifacts to use the words "API", "function", or "high risk". Exclude it only when the brief or review explicitly establishes that no developer-facing interface was added or changed.
- Treat positive manual or visual validation as evidence that the capability works when the review confirms the intended behaviour and the relevant exit criteria, validation questions, or assumptions. Do not dismiss that evidence merely because validation happened through a demo or visual scenario.
- When this review positively validates a newly implemented or changed developer-facing capability, the high-risk feasibility exception ends: the review suggests follow-up documentation appropriate to the validated code, such as public API comments and reference documentation or developer-facing implementation notes. No documentation follow-up is required while feasibility remains negative or inconclusive.
- When this review positively validates a newly implemented or changed developer-facing capability, the review suggests a follow-up tutorial explaining how to build or use it. If the validation phase produced an example or demo containing code, that tutorial explains the example or demo rather than leaving it unexplained. No tutorial follow-up is required while feasibility remains negative or inconclusive.
- Existing unresolved documentation or tutorial backlog items do not justify omitting the follow-up from the review: reference the existing items instead of creating duplicates. A review that records "Backlog changes: None" without mentioning those applicable items fails this check.
