# Session 2: Package Identity and Public Models

**Status:** Planned
**Time box:** 45–60 minutes
**Outcome:** Consumers can import `VentilationAdvisor`, construct its settings
and input models, and inspect, compare, encode, and decode its output models. No
validation, psychrometric calculation, scoring, prediction, or recommendation
behavior is implemented.

## Review outcome

The initial stage outline had three risks that this plan resolves:

1. Renaming the target and physical directories in one step would make the first
   test fail because SwiftPM could not discover target sources. That is an
   infrastructure error, not a valid TDD RED for missing model behavior.
2. The specification's broad wording about public value types could imply that
   `VentilationAdvisorError` is Codable. Errors are not interchange models. The
   technical specification now explicitly exempts the error enum from Codable.
3. Giving `VentilationAdvice` a public 18-argument memberwise initializer would
   expose an error-prone construction API for a value that only the advisor
   produces. Output properties remain public, but output construction remains
   package-owned.

To preserve a meaningful first RED, rename the package product and target while
temporarily pointing them at the generated lowercase directories. Normalize the
physical directories only after all model tests are green.

## Global constraints

- Swift tools and language version: 6.3.
- Package, product, module, and final target directory: `VentilationAdvisor`.
- Test target and final test directory: `VentilationAdvisorTests`.
- Third-party dependencies: none.
- Public domain models: `Codable`, `Equatable`, `Sendable`.
- Public errors: `Error`, `Equatable`, `Sendable`.
- All stored properties are immutable `let` values.
- Caller-owned settings, conditions, and input models have explicit public
  initializers.
- Library-produced `PredictedConditions` and `VentilationAdvice` have no public
  memberwise initializers.
- All timestamp, interval, and recommended-minute fields use `Int`.
- Validation is deferred to Session 3. Model initializers do not throw or clamp.

## Final file map

```text
Package.swift
Sources/VentilationAdvisor/Models/ComfortSettings.swift
Sources/VentilationAdvisor/Models/Conditions.swift
Sources/VentilationAdvisor/Models/VentilationAdvice.swift
Sources/VentilationAdvisor/VentilationAdvisorError.swift
Tests/VentilationAdvisorTests/ModelsTests.swift
```

Delete the generated test placeholder before the first RED. Delete the generated
source placeholder when the directories are normalized at the final checkpoint.

## Locked public data contract

### Comfort settings

```swift
public struct ComfortRange: Codable, Equatable, Sendable {
    public let minimum: Double
    public let maximum: Double
    public init(minimum: Double, maximum: Double)
}

public enum HumidityMetric: String, Codable, Equatable, Sendable {
    case relativeHumidity = "RELATIVE_HUMIDITY"
    case dewPoint = "DEW_POINT"
}

public struct HumidityComfortPreference: Codable, Equatable, Sendable {
    public let metric: HumidityMetric
    public let range: ComfortRange
    public init(metric: HumidityMetric, range: ComfortRange)
}

public struct ComfortSettings: Codable, Equatable, Sendable {
    public let temperatureRangeC: ComfortRange
    public let humidityPreference: HumidityComfortPreference
    public let freshAirIntervalMinutes: Int?

    public init(
        temperatureRangeC: ComfortRange,
        humidityPreference: HumidityComfortPreference,
        freshAirIntervalMinutes: Int?
    )

    public static let standard: ComfortSettings
}
```

`standard` is exactly:

```swift
ComfortSettings(
    temperatureRangeC: ComfortRange(minimum: 18.0, maximum: 24.0),
    humidityPreference: HumidityComfortPreference(
        metric: .relativeHumidity,
        range: ComfortRange(minimum: 40.0, maximum: 60.0)
    ),
    freshAirIntervalMinutes: 180
)
```

### Conditions and input

```swift
public struct IndoorConditions: Codable, Equatable, Sendable {
    public let temperatureC: Double
    public let relativeHumidityPercent: Double
    public init(temperatureC: Double, relativeHumidityPercent: Double)
}

public struct OutdoorConditions: Codable, Equatable, Sendable {
    public let temperatureC: Double
    public let relativeHumidityPercent: Double
    public let dewPointC: Double?
    public init(
        temperatureC: Double,
        relativeHumidityPercent: Double,
        dewPointC: Double?
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
    public let temperatureC: Double
    public let relativeHumidityPercent: Double
    public let dewPointC: Double
}

public struct VentilationAdvice: Codable, Equatable, Sendable {
    public let recommendation: Recommendation
    public let recommendedMinutes: Int
    public let currentIndoorTempC: Double
    public let currentIndoorRelativeHumidityPercent: Double
    public let currentIndoorDewPointC: Double
    public let outdoorTempC: Double
    public let outdoorRelativeHumidityPercent: Double
    public let outdoorDewPointC: Double
    public let predictedTempC: Double
    public let predictedRelativeHumidityPercent: Double
    public let predictedDewPointC: Double
    public let currentScore: Double
    public let predictedScore: Double
    public let temperatureDeltaC: Double
    public let dewPointDeltaC: Double
    public let scoreDelta: Double
    public let shortReason: String
    public let detailedReason: String
}
```

