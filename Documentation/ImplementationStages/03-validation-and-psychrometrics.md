# Session 3: Validation and Psychrometrics

**Time box:** 45–60 minutes  
**Depends on:** Session 2  
**Outcome:** The package publicly calculates dew point and inverse RH with typed
validation failures.

## Files in scope

```text
Sources/VentilationAdvisor/Science/DewPointCalculator.swift
Sources/VentilationAdvisor/Science/InputValidator.swift
Tests/VentilationAdvisorTests/PsychrometricsTests.swift
```

`InputValidator` remains internal. `DewPointCalculator` is a public caseless enum.

## Interface delivered

```swift
public enum DewPointCalculator {
    public static func dewPoint(
        temperatureC: Double,
        relativeHumidityPercent: Double
    ) throws -> Double

    public static func relativeHumidity(
        temperatureC: Double,
        dewPointC: Double
    ) throws -> Double
}
```

## Red-green-refactor sequence

1. RED: assert 20 C / 50% RH produces approximately 9.3 C. Implement validated
   Magnus dew-point calculation with `a = 17.27`, `b = 237.7`.
2. RED: calculate dew point for 24 C / 50% RH, feed it to inverse Magnus, and
   expect 50% within `0.2`. Implement inverse RH and clamp only its calculated
   result to `0...100`.
3. RED: parameterize non-finite temperature/RH/dew-point inputs and expect
   `.nonFiniteValue` with the correct field name.
4. RED: parameterize temperatures below -50 and above 80 and expect
   `.temperatureOutOfRange`.
5. RED: test RH of 0, negative RH, and RH above 100 and expect
   `.relativeHumidityOutOfRange`.
6. RED: test dew point above temperature and at or below -237.7 and expect
   `.invalidDewPoint`.
7. Refactor shared validation into the internal validator, rerunning all tests
   after every extraction.

## Acceptance criteria

- Both public calculations match the specification within tolerance.
- Every invalid caller value throws the documented error rather than trapping.
- No comfort scoring or ventilation prediction is introduced.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add validated psychrometric calculations`

