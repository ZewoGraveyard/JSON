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

@_exported import Data

public class JSONSerializer {
    public init() {}

    public func serialize(json: JSON) -> Data {
        return serializeToString(json).data
    }

    public func serializeToString(json: JSON) -> String {
        switch json {
        case .NullValue: return "null"
        case .BooleanValue(let b): return b ? "true" : "false"
        case .NumberValue(let n): return serializeNumber(n)
        case .StringValue(let s): return escapeAsJSONString(s)
        case .ArrayValue(let a): return serializeArray(a)
        case .ObjectValue(let o): return serializeObject(o)
        }
    }

    func serializeNumber(n: Double) -> String {
        if n == Double(Int64(n)) {
            return Int64(n).description
        } else {
            return n.description
        }
    }

    func serializeArray(a: [JSON]) -> String {
        var s = "["

        for i in 0 ..< a.count {
            s += serializeToString(a[i])

            if i != (a.count - 1) {
                s += ","
            }
        }

        return s + "]"
    }

    func serializeObject(o: [String: JSON]) -> String {
        var s = "{"
        var i = 0

        for entry in o {
            s += "\(escapeAsJSONString(entry.0)):\(serialize(entry.1))"
            if i != (o.count - 1) {
                s += ","
            }
            i += 1
        }

        return s + "}"
    }
}

public final class PrettyJSONSerializer: JSONSerializer {
    var indentLevel = 0

    override public func serializeArray(a: [JSON]) -> String {
        var s = "["
        indentLevel += 1

        for i in 0 ..< a.count {
            s += "\n"
            s += indent()
            s += serializeToString(a[i])

            if i != (a.count - 1) {
                s += ","
            }
        }

        indentLevel -= 1
        return s + "\n" + indent() + "]"
    }

    override public func serializeObject(o: [String: JSON]) -> String {
        var s = "{"
        indentLevel += 1
        var i = 0

        for (key, value) in o {
            s += "\n"
            s += indent()
            s += "\(escapeAsJSONString(key)): \(serialize(value))"

            if i != (o.count - 1) {
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