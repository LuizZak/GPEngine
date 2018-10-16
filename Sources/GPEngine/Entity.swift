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
            if(Swift.type(of: comp) == type) {
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
    open func withComponents<C: Component>(ofType type: C.Type, do closure: (C) throws -> ()) rethrows {
        for comp in components {
            if let c = comp as? C {
                try closure(c)
            }
        }
    }
    
    /// Applies a given closure by fetching the first two components that match
    /// a specified type and using them as arguments for the closure. A helper
    /// method that might aid in manipulation of two relevant components added
    /// to entities.
    ///
    /// ```swift
    /// entity.withComponents(ofTypes: MyComponent.self, MyOtherComponent.self) { c1, c2 in
    ///     // ...
    /// }
    /// ```
    open func withComponents<C1: Component,
                             C2: Component>(ofTypes type1: C1.Type,
                                            _ type2: C2.Type,
                                            do closure: (C1, C2) throws -> ()) rethrows {
        if let c1 = component(ofType: C1.self), let c2 = component(ofType: C2.self) {
            try closure(c1, c2)
        }
    }
    
    /// Applies a given closure by fetching the first two components that match
    /// a specified type and using them as arguments for the closure. A helper
    /// method that might aid in manipulation of two relevant components added
    /// to entities.
    ///
    /// This is a type-inferred version of withComponents above which can be used
    /// with typed-closures to drop the type requirements in parameters:
    ///
    /// ```swift
    /// entity.withComponents { (c1: MyComponent, c2: MyOtherComponent) in
    ///     // ...
    /// }
    /// ```
    open func withComponents<C1: Component, C2: Component>(do closure: (C1, C2) throws -> ()) rethrows {
        try withComponents(ofTypes: C1.self, C2.self, do: closure)
    }
    
    /// Applies a given closure by fetching the first three components that match
    /// a specified type and using them as arguments for the closure. A helper
    /// method that might aid in manipulation of three relevant components added
    /// to entities.
    ///
    /// ```swift
    /// entity.withComponents(ofTypes: MyComponent.self, MyOtherComponent.self, c3: MyYetAnotherComponent.self) { c1, c2, c3 in
    ///     // ...
    /// }
    /// ```
    open func withComponents<C1: Component,
                             C2: Component,
                             C3: Component>(ofTypes type1: C1.Type,
                                            _ type2: C2.Type,
                                            _ type3: C3.Type,
                                            do closure: (C1, C2, C3) throws -> ()) rethrows {
        if let c1 = component(ofType: C1.self), let c2 = component(ofType: C2.self), let c3 = component(ofType: C3.self) {
            try closure(c1, c2, c3)
        }
    }
    
    /// Applies a given closure by fetching the first three components that match
    /// a specified type and using them as arguments for the closure. A helper
    /// method that might aid in manipulation of three relevant components added
    /// to entities.
    ///
    /// This is a type-inferred version of withComponents above which can be used
    /// with typed-closures to drop the type requirements in parameters:
    ///
    /// ```swift
    /// entity.withComponents { (c1: MyComponent, c2: MyOtherComponent, c3: MyYetAnotherComponent) in
    ///     // ...
    /// }
    /// ```
    open func withComponents<C1: Component, C2: Component, C3: Component>(do closure: (C1, C2, C3) throws -> ()) rethrows {
        try withComponents(ofTypes: C1.self, C2.self, C3.self, do: closure)
    }
    
    /// Gets all components in this entity
    open func getAllComponents() -> [Component] {
        return components
    }
    
    /// Gets a list of components that match a given component class type
    open func components<T: Component>(ofType type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
    
    /// Performs a reference-equality check between two Entity instances.
    /// Parameter are equal if they reference the same object.
    public static func ==(lhs: Entity, rhs: Entity) -> Bool {
        return lhs === rhs
    }
}
