//
//  SerializationTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 01/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import GPEngine
import SwiftyJSON

class SerializationTests: XCTestCase {
    
    struct MyComponent: Component, Serializable {
        var field: Int
        
        func serialized() -> JSON {
            return ["field": field]
        }
        mutating func deserialize(from json: JSON) throws {
            
        }
        static func deserialized(from json: JSON) throws -> MyComponent {
            return MyComponent(field: json["field"].intValue)
        }
    }
    
    class Provider: SerializationTypeProvider {
        func deserialized(from name: String) throws -> Serializable.Type {
            return MyComponent.self
        }
    }
    
    func testSerializationType() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = MyComponent(field: 10)
        let object = serializer.serialize(original)
        let ser: MyComponent = try serializer.extract(from: object)
        
        XCTAssertEqual(ser.field, original.field)
    }
    
    func testSerializeEntity() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Entity(components: [MyComponent(field: 10)])
        
        let object = try serializer.serialize(original)
        let ser: Entity = try serializer.extract(from: object)
        
        XCTAssertEqual(ser.component(ofType: MyComponent.self)?.field, 10)
    }
}
