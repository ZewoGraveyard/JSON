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
//
// This file has been modified from its original project Swift-JsonSerializer

public enum JSON {
    case NullValue
    case BooleanValue(Bool)
    case NumberValue(Double)
    case StringValue(String)
    case ArrayValue([JSON])
    case ObjectValue([String: JSON])

    static func from(value: Bool) -> JSON {
        return .BooleanValue(value)
    }

    static func from(value: Double) -> JSON {
        return .NumberValue(value)
    }

    static func from(value: String) -> JSON {
        return .StringValue(value)
    }

    static func from(value: [JSON]) -> JSON {
        return .ArrayValue(value)
    }

    static func from(value: [String: JSON]) -> JSON {
        return .ObjectValue(value)
    }

    // TODO: decide what to do if Any is not a JSON value
    static func from(values: [Any]) -> JSON {
        var jsonArray: [JSON] = []
        for value in values {
            if let value = value as? Bool {
                jsonArray.append(JSON.from(value))
            }
            if let value = value as? Double {
                jsonArray.append(JSON.from(value))
            }
            if let value = value as? String {
                jsonArray.append(JSON.from(value))
            }
            if let value = value as? [Any] {
                jsonArray.append(JSON.from(value))
            }
            if let value = value as? [String: Any] {
                jsonArray.append(JSON.from(value))
            }
        }
        return JSON.from(jsonArray)
    }

    // TODO: decide what to do if Any is not a JSON value
    static func from(value: [String: Any]) -> JSON {
        var jsonDictionary: [String: JSON] = [:]
        for (key, value) in value {
            if let value = value as? Bool {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? Double {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? String {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? [Any] {
                jsonDictionary[key] = JSON.from(value)
            }
            if let value = value as? [String: Any] {
                jsonDictionary[key] = JSON.from(value)
            }
        }

        return JSON.from(jsonDictionary)
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

    public var boolValue: Bool? {
        switch self {
        case .BooleanValue(let b): return b
        default: return nil
        }
    }

    public var doubleValue: Double? {
        switch self {
        case .NumberValue(let n): return n
        default: return nil
        }
    }

    public var intValue: Int? {
        return doubleValue != nil ? Int(doubleValue!) : nil
    }

    public var uintValue: UInt? {
        return doubleValue != nil ? UInt(doubleValue!) : nil
    }

    public var stringValue: String? {
        switch self {
        case .StringValue(let s): return s
        default: return nil
        }
    }

    public var arrayValue: [JSON]? {
        switch self {
        case .ArrayValue(let array): return array
        default: return nil
        }
    }

    public var dictionaryValue: [String: JSON]? {
        switch self {
        case .ObjectValue(let dictionary): return dictionary
        default: return nil
        }
    }

    public var anyValue: Any? {
        switch self {
        case NullValue: return nil
        case BooleanValue(let bool): return bool
        case NumberValue(let double): return double
        case StringValue(let string): return string
        case ArrayValue(let array): return array.map { $0.anyValue }
        case ObjectValue(let object):
            var dictionaryOfAny: [String: Any] = [:]
            for (key, json) in object {
                dictionaryOfAny[key] = json.anyValue
            }
            return dictionaryOfAny
        }
    }

    public var dictionaryOfAnyValue: [String: Any]? {
        if let dictionaryOfAny = anyValue as? [String: Any] {
            return dictionaryOfAny
        }
        return nil
    }

    public subscript(index: UInt) -> JSON {
        set {
            switch self {
            case .ArrayValue(var array):
                if Int(index) < array.count {
                    array[Int(index)] = newValue
                    self = .ArrayValue(array)
                }
            default: break
            }
        }
        get {
            switch self {
            case .ArrayValue(let a):
                return Int(index) < a.count ? a[Int(index)] : .NullValue
            default: return .NullValue
            }
        }
    }

    public subscript(key: String) -> JSON {
        set {
            switch self {
            case .ObjectValue(var object):
                object[key] = newValue
                self = .ObjectValue(object)
            default: break
            }
        }
        get {
            switch self {
            case .ObjectValue(let object): return object[key] ?? .NullValue
            default: return .NullValue
            }
        }
    }

    public func serialize(serializer: JSONSerializer) -> String {
        return serializer.serialize(self)
    }
}

extension JSON: CustomStringConvertible {
    public var description: String {
        return serialize(DefaultJSONSerializer())
    }
}

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        return serialize(PrettyJSONSerializer())
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
    public typealias UnicodeScalarLiteralType = String

    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self = .StringValue(value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
        self = .StringValue(value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self = .StringValue(value)
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