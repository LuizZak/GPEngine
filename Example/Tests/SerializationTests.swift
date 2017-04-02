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
    
    struct SerializableComponent: Component, Serializable {
        var field: Int
        
        func serialized() -> JSON {
            return ["field": field]
        }
        mutating func deserialize(from json: JSON) throws {
            
        }
        static func deserialized(from json: JSON) throws -> SerializableComponent {
            return SerializableComponent(field: json["field"].intValue)
        }
    }
    
    struct UnserializableComponent: Component {
        
    }
    
    class Provider: SerializationTypeProvider {
        func deserialized(from name: String) throws -> Serializable.Type {
            return SerializableComponent.self
        }
    }
    
    func testSerializationType() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = SerializableComponent(field: 10)
        let object = serializer.serialize(original)
        let ser: SerializableComponent = try serializer.extract(from: object)
        
        XCTAssertEqual(ser.field, original.field)
    }
    
    func testSerializeEntity() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let originalComponents = [
            SerializableComponent(field: 10),
            SerializableComponent(field: 20)
        ]
        let original = Entity(components: originalComponents)
        original.id = 20
        original.type = 3
        
        let object = try serializer.serialize(original)
        
        let deserialized: Entity = try serializer.extract(from: object)
        // Check basic deserialization
        XCTAssertEqual(deserialized.id, 20)
        XCTAssertEqual(deserialized.type, 3)
        
        // Check deserialzied components
        XCTAssertEqual(2, deserialized.components.count)
        let deserializedComps = deserialized.components(ofType: SerializableComponent.self)
        
        XCTAssert(deserializedComps.elementsEqual(originalComponents, by: { $0.field == $1.field }))
    }
    
    func testSerializeEntityError() throws {
        // Tests error thrown when trying to serialzie an entity with an
        // unserializable component
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Entity(components: [UnserializableComponent()])
        
        do {
            _=try serializer.serialize(original)
        } catch {
            XCTAssert(error is SerializationError)
        }
    }
}
