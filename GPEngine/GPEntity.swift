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
    func addComponent(component : GPComponent)
    {
        self.components += component;
    }
    
    // Removes a component from this entity
    func removeComponent(component : GPComponent)
    {
        self.components.remove(component);
    }
    
    // Returns whether the entity has the given component type inside of it
    func hasComponentType(type : AnyClass) -> Bool
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
