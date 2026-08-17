# Ventilation Advisor Technical Specification

Version: 1.0-draft

This document is the normative implementation contract for the
`VentilationAdvisor` Swift package. The words MUST, MUST NOT, SHOULD, and MAY
describe requirement strength.

## 1. Purpose and scope

Given indoor conditions, outdoor conditions, the current window state, comfort
settings, and ventilation time metadata, the package answers:

> Should the user open, keep open, close, or keep closed the windows, and what
> indoor state is expected afterward?

The package MUST contain only domain and scientific logic. It MUST NOT fetch
weather, request permissions, read sensors, store settings, schedule background
work, depend on a UI framework, choose presentation colors or icons, or use an
app-specific clock.

The Kotlin Luftung application is a behavioral reference for psychrometrics,
prediction, recommendation categories, and explanations. Its multiplier-based
comfort profiles are not part of this package. The range-based comfort settings
below are an intentional Swift-specific design.

## 2. Package contract

- Swift tools and language version: 6.3.
- Package, library product, module, and target name: `VentilationAdvisor`.
- Test target name: `VentilationAdvisorTests`.
- Supported execution architecture: 64-bit.
- Third-party dependencies: none.
- Foundation `Measurement<UnitTemperature>` is the public absolute-temperature
  representation.
- Tests MUST use Swift Testing.
- Public domain data models MUST conform to `Codable`, `Equatable`, and
  `Sendable`.
- `VentilationAdvisorError` MUST conform to `Error`, `Equatable`, and
  `Sendable`. `VentilationAdvisorValidationIssue` MUST conform to `Equatable`
  and `Sendable`. Neither type is part of the Codable interchange model.
- Public stateless namespaces MUST be caseless enums.
- Public APIs MUST use `Date` for instants and `Int`, not fixed-width integer
  types, for intervals and recommended minutes.

Suggested source responsibilities:

```text
Sources/VentilationAdvisor/
  Models/
  Science/
  Advisor/
Tests/VentilationAdvisorTests/
```

## 3. Public API

Declarations containing measurements import Foundation.

```swift
public struct VentilationAdvisor: Sendable {
    public init()
    public func assess(_ input: VentilationInput) throws -> VentilationAdvice
}
```

```swift
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

```swift
public enum ComfortScorer {
    public static func score(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double,
        dewPoint: Measurement<UnitTemperature>,
        settings: ComfortSettings
    ) throws -> Double
}
```

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

The explanation builder, ventilation candidates, and candidate selector MUST
remain internal.

## 4. Models and wire representation

All JSON keys use the Swift property names shown below. Enum discriminator and
raw values use the uppercase strings shown in parentheses.

```text
TemperatureRange
  minimum: Measurement<UnitTemperature>
  maximum: Measurement<UnitTemperature>

RelativeHumidityRange
  minimumPercent: Double
  maximumPercent: Double

HumidityComfortPreference
  relativeHumidity(RelativeHumidityRange) (RELATIVE_HUMIDITY)
  dewPoint(TemperatureRange) (DEW_POINT)

ComfortSettings
  temperatureRange: TemperatureRange
  humidityPreference: HumidityComfortPreference
  freshAirIntervalMinutes: Int?

IndoorConditions
  temperature: Measurement<UnitTemperature>
  relativeHumidityPercent: Double

OutdoorConditions
  temperature: Measurement<UnitTemperature>
  relativeHumidityPercent: Double

WindowState
  closed (CLOSED)
  tilted (TILTED)
  open (OPEN)

VentilationInput
  indoor: IndoorConditions
  outdoor: OutdoorConditions
  windowState: WindowState
  comfortSettings: ComfortSettings
  lastVentilatedAt: Date?
  now: Date

Recommendation
  openWindows (OPEN_WINDOWS)
  closeWindows (CLOSE_WINDOWS)
  keepWindowsOpen (KEEP_WINDOWS_OPEN)
  keepWindowsClosed (KEEP_WINDOWS_CLOSED)

PredictedConditions
  temperature: Measurement<UnitTemperature>
  relativeHumidityPercent: Double
  dewPoint: Measurement<UnitTemperature>

