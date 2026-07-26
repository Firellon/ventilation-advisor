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
- Tests MUST use Swift Testing.
- Public domain data models MUST conform to `Codable`, `Equatable`, and
  `Sendable`.
- `VentilationAdvisorError` MUST conform to `Error`, `Equatable`, and
  `Sendable`; errors are not part of the Codable interchange model.
- Public stateless namespaces MUST be caseless enums.
- Public APIs MUST use `Int`, not fixed-width integer types, for timestamps,
  intervals, and recommended minutes.

Suggested source responsibilities:

```text
Sources/VentilationAdvisor/
  Models/
  Science/
  Advisor/
Tests/VentilationAdvisorTests/
```

## 3. Public API

```swift
public struct VentilationAdvisor: Sendable {
    public init()
    public func assess(_ input: VentilationInput) throws -> VentilationAdvice
}
```

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

```swift
public enum ComfortScorer {
    public static func score(
        temperatureC: Double,
        relativeHumidityPercent: Double,
        dewPointC: Double,
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

All JSON keys use the Swift property names shown below. Enum raw values use the
uppercase strings shown in parentheses.

```text
ComfortRange
  minimum: Double
  maximum: Double

HumidityMetric
  relativeHumidity (RELATIVE_HUMIDITY)
  dewPoint (DEW_POINT)

HumidityComfortPreference
  metric: HumidityMetric
  range: ComfortRange

ComfortSettings
  temperatureRangeC: ComfortRange
  humidityPreference: HumidityComfortPreference
  freshAirIntervalMinutes: Int?

IndoorConditions
  temperatureC: Double
  relativeHumidityPercent: Double

OutdoorConditions
  temperatureC: Double
  relativeHumidityPercent: Double
  dewPointC: Double?

WindowState
  closed (CLOSED)
  tilted (TILTED)
  open (OPEN)

VentilationInput
  indoor: IndoorConditions
  outdoor: OutdoorConditions
  windowState: WindowState
  comfortSettings: ComfortSettings
  lastVentilatedAtMillis: Int?
  nowMillis: Int

Recommendation
  openWindows (OPEN_WINDOWS)
  closeWindows (CLOSE_WINDOWS)
  keepWindowsOpen (KEEP_WINDOWS_OPEN)
  keepWindowsClosed (KEEP_WINDOWS_CLOSED)

PredictedConditions
  temperatureC: Double
  relativeHumidityPercent: Double
  dewPointC: Double

VentilationAdvice
  recommendation: Recommendation
  recommendedMinutes: Int
  currentIndoorTempC: Double
  currentIndoorRelativeHumidityPercent: Double
  currentIndoorDewPointC: Double
  outdoorTempC: Double
  outdoorRelativeHumidityPercent: Double
  outdoorDewPointC: Double
  predictedTempC: Double
  predictedRelativeHumidityPercent: Double
  predictedDewPointC: Double
  currentScore: Double
  predictedScore: Double
  temperatureDeltaC: Double
  dewPointDeltaC: Double
  scoreDelta: Double
  shortReason: String
  detailedReason: String
```

`ComfortSettings.standard` MUST be 18...24 C, 40...60% RH, and a 180-minute
fresh-air interval.

Example comfort-settings JSON:

```json
{
  "temperatureRangeC": { "minimum": 18.0, "maximum": 24.0 },
  "humidityPreference": {
    "metric": "RELATIVE_HUMIDITY",
    "range": { "minimum": 40.0, "maximum": 60.0 }
  },
  "freshAirIntervalMinutes": 180
}
```

## 5. Validation and errors

Public operations MUST throw `VentilationAdvisorError`; they MUST NOT trap or
silently repair invalid caller data.

Required error categories:

```swift
public enum VentilationAdvisorError: Error, Equatable, Sendable {
    case nonFiniteValue(field: String)
    case temperatureOutOfRange(field: String, value: Double)
    case relativeHumidityOutOfRange(field: String, value: Double)
    case invalidDewPoint(temperatureC: Double, dewPointC: Double)
    case invalidComfortRange(field: String, minimum: Double, maximum: Double)
    case invalidFreshAirInterval(minutes: Int)
    case invalidDuration(minutes: Int)
    case invalidTimeRange(lastVentilatedAtMillis: Int?, nowMillis: Int)
}
```

Rules:

- All floating-point inputs MUST be finite.
- Temperatures MUST be in `-50...80` C.
- RH MUST satisfy `0 < RH <= 100`.
- A dew point used for inverse Magnus MUST be greater than `-237.7` C and no
  greater than its temperature.
- Every comfort range MUST be finite and have `minimum < maximum`.
- Temperature comfort bounds MUST be in `-50...80` C.
- RH comfort bounds MUST satisfy `0 < minimum < maximum <= 100`.
- Dew-point comfort bounds MUST be greater than `-237.7` C and no greater than
  80 C.
- A non-nil fresh-air interval MUST be greater than zero.
- Prediction minutes MUST be greater than zero.
- `nowMillis` and a non-nil `lastVentilatedAtMillis` MUST be nonnegative, and
  the last-ventilated time MUST be no later than `nowMillis`.

If outdoor dew point is absent, the advisor and predictor MUST calculate it. If
it is present, they MUST validate and use the supplied value.

## 6. Psychrometrics

Use Magnus constants:

```text
a = 17.27
b = 237.7
```

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

Use exactly one humidity penalty, selected by `HumidityMetric`. Combine penalties
relative to the configured maximum accepted temperature `maxT`:

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

Derived values:

```text
temperatureDeltaC = predictedTempC - currentIndoorTempC
dewPointDeltaC = predictedDewPointC - currentIndoorDewPointC
scoreDelta = currentScore - predictedScore
```

## 10. Fresh-air override

The override applies only when all conditions hold:

- windows are closed;
- `freshAirIntervalMinutes` is non-nil;
- `lastVentilatedAtMillis` is non-nil;
- elapsed time is at least the configured interval;
- the best candidate does not improve comfort;
- outside air is not extremely unfavorable.

Extremely unfavorable means both:

```text
outdoorTempC > indoorTempC + 5
outdoorDewPointC > indoorDewPointC + 3
```

The override selects the five-minute open-window candidate.

## 11. Explanation rules

`shortReason` MUST be at most 80 characters. `detailedReason` MUST include a
plain-language category and:

```text
Expected after: {temp to 1 decimal} C / {RH to 1 decimal}% RH / dew point
{dew point to 1 decimal} C.
```

Formatting MUST be deterministic and locale-independent. Numeric properties in
`VentilationAdvice` remain unrounded.

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
`0.1` tolerance for temperatures, RH, and dew point. Reasons are checked by
category substring, not full-string equality.

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

Unit tests MUST additionally cover every formula boundary, validation error,
enum wire value, Codable round trip, window mode, candidate tie, and fresh-air
threshold condition.

## 13. Implementation sequence

Implementation is divided into one-hour TDD stages. Each coding stage starts
with a failing Swift Testing test, adds the minimum production behavior needed
to pass, refactors only while green, runs the complete build and test suite, and
ends with a focused commit.

The stage index and individual handoff documents are maintained in
[`Documentation/ImplementationStages/`](ImplementationStages/README.md).
