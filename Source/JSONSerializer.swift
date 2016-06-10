// JSONSerializer.swift
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

public class JSONSerializer {
    public init() {}

    public func serialize(json: JSON) -> Data {
        return serializeToString(json: json).data
    }

    public func serializeToString(json: JSON) -> String {
        switch json {
        case .null: return "null"
        case .boolean(let b): return String(b)
        case .number(let n): return String(n)
        case .string(let s): return escapeAsJSON(s)
        case .array(let a): return serialize(array: a)
        case .object(let o): return serialize(object: o)
        }
    }

    func serialize(array: [JSON]) -> String {
        var s = "["

        for i in 0 ..< array.count {
            s += serializeToString(json: array[i])

            if i != (array.count - 1) {
                s += ","
            }
        }

        return s + "]"
    }

    func serialize(object: [String: JSON]) -> String {
        var s = "{"
        var i = 0

        for entry in object {
            s += "\(escapeAsJSON(entry.0)):\(serialize(json: entry.1))"
            if i != (object.count - 1) {
                s += ","
            }
            i += 1
        }

        return s + "}"
    }
}

public final class PrettyJSONSerializer: JSONSerializer {
    var indentLevel = 0

    override public func serialize(array: [JSON]) -> String {
        var s = "["
        indentLevel += 1

        for i in 0 ..< array.count {
            s += "\n"
            s += indent()
            s += serializeToString(json: array[i])

            if i != (array.count - 1) {
                s += ","
            }
        }

        indentLevel -= 1
        return s + "\n" + indent() + "]"
    }

    override public func serialize(object: [String: JSON]) -> String {
        var s = "{"
        indentLevel += 1
        var i = 0

        for (key, value) in object {
            s += "\n"
            s += indent()
            s += "\(escapeAsJSON(key)): \(serialize(json: value))"

            if i != (object.count - 1) {
                s += ","
            }

            i += 1
        }

        indentLevel -= 1
        return s + "\n" + indent() + "}"
    }

    func indent() -> String {
        var s = ""

        for _ in 0 ..< indentLevel {
            s += "    "
        }

        return s
    }
}