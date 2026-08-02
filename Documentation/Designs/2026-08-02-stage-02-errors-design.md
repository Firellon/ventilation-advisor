# Stage 02 Error Surface

**Status:** Implemented

## Goal

Define the complete public `VentilationAdvisorError` value contract required by
Stage 02, without introducing validation or touching codec-dependent models.

## Scope

`Sources/VentilationAdvisor/VentilationAdvisorError.swift` contains the ten
cases specified in `Documentation/TechnicalSpecification.md`. The enum conforms
to `Error`, `Equatable`, and `Sendable`. Associated temperature values use
`Measurement<UnitTemperature>`, so the file imports Foundation.

`Tests/VentilationAdvisorTests/VentilationAdvisorErrorTests.swift` contains a
construction and equality test covering every case. The test asserts the total
case count and verifies that associated values participate in equality.

## Boundaries

- Do not add validation, throwing operations, normalization, or clamping.
- Do not modify `ComfortSettings.swift`, `ModelsTests.swift`, or the unpublished
  `TemperatureMeasurementCoding` helper.
- Do not implement Task 4 condition, prediction, or advice models.
- Preserve original measurements and scalar values in associated error values.
- Use `Int` for interval, duration, and timestamp associated values.

## TDD Record

1. The focused test was added with all ten required error constructions.
2. The focused test failed because `VentilationAdvisorError` was missing.
3. The minimal public enum was added with the exact associated-value
   signatures.
4. The focused test and complete test suite passed.

## Verification

- Swift 6.3.3 package build: passed.
- Complete Swift Testing suite: 4 tests passed.
- `git diff --check`: passed.
- `Int64` scan across `Sources` and `Tests`: no matches.

## Integration

This work is independent of Stage 02 Task 3 and integrates without relying on
the shared temperature codec interface.
