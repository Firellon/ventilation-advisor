# Session 2: Package Identity and Unit-Aware Public Models

**Status:** Planned
**Time box:** 45–60 minutes
**Outcome:** Consumers can import `VentilationAdvisor`, construct unit-aware
settings and inputs, and inspect, compare, encode, and decode outputs. No
validation, psychrometric calculation, scoring, prediction, or recommendation
behavior is implemented.

## Review outcome

This stage resolves four API risks before implementation:

1. The product and target are renamed while temporarily retaining the generated
   lowercase directories, so the first TDD failure is a missing model rather
   than failed SwiftPM source discovery.
2. Caller-owned models have explicit public initializers. Library-produced
   `PredictedConditions` and `VentilationAdvice` have only internal synthesized
   memberwise initializers.
3. Absolute temperatures use `Measurement<UnitTemperature>` and carry Celsius,
   Fahrenheit, or Kelvin through the public API.
4. Package JSON uses an explicit `{ "value", "unit" }` temperature shape rather
   than depending on Foundation's synthesized `Measurement` encoding.

## Global constraints

- Swift tools and language version: 6.3.
- Package, product, module, and final target directory: `VentilationAdvisor`.
- Test target and final test directory: `VentilationAdvisorTests`.
- Third-party dependencies: none; import Foundation for `Measurement` and
  `UnitTemperature`.
- Public domain models: `Codable`, `Equatable`, `Sendable`.
- Aggregate public errors: `Error`, `Equatable`, `Sendable`; individual public
  validation issues: `Equatable`, `Sendable`. Neither type is Codable.
- Stored properties are immutable `let` values.
- Timestamps, intervals, and recommended minutes use `Int`.
- Model initializers do not validate, throw, normalize, or clamp values.
- Validation and Celsius normalization begin in Session 3.

## Final file map

```text
Package.swift
Sources/VentilationAdvisor/Models/TemperatureMeasurementCoding.swift
Sources/VentilationAdvisor/Models/ComfortSettings.swift
Sources/VentilationAdvisor/Models/Conditions.swift
Sources/VentilationAdvisor/Models/VentilationAdvice.swift
Sources/VentilationAdvisor/VentilationAdvisorError.swift
Tests/VentilationAdvisorTests/ComfortSettingsTests.swift
Tests/VentilationAdvisorTests/ConditionsTests.swift
Tests/VentilationAdvisorTests/VentilationAdviceTests.swift
Tests/VentilationAdvisorTests/VentilationAdvisorErrorTests.swift
```

Delete the generated test placeholder before the first RED. Delete the generated
source placeholder when directories are normalized at the final checkpoint.

## Locked public data contract

All declarations using measurements import Foundation.

### Comfort settings

```swift
public struct TemperatureRange: Codable, Equatable, Sendable {
    public let minimum: Measurement<UnitTemperature>
    public let maximum: Measurement<UnitTemperature>

    public init(
        minimum: Measurement<UnitTemperature>,
        maximum: Measurement<UnitTemperature>
    )
}

public struct RelativeHumidityRange: Codable, Equatable, Sendable {
    public let minimumPercent: Double
    public let maximumPercent: Double

    public init(minimumPercent: Double, maximumPercent: Double)
}

public enum HumidityComfortPreference: Codable, Equatable, Sendable {
    case relativeHumidity(RelativeHumidityRange)
    case dewPoint(TemperatureRange)
}

public struct ComfortSettings: Codable, Equatable, Sendable {
    public let temperatureRange: TemperatureRange
    public let humidityPreference: HumidityComfortPreference
    public let freshAirIntervalMinutes: Int?

    public init(
        temperatureRange: TemperatureRange,
        humidityPreference: HumidityComfortPreference,
        freshAirIntervalMinutes: Int?
    )

    public static let standard: ComfortSettings
}
```

`standard` is exactly:

```swift
ComfortSettings(
    temperatureRange: TemperatureRange(
        minimum: Measurement(value: 18, unit: .celsius),
        maximum: Measurement(value: 24, unit: .celsius)
    ),
    humidityPreference: .relativeHumidity(
        RelativeHumidityRange(
            minimumPercent: 40,
            maximumPercent: 60
        )
    ),
    freshAirIntervalMinutes: 180
)
```

### Conditions and input

```swift
public struct IndoorConditions: Codable, Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let relativeHumidityPercent: Double

    public init(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double
    )
}

public struct OutdoorConditions: Codable, Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let relativeHumidityPercent: Double
    public let dewPoint: Measurement<UnitTemperature>?

    public init(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double,
        dewPoint: Measurement<UnitTemperature>?
    )
}

public enum WindowState: String, Codable, Equatable, Sendable {
    case closed = "CLOSED"
    case tilted = "TILTED"
    case open = "OPEN"
}

public struct VentilationInput: Codable, Equatable, Sendable {
    public let indoor: IndoorConditions
    public let outdoor: OutdoorConditions
    public let windowState: WindowState
    public let comfortSettings: ComfortSettings
    public let lastVentilatedAtMillis: Int?
    public let nowMillis: Int

    public init(
        indoor: IndoorConditions,
        outdoor: OutdoorConditions,
        windowState: WindowState,
        comfortSettings: ComfortSettings,
        lastVentilatedAtMillis: Int?,
        nowMillis: Int
    )
}
```

