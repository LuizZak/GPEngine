//
//  SerializationTests.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 01/04/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
@testable import GPEngine
#if SWIFT_PACKAGE
@testable import Serialization
#endif

class SerializationTests: XCTestCase {
    struct SerializableCodableComponent: Component, Serializable, Codable {
        var field1: Int
        var field2: String
    }
    
    struct SerializableComponent: Component, Serializable {
        var field: Int
        
        init(field: Int) {
            self.field = field
        }
        
        init(json: JSON, path: JsonPath) throws {
            field = try json[path: "field"].integer(prefixPath: path)
        }
        
        func serialized() -> JSON {
            return ["field": field.json]
        }
    }
    
    final class SerializableSubspace: Subspace, Serializable {
        var subspaceField: Int
        
        init(subspaceField: Int) {
            self.subspaceField = subspaceField
        }
        
        init(json: JSON, path: JsonPath) throws {
            subspaceField = try json[path: "subspaceField"].integer(prefixPath: path)
        }
        
        func serialized() -> JSON {
            return ["subspaceField": subspaceField.json]
        }
    }
    
    struct UnserializableComponent: Component {
        
    }

    final class UnserializableSubspace: Subspace {

    }
    
    class Provider: BasicSerializationTypeProvider {
        var serializableTypes: [(Serializable.Type, (JSON, JsonPath) throws -> Serializable)] = [
            (SerializableCodableComponent.self, SerializableCodableComponent.init),
            (SerializableComponent.self, SerializableComponent.init),
            (SerializableSubspace.self, SerializableSubspace.init)
        ]
    }
    
    // MARK: Component
    
    func testSerializationType() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = SerializableComponent(field: 10)
        let object = serializer.serialize(original)
        XCTAssertEqual(object.contentType, .component)
        
        let ser: SerializableComponent = try serializer.extract(from: object, path: .root)
        