Do not declare an initializer for either output struct. Swift synthesizes an
internal memberwise initializer that production code and tests using
`@testable import VentilationAdvisor` can use. Consumers receive these values
from package operations and read their public properties. Synthesized Codable
conformance still allows consumers to encode and decode the complete flat wire
shape.

Do not introduce a public convenience initializer, builder, or nested snapshot
model in this session. Grouping fields would improve manual construction but
would also change the normative JSON shape.

### Error type

Declare every case already specified in
[`TechnicalSpecification.md`](../TechnicalSpecification.md#5-validation-and-errors):

```swift
public enum VentilationAdvisorError: Error, Equatable, Sendable
```

Session 2 defines the type and its cases only. Session 3 is responsible for
throwing them.

## Task 1: Rename the package without moving directories

**Files:**

- Modify `Package.swift`.
- Delete `Tests/ventilation-advisorTests/ventilation_advisorTests.swift`.
- Create `Tests/ventilation-advisorTests/ModelsTests.swift`.

### Step 1: Rename manifest identities

Use this temporary manifest shape:

```swift
let package = Package(
    name: "VentilationAdvisor",
    products: [
        .library(
            name: "VentilationAdvisor",
            targets: ["VentilationAdvisor"]
        ),
    ],
    targets: [
        .target(
            name: "VentilationAdvisor",
            path: "Sources/ventilation-advisor"
        ),
        .testTarget(
            name: "VentilationAdvisorTests",
            dependencies: ["VentilationAdvisor"],
            path: "Tests/ventilation-advisorTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
```

The explicit paths are temporary and removed in Task 5.

### Step 2: Write the first failing test

Delete the generated placeholder test first. It imports the old lowercase
module and would make the test run fail for the wrong reason.

```swift
import Foundation
import Testing
@testable import VentilationAdvisor

@Test("standard comfort settings use the documented defaults")
func standardComfortSettingsUseDocumentedDefaults() {
    let settings = ComfortSettings.standard

    #expect(settings.temperatureRangeC == ComfortRange(minimum: 18, maximum: 24))
    #expect(settings.humidityPreference.metric == .relativeHumidity)
    #expect(settings.humidityPreference.range == ComfortRange(minimum: 40, maximum: 60))
    #expect(settings.freshAirIntervalMinutes == 180)
}
```

Run:

```powershell
& $swift test
```

Expected RED: compilation fails because `ComfortSettings` and `ComfortRange` do
not exist. The import of `VentilationAdvisor` must succeed; a source-discovery or
module-import error is the wrong failure and must be corrected before continuing.

## Task 2: Add comfort settings models

**Files:**

- Create `Sources/ventilation-advisor/Models/ComfortSettings.swift`.

Implement the exact comfort-settings API above and nothing else. Run
`& $swift test`; the standard-settings test must pass.

Refactor only formatting and duplication while the test remains green.

## Task 3: Lock enum wire values

**Files:**

- Modify `Tests/ventilation-advisorTests/ModelsTests.swift`.
- Create `Sources/ventilation-advisor/Models/Conditions.swift`.
- Create `Sources/ventilation-advisor/Models/VentilationAdvice.swift`.

Add this helper:

```swift
private func encodedJSONString<T: Encodable>(_ value: T) throws -> String {
    let data = try JSONEncoder().encode(value)
    return try #require(String(data: data, encoding: .utf8))
}
```

Add separate parameterized tests for:

```swift
[
    (HumidityMetric.relativeHumidity, "\"RELATIVE_HUMIDITY\""),
    (HumidityMetric.dewPoint, "\"DEW_POINT\""),
]

[
    (WindowState.closed, "\"CLOSED\""),
    (WindowState.tilted, "\"TILTED\""),
    (WindowState.open, "\"OPEN\""),
]

[
    (Recommendation.openWindows, "\"OPEN_WINDOWS\""),
    (Recommendation.keepWindowsOpen, "\"KEEP_WINDOWS_OPEN\""),
    (Recommendation.closeWindows, "\"CLOSE_WINDOWS\""),
    (Recommendation.keepWindowsClosed, "\"KEEP_WINDOWS_CLOSED\""),
]
```

Run the tests before adding `WindowState` and `Recommendation`. Expected RED:
the referenced enum types are unavailable. Implement the exact raw-value enums,
rerun, and confirm all wire-value cases pass.

## Task 4: Add complete Codable round trips

**Files:**

- Modify `Tests/ventilation-advisorTests/ModelsTests.swift`.
- Modify the three model files.
- Create `Sources/ventilation-advisor/VentilationAdvisorError.swift`.

Add a generic round-trip helper:

```swift
private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
    let data = try JSONEncoder().encode(value)
    return try JSONDecoder().decode(T.self, from: data)
}
```

Write one test each for:

1. `VentilationInput` with non-nil `lastVentilatedAtMillis`.
2. `VentilationInput` with nil `lastVentilatedAtMillis` and nil outdoor dew point.
3. `PredictedConditions`.
4. `VentilationAdvice` with every property assigned a distinct value.

The input tests exercise explicit public initializers. The two output tests use
the synthesized internal memberwise initializers made visible by
`@testable import VentilationAdvisor`. This verifies the output wire contract
without promising public manual construction.

Write each test before its referenced model exists and confirm the expected RED
is a missing type. Then add only the stored properties, required conformances,
and public input initializer needed to make that test pass. Do not declare an
initializer for either output type.

Add this compile-time construction and equality test for every error case:

```swift
@Test("all public error cases are constructible and equatable")
func publicErrorCasesAreConstructible() {
    let errors: [VentilationAdvisorError] = [
        .nonFiniteValue(field: "indoor.temperatureC"),
        .temperatureOutOfRange(
            field: "indoor.temperatureC",
            value: 81
        ),
        .relativeHumidityOutOfRange(
            field: "indoor.relativeHumidityPercent",
            value: 0
        ),
        .invalidDewPoint(temperatureC: 20, dewPointC: 21),
        .invalidComfortRange(
            field: "temperatureRangeC",
            minimum: 24,
            maximum: 18
        ),
        .invalidFreshAirInterval(minutes: 0),
        .invalidDuration(minutes: 0),
        .invalidTimeRange(
            lastVentilatedAtMillis: 2,
            nowMillis: 1
        ),
    ]

    #expect(errors.count == 8)
    #expect(
        errors[0] ==
            .nonFiniteValue(field: "indoor.temperatureC")
    )
}
```

Do not encode errors and do not add throwing behavior.

## Task 5: Normalize directories and manifest paths

Only after all model tests are green:

```powershell
git mv Sources/ventilation-advisor Sources/VentilationAdvisor
git mv Tests/ventilation-advisorTests Tests/VentilationAdvisorTests
git rm Sources/VentilationAdvisor/ventilation_advisor.swift
```

Remove the temporary `path:` arguments from `Package.swift`. SwiftPM must now
discover both UpperCamelCase directories conventionally.

Run:

```powershell
& $swift build
& $swift test
git diff --check
rg -n "Int64|ventilation_advisor|ventilation-advisorTests|name: \"ventilation-advisor\"" `
    Package.swift Sources Tests
```

Expected:

- Build succeeds.
- All model tests pass.
- `git diff --check` is clean.
- The search returns no matches.

## Session acceptance checklist

- [ ] The first RED fails for missing model types, not module discovery.
- [ ] Product, module, and targets are named `VentilationAdvisor`.
- [ ] Final source and test directories use UpperCamelCase.
- [ ] Every public domain model is immutable, Codable, Equatable, and Sendable.
- [ ] Settings, condition, and input models have explicit public initializers.
- [ ] `PredictedConditions` and `VentilationAdvice` have no public memberwise
      initializer.
- [ ] Enum JSON values match the technical specification exactly.
- [ ] `ComfortSettings.standard` matches all documented defaults.
- [ ] Input, prediction, and advice round trips cover optional and nonoptional
      fields.
- [ ] `VentilationAdvisorError` exists but no validation behavior is implemented.
- [ ] Public timestamps and durations use `Int`; no `Int64` remains.
- [ ] No science, scoring, prediction, explanation, or advisor behavior exists.
- [ ] `swift build`, `swift test`, and `git diff --check` pass.

**Commit:** `feat: define ventilation advisor models`
