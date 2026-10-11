import Testing
import TOML

@Suite("Integer range safety")
struct IntegerRangeTests {
    struct Keyed<T: Codable>: Codable { let value: T }
    struct ArrayValue<T: Codable>: Codable { let values: [T] }
    struct Single<T: Codable>: Codable {
        let value: T
        init(_ value: T) { self.value = value }
        init(from decoder: any Decoder) throws {
            value = try decoder.singleValueContainer().decode(T.self)
        }
        func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value)
        }
    }

    private func reject<T: FixedWidthInteger & Codable>(_ type: T.Type, literal: String) throws {
        for action in [
            { _ = try TOMLDecoder().decode(Keyed<T>.self, from: "value = \(literal)") },
            { _ = try TOMLDecoder().decode(ArrayValue<T>.self, from: "values = [0, \(literal)]") },
            { _ = try TOMLDecoder().decode(Keyed<Single<T>>.self, from: "value = \(literal)") },
        ] {
            #expect(throws: TOMLDecodingError.self) { try action() }
        }
    }

    @Test func outOfRangeIntegersThrow() throws {
        try reject(Int8.self, literal: "128")
        try reject(Int8.self, literal: "-129")
        try reject(Int16.self, literal: "32768")
        try reject(Int32.self, literal: "2147483648")
        try reject(UInt8.self, literal: "256")
        try reject(UInt16.self, literal: "65536")
        try reject(UInt32.self, literal: "4294967296")
        try reject(UInt8.self, literal: "-1")
        try reject(UInt16.self, literal: "-1")
        try reject(UInt32.self, literal: "-1")
        try reject(UInt64.self, literal: "-1")
        try reject(UInt.self, literal: "-1")
    }

    @Test func unsignedEncodingOverflowThrows() throws {
        #expect(throws: TOMLEncodingError.self) {
            try TOMLEncoder().encode(Keyed(value: UInt64.max))
        }
        #expect(throws: TOMLEncodingError.self) {
            try TOMLEncoder().encode(ArrayValue(values: [UInt64(0), .max]))
        }
        #expect(throws: TOMLEncodingError.self) {
            try TOMLEncoder().encode(Keyed(value: Single(UInt64.max)))
        }
        if UInt.bitWidth == 64 {
            #expect(throws: TOMLEncodingError.self) {
                try TOMLEncoder().encode(Keyed(value: UInt.max))
            }
        }
    }

    @Test func validIntegerBoundariesRoundTrip() throws {
        func roundTrip<T: FixedWidthInteger & Codable>(_ value: T) throws {
            let encoded = try TOMLEncoder().encode(Keyed(value: value))
            let decoded = try TOMLDecoder().decode(Keyed<T>.self, from: encoded)
            #expect(decoded.value == value)
        }
        try roundTrip(Int8.min)
        try roundTrip(Int8.max)
        try roundTrip(Int16.min)
        try roundTrip(Int16.max)
        try roundTrip(Int32.min)
        try roundTrip(Int32.max)
        try roundTrip(Int64.min)
        try roundTrip(Int64.max)
        try roundTrip(Int.min)
        try roundTrip(Int.max)
        try roundTrip(UInt8.max)
        try roundTrip(UInt16.max)
        try roundTrip(UInt32.max)
        try roundTrip(UInt64(Int64.max))
        try roundTrip(UInt(0))
    }

    @Test func errorsRetainFieldAndArrayPaths() throws {
        do {
            _ = try TOMLDecoder().decode(ArrayValue<UInt16>.self, from: "values = [0, 65536]")
            Issue.record("Expected an out-of-range error")
        } catch TOMLDecodingError.dataCorrupted(_, let path) {
            #expect(path.map(\.stringValue) == ["values", "Index 1"])
        }
        do {
            _ = try TOMLEncoder().encode(ArrayValue(values: [UInt64(0), .max]))
            Issue.record("Expected an out-of-range error")
        } catch TOMLEncodingError.invalidValue(_, let path) {
            #expect(path.map(\.stringValue) == ["values", "Index 1"])
        }
    }
}
