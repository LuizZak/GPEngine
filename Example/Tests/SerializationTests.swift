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
            
            throw DeserializationError.unrecognizedSerializedName(name: name)
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
    
    // MARK: Presets
    func testDeserializePreset() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [
                    "x": "number",
                    "y": [ "type": "number", "default": 20.2 ]
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [
                        "id": 1,
                        "type": 0xff,
                        "components": [
                            [
                                "contentType": "component",
                                "typeName": "PositionComponent",
                                "data": [
                                    "x": [ "presetVariable": "x" ],
                                    "y": [ "presetVariable": "y" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            
            let preset = try SerializedPreset.deserialized(from: json)
            
            XCTAssertEqual("Player", preset.name)
            XCTAssertEqual(.entity, preset.type)
            
            // Check preset serialized within
            XCTAssertEqual(preset.data.contentType, .entity)
            XCTAssertEqual(preset.data.typeName, "Entity")
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testReplacePresetVariables() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [
                    "x": "number",
                    "y": "number",
                    "z": [ "type": "number", "default": 30 ]
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [
                        "id": 1,
                        "type": 0xff,
                        "components": [
                            [
                                "contentType": "component",
                                "typeName": "PositionComponent",
                                "data": [
                                    "x": [ "presetVariable": "x" ],
                                    "y": [ "presetVariable": "y" ],
                                    "z": [ "presetVariable": "z" ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            
            let preset = try SerializedPreset.deserialized(from: json)
            
            let expanded =
                try preset.expandPreset(withVariables:
                    [
                        "x": 10,
                        "y": 20
                    ])
            
            let data = expanded.data
            
            // Verify data
            XCTAssertEqual(data["components", 0, "data", "x"], 10)
            XCTAssertEqual(data["components", 0, "data", "y"], 20)
            XCTAssertEqual(data["components", 0, "data", "z"], 30)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testSimplePresetDeserialization() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [
                    "var1": [ "type": "number", "default": 0 ],
                    "var2": "string"
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [ ]
                ]
            ]
            
            let preset = try SerializedPreset.deserialized(from: json)
            
            XCTAssertEqual(preset.name, "Player")
            XCTAssertEqual(preset.type, .entity)
            XCTAssertEqual(preset.variables.count, 2)
            XCTAssertEqual(preset.variables["var1"]?.name, "var1")
            XCTAssertEqual(preset.variables["var1"]?.type, .number)
            XCTAssertEqual(preset.variables["var1"]?.defaultValue as? Double, Double(0))
            XCTAssertEqual(preset.variables["var2"]?.name, "var2")
            XCTAssertEqual(preset.variables["var2"]?.type, .string)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testPresetSerializedDataDifferentTypeError() {
        // If the type specified in 'presetName' differs from the presetData's
        // inner 'contentType', an error should be raised.
        
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [:],
                "presetData": [
                    "contentType": "custom",
                    "typeName": "MyType",
                    "data": [:]
                ]
            ]
            
            _=try SerializedPreset.deserialized(from: json)
            
            XCTFail("Should have thrown error")
        } catch {
            XCTAssert(error is DeserializationError)
        }
    }
    
    func testPresetSerializedDataNotDictionaryError() {
        // Presets can only contain dictionaries within their 'presetData' key
        
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [:],
                "presetData": [
                ]
            ]
            
            _=try SerializedPreset.deserialized(from: json)
            
            XCTFail("Should have thrown error")
        } catch {
            XCTAssert(error is DeserializationError)
        }
    }
    
    func testPresetCannotRepresentPresets() {
        // Presets are not allowed to represent 'preset' typed contents
        
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "preset",
                "presetVariables": [:],
                "presetData": [
                    "contentType": "preset",
                    "typeName": "SerializedPreset",
                    "data": [:]
                ]
            ]
            
            _=try SerializedPreset.deserialized(from: json)
            
            XCTFail("Should have thrown error")
        } catch {
            XCTAssert(error is DeserializationError)
        }
    }
    
    func testPresetVariableTypeError() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [
                    "var": "number"
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [
                        "from-preset": [ "presetVariable": "var" ]
                    ]
                ]
            ]
            
            let preset = try SerializedPreset.deserialized(from: json)
            
            _=try preset.expandPreset(withVariables: [ "var": "but i'm a string!" ])
            
            XCTFail("Should have thrown error")
        } catch {
            XCTAssert(error is SerializedPreset.VariableReplaceError)
        }
    }
    
    func testPresetDefaultVariableTypeError() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [
                    "broken": [ "type": "number", "default": "but i'm a string!" ]
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [:]
                ]
            ]
            
            _=try SerializedPreset.deserialized(from: json)
            
            XCTFail("Should have failed")
        } catch {
            XCTAssert(error is DeserializationError)
        }
    }
    
    // MARK: Preset expansion in serialized object
    
    func testPresetExpansion() {
        do {
            let serializer = GameSerializer(typeProvider: Provider())
            
            let json: JSON = [
                "contentType": "space",
                "typeName": "Space",
                
                // Presets are defined here, for an entity and a subspace...
                "presets": [
                    [
                        "presetName": "Player",
                        "presetType": "entity",
                        "presetVariables": [
                            "var": "number"
                        ],
                        "presetData": [
                            "contentType": "entity",
                            "typeName": "Entity",
                            "data": [
                                "id": 1,
                                "type": 2,
                                "components": [
                                    [
                                        "contentType": "component",
                                        "typeName": "SerializableComponent",
                                        "data": [
                                            "field": [ "presetVariable": "var" ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ],
                    [
                        "presetName": "ASubspace",
                        "presetType": "subspace",
                        "presetVariables": [
                            "var": "number"
                        ],
                        "presetData": [
                            "contentType": "subspace",
                            "typeName": "SerializableSubspace",
                            "data": [
                                "subspaceField": [ "presetVariable": "var" ]
                            ]
                        ]
                    ]
                ],
                
                // Presets are expanded here!
                "data": [
                    "subspaces": [
                        [
                            "contentType": "preset",
                            "typeName": "ASubspace",
                            "data": [
                                "var": 10
                            ]
                        ]
                    ],
                    "entities": [
                        [
                            "contentType": "preset",
                            "typeName": "Player",
                            "data": [
                                "var": 20
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
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testRecursivePresetExpansion() {
        // Tests that a moderately recursive-looking preset does not explode
        // during expansion, and results in an error during deserialization
        
        do {
            let serializer = GameSerializer(typeProvider: Provider())
            
            let json: JSON = [
                "contentType": "space",
                "typeName": "Space",
                "presets": [
                    [
                        "presetName": "Player",
                        "presetType": "entity",
                        "presetVariables": [
                            "var": "number"
                        ],
                        "presetData": [
                            "contentType": "entity",
                            "typeName": "Entity",
                            "presets": [
                                [
                                    "presetName": "Player",
                                    "presetType": "entity",
                                    "presetVariables": [:],
                                    "presetData": [
                                        "contentType": "entity",
                                        "typeName": "Entity",
                                        "data": [
                                            :
                                        ]
                                    ]
                                ]
                            ],
                            "data": [
                                "id": 1,
                                "type": 2,
                                "components": [
                                    [
                                        "contentType": "preset",
                                        "typeName": "Player",
                                        "data": [
                                            :
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ],
                "data": [
                    "subspaces": [ ],
                    "entities": [
                        [
                            "contentType": "preset",
                            "typeName": "Player",
                            "data": [
                                "var": 20
                            ]
                        ]
                    ]
                ]
            ]
            
            let serialized = try Serialized.deserialized(from: json)
            let _: Space=try serializer.extract(from: serialized)
            XCTFail("Should not have succeeded")
        } catch {
            // Success!
        }
    }
}
