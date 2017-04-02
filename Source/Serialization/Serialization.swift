//
//  Serialization.swift
//  Pods
//
//  Created by Luiz Fernando Silva on 01/04/17.
//
//

import SwiftyJSON
import enum SwiftyJSON.Type

/// Errors that can be throwing during a serialization process.
///
/// - cannotSerialize: An error ocurring during the serialization process
public enum SerializationError: Error, CustomStringConvertible {
    case cannotSerialize(reason: String)
    
    public var description: String {
        switch(self) {
        case .cannotSerialize(let reason):
            return "Serialization error: \(reason)"
        }
    }
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
public enum DeserializationError: Error, CustomStringConvertible {
    case notImplemented
    case unrecognizedSerializedName(name: String)
    case invalidSerialized(message: String)
    
    public var description: String {
        switch(self) {
        case .notImplemented:
            return "Deserialization error: method not implemented"
        case .unrecognizedSerializedName(let name):
            return "Deserialization error: unrecognized serialized type name '\(name)'"
        case .invalidSerialized(let message):
            return "Deserialization error: \(message)"
        }
    }
}

/// Class capable of serializing/deserializing components
public class GameSerializer {
    /// A type provider for this serializer
    public var typeProvider: SerializationTypeProvider
    
    /// Preset context for presets found during deserialization
    var presetContext = PresetContext()
    
