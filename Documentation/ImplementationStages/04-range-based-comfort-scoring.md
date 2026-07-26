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

## Internal range representation

Keep `ComfortRange` as the public Codable model. Add an internal range-validation
helper in `ComfortScorer.swift` with this responsibility:

```swift
private enum ComfortRangeKind {
    case temperature
    case relativeHumidity
    case dewPoint
}

private func validatedClosedRange(
    _ range: ComfortRange,
    field: String,
    kind: ComfortRangeKind
) throws -> ClosedRange<Double>
```

The helper validates finite bounds, strict ordering, and the domain rules for
the selected kind before constructing `range.minimum...range.maximum`. All
scoring penalty functions consume the returned `ClosedRange<Double>` and use
`lowerBound`, `upperBound`, and `contains(_:)`. Never construct a
`ClosedRange<Double>` from unvalidated caller data.

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
   Implement `validatedClosedRange(_:field:kind:)` so every malformed range
   throws `.invalidComfortRange` before `ClosedRange<Double>` construction.
7. Refactor the three piecewise calculations into focused internal functions
   that consume validated `ClosedRange<Double>` values; keep `score` as the only
   public scoring entry point.

## Acceptance criteria

- Lower scores consistently mean closer to the selected comfort ranges.
- Every boundary follows the inclusive/exclusive rules in the specification.
- RH and dew-point modes can produce different scores for identical conditions.
- Invalid settings throw typed errors and are never silently normalized.
- Public Codable settings retain the `ComfortRange` JSON shape while scoring
  internals use `ClosedRange<Double>`.
- No `ClosedRange<Double>` is constructed before its source bounds pass
  validation.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add configurable comfort scoring`

