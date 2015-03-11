//
//  GPSubspace.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Defines a subspace, which is a part of a game space that contains
/// an entity selector and data that pertains to a specific portion of a game.
/// Subspaces are queried by game systems to have operations made upon
public class GPSubspace: Equatable
{
    /// The entity selector for the subspace
    public var selector:GPEntitySelector;
    
    /// The game space that contains this subspace
    public internal(set) var space: GPSpace?;
    /// The list of entities currently being manipulated by this game space
    public internal(set) var entities: [GPEntity] = [];
    
    public init()
    {
        selector = GPEntitySelector(GPSRNone());
    }
    
    /// Reloads the list of entities from the space this subspace is currently hosted on
    public func reloadFromSpace()
    {
        clearEntities();
        
        if let space = self.space
        {
            for entity in space.entities
            {
                testEntity(entity);
            }
        }
    }
    
    /// Tests an entity to check whether it is fit for this subspace
    public func testEntity(entity: GPEntity) -> Bool
    {
        return selector.applyRuleToEntity(entity);
    }
    
    /// Adds the specified entity to this subspace
    public func addEntity(entity: GPEntity)
    {
        entities += entity;
        
        entityAdded(entity);
    }
    
    /// Removes an entity from this subspace
    public func removeEntity(entity: GPEntity)
    {
        entities -= entity;
        
        entityRemoved(entity);
    }
    
    /// Called to notify an entity has been added into this subspace
    public func entityAdded(entity: GPEntity)
    {
        
    }
    
    /// Called to notify an entity has been removed from this subspace
    public func entityRemoved(entity: GPEntity)
    {
        
    }
    
    /// Manages a given entity in this subspace, removing it if it no longer fits the entity
    /// selector, and adding it in if it fits
    public func manageEntity(entity: GPEntity)
    {
        if(entities.contains(entity))
        {
            if(!testEntity(entity))
            {
                removeEntity(entity);
            }
        }
        else
        {
            if(testEntity(entity))
            {
                addEntity(entity);
            }
        }
    }
    
    /// Function called whenever this subspace's space has been changed
    func spaceSet(newSpace: GPSpace?)
    {
        
    }
    
    /// Clears all the entities from this subspace
    public func clearEntities()
    {
        while(entities.count > 0)
        {
            removeEntity(entities[0]);
        }
    }
}

public func ==(lhs: GPSubspace, rhs: GPSubspace) -> Bool
{
    return lhs === rhs;
}