# Stage 02 Aggregate Validation Errors

**Status:** Implemented

## Goal

Return every independent validation issue discovered during one public
operation, allowing callers to correct multiple input problems in one pass.
Model initializers remain nonthrowing, and validation occurs when callers invoke
advisor, prediction, scoring, or psychrometric behavior.

## Public Contract

`VentilationAdvisorError` is the single error value thrown for invalid domain
input. It contains a nonempty, flat collection of individual issues:

```swift
public struct VentilationAdvisorError: Error, Equatable, Sendable {
    public let issues: [VentilationAdvisorValidationIssue]

    public init(
        first: VentilationAdvisorValidationIssue,
        additional: [VentilationAdvisorValidationIssue] = []
    )
}
```

Accepting a required first issue prevents callers and package internals from
creating a validation error with no cause.

`VentilationAdvisorValidationIssue` identifies one correctable problem:

```swift
public enum VentilationAdvisorValidationIssue: Equatable, Sendable {
    case nonFiniteValue(field: String)
    case unsupportedTemperatureUnit(field: String, symbol: String)
    case temperatureOutOfRange(
        field: String,
        value: Measurement<UnitTemperature>
    )
    case relativeHumidityOutOfRange(field: String, value: Double)
    case invalidDewPoint(
        temperature: Measurement<UnitTemperature>,
        dewPoint: Measurement<UnitTemperature>
    )
    case invalidTemperatureRange(
        field: String,
        minimum: Measurement<UnitTemperature>,
        maximum: Measurement<UnitTemperature>
    )
    case invalidRelativeHumidityRange(
        field: String,
        minimumPercent: Double,
        maximumPercent: Double
    )
    case invalidFreshAirInterval(minutes: Int)
    case invalidDuration(minutes: Int)
    case invalidTimeRange(lastVentilatedAt: Date?, now: Date)
}
```

The issue enum does not conform to `Error`: public operations throw only the
aggregate `VentilationAdvisorError`, so consumers always receive the same error
shape whether validation finds one issue or several.

## Collection Semantics

- Collect independent issues instead of stopping after the first failure.
- Preserve issues in deterministic input-field order.
- Keep the collection flat; do not nest aggregate errors.
- Do not add duplicate issues for the same invalid condition.
- Preserve caller-supplied measurements and scalar values in associated values.
- Skip dependent validation when a prerequisite is invalid. For example, an
  unsupported temperature unit produces its unit issue, but checks requiring
  Celsius conversion of that measurement do not run.
- Continue validating unrelated fields after a prerequisite failure. An invalid
  indoor temperature does not prevent reporting an invalid fresh-air interval.

## Public Interaction

```swift
do {
    let advice = try VentilationAdvisor().assess(input)
    display(advice)
} catch let error as VentilationAdvisorError {
    for issue in error.issues {
        displayValidationIssue(issue)
    }
}
```

The package supplies structured values, not localized user-facing messages.
Consuming applications decide how to display, log, or associate each issue with
a form field.

## Boundaries

- Codable failures continue to use standard `EncodingError` and
  `DecodingError`; they are not validation issues.
- Do not add validation, normalization, or clamping to model initializers.
- Do not introduce networking, persistence, sensor, permission, or UI errors.
- Do not add a generic internal or calculation error that could hide a package
  defect.
- Associated instants use `Date`; intervals and durations use `Int`.
- Neither public validation type conforms to `Codable`.

## Verification

- All ten issue cases are constructed in tests, and equality includes associated
  values.
- Single- and multiple-issue errors verify that the first issue is always
  present and ordering is preserved.
- Swift 6.3.3 package build passes.
- The complete Swift Testing suite passes with 5 tests.
- `git diff --check` passes.
- Legacy singular-error and `Int64` scans return no matches.

Stage 03 validation tests will verify that multiple independent invalid fields
are returned together, dependent checks are suppressed after invalid
prerequisites, unrelated checks continue, and public operations never throw an
empty validation error.

## Specification Alignment

`Documentation/TechnicalSpecification.md` and the affected Stage 02–05 guides
define the aggregate error, validation issue enum, collection order, and
dependency rules. Later stage guides that only rely on the public `throws`
signatures require no change.

## Task 3 Independence

The error types remain independent of Stage 02 Task 3 and do not rely on the
shared temperature codec interface.
