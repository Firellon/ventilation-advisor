# Session 8: Advisor Composition and Golden Tests

**Time box:** 45–60 minutes  
**Depends on:** Sessions 2–7  
**Outcome:** The complete public advisor composes the tested components and
passes end-to-end golden cases.

## Files in scope

```text
Sources/VentilationAdvisor/Advisor/VentilationAdvisor.swift
Tests/VentilationAdvisorTests/VentilationAdvisorGoldenTests.swift
README.md
```

## Interface delivered

```swift
public struct VentilationAdvisor: Sendable {
    public init()
    public func assess(_ input: VentilationInput) throws -> VentilationAdvice
}
```

## Red-green-refactor sequence

1. RED: add the cooler/drier standard case and expect `.openWindows`, 30 minutes,
   score improvement, predicted physical values within tolerance, and the
   cooler/lower-dew-point reason.
2. GREEN: compose validation, dew-point resolution, current scoring, candidate
   generation, selection, explanation, and advice mapping through `assess`.
3. RED: add hot/humid closed conditions and expect `.keepWindowsClosed`, zero
   minutes, the five-minute rejected prediction, and the tied/no-improvement
   category.
4. RED: add four-hours-stale closed conditions and expect `.openWindows`, five
   minutes, and the fresh-air category.
5. RED: add hot/humid already-open conditions and expect `.closeWindows`, zero
   minutes, and current values as the prediction.
6. RED: assess 29 C / 45% RH indoors and 24 C / 70% RH outdoors under standard RH
   settings and under 5...15 C dew-point settings; expect 30 and 15 minutes.
7. RED: verify all deltas and `scoreDelta = currentScore - predictedScore`.
8. RED: decode a complete JSON input, assess it, encode advice, and verify the
   documented interchange keys and enum values.
9. Refactor only orchestration duplication; do not expand the public API.

## Final verification

- Run `swift build` and `swift test` from a fresh invocation.
- Confirm recommendation/minutes exactly, scores within `0.01`, and physical
  values within `0.1` across golden cases.
- Run `git diff --check` and search public Swift sources for `Int64`.
- Compare implementation against every MUST/MUST NOT in the technical
  specification.
- Update README status from specification-first to implemented only after all
  verification succeeds.

## Acceptance criteria

- `VentilationAdvisor.assess(_:)` is the complete public orchestration API.
- All required golden cases pass using real components without mocks.
- No platform, networking, persistence, sensor, or UI dependency is present.
- All public integer fields use `Int`.
- Full build and test output is warning-free.

**Commit:** `feat: complete ventilation advisor engine`

