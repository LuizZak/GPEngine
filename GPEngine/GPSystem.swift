//
//  GPSystem.swift
//  GPEngine
//
//  Created by Luiz Fernando Silva on 03/08/14.
//  Copyright (c) 2014 Luiz Fernando Silva. All rights reserved.
//

import UIKit

public func ==(lhs: GPSystem, rhs: GPSystem) -> Bool
{
    return lhs === rhs;
}

// Describes a game system, that handles interactions between entities in a game scene
public class GPSystem: Equatable
{
    public var game: GPGame;
    
    /* NEW ENGINE UPDATE MEMBERS */
    public init(game: GPGame)
    {
        self.game = game;
    }
    
    /// Updates a specific space with this system
    public func update(space: GPSpace, _ deltaTime: NSTimeInterval)
    {
        
    }
    
    /// Renders a specific space with this system
    public func render(space: GPSpace)
    {
        
    }
}