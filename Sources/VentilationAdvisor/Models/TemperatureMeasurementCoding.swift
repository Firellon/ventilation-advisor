import Foundation

/// The wire representation of a single absolute temperature: `{ "value", "unit" }`.
///
/// This internal helper owns the wire-only unit enum and the mapping between it and
/// Foundation's `UnitTemperature`. Public models delegate their measurement fields here
/// so package JSON never exposes Foundation's synthesized `Measurement` representation.
struct CodedTemperature: Codable {
    let measurement: Measurement<UnitTemperature>

    init(_ measurement: Measurement<UnitTemperature>) {
        self.measurement = measurement
    }

    private enum CodingKeys: String, CodingKey {
        case value
        case unit
    }

    /// The only supported unit strings on the wire.
    private enum WireUnit: String {
        case celsius = "CELSIUS"
        case fahrenheit = "FAHRENHEIT"
        case kelvin = "KELVIN"

        /// Maps a Foundation unit onto the wire enum.
        ///
        /// `UnitTemperature` is a class rather than an enum, so this switch cannot be
        /// exhaustive; anything outside the three supported cases fails encoding.
        init(_ unit: UnitTemperature) throws {
            switch unit {
            case .celsius: self = .celsius
            case .fahrenheit: self = .fahrenheit
            case .kelvin: self = .kelvin
            default:
                throw EncodingError.invalidValue(
                    unit,
                    EncodingError.Context(
                        codingPath: [],
                        debugDescription: "Unsupported temperature unit \"\(unit.symbol)\"."
                    )
                )
            }
        }

        var unit: UnitTemperature {
            switch self {
            case .celsius: .celsius
            case .fahrenheit: .fahrenheit
            case .kelvin: .kelvin
            }
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(Double.self, forKey: .value)
        let symbol = try container.decode(String.self, forKey: .unit)

        guard let wireUnit = WireUnit(rawValue: symbol) else {
            throw DecodingError.dataCorruptedError(
                forKey: .unit,
                in: container,
                debugDescription: "Unsupported temperature unit \"\(symbol)\"."
            )
        }

        measurement = Measurement(value: value, unit: wireUnit.unit)
    }

    func encode(to encoder: Encoder) throws {
        let wireUnit = try WireUnit(measurement.unit)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(measurement.value, forKey: .value)
        try container.encode(wireUnit.rawValue, forKey: .unit)
    }
}


extension KeyedDecodingContainer {
    func decodeRelativeHumidity(forKey key: Key) throws -> Double {
        let value = try decode(Double.self, forKey: key)

        guard value.isFinite, value > 0, value <= 100 else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Relative humidity must be finite and greater than 0 through 100 percent."
            )
        }

        return value
    }
}
