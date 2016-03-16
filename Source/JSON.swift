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

public enum JSONError: ErrorProtocol {
    case IncompatibleType
}

public enum JSON {
    case NullValue
    case BooleanValue(Bool)
    case NumberValue(Double)
    case StringValue(String)
    case ArrayValue([JSON])
    case ObjectValue([String: JSON])

    public static func from(value: Bool) -> JSON {
        return .BooleanValue(value)
    }

    public static func from(value: Double) -> JSON {
        return .NumberValue(value)
    }

    public static func from(value: Int) -> JSON {
        return .NumberValue(Double(value))
    }

    public static func from(value: String) -> JSON {
        return .StringValue(value)
    }

    public static func from(value: [JSON]) -> JSON {
        return .ArrayValue(value)
    }

    public static func from(value: [String: JSON]) -> JSON {
        return .ObjectValue(value)
    }

    public var isBoolean: Bool {
        switch self {
        case .BooleanValue: return true
        default: return false
        }
    }

    public var isNumber: Bool {
        switch self {
        case .NumberValue: return true
        default: return false
        }
    }

    public var isString: Bool {
        switch self {
        case .StringValue: return true
        default: return false
        }
    }

    public var isArray: Bool {
        switch self {
        case .ArrayValue: return true
        default: return false
        }
    }

    public var isObject: Bool {
        switch self {
        case .ObjectValue: return true
        default: return false
        }
    }

    public var bool: Bool? {
        switch self {
        case .BooleanValue(let b): return b
        default: return nil
        }
    }

    public var double: Double? {
        switch self {
        case .NumberValue(let n): return n
        default: return nil
        }
    }

    public var int: Int? {
        if let v = double {
            return Int(v)
        }
        return nil
    }

    public var uint: UInt? {
        if let v = double {
            return UInt(v)
        }
        return nil
    }

    public var string: String? {
        switch self {
        case .StringValue(let s): return s
        default: return nil
        }
    }

    public var array: [JSON]? {
        switch self {
        case .ArrayValue(let array): return array
        default: return nil
        }
    }

    public var dictionary: [String: JSON]? {
        switch self {
        case .ObjectValue(let dictionary): return dictionary
        default: return nil
        }
    }

    public func get<T>() -> T? {
        switch self {
        case NullValue:
            return nil
        case BooleanValue(let bool):
            return bool as? T
        case NumberValue(let number):
            return number as? T
        case StringValue(let string):
            return string as? T
        case ArrayValue(let array):
            return array as? T
        case ObjectValue(let object):
            return object as? T
        }
    }

    public func get<T>() throws -> T {
        switch self {
        case BooleanValue(let bool):
            if let value = bool as? T {
                return value
            }

        case NumberValue(let number):
            if let value = number as? T {
                return value
            }

        case StringValue(let string):
            if let value = string as? T {
                return value
            }

        case ArrayValue(let array):
            if let value = array as? T {
                return value
            }

        case ObjectValue(let object):
            if let value = object as? T {
                return value
            }

        default: break
        }

        throw JSONError.IncompatibleType
    }

    public func asBool() throws -> Bool {
        if let value = bool {
            return value
        }
        throw JSONError.IncompatibleType
    }

    public func asDouble() throws -> Double {
        if let value = double {
            return value
        }
        throw JSONError.IncompatibleType
    }

    public func asInt() throws -> Int {
        if let value = int {
            return value
        }
        throw JSONError.IncompatibleType
    }

    public func asUInt() throws -> UInt {
        if let value = uint {
            return UInt(value)
        }
        throw JSONError.IncompatibleType
    }

    public func asString() throws -> String {
        if let value = string {
            return value
        }
        throw JSONError.IncompatibleType
    }

    public func asArray() throws -> [JSON] {
        if let value = array {
            return value
        }
        throw JSONError.IncompatibleType
    }

    public func asDictionary() throws -> [String: JSON] {
        if let value = dictionary {
            return value
        }
        throw JSONError.IncompatibleType
    }

    public subscript(index: Int) -> JSON? {
        set {
            switch self {
            case .ArrayValue(let array):
                var array = array
                if index < array.count {
                    if let json = newValue {
                        array[index] = json
                    } else {
                        array[index] = .NullValue
                    }
                    self = .ArrayValue(array)
                }
            default: break
            }
        }
        get {
            switch self {
            case .ArrayValue(let array):
                return index < array.count ? array[index] : nil
            default: return nil
            }
        }
    }

    public subscript(key: String) -> JSON? {
        set {
            switch self {
            case .ObjectValue(let object):
                var object = object
                object[key] = newValue
                self = .ObjectValue(object)
            default: break
            }
        }
        get {
            switch self {
            case .ObjectValue(let object):
                return object[key]
            default: return nil
            }
        }
    }
}

extension JSON: Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch lhs {
    case .NullValue:
        switch rhs {
        case .NullValue: return true
        default: return false
        }
    case .BooleanValue(let lhsValue):
        switch rhs {
        case .BooleanValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .StringValue(let lhsValue):
        switch rhs {
        case .StringValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .NumberValue(let lhsValue):
        switch rhs {
        case .NumberValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .ArrayValue(let lhsValue):
        switch rhs {
        case .ArrayValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .ObjectValue(let lhsValue):
        switch rhs {
        case .ObjectValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    }
}

extension JSON: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .NullValue
    }
}

extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .BooleanValue(value)
    }
}

extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .NumberValue(Double(value))
    }
}

extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .NumberValue(Double(value))
    }
}

extension JSON: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .StringValue(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .StringValue(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .StringValue(value)
    }
}

extension JSON: StringInterpolationConvertible {
    public init(stringInterpolation strings: JSON...) {
        var string = ""

        for s in strings {
            string += s.string!
        }

        self = .StringValue(String(string))
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .StringValue(String(expr))
    }
}

extension JSON: ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSON...) {
        self = .ArrayValue(elements)
    }
}

extension JSON: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON](minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }

        self = .ObjectValue(dictionary)
    }
}

extension JSON: CustomStringConvertible {
    public var description: String {
        return JSONSerializer().serializeToString(self)
    }
}

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return PrettyJSONSerializer().serializeToString(self)
    }
}