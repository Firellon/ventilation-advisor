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
}
