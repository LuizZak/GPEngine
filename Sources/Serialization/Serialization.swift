//
//  Serialization.swift
//  Pods
//
//  Created by Luiz Fernando Silva on 01/04/17.
//
//

import Foundation
#if SWIFT_PACKAGE
import GPEngine
#endif

/// Errors that can be throwing during a serialization process.
///
/// - cannotSerialize: An error occurring during the serialization process
public enum SerializationError: Error, CustomStringConvertible {
    case cannotSerialize(reason: String)
    
    public var description: String {
        switch self {
        case .cannotSerialize(let reason):
            return "Serialization error: \(reason)"
        }
    }
}

public typealias JsonPath = [JSONSubscriptAccess.JSONAccess]

/// Errors that can be throwing during a deserialization process.
///
/// - notImplemented: The current implementer has not overridden a default
/// implementation with a suitable body.
/// Default error thrown when trying to call a serialization-related method on
/// objects that have not implemented these methods.
///
/// - unrecognizedSerializedName: Thrown when a serializable type provider cannot
/// detect a given serializable type name.
///
/// - invalidSerialized: A serialized object cannot be deserialized with a
/// provided JSON
///
/// - presetNotFound: Error raised when a preset with a specific name is not found.
public enum DeserializationError: Error, CustomStringConvertible {
    case notImplemented(path: JsonPath)
    case unrecognizedSerializedName(name: String, path: JsonPath)
    case invalidSerialized(message: String, path: JsonPath)
    case presetNotFound(presetName: String, path: JsonPath)
    
    public var description: String {
        switch self {
        case .notImplemented(let path):
            return "Deserialization error @ \(path.asJsonAccessString()): method not implemented"
        case .unrecognizedSerializedName(let name, let path):
            return "Deserialization error @ \(path.asJsonAccessString()): unrecognized serialized type name '\(name)'"
        case .invalidSerialized(let message, let path):
            return "Deserialization error @ \(path.asJsonAccessString()): \(message)"
        case .presetNotFound(let presetName, let path):
            return "Deserialization error @ \(path.asJsonAccessString()): preset '\(presetName)' not found"
        }
    }

    /// Gets the common 'path' associated value from this enum.
    public var path: JsonPath {
        switch self {
        case .notImplemented(let path),
            .unrecognizedSerializedName(_, path: let path),
            .invalidSerialized(_, path: let path),
            .presetNotFound(_, path: let path):

            return path
        }
    }
}

/// Class capable of serializing/deserializing components
public class GameSerializer {
    /// A type provider for this serializer
    public var typeProvider: SerializationTypeProvider
    
    /// Preset context for presets found during deserialization
    private let presetContext = PresetContext()
    
    public init(typeProvider: SerializationTypeProvider) {
        self.typeProvider = typeProvider
    }
    
    /// Serializes an entity passed in.
    /// Throws, if any of the components are non-serializable.
    public func serialize(_ entity: Entity) throws -> Serialized {
        let type = Serialized.ContentType.entity
        let name = String(describing: Entity.self)

        var serializedComps: [Serialized] = []
        
        for comp in entity.components {
            guard let ser = comp as? Serializable else {
                throw SerializationError.cannotSerialize(reason: "Found component type \(Swift.type(of: comp)) is not serializable.")
            }
            
            serializedComps.append(serialize(ser))
        }

        let serializedEntity = SerializedEntity(id: entity.id, type: entity.type, components: serializedComps)
        
        return Serialized(typeName: name, contentType: type, data: serializedEntity.serialized())
    }
    
