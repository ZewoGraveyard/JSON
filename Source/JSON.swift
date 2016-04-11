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

@_exported import StructuredData

public enum JSONError: ErrorProtocol {
    case incompatibleType
}

public enum JSON {
    case nullValue
    case booleanValue(Bool)
    case numberValue(Double)
    case stringValue(String)
    case arrayValue([JSON])
    case objectValue([String: JSON])

    public static func from(value: Bool) -> JSON {
        return .booleanValue(value)
    }

    public static func from(value: Double) -> JSON {
        return .numberValue(value)
    }

    public static func from(value: Int) -> JSON {
        return .numberValue(Double(value))
    }

    public static func from(value: String) -> JSON {
        return .stringValue(value)
    }

    public static func from(value: [JSON]) -> JSON {
        return .arrayValue(value)
    }

    public static func from(value: [String: JSON]) -> JSON {
        return .objectValue(value)
    }

    public var isBoolean: Bool {
        switch self {
        case .booleanValue: return true
        default: return false
        }
    }

    public var isNumber: Bool {
        switch self {
        case .numberValue: return true
        default: return false
        }
    }

    public var isString: Bool {
        switch self {
        case .stringValue: return true
        default: return false
        }
    }

    public var isArray: Bool {
        switch self {
        case .arrayValue: return true
        default: return false
        }
    }

    public var isObject: Bool {
        switch self {
        case .objectValue: return true
        default: return false
        }
    }

    public var bool: Bool? {
        switch self {
        case .booleanValue(let b): return b
        default: return nil
        }
    }

    public var double: Double? {
        switch self {
        case .numberValue(let n): return n
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
        case .stringValue(let s): return s
        default: return nil
        }
    }

    public var array: [JSON]? {
        switch self {
        case .arrayValue(let array): return array
        default: return nil
        }
    }

    public var dictionary: [String: JSON]? {
        switch self {
        case .objectValue(let dictionary): return dictionary
        default: return nil
        }
    }

    public func get<T>() -> T? {
        switch self {
        case nullValue:
            return nil
        case booleanValue(let bool):
            return bool as? T
        case numberValue(let number):
            return number as? T
        case stringValue(let string):
            return string as? T
        case arrayValue(let array):
            return array as? T
        case objectValue(let object):
            return object as? T
        }
    }

    public func get<T>() throws -> T {
        switch self {
        case booleanValue(let bool):
            if let value = bool as? T {
                return value
            }

        case numberValue(let number):
            if let value = number as? T {
                return value
            }

        case stringValue(let string):
            if let value = string as? T {
                return value
            }

        case arrayValue(let array):
            if let value = array as? T {
                return value
            }

        case objectValue(let object):
            if let value = object as? T {
                return value
            }

        default: break
        }

        throw JSONError.incompatibleType
    }

    public func asBool() throws -> Bool {
        if let value = bool {
            return value
        }
        throw JSONError.incompatibleType
    }

    public func asDouble() throws -> Double {
        if let value = double {
            return value
        }
        throw JSONError.incompatibleType
    }

    public func asInt() throws -> Int {
        if let value = int {
            return value
        }
        throw JSONError.incompatibleType
    }

    public func asUInt() throws -> UInt {
        if let value = uint {
            return UInt(value)
        }
        throw JSONError.incompatibleType
    }

    public func asString() throws -> String {
        if let value = string {
            return value
        }
        throw JSONError.incompatibleType
    }

    public func asArray() throws -> [JSON] {
        if let value = array {
            return value
        }
        throw JSONError.incompatibleType
    }

    public func asDictionary() throws -> [String: JSON] {
        if let value = dictionary {
            return value
        }
        throw JSONError.incompatibleType
    }

    public subscript(index: Int) -> JSON? {
        get {
            switch self {
            case .arrayValue(let array):
                return index < array.count ? array[index] : nil
            default: return nil
            }
        }

        set(json) {
            switch self {
            case .arrayValue(let array):
                var array = array
                if index < array.count {
                    if let json = json {
                        array[index] = json
                    } else {
                        array[index] = .nullValue
                    }
                    self = .arrayValue(array)
                }
            default: break
            }
        }
    }

    public subscript(key: String) -> JSON? {
        get {
            switch self {
            case .objectValue(let object):
                return object[key]
            default: return nil
            }
        }

        set(json) {
            switch self {
            case .objectValue(let object):
                var object = object
                object[key] = json
                self = .objectValue(object)
            default: break
            }
        }
    }
}

extension JSON: Equatable {}

public func ==(lhs: JSON, rhs: JSON) -> Bool {
    switch lhs {
    case .nullValue:
        switch rhs {
        case .nullValue: return true
        default: return false
        }
    case .booleanValue(let lhsValue):
        switch rhs {
        case .booleanValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .stringValue(let lhsValue):
        switch rhs {
        case .stringValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .numberValue(let lhsValue):
        switch rhs {
        case .numberValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .arrayValue(let lhsValue):
        switch rhs {
        case .arrayValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    case .objectValue(let lhsValue):
        switch rhs {
        case .objectValue(let rhsValue): return lhsValue == rhsValue
        default: return false
        }
    }
}

extension JSON: NilLiteralConvertible {
    public init(nilLiteral value: Void) {
        self = .nullValue
    }
}

extension JSON: BooleanLiteralConvertible {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .booleanValue(value)
    }
}

extension JSON: IntegerLiteralConvertible {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .numberValue(Double(value))
    }
}

extension JSON: FloatLiteralConvertible {
    public init(floatLiteral value: FloatLiteralType) {
        self = .numberValue(Double(value))
    }
}

extension JSON: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self = .stringValue(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = .stringValue(value)
    }

    public init(stringLiteral value: StringLiteralType) {
        self = .stringValue(value)
    }
}

extension JSON: StringInterpolationConvertible {
    public init(stringInterpolation strings: JSON...) {
        var string = ""

        for s in strings {
            string += s.string!
        }

        self = .stringValue(String(string))
    }

    public init<T>(stringInterpolationSegment expr: T) {
        self = .stringValue(String(expr))
    }
}

extension JSON: ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSON...) {
        self = .arrayValue(elements)
    }
}

extension JSON: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var dictionary = [String: JSON](minimumCapacity: elements.count)

        for pair in elements {
            dictionary[pair.0] = pair.1
        }

        self = .objectValue(dictionary)
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