### Prediction and advice

```swift
public enum Recommendation: String, Codable, Equatable, Sendable {
    case openWindows = "OPEN_WINDOWS"
    case closeWindows = "CLOSE_WINDOWS"
    case keepWindowsOpen = "KEEP_WINDOWS_OPEN"
    case keepWindowsClosed = "KEEP_WINDOWS_CLOSED"
}

public struct PredictedConditions: Codable, Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let relativeHumidityPercent: Double
    public let dewPoint: Measurement<UnitTemperature>
}

public struct VentilationAdvice: Codable, Equatable, Sendable {
    public let recommendation: Recommendation
    public let recommendedMinutes: Int
    public let currentIndoorTemperature: Measurement<UnitTemperature>
    public let currentIndoorRelativeHumidityPercent: Double
    public let currentIndoorDewPoint: Measurement<UnitTemperature>
    public let outdoorTemperature: Measurement<UnitTemperature>
    public let outdoorRelativeHumidityPercent: Double
    public let outdoorDewPoint: Measurement<UnitTemperature>
    public let predictedTemperature: Measurement<UnitTemperature>
    public let predictedRelativeHumidityPercent: Double
    public let predictedDewPoint: Measurement<UnitTemperature>
    public let currentScore: Double
    public let predictedScore: Double
    public let shortReason: String
    public let detailedReason: String
}
```

Do not declare a public memberwise initializer for either output struct.
Implement their custom Codable requirements in extensions so Swift retains the
internal synthesized memberwise initializer for production composition and
tests using `@testable import VentilationAdvisor`.

Do not add temperature, dew-point, or score delta properties. They are derived
values and are outside the public contract.

### Error types

