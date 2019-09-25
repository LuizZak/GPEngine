import XCTest
import Serialization

class JSONTests: XCTestCase {
    func testAccess() {
        let json: JSON = [
            "a": [1, 2, 3],
            "b": [
                "c": [1, 2, 3],
                "d": false
            ]
        ]

        XCTAssertEqual(json[path: "b", "d"].value, .value(false))
        XCTAssertEqual(json[path: "b", "c", 0].value, .value(1))
        XCTAssertEqual(json[path: "b", "c", 0].json, 1)
    }

    func testAccessInvalidJson() {
        let json: JSON = [ "a": true ]

        XCTAssertNil(json[path: 0].json)
    }

    func testAccessInvalidRoot() {
        let json: JSON = [ "a": true ]

        XCTAssertEqual(json[path: 0].value, .notAnArray([]))
    }

    func testAccessInvalidDictionary() {
        let json: JSON = [
            "a": [1, 2, 3],
            "b": [
                "c": [1, 2, 3],
                "d": false
            ]
        ]

        XCTAssertEqual(json[path: "a", "b"].value, .notADictionary([.dictionary("a")]))
    }

    func testAccessKeyNotFoundDictionary() {
        let json: JSON = [ "a": false ]

        XCTAssertEqual(json[path: "b"].value, .keyNotFound([.dictionary("b")]))
    }

    func testAccessKeyNotFoundArray() {
        let json: JSON = []

        XCTAssertEqual(json[path: 0].value, .keyNotFound([.index(0)]))
    }

    func testAccessInvalidArray() {
        let json: JSON = [
            "a": [1, 2, 3],
            "b": [
                "c": [1, 2, 3],
                "d": false
            ]
        ]

        XCTAssertEqual(json[path: "b", 0].value, .notAnArray([.dictionary("b")]))
    }
}
