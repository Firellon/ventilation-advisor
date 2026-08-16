import Foundation

public enum Recommendation: String, Codable, Equatable, Sendable {
    case openWindows = "OPEN_WINDOWS"
    case closeWindows = "CLOSE_WINDOWS"
    case keepWindowsOpen = "KEEP_WINDOWS_OPEN"
    case keepWindowsClosed = "KEEP_WINDOWS_CLOSED"
}

public struct PredictedConditions: Codable, Equatable, Sendable {
    public let temperature: Measurement<UnitTemperature>
    public let relativeHumidityPercent: Double
    public let dewPoint: Measurement<UnitTemperature>
}

extension PredictedConditions {
    private enum CodingKeys: String, CodingKey {
        case temperature
        case relativeHumidityPercent
        case dewPoint
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        temperature = try container.decode(CodedTemperature.self, forKey: .temperature).measurement
        relativeHumidityPercent = try container.decode(Double.self, forKey: .relativeHumidityPercent)
        dewPoint = try container.decode(CodedTemperature.self, forKey: .dewPoint).measurement
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(CodedTemperature(temperature), forKey: .temperature)
        try container.encode(relativeHumidityPercent, forKey: .relativeHumidityPercent)
        try container.encode(CodedTemperature(dewPoint), forKey: .dewPoint)
    }
}

public struct VentilationAdvice: Codable, Equatable, Sendable {
    public let recommendation: Recommendation
    public let recommendedMinutes: Int
    public let currentIndoorTemperature: Measurement<UnitTemperature>
    public let currentIndoorRelativeHumidityPercent: Double
    public let currentIndoorDewPoint: Measurement<UnitTemperature>
    public let outdoorTemperature: Measurement<UnitTemperature>
    public let outdoorRelativeHumidityPercent: Double
    public let outdoorDewPoint: Measurement<UnitTemperature>
    public let predictedTemperature: Measurement<UnitTemperature>
    public let predictedRelativeHumidityPercent: Double
    public let predictedDewPoint: Measurement<UnitTemperature>
    public let currentScore: Double
    public let predictedScore: Double
    public let shortReason: String
    public let detailedReason: String
}

extension VentilationAdvice {
    private enum CodingKeys: String, CodingKey {
        case recommendation
        case recommendedMinutes
        case currentIndoorTemperature
        case currentIndoorRelativeHumidityPercent
        case currentIndoorDewPoint
        case outdoorTemperature
        case outdoorRelativeHumidityPercent
        case outdoorDewPoint
        case predictedTemperature
        case predictedRelativeHumidityPercent
        case predictedDewPoint
        case currentScore
        case predictedScore
        case shortReason
        case detailedReason
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        recommendation = try container.decode(Recommendation.self, forKey: .recommendation)
        recommendedMinutes = try container.decode(Int.self, forKey: .recommendedMinutes)
        currentIndoorTemperature = try container.decode(CodedTemperature.self, forKey: .currentIndoorTemperature).measurement
        currentIndoorRelativeHumidityPercent = try container.decode(Double.self, forKey: .currentIndoorRelativeHumidityPercent)
        currentIndoorDewPoint = try container.decode(CodedTemperature.self, forKey: .currentIndoorDewPoint).measurement
        outdoorTemperature = try container.decode(CodedTemperature.self, forKey: .outdoorTemperature).measurement
        outdoorRelativeHumidityPercent = try container.decode(Double.self, forKey: .outdoorRelativeHumidityPercent)
        outdoorDewPoint = try container.decode(CodedTemperature.self, forKey: .outdoorDewPoint).measurement
        predictedTemperature = try container.decode(CodedTemperature.self, forKey: .predictedTemperature).measurement
        predictedRelativeHumidityPercent = try container.decode(Double.self, forKey: .predictedRelativeHumidityPercent)
        predictedDewPoint = try container.decode(CodedTemperature.self, forKey: .predictedDewPoint).measurement
        currentScore = try container.decode(Double.self, forKey: .currentScore)
        predictedScore = try container.decode(Double.self, forKey: .predictedScore)
        shortReason = try container.decode(String.self, forKey: .shortReason)
        detailedReason = try container.decode(String.self, forKey: .detailedReason)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(recommendation, forKey: .recommendation)
        try container.encode(recommendedMinutes, forKey: .recommendedMinutes)
        try container.encode(CodedTemperature(currentIndoorTemperature), forKey: .currentIndoorTemperature)
        try container.encode(currentIndoorRelativeHumidityPercent, forKey: .currentIndoorRelativeHumidityPercent)
        try container.encode(CodedTemperature(currentIndoorDewPoint), forKey: .currentIndoorDewPoint)
        try container.encode(CodedTemperature(outdoorTemperature), forKey: .outdoorTemperature)
        try container.encode(outdoorRelativeHumidityPercent, forKey: .outdoorRelativeHumidityPercent)
        try container.encode(CodedTemperature(outdoorDewPoint), forKey: .outdoorDewPoint)
        try container.encode(CodedTemperature(predictedTemperature), forKey: .predictedTemperature)
        try container.encode(predictedRelativeHumidityPercent, forKey: .predictedRelativeHumidityPercent)
        try container.encode(CodedTemperature(predictedDewPoint), forKey: .predictedDewPoint)
        try container.encode(currentScore, forKey: .currentScore)
        try container.encode(predictedScore, forKey: .predictedScore)
        try container.encode(shortReason, forKey: .shortReason)
        try container.encode(detailedReason, forKey: .detailedReason)
    }
}
