//
//  Space.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

/// Represents a game space. A space is a set of game entities and game
/// subspaces that compose a standalone, independent region of the game.
///
/// Spaces do not interact with each other in any way, and entities across
/// spaces are also considered isolated from each other.
open class Space {
    
    /// Whether this space is currently active
    open var active: Bool = true
    
    /// The set of entities for the space
    open fileprivate(set) var entities: [Entity]
    /// The set of subspaces for the space
    open fileprivate(set) var subspaces: [Subspace]
    
    /// The event dispatcher that handles event handling specificly on this
    /// space
    open internal(set) var eventDispatcher = GameEventDispatcher()
    
    public init() {
        entities = [Entity]()
        subspaces = [Subspace]()
    }
    
    /// Adds a subspace to this space.
    /// If the subspace is already contained within a space, it is removed and
    /// then added to this space.
    open func addSubspace(_ subspace: Subspace) {
        if let previous = subspace.space {
            if previous === self {
                return
            }
            
            if let index = previous.subspaces.firstIndex(where: { $0 === subspace }) {
                previous.subspaces.remove(at: index)
            }
        }
        
        subspaces.append(subspace)
        
        subspace.space = self
        subspace.didMoveTo(space: self)
        
        subspace.reloadFromSpace()
    }
    
    /// Removes a subspace from this space
    open func removeSubspace(_ subspace: Subspace) {
        if let index = subspaces.firstIndex(where: { $0 === subspace }) {
            subspaces.remove(at: index)
        }
        
        subspace.space = nil
        subspace.didMoveTo(space: nil)
    }
    
    /// Gets a subspace with a specified type from this space
    open func subspace<S: Subspace>(_ type: S.Type) -> S? {
        for subspace in subspaces {
            if let subspace = subspace as? S {
                return subspace
            }
        }
        
        return nil
    }
    
    /// Adds an entity into this space
    open func addEntity(_ entity: Entity) {
        if entities.contains(where: { $0 === entity }) {
            return
        }
        
        entities.append(entity)
        
        // Notify the subspaces
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
    }
    
    /// For every entity within this space that matches a specified selector,
    /// apply a closure passing the entity as a parameter.
    open func withEntities(matching selector: EntitySelector, do closure: (Entity) throws -> Void) rethrows {
        try selector.select(from: entities).forEach(closure)
    }
    
    /// Removes an entity from this space
    open func removeEntity(_ entity: Entity) {
        entities.append(entity)
        
        // Remove the entity from any subspace it is in
        for subspace in subspaces {
            subspace.removeEntity(entity)
        }
    }
    
    /// Adds a component to an entity in this space
    open func addComponent(_ component: Component, to entity: Entity) {
        // Notify component addition
        for subspace in subspaces {
            subspace.willAddComponent(component, to: entity)
        }
        
        entity.components.append(component)
        
        /// Update subspaces that may contain this entity
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
    }
    
    /// Removes a given component type from an entity
    open func removeComponent<C: Component>(type: C.Type, from entity: Entity) {
        // Type-casting already performed by removeFirstComponent
        removeFirstComponent(from: entity) { (_: C) -> Bool in true }
    }
    
    /// Removes the first component that returns true for a given closure.
    open func removeFirstComponent<C: Component>(from entity: Entity, where closure: (C) throws -> Bool) rethrows {
        var components = entity.components
        let rem = try components.removeFirst { component -> Bool in
            if let component = component as? C {
                return try closure(component)
            }
            return false
        }
        
        // No change
        guard let removed = rem else {
            return
        }
        
        // Notify impending removal
        for subspace in subspaces {
            subspace.willRemoveComponent(removed, from: entity)
        }
        
        entity.components = components
        
        // Update subspaces that may contain this entity
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
    }
    
    /// Returns all instances of Subspace objects in this space that are of a
    /// specified type
    open func subspaces<S: Subspace>(ofType type: S.Type) -> [S] {
        return subspaces.compactMap { $0 as? S }
    }
    
    /// Applies a given closure to all subspaces that match a specified type
    /// within this space
    open func withSubspaces<S: Subspace>(ofType type: S.Type, do closure: (S) throws -> Void) rethrows {
        for subspace in subspaces {
            if let subspace = subspace as? S {
                try closure(subspace)
            }
        }
    }
}
