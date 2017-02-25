//
//  Subspace.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Defines a subspace, which is a part of a game space that contains
/// an entity selector and data that pertains to a specific portion of a game.
/// Subspaces are queried by game systems to have operations made upon
open class Subspace: Equatable {
    
    /// The entity selector for the subspace
    open var selector: EntitySelector
    
    /// The game space that contains this subspace
    open internal(set) weak var space: Space?
    
    /// The list of entities currently being manipulated by this game space
    open internal(set) var entities: [Entity] = []
    
    public init() {
        selector = .none
    }
    
    /// Reloads the list of entities from the space this subspace is currently hosted on
    open func reloadFromSpace() {
        clearEntities()
        
        if let space = self.space {
            for entity in space.entities {
                if(testEntity(entity)) {
                    addEntity(entity)
                }
            }
        }
    }
    
    /// Tests an entity to check whether it is fit for this subspace
    open func testEntity(_ entity: Entity) -> Bool {
        return selector.evaluate(with: entity)
    }
    
    /// Adds the specified entity to this subspace
    open func addEntity(_ entity: Entity) {
        entities.append(entity)
        
        entityAdded(entity)
    }
    
    /// Removes an entity from this subspace
    open func removeEntity(_ entity: Entity) {
        entities.remove(entity)
        
        entityRemoved(entity)
    }
    
    /// Called to notify an entity has been added into this subspace
    open func entityAdded(_ entity: Entity) {
        
    }
    
    /// Called to notify an entity has been removed from this subspace
    open func entityRemoved(_ entity: Entity) {
        
    }
    
    /// Manages a given entity in this subspace, removing it if it no longer fits the entity
    /// selector, and adding it in if it fits
    open func manageEntity(_ entity: Entity) {
        if(entities.contains(entity)) {
            if(!testEntity(entity)) {
                removeEntity(entity)
            }
        } else {
            if(testEntity(entity)) {
                addEntity(entity)
            }
        }
    }
    
    /// Function called whenever this subspace's space has been changed
    func didMoveTo(space newSpace: Space?) {
        
    }
    
    /// Clears all the entities from this subspace
    open func clearEntities() {
        while(entities.count > 0) {
            removeEntity(entities[0])
        }
    }
}

public func ==(lhs: Subspace, rhs: Subspace) -> Bool {
    return lhs === rhs
}
