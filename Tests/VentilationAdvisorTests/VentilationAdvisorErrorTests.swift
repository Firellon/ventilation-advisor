import Foundation
import Testing

@testable import VentilationAdvisor

@Test("documented validation issues are constructible and equatable")
func documentedValidationIssuesAreConstructibleAndEquatable() {
    let invalidDewPointIssue = VentilationAdvisorValidationIssue.invalidDewPoint(
        temperature: Measurement(value: 20, unit: .celsius),
        dewPoint: Measurement(value: 21, unit: .celsius)
    )

    let issues: [VentilationAdvisorValidationIssue] = [
        .nonFiniteValue(field: "indoor.temperature.value"),
        .unsupportedTemperatureUnit(field: "indoor.temperature", symbol: "°R"),
        .temperatureOutOfRange(
            field: "indoor.temperature",
            value: Measurement(value: 81, unit: .celsius)
        ),
        .relativeHumidityOutOfRange(
            field: "indoor.relativeHumidityPercent",
            value: 0
        ),
        invalidDewPointIssue,
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
            lastVentilatedAt: Date(timeIntervalSince1970: 2),
            now: Date(timeIntervalSince1970: 1)
        ),
    ]

    #expect(issues.count == 10)
    #expect(
        invalidDewPointIssue != .invalidDewPoint(
            temperature: Measurement(value: 20, unit: .celsius),
            dewPoint: Measurement(value: 19, unit: .celsius)
        )
    )
}

@Test("advisor errors contain one or more ordered validation issues")
func advisorErrorsContainOneOrMoreOrderedValidationIssues() {
    let first = VentilationAdvisorValidationIssue.nonFiniteValue(
        field: "indoor.temperature.value"
    )
    let second = VentilationAdvisorValidationIssue.relativeHumidityOutOfRange(
        field: "indoor.relativeHumidityPercent",
        value: 0
    )

    let singleIssueError = VentilationAdvisorError(first: first)
    let multipleIssueError = VentilationAdvisorError(
        first: first,
        additional: [second]
    )

    #expect(singleIssueError.issues == [first])
    #expect(multipleIssueError.issues == [first, second])
    #expect(singleIssueError != multipleIssueError)
}
