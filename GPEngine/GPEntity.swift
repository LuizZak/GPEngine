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
    private var components : [GPComponent] = [];
    
    // The unique identifier for this entity
    var id = 0;
    // A bitmask field used to quickly describe the type of this entity
    var type = 0;
    
    // A node that is associated with this entity
    var node : SKNode;
    
    // The game scene that owns this GPEntity instance
    var gameScene : GPGameScene?;
    
    init(_ node : SKNode)
    {
        self.node = node;
        
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
        self.components += components;
        
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
        self.components += component;
    }
    
    // Internal method that removes components from this entity
    private func internalRemoveComponent(component: GPComponent)
    {
        self.components -= component;
    }
    
    // Returns whether the entity has the given component type inside of it
    func hasComponentType(type: AnyClass) -> Bool
    {
        for comp in self.components
        {
            if(comp.isKindOfClass(type))
            {
                return true;
            }
        }
        
        return false;
    }
}
