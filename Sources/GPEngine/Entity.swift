//
//  Entity.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

/// Describes a game entity
public class Entity {
    public typealias Id = Int
    
    /// The internal list of components for this entity
    public internal(set) var components: [Component] = []
    
    /// The unique identifier for this entity
    public var id: Id = 0
    /// A bitmask field used to quickly describe the type of this entity
    public var type = 0
    
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
    public func hasComponent(ofType type: Component.Type) -> Bool {
        for comp in self.components {
            if Swift.type(of: comp) == type {
                return true
            }
        }
        
        return false
    }
    
    /// Gets a single component that matches a given component class type
    /// If no components match the passed component type, nil is returned
    public func component<T: Component>(ofType type: T.Type) -> T? {
        for comp in self.components {
            if let component = comp as? T {
                return component
            }
        }
        
        return nil
    }
    
    /// Applies a given closure to each component of a given type on this entity
    public func withComponents<C: Component>(ofType type: C.Type, do closure: (C) throws -> Void) rethrows {
        for comp in components {
            if let component = comp as? C {
                try closure(component)
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
    public func withComponents<C1, C2>(ofTypes type1: C1.Type,
                                       _ type2: C2.Type,
                                       do closure: (C1, C2) throws -> Void) rethrows where C1: Component, C2: Component {
        if let comp1 = component(ofType: C1.self), let comp2 = component(ofType: C2.self) {
            try closure(comp1, comp2)
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
    public func withComponents<C1: Component, C2: Component>(do closure: (C1, C2) throws -> Void) rethrows {
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
    public func withComponents<C1, C2, C3>(ofTypes type1: C1.Type,
                                           _ type2: C2.Type,
                                           _ type3: C3.Type,
                                           do closure: (C1, C2, C3) throws -> Void) rethrows where C1: Component, C2: Component, C3: Component {
        if let comp1 = component(ofType: C1.self), let comp2 = component(ofType: C2.self), let comp3 = component(ofType: C3.self) {
            try closure(comp1, comp2, comp3)
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
    public func withComponents<C1: Component, C2: Component, C3: Component>(do closure: (C1, C2, C3) throws -> Void) rethrows {
        try withComponents(ofTypes: C1.self, C2.self, C3.self, do: closure)
    }
    
    /// Gets all components in this entity
    public func getAllComponents() -> [Component] {
        return components
    }
    
    /// Gets a list of components that match a given component class type
    public func components<T: Component>(ofType type: T.Type) -> [T] {
        return components.compactMap { $0 as? T }
    }
}
