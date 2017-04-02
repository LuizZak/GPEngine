//
//  Serialization.swift
//  Pods
//
//  Created by Luiz Fernando Silva on 01/04/17.
//
//

import SwiftyJSON

/// Errors that can be throwing during a serialization process.
///
/// - cannotSerialize: An error ocurring during the serialization process
public enum SerializationError: Error {
    case cannotSerialize(reason: String)
}

/// Errors that can be throwing during a deserialization process.
///
/// - notImplemented: The current implementer has not overriden a default
/// implementation with a suitable body.
/// Default error thrown when trying to call a serialization-related method on
/// objects that have not implemented these methods.
///
/// - unrecognizedSerializedName: Thrown when a serializable type provider cannot
/// detect a given serializable type name.
///
/// - invalidSerialized: A serialized object cannot be deserialized with a
/// provided JSON
public enum DeserializationError: Error {
    case notImplemented
    case unrecognizedSerializedName
    case invalidSerialized(message: String)
}

/// Class capable of serializing/deserializing components
public class GameSerializer {
    /// A type provider for this serializer
    public var typeProvider: SerializationTypeProvider
    
    public init(typeProvider: SerializationTypeProvider) {
        self.typeProvider = typeProvider
    }
    
    /// Returns if a game space is serializable.
    /// A game space is serializable if all its entities and subspaces are, as
    /// well.
    /// See `canSerialize(_:Entity)` for entity serialization rules.
    public func canSerialize(_ space: Space) -> Bool {
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
    public func canSerialize(_ entity: Entity) -> Bool {
        for component in entity.components {
            if !(component is Serializable) {
                return false
            }
        }
        
        return true
    }
    
    /// Serializes an entity passed in.
    /// Throws, if any of the components are non-serializable.
    public func serialize(_ entity: Entity) throws -> Serialized {
        let type = Serialized.ContentType.entity
        let name = String(describing: Entity.self)
        
        // Start serializing entity
        var data: JSON = [
            "id": entity.id,
            "type": entity.type
        ]
        
        var serializedComps: [Serialized] = []
        
        for comp in entity.components {
            guard let ser = comp as? Serializable else {
                throw SerializationError.cannotSerialize(reason: "Found component type \(type(of: comp)) is not serializable.")
            }
            
            serializedComps.append(serialize(ser))
        }
        
        data["components"].arrayObject = serializedComps.map { $0.serialized().object }
        
        return Serialized(typeName: name, contentType: type, data: data)
    }
    
    /// Serializes a game space passed in.
    /// Throws, if any of the entities are non-serializable.
    /// See `serialize(_:Entity)` for Entity serialization rules.
    public func serialize(_ space: Space) throws -> Serialized {
        let type = Serialized.ContentType.space
        let name = String(describing: Space.self)
        
        var data: JSON = [:]
        
        var serializedEntities: [Serialized] = []
        
        for entity in space.entities {
            try serializedEntities.append(serialize(entity))
        }
        
        var serializedSubspaces: [Serialized] = []
        
        for subspace in space.subspaces {
            guard let ser = subspace as? Serializable else {
                throw SerializationError.cannotSerialize(reason: "Found subspace type \(type(of: subspace)) is not serializable.")
            }
            
            serializedSubspaces.append(serialize(ser))
        }
        
        data["entities"].arrayObject = serializedEntities.map { $0.serialized().object }
        data["subspaces"].arrayObject = serializedSubspaces.map { $0.serialized().object }
        
        return Serialized(typeName: name, contentType: type, data: data)
    }
    
    /// Serializes a given serializable object, returning an encapsulated
    /// serialized object representation.
    public func serialize(_ serializable: Serializable) -> Serialized {
        let serialized = serializable.serialized()
        let type: Serialized.ContentType
        let name = typeProvider.serializedName(for: type(of: serializable))
        
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
        } else if serializable is Game {
            type = .game
        } else if serializable is Serialized {
            type = .serialized
        } else {
            type = .custom
        }
        
        return Serialized(typeName: name, contentType: type, data: serialized)
    }
    
    /// Deserializes a given serialized instance
    public func deserialize(from json: JSON) throws -> Serialized {
        return try Serialized.deserialized(from: json)
    }
    
    /// Extracts an entity with all its components from a serialized object
    public func extract(from serialized: Serialized) throws -> Entity {
        if(serialized.typeName != "Entity" || serialized.contentType != .entity) {
            throw DeserializationError.invalidSerialized(message: "Does not represent a plain serialized Entity instance")
        }
        
        guard let id = serialized.data["id"].int else {
            throw DeserializationError.invalidSerialized(message: "Missing 'id'")
        }
        guard let type = serialized.data["type"].int else {
            throw DeserializationError.invalidSerialized(message: "Missing 'type'")
        }
        guard let components = serialized.data["components"].array else {
            throw DeserializationError.invalidSerialized(message: "Missing 'components'")
        }
        
        let serialComps: [Serialized] = try components.map {
            try Serialized.deserialized(from: $0)
        }
        let comps: [Component] = try serialComps.map {
            try extract(from: $0)
        }
        
        let entity = Entity(components: comps)
        entity.id = id
        entity.type = type
        
        return entity
    }
    
