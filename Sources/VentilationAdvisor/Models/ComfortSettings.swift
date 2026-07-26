import Foundation

/// A closed range of absolute temperatures accepted as comfortable.
///
/// Bounds may use different supported units; they are not normalized here.
public struct TemperatureRange: Codable, Equatable, Sendable {
    public let minimum: Measurement<UnitTemperature>
    public let maximum: Measurement<UnitTemperature>
    
    public init(minimum: Measurement<UnitTemperature>, maximum: Measurement<UnitTemperature>) {
        self.minimum = minimum
        self.maximum = maximum
    }
}

/// A closed range of relative humidity percentages accepted as comfortable.
public struct RelativeHumidityRange: Codable, Equatable, Sendable {
    public let minimumPercent: Double
    public let maximumPercent: Double
    
    public init(minimumPercent: Double, maximumPercent: Double) {
        self.minimumPercent = minimumPercent
        self.maximumPercent = maximumPercent
    }
}

/// The humidity metric a caller wants comfort judged by, with its accepted range.
public enum HumidityComfortPreference: Codable, Equatable, Sendable {
    case relativeHumidity(RelativeHumidityRange)
    case dewPoint(TemperatureRange)
}

/// The caller-owned comfort contract the advisor scores conditions against.
public struct ComfortSettings: Codable, Equatable, Sendable {
    public let temperatureRange: TemperatureRange
    public let humidityPreference: HumidityComfortPreference
    public let freshAirIntervalMinutes: Int?
    
    public init(
        temperatureRange: TemperatureRange,
        humidityPreference: HumidityComfortPreference,
        freshAirIntervalMinutes: Int?
    ) {
        self.temperatureRange = temperatureRange
        self.humidityPreference = humidityPreference
        self.freshAirIntervalMinutes = freshAirIntervalMinutes
    }
    
    /// The documented defaults: 18...24 C, 40...60% RH, and a 180-minute fresh-air interval.
    public static let standard = ComfortSettings(
        temperatureRange: TemperatureRange(
            minimum: Measurement(value: 18, unit: .celsius),
            maximum: Measurement(value: 24, unit: .celsius)
        ),
        humidityPreference: .relativeHumidity(
            RelativeHumidityRange(
                minimumPercent: 40,
                maximumPercent: 60
            )
        ),
        freshAirIntervalMinutes: 180
    )
}
