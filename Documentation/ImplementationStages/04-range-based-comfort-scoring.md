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
import Foundation

public enum ComfortScorer {
    public static func score(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double,
        dewPoint: Measurement<UnitTemperature>,
        settings: ComfortSettings
    ) throws -> Double
}
```

## Internal range representation

Keep `TemperatureRange` and `RelativeHumidityRange` as public Codable models.
Add internal range-validation helpers in `ComfortScorer.swift`:

```swift
private enum TemperatureRangeKind {
    case temperature
    case dewPoint
}

private func validatedTemperatureRange(
    _ range: TemperatureRange,
    field: String,
    kind: TemperatureRangeKind
) throws -> ClosedRange<Double>

private func validatedRelativeHumidityRange(
    _ range: RelativeHumidityRange,
    field: String
) throws -> ClosedRange<Double>
```

The temperature helper validates supported units and finite values, normalizes
both bounds to Celsius, validates strict ordering and the selected domain, and
only then constructs a `ClosedRange<Double>`. The RH helper performs the
corresponding scalar checks. Penalty functions use `lowerBound`, `upperBound`,
and `contains(_:)` on validated ranges.

## Red-green-refactor sequence

1. RED: test zero temperature penalty inside 18...24 C using Fahrenheit input
   and mixed-unit bounds, a cold value below 18 C, and the Celsius-equivalent
   upper breakpoints 28 and 32 C. Implement the four temperature segments using
   normalized Celsius distances.
2. RED: use mixed-unit dew-point settings equivalent to 5...15 C and test below
   5, inside the range, at 17, at 20, and above 20 C. Implement the four
   dew-point segments using normalized Celsius distances.
3. RED: use RH settings 40...60 and test below 40, inside the range, at 70, at
   85, and above 85. Implement the four RH segments.
4. RED: verify the selected `HumidityComfortPreference` case is the only
   humidity penalty used by holding conditions constant and switching cases.
5. RED: verify combination weights immediately below, at, and above maximum
   accepted temperature +2 and +8.
6. RED: cover unsupported units, non-finite measurements, invalid RH, reversed
   or equal ranges after unit normalization, out-of-domain ranges, and
   nonpositive fresh-air intervals. Implement both validation helpers so every
   malformed range throws its typed range error before `ClosedRange<Double>`
   construction.
7. Refactor the three piecewise calculations into focused internal functions
   that consume validated `ClosedRange<Double>` values; keep `score` as the only
   public scoring entry point.

## Acceptance criteria

- Lower scores consistently mean closer to the selected comfort ranges.
- Every boundary follows the inclusive/exclusive rules in the specification.
- RH and dew-point modes can produce different scores for identical conditions.
- Invalid settings throw typed errors and are never silently normalized.
- Public Codable settings retain their unit-aware range shapes while scoring
  internals use Celsius `ClosedRange<Double>` values.
- No `ClosedRange<Double>` is constructed before its source bounds pass
  validation.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add configurable comfort scoring`

