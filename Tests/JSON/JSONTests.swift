@testable import JSON
import XCTest

class JSONTests: XCTestCase {
    func testStringInterpolation() {

        let string: String = "string"
        let json: JSON = [
            "key": "\(string)"
        ]

        XCTAssertNotNil(json["key"]?.string)

        XCTAssert(json["key"]!.string! == "string")

        let serialized = JSONSerializer().serializeToString(json: json)
        XCTAssert(serialized == "{\"key\":\"string\"}")
    }
    
    func testJSONBasicUsage() {
        let value = "value"
        
        var json: JSON = [
                             "key": value
                             ]
        
        json["int"] = 3
        
        XCTAssertEqual(json["key"]?.string, "value")
        XCTAssertEqual(json["int"]?.double, Double(3))
    }
}

extension JSONTests {
    static var allTests: [(String, JSONTests -> () throws -> Void)] {
        return [
            ("testStringInterpolation", testStringInterpolation),
        ]
    }
}
