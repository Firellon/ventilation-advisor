import Foundation
import Testing

import VentilationAdvisor

struct ComfortSettingsTests {
    
    let settings = ComfortSettings.standard
    
    @Test func `Standard temperature 18C-24C range`() {
        #expect(settings.temperatureRange.minimum == Measurement(value: 18, unit: UnitTemperature.celsius))
        #expect(settings.temperatureRange.maximum == Measurement(value: 24, unit: UnitTemperature.celsius))
    }
    
    @Test func `Standard fresh air interval is 180 minutes`() {
        #expect(settings.freshAirIntervalMinutes == 180)
    }
    
    @Test func `Standard humidity preference is 40%-60% relative humidity range`() {
        guard case .relativeHumidity(let range) = settings.humidityPreference else {
            Issue.record("Expected relative-humidity preference")
            return
        }

        #expect(range.minimumPercent == 40)
        #expect(range.maximumPercent == 60)
    }

    // MARK: - JSON wire representation

    @Test(arguments: [
        (.celsius, "\"unit\":\"CELSIUS\""),
        (.fahrenheit, "\"unit\":\"FAHRENHEIT\""),
        (.kelvin, "\"unit\":\"KELVIN\""),
    ] as [(UnitTemperature, String)]) 
    func `Temperature bounds encode with uppercase unit strings`(unit: UnitTemperature, expectedValue: String) throws {
        #expect(try encodedTemperatureRange(unit: unit).contains(expectedValue))
    }

    @Test(arguments: [UnitTemperature.celsius, .fahrenheit, .kelvin]) 
    func `Temperature bounds decode back to equal measurements`(unit: UnitTemperature) throws {
        let range = TemperatureRange(
            minimum: Measurement(value: 10, unit: unit),
            maximum: Measurement(value: 20, unit: unit)
        )
        let data = try JSONEncoder().encode(range)
        let decoded = try JSONDecoder().decode(TemperatureRange.self, from: data)

        #expect(decoded == range)
        #expect(decoded.minimum.unit == unit)
        #expect(decoded.maximum.unit == unit)
    }

    @Test func `Unknown temperature unit fails decoding`() {
        let json = Data("""
        {"minimum":{"value":10,"unit":"RANKINE"},"maximum":{"value":20,"unit":"CELSIUS"}}
        """.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(TemperatureRange.self, from: json)
        }
    }

    @Test func `Custom temperature unit fails encoding`() {
        let custom = UnitTemperature(symbol: "°R", converter: UnitConverterLinear(coefficient: 5.0 / 9.0))
        let range = TemperatureRange(
            minimum: Measurement(value: 10, unit: custom),
            maximum: Measurement(value: 20, unit: .celsius)
        )

        #expect(throws: EncodingError.self) {
            try JSONEncoder().encode(range)
        }
    }

    @Test func `Relative humidity preference encodes with metric discriminator`() throws {
        let preference = HumidityComfortPreference.relativeHumidity(
            RelativeHumidityRange(minimumPercent: 40, maximumPercent: 60)
        )
        let json = try encode(preference)

        #expect(json.contains("\"metric\":\"RELATIVE_HUMIDITY\""))
        #expect(json.contains("\"minimumPercent\":40"))
        #expect(json.contains("\"maximumPercent\":60"))

        let decoded = try JSONDecoder().decode(HumidityComfortPreference.self, from: Data(json.utf8))
        #expect(decoded == preference)
    }

    @Test func `Dew point preference encodes with metric discriminator and temperature range`() throws {
        let preference = HumidityComfortPreference.dewPoint(
            TemperatureRange(
                minimum: Measurement(value: 5, unit: .celsius),
                maximum: Measurement(value: 15, unit: .celsius)
            )
        )
        let json = try encode(preference)

        #expect(json.contains("\"metric\":\"DEW_POINT\""))
        #expect(json.contains("\"unit\":\"CELSIUS\""))

        let decoded = try JSONDecoder().decode(HumidityComfortPreference.self, from: Data(json.utf8))
        #expect(decoded == preference)
    }

    @Test func `Mixed-unit temperature range round-trips without normalization`() throws {
        let range = TemperatureRange(
            minimum: Measurement(value: 5, unit: .celsius),
            maximum: Measurement(value: 300, unit: .kelvin)
        )
        let data = try JSONEncoder().encode(range)
        let decoded = try JSONDecoder().decode(TemperatureRange.self, from: data)

        #expect(decoded.minimum.unit == .celsius)
        #expect(decoded.minimum.value == 5)
        #expect(decoded.maximum.unit == .kelvin)
        #expect(decoded.maximum.value == 300)
    }

    // MARK: - Helpers

    private func encode<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return String(decoding: try encoder.encode(value), as: UTF8.self)
    }

    private func encodedTemperatureRange(unit: UnitTemperature) throws -> String {
        try encode(
            TemperatureRange(
                minimum: Measurement(value: 10, unit: unit),
                maximum: Measurement(value: 20, unit: unit)
            )
        )
    }
}
