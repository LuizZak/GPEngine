import XCTest
import Serialization

class JSONTests: XCTestCase {
    func testEncodeRoundtrip() throws {
        let json: JSON = [
            "a": 123.0,
            "b": true,
            "c": [
                1,
                "d",
                .null
            ]
        ]
        
        let data = try JSONEncoder().encode(json)
        let result = try JSONDecoder().decode(JSON.self, from: data)
        
        XCTAssertEqual(json, result)
    }
    
    func testAccess() {
        let json: JSON = [
            "a": [1, 2, 3],
            "b": [
                "c": [1, 2, 3],
                "d": false
            ]
        ]

        XCTAssertEqual(json[path: "b", "d"], .value(false))
        XCTAssertEqual(json[path: "b", "c", 0], .value(1))
        XCTAssertEqual(json[path: "b", "c", 0].json, 1)
    }

    func testAccessInvalidJson() {
        let json: JSON = [ "a": true ]

        XCTAssertNil(json[path: 0].json)
    }

    func testAccessInvalidRoot() {
        let json: JSON = [ "a": true ]

        XCTAssertEqual(json[path: 0], .notAnArray([]))
    }

    func testAccessInvalidDictionary() {
        let json: JSON = [
            "a": [1, 2, 3],
            "b": [
                "c": [1, 2, 3],
                "d": false
            ]
        ]

        XCTAssertEqual(json[path: "a", "b"], .notADictionary([.dictionary("a")]))
    }

    func testAccessKeyNotFoundDictionary() {
        let json: JSON = [ "a": false ]

        XCTAssertEqual(json[path: "b"], .keyNotFound([.dictionary("b")]))
    }

    func testAccessKeyNotFoundArray() {
        let json: JSON = []

        XCTAssertEqual(json[path: 0], .keyNotFound([.index(0)]))
    }

    func testAccessInvalidArray() {
        let json: JSON = [
            "a": [1, 2, 3],
            "b": [
                "c": [1, 2, 3],
                "d": false
            ]
        ]

        XCTAssertEqual(json[path: "b", 0], .notAnArray([.dictionary("b")]))
    }
    
    func testPathToNumber() {
        let json: JSON = [
            "a": [ 1.0 ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].number(), 1)
    }
    
    func testPathToString() {
        let json: JSON = [
            "a": [ "b" ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].string(), "b")
    }
    
    func testPathToBool() {
        let json: JSON = [
            "a": [ true ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].bool(), true)
    }
    
    func testPathToNil() {
        let json: JSON = [
            "a": [ .null ]
        ]
        
        XCTAssertTrue(try json[path: "a", 0].isNull())
    }
    
    func testPathToArray() {
        let json: JSON = [
            "a": [ "b", "c" ]
        ]
        
        XCTAssertEqual(try json[path: "a"].array(), [ "b", "c" ])
    }
    
    func testPathToDictionary() {
        let json: JSON = [
            "a": [ "b": "c" ]
        ]
        
        XCTAssertEqual(try json[path: "a"].dictionary(), [ "b": "c" ])
    }
}