    /// Serializes a game space passed in.
    /// Throws, if any of the entities are non-serializable.
    /// See `serialize(_:Entity)` for Entity serialization rules.
    public func serialize(_ space: Space) throws -> Serialized {
        let type = Serialized.ContentType.space
        let name = String(describing: Space.self)

        var serializedEntities: [Serialized] = []
        
        for entity in space.entities {
            try serializedEntities.append(serialize(entity))
        }
        
        var serializedSubspaces: [Serialized] = []
        
        for subspace in space.subspaces {
            guard let ser = subspace as? Serializable else {
                throw SerializationError.cannotSerialize(reason: "Found subspace type \(Swift.type(of: subspace)) is not serializable.")
            }
            
            serializedSubspaces.append(serialize(ser))
        }

        let serializedSpace = SerializedSpace(entities: serializedEntities, subspaces: serializedSubspaces)
        
        return Serialized(typeName: name, contentType: type, data: serializedSpace.serialized())
    }
    
    /// Serializes a given serializable object, returning an encapsulated
    /// serialized object representation.
    public func serialize(_ serializable: Serializable) -> Serialized {
        let serialized = serializable.serialized()
        let type: Serialized.ContentType
        let name = typeProvider.serializedName(for: Swift.type(of: serializable))
        
        if serializable is Component {
            type = .component
        } else if serializable is Entity {
            type = .entity
        } else if serializable is System {
            type = .system
        } else if serializable is Space {
            type = .space
        } else if serializable is Subspace {
            type = .subspace
        } else if serializable is Serialized {
            type = .serialized
        } else if serializable is SerializedPreset {
            type = .preset
        } else {
            type = .custom
        }
        
        return Serialized(typeName: name, contentType: type, data: serialized)
    }
    
