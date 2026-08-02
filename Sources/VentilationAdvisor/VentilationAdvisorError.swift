import Foundation

public enum VentilationAdvisorError: Error, Equatable, Sendable {
    case nonFiniteValue(field: String)
    case unsupportedTemperatureUnit(field: String, symbol: String)
    case temperatureOutOfRange(
        field: String,
        value: Measurement<UnitTemperature>
    )
    case relativeHumidityOutOfRange(field: String, value: Double)
    case invalidDewPoint(
        temperature: Measurement<UnitTemperature>,
        dewPoint: Measurement<UnitTemperature>
    )
    case invalidTemperatureRange(
        field: String,
        minimum: Measurement<UnitTemperature>,
        maximum: Measurement<UnitTemperature>
    )
    case invalidRelativeHumidityRange(
        field: String,
        minimumPercent: Double,
        maximumPercent: Double
    )
    case invalidFreshAirInterval(minutes: Int)
    case invalidDuration(minutes: Int)
    case invalidTimeRange(lastVentilatedAtMillis: Int?, nowMillis: Int)
}
