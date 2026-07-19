# Session 2: Package Identity and Public Models

**Time box:** 45–60 minutes  
**Outcome:** Consumers can import `VentilationAdvisor` and construct, compare,
encode, and decode the complete public data contract. No calculations or advisor
behavior are implemented.

## Files in scope

```text
Package.swift
Sources/VentilationAdvisor/Models/ComfortSettings.swift
Sources/VentilationAdvisor/Models/Conditions.swift
Sources/VentilationAdvisor/Models/VentilationAdvice.swift
Sources/VentilationAdvisor/VentilationAdvisorError.swift
Tests/VentilationAdvisorTests/ModelsTests.swift
```

Remove the generated kebab-case source and test placeholders after the new target
paths compile.

## Interfaces delivered

- `ComfortRange`
- `HumidityMetric`
- `HumidityComfortPreference`
- `ComfortSettings`, including `.standard`
- `IndoorConditions` and `OutdoorConditions`
- `WindowState`
- `VentilationInput`
- `Recommendation`
- `PredictedConditions`
- `VentilationAdvice`
- `VentilationAdvisorError`

Every public model is immutable and conforms to `Codable`, `Equatable`, and
`Sendable`. All public initializers are explicit. Timestamp and duration fields
use `Int`.

## Red-green-refactor sequence

### Cycle 1: Package identity

- Adjust `Package.swift` to expose one library product and module named
  `VentilationAdvisor` with a `VentilationAdvisorTests` target.
- Add `ModelsTests.swift` importing `@testable import VentilationAdvisor` and
  referencing `ComfortSettings.standard` before defining that type.
- Run `swift test`; the expected RED is a compiler failure that
  `ComfortSettings` is unavailable.

### Cycle 2: Standard settings

- Test exact standard values: temperature `18...24`, RH `40...60`, and fresh-air
  interval `180`.
- Implement only the comfort range, humidity preference, and settings models.
- Confirm the focused model tests pass.

### Cycle 3: Wire values

- Add parameterized tests that encode every `HumidityMetric`, `WindowState`, and
  `Recommendation` case and compare the exact uppercase JSON string.
- Add raw String values matching the technical specification.

### Cycle 4: Complete round trips

- Construct representative `VentilationInput`, `PredictedConditions`, and
  `VentilationAdvice` values.
- Encode and decode each value with `JSONEncoder` and `JSONDecoder`.
- Assert decoded values equal their originals and timestamp fields remain `Int`.
- Implement the remaining data models and public initializers.

### Refactor and checkpoint

- Split models by responsibility without changing their wire keys.
- Remove the generated example source and test.
- Run the complete build and test suite.

## Acceptance criteria

- `import VentilationAdvisor` compiles.
- Package, product, module, source target, and test target use UpperCamelCase.
- Codable enum representations match the specification exactly.
- `.standard` has the required values.
- No formula, scoring, prediction, or advisor orchestration exists yet.
- `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: define ventilation advisor models`

