# Session 6: Candidate Generation and Recommendation Selection

**Time box:** 45–60 minutes  
**Depends on:** Sessions 2–5  
**Outcome:** Internal domain logic deterministically selects the best action from
the five candidate durations.

## Files in scope

```text
Sources/VentilationAdvisor/Advisor/VentilationCandidate.swift
Sources/VentilationAdvisor/Advisor/VentilationCandidateSelector.swift
Tests/VentilationAdvisorTests/CandidateSelectionTests.swift
```

The candidate and selector types remain internal and are tested with
`@testable import VentilationAdvisor`.

## Red-green-refactor sequence

1. RED: generate candidates and assert minutes are exactly
   `[5, 10, 15, 30, 60]` in ascending order.
2. RED: for `.closed`, compare candidates with public predictor results using
   `.open`; for each non-closed state, verify its own ACH is retained.
3. RED: provide a strictly better lowest score and expect `.openWindows` from a
   closed state and `.keepWindowsOpen` from a non-closed state.
4. RED: provide equal or worse scores and expect `.keepWindowsClosed` or
   `.closeWindows`, respectively.
5. RED: give two candidates identical scores and assert the earlier/shorter
   candidate wins.
6. RED: verify `.keepWindowsClosed` uses the best rejected candidate's
   prediction and score but returns zero recommended minutes.
7. RED: verify `.closeWindows` uses current conditions/current score and zero
   minutes rather than the rejected continued-ventilation prediction.
8. Refactor selection from candidate construction so Session 7 can apply the
   stale-air override without changing base score ordering.

## Acceptance criteria

- Strictly lower means improvement; equality never opens windows for comfort.
- Candidate tie behavior is stable and independent of collection implementation.
- Rejected-candidate output follows the two distinct specification rules.
- No stale-air override or user-facing text exists yet.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: select ventilation recommendations`