VentilationAdvice
  recommendation: Recommendation
  recommendedMinutes: Int
  currentIndoorTemperature: Measurement<UnitTemperature>
  currentIndoorRelativeHumidityPercent: Double
  currentIndoorDewPoint: Measurement<UnitTemperature>
  outdoorTemperature: Measurement<UnitTemperature>
  outdoorRelativeHumidityPercent: Double
  outdoorDewPoint: Measurement<UnitTemperature>
  predictedTemperature: Measurement<UnitTemperature>
  predictedRelativeHumidityPercent: Double
  predictedDewPoint: Measurement<UnitTemperature>
  currentScore: Double
  predictedScore: Double
  shortReason: String
  detailedReason: String
```

`ComfortSettings.standard` MUST be 18...24 C, 40...60% RH, and a 180-minute
fresh-air interval.

`TemperatureRange` bounds MAY use different supported units. After validating
and converting both bounds to Celsius, scoring internals MUST construct a
`ClosedRange<Double>` and use it for containment and bound access.
`RelativeHumidityRange` follows the same pattern without unit conversion.
Conversion to `ClosedRange<Double>` MUST NOT precede validation.

Every encoded absolute temperature uses this exact shape:

```json
{ "value": 68.0, "unit": "FAHRENHEIT" }
```

Allowed unit strings are `CELSIUS`, `FAHRENHEIT`, and `KELVIN`. Public models
MUST implement Codable using a shared internal measurement codec; they MUST NOT
expose Foundation's synthesized `Measurement` representation as package JSON.

Example comfort-settings JSON:

```json
{
  "temperatureRange": {
    "minimum": { "value": 18.0, "unit": "CELSIUS" },
    "maximum": { "value": 24.0, "unit": "CELSIUS" }
  },
  "humidityPreference": {
    "metric": "RELATIVE_HUMIDITY",
    "range": { "minimumPercent": 40.0, "maximumPercent": 60.0 }
  },
  "freshAirIntervalMinutes": 180
}
```

## 5. Validation and errors

Public advisor, predictor, scorer, and psychrometric operations MUST collect all
independent validation issues and throw one `VentilationAdvisorError`; they MUST
NOT trap or silently repair invalid caller data. Codable failures use the
standard `EncodingError` and `DecodingError` required by those protocols.

The thrown error has one stable shape whether validation finds one issue or
several. Its public initializer requires a first issue so an empty validation
error cannot be constructed:

```swift
public struct VentilationAdvisorError: Error, Equatable, Sendable {
    public let issues: [VentilationAdvisorValidationIssue]

    public init(
        first: VentilationAdvisorValidationIssue,
        additional: [VentilationAdvisorValidationIssue] = []
    )
}

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

Validation collection rules:

- Issues MUST be flat, contain no duplicate report of the same invalid
  condition, and follow deterministic public parameter and model-property order.
- Validation MUST continue across independent fields after finding an issue.
- A check whose prerequisite is invalid MUST be skipped. For example, a
  measurement with an unsupported unit adds `unsupportedTemperatureUnit`, but
  checks requiring Celsius conversion of that measurement do not run.
- If validation produces at least one issue, the public operation MUST throw one
  `VentilationAdvisorError` before performing scientific, scoring, prediction,
  or recommendation calculations.
- `VentilationAdvisorValidationIssue` MUST NOT conform to `Error`; public
  operations throw only the aggregate error.

Rules:

- All floating-point inputs and measurement values MUST be finite.
- Supported temperature units are Celsius, Fahrenheit, and Kelvin. Custom
  `UnitTemperature` values MUST add `unsupportedTemperatureUnit`.
- Absolute temperatures MUST be converted to Celsius for validation and MUST
  be in `-50...80` C.
- RH MUST satisfy `0 < RH <= 100`.
- A dew point MUST be converted to Celsius, be greater than `-237.7` C, and be
  no greater than its associated temperature.
- Every range MUST have finite bounds and a strictly lower minimum after unit
  normalization.
- Temperature comfort bounds MUST normalize into `-50...80` C.
- RH comfort bounds MUST satisfy
  `0 < minimumPercent < maximumPercent <= 100`.
