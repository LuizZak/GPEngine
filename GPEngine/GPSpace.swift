//
//  GPSpace.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 12/01/15.
//  Copyright (c) 2015 Luiz Fernando Silva. All rights reserved.
//

import UIKit

/// Represents a game space. A space is a set of game entities and game subspaces
/// that compose a standalone, independent region of the game. Spaces do not interact
/// with each other in any way
public class GPSpace: Equatable
{
    /// Whether this space is currently active
    public var active: Bool = true;
    
    /// The set of entities for the space
    public private(set) var entities: [GPEntity];
    /// The set of subspaces for the space
    public private(set) var subspaces: [GPSubspace];
    
    /// The event dispatcher that handles event handling on the game screen
    private var _eventDispatcher: GPEventDispatcher = GPEventDispatcher();
    
    /// Gets the event dispatcher for this game scene
    public var eventDispatcher: GPEventDispatcher { return _eventDispatcher }
    
    public init()
    {
        entities = [GPEntity]();
        subspaces = [GPSubspace]();
    }
    
    /// Adds a subspace to this space
    public func addSubspace(subspace: GPSubspace)
    {
        if(subspace.space != nil)
        {
            return;
        }
        
        subspaces += subspace;
        subspace.addedToSpace(self);
        subspace.reloadFromSpace();
    }
    
    /// Removes a subspace from this space
    public func removeSubspace(subspace: GPSubspace)
    {
        subspaces -= subspace;
        subspace.removedFromSpace();
    }
    
    /// Gets a subspace with a specified type from this space
    public func getSubspace<T: GPSubspace>(type: T.Type) -> T?
    {
        for subspace in subspaces
        {
            if(subspace is T)
            {
                return subspace as? T;
            }
        }
        
        return nil;
    }
    
    /// Adds an entity into this space
    public func addEntity(entity: GPEntity)
    {
        if(entities.contains(entity))
        {
            return;
        }
        
        entities += entity;
        
        // Notify the subspaces
        for subspace in subspaces
        {
            subspace.manageEntity(entity);
        }
    }
    
    /// Removes an entity from this space
    public func removeEntity(entity: GPEntity)
    {
        entities -= entity;
        
        // Remove the entity from any subspace it is in
        for subspace in subspaces
        {
            subspace.removeEntity(entity);
        }
    }
    
    /// Adds a component to an entity in this space
    public func addComponent(component: GPComponent, entity: GPEntity)
    {
        entity.addComponent(component);
        
        /// Update subspaces that may contain this entity
        for subspace in subspaces
        {
            subspace.manageEntity(entity);
        }
    }
}

public func ==(lhs: GPSpace, rhs: GPSpace) -> Bool
{
    return lhs === rhs;
}

/// Extension methods for management of subspaces that are used by the space class
private extension GPSubspace
{
    /// Called to notify this subspace has been added to a space
    func addedToSpace(space: GPSpace)
    {
        self.space = space;
        spaceSet(space);
    }
    /// Called to notify this subspace that it has been removed from its current space
    func removedFromSpace()
    {
        self.space = nil;
        spaceSet(nil);
    }
}