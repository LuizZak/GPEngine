//
//  Entity.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// Describes a game entity
open class Entity: Equatable {
    
    /// The internal list of components for this entity
    internal(set) public var components : [Component] = []
    
    /// The unique identifier for this entity
    open var id = 0
    /// A bitmask field used to quickly describe the type of this entity
    open var type = 0
    
    /// Initializes this entity
    public init(components: [Component] = []) {
        self.components = components
    }
    
    /// Initializes this entity, placing it on a given space in the process.
    /// Mostly a convenience - calls space.addEntity automatically.
    public init(_ space: Space, components: [Component] = []) {
        self.components = components
        
        space.addEntity(self)
    }
    
    /// Returns whether the entity has the given component type inside of it
    open func hasComponent(ofType type: Component.Type) -> Bool {
        for comp in self.components {
            if(type(of: comp) == type) {
                return true
            }
        }
        
        return false
    }
    
    /// Gets a single component that matches a given component class type
    /// If no components match the passed component type, nil is returned
    open func component<T: Component>(ofType type: T.Type) -> T? {
        for comp in self.components {
            if let c = comp as? T {
                return c
            }
        }
        
        return nil
    }
    
    /// Applies a given closure to each component of this entity
    open func withComponents<T: Component>(ofType type: T.Type, do closure: (T) throws -> ()) rethrows {
        for comp in components {
            if let c = comp as? T {
                try closure(c)
            }
        }
    }
    
    /// Gets all components in this entity
    open func getAllComponents() -> [Component] {
        return components
    }
    
    /// Gets a list of components that match a given component class type
    open func components<T: Component>(ofType type: T.Type) -> [T] {
        return components.flatMap { $0 as? T }
    }
    
    public static func ==(lhs: Entity, rhs: Entity) -> Bool {
        return lhs === rhs
    }
}
