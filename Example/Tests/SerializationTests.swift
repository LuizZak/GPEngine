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
    
    final class SerializableSubspace: Subspace, Serializable {
        var subspaceField: Int
        
        init(subspaceField: Int) {
            self.subspaceField = subspaceField
        }
        
        func serialized() -> JSON {
            return ["subspaceField": subspaceField]
        }
        func deserialize(from json: JSON) throws {
            
        }
        static func deserialized(from json: JSON) throws -> SerializableSubspace {
            return SerializableSubspace(subspaceField: json["subspaceField"].intValue)
        }
    }
    
    struct UnserializableComponent: Component {
        
    }
    
    class Provider: SerializationTypeProvider {
        
        var types: [Serializable.Type] = [
            SerializableComponent.self,
            SerializableSubspace.self
        ]
        
        func deserialized(from name: String) throws -> Serializable.Type {
            for type in types {
                if(String(describing: type) == name) {
                    return type
                }
            }
            
            throw DeserializationError.unrecognizedSerializedName
        }
    }
    
    // MARK: Component
    
    func testSerializationType() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = SerializableComponent(field: 10)
        let object = serializer.serialize(original)
        XCTAssertEqual(object.contentType, .component)
        
        let ser: SerializableComponent = try serializer.extract(from: object)
        
        XCTAssertEqual(ser.field, original.field)
    }
    
    // MARK: Entity
    
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
        XCTAssertEqual(object.contentType, .entity)
        XCTAssertEqual(deserialized.id, 20)
        XCTAssertEqual(deserialized.type, 3)
        
        // Check deserialzied components
        XCTAssertEqual(2, deserialized.components.count)
        let deserializedComps = deserialized.components(ofType: SerializableComponent.self)
        
        XCTAssert(deserializedComps.elementsEqual(originalComponents, by: { $0.field == $1.field }))
    }
    
    func testSerializeEntityError() throws {
        // Tests error thrown when trying to serialize an entity with an
        // unserializable component
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Entity(components: [UnserializableComponent()])
        
        do {
            _=try serializer.serialize(original)
            XCTFail()
        } catch {
            XCTAssert(error is SerializationError)
        }
    }
    
    // MARK: Space
    
    func testSerializeSpace() throws {
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Space()
        original.addEntity(Entity(components: [SerializableComponent(field: 10)]))
        original.addSubspace(SerializableSubspace(subspaceField: 20))
        
        let object = try serializer.serialize(original)
        
        XCTAssertEqual(object.contentType, .space)
        
        let deserialized: Space = try serializer.extract(from: object)
        
        XCTAssertEqual(1, deserialized.entities.count)
        XCTAssertEqual(1, deserialized.entities[0].components.count)
        XCTAssertEqual(1, deserialized.subspaces.count)
        
        XCTAssertEqual(deserialized.subspace(SerializableSubspace.self)?.subspaceField, 20)
    }
    
    func testSerializeSpaceEntityError() throws {
        // Tests error thrown when trying to serialize a space with an
        // unserializable entity
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Space()
        original.addEntity(Entity(components: [UnserializableComponent()]))
        
        do {
            _=try serializer.serialize(original)
            XCTFail()
        } catch {
            XCTAssert(error is SerializationError)
        }
    }
    
    func testSerializeSpaceSubspaceError() throws {
        // Tests error thrown when trying to serialize a space with an
        // unserializable subspace
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Space()
        original.addSubspace(Subspace()) // Default Subspace is unserializable by default
        
        do {
            _=try serializer.serialize(original)
            XCTFail()
        } catch {
            XCTAssert(error is SerializationError)
        }
    }
    
    func testFullDeserialize() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let json: JSON = [
            "contentType": "space",
            "typeName": "Space", // Must always be 'Space' for spaces
            "data": [
                "subspaces": [
                    [
                        "contentType": "subspace",
                        "typeName": "SerializableSubspace",
                        "data": [
                            "subspaceField": 10
                        ]
                    ]
                ],
                "entities": [
                    [
                        "contentType": "entity",
                        "typeName": "Entity", // Must always be 'Entity' for entities
                        "data": [
                            "id": 1,
                            "type": 2,
                            "components": [
                                [
                                    "contentType": "component",
                                    "typeName": "SerializableComponent",
                                    "data": [
                                        "field": 20
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
            
        let serialized = try Serialized.deserialized(from: json)
        let space: Space = try serializer.extract(from: serialized)
        
        XCTAssertEqual(space.subspaces.count, 1)
        XCTAssertEqual(space.subspace(SerializableSubspace.self)?.subspaceField, 10)
        
        XCTAssertEqual(space.entities.count, 1)
        XCTAssertEqual(space.entities[0].id, 1)
        XCTAssertEqual(space.entities[0].type, 2)
        XCTAssertEqual(space.entities[0].component(ofType: SerializableComponent.self)?.field, 20)
    }
}