    /// Deserializes a preset that is contained within a serialized object.
    /// This method returns the expanded serialized container within the preset,
    /// using the variables within the `serialized.data` property to feed the
    /// preset variables.
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func deserializePreset(in serialized: Serialized, path: JsonPath) throws -> Serialized {
        if serialized.contentType != .preset {
            throw DeserializationError
                .invalidSerialized(
                    message: "Does not represent a preset",
                    path: path
                )
        }
        
        // Fetch variables from data and expand preset on them
        guard let vars = serialized.data.dictionary else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Data for a serialized preset must be a dictionary",
                    path: path.dictionary("data")
                )
        }
        
        guard let preset = presetContext.preset(named: serialized.typeName) else {
            throw DeserializationError
                .presetNotFound(
                    presetName: serialized.typeName,
                    path: path.dictionary("typeName")
                )
        }
        
        return try preset.expandPreset(withVariables: vars)
    }
    
    /// Deserializes a given serialized instance
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func deserialize(from json: JSON, path: JsonPath) throws -> Serialized {
        return try Serialized(json: json, path: path)
    }
    
    /// Extracts an entity with all its components from a serialized object
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func extract(from serialized: Serialized, path: JsonPath) throws -> Entity {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if serialized.contentType == .preset {
            return try extract(
                from: deserializePreset(
                    in: serialized,
                    path: path
                ),
                path: path
            )
        }
        
        if serialized.typeName != "Entity" {
            throw DeserializationError
                .invalidSerialized(
                    message: "Does not represent a plain serialized Entity instance: Expected serialized.typeName to be 'Entity', but found \(serialized.typeName)",
                    path: path.dictionary("typeName")
                )
        }
        if serialized.contentType != .entity {
            throw DeserializationError
                .invalidSerialized(
                    message: "Does not represent a plain serialized Space instance: Expected serialized.contentType to be '.entity', but found \(serialized.contentType)",
                    path: path.dictionary("contentType")
                )
        }


        let serializedEntity = try SerializedEntity(
            json: serialized.data,
            path: path.dictionary("data")
        )
        let comps: [Component] = try serializedEntity.components.enumerated().map {
            try extract(
                from: $0.element,
                path: path.dictionary("components").index($0.offset)
            )
        }
        
        let entity = Entity(components: comps)
        entity.id = serializedEntity.id
        entity.type = serializedEntity.type
        
        return entity
    }
    
    /// Extracts a game space with all its entities from a serialized object
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func extract(from serialized: Serialized, path: JsonPath) throws -> Space {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if serialized.contentType == .preset {
            return try extract(
                from: deserializePreset(in: serialized, path: path),
                path: path.dictionary("presetData").dictionary("data")
            )
        }
        
        if serialized.typeName != "Space" {
            throw DeserializationError
                .invalidSerialized(
                    message: "Does not represent a plain serialized Space instance: Expected serialized.typeName to be 'Space', but found \(serialized.typeName)",
                    path: path.dictionary("typeName")
                )
        }
        if serialized.contentType != .space {
            throw DeserializationError
                .invalidSerialized(
                    message: "Does not represent a plain serialized Space instance: Expected serialized.contentType to be '.space', but found \(serialized.contentType)",
                    path: path.dictionary("contentType")
                )
        }

        let serializedSpace = try SerializedSpace(
            json: serialized.data,
            path: path.dictionary("data")
        )

        let entities: [Entity] = try serializedSpace.entities.enumerated().map {
            try extract(
                from: $0.element,
                path: path.dictionary("entities").index($0.offset)
            )
        }
        
        let subspaces: [Subspace] = try serializedSpace.subspaces.enumerated().map {
            try extract(
                from: $0.element,
                path: path.dictionary("subspaces").index($0.offset)
            )
        }
        
        let space = Space()
        for sub in subspaces {
            space.addSubspace(sub)
        }
        for entity in entities {
            space.addEntity(entity)
        }
        
        return space
    }
    
    /// Extracts a serializable object from a serialized object container.
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func extract<T: Serializable>(from serialized: Serialized, path: JsonPath) throws -> T {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if serialized.contentType == .preset {
            return try extract(
                from: deserializePreset(in: serialized, path: path),
                path: path.dictionary("presetData").dictionary("data")
            )
        }

        if let value = try typeProvider.createDeserializable(from: serialized.typeName, json: serialized.data, path: path.dictionary("path")) as? T {
            return value
        }

        throw DeserializationError
            .invalidSerialized(
                message: "Serialized value returned by type provider is not of type \(T.self)",
                path: path
            )
    }
    
    /// Extracts a Component type from a serialized object.
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func extract(from serialized: Serialized, path: JsonPath) throws -> Component {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if serialized.contentType == .preset {
            return try extract(
                from: deserializePreset(in: serialized, path: path),
                path: path.dictionary("presetData").dictionary("data")
            )
        }

        if let value = try typeProvider.createDeserializable(from: serialized.typeName, json: serialized.data, path: path.dictionary("data")) as? Component {
            return value
        }

        throw DeserializationError
            .invalidSerialized(
                message: "Serialized value returned by type provider is not of type \(Component.self)",
                path: path
            )
    }
    
    /// Extracts a Subspace type from a serialized object.
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public func extract(from serialized: Serialized, path: JsonPath) throws -> Subspace {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if serialized.contentType == .preset {
            return try extract(
                from: deserializePreset(in: serialized, path: path),
                path: path.dictionary("presetData").dictionary("data")
            )
        }
        
        if let value = try typeProvider.createDeserializable(from: serialized.typeName, json: serialized.data, path: path.dictionary("data")) as? Subspace {
            return value
        }

        throw DeserializationError
            .invalidSerialized(
                message: "Serialized value returned by type provider is not of type \(Subspace.self)",
                path: path
            )
    }
    
    /// Returns if a game space is serializable.
    /// A game space is serializable if all its entities and subspaces are, as
    /// well.
    /// See `canSerialize(_:Entity)` for entity serialization rules.
    public static func canSerialize(_ space: Space) -> Bool {
        for entity in space.entities {
            if !canSerialize(entity) {
                return false
            }
        }
        for subspace in space.subspaces {
            if !(subspace is Serializable) {
                return false
            }
        }
        
        return true
    }
    
    /// Returns if an entity is serializable.
    /// An entity is serializable if all its components are, as well.
    public static func canSerialize(_ entity: Entity) -> Bool {
        for component in entity.components {
            if !(component is Serializable) {
                return false
            }
        }
        
        return true
    }
    
    /// Scans and prints to the console a given space for components/subspaces
    /// that are not serializable.
    ///
    /// Useful during debugging.
    public static func diagnoseSerialize(on space: Space) {
        if canSerialize(space) {
            print("Space is serializable!")
            return
        }
        
        for subspace in space.subspaces {
            if !(subspace is Serializable) {
                print("Found subspace type \(type(of: subspace)) that is not serializable!")
            }
        }
        
        for entity in space.entities {
            for comp in entity.components {
                if !(comp is Serializable) {
                    print("Found component type \(type(of: comp)) on entity id \(entity.id) that is not serializable!")
                }
            }
        }
    }
    
    /// Scans and prints to the console a given entity for components that are
    /// not serializable.
    ///
    /// Useful during debugging.
    public static func diagnoseSerialize(on entity: Entity) {
        for comp in entity.components {
            if !(comp is Serializable) {
                print("Found component type \(type(of: comp)) that is not serializable!")
            }
        }
    }
    
    /// A preset context holds information about presets available during
    /// expansion of serialized objects
    private class PresetContext {
        /// The presets available within this context
        var presets: [SerializedPreset] = []
        
        /// Represents the indexes at which the presets where pushed.
        /// When calling `pop`, the method removes the last item from this array
        /// and removes all elements on `presets` past that index.
        var stack: [Int] = []
        
        /// Pushes a new preset stack context
        func push() {
            stack.append(presets.count)
        }
        
        /// Adds a series of presets to the currently available preset stack
        /// level
        func addPresets(presets: [SerializedPreset]) {
            self.presets.append(contentsOf: presets)
        }
        
        /// Removes the current preset stack.
        /// Traps, if stack is empty
        func pop() {
            let last = stack.removeLast()
            
            // Only remove if there's anything to remove
            if last != presets.count {
                presets = Array(presets[..<last])
            }
        }
        
        /// Searches for a serialized preset with a given name.
        /// This searches in reverse order, so the last preset specifies with a
        /// given name is the one chosen.
        ///
        /// Returns nil, if no preset named `name` was found.
        func preset(named name: String) -> SerializedPreset? {
            return presets.reversed().first { $0.name == name }
        }
    }
}

