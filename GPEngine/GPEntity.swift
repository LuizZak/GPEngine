//
//  GPEntity.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit
import SpriteKit

// Describes a game entity
class GPEntity: NSObject
{
    // The internal list of components for this entity
    private var _components : [GPComponent] = [];
    
    // The unique identifier for this entity
    private var _id = 0;
    // A bitmask field used to quickly describe the type of this entity
    private var _type = 0;
    
    // A node that is associated with this entity
    private var _node : SKNode;
    
    // The game scene that owns this GPEntity instance
    var gameScene : GPGameScene?;
    
    // Gets or sets the ID of this entity
    var id: Int { get { return _id; } set { _id = newValue; self.gameScene?.entityModified(self); } }
    // Gets or sets the type of this entity
    var type: Int { get { return _type; } set { _type = newValue; self.gameScene?.entityModified(self); } }
    
    // Gets this entity's node
    var node: SKNode { return _node; }
    
    init(_ node : SKNode)
    {
        self._node = node;
        
        super.init();
    }
    
    // Adds the given component to this entity
    func addComponent(component: GPComponent)
    {
        self.internalAddComponent(component);
        
        // Notify the game scene this entity has been modified
        self.gameScene?.entityModified(self);
    }
    
    // Adds an array of components to this entity
    func addComponents(components: [GPComponent])
    {
        self._components += components;
        
        // Notify the game scene this entity has been modified
        self.gameScene?.entityModified(self);
    }
    
    // Removes a component from this entity
    func removeComponent(component: GPComponent)
    {
        self.internalRemoveComponent(component);
        
        // Notify the game scene this entity has been modified
        self.gameScene?.entityModified(self);
    }
    
    // Intenral method that adds a components to this entity
    private func internalAddComponent(component: GPComponent)
    {
        self._components += component;
    }
    
    // Internal method that removes components from this entity
    private func internalRemoveComponent(component: GPComponent)
    {
        self._components -= component;
    }
    
    // Returns whether the entity has the given component type inside of it
    func hasComponentType(type: GPComponent.Type) -> Bool
    {
        for comp in self._components
        {
            if(comp.isKindOfClass(type))
            {
                return true;
            }
        }
        
        return false;
    }
    
    // Gets a list of components that match a given component class type
    func getComponentsWithType<T: GPComponent>(type: T.Type) -> [T]
    {
        var ret: [T] = [];
        
        for comp in self._components
        {
            if(comp is T)
            {
                ret += (comp as T);
            }
        }
        
        return ret;
    }
    
    // Removes all components that match the given class type
    func removeComponentsWithType(type: GPComponent.Type)
    {
        var i:Int = 0;
        
        while(i < self._components.count)
        {
            if(self._components[i].isKindOfClass(type))
            {
                self._components.removeAtIndex(i);
            }
            else
            {
                i++;
            }
        }
        
        // Notify the game scene this entity has been modified
        self.gameScene?.entityModified(self);
    }
}