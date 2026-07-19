# Session 4: Range-Based Comfort Scoring

**Time box:** 45–60 minutes  
**Depends on:** Sessions 2–3  
**Outcome:** Consumers can score conditions against custom temperature and RH or
dew-point ranges.

## Files in scope

```text
Sources/VentilationAdvisor/Science/ComfortScorer.swift
Tests/VentilationAdvisorTests/ComfortScorerTests.swift
```

## Interface delivered

```swift
public enum ComfortScorer {
    public static func score(
        temperatureC: Double,
        relativeHumidityPercent: Double,
        dewPointC: Double,
        settings: ComfortSettings
    ) throws -> Double
}
```

## Red-green-refactor sequence

1. RED: test zero temperature penalty inside 18...24, a cold value below 18,
   and the exact upper breakpoints 28 and 32. Implement the four temperature
   segments from the specification.
2. RED: use dew-point settings 5...15 and test below 5, inside the range, at 17,
   at 20, and above 20. Implement the four dew-point segments.
3. RED: use RH settings 40...60 and test below 40, inside the range, at 70, at
   85, and above 85. Implement the four RH segments.
4. RED: verify the selected humidity metric is the only humidity penalty used by
   holding conditions constant and switching metric/range.
5. RED: verify combination weights immediately below, at, and above maximum
   accepted temperature +2 and +8.
6. RED: cover non-finite conditions, invalid temperature/RH values, reversed or
   equal ranges, out-of-domain ranges, and nonpositive fresh-air intervals.
7. Refactor the three piecewise calculations into focused internal functions;
   keep `score` as the only public scoring entry point.

## Acceptance criteria

- Lower scores consistently mean closer to the selected comfort ranges.
- Every boundary follows the inclusive/exclusive rules in the specification.
- RH and dew-point modes can produce different scores for identical conditions.
- Invalid settings throw typed errors and are never silently normalized.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add configurable comfort scoring`