private struct SerializedEntity: Serializable {
    var id: Int
    var type: Int
    var components: [Serialized]

    init(json: JSON, path: JsonPath) throws {
        guard let id = json["id"]?.int else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'id' key",
                    path: path
                )
        }
        guard let type = json["type"]?.int else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'type' key",
                    path: path
                )
        }
        guard let components = json["components"]?.array else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'components' keys",
                    path: path
                )
        }

        self.id = id
        self.type = type
        self.components = try components.enumerated().map {
            try Serialized(
                json: $0.element,
                path: path.dictionary("components").index($0.offset)
            )
        }
    }

    init(id: Int, type: Int, components: [Serialized]) {
        self.id = id
        self.type = type
        self.components = components
    }

    func serialized() -> JSON {
        return [
            "id": id.json,
            "type": type.json,
            "components": components.map { $0.serialized() }.json
        ]
    }
}

private struct SerializedSpace: Serializable {
    var entities: [Serialized]
    var subspaces: [Serialized]

    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    init(json: JSON, path: JsonPath) throws {
        guard let entitiesJson = json["entities"]?.array else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'entities' key",
                    path: path
                )
        }
        guard let subspacesJson = json["subspaces"]?.array else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'subspaces' key",
                    path: path
                )
        }
        
        let entitiesKey = path.dictionary("entities")
        entities = try entitiesJson.enumerated().map {
            try Serialized(
                json: $0.element,
                path: entitiesKey.index($0.offset)
            )
        }
        let subspacesKey = path.dictionary("subspaces")
        subspaces = try subspacesJson.enumerated().map {
            try Serialized(
                json: $0.element,
                path: subspacesKey.index($0.offset)
            )
        }
    }

    init(entities: [Serialized], subspaces: [Serialized]) {
        self.entities = entities
        self.subspaces = subspaces
    }

    func serialized() -> JSON {
        return [
            "entities": entities.map { $0.serialized() }.json,
            "subspaces": subspaces.map { $0.serialized() }.json
        ]
    }
}

