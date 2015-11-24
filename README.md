Medea
=========

[![Swift 2.1](https://img.shields.io/badge/Swift-2.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Platforms OS X | iOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![Cocoapods Compatible](https://img.shields.io/badge/Cocoapods-Compatible-4BC51D.svg?style=flat)](https://cocoapods.org/pods/Venice)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Carthage/Carthage)

**Medea** provides JSON ([RFC 7159](http://tools.ietf.org/html/rfc7159)) for **Swift 2**.

## Features

- [x] No `Foundation` dependency (**Linux ready**)

## Usage

```swift

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

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 0.39.0+ is required to build Medea.

To integrate **Medea** into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

pod 'Medea', '0.1'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate **Medea** into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Zewo/Medea" == 0.1
```

### Command Line Application

To use **Medea** in a command line application:

- Install the [Swift Command Line Application](https://github.com/Zewo/Swift-Command-Line-Application-Template) Xcode template
- Follow [Cocoa Pods](#cocoapods) or [Carthage](#carthage) instructions.

License
-------

**Medea** is released under the MIT license. See LICENSE for details.