Declare the aggregate error and every validation issue in
[`TechnicalSpecification.md`](../TechnicalSpecification.md#5-validation-and-errors):

```swift
public struct VentilationAdvisorError: Error, Equatable, Sendable {
    public let issues: [VentilationAdvisorValidationIssue]

    public init(
        first: VentilationAdvisorValidationIssue,
        additional: [VentilationAdvisorValidationIssue] = []
    )
}

public enum VentilationAdvisorValidationIssue: Equatable, Sendable
```

The required first issue prevents empty aggregate errors. Session 2 defines and
compares error and issue values but does not throw them.

## Locked temperature JSON

The shared internal `TemperatureMeasurementCoding` helper maps only:

```text
UnitTemperature.celsius    <-> CELSIUS
UnitTemperature.fahrenheit <-> FAHRENHEIT
UnitTemperature.kelvin     <-> KELVIN
```

Every nested measurement has this exact representation:

```json
{ "value": 68.0, "unit": "FAHRENHEIT" }
```

The helper owns the wire-only unit enum and the conversion between that enum and
Foundation units. Public models use custom Codable implementations that delegate
measurement fields to the helper. Decoding an unknown unit throws
`DecodingError.dataCorrupted`; encoding a custom `UnitTemperature` throws
`EncodingError.invalidValue`. Scientific validation remains deferred.

`HumidityComfortPreference` uses:

```json
{
  "metric": "RELATIVE_HUMIDITY",
  "range": {
    "minimumPercent": 40.0,
    "maximumPercent": 60.0
  }
}
```

or:

```json
{
  "metric": "DEW_POINT",
  "range": {
    "minimum": { "value": 5.0, "unit": "CELSIUS" },
    "maximum": { "value": 15.0, "unit": "CELSIUS" }
  }
}
```

## Task 1: Rename the package — DONE

**Status:** Complete. The package, product, module, and targets are named
`VentilationAdvisor`, and the directories were normalized to UpperCamelCase in
the same step rather than later at Task 6.

**Superseded guidance (kept for rationale):** this task originally renamed the
package while leaving the generated lowercase directories in place behind
temporary `path: "Sources/ventilation-advisor"` and
`path: "Tests/ventilation-advisorTests"` target entries, so that the first TDD
failure would be a missing model rather than failed SwiftPM source discovery.
That goal is satisfied directly by the normalized directories, so no `path:`
overrides exist in `Package.swift` and none should be added.

**Files:**

- Modify `Package.swift`. — done
- Delete the generated test placeholder. — done
- Create `Tests/VentilationAdvisorTests/ComfortSettingsTests.swift`. — done

Delete the generated test before adding:

```swift
import Foundation
import Testing
@testable import VentilationAdvisor

@Test("standard comfort settings use documented unit-aware defaults")
func standardComfortSettingsUseDocumentedDefaults() {
    let settings = ComfortSettings.standard

    #expect(
        settings.temperatureRange.minimum ==
            Measurement(value: 18, unit: UnitTemperature.celsius)
    )
    #expect(
        settings.temperatureRange.maximum ==
            Measurement(value: 24, unit: UnitTemperature.celsius)
    )

    guard case .relativeHumidity(let range) =
        settings.humidityPreference
    else {
        Issue.record("Expected relative-humidity preference")
        return
    }

    #expect(range.minimumPercent == 40)
    #expect(range.maximumPercent == 60)
    #expect(settings.freshAirIntervalMinutes == 180)
}
```

Run `& $swift test`. Expected RED: `ComfortSettings` and `TemperatureRange` are
missing while the `VentilationAdvisor` import succeeds.

## Task 2: Add comfort-setting model shapes — DONE

**Status:** Complete. The defaults test passes.

**Files:**

- Create `Sources/VentilationAdvisor/Models/ComfortSettings.swift`. — done

Implement the exact public settings declarations and `.standard`. Do not add
custom Codable yet. Run `& $swift test`; the defaults test must pass.

The generated source placeholder was removed here rather than at Task 6, since
`ComfortSettings.swift` now keeps the target from being source-less.

Note for later tasks: `Measurement` equality converts between units, so
`0 °C == 273.15 K` is `true`. Asserting a bound's `.unit` is therefore
unnecessary for value equality, but a "round-trip without normalization" check
needs more than `==` to prove the original unit survived.

## Task 3: Lock measurement and humidity-preference JSON

**Files:**

- Create
  `Sources/VentilationAdvisor/Models/TemperatureMeasurementCoding.swift`.
- Modify `Sources/VentilationAdvisor/Models/ComfortSettings.swift`.
- Modify `Tests/VentilationAdvisorTests/ComfortSettingsTests.swift`.

Use an encoder configured with `.sortedKeys` for exact JSON assertions. RED tests
must assert:

1. Celsius, Fahrenheit, and Kelvin each encode to their exact uppercase unit.
2. All three forms decode back to equal `Measurement<UnitTemperature>` values.
3. Unknown unit `"RANKINE"` fails decoding.
4. A custom `UnitTemperature` fails encoding.
5. Both `HumidityComfortPreference` cases encode with exact `metric` and
   case-specific `range` shapes.
6. Mixed-unit `TemperatureRange` bounds round-trip without normalization.

GREEN: implement the internal measurement codec and custom Codable for
`TemperatureRange` and `HumidityComfortPreference`. Custom coding belongs in
extensions where doing so preserves desired synthesized initializers.

## Task 4: Add conditions and enum wire values

**Files:**

- Create `Sources/VentilationAdvisor/Models/Conditions.swift`.
- Create `Sources/VentilationAdvisor/Models/VentilationAdvice.swift`.
- Create `Tests/VentilationAdvisorTests/ConditionsTests.swift`.
- Create `Tests/VentilationAdvisorTests/VentilationAdviceTests.swift`.

RED: parameterize exact encoding for:

```swift
[
    (WindowState.closed, "\"CLOSED\""),
    (WindowState.tilted, "\"TILTED\""),
    (WindowState.open, "\"OPEN\""),
]

[
    (Recommendation.openWindows, "\"OPEN_WINDOWS\""),
    (Recommendation.closeWindows, "\"CLOSE_WINDOWS\""),
    (Recommendation.keepWindowsOpen, "\"KEEP_WINDOWS_OPEN\""),
    (Recommendation.keepWindowsClosed, "\"KEEP_WINDOWS_CLOSED\""),
]
```

Also construct `IndoorConditions` in Fahrenheit and `OutdoorConditions` in
Kelvin with a Celsius dew point. Expected RED: these types do not exist. GREEN:
add the exact declarations and custom Codable extensions using the shared
measurement codec.

## Task 5: Complete model round trips and errors

**Files:**

- Modify all four model files.
- Create `Sources/VentilationAdvisor/VentilationAdvisorError.swift`.
- Modify `Tests/VentilationAdvisorTests/ConditionsTests.swift`.
- Modify `Tests/VentilationAdvisorTests/VentilationAdviceTests.swift`.
- Create `Tests/VentilationAdvisorTests/VentilationAdvisorErrorTests.swift`.

Add the round-trip helper to each model test file that uses it:

```swift
private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(T.self, from: data)
}
```

RED then GREEN one representative value at a time:

1. `VentilationInput` with Fahrenheit indoor temperature, Kelvin outdoor
   temperature, Celsius supplied dew point, mixed-unit temperature bounds, and
   non-nil time metadata.
2. `VentilationInput` with nil outdoor dew point and nil last-ventilated time.
3. `PredictedConditions` with Fahrenheit temperature and dew point.
4. `VentilationAdvice` with every property assigned a distinct value and no
   delta properties.

Input models exercise public initializers. Output tests use internal synthesized
memberwise initializers through `@testable import`. Implement output Codable in
extensions so those internal initializers remain available.

In `VentilationAdvisorErrorTests.swift`, add a compile-time equality test
containing all validation issue cases and both single- and multiple-issue
aggregate errors:

```swift
let issues: [VentilationAdvisorValidationIssue] = [
    .nonFiniteValue(field: "indoor.temperature.value"),
    .unsupportedTemperatureUnit(
        field: "indoor.temperature",
        symbol: "°R"
    ),
    .temperatureOutOfRange(
        field: "indoor.temperature",
        value: Measurement(value: 81, unit: .celsius)
    ),
    .relativeHumidityOutOfRange(
        field: "indoor.relativeHumidityPercent",
        value: 0
    ),
    .invalidDewPoint(
        temperature: Measurement(value: 20, unit: .celsius),
        dewPoint: Measurement(value: 21, unit: .celsius)
    ),
    .invalidTemperatureRange(
        field: "temperatureRange",
        minimum: Measurement(value: 24, unit: .celsius),
        maximum: Measurement(value: 18, unit: .celsius)
    ),
    .invalidRelativeHumidityRange(
        field: "humidityPreference.range",
        minimumPercent: 60,
        maximumPercent: 40
    ),
    .invalidFreshAirInterval(minutes: 0),
    .invalidDuration(minutes: 0),
    .invalidTimeRange(
        lastVentilatedAtMillis: 2,
        nowMillis: 1
    ),
]

#expect(issues.count == 10)
#expect(
    issues[0] ==
        .nonFiniteValue(field: "indoor.temperature.value")
)

let singleIssueError = VentilationAdvisorError(first: issues[0])
let multipleIssueError = VentilationAdvisorError(
    first: issues[0],
    additional: Array(issues.dropFirst())
)

#expect(singleIssueError.issues == [issues[0]])
#expect(multipleIssueError.issues == issues)
```

Do not add validation or throwing production behavior.

## Task 6: Final checkpoint

**Superseded guidance (kept for rationale):** this task originally normalized
the directories and removed the temporary target paths at the very end:

```powershell
git mv Sources/ventilation-advisor Sources/VentilationAdvisor
git mv Tests/ventilation-advisorTests Tests/VentilationAdvisorTests
git rm Sources/VentilationAdvisor/ventilation_advisor.swift
```

All three landed earlier — the directory moves at Task 1 and the placeholder
removal at Task 2 — and `Package.swift` never gained temporary paths to remove.

What remains for this task, once all model tests are green:

```powershell
& $swift build
& $swift test
rg -n "Int64|temperatureC|dewPointC|TempC|temperatureDelta|dewPointDelta|scoreDelta|HumidityMetric|ComfortRange|ventilation_advisor|ventilation-advisorTests" `
    Package.swift Sources Tests
```

Expected: build and tests pass, and the search returns no matches.

**Open conflict — `git diff --check`.** The original checkpoint also ran
`git diff --check`. That check reports trailing whitespace, which
`.swift-format`'s `indentBlankLines` deliberately produces on blank lines inside
declarations. `.editorconfig` now sets `trim_trailing_whitespace = false` so
editors stop fighting the formatter, but `git diff --check` does not read
`.editorconfig` and still exits non-zero. Either scope the check
(`git config core.whitespace -trailing-space`) or drop it as a criterion; until
then it cannot pass alongside the current formatter configuration.

## Session acceptance checklist

- [ ] The first RED fails for missing models, not source discovery.
- [ ] Package, product, module, targets, and final directories use the required
      UpperCamelCase names.
- [ ] Public models are immutable, Codable, Equatable, and Sendable.
- [ ] Absolute temperatures use `Measurement<UnitTemperature>`.
- [ ] Settings and input models have explicit public initializers.
- [ ] Output models have no public memberwise initializer.
- [ ] Temperature JSON uses only `CELSIUS`, `FAHRENHEIT`, or `KELVIN`.
- [ ] Humidity-preference JSON uses the exact discriminator and range shape.
- [ ] Standard settings are 18...24 C, 40...60% RH, and 180 minutes.
- [ ] Mixed-unit inputs, ranges, predictions, and advice round-trip exactly.
- [ ] Advice exposes no temperature, dew-point, or score delta properties.
- [ ] Errors exist but no validation behavior is implemented.
- [ ] No scientific, prediction, scoring, or recommendation behavior exists.
- [ ] `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: define unit-aware ventilation advisor models`