/// Represents a serialized object.
/// A Serialized container is itself serializable, as well.
public struct Serialized: Serializable {
    
    /// The type name for this serialized object
    public var typeName: String
    /// The type of content serialized
    public var contentType: ContentType
    /// Any presets that where specified in the original JSON object
    public var presets: [SerializedPreset]
    /// The serialized object
    public var data: JSON
    
    init(
        typeName: String,
        presets: [SerializedPreset] = [],
        contentType: ContentType,
        data: JSON
    ) {

        self.typeName = typeName
        self.presets = presets
        self.contentType = contentType
        self.data = data
    }
    
    /// Creates and initializes an instance of this type from a given serialized
    /// state.
    ///
    /// - parameter from: A state that was previously serialized by an instance
    /// of this type using `serialized()`
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    /// - returns: A deserialized instance of this component type
    /// - throws: Any type of error during deserialization.
    public init(json: JSON, path: JsonPath) throws {
        guard let name = json[CodingKeys.typeName]?.string else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'typeName'",
                    path: path.dictionary(CodingKeys.typeName)
                )
        }
        guard let type = json[CodingKeys.contentType]?.string else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'contentType'",
                    path: path.dictionary(CodingKeys.contentType)
                )
        }
        guard let contentType = ContentType(rawValue: type) else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Invalid content type \(type)",
                    path: path.dictionary(CodingKeys.contentType)
                )
        }
        if json[CodingKeys.data]?.type == .null {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'data' key",
                    path: path
                )
        }
        if let presets = json[CodingKeys.presets] {
            let presetsKey = path.dictionary(CodingKeys.presets)

            if let array = presets.array {
                self.presets = try array.enumerated().map {
                    try SerializedPreset(
                        json: $0.element,
                        path: presetsKey.index($0.offset)
                    )
                }
            } else {
                throw DeserializationError
                    .invalidSerialized(
                        message: "Expected 'presets' to be an array, found '\(presets.type)'",
                        path: presetsKey
                    )
            }
        } else {
            self.presets = []
        }
        
        self.typeName = name
        self.contentType = contentType
        self.data = json[CodingKeys.data.rawValue] ?? [:]
    }
    
    fileprivate init() {
        self.typeName = ""
        self.presets = []
        self.contentType = .custom
        self.data = []
    }
    
    /// Serializes the state of this component into a JSON object.
    ///
    /// - returns: The serialized state for this object.
    public func serialized() -> JSON {
        return [
            CodingKeys.typeName.rawValue: typeName.json,
            CodingKeys.contentType.rawValue: contentType.rawValue.json,
            CodingKeys.presets.rawValue: presets.map { $0.serialized() }.json,
            CodingKeys.data.rawValue: data
        ]
    }
    
    /// The type of content serialized within this serialized object.
    ///
    /// - component: An implementer of Component
    /// - subspace: A subclass of Subsystem
    /// - entity: An entity object
    /// - space: A subclass Space
    /// - system: A subclass of System
    /// - serialized: A Serialized object itself
    /// - preset: A SerializedPreset object
    /// - custom: A custom implementer of Serialized, that is not any of the
    /// above types.
    public enum ContentType: String {
        case component
        case entity
        case subspace
        case space
        case system
        case serialized
        case preset
        case custom
    }

    public enum CodingKeys: String, CodingKey {
        case typeName
        case contentType
        case presets
        case data
    }
}

/// Represents a reusable serializable object template that can be reference
/// multiple times within a serialized instance.
///
/// Supports variable fields using 'presetVariable'.
public struct SerializedPreset: Serializable {
    
    /// The reference name for this preset
    public var name: String
    
