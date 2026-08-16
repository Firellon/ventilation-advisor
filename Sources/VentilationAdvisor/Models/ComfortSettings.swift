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

extension TemperatureRange {
    private enum CodingKeys: String, CodingKey {
        case minimum
        case maximum
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            minimum: try container.decode(CodedTemperature.self, forKey: .minimum).measurement,
            maximum: try container.decode(CodedTemperature.self, forKey: .maximum).measurement
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodedTemperature(minimum), forKey: .minimum)
        try container.encode(CodedTemperature(maximum), forKey: .maximum)
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

extension HumidityComfortPreference {
    private enum CodingKeys: String, CodingKey {
        case metric
        case range
    }

    private enum Metric: String, Codable {
        case relativeHumidity = "RELATIVE_HUMIDITY"
        case dewPoint = "DEW_POINT"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Metric.self, forKey: .metric) {
        case .relativeHumidity:
            self = .relativeHumidity(try container.decode(RelativeHumidityRange.self, forKey: .range))
        case .dewPoint:
            self = .dewPoint(try container.decode(TemperatureRange.self, forKey: .range))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .relativeHumidity(let range):
            try container.encode(Metric.relativeHumidity, forKey: .metric)
            try container.encode(range, forKey: .range)
        case .dewPoint(let range):
            try container.encode(Metric.dewPoint, forKey: .metric)
            try container.encode(range, forKey: .range)
        }
    }
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
