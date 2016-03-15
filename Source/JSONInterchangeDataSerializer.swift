// JSONInterchangeDataSerializer.swift
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

@_exported import InterchangeData

public struct JSONInterchangeDataSerializer: InterchangeDataSerializer {
    enum Error: ErrorType {
        case InvalidInterchangeData
    }

    public init() {}

    public func serialize(data: InterchangeData) throws -> Data {
        return try serializeToString(data).data
    }

    public func serializeToString(data: InterchangeData) throws -> String {
        switch data {
        case .Null: return "null"
        case .Boolean(let boolean): return boolean ? "true" : "false"
        case .Number(let number): return serializeNumber(number)
        case .Text(let text): return escapeAsJSONString(text)
        case .Array(let array): return try serializeArray(array)
        case .Dictionary(let dictionary): return try serializeDictionary(dictionary)
        default: throw Error.InvalidInterchangeData
        }
    }

    func serializeNumber(n: Double) -> String {
        if n == Double(Int64(n)) {
            return Int64(n).description
        } else {
            return n.description
        }
    }

    func serializeArray(a: [InterchangeData]) throws -> String {
        var s = "["

        for i in 0 ..< a.count {
            s += try serializeToString(a[i])

            if i != (a.count - 1) {
                s += ","
            }
        }

        return s + "]"
    }

    func serializeDictionary(o: [String: InterchangeData]) throws -> String {
        var s = "{"
        var i = 0

        for entry in o {
            s += try "\(escapeAsJSONString(entry.0)):\(serialize(entry.1))"
            if i != (o.count - 1) {
                s += ","
            }
            i += 1
        }

        return s + "}"
    }
}