    /// The inner type the preset expands to.
    /// Cannot be `preset` itself.
    public var type: Serialized.ContentType
    
    /// A collection of variables that can be defined within the preset when its
    /// used to override values on the preset data.
    public var variables: [String: Variable]
    
    /// The contents of the serialized preset
    public var data: Serialized
    
    public init(
        name: String,
        type: Serialized.ContentType,
        variables: [String: Variable],
        data: Serialized
    ) {

        self.name = name
        self.type = type
        self.variables = variables
        self.data = data
    }
    
    /// Deserializes a serialized preset from a given JSON object
    ///
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    public init(json: JSON, path: JsonPath) throws {
        guard let name = json["presetName"]?.string else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'presetName'",
                    path: path.dictionary("presetName")
                )
        }
        guard let type = json["presetType"]?.string else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'presetType' in preset '\(name)'",
                    path: path.dictionary("presetType")
                )
        }
        guard let presetType = Serialized.ContentType(rawValue: type) else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Invalid preset type '\(type)' in preset '\(name)'",
                    path: path.dictionary("presetType")
                )
        }
        guard let vars = json["presetVariables"]?.dictionary else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Missing 'presetVariables' in preset '\(name)'",
                    path: path
                )
        }
        
        if presetType == .preset {
            throw DeserializationError
                .invalidSerialized(
                    message: "Presets cannot represent preset types themselves in preset '\(name)'",
                    path: path
                )
        }
        
        guard let presetData = json["presetData"] else {
            throw DeserializationError
                .invalidSerialized(
                    message: "Expected 'presetData' to contain a dictionary in preset '\(name)'",
                    path: path.dictionary("presetData")
                )
        }
        if presetData.type != .dictionary {
            throw DeserializationError
                .invalidSerialized(
                    message: "Expected 'presetData' to contain a dictionary in preset '\(name)'",
                    path: path.dictionary("presetData")
                )
        }
        
        self.name = name
        self.type = presetType
        self.data = try Serialized(
            json: presetData,
            path: path.dictionary("presetData")
        )
        
        // Match serialized content types
        if self.type != self.data.contentType {
            // swiftlint:disable:next line_length
            throw DeserializationError
                .invalidSerialized(
                    message: "Expected preset data of type '\(type)', but received preset with contentType '\(self.data.contentType)' in preset '\(name)'",
                    path: path.dictionary("presetData").dictionary("contentType")
                )
        }
        
        // Expand variables
        variables = [:]
        for (key, value) in vars {
            let typeString: String
            var defaultValue: JSON?

            let varPath = path
                .dictionary("presetVariables")
                .dictionary(key)

            if value.type == .dictionary {
                guard let tString = value["type"]?.string else {
                    throw DeserializationError
                        .invalidSerialized(
                            message: "Missing 'type' on variable '\(key)' in preset '\(name)'",
                            path: varPath
                        )
                }
                
                // Currently we only support default values of string and number
                if value["default"]?.type == .string {
                    defaultValue = value["default"]
                } else if value["default"]?.type == .number {
                    defaultValue = value["default"]
                } else {
                    throw DeserializationError
                        .invalidSerialized(
                            message: "Unsupported variable type '\(value["default"]?.type as Any)' in variable '\(name)' in preset '\(name)'",
                            path: varPath
                        )
                }
                
                typeString = tString
            } else if let string = value.string {
                typeString = string
            } else {
                // swiftlint:disable:next line_length
                throw DeserializationError
                    .invalidSerialized(
                        message: "Preset variable value must either be string or dictionary, received \(value.type) in variable '\(key)' in preset '\(name)'",
                        path: varPath
                    )
            }
            
            guard let type = VariableType(rawValue: typeString) else {
                throw DeserializationError
                    .invalidSerialized(
                        message: "Unrecognized variable type '\(typeString)' on preset variable '\(key)' in preset '\(name)'",
                        path: varPath
                    )
            }
            
            // Check type of default value
            if let def = defaultValue {
                if type.jsonType != def.type {
                    throw DeserializationError
                        .invalidSerialized(
                            message: "Default value for preset variable '\(key)' has a different type (\(def.type)) than declared (\(type.jsonType)) in preset '\(name)'",
                            path: varPath
                        )
                }
            }
            
            variables[key] = Variable(
                name: key,
                type: type,
                defaultValue: defaultValue
            )
        }
    }
    
    /// Serializes this preset object
    public func serialized() -> JSON {
        // Encode variables
        var vars: JSON = [:]
        
        for (key, variable) in variables {
            if let defaultValue = variable.defaultValue {
                vars[key] = [
                    "type": variable.type.rawValue.json,
                    "default": defaultValue
                ]
            } else {
                vars[key] = .string(variable.type.rawValue)
            }
        }
        
        let json: JSON = [
            "presetName": name.json,
            "presetType": type.rawValue.json,
            "presetVariables": vars,
            "presetData": data.serialized()
        ]
        
        return json
    }
    
    /// Returns a copy of the Serialized data within this preset, using a given
    /// map of variables to expand any variable within the preset object.
    /// Preset variables are identified by being values with a 
    /// `[ "presetVariable": {variableName} ]` for any key json within.
    /// The replacement is applied recursively.
    ///
    /// Throws an error, if encounters preset variables with incorrect values or
    /// that have no matching variables.
    public func expandPreset(withVariables values: [String: JSON]) throws -> Serialized {
        var json = data.data
        
        // Verify variables
        for (key, value) in values {
            // Find matching definition
            if let def = variables[key] {
                if def.type.jsonType != value.type {
                    throw VariableReplaceError.mismatchedType(
                        valueName: key,
                        expected: def.type.jsonType,
                        received: value.type
                    )
                }
            }
        }
        
        // Walk recursively, expanding within
        json = try expandPreset(recursiveOn: json, withVariables: values)
        
        return Serialized(typeName: data.typeName, contentType: data.contentType, data: json)
    }
    
    private func expandPreset(
        recursiveOn json: JSON,
        withVariables values: [String: JSON]
    ) throws -> JSON {

        // A preset replacement!
        if let varName = json["presetVariable"]?.string {
            guard let varDef = variables[varName] else {
                throw VariableReplaceError.unknownVariable(variableName: varName)
            }
            
            if let value = values[varName] {
                return value
            }
            
            // Search for default
            guard let value = varDef.defaultValue else {
                throw VariableReplaceError.missingValue(valueName: varName)
            }
            
            return value
        }
        
        // Traverse into the values...
        if let dictionary = json.dictionary {
            return try .dictionary(dictionary.mapValues {
                try expandPreset(recursiveOn: $0, withVariables: values)
            })
        } else if let array = json.array {
            return try .array(array.map {
                try expandPreset(recursiveOn: $0, withVariables: values)
            })
        }
        
        return json
    }
    
    /// Represents a preset variable
    public struct Variable {
        /// The name of this variable
        public var name: String
        
        /// The type for this variable
        public var type: VariableType
        
        /// The default value, if available.
        /// Must match type specified on `type` field above.
        public var defaultValue: JSON?
    }
    
    /// Allowed scalar values to expand a preset variable to.
    /// Must expand to a recognized JSON type.
    public enum VariableType: String {
        /// 64-bit floating point number
        case number
        
        /// Boolean value
        case bool
        
        /// Unicode string
        case string
        
        /// Fetches the equivalent `JSON.JSONType` enumeration value for this
        /// variable
        var jsonType: JSON.JSONType {
            switch self {
            case .number:
                return .number
            case .bool:
                return .bool
            case .string:
                return .string
            }
        }
    }
    
    /// Possible errors returned by `.expandPreset(withVariables:)`
    ///
    /// - unknownVariable: A variable reference within the preset data is not
    /// listed within the preset's variable list
    /// - missingValue: A variable within the preset data has no matching value
    /// within the variables dictionary
    /// - mismatchedType: A value that was fed to the variables dictionary
    /// mismatches the expected type
    public enum VariableReplaceError: Error, CustomStringConvertible {
        case unknownVariable(variableName: String)
        case missingValue(valueName: String)
        case mismatchedType(valueName: String, expected: JSON.JSONType, received: JSON.JSONType)
        
        public var description: String {
            switch self {
            case .unknownVariable(let name):
                return "Unrecognized variable name \(name)"
            case .missingValue(let name):
                return "Values dictionary provided misses required value for variable '\(name)'"
            case .mismatchedType(let name, let expected, let received):
                return "Value for variable '\(name)' provided is \(received), but expected \(expected)"
            }
        }
    }

    public enum CodingKeys: String, CodingKey {
        case name
        case type
        case variables
        case data
    }
}