- Dew-point comfort bounds MUST be greater than `-237.7` C and no greater than
  80 C.
- A non-nil fresh-air interval MUST be greater than zero.
- Prediction minutes MUST be greater than zero.
- A non-nil `lastVentilatedAt` MUST be no later than `now`.

The advisor and predictor MUST calculate outdoor dew point from outdoor
temperature and relative humidity. Callers do not supply outdoor dew point.

All public operations MUST normalize supported temperature measurements to
Celsius before scientific calculations. Standalone dew-point calculation
returns its result in the supplied temperature's unit. Prediction and advisor
operations return every absolute temperature and dew point in the indoor input
temperature's unit, including outdoor values copied into `VentilationAdvice`.

## 6. Psychrometrics

Use Magnus constants:

```text
a = 17.27
b = 237.7
```

The variables ending in `C` below are internal Celsius `Double` values obtained
from validated public measurements.

Dew point from temperature and RH:

```text
alpha = (a * temperatureC) / (b + temperatureC) + ln(RH / 100)
dewPointC = (b * alpha) / (a - alpha)
```

RH from temperature and dew point:

```text
RH = 100 * exp((a * dewPointC) / (b + dewPointC))
         / exp((a * temperatureC) / (b + temperatureC))
```

Only calculated RH is clamped to `0...100`.

## 7. Comfort scoring

Lower scores are better. Values inside their accepted ranges have zero penalty.

Temperature penalty, where `d` is distance outside the range:

```text
below minimum: d
first 4 C above maximum: 0.7 * d
next 4 C: 2.8 + 1.2 * (d - 4)
beyond 8 C: 7.6 + 2.0 * (d - 8)
```

Dew-point penalty:

```text
below minimum: 0.5 * d
first 2 C above maximum: d
next 3 C: 2 + 2 * (d - 2)
beyond 5 C: 8 + 4 * (d - 5)
```

RH penalty:

```text
below minimum: 0.1 * d
first 10 percentage points above maximum: 0.2 * d
next 15 points: 2 + 0.4 * (d - 10)
beyond 25 points: 8 + 0.8 * (d - 25)
```

Use exactly one humidity penalty, selected by the
`HumidityComfortPreference` case. Normalize temperature and dew-point
measurements and ranges to Celsius before calculating distance. Combine
penalties relative to the configured maximum accepted Celsius temperature
`maxT`:

```text
temperatureC < maxT + 2:
  temperaturePenalty + 1.3 * humidityPenalty

temperatureC < maxT + 8:
  1.2 * temperaturePenalty + 1.2 * humidityPenalty

otherwise:
  1.8 * temperaturePenalty + 1.5 * humidityPenalty
```

## 8. Ventilation prediction

Air changes per hour:

```text
CLOSED = 0.0
TILTED = 0.35
OPEN = 2.0
```

These fixed rates are the initial package approximation. `WindowState`
describes only the observable opening state; it MUST NOT attempt to encode room
layout or airflow topology. Estimating ACH from wind conditions and
apartment-specific calibration is a possible future extension and is outside
the current package contract.

```text
hours = minutes / 60
mixFactor = 1 - exp(-airChangesPerHour * hours)
predictedTemp = indoorTemp + (outdoorTemp - indoorTemp) * mixFactor
predictedDewPoint = indoorDewPoint
                  + (outdoorDewPoint - indoorDewPoint) * mixFactor
```

Predicted RH MUST be reconstructed from predicted temperature and dew point.

## 9. Candidate and recommendation rules

Candidate minutes are exactly `5, 10, 15, 30, 60`, in ascending order.

- Closed windows evaluate candidates using `.open` ACH.
- Other states evaluate continued ventilation using their current ACH.
- The lowest-score candidate wins.
- Equal candidate scores MUST retain the shorter duration.
- A candidate MUST have a strictly lower score than the current state to count
  as a comfort improvement.
- Improvement while closed produces `OPEN_WINDOWS`.
- Improvement while non-closed produces `KEEP_WINDOWS_OPEN`.
- No improvement while closed produces `KEEP_WINDOWS_CLOSED`, zero minutes, while
  retaining the best rejected candidate's predicted values and score.
