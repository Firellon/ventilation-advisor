import Foundation
import Testing

@testable import VentilationAdvisor

struct VentilationAdviceTests {
    @Test(arguments: [
        (Recommendation.openWindows, "\"OPEN_WINDOWS\""),
        (Recommendation.closeWindows, "\"CLOSE_WINDOWS\""),
        (Recommendation.keepWindowsOpen, "\"KEEP_WINDOWS_OPEN\""),
        (Recommendation.keepWindowsClosed, "\"KEEP_WINDOWS_CLOSED\""),
    ])
    func recommendationUsesDocumentedWireValue(
        recommendation: Recommendation,
        expectedJSON: String
    ) throws {
        #expect(
            String(decoding: try JSONEncoder().encode(recommendation), as: UTF8.self)
                == expectedJSON
        )
    }

    @Test("predicted conditions round-trip preserves values and temperature units")
    func predictedConditionsRoundTripPreservesValuesAndUnits() throws {
        let conditions = PredictedConditions(
            temperature: Measurement(value: 66, unit: .fahrenheit),
            relativeHumidityPercent: 43,
            dewPoint: Measurement(value: 48, unit: .fahrenheit)
        )

        let decoded = try roundTrip(conditions)

        #expect(decoded == conditions)
        #expect(decoded.temperature.unit == .fahrenheit)
        #expect(decoded.dewPoint.unit == .fahrenheit)
    }

    @Test("complete ventilation advice round-trip preserves every value and temperature unit")
    func completeVentilationAdviceRoundTripPreservesValuesAndUnits() throws {
        let advice = VentilationAdvice(
            recommendation: .keepWindowsOpen,
            recommendedMinutes: 15,
            currentIndoorTemperature: Measurement(value: 68, unit: .fahrenheit),
            currentIndoorRelativeHumidityPercent: 41,
            currentIndoorDewPoint: Measurement(value: 50, unit: .fahrenheit),
            outdoorTemperature: Measurement(value: 280, unit: .kelvin),
            outdoorRelativeHumidityPercent: 52,
            outdoorDewPoint: Measurement(value: 3, unit: .celsius),
            predictedTemperature: Measurement(value: 66, unit: .fahrenheit),
            predictedRelativeHumidityPercent: 43,
            predictedDewPoint: Measurement(value: 48, unit: .fahrenheit),
            currentScore: 7.25,
            predictedScore: 3.5,
            shortReason: "Outdoor air should improve comfort.",
            detailedReason: "Keep the windows open for the recommended duration."
        )

        let decoded = try roundTrip(advice)

        #expect(decoded == advice)
        #expect(decoded.currentIndoorTemperature.unit == .fahrenheit)
        #expect(decoded.currentIndoorDewPoint.unit == .fahrenheit)
        #expect(decoded.outdoorTemperature.unit == .kelvin)
        #expect(decoded.outdoorDewPoint.unit == .celsius)
        #expect(decoded.predictedTemperature.unit == .fahrenheit)
        #expect(decoded.predictedDewPoint.unit == .fahrenheit)
    }

    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        let data = try JSONEncoder().encode(value)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
