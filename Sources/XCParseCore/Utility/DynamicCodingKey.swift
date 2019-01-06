struct DynamicCodingKey: CodingKey {
    var intValue: Int?
    var stringValue: String

    init(string: String) {
        stringValue = string
    }

    init?(intValue: Int) {
        return nil
    }

    init?(stringValue: String) {
        self.init(string: stringValue)
    }
}

extension DynamicCodingKey: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        stringValue = value
    }
}

extension DynamicCodingKey: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        intValue = value
        stringValue = ""
    }
}
