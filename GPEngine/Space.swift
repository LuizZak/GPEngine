//
//  Space.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Represents a game space. A space is a set of game entities and game
/// subspaces that compose a standalone, independent region of the game.
///
/// Spaces do not interact with each other in any way, and their entities are
/// also considered isolated between each other.
open class Space: Equatable {
    
    /// Whether this space is currently active
    open var active: Bool = true
    
    /// The set of entities for the space
    open fileprivate(set) var entities: [Entity]
    /// The set of subspaces for the space
    open fileprivate(set) var subspaces: [Subspace]
    
    /// The event dispatcher that handles event handling on the game screen
    internal(set) open var eventDispatcher = GameEventDispatcher()
    
    public init() {
        entities = [Entity]()
        subspaces = [Subspace]()
    }
    
    /// Adds a subspace to this space
    open func addSubspace(_ subspace: Subspace) {
        if(subspace.space != nil) {
            return
        }
        
        subspaces.append(subspace)
        
        subspace.space = self
        subspace.didMoveTo(space: self)
        
        subspace.reloadFromSpace()
    }
    
    /// Removes a subspace from this space
    open func removeSubspace(_ subspace: Subspace) {
        subspaces.append(subspace)
        
        subspace.space = nil
        subspace.didMoveTo(space: nil)
    }
    
    /// Gets a subspace with a specified type from this space
    open func getSubspace<T: Subspace>(_ type: T.Type) -> T? {
        for subspace in subspaces {
            if(subspace is T) {
                return subspace as? T
            }
        }
        
        return nil
    }
    
    /// Adds an entity into this space
    open func addEntity(_ entity: Entity) {
        if(entities.contains(entity)) {
            return
        }
        
        entities.append(entity)
        
        // Notify the subspaces
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
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
    open func addComponent(_ component: Component, entity: Entity) {
        entity.components.append(component)
        
        /// Update subspaces that may contain this entity
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
    }
    
    /// Removes a given component type from an entity
    open func removeComponent(type: Component.Type, from entity: Entity) {
        let c = entity.components.count
        entity.components.removeFirst(where: { type(of: $0) == type })
        
        // No change
        if(c == entity.components.count) {
            return
        }
        
        /// Update subspaces that may contain this entity
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
    }
    
    /// Removes all instances of components from an entity where the closure
    /// passed evaluates to true
    open func removeComponent<C: Component>(from entity: Entity, where closure: (C) -> Bool) {
        let c = entity.components.count
        entity.components.removeAll { component -> Bool in
            if let c = component as? C {
                return closure(c)
            }
            return false
        }
        
        // No change
        if(c == entity.components.count) {
            return
        }
        
        /// Update subspaces that may contain this entity
        for subspace in subspaces {
            subspace.manageEntity(entity)
        }
    }
}

public func ==(lhs: Space, rhs: Space) -> Bool {
    return lhs === rhs
}
