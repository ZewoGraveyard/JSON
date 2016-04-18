// JSONStructuredDataParser.swift
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

#if os(Linux)
    @_exported import Glibc
#else
    @_exported import Darwin.C
#endif

public enum JSONStructuredDataParseError: ErrorProtocol, CustomStringConvertible {
    case unexpectedTokenError(reason: String, lineNumber: Int, columnNumber: Int)
    case insufficientTokenError(reason: String, lineNumber: Int, columnNumber: Int)
    case extraTokenError(reason: String, lineNumber: Int, columnNumber: Int)
    case nonStringKeyError(reason: String, lineNumber: Int, columnNumber: Int)
    case invalidStringError(reason: String, lineNumber: Int, columnNumber: Int)
    case invalidNumberError(reason: String, lineNumber: Int, columnNumber: Int)

    public var description: String {
        switch self {
        case unexpectedTokenError(let r, let l, let c):
            return "UnexpectedTokenError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case insufficientTokenError(let r, let l, let c):
            return "InsufficientTokenError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case extraTokenError(let r, let l, let c):
            return "ExtraTokenError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case nonStringKeyError(let r, let l, let c):
            return "NonStringKeyError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case invalidStringError(let r, let l, let c):
            return "InvalidStringError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        case invalidNumberError(let r, let l, let c):
            return "InvalidNumberError!\nLine: \(l)\nColumn: \(c)]\nReason: \(r)"
        }
    }
}

public struct JSONStructuredDataParser: StructuredDataParser {
    public init() {}

    public func parse(_ data: Data) throws -> StructuredData {
        return try GenericJSONStructuredDataParser(data).parse()
    }
}

class GenericJSONStructuredDataParser<ByteSequence: Collection where ByteSequence.Iterator.Element == UInt8> {
    typealias Source = ByteSequence
    typealias Char = Source.Iterator.Element

    let source: Source
    var cur: Source.Index
    let end: Source.Index

    var lineNumber = 1
    var columnNumber = 1

    init(_ source: Source) {
        self.source = source
        self.cur = source.startIndex
        self.end = source.endIndex
    }