        XCTAssertEqual(ser.field, original.field)
    }
    
    func testSerializationCodableType() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = SerializableCodableComponent(field1: 10, field2: "abc")
        let object = serializer.serialize(original)
        XCTAssertEqual(object.contentType, .component)
        
        let ser: SerializableCodableComponent = try serializer.extract(from: object, path: .root)
        
        XCTAssertEqual(ser.field1, original.field1)
        XCTAssertEqual(ser.field2, original.field2)
    }
    
    // MARK: Entity
    
    func testSerializeEntity() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        let expected: JSON = [
            "presets": [],
            "typeName": "Entity",
            "contentType": "entity",
            "data": [
                "id": 20.0,
                "type": 3.0,
                "components": [
                    [
                        "typeName": "SerializableComponent",
                        "contentType": "component",
                        "presets": [],
                        "data": [
                            "field": 10.0,
                        ],
                    ],
                    [
                        "typeName": "SerializableComponent",
                        "contentType": "component",
                        "presets": [],
                        "data": [
                            "field": 20.0,
                        ],
                    ],
                ],
            ],
        ]
        
        let entity = Entity(components: [
            SerializableComponent(field: 10),
            SerializableComponent(field: 20)
        ])
        entity.id = 20
        entity.type = 3
        
        let object = try serializer.serialize(entity)
        
        assertEquals(expected, object.serialized())
    }
    
    func testSerializeEntity_roundtrip() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        
        let originalComponents = [
            SerializableComponent(field: 10),
            SerializableComponent(field: 20)
        ]
        let original = Entity(components: originalComponents)
        original.id = 20
        original.type = 3
        
        let object = try serializer.serialize(original)
        
        let deserialized: Entity = try serializer.extract(from: object, path: .root)
        // Check basic deserialization
        XCTAssertEqual(object.contentType, .entity)
        XCTAssertEqual(deserialized.id, 20)
        XCTAssertEqual(deserialized.type, 3)
        
        // Check deserialized components
        XCTAssertEqual(2, deserialized.components.count)
        let deserializedComps = deserialized.components(ofType: SerializableComponent.self)
        
        XCTAssert(deserializedComps.elementsEqual(originalComponents) { $0.field == $1.field })
    }
    
    func testSerializeEntityError() throws {
        // Tests error thrown when trying to serialize an entity with an
        // unserializable component
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Entity(components: [UnserializableComponent()])
        
        do {
            _ = try serializer.serialize(original)
            XCTFail("Should not have serialized successfully")
        } catch {
            XCTAssert(error is SerializationError)
        }
    }

    func testCanSerializeEntity() {
        let entity = Entity()

        XCTAssertTrue(GameSerializer.canSerialize(entity))
    }

    func testCanSerializeEntityChecksComponents() {
        let entity = Entity(components: [SerializableComponent(field: 1)])

        XCTAssertTrue(GameSerializer.canSerialize(entity))
    }

    func testCanSerializeEntityFailsOnNonSerializableComponent() {
        let entity = Entity(components: [UnserializableComponent()])

        XCTAssertFalse(GameSerializer.canSerialize(entity))
    }
    
    // MARK: Space
    
    func testSerializeSpace() throws {
        let serializer = GameSerializer(typeProvider: Provider())
        let expected: JSON = [
            "presets": [],
            "typeName": "Space",
            "contentType": "space",
            "data": [
                "entities": [
                    [
                        "presets": [],
                        "typeName": "Entity",
                        "contentType": "entity",
                        "data": [
                            "id": 20.0,
                            "type": 3.0,
                            "components": [
                                [
                                    "typeName": "SerializableComponent",
                                    "contentType": "component",
                                    "presets": [],
                                    "data": [
                                        "field": 10.0,
                                    ],
                                ],
                                [
                                    "typeName": "SerializableComponent",
                                    "contentType": "component",
                                    "presets": [],
                                    "data": [
                                        "field": 20.0,
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
                "subspaces": [
                    [
                        "typeName": "SerializableSubspace",
                        "contentType": "subspace",
                        "presets": [],
                        "data": [
                            "subspaceField": 1.0,
                        ],
                    ],
                ],
            ],
        ]
        
        let entity = Entity(components: [
            SerializableComponent(field: 10),
            SerializableComponent(field: 20)
        ])
        entity.id = 20
        entity.type = 3
        let space = Space()
        space.addEntity(entity)
        space.addSubspace(SerializableSubspace(subspaceField: 1))
        
        let object = try serializer.serialize(space)

        assertEquals(expected, object.serialized())
    }
    
    func testSerializeSpace_roundtrip() throws {
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let original = Space()
        original.addEntity(Entity(components: [SerializableComponent(field: 10)]))
        original.addSubspace(SerializableSubspace(subspaceField: 20))
        
        let object = try serializer.serialize(original)
        
        XCTAssertEqual(object.contentType, .space)
        
        let deserialized: Space = try serializer.extract(from: object, path: .root)
        
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
            _ = try serializer.serialize(original)
            XCTFail("Should not have serialized successfully")
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
            _ = try serializer.serialize(original)
            XCTFail("Should not have serialized successfully")
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
                            "subspaceField": 10,
                        ],
                    ],
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
                                        "field": 20,
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
        ]
            
        let serialized = try Serialized(json: json, path: .root)
        let space: Space = try serializer.extract(from: serialized, path: .root)
        
        XCTAssertEqual(space.subspaces.count, 1)
        XCTAssertEqual(space.subspace(SerializableSubspace.self)?.subspaceField, 10)
        
        XCTAssertEqual(space.entities.count, 1)
        XCTAssertEqual(space.entities[0].id, 1)
        XCTAssertEqual(space.entities[0].type, 2)
        XCTAssertEqual(space.entities[0].component(ofType: SerializableComponent.self)?.field, 20)
    }

    func testCanSerializeSpace() {
        let space = Space()

        XCTAssertTrue(GameSerializer.canSerialize(space))
    }

    func testCanSerializeSpaceChecksComponents() {
        let space = Space()
        space.addEntity(Entity(components: [SerializableComponent(field: 1)]))

        XCTAssertTrue(GameSerializer.canSerialize(space))
    }

    func testCanSerializeSpaceFailsOnNonSerializableComponent() {
        let space = Space()
        space.addEntity(Entity(components: [UnserializableComponent()]))

        XCTAssertFalse(GameSerializer.canSerialize(space))
    }

    func testCanSerializeSpaceFailsOnNonSerializableSubspace() {
        let space = Space()
        space.addSubspace(UnserializableSubspace())

        XCTAssertFalse(GameSerializer.canSerialize(space))
    }
    
    // MARK: Presets
    func testDeserializePreset() throws {
        let json: JSON = [
            "presetName": "Player",
            "presetType": "entity",
            "presetVariables": [
                "x": "number",
                "y": [ "type": "number", "default": 20.2 ],
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
                            ],
                        ],
                    ],
                ],
            ],
        ]
        
        let preset = try SerializedPreset(json: json, path: .root)
        
        XCTAssertEqual("Player", preset.name)
        XCTAssertEqual(.entity, preset.type)
        
        // Check preset serialized within
        XCTAssertEqual(preset.data.contentType, .entity)
        XCTAssertEqual(preset.data.typeName, "Entity")
    }
    
    func testReplacePresetVariables() throws {
        let json: JSON = [
            "presetName": "Player",
            "presetType": "entity",
            "presetVariables": [
                "x": "number",
                "y": "bool",
                "z": [ "type": "string", "default": "abc" ],
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
                                "z": [ "presetVariable": "z" ],
                            ],
                        ],
                    ],
                ],
            ],
        ]
        
        let preset = try SerializedPreset(json: json, path: .root)
        
        let expanded =
            try preset.expandPreset(withVariables:
                [
                    "x": 10,
                    "y": false
                ])
        
        let data = expanded.data
        
        // Verify data
        XCTAssertEqual(data["components"]?[0]["data"]?["x"]?.double, 10)
        XCTAssertEqual(data["components"]?[0]["data"]?["y"]?.bool, false)
        XCTAssertEqual(data["components"]?[0]["data"]?["z"]?.string, "abc")
    }

    func testReplacePresetVariables_respectsVariablesPlaceholderValue() throws {
        let json: JSON = [
            "presetName": "Player",
            "presetType": "entity",
            "presetVariables": [
                "x": "number",
                "y": "bool",
                "z": [ "type": "string", "default": "abc" ]
            ],
            "variablesPlaceholder": "aCustomPlaceholder",
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
                                "x": [ "aCustomPlaceholder": "x" ],
                                "y": [ "aCustomPlaceholder": "y" ],
                                "z": [ "aCustomPlaceholder": "z" ],
                            ],
                        ],
                    ],
                ],
            ],
        ]
        
        let preset = try SerializedPreset(json: json, path: .root)
        
        let expanded =
            try preset.expandPreset(withVariables:
                [
                    "x": 10,
                    "y": false
                ])
        
        let data = expanded.data
        
        // Verify data
        XCTAssertEqual(data["components"]?[0]["data"]?["x"]?.double, 10)
        XCTAssertEqual(data["components"]?[0]["data"]?["y"]?.bool, false)
        XCTAssertEqual(data["components"]?[0]["data"]?["z"]?.string, "abc")
    }

    func testEmptyPresetSerialization() {
        let expected: JSON = [
            "presetName": "PresetName",
            "presetType": "entity",
            "presetVariables": [:],
            "presetData": [
                "presets": [],
                "contentType": "entity",
                "data": [:],
                "typeName": "Entity",
            ]
        ]
        let preset = SerializedPreset(
            name: "PresetName",
            type: .entity,
            variables: [:],
            data: Serialized(typeName: "Entity", contentType: .entity, data: [:])
        )

        let result = preset.serialized()

        assertEquals(expected, result)
    }

    func testPresetSerialization_emitsVariablesPlaceholder() {
        let expected: JSON = [
            "presetName": "PresetName",
            "presetType": "entity",
            "presetVariables": [:],
            "variablesPlaceholder": "aCustomPlaceholder",
            "presetData": [
                "presets": [],
                "contentType": "entity",
                "data": [:],
                "typeName": "Entity",
            ]
        ]
        let preset = SerializedPreset(
            name: "PresetName",
            type: .entity,
            variables: [:],
            variablesPlaceholder: "aCustomPlaceholder",
            data: Serialized(typeName: "Entity", contentType: .entity, data: [:])
        )

        let result = preset.serialized()

        assertEquals(expected, result)
    }

    func testPresetSerialization() {
        let expected: JSON = [
            "presetName": "PresetName",
            "presetType": "entity",
            "presetVariables": [
                "var1": [
                    "type": "number",
                    "default": 1,
                ],
                "var2": "number",
            ],
            "presetData": [
                "typeName": "TypeName",
                "presets": [
                    [
                        "presetName": "Player",
                        "presetType": "entity",
                        "presetVariables": [:],
                        "presetData": [
                            "presets": [],
                            "contentType": "entity",
                            "data": [:],
                            "typeName": "Entity",
                        ]
                    ]
                ],
                "data": [:],
                "contentType": "entity",
            ]
        ]
        let innerPreset = SerializedPreset(
            name: "Player",
            type: .entity,
            variables: [:],
            data: Serialized(typeName: "Entity", contentType: .entity, data: [:])
        )
        let preset = SerializedPreset(
            name: "PresetName",
            type: .entity,
            variables: [
                "var1": SerializedPreset.Variable(name: "var1", type: .number, defaultValue: 1),
                "var2": SerializedPreset.Variable(name: "var2", type: .number)
            ],
            data: Serialized(typeName: "TypeName", presets: [innerPreset], contentType: .entity, data: [:])
        )

        let result = preset.serialized()

        assertEquals(expected, result)
    }
    
    func testSimplePresetDeserialization() throws {
        let json: JSON = [
            "presetName": "Player",
            "presetType": "entity",
            "presetVariables": [
                "var1": [ "type": "number", "default": 0 ],
                "var2": "string",
            ],
            "presetData": [
                "contentType": "entity",
                "typeName": "Entity",
                "data": [],
            ],
        ]
        
        let preset = try SerializedPreset(json: json, path: .root)
        
        XCTAssertEqual(preset.name, "Player")
        XCTAssertEqual(preset.type, .entity)
        XCTAssertEqual(preset.variables.count, 2)
        XCTAssertEqual(preset.variables["var1"]?.name, "var1")
        XCTAssertEqual(preset.variables["var1"]?.type, .number)
        XCTAssertEqual(preset.variables["var1"]?.defaultValue, .number(0))
        XCTAssertEqual(preset.variables["var2"]?.name, "var2")
        XCTAssertEqual(preset.variables["var2"]?.type, .string)
    }

    func testPresetDeserialization_presetsAreProperlyScoped() throws {
        let json: JSON = [
            "presetName": "Object",
            "presetType": "space",
            "presetVariables": [
                "var1": [ "type": "number", "default": 0 ],
                "var2": "string",
            ],
            "presetData": [
                "contentType": "space",
                "typeName": "Space",
                "data": [
                    "entities": [
                        [
                            "contentType": "entity",
                            "typeName": "Entity",
                            "presets": [
                                [
                                    "presetName": "Nested",
                                    "presetType": "component",
                                    "presetVariables": [
                                        "var1": [ "type": "number", "default": 0 ],
                                    ],
                                    "presetData": [
                                        "contentType": "component",
                                        "typeName": "SerializableComponent",
                                        "data": [
                                            "field": [ "presetVariable": "var1" ],
                                        ],
                                    ],
                                ],
                            ],
                            "data": [
                                "id": 0,
                                "type": 0,
                                "components": [],
                            ],
                        ],
                        [
                            "contentType": "entity",
                            "typeName": "Entity",
                            "data": [
                                "id": 0,
                                "type": 0,
                                "components": [
                                    // Reference to preset created in previous
                                    // entity should not be visible in this entity.
                                    [
                                        "contentType": "preset",
                                        "typeName": "Nested",
                                        "vars": [
                                            "var1": 2,
                                        ],
                                    ],
                                ],
                            ],
                        ],
                    ],
                    "subspaces": [],
                ],
            ],
        ]
        
        do {
            let preset = try SerializedPreset(json: json, path: .root)
            let serializer = GameSerializer(typeProvider: Provider())
            let _: Space = try serializer.extract(
                from: preset.data,
                path: .root.dictionary("presetData").dictionary("data")
            )

            XCTFail("Should have thrown error")
        } catch
            DeserializationError.presetNotFound(
                "Nested",
                let path
            )
        {
            XCTAssertEqual(path.asJsonAccessString(), "<root>.presetData.data.entities[1].components[0].typeName")
        } catch {
            XCTFail("Expected DeserializationError.presetNotFound error, found \(error).")
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
                    "data": [:],
                ]
            ]
            
            _ = try SerializedPreset(json: json, path: .root)
            
            XCTFail("Should have thrown error")
        } catch let error as DeserializationError {
            XCTAssertEqual(
                error.description,
                "Deserialization error @ <root>.presetData.contentType: Expected preset data of type 'entity', but received preset with contentType 'custom' in preset 'Player'"
            )
        } catch {
            XCTFail("Expected DeserializationError error, found \(error)")
        }
    }
    
    func testPresetSerializedDataNotDictionaryError() {
        // Presets can only contain dictionaries within their 'presetData' key
        
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [:],
                "presetData": [],
            ]
            
            _ = try SerializedPreset(json: json, path: .root)
            
            XCTFail("Should have thrown error")
        } catch let error as DeserializationError {
            XCTAssertEqual(
                error.description,
                "Deserialization error @ <root>.presetData: Expected 'presetData' to contain a dictionary in preset 'Player'"
            )
        } catch {
            XCTFail("Expected DeserializationError error, found \(error)")
        }
    }
    
    func testDeserializePresetsKeyNotArray() {
        // 'presets' key in serialized objects need to be an array.
        
        do {
            let json: JSON = [
                "contentType": "entity",
                "typeName": "Entity",
                "presets": [ // Dictionary, not an array
                    "presetName": "Player",
                    "presetType": "entity",
                    "presetVariables": [:],
                    "presetData": [],
                ],
                "data": [
                    "id": 0,
                    "type": 0,
                    "components": [],
                ],
            ]
            
            _ = try Serialized(json: json, path: .root)
            
            XCTFail("Should have thrown error")
        } catch let error as DeserializationError {
            XCTAssertEqual(
                error.description,
                "Deserialization error @ <root>.presets: Expected 'presets' to be an array, found 'dictionary'"
            )
        } catch {
            XCTFail("Expected DeserializationError error, found \(error)")
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
                    "data": [:],
                ],
            ]
            
            _ = try SerializedPreset(json: json, path: .root)
            
            XCTFail("Should have thrown error")
        } catch let error as DeserializationError {
            XCTAssertEqual(
                error.description,
                "Deserialization error @ <root>: Presets cannot represent preset types themselves in preset 'Player'"
            )
        } catch {
            XCTFail("Expected DeserializationError error, found \(error)")
        }
    }
    
    func testPresetVariableTypeError() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [
                    "var": "number",
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [
                        "from-preset": [ "presetVariable": "var" ],
                    ],
                ],
            ]
            
            let preset = try SerializedPreset(json: json, path: .root)
            
            _ = try preset.expandPreset(withVariables: [ "var": "but i'm a string!" ])
            
            XCTFail("Should have thrown error")
        } catch {
            XCTAssert(error is SerializedPreset.VariableReplaceError)
        }
    }
    
    func testPresetNonExistentVariableError() {
        do {
            let json: JSON = [
                "presetName": "Player",
                "presetType": "entity",
                "presetVariables": [:],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [
                        "from-preset": [ "presetVariable": "var" ],
                    ],
                ],
            ]

            let preset = try SerializedPreset(json: json, path: .root)

            _ = try preset.expandPreset(withVariables: ["var": "abc"])

            XCTFail("Should have thrown error")
        } catch {
            XCTAssert(error is SerializedPreset.VariableReplaceError)
        }
    }

    func testPresetMissingVariableError() {
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
                        "from-preset": [ "presetVariable": "var" ],
                    ],
                ],
            ]

            let preset = try SerializedPreset(json: json, path: .root)

            _ = try preset.expandPreset(withVariables: [:])

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
                    "broken": [ "type": "number", "default": "but i'm a string!" ],
                ],
                "presetData": [
                    "contentType": "entity",
                    "typeName": "Entity",
                    "data": [:],
                ],
            ]
            
            _ = try SerializedPreset(json: json, path: .root)
            
            XCTFail("Should have failed")
        } catch let error as DeserializationError {
            XCTAssertEqual(
                error.description,
                "Deserialization error @ <root>.presetVariables.broken: Default value for preset variable 'broken' has a different type (string) than declared (number) in preset 'Player'"
            )
        } catch {
            XCTFail("Expected DeserializationError error, found \(error)")
        }
    }
    
    // MARK: Preset expansion in serialized object
    
    func testPresetExpansion() throws {
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
                        "var": "number",
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
                                        "field": [ "presetVariable": "var" ],
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
                [
                    "presetName": "ASubspace",
                    "presetType": "subspace",
                    "presetVariables": [
                        "var": "number",
                    ],
                    "presetData": [
                        "contentType": "subspace",
                        "typeName": "SerializableSubspace",
                        "data": [
                            "subspaceField": [ "presetVariable": "var" ],
                        ],
                    ],
                ],
            ],
            
            // Presets are expanded here!
            "data": [
                "subspaces": [
                    [
                        "contentType": "preset",
                        "typeName": "ASubspace",
                        "data": [
                            "var": 10,
                        ],
                    ],
                ],
                "entities": [
                    [
                        "contentType": "preset",
                        "typeName": "Player",
                        "data": [
                            "var": 20,
                        ],
                    ],
                ],
            ],
        ]
        
        let serialized = try Serialized(json: json, path: .root)
        let space: Space = try serializer.extract(from: serialized, path: .root)
        
        XCTAssertEqual(space.subspaces.count, 1)
        XCTAssertEqual(space.subspace(SerializableSubspace.self)?.subspaceField, 10)
        
        XCTAssertEqual(space.entities.count, 1)
        XCTAssertEqual(space.entities[0].id, 1)
        XCTAssertEqual(space.entities[0].type, 2)
        XCTAssertEqual(space.entities[0].component(ofType: SerializableComponent.self)?.field, 20)
    }
    
    func testRecursivePresetExpansion() throws {
        // Tests that a moderately recursive-looking preset does not explode
        // during expansion, and results in an error during deserialization
        
        let serializer = GameSerializer(typeProvider: Provider())
        
        let json: JSON = [
            "contentType": "space",
            "typeName": "Space",
            "presets": [
                [
                    "presetName": "Player",
                    "presetType": "entity",
                    "presetVariables": [
                        "var": "number",
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
                                    "data": [:],
                                ],
                            ],
                        ],
                        "data": [
                            "id": 1,
                            "type": 2,
                            "components": [
                                [
                                    "contentType": "preset",
                                    "typeName": "Player",
                                    "data": [:],
                                ],
                            ],
                        ],
                    ],
                ],
            ],
            "data": [
                "subspaces": [ ],
                "entities": [
                    [
                        "contentType": "preset",
                        "typeName": "Player",
                        "data": [
                            "var": 20,
                        ],
                    ],
                ],
            ],
        ]
        
        let serialized = try Serialized(json: json, path: .root)

        do {
            let _: Space = try serializer.extract(from: serialized, path: .root)
        } catch let error as DeserializationError {
            XCTAssertEqual(
                error.description,
                "Deserialization error @ <root>.entities[0].components[0].presetData.data.data: unrecognized serialized type name 'Entity'"
            )
        } catch {
            XCTFail("Expected DeserializationError error, found \(error)")
        }
    }

    private func assertEquals(_ expected: JSON, _ actual: JSON, line: UInt = #line) {
        guard expected != actual else {
            return
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

            let expString = try XCTUnwrap(String(data: try encoder.encode(expected), encoding: .utf8))
            let actString = try XCTUnwrap(String(data: try encoder.encode(actual), encoding: .utf8))

            XCTFail(
                """
                (\(expected)) is not equal to (\(actual))

                Expected JSON:

                \(expString)

                Actual JSON:

                \(actString)
                """,
                line: line
            )
        } catch {
            XCTFail("(\(expected)) is not equal to (\(actual))", line: line)
        }
    }
}
