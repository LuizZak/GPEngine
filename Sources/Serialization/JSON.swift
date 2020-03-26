public enum JSON: Codable {
    case dictionary([String: JSON])
    case array([JSON])
    case string(String)
    case number(Double)
    case bool(Bool)
    case null

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: JSONKey.self) {
            var dict: [String: JSON] = [:]
            for key in container.allKeys {
                dict[key.stringValue] = try container.decode(JSON.self, forKey: key)
            }
            self = .dictionary(dict)
            return
        }
        if var container = try? decoder.unkeyedContainer() {
            var array: [JSON] = []
            while !container.isAtEnd {
                array.append(try container.decode(JSON.self))
            }
            self = .array(array)
            return
        }
        let singleValue = try decoder.singleValueContainer()
        if let number = try? singleValue.decode(Double.self) {
            self = .number(number)
        } else if let number = try? singleValue.decode(Int.self) {
            self = .number(Double(number))
        } else if let string = try? singleValue.decode(String.self) {
            self = .string(string)
        } else if let bool = try? singleValue.decode(Bool.self) {
            self = .bool(bool)
        } else if singleValue.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: singleValue,
                                                   debugDescription: "Not a valid JSON value")
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .dictionary(let dict):
            var container = encoder.container(keyedBy: JSONKey.self)
            for (key, value) in dict {
                try container.encode(value, forKey: .string(key))
            }
            return
        case .array(let array):
            var container = encoder.unkeyedContainer()
            for value in array {
                try container.encode(value)
            }
            return
        case .number(let number):
            var container = encoder.singleValueContainer()
            try container.encode(number)
        case .string(let string):
            var container = encoder.singleValueContainer()
            try container.encode(string)
        case .bool(let bool):
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

    public enum JSONType: String {
        case dictionary
        case array
        case string
        case number
        case bool
        case null
    }
}

extension JSON: Equatable { }

