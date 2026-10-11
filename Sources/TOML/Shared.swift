struct TOMLCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }
}

// TOML integers are signed 64-bit values. Invalid conversions must throw,
// including in narrow Swift integer types and unsigned configuration fields.
func decodeTOMLInteger<T: FixedWidthInteger>(
    _ value: Int64,
    as type: T.Type,
    codingPath: [any CodingKey]
) throws -> T {
    guard let result = T(exactly: value) else {
        throw TOMLDecodingError.dataCorrupted(
            message: "TOML integer \(value) is outside the range of \(type)",
            codingPath: codingPath
        )
    }
    return result
}

func encodeTOMLInteger<T: BinaryInteger>(
    _ value: T,
    codingPath: [any CodingKey]
) throws -> Int64 {
    guard let result = Int64(exactly: value) else {
        throw TOMLEncodingError.invalidValue(
            "Integer \(value) is outside the signed 64-bit TOML range",
            codingPath: codingPath
        )
    }
    return result
}
