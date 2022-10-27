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
                .null,
            ],
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
                "d": false,
            ],
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
                "d": false,
            ],
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
                "d": false,
            ],
        ]

        XCTAssertEqual(json[path: "b", 0], .notAnArray([.dictionary("b")]))
    }
    
    func testPathToNumber() {
        let json: JSON = [
            "a": [ 1.0 ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].number(), 1)
    }
    
    func testPathToNumber_typeError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", 0].number(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Expected a value of type 'number' but found a value of type 'string' @ <root>.prefixKey"
            )
        }
    }
    
    func testPathToNumber_invalidPathError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].number(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
    
    func testPathToInteger() {
        let json: JSON = [
            "a": [ 1.0 ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].integer(), 1)
    }
    
    func testPathToInteger_typeError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", 0].integer(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Expected a value of type 'number' but found a value of type 'string' @ <root>.prefixKey"
            )
        }
    }
    
    func testPathToInteger_invalidPathError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].integer(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
    
    func testPathToString() {
        let json: JSON = [
            "a": [ "b" ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].string(), "b")
    }
    
    func testPathToString_typeError() throws {
        let json: JSON = [
            "a": [ 0 ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", 0].string(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Expected a value of type 'string' but found a value of type 'number' @ <root>.prefixKey"
            )
        }
    }
    
    func testPathToString_invalidPathError() throws {
        let json: JSON = [
            "a": [ 0 ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].number(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
    
    func testPathToBool() {
        let json: JSON = [
            "a": [ true ]
        ]
        
        XCTAssertEqual(try json[path: "a", 0].bool(), true)
    }
    
    func testPathToBool_typeError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", 0].bool(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Expected a value of type 'bool' but found a value of type 'string' @ <root>.prefixKey"
            )
        }
    }
    
    func testPathToBool_invalidPathError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].bool(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
    
    func testPathToNull() {
        let json: JSON = [
            "a": [ .null ]
        ]
        
        XCTAssertTrue(try json[path: "a", 0].isNull())
    }
    
    func testPathToNull_invalidPathError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].isNull(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
    
    func testPathToArray() {
        let json: JSON = [
            "a": [ "b", "c" ]
        ]
        
        XCTAssertEqual(try json[path: "a"].array(), [ "b", "c" ])
    }
    
    func testPathToArray_typeError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", 0].array(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Expected a value of type 'array' but found a value of type 'string' @ <root>.prefixKey"
            )
        }
    }
    
    func testPathToArray_invalidPathError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].array(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
    
    func testPathToDictionary() {
        let json: JSON = [
            "a": [ "b": "c" ]
        ]
        
        XCTAssertEqual(try json[path: "a"].dictionary(), [ "b": "c" ])
    }

    func testPathToDictionary_typeError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", 0].dictionary(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Expected a value of type 'dictionary' but found a value of type 'string' @ <root>.prefixKey"
            )
        }
    }
    
    func testPathToDictionary_invalidPathError() throws {
        let json: JSON = [
            "a": [ "" ]
        ]
        
        try XCTAssertThrowsError(try json[path: "a", "key", 0].dictionary(prefixPath: .root.dictionary("prefixKey"))) { error in
            XCTAssertEqual(
                try XCTUnwrap((error as? Serialization.JSONSubscriptAccess.Error)?.description),
                "Invalid JSON path <root>.prefixKey.a"
            )
        }
    }
}