    /// Extracts a game space with all its entities from a serialized object
    public func extract(from serialized: Serialized) throws -> Space {
        if(serialized.typeName != "Space" || serialized.contentType != .space) {
            throw DeserializationError.invalidSerialized(message: "Does not represent a plain serialized Space instance")
        }
        
        guard let entitiesJson = serialized.data["entities"].array else {
            throw DeserializationError.invalidSerialized(message: "Missing 'entities'")
        }
        guard let subspacesJson = serialized.data["subspaces"].array else {
            throw DeserializationError.invalidSerialized(message: "Missing 'subspaces'")
        }
        
        let entities: [Entity] = try entitiesJson.map {
            try Serialized.deserialized(from: $0)
        }.map {
            try extract(from: $0)
        }
        
        let subspaces: [Subspace] = try subspacesJson.map {
            try Serialized.deserialized(from: $0)
        }.map {
            try extract(from: $0)
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
    
    /// Extracts a component type from a serialized object
    public func extract<T: Component>(from serialized: Serialized) throws -> T {
        let type = try typeProvider.deserialized(from: serialized.typeName)
        if type is T.Type {
            return try type.deserialized(from: serialized.data) as! T
        }
        
        throw DeserializationError.unrecognizedSerializedName
    }
    
    /// Extracts a Component type from a serialized object
    public func extract(from serialized: Serialized) throws -> Component {
        let type = try typeProvider.deserialized(from: serialized.typeName)
        if type is Component.Type {
            return try type.deserialized(from: serialized.data) as! Component
        }
        
        throw DeserializationError.unrecognizedSerializedName
    }
    
    /// Extracts a Subspace type from a serialized object
    public func extract(from serialized: Serialized) throws -> Subspace {
        let type = try typeProvider.deserialized(from: serialized.typeName)
        if type is Subspace.Type {
            return try type.deserialized(from: serialized.data) as! Subspace
        }
        
        throw DeserializationError.unrecognizedSerializedName
    }
}

/// Represents a serialized object.
/// A Serialized container is itself serializable, as well.
public struct Serialized: Serializable {
    
    /// The type name for this serialized object
    var typeName: String
    /// The type of content serialized
    var contentType: ContentType
    /// The serialized object
    var data: JSON
    
    init(typeName: String, contentType: ContentType, data: JSON) {
        self.typeName = typeName
        self.contentType = contentType
        self.data = data
    }
    
    fileprivate init() {
        self.typeName = ""
        self.contentType = .custom
        self.data = []
    }
    
    /// Serializes the state of this component into a JSON object.
    ///
    /// - Returns: The serialized state for this object.
    public func serialized() -> JSON {
        return [
            "typeName": typeName,
            "contentType": contentType.rawValue,
            "data": data.object
        ]
    }
    
    /// Deserializes state from a given JSON object
    ///
    /// - Parameter from: A JSON object containing the results of a previous
    /// call to an instance of this object type's `serialize()` method.
    /// - Throws: Any type of error during deserialization.
    public mutating func deserialize(from json: JSON) throws {
        guard let name = json["typeName"].string else {
            throw DeserializationError.invalidSerialized(message: "Missing 'typeName'")
        }
        guard let type = json["contentType"].string else {
            throw DeserializationError.invalidSerialized(message: "Missing 'contentType'")
        }
        guard let contentType = ContentType(rawValue: type) else {
            throw DeserializationError.invalidSerialized(message: "Invalid content type \(type)")
        }
        if(json["data"].type == .null || json["data"].type == .unknown) {
            throw DeserializationError.invalidSerialized(message: "Missing 'data'")
        }
        
        self.typeName = name
        self.contentType = contentType
        self.data = json["data"]
    }
    
    /// Creates and initializes an instance of this type from a given serialized
    /// state.
    ///
    /// - Parameter from: A state that was previously serialized by an instance
    /// of this type using `serialized()`
    /// - Returns: A deserialized instance of this component type
    /// - Throws: Any type of error during deserialization.
    public static func deserialized(from json: JSON) throws -> Serialized {
        var obj = Serialized()
        try obj.deserialize(from: json)
        return obj
    }
    
    /// The type of content serialized within this serialized object.
    ///
    /// - component: An implementer of Component
    /// - subspace: A subclass of Subsystem
    /// - entity: An entity object
    /// - space: A subclass Space
    /// - system: A subclass of System
    /// - game: An entire game state
    /// - serialized: A Serialized object itself
    /// - custom: A custom implementer of Serialized, that is not any of the
    /// above types.
    enum ContentType: String {
        case component
        case entity
        case subspace
        case space
        case system
        case game
        case serialized
        case custom
    }
}

/// Describes an object that can be serialized to and back from a JSON object.
/// Implementers of this protocol should take care of guaranteeing that the inner
/// state of the object remains the same when deserializing from a previously
/// serialized object.
public protocol Serializable {
    /// Serializes the state of this component into a JSON object.
    ///
    /// - Returns: The serialized state for this object.
    func serialized() -> JSON
    
    /// Deserializes state from a given JSON object
    ///
    /// - Parameter json: A JSON object containing the results of a previous
    /// call to an instance of this object type's `serialize()` method.
    /// - Throws: Any type of error during deserialization.
    mutating func deserialize(from json: JSON) throws
    
    /// Creates and initializes an instance of this type from a given serialized
    /// state.
    ///
    /// - Parameter json: A state that was previously serialized by an instance
    /// of this type using `serialized()`
    /// - Returns: A deserialized instance of this component type
    /// - Throws: Any type of error during deserialization.
    static func deserialized(from json: JSON) throws -> Self
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
    /// - Parameter serializable: The static type of a Serializable.
    /// - Returns: A string that can uniquely identify the type of the serializable.
    func serializedName(for serializable: Serializable.Type) -> String
    
    /// Asks the implementer for the deserialized version of a Serializable with
    /// a matching name.
    ///
    /// - Parameter name: A name of a Serializable to use during deserialization.
    /// - Returns: A type of Serializable that can then be deserialized.
    /// - Throws: Some error found during search for the serializable type.
    /// Can be thrown when the implementer does not recognize the name passed in.
    func deserialized(from name: String) throws -> Serializable.Type
}

public extension SerializationTypeProvider {
    func serializedName(for serializable: Serializable.Type) -> String {
        return String(describing: serializable)
    }
}