/// Describes an object that can be serialized to and back from a JSON object.
/// Implementers of this protocol should take care of guaranteeing that the inner
/// state of the object remains the same when deserializing from a previously
/// serialized object.
public protocol Serializable {
    /// Serializes the state of this component into a JSON object.
    ///
    /// - returns: The serialized state for this object.
    func serialized() -> JSON
}

public extension Serializable where Self: Decodable {
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    init(json: JSON, path: JsonPath) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(json)
        self = try decoder.decode(Self.self, from: data)
    }
}

public extension Serializable where Self: Encodable {
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    func serialized() -> JSON {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try! encoder.encode(self)
        return try! decoder.decode(JSON.self, from: data)
    }
}

/// Protocol to be implemented by objects that can provide the correct types to
/// create when deserializing a previously serialized state.
public protocol SerializationTypeProvider {
    
    /// Asks the implementer for the serialized name to use for a Serializable
    /// instance.
    ///
    /// The default implementation of this method simply returns the name of the
    /// type passed in by the `serializable` parameter.
    ///
    /// - parameter serializable: The static type of a Serializable.
    /// - returns: A string that can uniquely identify the type of the serializable.
    func serializedName(for serializable: Serializable.Type) -> String

    /// Asks the implementer for a deserialized type with a given name, with the
    /// given JSON data.
    ///
    /// - parameter name: The name of the serialized object.
    /// - parameter json: A JSON object describing the serialized object.
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    /// - returns: A deserialized object of the given type, with the given JSON
    /// data.
    /// - throws: Some error found during the search for the serializable type.
    /// Errors must be thrown when the implementer does not recognize the serializable
    /// name passed in.
    func createDeserializable(from name: String, json: JSON, path: JsonPath) throws -> Serializable
}

