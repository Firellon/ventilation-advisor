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
import Foundation

public enum DewPointCalculator {
    public static func dewPoint(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double
    ) throws -> Measurement<UnitTemperature>

    public static func relativeHumidity(
        temperature: Measurement<UnitTemperature>,
        dewPoint: Measurement<UnitTemperature>
    ) throws -> Double
}
```

## Red-green-refactor sequence

1. RED: pass 20 C / 50% RH and expect approximately 9.3 C. Repeat with the
   equivalent Fahrenheit and Kelvin inputs; expect physically equivalent dew
   points returned in the respective input units. Implement supported-unit
   checks, Celsius normalization, Magnus calculation with `a = 17.27` and
   `b = 237.7`, and conversion back to the input unit.
2. RED: calculate dew point for 24 C / 50% RH, feed it to inverse Magnus, and
   expect 50% within `0.2`. Repeat with temperature and dew point expressed in
   different supported units. Implement inverse RH in Celsius and clamp only
   its calculated result to `0...100`.
3. RED: parameterize non-finite measurement values, RH, and dew-point values and
   expect
   `.nonFiniteValue` with the correct field name.
4. RED: construct a custom `UnitTemperature` and expect
   `.unsupportedTemperatureUnit` before any conversion.
5. RED: parameterize Celsius-, Fahrenheit-, and Kelvin-expressed temperatures
   physically below -50 C and above 80 C and expect `.temperatureOutOfRange`
   carrying the original measurement.
6. RED: test RH of 0, negative RH, and RH above 100 and expect
   `.relativeHumidityOutOfRange`.
7. RED: test mixed-unit dew point above temperature and dew point at or below
   -237.7 C and expect `.invalidDewPoint` with original measurements.
8. Refactor shared validation into `InputValidator`, including one internal
   helper that validates a supported measurement and returns its Celsius
   `Double`. Rerun all tests after every extraction.

## Acceptance criteria

- Both public calculations match the specification within tolerance.
- Celsius, Fahrenheit, and Kelvin inputs produce equivalent physics.
- Dew-point output preserves the input temperature's unit.
- Every invalid caller value throws the documented error rather than trapping.
- No comfort scoring or ventilation prediction is introduced.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add validated psychrometric calculations`

