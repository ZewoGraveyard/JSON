JSON
====

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms Linux](https://img.shields.io/badge/Platforms-Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](https://zewo-slackin.herokuapp.com)

JSON ([RFC 7159](http://tools.ietf.org/html/rfc7159)) for **Swift 2.2**.

## Usage

```swift
import JSON

// parse JSON string

let json = try! JSONParser.parse("{\"foo\":\"bar\"}")

// create JSON literal

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
```

## Installation

- Add `JSON` to your `Package.swift`

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/JSON.git", majorVersion: 0, minor: 1)
    ]
)
```

## Community

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](https://zewo-slackin.herokuapp.com)

Join us on [Slack](https://zewo-slackin.herokuapp.com).

License
-------

**JSON** is released under the MIT license. See LICENSE for details.
