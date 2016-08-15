@testable import JSON
import XCTest

class JSONTests: XCTestCase {
    func testStringInterpolation() {

        let string: String = "string"
        let json: JSON = [
            "key": "\(string)"
        ]

        XCTAssertNotNil(json["key"]?.stringValue)

        XCTAssert(json["key"]!.stringValue! == "string")

        let serialized = JSONSerializer().serializeToString(json: json)
        XCTAssert(serialized == "{\"key\":\"string\"}")
    }
    
    func testJSONBasicUsage() {
        let value = "value"
        
        var json: JSON = [
            "key": .string(value)
        ]

        json["int"] = 3
        
        XCTAssertEqual(json["key"]?.stringValue, "value")
        XCTAssertNotEqual(json["int"]?.doubleValue, Double(3))
    }
}

extension JSONTests {
    static var allTests: [(String, (JSONTests) -> () throws -> Void)] {
        return [
            ("testStringInterpolation", testStringInterpolation),
        ]
    }
}
