// MedeaTests.swift
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

import XCTest
import Medea

class MedeaTests: XCTestCase {
    func testExample() {
        let parsedJson = try! JSONParser.parse("{\"foo\":\"bar\"}")
        print(parsedJson.debugDescription)

        let json: JSON = [
            "null": nil,
            "string": "Foo Bar",
            "boolean": true,
            "array": [
                "1",
                2,
                nil,
                true,
                ["1", 2, nil, false],
                ["a": "b"]
            ],
            "object": [
                "a": "1",
                "b": 2,
                "c": nil,
                "d": false,
                "e": ["1", 2, nil, false],
                "f": ["a": "b"]
            ],
            "number": 1969
        ]
        print(json.debugDescription)
    }
}
