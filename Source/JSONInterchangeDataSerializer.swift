// JSONStructuredDataSerializer.swift
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

public struct JSONStructuredDataSerializer: StructuredDataSerializer {
    enum Error: ErrorProtocol {
        case invalidStructuredData
    }

    public init() {}

    public func serialize(_ data: StructuredData) throws -> Data {
        return try serializeToString(data).data
    }

    public func serializeToString(_ data: StructuredData) throws -> String {
        switch data {
        case .nullValue: return "null"
        case .boolValue(let bool): return bool ? "true" : "false"
        case .numberValue(let number): return serialize(number: number)
        case .stringValue(let text): return escapeAsJSON(text)
        case .arrayValue(let array): return try serialize(array: array)
        case .dictionaryValue(let dictionary): return try serialize(dictionary: dictionary)
        default: throw Error.invalidStructuredData
        }
    }

    func serialize(number: Double) -> String {
        if number == Double(Int64(number)) {
            return Int64(number).description
        } else {
            return number.description
        }
    }

    func serialize(array: [StructuredData]) throws -> String {
        var s = "["

        for i in 0 ..< array.count {
            s += try serializeToString(array[i])

            if i != (array.count - 1) {
                s += ","
            }
        }

        return s + "]"
    }

    func serialize(dictionary: [String: StructuredData]) throws -> String {
        var s = "{"
        var i = 0

        for entry in dictionary {
            s += try "\(escapeAsJSON(entry.0)):\(serialize(entry.1))"
            if i != (dictionary.count - 1) {
                s += ","
            }
            i += 1
        }

        return s + "}"
    }
}