    public init(typeProvider: SerializationTypeProvider) {
        self.typeProvider = typeProvider
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
    public func deserializePreset(in serialized: Serialized) throws -> Serialized {
        if(serialized.contentType != .preset) {
            throw DeserializationError.invalidSerialized(message: "Does not represent a preset")
        }
        
        // Fetch variables from data and expand preset on them
        guard let vars = serialized.data.dictionaryObject else {
            throw DeserializationError.invalidSerialized(message: "Data for a serialized preset must be a dictionary")
        }
        
        guard let preset = presetContext.preset(named: serialized.typeName) else {
            throw DeserializationError.invalidSerialized(message: "Could not find preset named \(serialized.typeName)")
        }
        
        return try preset.expandPreset(withVariables: vars)
    }
    
    /// Deserializes a given serialized instance
    public func deserialize(from json: JSON) throws -> Serialized {
        return try Serialized(json: json)
    }
    
    /// Extracts an entity with all its components from a serialized object
    public func extract(from serialized: Serialized) throws -> Entity {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if(serialized.contentType == .preset) {
            return try extract(from: deserializePreset(in: serialized))
        }
        
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
            try Serialized(json: $0)
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
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if(serialized.contentType == .preset) {
            return try extract(from: deserializePreset(in: serialized))
        }
        
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
            try Serialized(json: $0)
        }.map {
            try extract(from: $0)
        }
        
        let subspaces: [Subspace] = try subspacesJson.map {
            try Serialized(json: $0)
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
    
    /// Extracts a serializable object from a serialized object container
    public func extract<T: Serializable>(from serialized: Serialized) throws -> T {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if(serialized.contentType == .preset) {
            return try extract(from: deserializePreset(in: serialized))
        }
        
        let type = try typeProvider.deserialized(from: serialized.typeName)
        if type is T.Type {
            return try type.init(json: serialized.data) as! T
        }
        
        throw DeserializationError.unrecognizedSerializedName(name: serialized.typeName)
    }
    
    /// Extracts a Component type from a serialized object
    public func extract(from serialized: Serialized) throws -> Component {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if(serialized.contentType == .preset) {
            return try extract(from: deserializePreset(in: serialized))
        }
        
        let type = try typeProvider.deserialized(from: serialized.typeName)
        if type is Component.Type {
            return try type.init(json: serialized.data) as! Component
        }
        
        throw DeserializationError.unrecognizedSerializedName(name: serialized.typeName)
    }
    
    /// Extracts a Subspace type from a serialized object
    public func extract(from serialized: Serialized) throws -> Subspace {
        // Push context for presets
        presetContext.push()
        presetContext.addPresets(presets: serialized.presets)
        defer {
            presetContext.pop()
        }
        
        // Detect preset on this object
        if(serialized.contentType == .preset) {
            return try extract(from: deserializePreset(in: serialized))
        }
        
        let type = try typeProvider.deserialized(from: serialized.typeName)
        if type is Subspace.Type {
            return try type.init(json: serialized.data) as! Subspace
        }
        
        throw DeserializationError.unrecognizedSerializedName(name: serialized.typeName)
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
        if(canSerialize(space)) {
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
    class PresetContext {
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
            if(last != presets.count) {
                presets = Array(presets[last..<presets.count])
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
    
    init(typeName: String, presets: [SerializedPreset] = [], contentType: ContentType, data: JSON) {
        self.typeName = typeName
        self.presets = presets
        self.contentType = contentType
        self.data = data
    }
    
    /// Creates and initializes an instance of this type from a given serialized
    /// state.
    ///
    /// - Parameter from: A state that was previously serialized by an instance
    /// of this type using `serialized()`
    /// - Returns: A deserialized instance of this component type
    /// - Throws: Any type of error during deserialization.
    public init(json: JSON) throws {
        typeName = ""
        presets = []
        contentType = .custom
        data = []
        
        try deserialize(from: json)
    }
    
    fileprivate init() {
        self.typeName = ""
        self.presets = []
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
            "presets": presets.map { $0.serialized().object },
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
        if let presets = json["presets"].array {
            self.presets = try presets.map { try SerializedPreset(json: $0) }
        }
        
        self.typeName = name
        self.contentType = contentType
        self.data = json["data"]
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
    
    public init(name: String, type: Serialized.ContentType, variables: [String: Variable], data: Serialized) {
        self.name = name
        self.type = type
        self.variables = variables
        self.data = data
    }
    
    /// Deserializes a serialzied preset from a given JSON object
    public init(json: JSON) throws {
        name = ""
        type = .custom
        variables = [:]
        data = Serialized(typeName: "", contentType: .custom, data: [:])
        
        try deserialize(from: json)
    }
    
    /// Serializes this preset object
    public func serialized() -> JSON {
        // Encode variables
        var vars: JSON = [:]
        
        for (key, variable) in variables {
            if let defaultValue = variable.defaultValue {
                vars[key].object = [
                    "type": variable.type.rawValue,
                    "default": defaultValue
                ]
            } else {
                vars[key].string = variable.type.rawValue
            }
        }
        
        let json: JSON = [
            "presetName": name,
            "presetType": type.rawValue,
            "presetVariables": vars.object,
            "presetData": data.serialized().object
        ]
        
        return json
    }
    
    /// Deserializeds a preset from a given JSON object.
    /// The preset information provided cannot represent a preset type itself
    /// (i.e. `"presetType" != .preset`.
    mutating public func deserialize(from json: JSON) throws {
        guard let name = json["presetName"].string else {
            throw DeserializationError.invalidSerialized(message: "Missing 'presetName'")
        }
        guard let type = json["presetType"].string else {
            throw DeserializationError.invalidSerialized(message: "Missing 'presetType' in preset '\(name)'")
        }
        guard let presetType = Serialized.ContentType(rawValue: type) else {
            throw DeserializationError.invalidSerialized(message: "Invalid preset type '\(type)' in preset '\(name)'")
        }
        guard let vars = json["presetVariables"].dictionary else {
            throw DeserializationError.invalidSerialized(message: "Missing 'presetVariables' in preset '\(name)'")
        }
        
        if presetType == .preset {
            throw DeserializationError.invalidSerialized(message: "Presets cannot represent preset types themselves in preset '\(name)'")
        }
        
        let presetData = json["presetData"]
        if(presetData.type != .dictionary) {
            throw DeserializationError.invalidSerialized(message: "Expected 'presetData' to contain a dictionary in preset '\(name)'")
        }
        
        self.name = name
        self.type = presetType
        self.data = try Serialized(json: presetData)
        
        // Match serialized content types
        if(self.type != self.data.contentType) {
            throw DeserializationError.invalidSerialized(message: "Expected preset data of type '\(type)', but received preset with contentType '\(self.data.contentType)' in preset '\(name)'")
        }
        
        // Expand variables
        variables.removeAll()
        for (key, value) in vars {
            let typeString: String
            var defaultValue: Any? = nil
            if value.type == .dictionary {
                guard let tString = value["type"].string else {
                    throw DeserializationError.invalidSerialized(message: "Missing 'type' on variable '\(key)' in preset '\(name)'")
                }
                
                // Currently we only support default values of string and number
                if value["default"].type == .string {
                    defaultValue = value["default"].string
                } else if value["default"].type == .number {
                    defaultValue = value["default"].double
                } else {
                    throw DeserializationError.invalidSerialized(message: "Unsuported variable type '\(value["default"].type)' in variable '\(name)' in preset '\(name)'")
                }
                
                typeString = tString
            } else if let string = value.string {
                typeString = string
            } else {
                throw DeserializationError.invalidSerialized(message: "Preset variable value must either be string or dictionary, received \(value.type) in variable '\(key)' in preset '\(name)'")
            }
            
            guard let type = VariableType(rawValue: typeString) else {
                throw DeserializationError.invalidSerialized(message: "Unrecognized variable type '\(typeString)' on preset variable '\(key)' in preset '\(name)'")
            }
            
            // Check type of default value
            if let def = defaultValue {
                if(JSON(def).type != type.jsonType) {
                    throw DeserializationError.invalidSerialized(message: "Default value for variable '\(name)' has a different type than the variable in preset '\(name)'")
                }
            }
            
            variables[key] = Variable(name: key, type: type, defaultValue: defaultValue)
        }
    }
    
    /// Returns a copy of the Serialized data within this preset, using a given
    /// map of variables to expand any variable within the preset object.
    /// Preset variables are identified by being values with a 
    /// `[ "presetVariable": {variableName} ]` for any key json within.
    /// The replacement is applied recursively.
    ///
    /// Throws an error, if encounters preset variables with incorrect values or
    /// that have no matching variables.
    public func expandPreset(withVariables values: [String: Any]) throws -> Serialized {
        var json = data.data
        
        // Verify variables
        for (key, value) in values {
            // Find matching definition
            if let def = variables[key] {
                if(def.type.jsonType != JSON(value).type) {
                    throw VariableReplaceError.missmatchedType(valueName: key, expected: def.type.jsonType, received: JSON(value).type)
                }
            }
        }
        
        // Walk recursively, expanding within
        try expandPreset(recursiveOn: &json, withVariables: values)
        
        return Serialized(typeName: data.typeName, contentType: data.contentType, data: json)
    }
    
    private func expandPreset(recursiveOn json: inout JSON, withVariables values: [String: Any]) throws {
        // A preset replacement!
        if let varName = json["presetVariable"].string {
            if let value = values[varName] {
                json = JSON(value)
                return
            } else {
                // Search for default
                if let def = variables[varName] {
                    if let value = def.defaultValue {
                        json = JSON(value)
                        return
                    }
                }
                
                throw VariableReplaceError.missingValue(valueName: varName)
            }
        }
        
        // Traverse into the values...
        if json.type == .dictionary {
            for (key, var value) in json {
                try expandPreset(recursiveOn: &value, withVariables: values)
                json[key] = value
            }
        } else if json.type == .array {
            for i in 0..<json.arrayValue.count {
                var value = json[i]
                try expandPreset(recursiveOn: &value, withVariables: values)
                json[i] = value
            }
        }
    }
    
    /// Represents a preset variable
    public struct Variable {
        /// The name of this variable
        public var name: String
        
        /// The type for this variable
        public var type: VariableType
        
        /// The default value, if available.
        /// Must match type specified on `type` field above.
        public var defaultValue: Any?
    }
    
    /// Allowed scalar values to expand a preset variable to.
    /// Must expand to a recognized JSON type.
    ///
    /// - number: 64-bit floating point number
    /// - string: Unicode string
    public enum VariableType: String {
        case number
        case string
        
        /// Fetches the equivalent SwiftyJSON.Type enumeration value for this
        /// variable
        var jsonType: Type {
            switch(self) {
            case .number:
                return .number
            case .string:
                return .string
            }
        }
    }
    
    /// Possible errors returned by `.expandPreset(withVariables:)`
    ///
    /// - unkownVariable: A variable reference within the preset data is not
    /// listed within the preset's variable list
    /// - missingValue: A variable within the preset data has no matching value
    /// within the variables dictionary
    /// - missmatchedType: A value that was fed to the variables dictionary
    /// mismatches the expected type
    public enum VariableReplaceError: Error, CustomStringConvertible {
        case unkownVariable(variableName: String)
        case missingValue(valueName: String)
        case missmatchedType(valueName: String, expected: Type, received: Type)
        
        public var description: String {
            switch(self) {
            case .unkownVariable(let name):
                return "Unrecognized variable name \(name)"
            case .missingValue(let name):
                return "Values dictionary provided misses required value for variable '\(name)'"
            case .missmatchedType(let name, let expected, let received):
                return "Value for variable '\(name)' provided is \(received), but expected \(expected)"
            }
        }
    }
}

/// Describes an object that can be serialized to and back from a JSON object.
/// Implementers of this protocol should take care of guaranteeing that the inner
/// state of the object remains the same when deserializing from a previously
/// serialized object.
public protocol Serializable {
    /// Initializes an instance of this type from a given serialized state.
    ///
    /// - Parameter json: A state that was previously serialized by an instance
    /// of this type using `serialized()`
    /// - Throws: Any type of error during deserialization.
    init(json: JSON) throws
    
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