public extension JSON {
    var dictionary: [String: JSON]? {
        switch self {
        case .dictionary(let dict):
            return dict
        default:
            return nil
        }
    }
    var array: [JSON]? {
        switch self {
        case .array(let array):
            return array
        default:
            return nil
        }
    }
    var string: String? {
        switch self {
        case .string(let string):
            return string
        default:
            return nil
        }
    }
    var double: Double? {
        switch self {
        case .number(let number):
            return number
        default:
            return nil
        }
    }
    var bool: Bool? {
        switch self {
        case .bool(let bool):
            return bool
        default:
            return nil
        }
    }
    var int: Int? {
        switch self {
        case .number(let number):
            return Int(exactly: number)
        default:
            return nil
        }
    }
    var type: JSONType {
        switch self {
        case .dictionary:
            return .dictionary
        case .array:
            return .array
        case .string:
            return .string
        case .number:
            return .number
        case .bool:
            return .bool
        case .null:
            return .null
        }
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dict: [String: JSON] = .init(minimumCapacity: elements.count)
        elements.forEach { dict[$0] = $1 }
        self = .dictionary(dict)
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Double) {
        self = .number(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(Double(value))
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .bool(value)
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

public enum JSONKey: CodingKey {
    case int(Int)
    case string(String)

    public init?(intValue: Int) {
        self = .int(intValue)
    }
    public init?(stringValue: String) {
        self = .string(stringValue)
    }

    public var intValue: Int? {
        switch self {
        case .int(let int):
            return int
        case .string:
            return nil
        }
    }

    public var stringValue: String {
        switch self {
        case .int(let int):
            return int.description
        case .string(let string):
            return string
        }
    }
}

extension JSON: Collection {
    public enum JSONIndexKey: Comparable {
        case array(Int)
        case dictionary(Dictionary<String, JSON>.Index)
        case null

        public static func == (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.array(let left), .array(let right)):
                return left == right
            case (.dictionary(let left), .dictionary(let right)):
                return left == right
            case (.null, .null):
                return true
            default:
                return false
            }
        }

        public static func < (lhs: Index, rhs: Index) -> Bool {
            switch (lhs, rhs) {
            case (.array(let left), .array(let right)):
                return left < right
            case (.dictionary(let left), .dictionary(let right)):
                return left < right
            default:
                return false
            }
        }
    }

    public typealias Index = JSONIndexKey
    public typealias Element = (String, JSON)

    public var startIndex: Index {
        switch self {
        case .array(let array):
            return .array(array.startIndex)
        case .dictionary(let dict):
            return .dictionary(dict.startIndex)
        default:
            return .null
        }
    }

    public var endIndex: Index {
        switch self {
        case .array(let array):
            return .array(array.endIndex)
        case .dictionary(let dict):
            return .dictionary(dict.endIndex)
        default:
            return .null
        }
    }

    public func index(after i: Index) -> Index {
        switch (self, i) {
        case (.array(let array), .array(let index)):
            return .array(array.index(after: index))
        case (.dictionary(let dict), .dictionary(let index)):
            return .dictionary(dict.index(after: index))
        default:
            return .null
        }
    }

    public subscript(position: Index) -> (String, JSON) {
        switch (self, position) {
        case (.array(let array), .array(let index)):
            return (String(index), array[index])
        case (.dictionary(let dict), .dictionary(let index)):
            return (dict[index].key, dict[index].value)
        default:
            return ("", .null)
        }
    }

    public subscript(key: String) -> JSON? {
        get {
            switch self {
            case .dictionary(let dict):
                return dict[key]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .dictionary(var dict):
                dict[key] = newValue
                self = .dictionary(dict)
            default:
                break
            }
        }
    }

    public subscript(index: Int) -> JSON {
        get {
            switch self {
            case .array(let array):
                return array[index]
            default:
                return .null
            }
        }
        set {
            switch self {
            case .array(var array):
                array[index] = newValue
                self = .array(array)
            default:
                break
            }
        }
    }

    public subscript(path path: JSONIndexer...) -> JSONSubscriptAccess {
        return JSONSubscriptAccess(base: self, accesses: path.map { $0.jsonIndex })
    }
}

public protocol JSONIndexer {
    var jsonIndex: JSONSubscriptAccess.JSONAccess { get }
}

extension String: JSONIndexer {
    public var jsonIndex: JSONSubscriptAccess.JSONAccess {
        return .dictionary(self)
    }
}

extension Int: JSONIndexer {
    public var jsonIndex: JSONSubscriptAccess.JSONAccess {
        return .index(self)
    }
}

public struct JSONSubscriptAccess {
    var base: JSON
    var accesses: [JSONAccess]

    public var json: JSON? {
        switch value {
        case .value(let json):
            return json
        default:
            return nil
        }
    }

    public var value: AccessResult {
        var json: JSON = base

        for (i, access) in accesses.enumerated() {
            switch access {
            case .dictionary(let key):
                if let value = json[key] {
                    json = value
                } else if json.type == .dictionary {
                    return .keyNotFound(Array(accesses[...i]))
                } else {
                    return .notADictionary(Array(accesses[..<i]))
                }
            case .index(let index):
                if let array = json.array, index < array.count {
                    json = array[index]
                } else if json.type == .array {
                    return .keyNotFound(Array(accesses[...i]))
                } else {
                    return .notAnArray(Array(accesses[..<i]))
                }
            }
        }

        return .value(json)
    }

    public enum JSONAccess: Equatable {
        case index(Int)
        case dictionary(String)
    }
    public enum AccessResult: Equatable {
        case value(JSON)
        case notAnArray([JSONAccess])
        case notADictionary([JSONAccess])
        case keyNotFound([JSONAccess])
    }
}

public protocol JSONConvertible {
    var json: JSON { get }
}

extension JSON: JSONConvertible {
    public var json: JSON { self }
}
extension String: JSONConvertible {
    public var json: JSON { .string(self) }
}
extension Double: JSONConvertible {
    public var json: JSON { .number(self) }
}
extension Int: JSONConvertible {
    public var json: JSON { .number(Double(self)) }
}
extension Bool: JSONConvertible {
    public var json: JSON { .bool(self) }
}
extension Array: JSONConvertible where Element: JSONConvertible {
    public var json: JSON { .array(self.map { $0.json }) }
}
extension Dictionary: JSONConvertible where Key == String, Value: JSONConvertible {
    public var json: JSON {
        .dictionary(self.mapValues { $0.json })
    }
}
