// JSON.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

@_exported import C7

extension JSON {
    public enum JSONError: Error {
        case incompatibleType
    }
}

extension JSON {
    public static func infer(_ value: Bool) -> JSON {
        return .boolean(value)
    }

    public static func infer(_ value: Int) -> JSON {
        return .number(JSON.Number.integer(value))
    }

    public static func infer(_ value: UInt) -> JSON {
        return .number(JSON.Number.unsignedInteger(value))
    }

    public static func infer(_ value: Double) -> JSON {
        return .number(JSON.Number.double(value))
    }

    public static func infer(_ value: String) -> JSON {
        return .string(value)
    }

    public static func infer(_ value: [JSON]) -> JSON {
        return .array(value)
    }

    public static func infer(_ value: [String: JSON]) -> JSON {
        return .object(value)
    }
}

extension JSON {
    public var isBool: Bool {
        if case .boolean = self {
            return true
        }
        return false
    }

    public var isNumber: Bool {
        if case .number = self {
            return true
        }
        return false
    }

    public var isString: Bool {
        if case .string = self {
            return true
        }
        return false
    }

    public var isArray: Bool {
        if case .array = self {
            return true
        }
        return false
    }

    public var isDictionary: Bool {
        if case .object = self {
            return true
        }
        return false
    }
}

extension JSON {
    public func get<T>() throws -> T {
        switch self {
        case .boolean(let value as T):
            return value
        case .number(let value):
            switch value {
                case .integer(let value as T):
                    return value
                case .unsignedInteger(let value as T):
                    return value
                case .double(let value as T):
                    return value
                default: break
            }

        case .string(let value as T):
            return value
        case .array(let value as T):
            return value
        case .object(let value as T):
            return value
        default: break
        }
        throw JSONError.incompatibleType
    }

    public func get<T>(_ key: String) throws -> T {
        if let value = self[key] {
            return try value.get()
        }

        throw JSONError.incompatibleType
    }

    public func get<T>() -> T? {
        return try? get()
    }
}

extension JSON {
    public var booleanValue: Bool? {
        return try? get()
    }

    public var doubleValue: Double? {
        return try? get()
    }

    public var intValue: Int? {
        return try? get()
    }

    public var uintValue: UInt? {
        return try? get()
    }

    public var stringValue: String? {
        return try? get()
    }

    public var dataValue: Data? {
        return try? get()
    }

    public var arrayValue: [JSON]? {
        return try? get()
    }

    public var objectValue: [String: JSON]? {
        return try? get()
    }
}

extension JSON {
    public func asBool() throws -> Bool {
        return try get()
    }

    public func asDouble() throws -> Double {
        return try get()
    }

    public func asInt() throws -> Int {
        return try get()
    }

    public func asUInt() throws -> UInt {
        if let uint = uintValue {
            return UInt(uint)
        }
        throw JSONError.incompatibleType
    }

    public func asString() throws -> String {
        return try get()
    }

    public func asData() throws -> Data {
        return try get()
    }

    public func asArray() throws -> [JSON] {
        return try get()
    }

    public func asDictionary() throws -> [String: JSON] {
        return try get()
    }
}

extension JSON {
    public subscript(index: Int) -> C7.JSON? {
        get {
            guard let array = arrayValue, index >= 0 && index < array.count else {
                return nil
            }
            return array[index]
        }

        set(JSON) {
            switch self {
            case .array(let array):
                var array = array
                if index >= 0 && index < array.count {
                    array[index] = JSON ?? .null
                    self = .array(array)
                }
            default:
                 break
            }
        }
    }

    public subscript(key: String) -> C7.JSON? {
        get {
            return objectValue?[key]
        }

        set(JSON) {
            switch self {
            case .object(let object):
                var object = object
                object[key] = JSON
                self = .object(object)
            default: break
            }
        }
    }
}

extension JSON.Number: Equatable {}

public func ==(lhs: JSON.Number, rhs: JSON.Number) -> Bool {
    switch (lhs, rhs) {
    case (.integer(let l), .integer(let r)) where l == r:
        return true
    case (.unsignedInteger(let l), .unsignedInteger(let r)) where l == r:
        return true
    case (.double(let l), .double(let r)) where l == r:
        return true
    default:
        return false
    }
}

extension JSON: Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch (lhs, rhs) {
    case (.null, .null):
        return true
    case (.boolean(let l), .boolean(let r)) where l == r:
        return true
    case (.string(let l), .string(let r)) where l == r:
        return true
    case (.number(let l), .number(let r)) where l == r:
        return true
    case (.array(let l), .array(let r)) where l == r:
        return true
    case (.object(let l), .object(let r)) where l == r:
        return true
    default:
        return false
    }
}

extension JSON: ExpressibleByNilLiteral {
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension JSON: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = .boolean(value)
    }
}

extension JSON: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .number(JSON.Number.integer(value))
    }
}

extension JSON: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Float) {
        self = .number(JSON.Number.double(Double(value)))
    }
}

extension JSON: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .string(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .string(value)
    }

    public init(stringLiteral value: String) {
        self = .string(value)
    }
}

extension JSON: ExpressibleByStringInterpolation {
    public init(stringInterpolation strings: JSON...) {
        let string = strings.reduce("") { $0 + ($1.stringValue ?? "") }
        self = .string(string)
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .string(String(describing: expr))
    }
}

extension JSON: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSON...) {
        self = .array(elements)
    }
}

extension JSON: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var object = [String: JSON](minimumCapacity: elements.count)

        for (key, value) in elements {
            object[key] = value
        }

        self = .object(object)
    }
}

extension JSON.Number: CustomStringConvertible {
    public var description: String {
        switch self {
        case .integer(let i): return String(i)
        case .unsignedInteger(let u): return String(u)
        case .double(let d): return String(d)
        }
    }
}

extension JSON: CustomStringConvertible {
    public var description: String {
        var indentLevel = 0

        func serialize(_ data: JSON) -> String {
            switch data {
            case .null: return "null"
            case .boolean(let b): return String(b)
            case .number(let n): return String(describing: n)
            case .string(let s): return escape(s)
            case .array(let a): return serialize(array: a)
            case .object(let o): return serialize(object: o)
            }
        }

        func serialize(array: [JSON]) -> String {
            var s = "["
            indentLevel += 1

            for i in 0 ..< array.count {
                s += "\n"
                s += indent()
                s += serialize(array[i])

                if i != (array.count - 1) {
                    s += ","
                }
            }

            indentLevel -= 1
            return s + "\n" + indent() + "]"
        }

        func serialize(object: [String: JSON]) -> String {
            var s = "{"
            indentLevel += 1
            var i = 0

            for (key, value) in object {
                s += "\n"
                s += indent()
                s += "\(escape(key)): \(serialize(value))"

                if i != (object.count - 1) {
                    s += ","
                }
                i += 1
            }

            indentLevel -= 1
            return s + "\n" + indent() + "}"
        }

        func indent() -> String {
            let spaceCount = indentLevel * 4
            return String(repeating: " ", count: spaceCount)
        }

        return serialize(self)
    }
}

func escape(_ source: String) -> String {
    var s = "\""

    for c in source.characters {
        if let escapedSymbol = escapeMapping[c] {
            s.append(escapedSymbol)
        } else {
            s.append(c)
        }
    }

    s.append("\"")

    return s
}
