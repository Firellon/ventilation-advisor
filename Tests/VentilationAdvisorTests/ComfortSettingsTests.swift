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
}
