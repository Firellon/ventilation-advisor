import Foundation

public struct IndoorConditions: Codable, Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let relativeHumidityPercent: Double

    public init(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double
    ) {
        self.temperature = temperature
        self.relativeHumidityPercent = relativeHumidityPercent
    }
}

extension IndoorConditions {
    private enum CodingKeys: String, CodingKey {
        case temperature
        case relativeHumidityPercent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            temperature: try container.decode(CodedTemperature.self, forKey: .temperature).measurement,
            relativeHumidityPercent: try container.decodeRelativeHumidity(forKey: .relativeHumidityPercent)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodedTemperature(temperature), forKey: .temperature)
        try container.encode(relativeHumidityPercent, forKey: .relativeHumidityPercent)
    }
}

public struct OutdoorConditions: Codable, Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let relativeHumidityPercent: Double

    public init(
        temperature: Measurement<UnitTemperature>,
        relativeHumidityPercent: Double
    ) {
        self.temperature = temperature
        self.relativeHumidityPercent = relativeHumidityPercent
    }
}

extension OutdoorConditions {
    private enum CodingKeys: String, CodingKey {
        case temperature
        case relativeHumidityPercent
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            temperature: try container.decode(CodedTemperature.self, forKey: .temperature).measurement,
            relativeHumidityPercent: try container.decodeRelativeHumidity(forKey: .relativeHumidityPercent)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodedTemperature(temperature), forKey: .temperature)
        try container.encode(relativeHumidityPercent, forKey: .relativeHumidityPercent)
    }
}

public enum WindowState: String, Codable, Equatable, Sendable {
    case closed = "CLOSED"
    case tilted = "TILTED"
    case open = "OPEN"
}

public struct VentilationInput: Codable, Equatable, Sendable {
    public let indoor: IndoorConditions
    public let outdoor: OutdoorConditions
    public let windowState: WindowState
    public let comfortSettings: ComfortSettings
    public let lastVentilatedAt: Date?
    public let now: Date

    public init(
        indoor: IndoorConditions,
        outdoor: OutdoorConditions,
        windowState: WindowState,
        comfortSettings: ComfortSettings,
        lastVentilatedAt: Date?,
        now: Date = .now
    ) {
        self.indoor = indoor
        self.outdoor = outdoor
        self.windowState = windowState
        self.comfortSettings = comfortSettings
        self.lastVentilatedAt = lastVentilatedAt
        self.now = now
    }
}
