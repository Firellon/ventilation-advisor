# Session 7: Fresh-Air Override and Explanations

**Time box:** 45–60 minutes  
**Depends on:** Sessions 2–6  
**Outcome:** Internal logic applies configurable stale-air policy and generates
deterministic short and detailed reasons.

## Files in scope

```text
Sources/VentilationAdvisor/Advisor/FreshAirPolicy.swift
Sources/VentilationAdvisor/Advisor/VentilationExplanationBuilder.swift
Tests/VentilationAdvisorTests/FreshAirPolicyTests.swift
Tests/VentilationAdvisorTests/ExplanationTests.swift
```

## Red-green-refactor sequence

### Fresh-air policy

1. RED: test the standard interval immediately before 180 minutes and exactly at
   180 minutes. Only the exact threshold activates.
2. RED: test a custom positive interval and `nil`, where `nil` disables the
   policy.
3. RED: verify the policy requires closed windows, a known last-ventilated time,
   and no comfort-improving candidate.
4. RED: verify the override selects the existing five-minute candidate.
5. RED: use mixed-unit inputs to verify suppression only when outside
   temperature is physically over 5 C warmer and outside dew point is
   physically over 3 C higher; test each condition alone too. Normalize to
   Celsius before calculating these internal differences.
6. RED: cover future last-ventilated time and compare the configured interval
   against the elapsed `Date` duration without integer conversion.

### Explanation builder

1. RED: add one case for each required category: cooler/lower dew point,
   cooler/higher dew point, warmer/lower dew point, other improvement, strictly
   worse, tied/no improvement, and fresh air.
2. RED: verify moisture category decisions use dew point even under RH comfort
   settings.
3. RED: verify detailed text includes locale-independent one-decimal expected
   temperature, RH, and dew point using exact `°C`, `°F`, or `K` symbols.
4. RED: pass Fahrenheit indoor input with Kelvin outdoor input and verify all
   explanation measurements use Fahrenheit. Repeat a formatting case with
   Kelvin indoor input.
5. RED: verify numeric advice values remain unrounded and every short reason is
   at most 80 characters.
6. Refactor category selection and expected-value formatting into separate
   internal functions.

## Acceptance criteria

- Fresh-air policy is deterministic at every threshold and exception boundary.
- `nil` disables time-based recommendations.
- Tied and strictly worse candidates produce different accurate wording.
- Threshold comparisons are unit-independent and explanation units follow the
  indoor input temperature.
- Explanation code remains internal and contains no localization framework.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: add fresh-air override and explanations`

