# Session 5: Ventilation Prediction

**Time box:** 45–60 minutes  
**Depends on:** Sessions 2–3  
**Outcome:** Consumers can predict temperature, dew point, and RH after a stated
window mode and duration.

## Files in scope

```text
Sources/VentilationAdvisor/Science/VentilationPredictor.swift
Tests/VentilationAdvisorTests/VentilationPredictorTests.swift
```

## Interface delivered

```swift
public enum VentilationPredictor {
    public static func predict(
        indoor: IndoorConditions,
        outdoor: OutdoorConditions,
        windowState: WindowState,
        minutes: Int
    ) throws -> PredictedConditions
}
```

## Red-green-refactor sequence

1. RED: parameterize the three window states and verify their air-change rates
   are 0, 0.35, and 2 ACH through observable mix-factor results.
2. RED: verify the open-window mix factor at 30 minutes equals
   `1 - exp(-2 * 0.5)` within tolerance. Implement the exponential formula.
3. RED: provide Fahrenheit indoor temperature and Kelvin outdoor temperature;
   assert Celsius-normalized interpolation and a Fahrenheit predicted
   temperature. Implement linear interpolation in Celsius and convert the
   result to the indoor unit.
4. RED: omit outdoor dew point and expect it to be calculated; provide a valid
   dew point in a third supported unit and expect that physical value to drive
   prediction. Predicted dew point uses the indoor temperature's unit.
5. RED: assert predicted RH equals inverse Magnus for predicted temperature and
   dew point. Add RH reconstruction.
6. RED: assert `.closed` returns unchanged conditions and nonpositive minutes
   produce an aggregate error containing `.invalidDuration`.
7. RED: cover invalid indoor/outdoor conditions and inconsistent supplied dew
   point, including unsupported units, using aggregate errors from Session 3.
   Combine independent invalid values and assert all applicable issues appear in
   deterministic model-property order.

## Acceptance criteria

- Prediction follows the exact exponential air-exchange equation.
- The initial fixed ACH mapping is `.closed = 0`, `.tilted = 0.35`, and
  `.open = 2`.
- All three predicted physical values are returned without display rounding.
- Every predicted absolute temperature uses the indoor input temperature's unit.
- Mixed-unit inputs produce the same physics as Celsius-equivalent inputs.
- Supplied and calculated outdoor dew point paths are both tested.
- The predictor does not generate recommendation candidates or advice.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add ventilation prediction`

