import Foundation
import Testing

@testable import VentilationAdvisor

@Test("documented advisor errors are constructible and equatable")
func documentedAdvisorErrorsAreConstructibleAndEquatable() {
    let errors: [VentilationAdvisorError] = [
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
        .invalidTimeRange(lastVentilatedAtMillis: 2, nowMillis: 1),
    ]

    #expect(errors.count == 10)
    #expect(errors[0] == .nonFiniteValue(field: "indoor.temperature.value"))
    #expect(
        errors[4] != .invalidDewPoint(
            temperature: Measurement(value: 20, unit: .celsius),
            dewPoint: Measurement(value: 19, unit: .celsius)
        )
    )
}
