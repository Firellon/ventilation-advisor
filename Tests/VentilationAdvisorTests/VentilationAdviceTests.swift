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

    @Test(arguments: [0.0, -1.0, 100.1])
    func predictedConditionsRejectInvalidRelativeHumidityWhenDecoding(
        relativeHumidityPercent: Double
    ) {
        let json = Data("""
        {
          "temperature": {"value": 20, "unit": "CELSIUS"},
          "relativeHumidityPercent": \(relativeHumidityPercent),
          "dewPoint": {"value": 10, "unit": "CELSIUS"}
        }
        """.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(PredictedConditions.self, from: json)
        }
    }
}
