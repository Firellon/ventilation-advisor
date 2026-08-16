import Foundation
import Testing

@testable import VentilationAdvisor

struct ConditionsTests {
    @Test(arguments: [
        (WindowState.closed, "\"CLOSED\""),
        (WindowState.tilted, "\"TILTED\""),
        (WindowState.open, "\"OPEN\""),
    ])
    func windowStateUsesDocumentedWireValue(state: WindowState, expectedJSON: String) throws {
        #expect(String(decoding: try JSONEncoder().encode(state), as: UTF8.self) == expectedJSON)
    }

    @Test("condition models preserve the caller's temperature units")
    func conditionModelsPreserveTemperatureUnits() throws {
        let indoor = IndoorConditions(
            temperature: Measurement(value: 68, unit: .fahrenheit),
            relativeHumidityPercent: 45
        )
        let outdoor = OutdoorConditions(
            temperature: Measurement(value: 280, unit: .kelvin),
            relativeHumidityPercent: 70,
            dewPoint: Measurement(value: 3, unit: .celsius)
        )

        let decodedIndoor = try roundTrip(indoor)
        let decodedOutdoor = try roundTrip(outdoor)

        #expect(decodedIndoor.temperature.unit == .fahrenheit)
        #expect(decodedIndoor.temperature.value == 68)
        #expect(decodedOutdoor.temperature.unit == .kelvin)
        #expect(decodedOutdoor.temperature.value == 280)
        #expect(decodedOutdoor.dewPoint?.unit == .celsius)
        #expect(decodedOutdoor.dewPoint?.value == 3)
    }

    @Test("ventilation input round-trip preserves every value and temperature unit")
    func ventilationInputRoundTripPreservesValuesAndUnits() throws {
        let input = VentilationInput(
            indoor: IndoorConditions(
                temperature: Measurement(value: 68, unit: .fahrenheit),
                relativeHumidityPercent: 45
            ),
            outdoor: OutdoorConditions(
                temperature: Measurement(value: 280, unit: .kelvin),
                relativeHumidityPercent: 70,
                dewPoint: Measurement(value: 3, unit: .celsius)
            ),
            windowState: .open,
            comfortSettings: ComfortSettings(
                temperatureRange: TemperatureRange(
                    minimum: Measurement(value: 64, unit: .fahrenheit),
                    maximum: Measurement(value: 297, unit: .kelvin)
                ),
                humidityPreference: .relativeHumidity(
                    RelativeHumidityRange(minimumPercent: 40, maximumPercent: 60)
                ),
                freshAirIntervalMinutes: 180
            ),
            lastVentilatedAtMillis: 1_725_000_000_000,
            nowMillis: 1_725_000_900_000
        )

        let decoded = try roundTrip(input)

        #expect(decoded == input)
        #expect(decoded.indoor.temperature.unit == .fahrenheit)
        #expect(decoded.outdoor.temperature.unit == .kelvin)
        #expect(decoded.outdoor.dewPoint?.unit == .celsius)
        #expect(decoded.comfortSettings.temperatureRange.minimum.unit == .fahrenheit)
        #expect(decoded.comfortSettings.temperatureRange.maximum.unit == .kelvin)
    }

    @Test("ventilation input round-trip preserves absent optional values")
    func ventilationInputRoundTripPreservesAbsentOptionals() throws {
        let input = VentilationInput(
            indoor: IndoorConditions(
                temperature: Measurement(value: 21, unit: .celsius),
                relativeHumidityPercent: 50
            ),
            outdoor: OutdoorConditions(
                temperature: Measurement(value: 12, unit: .celsius),
                relativeHumidityPercent: 65,
                dewPoint: nil
            ),
            windowState: .closed,
            comfortSettings: .standard,
            lastVentilatedAtMillis: nil,
            nowMillis: 1_725_000_900_000
        )

        let decoded = try roundTrip(input)

        #expect(decoded == input)
        #expect(decoded.outdoor.dewPoint == nil)
        #expect(decoded.lastVentilatedAtMillis == nil)
    }

    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let data = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