public extension SerializationTypeProvider {
    func serializedName(for serializable: Serializable.Type) -> String {
        return String(describing: serializable)
    }
}

/// A basic serialization type provider that works by storing serializable types
/// in an array, and using that array on pre-implemented stubs to `serializedName(for:)` 
/// and `deserialized(from:)`.
public protocol BasicSerializationTypeProvider: SerializationTypeProvider {
    var serializableTypes: [(Serializable.Type, (JSON, JsonPath) throws -> Serializable)] { get }
}

public extension BasicSerializationTypeProvider {
    /// - parameter path: The full JSON path to the serialized object. Used for
    /// diagnostics purposes.
    func createDeserializable(
        from name: String,
        json: JSON,
        path: JsonPath
    ) throws -> Serializable {

        for (type, constructor) in serializableTypes {
            if String(describing: type) == name {
                return try constructor(json, path)
            }
        }

        throw DeserializationError
            .unrecognizedSerializedName(
                name: name,
                path: path
            )
    }
}

extension JSON {
    subscript<T: RawRepresentable & CodingKey>(key: T) -> JSON? where T.RawValue == String {
        return self[key.rawValue]
    }
}

extension JsonPath {
    func dictionary<T: RawRepresentable & CodingKey>(_ key: T) -> Self where T.RawValue == String {
        return dictionary(key.rawValue)
    }
}