    func parse() throws -> StructuredData {
        let JSON = try parseValue()
        skipWhitespaces()
        if (cur == end) {
            return JSON
        } else {
            throw JSONStructuredDataParseError.extraTokenError(
                reason: "extra tokens found",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }
    }
}

// MARK: - Private

extension GenericJSONStructuredDataParser {
    private func parseValue() throws -> StructuredData {
        skipWhitespaces()
        if cur == end {
            throw JSONStructuredDataParseError.insufficientTokenError(
                reason: "unexpected end of tokens",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        switch currentChar {
        case Char(ascii: "n"): return try parseSymbol("null", StructuredData.nullValue)
        case Char(ascii: "t"): return try parseSymbol("true", StructuredData.boolValue(true))
        case Char(ascii: "f"): return try parseSymbol("false", StructuredData.boolValue(false))
        case Char(ascii: "-"), Char(ascii: "0") ... Char(ascii: "9"): return try parseNumber()
        case Char(ascii: "\""): return try parseString()
        case Char(ascii: "{"): return try parseObject()
        case Char(ascii: "["): return try parseArray()
        case (let c): throw JSONStructuredDataParseError.unexpectedTokenError(
            reason: "unexpected token: \(c)",
            lineNumber: lineNumber,
            columnNumber: columnNumber
        )
        }
    }

    private var currentChar: Char {
        return source[cur]
    }

    private var nextChar: Char {
        return source[cur.successor()]
    }

    private var currentSymbol: Character {
        return Character(UnicodeScalar(currentChar))
    }

    private func parseSymbol(_ target: StaticString, @autoclosure _ iftrue: Void -> StructuredData) throws -> StructuredData {
        if expect(target) {
            return iftrue()
        } else {
            throw JSONStructuredDataParseError.unexpectedTokenError(
                reason: "expected \"\(target)\" but \(currentSymbol)",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }
    }

    private func parseString() throws -> StructuredData {
        assert(currentChar == Char(ascii: "\""), "points a double quote")
        advance()
        var buffer: [CChar] = []

        LOOP: while cur != end {
            switch currentChar {
            case Char(ascii: "\\"):
                advance()
                if (cur == end) {
                    throw JSONStructuredDataParseError.invalidStringError(
                        reason: "unexpected end of a string literal",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }

                if let c = parseEscapedChar() {
                    for u in String(c).utf8 {
                        buffer.append(CChar(bitPattern: u))
                    }
                } else {
                    throw JSONStructuredDataParseError.invalidStringError(
                        reason: "invalid escape sequence",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }
            case Char(ascii: "\""): break LOOP
            default: buffer.append(CChar(bitPattern: currentChar))
            }
            advance()
        }

        if !expect("\"") {
            throw JSONStructuredDataParseError.invalidStringError(
                reason: "missing double quote",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        buffer.append(0)
        let s = String(validatingUTF8: buffer)!
        return .stringValue(s)
    }

    private func parseEscapedChar() -> UnicodeScalar? {
        let c = UnicodeScalar(currentChar)

        if c == "u" {
            var length = 0
            var value: UInt32 = 0

            while let d = hexToDigit(nextChar) {
                advance()
                length += 1

                if length > 8 {
                    break
                }

                value = (value << 4) | d
            }

            if length < 2 {
                return nil
            }

            return UnicodeScalar(value)
        } else {
            let c = UnicodeScalar(currentChar)
            return unescapeMapping[c] ?? c
        }
    }

    private func parseNumber() throws -> StructuredData {
        let sign = expect("-") ? -1.0 : 1.0
        var integer: Int64 = 0

        switch currentChar {
        case Char(ascii: "0"): advance()
        case Char(ascii: "1") ... Char(ascii: "9"):
            while cur != end {
                if let value = digitToInt(currentChar) {
                    integer = (integer * 10) + Int64(value)
                } else {
                    break
                }
                advance()
            }
        default:
            throw JSONStructuredDataParseError.invalidStringError(
                reason: "missing double quote",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        if integer != Int64(Double(integer)) {
            throw JSONStructuredDataParseError.invalidNumberError(
                reason: "too large number",
                lineNumber: lineNumber,
                columnNumber: columnNumber
            )
        }

        var fraction: Double = 0.0

        if expect(".") {
            var factor = 0.1
            var fractionLength = 0

            while cur != end {
                if let value = digitToInt(currentChar) {
                    fraction += (Double(value) * factor)
                    factor /= 10
                    fractionLength += 1
                } else {
                    break
                }
                advance()
            }

            if fractionLength == 0 {
                throw JSONStructuredDataParseError.invalidNumberError(
                    reason: "insufficient fraction part in number",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }
        }

        var exponent: Int64 = 0

        if expect("e") || expect("E") {
            var expSign: Int64 = 1

            if expect("-") {
                expSign = -1
            } else if expect("+") {}

            exponent = 0
            var exponentLength = 0

            while cur != end {
                if let value = digitToInt(currentChar) {
                    exponent = (exponent * 10) + Int64(value)
                    exponentLength += 1
                } else {
                    break
                }
                advance()
            }

            if exponentLength == 0 {
                throw JSONStructuredDataParseError.invalidNumberError(
                    reason: "insufficient exponent part in number",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }

            exponent *= expSign
        }

        return .numberValue(sign * (Double(integer) + fraction) * pow(10, Double(exponent)))
    }

    private func parseObject() throws -> StructuredData {
        assert(currentChar == Char(ascii: "{"), "points \"{\"")
        advance()
        skipWhitespaces()
        var object: [String: StructuredData] = [:]

        LOOP: while cur != end && !expect("}") {
            let keyValue = try parseValue()

            switch keyValue {
            case .stringValue(let key):
                skipWhitespaces()

                if !expect(":") {
                    throw JSONStructuredDataParseError.unexpectedTokenError(
                        reason: "missing colon (:)",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }

                skipWhitespaces()
                let value = try parseValue()
                object[key] = value
                skipWhitespaces()

                if expect(",") {
                    break
                } else if expect("}") {
                    break LOOP
                } else {
                    throw JSONStructuredDataParseError.unexpectedTokenError(
                        reason: "missing comma (,)",
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    )
                }
            default:
                throw JSONStructuredDataParseError.nonStringKeyError(
                    reason: "unexpected value for object key",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }
        }

        return .dictionaryValue(object)
    }

    private func parseArray() throws -> StructuredData {
        assert(currentChar == Char(ascii: "["), "points \"[\"")
        advance()
        skipWhitespaces()

        var array: [StructuredData] = []

        LOOP: while cur != end && !expect("]") {
            let JSON = try parseValue()
            skipWhitespaces()
            array.append(JSON)

            if expect(",") {
                continue
            } else if expect("]") {
                break LOOP
            } else {
                throw JSONStructuredDataParseError.unexpectedTokenError(
                    reason: "missing comma (,) (token: \(currentSymbol))",
                    lineNumber: lineNumber,
                    columnNumber: columnNumber
                )
            }
        }

        return .arrayValue(array)
    }


    private func expect(_ target: StaticString) -> Bool {
        if cur == end {
            return false
        }

        if !isIdentifier(target.utf8Start.pointee) {
            if target.utf8Start.pointee == currentChar {
                advance()
                return true
            } else {
                return false
            }
        }

        let start = cur
        let l = lineNumber
        let c = columnNumber

        var p = target.utf8Start
        let endp = p.advanced(by: Int(target.utf8CodeUnitCount))

        while p != endp {
            if p.pointee != currentChar {
                cur = start
                lineNumber = l
                columnNumber = c
                return false
            }
            p += 1
            advance()
        }

        return true
    }

    // only "true", "false", "null" are identifiers
    private func isIdentifier(_ char: Char) -> Bool {
        switch char {
        case Char(ascii: "a") ... Char(ascii: "z"):
            return true
        default:
            return false
        }
    }

    private func advance() {
        assert(cur != end, "out of range")
        cur = cur.successor()

        if cur != end {
            switch currentChar {

            case Char(ascii: "\n"):
                lineNumber += 1
                columnNumber = 1

            default:
                columnNumber += 1
            }
        }
    }

    private func skipWhitespaces() {
        while cur != end {
            switch currentChar {
            case Char(ascii: " "), Char(ascii: "\t"), Char(ascii: "\r"), Char(ascii: "\n"):
                break
            default:
                return
            }
            advance()
        }
    }
}
