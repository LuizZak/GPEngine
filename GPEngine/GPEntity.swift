//
//  GPEntity.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import SpriteKit

/// Describes a game entity
public class GPEntity: Equatable
{
    /// The internal list of components for this entity
    private var _components : [GPComponent] = [];
    
    /// The unique identifier for this entity
    private var _id = 0;
    /// A bitmask field used to quickly describe the type of this entity
    private var _type = 0;
    
    /// The gamespace that owns this entity
    private var _space: GPSpace;
    
    /// Gets or sets the ID of this entity
    public var id: Int { get { return _id; } set { _id = newValue; } }
    /// Gets or sets the type of this entity
    public var type: Int { get { return _type; } set { _type = newValue; } }
    
    /// Gets the game space that owns this entity
    public var space: GPSpace { return _space; }
    
    public init(_ space: GPSpace)
    {
        self._space = space;
        
        space.addEntity(self);
    }
    
    /// Moves this entity to another space
    public func moveToSpace(space: GPSpace)
    {
        _space.removeEntity(self);
        
        space.addEntity(self);
    }
    
    /// Adds the given component to this entity
    public func addComponent(component: GPComponent)
    {
        self.internalAddComponent(component);
    }
    
    /// Adds an array of components to this entity
    public func addComponents(components: [GPComponent])
    {
        self._components += components;
    }
    
    /// Removes a component from this entity
    public func removeComponent(component: GPComponent)
    {
        self.internalRemoveComponent(component);
    }
    
    /// Intenral method that adds a components to this entity
    private func internalAddComponent(component: GPComponent)
    {
        self._components += component;
    }
    
    /// Internal method that removes components from this entity
    private func internalRemoveComponent(component: GPComponent)
    {
        self._components -= component;
    }
    
    /// Returns whether the entity has the given component type inside of it
    public func hasComponentType<T: GPComponent>(type: T.Type) -> Bool
    {
        for comp in self._components
        {
            if(comp.dynamicType.self === type)
            {
                return true;
            }
        }
        
        return false;
    }
    
    /// Gets a single component that matches a given component class type
    /// If no components match the passed component type, nil is returned
    public func getComponentWithType<T: GPComponent>(type: T.Type) -> T?
    {
        for comp in self._components
        {
            if(comp is T)
            {
                return comp as? T;
            }
        }
        
        return nil;
    }
    
    /// Gets a list of components that match a given component class type
    public func getComponentsWithType<T: GPComponent>(type: T.Type) -> [T]
    {
        var ret: [T] = [];
        
        for comp in self._components
        {
            if(comp is T)
            {
                ret += (comp as! T);
            }
        }
        
        return ret;
    }
    
    /// Removes all components that match the given class type
    public func removeComponentsWithType<T: GPComponent>(type: T.Type)
    {
        var i:Int = 0;
        
        while(i < self._components.count)
        {
            if(self._components[i] is T)
            {
                self._components.removeAtIndex(i);
            }
            else
            {
                i++;
            }
        }
    }
}

public func ==(lhs: GPEntity, rhs: GPEntity) -> Bool
{
    return lhs === rhs;
}