- No improvement while non-closed produces `CLOSE_WINDOWS`, zero minutes,
  with predicted values and score equal to the current state.

`VentilationAdvice` MUST NOT include temperature, dew-point, or score delta
properties. Each delta is derivable from the corresponding current and
predicted values. Explanation logic MAY calculate internal Celsius differences.

## 10. Fresh-air override

The override applies only when all conditions hold:

- windows are closed;
- `freshAirIntervalMinutes` is non-nil;
- `lastVentilatedAt` is non-nil;
- elapsed time is at least the configured interval;
- the best candidate does not improve comfort;
- outside air is not extremely unfavorable.

Extremely unfavorable means both:

```text
outdoorTemperatureC > indoorTemperatureC + 5
outdoorDewPointC > indoorDewPointC + 3
```

The override selects the five-minute open-window candidate.

## 11. Explanation rules

`shortReason` MUST be at most 80 characters. `detailedReason` MUST include a
plain-language category and:

```text
Expected after: {temp to 1 decimal}{unit symbol} / {RH to 1 decimal}% RH /
dew point {dew point to 1 decimal}{unit symbol}.
```

Formatting MUST be deterministic and locale-independent. Unit symbols are
exactly `°C`, `°F`, and `K`. Explanation measurements use the indoor input
temperature's unit. Numeric properties in `VentilationAdvice` remain unrounded.

Required detailed categories:

- Cooler and lower dew point: `Outdoor air improves both temperature and dew point.`
- Cooler but higher dew point with improvement: `Cooling benefit outweighs the dew point increase.`
- Warmer but lower dew point with improvement: `Drier air helps, but warming limits the benefit.`
- Strictly worse rejected candidate: `Opening would make comfort worse.`
- Equal-score rejected candidate: `Opening would not improve comfort.`
- Fresh-air override: `Short airing is useful for fresh air after several closed hours.`
- Other improvement: `Predicted comfort improves after ventilation.`

Moisture comparison wording MUST use dew point even when RH is the selected
comfort metric.

## 12. Testing and golden cases

Tests MUST use exact recommendations and minutes, `0.01` score tolerance, and
`0.1` tolerance for measurement values, RH, and dew point after conversion to
the expected unit. Reasons are checked by category substring, not full-string
equality.

Required end-to-end cases using standard settings unless specified:

1. Indoor 29 C / 60% RH, outdoor 21 C / 45% RH, closed: `OPEN_WINDOWS`,
   30 minutes, cooler-and-lower-dew-point reason.
2. Indoor 22 C / 45% RH, outdoor 31 C / 70% RH, closed:
   `KEEP_WINDOWS_CLOSED`, zero
   minutes, tied/no-improvement reason, with the five-minute rejected candidate.
3. Indoor 22 C / 45% RH, outdoor 23 C / 45% RH, closed for four hours:
   `OPEN_WINDOWS`, five minutes, fresh-air reason.
4. Indoor 22 C / 45% RH, outdoor 31 C / 70% RH, already open:
   `CLOSE_WINDOWS`, zero minutes, unchanged prediction.
5. Indoor 29 C / 45% RH, outdoor 24 C / 70% RH: standard RH settings select
   30 minutes; settings using 5...15 C dew point select 15 minutes.
6. Repeat a golden case with indoor temperature in Fahrenheit, outdoor
   temperature in Kelvin, and comfort bounds using mixed supported units.
   Recommendation, minutes, and scores MUST match the Celsius-equivalent case;
   every absolute temperature and dew point in the advice MUST use Fahrenheit.

Unit tests MUST additionally cover every formula boundary, validation error,
temperature unit and JSON representation, mixed-unit range, enum wire value,
Codable round trip, window mode, candidate tie, and fresh-air threshold
condition.

## 13. Implementation sequence

Implementation is divided into one-hour TDD stages. Each coding stage starts
with a failing Swift Testing test, adds the minimum production behavior needed
to pass, refactors only while green, runs the complete build and test suite, and
ends with a focused commit.

The stage index and individual handoff documents are maintained in
[`Documentation/ImplementationStages/`](ImplementationStages/README.md).
