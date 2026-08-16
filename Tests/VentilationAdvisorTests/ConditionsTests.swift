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

    @Test(arguments: [0.0, -1.0, 100.1])
    func indoorConditionsRejectInvalidRelativeHumidityWhenDecoding(
        relativeHumidityPercent: Double
    ) {
        let json = Data("""
        {
          "temperature": {"value": 20, "unit": "CELSIUS"},
          "relativeHumidityPercent": \(relativeHumidityPercent)
        }
        """.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(IndoorConditions.self, from: json)
        }
    }

    @Test(arguments: [0.0, -1.0, 100.1])
    func outdoorConditionsRejectInvalidRelativeHumidityWhenDecoding(
        relativeHumidityPercent: Double
    ) {
        let json = Data("""
        {
          "temperature": {"value": 10, "unit": "CELSIUS"},
          "relativeHumidityPercent": \(relativeHumidityPercent),
          "dewPoint": null
        }
        """.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(OutdoorConditions.self, from: json)
        }
    }

    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let data = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
