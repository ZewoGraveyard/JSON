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

public protocol JSONSerializer {
    func serialize(JSONValue: JSON) -> String
}

public class DefaultJSONSerializer: JSONSerializer {
    public init() {}
	
    public func serialize(JSONValue: JSON) -> String {
        switch JSONValue {
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

        for var i = 0; i < a.count; i++ {
            s += a[i].serialize(self)

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
            s += "\(escapeAsJSONString(entry.0)):\(entry.1.serialize(self))"
            if i++ != (o.count - 1) {
                s += ","
            }
        }

        return s + "}"
    }
}

public class PrettyJSONSerializer: DefaultJSONSerializer {
    var indentLevel = 0

    override public func serializeArray(a: [JSON]) -> String {
        var s = "["
        indentLevel++

        for var i = 0; i < a.count; i++ {
            s += "\n"
            s += indent()
            s += a[i].serialize(self)

            if i != (a.count - 1) {
                s += ","
            }
        }

        indentLevel--
        return s + "\n" + indent() + "]"
    }

    override public func serializeObject(o: [String: JSON]) -> String {
        var s = "{"
        indentLevel++
        var i = 0

        var keys = Array(o.keys)
        keys.sortInPlace()

        for key in keys {
            s += "\n"
            s += indent()
            s += "\(escapeAsJSONString(key)): \(o[key]!.serialize(self))"

            if i++ != (o.count - 1) {
                s += ","
            }
        }

        indentLevel--
        return s + "\n" + indent() + "}"
    }

    func indent() -> String {
        var s = ""

        for var i = 0; i < indentLevel; i++ {
            s += "    "
        }

        return s
    }
}